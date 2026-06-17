from __future__ import annotations

import json

from sqlalchemy import text
from sqlalchemy.orm import Session


def list_call_history(db: Session, limit: int = 50) -> list[dict]:
    rows = db.execute(
        text("""
            SELECT id, scope, call_purpose, model, status,
                   duration_ms, total_tokens, prompt_tokens, completion_tokens,
                   http_status_code, error_type, error_message,
                   related_email_message_id, related_thread_id,
                   json_parse_ok, created_at
            FROM gestor_tickets.ai_call_history
            ORDER BY id DESC
            LIMIT :limit
        """),
        {"limit": limit},
    ).mappings().all()
    result = []
    for row in rows:
        item = dict(row)
        if item.get("created_at"):
            item["created_at"] = str(item["created_at"])
        result.append(item)
    return result


def get_call_detail(db: Session, call_id: int) -> dict | None:
    row = db.execute(
        text("""
            SELECT id, scope, call_purpose, model, endpoint_url, status,
                   duration_ms, total_tokens, prompt_tokens, completion_tokens,
                   http_status_code, error_type, error_message,
                   request_messages_json, response_full_json, response_parsed_json,
                   response_message_content, json_parse_ok, json_validation_ok,
                   related_email_message_id, related_thread_id, created_at
            FROM gestor_tickets.ai_call_history
            WHERE id = :id
        """),
        {"id": call_id},
    ).mappings().first()
    if not row:
        return None
    item = dict(row)
    if item.get("created_at"):
        item["created_at"] = str(item["created_at"])
    for field in ("request_messages_json", "response_full_json", "response_parsed_json"):
        val = item.get(field)
        if val is not None:
            try:
                item[field + "_pretty"] = json.dumps(val, ensure_ascii=False, indent=2)
            except Exception:
                item[field + "_pretty"] = str(val)
        else:
            item[field + "_pretty"] = ""
    return item
