from __future__ import annotations

import json
import time
from typing import Any
from urllib.parse import urljoin

import httpx
from sqlalchemy import text
from sqlalchemy.orm import Session

from app.core.security import decrypt_text
from app.services.ai_model_discovery_service import (
    FALLBACK_ERROR_TYPES,
    _apply_reasoning_payload,
    _classify_error,
    _extract_chat_content,
    _parse_llm_json,
    _redact_error_message,
    _strip_thinking_blocks,
)


def _join_url(base_url: str, path: str) -> str:
    return urljoin(base_url.rstrip("/") + "/", path.lstrip("/"))


def _get_active_endpoints(db: Session) -> list[dict]:
    rows = db.execute(
        text("""
            SELECT id, name, base_url, chat_endpoint_path, api_key_ciphertext,
                   default_model, timeout_seconds, temperature, top_p, max_tokens,
                   enable_thinking, reasoning_effort, extra_headers_json, provider_kind
            FROM gestor_tickets.ai_llm_endpoints
            WHERE is_active = true
              AND default_model IS NOT NULL
              AND api_key_ciphertext IS NOT NULL
            ORDER BY priority_order ASC, id ASC
        """)
    ).mappings().all()
    return [dict(r) for r in rows]


def _create_call_record(
    db: Session,
    *,
    scope: str,
    account_id: int,
    user_id: int,
    call_purpose: str,
    endpoint: dict,
    endpoint_url: str,
    messages: list[dict],
    related_email_id: int | None,
    related_thread_id: int | None,
) -> int:
    row = db.execute(
        text("""
            INSERT INTO gestor_tickets.ai_call_history (
                account_id, created_by_user_id,
                scope, call_source, call_purpose,
                model, endpoint_url, enable_thinking,
                temperature, top_p, max_tokens, timeout_seconds,
                status, request_messages_json,
                related_email_message_id, related_thread_id
            ) VALUES (
                :account_id, :user_id,
                CAST(:scope AS gestor_tickets.ai_scope), 'manual_ui', :call_purpose,
                :model, :endpoint_url, :enable_thinking,
                :temperature, :top_p, :max_tokens, :timeout_seconds,
                'pending', CAST(:messages AS jsonb),
                :related_email_id, :related_thread_id
            )
            RETURNING id
        """),
        {
            "account_id": account_id,
            "user_id": user_id,
            "scope": scope,
            "call_purpose": call_purpose,
            "model": endpoint.get("default_model"),
            "endpoint_url": endpoint_url,
            "enable_thinking": bool(endpoint.get("enable_thinking")),
            "temperature": float(endpoint.get("temperature") or 0.2),
            "top_p": float(endpoint.get("top_p") or 1.0),
            "max_tokens": int(endpoint.get("max_tokens") or 1024),
            "timeout_seconds": int(endpoint.get("timeout_seconds") or 60),
            "messages": json.dumps(messages, ensure_ascii=False),
            "related_email_id": related_email_id,
            "related_thread_id": related_thread_id,
        },
    ).scalar_one()
    db.commit()
    return int(row)


def _update_call_success(
    db: Session,
    call_id: int,
    *,
    duration_ms: int,
    http_status: int,
    response_full: dict,
    response_content: str,
    parsed_json: Any,
    is_strict: bool,
    prompt_tokens: int | None,
    completion_tokens: int | None,
    total_tokens: int | None,
) -> None:
    db.execute(
        text("""
            UPDATE gestor_tickets.ai_call_history SET
                status = 'success',
                duration_ms = :duration_ms,
                http_status_code = :http_status,
                response_full_json = CAST(:response_full AS jsonb),
                response_message_content = :response_content,
                response_parsed_json = CAST(:parsed_json AS jsonb),
                json_parse_ok = true,
                json_validation_ok = :is_strict,
                prompt_tokens = :prompt_tokens,
                completion_tokens = :completion_tokens,
                total_tokens = :total_tokens
            WHERE id = :call_id
        """),
        {
            "call_id": call_id,
            "duration_ms": duration_ms,
            "http_status": http_status,
            "response_full": json.dumps(response_full, ensure_ascii=False),
            "response_content": (response_content or "")[:4000],
            "parsed_json": json.dumps(parsed_json, ensure_ascii=False),
            "is_strict": is_strict,
            "prompt_tokens": prompt_tokens,
            "completion_tokens": completion_tokens,
            "total_tokens": total_tokens,
        },
    )
    db.commit()


def _update_call_error(
    db: Session,
    call_id: int,
    *,
    duration_ms: int,
    http_status: int | None,
    error_type: str,
    error_message: str,
    response_full: dict | None = None,
) -> None:
    db.execute(
        text("""
            UPDATE gestor_tickets.ai_call_history SET
                status = 'error',
                duration_ms = :duration_ms,
                http_status_code = :http_status,
                error_type = :error_type,
                error_message = :error_message,
                response_full_json = CAST(:response_full AS jsonb),
                json_parse_ok = false
            WHERE id = :call_id
        """),
        {
            "call_id": call_id,
            "duration_ms": duration_ms,
            "http_status": http_status,
            "error_type": error_type,
            "error_message": _redact_error_message(error_message),
            "response_full": json.dumps(response_full or {}, ensure_ascii=False),
        },
    )
    db.commit()


class AICallError(Exception):
    def __init__(self, message: str, error_type: str = "unknown_error"):
        super().__init__(message)
        self.error_type = error_type


def call_with_fallback(
    db: Session,
    *,
    scope: str,
    system_prompt: str,
    user_content_json: dict,
    account_id: int,
    user_id: int,
    call_purpose: str,
    related_email_id: int | None = None,
    related_thread_id: int | None = None,
) -> tuple[dict, int]:
    """
    Llama al LLM recorriendo endpoints activos por prioridad hasta obtener respuesta válida.
    Retorna (parsed_json, call_history_id).
    Lanza AICallError si todos los endpoints fallan.
    """
    endpoints = _get_active_endpoints(db)
    if not endpoints:
        raise AICallError("No hay endpoints IA activos con modelo configurado.", "no_endpoints")

    messages = [
        {"role": "system", "content": system_prompt},
        {"role": "user", "content": json.dumps(user_content_json, ensure_ascii=False)},
    ]

    last_error_type = "no_endpoints"
    last_error_msg = "Sin endpoints disponibles."

    for endpoint in endpoints:
        model = endpoint.get("default_model")
        if not model:
            continue

        extra_headers = endpoint.get("extra_headers_json") or {}
        if isinstance(extra_headers, str):
            try:
                extra_headers = json.loads(extra_headers)
            except Exception:
                extra_headers = {}

        endpoint_url = _join_url(
            str(endpoint["base_url"]).rstrip("/"),
            str(endpoint.get("chat_endpoint_path") or "/chat/completions"),
        )

        call_id = _create_call_record(
            db,
            scope=scope,
            account_id=account_id,
            user_id=user_id,
            call_purpose=call_purpose,
            endpoint=endpoint,
            endpoint_url=endpoint_url,
            messages=messages,
            related_email_id=related_email_id,
            related_thread_id=related_thread_id,
        )

        payload: dict[str, Any] = {
            "model": model,
            "messages": messages,
            "temperature": float(endpoint.get("temperature") or 0.2),
            "max_tokens": int(endpoint.get("max_tokens") or 1024),
        }
        if endpoint.get("top_p") is not None:
            payload["top_p"] = float(endpoint["top_p"])
        _apply_reasoning_payload(payload, endpoint)

        try:
            api_key = decrypt_text(endpoint["api_key_ciphertext"])
        except Exception:
            _update_call_error(
                db, call_id,
                duration_ms=0,
                http_status=None,
                error_type="auth_error",
                error_message="No se pudo descifrar la API key del endpoint.",
            )
            last_error_type = "auth_error"
            last_error_msg = f"Endpoint '{endpoint['name']}': error de descifrado"
            raise AICallError(last_error_msg, "auth_error")

        headers = {
            "Authorization": f"Bearer {api_key}",
            "Content-Type": "application/json",
            **extra_headers,
        }

        start = time.monotonic()
        try:
            with httpx.Client(timeout=int(endpoint.get("timeout_seconds") or 60)) as client:
                response = client.post(endpoint_url, headers=headers, json=payload)
            duration_ms = int((time.monotonic() - start) * 1000)

            try:
                response_json = response.json()
            except Exception:
                response_json = {"raw": response.text[:1200]}

            if response.status_code >= 400:
                error_type = _classify_error(response.status_code, response_json, response.text)
                _update_call_error(
                    db, call_id,
                    duration_ms=duration_ms,
                    http_status=response.status_code,
                    error_type=error_type,
                    error_message=f"HTTP {response.status_code}: {error_type}",
                    response_full=response_json,
                )
                last_error_type = error_type
                last_error_msg = f"Endpoint '{endpoint['name']}': {error_type}"
                if error_type not in FALLBACK_ERROR_TYPES:
                    raise AICallError(last_error_msg, error_type)
                continue

            raw_content = _extract_chat_content(response_json)
            content, _ = _strip_thinking_blocks(raw_content)
            parsed, is_strict, is_valid_json = _parse_llm_json(content)

            if not is_valid_json or not isinstance(parsed, dict):
                _update_call_error(
                    db, call_id,
                    duration_ms=duration_ms,
                    http_status=response.status_code,
                    error_type="json_invalid",
                    error_message="La respuesta no contiene un objeto JSON válido.",
                    response_full=response_json,
                )
                last_error_type = "json_invalid"
                last_error_msg = f"Endpoint '{endpoint['name']}': respuesta sin JSON válido"
                continue

            usage = response_json.get("usage") or {}
            _update_call_success(
                db, call_id,
                duration_ms=duration_ms,
                http_status=response.status_code,
                response_full=response_json,
                response_content=content,
                parsed_json=parsed,
                is_strict=is_strict,
                prompt_tokens=usage.get("prompt_tokens"),
                completion_tokens=usage.get("completion_tokens"),
                total_tokens=usage.get("total_tokens"),
            )
            return parsed, call_id

        except AICallError:
            raise
        except httpx.TimeoutException:
            duration_ms = int((time.monotonic() - start) * 1000)
            _update_call_error(db, call_id, duration_ms=duration_ms, http_status=None,
                               error_type="timeout", error_message="Timeout de conexión.")
            last_error_type = "timeout"
            last_error_msg = f"Endpoint '{endpoint['name']}': timeout"
            continue
        except httpx.ConnectError as exc:
            duration_ms = int((time.monotonic() - start) * 1000)
            _update_call_error(db, call_id, duration_ms=duration_ms, http_status=None,
                               error_type="connection_error", error_message=str(exc)[:200])
            last_error_type = "connection_error"
            last_error_msg = f"Endpoint '{endpoint['name']}': error de conexión"
            continue
        except httpx.RequestError as exc:
            duration_ms = int((time.monotonic() - start) * 1000)
            _update_call_error(db, call_id, duration_ms=duration_ms, http_status=None,
                               error_type="connection_error", error_message=str(exc)[:200])
            last_error_type = "connection_error"
            last_error_msg = f"Endpoint '{endpoint['name']}': error de red"
            continue

    raise AICallError(
        f"Todos los endpoints fallaron. Último error: {last_error_msg}",
        last_error_type,
    )
