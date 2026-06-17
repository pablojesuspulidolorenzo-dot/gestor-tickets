from __future__ import annotations

import json

from sqlalchemy import text
from sqlalchemy.orm import Session

from app.services.ai_llm_call_service import AICallError, call_with_fallback
from app.services.ai_prompt_service import get_active_version

_VALID_TIPOS = frozenset({
    "incidencia", "peticion", "consulta", "respuesta_cliente",
    "agradecimiento", "spam", "ruido",
})
_VALID_PRIORIDADES = frozenset({"baja", "media", "alta", "critica"})


def _get_email_data(db: Session, email_message_id: int) -> dict | None:
    row = db.execute(
        text("""
            SELECT id, subject, from_email, from_name, sent_at, received_at, body_text_preview
            FROM gestor_tickets.email_messages
            WHERE id = :id
        """),
        {"id": email_message_id},
    ).mappings().first()
    return dict(row) if row else None


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
                INSERT INTO gestor_tickets.email_ai_processing (email_message_id, status)
                VALUES (:email_message_id, CAST(:status AS gestor_tickets.ai_processing_status))
                RETURNING id
            """),
            {"email_message_id": email_message_id, "status": status},
        ).scalar_one()
    db.commit()
    return int(record_id)


def _save_processing_result(db: Session, record_id: int, call_id: int, result: dict) -> None:
    summary_json = result.get("summary_json")
    confidence = result.get("extraction_confidence")
    db.execute(
        text("""
            UPDATE gestor_tickets.email_ai_processing SET
                status = 'processed',
                llm_call_history_id = :call_id,
                tipo_correo = :tipo_correo,
                prioridad_sugerida = :prioridad_sugerida,
                accion_sugerida = :accion_sugerida,
                requiere_revision_humana = :requiere_revision_humana,
                body_new_found = :body_new_found,
                needs_thread_context = :needs_thread_context,
                extraction_confidence = :extraction_confidence,
                summary_json = CAST(:summary_json AS jsonb),
                processed_at = now(),
                error_message = NULL,
                updated_at = now()
            WHERE id = :record_id
        """),
        {
            "record_id": record_id,
            "call_id": call_id,
            "tipo_correo": str(result.get("tipo_correo") or "")[:50],
            "prioridad_sugerida": str(result.get("prioridad_sugerida") or "")[:20],
            "accion_sugerida": str(result.get("accion_sugerida") or "")[:500],
            "requiere_revision_humana": bool(result.get("requiere_revision_humana")),
            "body_new_found": bool(result.get("body_new_found")),
            "needs_thread_context": bool(result.get("needs_thread_context")),
            "extraction_confidence": float(confidence) if confidence is not None else None,
            "summary_json": json.dumps(summary_json, ensure_ascii=False) if isinstance(summary_json, dict) else "{}",
        },
    )
    db.commit()


def _save_processing_error(db: Session, record_id: int, error_message: str) -> None:
    db.execute(
        text("""
            UPDATE gestor_tickets.email_ai_processing SET
                status = 'error',
                error_message = :error_message,
                updated_at = now()
            WHERE id = :record_id
        """),
        {"record_id": record_id, "error_message": error_message[:1000]},
    )
    db.commit()


def process_email(db: Session, email_message_id: int, account_id: int, user_id: int) -> dict:
    """
    Analiza un correo archivado con IA (Contrato A).
    Retorna {"ok": True, "result": {...}} o {"ok": False, "error": "...", "error_type": "..."}
    """
    active_version = get_active_version(db, "email_analysis")
    if not active_version:
        return {
            "ok": False,
            "error": "No hay versión activa del prompt 'email_analysis'. Configura un prompt activo en Ajustes IA > Prompts.",
            "error_type": "no_active_prompt",
        }

    email = _get_email_data(db, email_message_id)
    if not email:
        return {"ok": False, "error": "Correo no encontrado en el sistema.", "error_type": "not_found"}

    record_id = _upsert_processing_record(db, email_message_id, status="processing")

    user_content = {
        "email_id": email_message_id,
        "from": f"{email.get('from_name') or ''} <{email.get('from_email') or ''}>".strip(" <>"),
        "subject": email.get("subject") or "",
        "date": str(email.get("sent_at") or email.get("received_at") or ""),
        "body_text": (email.get("body_text_preview") or "")[:3000],
    }

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

    if parsed.get("tipo_correo") not in _VALID_TIPOS:
        parsed["tipo_correo"] = "consulta"
    if parsed.get("prioridad_sugerida") not in _VALID_PRIORIDADES:
        parsed["prioridad_sugerida"] = "media"

    _save_processing_result(db, record_id, call_id, parsed)
    return {"ok": True, "result": parsed}


def get_email_ai_result(db: Session, email_message_id: int) -> dict | None:
    row = db.execute(
        text("""
            SELECT id, status, tipo_correo, prioridad_sugerida, accion_sugerida,
                   requiere_revision_humana, body_new_found, needs_thread_context,
                   extraction_confidence, summary_json, error_message, processed_at
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
