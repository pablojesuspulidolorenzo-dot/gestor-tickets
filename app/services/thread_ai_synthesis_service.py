from __future__ import annotations

import json

from sqlalchemy import text
from sqlalchemy.orm import Session

from app.services.ai_llm_call_service import AICallError, call_with_fallback


SYSTEM_PROMPT_THREAD = (
    "Eres un coordinador de Service Desk. Tu tarea es analizar un hilo cronológico de correos "
    "(de más antiguo a más reciente) y generar una síntesis del estado actual de la incidencia.\n"
    "\n"
    "REGLAS ESTRICTAS:\n"
    "1. Responde ÚNICA Y EXCLUSIVAMENTE con un objeto JSON válido.\n"
    "2. NO uses formato markdown (```json).\n"
    "3. Escribe en español de España, con un tono profesional y técnico.\n"
    "\n"
    "ESQUEMA JSON DE RESPUESTA OBLIGATORIO:\n"
    '{\n'
    '  "short_dialogue_text": "Resumen de 2-3 líneas para seguimiento GLPI.",\n'
    '  "state_summary_json": {\n'
    '    "estado_actual": "pendiente_usuario|pendiente_tecnico|resuelto",\n'
    '    "sintomas_actuales": ["falla tras reiniciar"],\n'
    '    "acciones_ya_realizadas": ["actualizar Windows"],\n'
    '    "bloqueo_actual": "Esperando log del cliente"\n'
    '  }\n'
    '}'
)

_VALID_ESTADOS = frozenset({"pendiente_usuario", "pendiente_tecnico", "resuelto"})


def _get_thread_with_messages(db: Session, thread_id: int) -> tuple[dict | None, list[dict]]:
    thread_row = db.execute(
        text("""
            SELECT id, title, subject_normalized, status, account_id
            FROM gestor_tickets.system_threads
            WHERE id = :thread_id
        """),
        {"thread_id": thread_id},
    ).mappings().first()

    if not thread_row:
        return None, []

    messages = db.execute(
        text("""
            SELECT em.id, em.from_email, em.from_name, em.subject,
                   em.sent_at, em.body_text_preview
            FROM gestor_tickets.email_thread_members etm
            JOIN gestor_tickets.email_messages em ON em.id = etm.email_message_id
            WHERE etm.thread_id = :thread_id AND etm.status = 'active'
            ORDER BY etm.position_asc ASC
        """),
        {"thread_id": thread_id},
    ).mappings().all()

    return dict(thread_row), [dict(m) for m in messages]


def _get_latest_email_id(messages: list[dict]) -> int | None:
    return messages[-1]["id"] if messages else None


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
                    latest_email_message_id = :latest_email_id,
                    updated_at = now()
                WHERE id = :record_id
            """),
            {"status": status, "record_id": record_id, "latest_email_id": latest_email_id},
        )
    else:
        record_id = db.execute(
            text("""
                INSERT INTO gestor_tickets.thread_ai_syntheses
                    (thread_id, latest_email_message_id, status)
                VALUES (
                    :thread_id, :latest_email_id,
                    CAST(:status AS gestor_tickets.ai_processing_status)
                )
                RETURNING id
            """),
            {"thread_id": thread_id, "latest_email_id": latest_email_id, "status": status},
        ).scalar_one()
    db.commit()
    return int(record_id)


def _save_synthesis_result(db: Session, record_id: int, call_id: int, result: dict) -> None:
    state_summary = result.get("state_summary_json")
    db.execute(
        text("""
            UPDATE gestor_tickets.thread_ai_syntheses SET
                status = 'processed',
                llm_call_history_id = :call_id,
                short_dialogue_text = :short_dialogue_text,
                state_summary_json = CAST(:state_summary_json AS jsonb),
                synthesized_at = now(),
                error_message = NULL,
                updated_at = now()
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
        },
    )
    db.commit()


def _save_synthesis_error(db: Session, record_id: int, error_message: str) -> None:
    db.execute(
        text("""
            UPDATE gestor_tickets.thread_ai_syntheses SET
                status = 'error',
                error_message = :error_message,
                updated_at = now()
            WHERE id = :record_id
        """),
        {"record_id": record_id, "error_message": error_message[:1000]},
    )
    db.commit()


def synthesize_thread(db: Session, thread_id: int, account_id: int, user_id: int) -> dict:
    """
    Sintetiza el estado de un hilo operativo con IA (Contrato B).
    Retorna {"ok": True, "result": {...}} o {"ok": False, "error": "...", "error_type": "..."}
    """
    thread, messages = _get_thread_with_messages(db, thread_id)
    if not thread:
        return {"ok": False, "error": "Hilo no encontrado.", "error_type": "not_found"}
    if not messages:
        return {"ok": False, "error": "El hilo no tiene correos para sintetizar.", "error_type": "no_messages"}

    latest_email_id = _get_latest_email_id(messages)
    record_id = _upsert_synthesis_record(db, thread_id, latest_email_id, status="processing")

    user_content = {
        "thread_id": thread_id,
        "subject": thread.get("title") or thread.get("subject_normalized") or "",
        "messages": [
            {
                "date": str(m.get("sent_at") or ""),
                "from": f"{m.get('from_name') or ''} <{m.get('from_email') or ''}>".strip(" <>"),
                "text": (m.get("body_text_preview") or "")[:1500],
            }
            for m in messages
        ],
    }

    try:
        parsed, call_id = call_with_fallback(
            db,
            scope="thread",
            system_prompt=SYSTEM_PROMPT_THREAD,
            user_content_json=user_content,
            account_id=account_id,
            user_id=user_id,
            call_purpose="thread_synthesis",
            related_thread_id=thread_id,
        )
    except AICallError as exc:
        _save_synthesis_error(db, record_id, str(exc))
        return {"ok": False, "error": str(exc), "error_type": exc.error_type}

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

    _save_synthesis_result(db, record_id, call_id, parsed)
    return {"ok": True, "result": parsed}


def get_thread_ai_synthesis(db: Session, thread_id: int) -> dict | None:
    row = db.execute(
        text("""
            SELECT id, status, short_dialogue_text, state_summary_json,
                   error_message, synthesized_at
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
