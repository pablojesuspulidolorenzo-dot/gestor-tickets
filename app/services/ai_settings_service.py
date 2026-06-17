from __future__ import annotations

import json
from typing import Any

from sqlalchemy import text
from sqlalchemy.orm import Session

from app.core.security import decrypt_text, encrypt_text


PROVIDER_PRESETS = {
    "gemini": {
        "label": "Google Gemini OpenAI-compatible",
        "base_url": "https://generativelanguage.googleapis.com/v1beta/openai",
        "models_endpoint_path": "/models",
        "chat_endpoint_path": "/chat/completions",
    },
    "groq": {
        "label": "Groq OpenAI-compatible",
        "base_url": "https://api.groq.com/openai/v1",
        "models_endpoint_path": "/models",
        "chat_endpoint_path": "/chat/completions",
    },
    "openrouter": {
        "label": "OpenRouter",
        "base_url": "https://openrouter.ai/api/v1",
        "models_endpoint_path": "/models",
        "chat_endpoint_path": "/chat/completions",
    },
    "mistral": {
        "label": "Mistral",
        "base_url": "https://api.mistral.ai/v1",
        "models_endpoint_path": "/models",
        "chat_endpoint_path": "/chat/completions",
    },
    "generic": {
        "label": "OpenAI-compatible genérico",
        "base_url": "",
        "models_endpoint_path": "/models",
        "chat_endpoint_path": "/chat/completions",
    },
}

DEFAULT_RETRY_POLICY = {
    "max_retries": 1,
    "retry_on": ["timeout", "connection_error", "rate_limited"],
    "do_not_retry_on": ["auth_error", "quota_exceeded", "model_not_found", "invalid_request"],
}

FORBIDDEN_EXTRA_HEADER_NAMES = {"authorization", "x-api-key", "api-key", "apikey", "openai-api-key"}


def _clean(value: str | None) -> str:
    return (value or "").strip()


def _path(value: str | None, default: str) -> str:
    value = _clean(value) or default
    return value if value.startswith("/") else f"/{value}"


def _mask_api_key(ciphertext: str | None) -> str | None:
    if not ciphertext:
        return None
    try:
        plain = decrypt_text(ciphertext)
    except Exception:
        return "****"
    tail = plain[-4:] if len(plain) >= 4 else plain
    if plain.startswith("sk-") and len(plain) > 8:
        return f"sk-...{tail}"
    return f"****{tail}"


def _sanitize_extra_headers(value: dict[str, Any] | None) -> dict[str, str]:
    headers: dict[str, str] = {}
    for key, raw_value in (value or {}).items():
        clean_key = _clean(str(key))
        if not clean_key:
            continue
        lowered = clean_key.lower()
        if lowered in FORBIDDEN_EXTRA_HEADER_NAMES or "token" in lowered or "secret" in lowered or "password" in lowered:
            raise ValueError("Las cabeceras adicionales no pueden contener API keys, tokens ni secretos.")
        headers[clean_key] = str(raw_value)
    return headers


def _row_to_endpoint(row) -> dict:
    item = dict(row)
    item["api_key_masked"] = _mask_api_key(item.pop("api_key_ciphertext", None))
    for key in ("created_at", "updated_at", "last_models_sync_at", "last_validation_at"):
        if item.get(key) is not None:
            item[key] = str(item[key])
    item["retry_policy_json"] = item.get("retry_policy_json") or DEFAULT_RETRY_POLICY
    item["extra_headers_json"] = item.get("extra_headers_json") or {}
    item["reasoning_effort"] = item.get("reasoning_effort") or "none"
    item["temperature"] = float(item["temperature"])
    item["top_p"] = float(item["top_p"])
    item["priority_order"] = int(item.get("priority_order") or 0)
    return item


def _row_to_model(row) -> dict:
    item = dict(row)
    item["last_seen_at"] = str(item["last_seen_at"])
    item["pricing_json"] = item.get("pricing_json") or {}
    item["raw_json"] = item.get("raw_json") or {}
    return item


def _endpoint_select_sql() -> str:
    return """
        SELECT
            id, name, provider_kind, base_url, models_endpoint_path, chat_endpoint_path,
            api_key_ciphertext, default_model, is_active, is_default, timeout_seconds,
            temperature, top_p, max_tokens, enable_thinking, reasoning_effort, daily_limit, free_quota_notes,
            retry_policy_json, extra_headers_json, last_models_sync_at, last_validation_at,
            last_validation_status, last_validation_error_type, last_validation_error_message,
            priority_order, created_at, updated_at
        FROM gestor_tickets.ai_llm_endpoints
    """


def list_endpoints(db: Session) -> list[dict]:
    rows = db.execute(text(_endpoint_select_sql() + " ORDER BY priority_order ASC, id ASC")).mappings().all()
    return [_row_to_endpoint(row) for row in rows]


def get_endpoint(db: Session, endpoint_id: int) -> dict:
    row = db.execute(
        text(_endpoint_select_sql() + " WHERE id = :endpoint_id"),
        {"endpoint_id": endpoint_id},
    ).mappings().first()
    if not row:
        raise ValueError("Endpoint IA no encontrado.")
    return _row_to_endpoint(row)


def get_endpoint_secret(db: Session, endpoint_id: int) -> tuple[dict, str]:
    row = db.execute(
        text(_endpoint_select_sql() + " WHERE id = :endpoint_id"),
        {"endpoint_id": endpoint_id},
    ).mappings().first()
    if not row:
        raise ValueError("Endpoint IA no encontrado.")
    item = dict(row)
    ciphertext = item.get("api_key_ciphertext")
    if not ciphertext:
        raise ValueError("El endpoint no tiene API key configurada.")
    return _row_to_endpoint(item), decrypt_text(ciphertext)


def _values(payload: dict[str, Any], *, existing_ciphertext: str | None = None) -> dict[str, Any]:
    api_key = payload.pop("api_key", None)
    keep_existing = bool(payload.pop("keep_existing_api_key", True))
    if hasattr(api_key, "get_secret_value") and api_key:
        api_key_value = api_key.get_secret_value()
    elif isinstance(api_key, str):
        api_key_value = _clean(api_key) or None
    else:
        api_key_value = None
    ciphertext = existing_ciphertext if keep_existing and not api_key_value else None
    if api_key_value:
        ciphertext = encrypt_text(api_key_value)

    reasoning_effort = _clean(payload.get("reasoning_effort") or "none").lower()
    if reasoning_effort not in {"none", "low", "medium", "high"}:
        raise ValueError("reasoning_effort no valido")

    return {
        "name": _clean(payload.get("name")),
        "provider_kind": _clean(payload.get("provider_kind")) or "generic",
        "base_url": _clean(payload.get("base_url")).rstrip("/"),
        "models_endpoint_path": _path(payload.get("models_endpoint_path"), "/models"),
        "chat_endpoint_path": _path(payload.get("chat_endpoint_path"), "/chat/completions"),
        "api_key_ciphertext": ciphertext,
        "default_model": _clean(payload.get("default_model")) or None,
        "is_active": bool(payload.get("is_active")),
        "is_default": bool(payload.get("is_default")),
        "timeout_seconds": int(payload.get("timeout_seconds") or 60),
        "temperature": float(payload.get("temperature") if payload.get("temperature") is not None else 0.2),
        "top_p": float(payload.get("top_p") if payload.get("top_p") is not None else 1.0),
        "max_tokens": int(payload.get("max_tokens") or 1024),
        "enable_thinking": bool(payload.get("enable_thinking")),
        "reasoning_effort": reasoning_effort,
        "daily_limit": payload.get("daily_limit"),
        "free_quota_notes": _clean(payload.get("free_quota_notes")) or None,
        "retry_policy_json": json.dumps(payload.get("retry_policy_json") or DEFAULT_RETRY_POLICY, ensure_ascii=False),
        "extra_headers_json": json.dumps(_sanitize_extra_headers(payload.get("extra_headers_json")), ensure_ascii=False),
    }


def create_endpoint(db: Session, payload: dict[str, Any]) -> dict:
    values = _values(dict(payload), existing_ciphertext=None)
    if not values["name"] or not values["base_url"]:
        raise ValueError("Nombre y base URL son obligatorios.")

    if values["is_default"]:
        db.execute(text("UPDATE gestor_tickets.ai_llm_endpoints SET is_default = false WHERE is_default IS TRUE"))

    max_priority = db.execute(
        text("SELECT COALESCE(MAX(priority_order), 0) FROM gestor_tickets.ai_llm_endpoints")
    ).scalar_one()
    values["priority_order"] = int(max_priority) + 1

    endpoint_id = db.execute(
        text("""
            INSERT INTO gestor_tickets.ai_llm_endpoints (
                name, provider_kind, base_url, models_endpoint_path, chat_endpoint_path,
                api_key_ciphertext, default_model, is_active, is_default, timeout_seconds,
                temperature, top_p, max_tokens, enable_thinking, reasoning_effort, daily_limit, free_quota_notes,
                retry_policy_json, extra_headers_json, priority_order, updated_at
            )
            VALUES (
                :name, :provider_kind, :base_url, :models_endpoint_path, :chat_endpoint_path,
                :api_key_ciphertext, :default_model, :is_active, :is_default, :timeout_seconds,
                :temperature, :top_p, :max_tokens, :enable_thinking, :reasoning_effort, :daily_limit, :free_quota_notes,
                CAST(:retry_policy_json AS jsonb), CAST(:extra_headers_json AS jsonb), :priority_order, now()
            )
            RETURNING id
        """),
        values,
    ).scalar_one()
    db.commit()
    return get_endpoint(db, int(endpoint_id))


def update_endpoint(db: Session, endpoint_id: int, payload: dict[str, Any]) -> dict:
    existing = db.execute(
        text("SELECT api_key_ciphertext FROM gestor_tickets.ai_llm_endpoints WHERE id = :endpoint_id"),
        {"endpoint_id": endpoint_id},
    ).mappings().first()
    if not existing:
        raise ValueError("Endpoint IA no encontrado.")

    values = _values(dict(payload), existing_ciphertext=existing["api_key_ciphertext"])
    values["endpoint_id"] = endpoint_id
    if not values["name"] or not values["base_url"]:
        raise ValueError("Nombre y base URL son obligatorios.")

    if values["is_default"]:
        db.execute(
            text("UPDATE gestor_tickets.ai_llm_endpoints SET is_default = false WHERE id <> :endpoint_id"),
            {"endpoint_id": endpoint_id},
        )

    db.execute(
        text("""
            UPDATE gestor_tickets.ai_llm_endpoints
            SET name = :name,
                provider_kind = :provider_kind,
                base_url = :base_url,
                models_endpoint_path = :models_endpoint_path,
                chat_endpoint_path = :chat_endpoint_path,
                api_key_ciphertext = :api_key_ciphertext,
                default_model = :default_model,
                is_active = :is_active,
                is_default = :is_default,
                timeout_seconds = :timeout_seconds,
                temperature = :temperature,
                top_p = :top_p,
                max_tokens = :max_tokens,
                enable_thinking = :enable_thinking,
                reasoning_effort = :reasoning_effort,
                daily_limit = :daily_limit,
                free_quota_notes = :free_quota_notes,
                retry_policy_json = CAST(:retry_policy_json AS jsonb),
                extra_headers_json = CAST(:extra_headers_json AS jsonb),
                updated_at = now()
            WHERE id = :endpoint_id
        """),
        values,
    )
    db.commit()
    return get_endpoint(db, endpoint_id)


def set_endpoint_active(db: Session, endpoint_id: int, active: bool) -> dict:
    db.execute(
        text("UPDATE gestor_tickets.ai_llm_endpoints SET is_active = :active, updated_at = now() WHERE id = :endpoint_id"),
        {"endpoint_id": endpoint_id, "active": active},
    )
    db.commit()
    return get_endpoint(db, endpoint_id)


def set_default_endpoint(db: Session, endpoint_id: int) -> dict:
    db.execute(text("UPDATE gestor_tickets.ai_llm_endpoints SET is_default = false WHERE is_default IS TRUE"))
    db.execute(
        text("UPDATE gestor_tickets.ai_llm_endpoints SET is_default = true, is_active = true, updated_at = now() WHERE id = :endpoint_id"),
        {"endpoint_id": endpoint_id},
    )
    db.commit()
    return get_endpoint(db, endpoint_id)


def clone_endpoint(db: Session, endpoint_id: int) -> dict:
    row = db.execute(
        text("SELECT * FROM gestor_tickets.ai_llm_endpoints WHERE id = :id"),
        {"id": endpoint_id},
    ).mappings().first()
    if not row:
        raise ValueError("Endpoint no encontrado.")
    src = dict(row)

    max_priority = db.execute(
        text("SELECT COALESCE(MAX(priority_order), 0) FROM gestor_tickets.ai_llm_endpoints")
    ).scalar_one()

    new_id = db.execute(
        text("""
            INSERT INTO gestor_tickets.ai_llm_endpoints (
                name, provider_kind, base_url, models_endpoint_path, chat_endpoint_path,
                api_key_ciphertext, default_model, is_active, is_default, timeout_seconds,
                temperature, top_p, max_tokens, enable_thinking, reasoning_effort, daily_limit,
                free_quota_notes, retry_policy_json, extra_headers_json, priority_order, updated_at
            )
            VALUES (
                :name, :provider_kind, :base_url, :models_endpoint_path, :chat_endpoint_path,
                :api_key_ciphertext, NULL, false, false, :timeout_seconds,
                :temperature, :top_p, :max_tokens, :enable_thinking, :reasoning_effort, :daily_limit,
                :free_quota_notes, CAST(:retry_policy_json AS jsonb), CAST(:extra_headers_json AS jsonb),
                :priority_order, now()
            )
            RETURNING id
        """),
        {
            "name": f"{src['name']} (copia)",
            "provider_kind": src["provider_kind"],
            "base_url": src["base_url"],
            "models_endpoint_path": src["models_endpoint_path"],
            "chat_endpoint_path": src["chat_endpoint_path"],
            "api_key_ciphertext": src.get("api_key_ciphertext"),
            "timeout_seconds": src["timeout_seconds"],
            "temperature": src["temperature"],
            "top_p": src["top_p"],
            "max_tokens": src["max_tokens"],
            "enable_thinking": src["enable_thinking"],
            "reasoning_effort": src.get("reasoning_effort") or "none",
            "daily_limit": src.get("daily_limit"),
            "free_quota_notes": src.get("free_quota_notes"),
            "retry_policy_json": json.dumps(src.get("retry_policy_json") or DEFAULT_RETRY_POLICY, ensure_ascii=False),
            "extra_headers_json": json.dumps(src.get("extra_headers_json") or {}, ensure_ascii=False),
            "priority_order": int(max_priority) + 1,
        },
    ).scalar_one()
    db.commit()
    return get_endpoint(db, int(new_id))


def move_endpoint(db: Session, endpoint_id: int, direction: str) -> None:
    current_row = db.execute(
        text("SELECT priority_order FROM gestor_tickets.ai_llm_endpoints WHERE id = :id"),
        {"id": endpoint_id},
    ).mappings().first()
    if not current_row:
        raise ValueError("Endpoint no encontrado.")
    current_priority = current_row["priority_order"]

    if direction == "up":
        other = db.execute(
            text("""
                SELECT id, priority_order FROM gestor_tickets.ai_llm_endpoints
                WHERE priority_order < :current ORDER BY priority_order DESC LIMIT 1
            """),
            {"current": current_priority},
        ).mappings().first()
    else:
        other = db.execute(
            text("""
                SELECT id, priority_order FROM gestor_tickets.ai_llm_endpoints
                WHERE priority_order > :current ORDER BY priority_order ASC LIMIT 1
            """),
            {"current": current_priority},
        ).mappings().first()

    if not other:
        return

    db.execute(
        text("UPDATE gestor_tickets.ai_llm_endpoints SET priority_order = :po, updated_at = now() WHERE id = :id"),
        {"po": other["priority_order"], "id": endpoint_id},
    )
    db.execute(
        text("UPDATE gestor_tickets.ai_llm_endpoints SET priority_order = :po, updated_at = now() WHERE id = :id"),
        {"po": current_priority, "id": other["id"]},
    )
    db.commit()


def list_models(db: Session, endpoint_id: int) -> list[dict]:
    rows = db.execute(
        text("""
            SELECT id, endpoint_id, model_id, display_name, owned_by, context_length,
                   model_type, pricing_json, raw_json, is_chat_capable, is_free_hint, last_seen_at
            FROM gestor_tickets.ai_llm_endpoint_models
            WHERE endpoint_id = :endpoint_id
            ORDER BY model_id ASC
        """),
        {"endpoint_id": endpoint_id},
    ).mappings().all()
    return [_row_to_model(row) for row in rows]


def list_validation_logs(db: Session, endpoint_id: int, limit: int = 20) -> list[dict]:
    rows = db.execute(
        text("""
            SELECT id, model_id, operation_type, http_status, success, latency_ms,
                   error_type, error_message, strict_json_ok, thinking_detected, created_at
            FROM gestor_tickets.ai_endpoint_validation_logs
            WHERE endpoint_id = :endpoint_id
            ORDER BY id DESC
            LIMIT :limit
        """),
        {"endpoint_id": endpoint_id, "limit": limit},
    ).mappings().all()
    return [{**dict(row), "created_at": str(row["created_at"])} for row in rows]
