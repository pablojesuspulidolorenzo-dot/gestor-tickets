from __future__ import annotations

import json

from sqlalchemy import text
from sqlalchemy.orm import Session

from app.services.ai_llm_call_service import AICallError, call_with_fallback
from app.services.ai_prompt_service import get_active_version

_VALID_ESTADOS = frozenset({"pendiente_usuario", "pendiente_tecnico", "resuelto"})
_VALID_URGENCIAS = frozenset({"inmediata", "alta", "normal", "baja"})
_VALID_TONOS_EVO = frozenset({"estable", "mejorando", "escalando", "resuelto"})
_VALID_ACCIONES_HILO = frozenset({
    "GENERAR_TICKET", "CERRAR_TICKET", "ESCALAR",
    "INTERVENIR_URGENTE", "PROGRAMAR_REUNION", "ENVIAR_SEGUIMIENTO",
    "ACTUALIZAR_CONTACTO", "ARCHIVAR_HILO", "GENERAR_INFORME",
})


# ─── Consultas de datos ────────────────────────────────────────────────────────

def _get_thread_row(db: Session, thread_id: int) -> dict | None:
    row = db.execute(
        text("""
            SELECT id, title, subject_normalized, status, account_id
            FROM gestor_tickets.system_threads
            WHERE id = :thread_id
        """),
        {"thread_id": thread_id},
    ).mappings().first()
    return dict(row) if row else None


def _get_messages_for_thread(
    db: Session,
    thread_id: int,
    *,
    mode: str,
    top_n: int | None,
) -> list[dict]:
    """Devuelve correos del hilo según el modo de síntesis, siempre en orden cronológico."""
    if mode == "incremental":
        # Solo el más reciente
        rows = db.execute(
            text("""
                SELECT em.id, em.from_email, em.from_name, em.subject,
                       em.sent_at, em.body_text_preview, em.direction
                FROM gestor_tickets.email_thread_members etm
                JOIN gestor_tickets.email_messages em ON em.id = etm.email_message_id
                WHERE etm.thread_id = :tid AND etm.status = 'active'
                ORDER BY em.sent_at DESC NULLS LAST, em.id DESC
                LIMIT 1
            """),
            {"tid": thread_id},
        ).mappings().all()
    elif mode == "top_n" and top_n:
        rows = db.execute(
            text("""
                SELECT em.id, em.from_email, em.from_name, em.subject,
                       em.sent_at, em.body_text_preview, em.direction
                FROM gestor_tickets.email_thread_members etm
                JOIN gestor_tickets.email_messages em ON em.id = etm.email_message_id
                WHERE etm.thread_id = :tid AND etm.status = 'active'
                ORDER BY em.sent_at DESC NULLS LAST, em.id DESC
                LIMIT :n
            """),
            {"tid": thread_id, "n": top_n},
        ).mappings().all()
        rows = list(reversed(list(rows)))
    else:
        rows = db.execute(
            text("""
                SELECT em.id, em.from_email, em.from_name, em.subject,
                       em.sent_at, em.body_text_preview, em.direction
                FROM gestor_tickets.email_thread_members etm
                JOIN gestor_tickets.email_messages em ON em.id = etm.email_message_id
                WHERE etm.thread_id = :tid AND etm.status = 'active'
                ORDER BY etm.position_asc ASC
            """),
            {"tid": thread_id},
        ).mappings().all()
    return [dict(r) for r in rows]


def _get_email_ai_summaries(
    db: Session,
    thread_id: int,
    *,
    top_n: int | None = None,
) -> list[dict]:
    """Síntesis IA procesadas de los correos del hilo, cronológicas."""
    limit_clause = f"LIMIT {int(top_n)}" if top_n else ""
    rows = db.execute(
        text(f"""
            SELECT em.id, em.from_email, em.from_name, em.sent_at, em.direction,
                   eap.tipo_correo, eap.prioridad_sugerida, eap.urgencia_atencion,
                   eap.accion_sugerida, eap.summary_json, eap.tono_cliente,
                   eap.acciones_propuestas_json
            FROM gestor_tickets.email_thread_members etm
            JOIN gestor_tickets.email_messages em ON em.id = etm.email_message_id
            LEFT JOIN gestor_tickets.email_ai_processing eap
                   ON eap.email_message_id = em.id AND eap.status = 'processed'
            WHERE etm.thread_id = :tid AND etm.status = 'active'
            ORDER BY em.sent_at DESC NULLS LAST, em.id DESC
            {limit_clause}
        """),
        {"tid": thread_id},
    ).mappings().all()

    result: list[dict] = []
    for r in reversed(list(rows)):
        entry: dict = {
            "email_id": int(r["id"]),
            "date": str(r.get("sent_at") or ""),
            "from": f"{r.get('from_name') or ''} <{r.get('from_email') or ''}>".strip(" <>"),
            "direction": str(r.get("direction") or ""),
        }
        for f in ("tipo_correo", "prioridad_sugerida", "urgencia_atencion",
                  "tono_cliente", "accion_sugerida"):
            if r.get(f):
                entry[f] = r[f]
        if isinstance(r.get("summary_json"), dict):
            entry["summary"] = r["summary_json"]
        result.append(entry)
    return result


def _get_previous_synthesis(db: Session, thread_id: int) -> dict | None:
    row = db.execute(
        text("""
            SELECT state_summary_json, short_dialogue_text,
                   accion_sugerida, urgencia_atencion
            FROM gestor_tickets.thread_ai_syntheses
            WHERE thread_id = :tid AND status = 'processed'
            ORDER BY id DESC LIMIT 1
        """),
        {"tid": thread_id},
    ).mappings().first()
    return dict(row) if row else None


def _get_linked_tickets(db: Session, thread_id: int) -> list[dict]:
    rows = db.execute(
        text("""
            SELECT gtc.glpi_ticket_id, gtc.title, gtc.status, gtc.urgency
            FROM gestor_tickets.glpi_ticket_thread_links gttl
            JOIN gestor_tickets.glpi_ticket_cache gtc ON gtc.id = gttl.glpi_ticket_cache_id
            WHERE gttl.thread_id = :tid AND gttl.status = 'active'
            ORDER BY gttl.id DESC
        """),
        {"tid": thread_id},
    ).mappings().all()
    return [
        {
            "glpi_ticket_id": r["glpi_ticket_id"],
            "title": str(r.get("title") or ""),
            "status": str(r.get("status") or ""),
            "urgency": str(r.get("urgency") or ""),
        }
        for r in rows
    ]


def _build_participants(messages: list[dict]) -> list[dict]:
    """Extrae participantes activos (remitentes únicos) de los mensajes."""
    seen: dict[str, dict] = {}
    for msg in messages:
        key = str(msg.get("from_email") or "").lower().strip()
        if not key:
            continue
        if key not in seen:
            seen[key] = {
                "nombre": str(msg.get("from_name") or ""),
                "email": key,
                "emails_enviados": 0,
                "ultimo_email": str(msg.get("sent_at") or ""),
            }
        seen[key]["emails_enviados"] += 1
        ts = str(msg.get("sent_at") or "")
        if ts > seen[key]["ultimo_email"]:
            seen[key]["ultimo_email"] = ts
    return list(seen.values())


# ─── Persistencia ─────────────────────────────────────────────────────────────

def _upsert_synthesis_record(
    db: Session,
    thread_id: int,
    latest_email_id: int | None,
    *,
    status: str,
) -> int:
    existing = db.execute(
        text("""
            SELECT id FROM gestor_tickets.thread_ai_syntheses
            WHERE thread_id = :id ORDER BY id DESC LIMIT 1
        """),
        {"id": thread_id},
    ).mappings().first()

    if existing:
        record_id = existing["id"]
        db.execute(
            text("""
                UPDATE gestor_tickets.thread_ai_syntheses
                SET status = CAST(:status AS gestor_tickets.ai_processing_status),
                    latest_email_message_id = :lei,
                    updated_at = now()
                WHERE id = :record_id
            """),
            {"status": status, "record_id": record_id, "lei": latest_email_id},
        )
    else:
        record_id = db.execute(
            text("""
                INSERT INTO gestor_tickets.thread_ai_syntheses
                    (thread_id, latest_email_message_id, status)
                VALUES (:tid, :lei,
                        CAST(:status AS gestor_tickets.ai_processing_status))
                RETURNING id
            """),
            {"tid": thread_id, "lei": latest_email_id, "status": status},
        ).scalar_one()
    db.commit()
    return int(record_id)


def _validate_acciones_hilo(raw: object) -> list[dict]:
    if not isinstance(raw, list):
        return []
    result: list[dict] = []
    for item in raw:
        if not isinstance(item, dict):
            continue
        accion = str(item.get("accion") or "")
        if accion not in _VALID_ACCIONES_HILO:
            continue
        result.append({
            "accion": accion,
            "confianza": min(1.0, max(0.0, float(item.get("confianza", 0.5)))),
            "motivo": str(item.get("motivo") or "")[:500],
        })
    return result


def _save_synthesis_result(
    db: Session,
    record_id: int,
    call_id: int,
    result: dict,
) -> None:
    state_summary = result.get("state_summary_json")
    acciones = _validate_acciones_hilo(result.get("acciones_propuestas_hilo"))
    participantes = result.get("participantes_activos") if isinstance(result.get("participantes_activos"), list) else None

    top_accion = acciones[0]["accion"] if acciones else str(result.get("accion_sugerida_hilo") or "")[:100] or None

    db.execute(
        text("""
            UPDATE gestor_tickets.thread_ai_syntheses SET
                status                 = 'processed',
                llm_call_history_id    = :call_id,
                short_dialogue_text    = :short_dialogue_text,
                state_summary_json     = CAST(:state_summary_json AS jsonb),
                accion_sugerida        = :accion_sugerida,
                urgencia_atencion      = :urgencia_atencion,
                tono_evolucion         = :tono_evolucion,
                participantes_json     = CAST(:participantes_json AS jsonb),
                acciones_propuestas_json = CAST(:acciones_propuestas_json AS jsonb),
                synthesized_at         = now(),
                error_message          = NULL,
                updated_at             = now()
            WHERE id = :record_id
        """),
        {
            "record_id": record_id,
            "call_id": call_id,
            "short_dialogue_text": str(result.get("short_dialogue_text") or "")[:2000],
            "state_summary_json": (
                json.dumps(state_summary, ensure_ascii=False)
                if isinstance(state_summary, dict)
                else "{}"
            ),
            "accion_sugerida": top_accion,
            "urgencia_atencion": str(result.get("urgencia_atencion") or "")[:20] or None,
            "tono_evolucion": str(result.get("tono_evolucion") or "")[:30] or None,
            "participantes_json": json.dumps(participantes, ensure_ascii=False) if participantes else "null",
            "acciones_propuestas_json": json.dumps(acciones, ensure_ascii=False),
        },
    )
    db.commit()


def _save_synthesis_error(db: Session, record_id: int, error_message: str) -> None:
    db.execute(
        text("""
            UPDATE gestor_tickets.thread_ai_syntheses SET
                status = 'error',
                error_message = :msg,
                updated_at = now()
            WHERE id = :record_id
        """),
        {"record_id": record_id, "msg": error_message[:1000]},
    )
    db.commit()


# ─── Entrada pública ──────────────────────────────────────────────────────────

def synthesize_thread(
    db: Session,
    thread_id: int,
    account_id: int,
    user_id: int,
    *,
    mode: str | None = None,
    top_n: int | None = None,
) -> dict:
    """
    Sintetiza el estado de un hilo con IA (Contrato B v2).

    Modos:
    - 'all'         (defecto): síntesis de todos los correos del hilo
    - 'top_n'       : síntesis de los N correos más recientes
    - 'incremental' : último correo + síntesis previa del hilo
    """
    active_version = get_active_version(db, "thread_synthesis")
    if not active_version:
        return {
            "ok": False,
            "error": "No hay versión activa del prompt 'thread_synthesis'.",
            "error_type": "no_active_prompt",
        }

    params = active_version.get("params_json") or {}
    if isinstance(params, str):
        try:
            params = json.loads(params)
        except Exception:
            params = {}

    effective_mode = mode or str(params.get("synthesis_mode", "all"))
    effective_top_n = top_n or (int(params.get("synthesis_top_n")) if params.get("synthesis_top_n") else None)
    if effective_mode not in ("all", "top_n", "incremental"):
        effective_mode = "all"

    thread = _get_thread_row(db, thread_id)
    if not thread:
        return {"ok": False, "error": "Hilo no encontrado.", "error_type": "not_found"}

    messages = _get_messages_for_thread(db, thread_id, mode=effective_mode, top_n=effective_top_n)
    if not messages:
        return {"ok": False, "error": "El hilo no tiene correos.", "error_type": "no_messages"}

    latest_email_id = messages[-1]["id"]
    record_id = _upsert_synthesis_record(db, thread_id, latest_email_id, status="processing")

    # Síntesis IA previas de los correos
    email_summaries = _get_email_ai_summaries(
        db, thread_id,
        top_n=effective_top_n if effective_mode == "top_n" else None,
    )

    # Síntesis previa del hilo (para modo incremental)
    previous_synthesis = _get_previous_synthesis(db, thread_id) if effective_mode == "incremental" else None

    linked_tickets = _get_linked_tickets(db, thread_id)
    participants = _build_participants(messages)

    max_body = int(params.get("max_body_chars_per_message", 1500))

    user_content: dict = {
        "thread_id": thread_id,
        "subject": thread.get("title") or thread.get("subject_normalized") or "",
        "synthesis_mode": effective_mode,
    }

    if effective_mode == "incremental" and previous_synthesis:
        last = messages[-1]
        user_content["latest_email"] = {
            "date": str(last.get("sent_at") or ""),
            "from": f"{last.get('from_name') or ''} <{last.get('from_email') or ''}>".strip(" <>"),
            "text": (last.get("body_text_preview") or "")[:max_body],
        }
        user_content["previous_synthesis"] = {
            "state_summary": previous_synthesis.get("state_summary_json"),
            "short_dialogue": previous_synthesis.get("short_dialogue_text"),
            "last_action": previous_synthesis.get("accion_sugerida"),
            "urgency": previous_synthesis.get("urgencia_atencion"),
        }
    elif email_summaries and any(s.get("summary") for s in email_summaries):
        # Hay síntesis IA previas de correos individuales → usarlas
        user_content["email_summaries"] = email_summaries
    else:
        # Fallback: texto plano de los correos
        user_content["messages"] = [
            {
                "date": str(m.get("sent_at") or ""),
                "from": f"{m.get('from_name') or ''} <{m.get('from_email') or ''}>".strip(" <>"),
                "text": (m.get("body_text_preview") or "")[:max_body],
            }
            for m in messages
        ]

    if linked_tickets:
        user_content["linked_tickets"] = linked_tickets
    if participants:
        user_content["known_participants"] = participants

    try:
        parsed, call_id = call_with_fallback(
            db,
            scope="thread",
            system_prompt=active_version["system_prompt_template"],
            user_content_json=user_content,
            account_id=account_id,
            user_id=user_id,
            call_purpose="thread_synthesis",
            related_thread_id=thread_id,
            prompt_version_id=int(active_version["id"]),
        )
    except AICallError as exc:
        _save_synthesis_error(db, record_id, str(exc))
        return {"ok": False, "error": str(exc), "error_type": exc.error_type}

    # Normalizar
    state_summary = parsed.get("state_summary_json")
    if isinstance(state_summary, dict):
        if state_summary.get("estado_actual") not in _VALID_ESTADOS:
            state_summary["estado_actual"] = "pendiente_tecnico"
    else:
        parsed["state_summary_json"] = {
            "estado_actual": "pendiente_tecnico",
            "sintomas_actuales": [],
            "acciones_ya_realizadas": [],
            "bloqueo_actual": "",
        }

    if parsed.get("urgencia_atencion") not in _VALID_URGENCIAS:
        parsed["urgencia_atencion"] = "normal"

    _save_synthesis_result(db, record_id, call_id, parsed)
    # Devolver el registro guardado en BD (claves consistentes con get_thread_ai_synthesis)
    saved = get_thread_ai_synthesis(db, thread_id)
    return {"ok": True, "result": saved}


def get_thread_ai_synthesis(db: Session, thread_id: int) -> dict | None:
    row = db.execute(
        text("""
            SELECT id, status, short_dialogue_text, state_summary_json,
                   error_message, synthesized_at,
                   accion_sugerida, urgencia_atencion, tono_evolucion,
                   participantes_json, acciones_propuestas_json
            FROM gestor_tickets.thread_ai_syntheses
            WHERE thread_id = :thread_id
            ORDER BY id DESC LIMIT 1
        """),
        {"thread_id": thread_id},
    ).mappings().first()
    if not row:
        return None
    result = dict(row)
    if result.get("synthesized_at"):
        result["synthesized_at"] = str(result["synthesized_at"])
    return result
