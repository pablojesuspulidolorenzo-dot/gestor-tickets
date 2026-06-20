from __future__ import annotations

import datetime as dt
import json

from sqlalchemy import text
from sqlalchemy.orm import Session

from app.services.ai_llm_call_service import AICallError, call_with_fallback
from app.services.ai_prompt_service import get_active_version
from app.services.contact_book_service import upsert_contact

_VALID_TIPOS = frozenset({
    "incidencia", "peticion", "consulta", "respuesta_cliente",
    "agradecimiento", "spam", "ruido",
})
_VALID_PRIORIDADES = frozenset({"baja", "media", "alta", "critica"})
_VALID_URGENCIAS = frozenset({"inmediata", "alta", "normal", "baja"})
_VALID_TONOS = frozenset({"neutro", "satisfecho", "impaciente", "frustrado", "critico"})
_VALID_DESTINATARIO = frozenset({"cuenta_colaborativa", "usuario_personal", "copia", "desconocido"})
_VALID_ACCIONES = frozenset({
    "GENERAR_TICKET", "ACTUALIZAR_TICKET", "CERRAR_TICKET", "REABRIR_TICKET",
    "ESCALAR_TICKET", "ASIGNAR_TICKET", "RESPONDER_CORREO", "SOLICITAR_INFO_ADICIONAL",
    "FUSIONAR_HILO", "CREAR_EVENTO_CALENDARIO", "ACTUALIZAR_CONTACTO",
    "DERIVAR_EXTERNO", "IGNORAR",
})


# ─── Consultas de datos ────────────────────────────────────────────────────────

def _get_email_data(db: Session, email_message_id: int) -> dict | None:
    row = db.execute(
        text("""
            SELECT id, subject, from_email, from_name, sent_at, received_at,
                   body_text_preview, direction, account_id
            FROM gestor_tickets.email_messages
            WHERE id = :id
        """),
        {"id": email_message_id},
    ).mappings().first()
    return dict(row) if row else None


def _get_account_email(db: Session, account_id: int) -> str:
    val = db.execute(
        text("SELECT email::text FROM gestor_tickets.collaborative_accounts WHERE id = :id"),
        {"id": account_id},
    ).scalar_one_or_none()
    return str(val) if val else ""


def _get_addressing(
    db: Session,
    *,
    email_message_id: int,
    account_email: str,
) -> dict:
    """Determina si el correo va al TO de la cuenta, solo CC, o a usuarios directos."""
    rows = db.execute(
        text("""
            SELECT recipient_type, email::text
            FROM gestor_tickets.email_recipients
            WHERE email_message_id = :id
            ORDER BY position
        """),
        {"id": email_message_id},
    ).mappings().all()

    to_account = False
    cc_account = False
    to_users: list[str] = []
    reply_to: str | None = None
    account_lower = account_email.lower()

    for r in rows:
        email_lower = str(r["email"]).lower()
        rt = str(r["recipient_type"])
        if rt == "reply_to":
            reply_to = str(r["email"])
            continue
        if email_lower == account_lower:
            if rt == "to":
                to_account = True
            elif rt == "cc":
                cc_account = True
        elif rt == "to":
            to_users.append(str(r["email"]))

    if to_account:
        destinatario_tipo = "cuenta_colaborativa"
    elif cc_account and to_users:
        destinatario_tipo = "copia"
    elif to_users:
        destinatario_tipo = "usuario_personal"
    else:
        destinatario_tipo = "desconocido"

    return {
        "to_account": to_account,
        "to_users_direct": to_users,
        "cc_only": cc_account and not to_account,
        "reply_to": reply_to,
        "destinatario_tipo": destinatario_tipo,
    }


def _get_thread_id_for_email(db: Session, email_message_id: int) -> int | None:
    row = db.execute(
        text("""
            SELECT thread_id
            FROM gestor_tickets.email_thread_members
            WHERE email_message_id = :id AND status = 'active'
            ORDER BY id LIMIT 1
        """),
        {"id": email_message_id},
    ).scalar_one_or_none()
    return int(row) if row is not None else None


def _get_thread_context(
    db: Session,
    *,
    email_message_id: int,
    thread_id: int,
    prior_context_count: int,
) -> dict:
    """Estadísticas del hilo + síntesis de los N correos anteriores al actual."""
    stats = db.execute(
        text("""
            SELECT COUNT(*) AS total_emails,
                   MIN(em.sent_at) AS first_at,
                   MAX(em.sent_at) AS last_at
            FROM gestor_tickets.email_thread_members etm
            JOIN gestor_tickets.email_messages em ON em.id = etm.email_message_id
            WHERE etm.thread_id = :thread_id AND etm.status = 'active'
        """),
        {"thread_id": thread_id},
    ).mappings().first()

    now = dt.datetime.now(dt.timezone.utc)
    total_emails = int(stats["total_emails"] or 0) if stats else 0
    duration_hours: float | None = None
    hours_since_last: float | None = None

    if stats and stats["first_at"] and stats["last_at"]:
        first = stats["first_at"]
        last = stats["last_at"]
        if first.tzinfo is None:
            first = first.replace(tzinfo=dt.timezone.utc)
        if last.tzinfo is None:
            last = last.replace(tzinfo=dt.timezone.utc)
        duration_hours = round((last - first).total_seconds() / 3600, 1)
        hours_since_last = round((now - last).total_seconds() / 3600, 1)

    # Síntesis de los N correos anteriores al actual (por sent_at / id)
    prior_rows = db.execute(
        text("""
            SELECT em.id AS email_id, em.sent_at, em.from_name, em.from_email,
                   em.direction, eap.tipo_correo, eap.prioridad_sugerida,
                   eap.urgencia_atencion, eap.accion_sugerida, eap.summary_json,
                   eap.tono_cliente
            FROM gestor_tickets.email_thread_members etm
            JOIN gestor_tickets.email_messages em ON em.id = etm.email_message_id
            LEFT JOIN gestor_tickets.email_ai_processing eap
                   ON eap.email_message_id = em.id AND eap.status = 'processed'
            WHERE etm.thread_id = :thread_id
              AND etm.status = 'active'
              AND em.id < :current_id
            ORDER BY em.sent_at ASC NULLS LAST, em.id ASC
            LIMIT :lim
        """),
        {"thread_id": thread_id, "current_id": email_message_id, "lim": prior_context_count},
    ).mappings().all()

    summaries = []
    for r in prior_rows:
        entry: dict = {
            "email_id": int(r["email_id"]),
            "date": str(r.get("sent_at") or ""),
            "from": f"{r.get('from_name') or ''} <{r.get('from_email') or ''}>".strip(" <>"),
            "direction": str(r.get("direction") or "unknown"),
        }
        for f in ("tipo_correo", "prioridad_sugerida", "urgencia_atencion",
                  "accion_sugerida", "tono_cliente"):
            if r.get(f):
                entry[f] = r[f]
        if isinstance(r.get("summary_json"), dict):
            entry["summary"] = r["summary_json"]
        summaries.append(entry)

    return {
        "thread_id": thread_id,
        "total_emails_in_thread": total_emails,
        "thread_duration_hours": duration_hours,
        "hours_since_last_response": hours_since_last,
        "prior_email_summaries": summaries,
    }


def _get_linked_tickets(db: Session, *, thread_id: int) -> list[dict]:
    rows = db.execute(
        text("""
            SELECT gtc.glpi_ticket_id, gtc.title, gtc.status,
                   gtc.urgency, gtc.assignee_json, gtc.last_sync_at
            FROM gestor_tickets.glpi_ticket_thread_links gttl
            JOIN gestor_tickets.glpi_ticket_cache gtc ON gtc.id = gttl.glpi_ticket_cache_id
            WHERE gttl.thread_id = :thread_id AND gttl.status = 'active'
            ORDER BY gttl.id DESC
        """),
        {"thread_id": thread_id},
    ).mappings().all()

    result = []
    for r in rows:
        item: dict = {
            "glpi_ticket_id": r["glpi_ticket_id"],
            "title": str(r.get("title") or ""),
            "status": str(r.get("status") or ""),
        }
        if r.get("urgency"):
            item["urgency"] = str(r["urgency"])
        if r.get("last_sync_at"):
            item["last_update"] = str(r["last_sync_at"])[:16]
        result.append(item)
    return result


def _get_known_sender(
    db: Session,
    *,
    account_id: int,
    from_email: str,
) -> dict | None:
    row = db.execute(
        text("""
            SELECT email::text, name, phone, company, last_seen_at
            FROM gestor_tickets.contact_book
            WHERE account_id = :account_id AND email = :email
        """),
        {"account_id": account_id, "email": from_email},
    ).mappings().first()
    if not row:
        return None
    return {
        "found_in_contacts": True,
        "name": row.get("name"),
        "phone": row.get("phone"),
        "company": row.get("company"),
        "last_contact_date": str(row["last_seen_at"])[:10] if row.get("last_seen_at") else None,
    }


# ─── Persistencia ─────────────────────────────────────────────────────────────

def _upsert_processing_record(db: Session, email_message_id: int, *, status: str) -> int:
    existing = db.execute(
        text("""
            SELECT id FROM gestor_tickets.email_ai_processing
            WHERE email_message_id = :id ORDER BY id DESC LIMIT 1
        """),
        {"id": email_message_id},
    ).mappings().first()

    if existing:
        record_id = existing["id"]
        db.execute(
            text("""
                UPDATE gestor_tickets.email_ai_processing
                SET status = CAST(:status AS gestor_tickets.ai_processing_status),
                    updated_at = now()
                WHERE id = :record_id
            """),
            {"status": status, "record_id": record_id},
        )
    else:
        record_id = db.execute(
            text("""
                INSERT INTO gestor_tickets.email_ai_processing
                    (email_message_id, status)
                VALUES (:eid, CAST(:status AS gestor_tickets.ai_processing_status))
                RETURNING id
            """),
            {"eid": email_message_id, "status": status},
        ).scalar_one()
    db.commit()
    return int(record_id)


def _validate_acciones(raw: object) -> list[dict]:
    if not isinstance(raw, list):
        return []
    result: list[dict] = []
    for item in raw:
        if not isinstance(item, dict):
            continue
        accion = str(item.get("accion") or "")
        if accion not in _VALID_ACCIONES:
            continue
        entry: dict = {
            "accion": accion,
            "confianza": min(1.0, max(0.0, float(item.get("confianza", 0.5)))),
            "motivo": str(item.get("motivo") or "")[:500],
        }
        if isinstance(item.get("datos"), dict):
            entry["datos"] = item["datos"]
        result.append(entry)
    return result


def _save_processing_result(
    db: Session,
    record_id: int,
    call_id: int,
    result: dict,
    destinatario_tipo: str,
) -> None:
    summary_json = result.get("summary_json")
    confidence = result.get("extraction_confidence")
    acciones = _validate_acciones(result.get("acciones_propuestas"))
    evento = result.get("evento_calendario_json") if isinstance(result.get("evento_calendario_json"), dict) else None
    contactos = result.get("contactos_detectados") if isinstance(result.get("contactos_detectados"), list) else None

    top_accion = acciones[0]["accion"] if acciones else str(result.get("accion_sugerida") or "")[:500]

    db.execute(
        text("""
            UPDATE gestor_tickets.email_ai_processing SET
                status                   = 'processed',
                llm_call_history_id      = :call_id,
                tipo_correo              = :tipo_correo,
                prioridad_sugerida       = :prioridad_sugerida,
                accion_sugerida          = :accion_sugerida,
                requiere_revision_humana = :requiere_revision_humana,
                body_new_found           = :body_new_found,
                needs_thread_context     = :needs_thread_context,
                extraction_confidence    = :extraction_confidence,
                summary_json             = CAST(:summary_json AS jsonb),
                urgencia_atencion        = :urgencia_atencion,
                destinatario_tipo        = :destinatario_tipo,
                tono_cliente             = :tono_cliente,
                acciones_propuestas_json = CAST(:acciones_propuestas_json AS jsonb),
                evento_calendario_json   = CAST(:evento_calendario_json AS jsonb),
                contactos_detectados_json= CAST(:contactos_detectados_json AS jsonb),
                processed_at             = now(),
                error_message            = NULL,
                updated_at               = now()
            WHERE id = :record_id
        """),
        {
            "record_id": record_id,
            "call_id": call_id,
            "tipo_correo": str(result.get("tipo_correo") or "")[:50],
            "prioridad_sugerida": str(result.get("prioridad_sugerida") or "")[:20],
            "accion_sugerida": str(top_accion)[:500],
            "requiere_revision_humana": bool(result.get("requiere_revision_humana")),
            "body_new_found": bool(result.get("body_new_found")),
            "needs_thread_context": bool(result.get("needs_thread_context")),
            "extraction_confidence": float(confidence) if confidence is not None else None,
            "summary_json": json.dumps(summary_json, ensure_ascii=False) if isinstance(summary_json, dict) else "{}",
            "urgencia_atencion": str(result.get("urgencia_atencion") or "")[:20] or None,
            "destinatario_tipo": str(result.get("destinatario_tipo") or destinatario_tipo)[:50] or None,
            "tono_cliente": str(result.get("tono_cliente") or "")[:30] or None,
            "acciones_propuestas_json": json.dumps(acciones, ensure_ascii=False),
            "evento_calendario_json": json.dumps(evento, ensure_ascii=False) if evento else "null",
            "contactos_detectados_json": json.dumps(contactos, ensure_ascii=False) if contactos else "null",
        },
    )
    db.commit()


def _save_processing_error(db: Session, record_id: int, error_message: str) -> None:
    db.execute(
        text("""
            UPDATE gestor_tickets.email_ai_processing SET
                status = 'error',
                error_message = :msg,
                updated_at = now()
            WHERE id = :record_id
        """),
        {"record_id": record_id, "msg": error_message[:1000]},
    )
    db.commit()


def _process_detected_contacts(
    db: Session,
    *,
    account_id: int,
    contactos: list,
) -> None:
    for c in contactos:
        if not isinstance(c, dict):
            continue
        email = str(c.get("email") or "").strip()
        if not email or "@" not in email:
            continue
        try:
            upsert_contact(
                db,
                account_id=account_id,
                email=email,
                name=str(c.get("nombre") or "").strip() or None,
                phone=str(c.get("telefono") or "").strip() or None,
                company=str(c.get("empresa") or "").strip() or None,
                source="ai_detected",
            )
        except Exception:
            pass


# ─── Entrada pública ──────────────────────────────────────────────────────────

def process_email(
    db: Session,
    email_message_id: int,
    account_id: int,
    user_id: int | None,
    *,
    prior_context_count: int | None = None,
) -> dict:
    """
    Analiza un correo archivado con IA (Contrato A v2).
    Incluye contexto del hilo, tickets vinculados, remitente conocido y
    detección de acciones, eventos de calendario y contactos.
    """
    active_version = get_active_version(db, "email_analysis")
    if not active_version:
        return {
            "ok": False,
            "error": "No hay versión activa del prompt 'email_analysis'.",
            "error_type": "no_active_prompt",
        }

    params = active_version.get("params_json") or {}
    if isinstance(params, str):
        try:
            params = json.loads(params)
        except Exception:
            params = {}
    ctx_count = (
        prior_context_count
        if prior_context_count is not None
        else int(params.get("prior_context_count", 5))
    )

    email = _get_email_data(db, email_message_id)
    if not email:
        return {"ok": False, "error": "Correo no encontrado.", "error_type": "not_found"}

    account_email = _get_account_email(db, account_id)
    record_id = _upsert_processing_record(db, email_message_id, status="processing")

    addressing = _get_addressing(
        db, email_message_id=email_message_id, account_email=account_email
    )

    thread_id = _get_thread_id_for_email(db, email_message_id)
    thread_context: dict = {}
    linked_tickets: list = []
    if thread_id:
        thread_context = _get_thread_context(
            db,
            email_message_id=email_message_id,
            thread_id=thread_id,
            prior_context_count=ctx_count,
        )
        linked_tickets = _get_linked_tickets(db, thread_id=thread_id)

    from_email = str(email.get("from_email") or "")
    known_sender = (
        _get_known_sender(db, account_id=account_id, from_email=from_email)
        if from_email else None
    )

    # Construir payload para el LLM (Contrato A v2)
    user_content: dict = {
        "email_id": email_message_id,
        "from": f"{email.get('from_name') or ''} <{from_email}>".strip(" <>"),
        "subject": email.get("subject") or "",
        "date": str(email.get("sent_at") or email.get("received_at") or ""),
        "body_text": (email.get("body_text_preview") or "")[:3000],
        "addressing": {
            "to_account": addressing["to_account"],
            "to_users_direct": addressing["to_users_direct"],
            "cc_only": addressing["cc_only"],
            "reply_to": addressing.get("reply_to"),
        },
    }
    if thread_context:
        user_content["thread_context"] = thread_context
    if linked_tickets:
        user_content["linked_tickets"] = linked_tickets
    if known_sender:
        user_content["known_sender"] = known_sender

    try:
        parsed, call_id = call_with_fallback(
            db,
            scope="email",
            system_prompt=active_version["system_prompt_template"],
            user_content_json=user_content,
            account_id=account_id,
            user_id=user_id,
            call_purpose="email_analysis",
            related_email_id=email_message_id,
            prompt_version_id=int(active_version["id"]),
        )
    except AICallError as exc:
        _save_processing_error(db, record_id, str(exc))
        return {"ok": False, "error": str(exc), "error_type": exc.error_type}

    # Normalizar valores controlados
    if parsed.get("tipo_correo") not in _VALID_TIPOS:
        parsed["tipo_correo"] = "consulta"
    if parsed.get("prioridad_sugerida") not in _VALID_PRIORIDADES:
        parsed["prioridad_sugerida"] = "media"
    if parsed.get("urgencia_atencion") not in _VALID_URGENCIAS:
        parsed["urgencia_atencion"] = "normal"

    # Persistir contactos detectados en la libreta
    contactos = parsed.get("contactos_detectados")
    if isinstance(contactos, list):
        _process_detected_contacts(db, account_id=account_id, contactos=contactos)

    _save_processing_result(db, record_id, call_id, parsed, addressing["destinatario_tipo"])
    # Devolver el registro guardado en BD (claves consistentes con get_email_ai_result)
    saved = get_email_ai_result(db, email_message_id)
    return {"ok": True, "result": saved}


def get_email_ai_result(db: Session, email_message_id: int) -> dict | None:
    row = db.execute(
        text("""
            SELECT id, status, tipo_correo, prioridad_sugerida, accion_sugerida,
                   requiere_revision_humana, body_new_found, needs_thread_context,
                   extraction_confidence, summary_json, error_message, processed_at,
                   urgencia_atencion, destinatario_tipo, tono_cliente,
                   acciones_propuestas_json, evento_calendario_json,
                   contactos_detectados_json
            FROM gestor_tickets.email_ai_processing
            WHERE email_message_id = :id
            ORDER BY id DESC LIMIT 1
        """),
        {"id": email_message_id},
    ).mappings().first()
    if not row:
        return None
    result = dict(row)
    if result.get("processed_at"):
        result["processed_at"] = str(result["processed_at"])
    return result
