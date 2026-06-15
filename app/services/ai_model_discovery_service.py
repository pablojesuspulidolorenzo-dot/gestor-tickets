from __future__ import annotations

import json
import re
import time
from typing import Any
from urllib.parse import urljoin

import httpx
from sqlalchemy import text
from sqlalchemy.orm import Session

from app.services.ai_settings_service import get_endpoint_secret, list_models, _path, _sanitize_extra_headers


REASONING_EFFORT_VALUES = {"none", "low", "medium", "high"}
THINKING_BLOCK_RE = re.compile(r"<thought>.*?</thought>", re.IGNORECASE | re.DOTALL)


def _join_url(base_url: str, path: str) -> str:
    return urljoin(base_url.rstrip("/") + "/", path.lstrip("/"))


def _api_key_plain(value: Any) -> str:
    if hasattr(value, "get_secret_value") and value:
        return value.get_secret_value().strip()
    return str(value or "").strip()


def _normalize_reasoning_effort(value: Any) -> str:
    effort = str(value or "none").strip().lower()
    return effort if effort in REASONING_EFFORT_VALUES else "none"


def _apply_reasoning_payload(request_payload: dict[str, Any], config: dict[str, Any]) -> None:
    if str(config.get("provider_kind") or "").strip().lower() == "gemini":
        request_payload["reasoning_effort"] = _normalize_reasoning_effort(config.get("reasoning_effort"))
        return
    if config.get("enable_thinking"):
        request_payload["enable_thinking"] = True


def _strip_thinking_blocks(content: str) -> tuple[str, bool]:
    original = content or ""
    cleaned = THINKING_BLOCK_RE.sub("", original).strip()
    return cleaned, cleaned != original.strip()


def _preview_endpoint(payload: dict[str, Any]) -> tuple[dict[str, Any], str]:
    api_key = _api_key_plain(payload.get("api_key"))
    if not api_key:
        raise ValueError("Debes indicar una API key para esta prueba técnica.")

    endpoint = {
        "base_url": str(payload.get("base_url") or "").strip().rstrip("/"),
        "models_endpoint_path": _path(payload.get("models_endpoint_path"), "/models"),
        "chat_endpoint_path": _path(payload.get("chat_endpoint_path"), "/chat/completions"),
        "provider_kind": str(payload.get("provider_kind") or "generic").strip().lower(),
        "reasoning_effort": _normalize_reasoning_effort(payload.get("reasoning_effort")),
        "enable_thinking": bool(payload.get("enable_thinking")),
        "timeout_seconds": int(payload.get("timeout_seconds") or 60),
        "top_p": float(payload.get("top_p") if payload.get("top_p") is not None else 1.0),
        "extra_headers_json": _sanitize_extra_headers(payload.get("extra_headers_json") or {}),
        "default_model": str(payload.get("default_model") or "").strip() or None,
    }
    if not endpoint["base_url"]:
        raise ValueError("Debes indicar la base URL del endpoint IA.")
    return endpoint, api_key


def _preview_models(models: list[dict[str, Any]]) -> list[dict[str, Any]]:
    now = time.strftime("%Y-%m-%d %H:%M:%S")
    return [{**model, "id": None, "endpoint_id": None, "last_seen_at": now} for model in models]


def _classify_error(status_code: int | None, body: Any, message: str) -> str:
    text_value = f"{body} {message}".lower()
    if status_code in {401, 403}:
        return "auth_error"
    if status_code == 404:
        return "model_not_found"
    if status_code == 408:
        return "timeout"
    if status_code == 429:
        if "quota" in text_value or "resource_exhausted" in text_value or "spending" in text_value:
            return "quota_exceeded"
        return "rate_limited"
    if status_code and 400 <= status_code < 500:
        return "invalid_request"
    if status_code and status_code >= 500:
        return "provider_error"
    if "timeout" in text_value:
        return "timeout"
    if "connect" in text_value:
        return "connection_error"
    return "unknown_error"


def _redact_error_message(message: str) -> str:
    message = (message or "").replace("\n", " ").strip()
    lowered = message.lower()
    if "authorization" in lowered or "bearer " in lowered or "api_key" in lowered or "token" in lowered:
        return "Error técnico redacted."
    return message[:500]


def _extract_models(payload: Any) -> list[dict[str, Any]]:
    if isinstance(payload, dict):
        data = payload.get("data", payload.get("models", payload.get("items", [])))
    else:
        data = payload

    if not isinstance(data, list):
        return []

    models = []
    for item in data:
        if isinstance(item, str):
            raw = {"id": item}
        elif isinstance(item, dict):
            raw = item
        else:
            continue

        model_id = raw.get("id") or raw.get("model") or raw.get("model_id") or raw.get("name")
        if not model_id:
            continue

        pricing = raw.get("pricing") if isinstance(raw.get("pricing"), dict) else {}
        architecture = raw.get("architecture") if isinstance(raw.get("architecture"), dict) else {}
        context_length = (
            raw.get("context_length")
            or raw.get("context_window")
            or raw.get("max_context_length")
            or architecture.get("context_length")
        )
        model_type = raw.get("type") or raw.get("object") or architecture.get("modality")
        models.append(
            {
                "model_id": str(model_id),
                "display_name": raw.get("name") or raw.get("display_name") or str(model_id),
                "owned_by": raw.get("owned_by") or raw.get("owner"),
                "context_length": int(context_length) if str(context_length or "").isdigit() else None,
                "model_type": str(model_type) if model_type else None,
                "pricing_json": pricing,
                "raw_json": raw,
                "is_chat_capable": "embedding" not in str(model_id).lower(),
                "is_free_hint": "free" in str(model_id).lower() or "free" in json.dumps(pricing).lower(),
            }
        )
    return models


def _upsert_models(db: Session, endpoint_id: int, models: list[dict[str, Any]]) -> None:
    for model in models:
        db.execute(
            text("""
                INSERT INTO gestor_tickets.ai_llm_endpoint_models (
                    endpoint_id, model_id, display_name, owned_by, context_length,
                    model_type, pricing_json, raw_json, is_chat_capable, is_free_hint,
                    last_seen_at, updated_at
                )
                VALUES (
                    :endpoint_id, :model_id, :display_name, :owned_by, :context_length,
                    :model_type, CAST(:pricing_json AS jsonb), CAST(:raw_json AS jsonb),
                    :is_chat_capable, :is_free_hint, now(), now()
                )
                ON CONFLICT (endpoint_id, model_id)
                DO UPDATE SET
                    display_name = EXCLUDED.display_name,
                    owned_by = EXCLUDED.owned_by,
                    context_length = EXCLUDED.context_length,
                    model_type = EXCLUDED.model_type,
                    pricing_json = EXCLUDED.pricing_json,
                    raw_json = EXCLUDED.raw_json,
                    is_chat_capable = EXCLUDED.is_chat_capable,
                    is_free_hint = EXCLUDED.is_free_hint,
                    last_seen_at = now(),
                    updated_at = now()
            """),
            {
                "endpoint_id": endpoint_id,
                **{k: v for k, v in model.items() if k not in {"pricing_json", "raw_json"}},
                "pricing_json": json.dumps(model.get("pricing_json") or {}, ensure_ascii=False),
                "raw_json": json.dumps(model.get("raw_json") or {}, ensure_ascii=False),
            },
        )


def _log_validation(
    db: Session,
    *,
    endpoint_id: int,
    model_id: str | None,
    operation_type: str,
    http_status: int | None,
    success: bool,
    latency_ms: int | None,
    error_type: str | None,
    error_message: str | None,
    request_json_redacted: dict,
    response_json: Any,
    response_text_preview: str | None,
    strict_json_ok: bool | None,
    thinking_detected: bool,
) -> None:
    db.execute(
        text("""
            INSERT INTO gestor_tickets.ai_endpoint_validation_logs (
                endpoint_id, model_id, operation_type, http_status, success, latency_ms,
                error_type, error_message, request_json_redacted, response_json,
                response_text_preview, strict_json_ok, thinking_detected
            )
            VALUES (
                :endpoint_id, :model_id, :operation_type, :http_status, :success, :latency_ms,
                :error_type, :error_message, CAST(:request_json_redacted AS jsonb), CAST(:response_json AS jsonb),
                :response_text_preview, :strict_json_ok, :thinking_detected
            )
        """),
        {
            "endpoint_id": endpoint_id,
            "model_id": model_id,
            "operation_type": operation_type,
            "http_status": http_status,
            "success": success,
            "latency_ms": latency_ms,
            "error_type": error_type,
            "error_message": _redact_error_message(error_message or "") if error_message else None,
            "request_json_redacted": json.dumps(request_json_redacted, ensure_ascii=False),
            "response_json": json.dumps(response_json if isinstance(response_json, (dict, list)) else {}, ensure_ascii=False),
            "response_text_preview": (response_text_preview or "")[:1200] or None,
            "strict_json_ok": strict_json_ok,
            "thinking_detected": thinking_detected,
        },
    )


def discover_models(db: Session, endpoint_id: int) -> list[dict]:
    endpoint, api_key = get_endpoint_secret(db, endpoint_id)
    url = _join_url(endpoint["base_url"], endpoint["models_endpoint_path"])
    headers = {"Authorization": f"Bearer {api_key}", **(endpoint.get("extra_headers_json") or {})}
    start = time.monotonic()
    response_json: Any = {}
    try:
        with httpx.Client(timeout=endpoint["timeout_seconds"]) as client:
            response = client.get(url, headers=headers)
        latency_ms = int((time.monotonic() - start) * 1000)
        try:
            response_json = response.json()
        except Exception:
            response_json = {"raw": response.text[:1200]}

        if response.status_code >= 400:
            error_type = _classify_error(response.status_code, response_json, response.text)
            _log_validation(
                db,
                endpoint_id=endpoint_id,
                model_id=None,
                operation_type="discover_models",
                http_status=response.status_code,
                success=False,
                latency_ms=latency_ms,
                error_type=error_type,
                error_message=f"No se pudieron obtener modelos: {error_type}",
                request_json_redacted={"method": "GET", "url": url},
                response_json=response_json,
                response_text_preview=response.text,
                strict_json_ok=None,
                thinking_detected=False,
            )
            db.execute(
                text("""
                    UPDATE gestor_tickets.ai_llm_endpoints
                    SET last_models_sync_at = now(),
                        last_validation_status = 'error',
                        last_validation_error_type = :error_type,
                        last_validation_error_message = :error_message,
                        updated_at = now()
                    WHERE id = :endpoint_id
                """),
                {"endpoint_id": endpoint_id, "error_type": error_type, "error_message": "Error obteniendo modelos."},
            )
            db.commit()
            raise ValueError(f"No se pudieron obtener modelos: {error_type}")

        models = _extract_models(response_json)
        _upsert_models(db, endpoint_id, models)
        db.execute(
            text("""
                UPDATE gestor_tickets.ai_llm_endpoints
                SET last_models_sync_at = now(),
                    last_validation_status = 'models_ok',
                    last_validation_error_type = NULL,
                    last_validation_error_message = NULL,
                    updated_at = now()
                WHERE id = :endpoint_id
            """),
            {"endpoint_id": endpoint_id},
        )
        _log_validation(
            db,
            endpoint_id=endpoint_id,
            model_id=None,
            operation_type="discover_models",
            http_status=response.status_code,
            success=True,
            latency_ms=latency_ms,
            error_type=None,
            error_message=None,
            request_json_redacted={"method": "GET", "url": url},
            response_json={"model_count": len(models)},
            response_text_preview=None,
            strict_json_ok=None,
            thinking_detected=False,
        )
        db.commit()
        return list_models(db, endpoint_id)

    except httpx.TimeoutException as exc:
        return _raise_logged_error(db, endpoint_id, None, "discover_models", "timeout", str(exc), start)
    except httpx.ConnectError as exc:
        return _raise_logged_error(db, endpoint_id, None, "discover_models", "connection_error", str(exc), start)
    except httpx.RequestError as exc:
        return _raise_logged_error(db, endpoint_id, None, "discover_models", "connection_error", str(exc), start)


def _raise_logged_error(db: Session, endpoint_id: int, model_id: str | None, operation_type: str, error_type: str, message: str, start: float):
    latency_ms = int((time.monotonic() - start) * 1000)
    _log_validation(
        db,
        endpoint_id=endpoint_id,
        model_id=model_id,
        operation_type=operation_type,
        http_status=None,
        success=False,
        latency_ms=latency_ms,
        error_type=error_type,
        error_message=message,
        request_json_redacted={"operation": operation_type},
        response_json={},
        response_text_preview=None,
        strict_json_ok=None,
        thinking_detected=False,
    )
    db.execute(
        text("""
            UPDATE gestor_tickets.ai_llm_endpoints
            SET last_validation_at = now(),
                last_validation_status = 'error',
                last_validation_error_type = :error_type,
                last_validation_error_message = :error_message,
                updated_at = now()
            WHERE id = :endpoint_id
        """),
        {"endpoint_id": endpoint_id, "error_type": error_type, "error_message": _redact_error_message(message)},
    )
    db.commit()
    raise ValueError(error_type)


def validate_model(db: Session, endpoint_id: int, model_id: str | None = None) -> dict:
    endpoint, api_key = get_endpoint_secret(db, endpoint_id)
    selected_model = model_id or endpoint.get("default_model")
    if not selected_model:
        raise ValueError("Debes seleccionar un modelo.")

    url = _join_url(endpoint["base_url"], endpoint["chat_endpoint_path"])
    payload = {
        "model": selected_model,
        "messages": [
            {"role": "system", "content": "Responde exclusivamente con JSON válido, sin markdown."},
            {"role": "user", "content": 'Devuelve exactamente este JSON: {"ok":true}'},
        ],
        "temperature": float(endpoint.get("temperature") if endpoint.get("temperature") is not None else 0.2),
        "max_tokens": int(endpoint.get("max_tokens") or 64),
    }
    if endpoint.get("top_p") is not None:
        payload["top_p"] = endpoint["top_p"]
    _apply_reasoning_payload(payload, endpoint)

    headers = {"Authorization": f"Bearer {api_key}", "Content-Type": "application/json", **(endpoint.get("extra_headers_json") or {})}
    start = time.monotonic()
    response_json: Any = {}
    response_text = ""
    try:
        with httpx.Client(timeout=endpoint["timeout_seconds"]) as client:
            response = client.post(url, headers=headers, json=payload)
        latency_ms = int((time.monotonic() - start) * 1000)
        response_text = response.text
        try:
            response_json = response.json()
        except Exception:
            response_json = {"raw": response.text[:1200]}

        if response.status_code >= 400:
            error_type = _classify_error(response.status_code, response_json, response.text)
            result = {
                "ok": False,
                "status": "error",
                "error_type": error_type,
                "error_message": f"Validación fallida: {error_type}",
                "http_status": response.status_code,
                "latency_ms": latency_ms,
                "strict_json_ok": False,
                "thinking_detected": False,
                "response_text_preview": response.text[:1200],
            }
        else:
            raw_content = _extract_chat_content(response_json)
            content, thinking_detected = _strip_thinking_blocks(raw_content)
            strict_json_ok = _strict_json_ok(content)
            ok = strict_json_ok
            status = "ok" if ok else "partial"
            error_type = None if ok else "json_not_strict"
            error_message = None if ok else "Modelo accesible, pero la respuesta util no es JSON estricto."
            result = {
                "ok": ok,
                "status": status,
                "error_type": error_type,
                "error_message": error_message,
                "http_status": response.status_code,
                "latency_ms": latency_ms,
                "strict_json_ok": strict_json_ok,
                "thinking_detected": thinking_detected,
                "response_text_preview": content[:1200],
            }

        _log_validation(
            db,
            endpoint_id=endpoint_id,
            model_id=selected_model,
            operation_type="validate_model",
            http_status=result["http_status"],
            success=result["status"] in {"ok", "partial"},
            latency_ms=result["latency_ms"],
            error_type=result["error_type"],
            error_message=result["error_message"],
            request_json_redacted={**payload, "messages": "[technical validation prompt only]"},
            response_json=response_json,
            response_text_preview=result["response_text_preview"],
            strict_json_ok=result["strict_json_ok"],
            thinking_detected=result["thinking_detected"],
        )
        db.execute(
            text("""
                UPDATE gestor_tickets.ai_llm_endpoints
                SET last_validation_at = now(),
                    last_validation_status = :status,
                    last_validation_error_type = :error_type,
                    last_validation_error_message = :error_message,
                    default_model = COALESCE(default_model, :model_id),
                    updated_at = now()
                WHERE id = :endpoint_id
            """),
            {
                "endpoint_id": endpoint_id,
                "status": result["status"],
                "error_type": result["error_type"],
                "error_message": result["error_message"],
                "model_id": selected_model,
            },
        )
        db.commit()
        return result

    except httpx.TimeoutException as exc:
        _raise_logged_error(db, endpoint_id, selected_model, "validate_model", "timeout", str(exc), start)
    except httpx.ConnectError as exc:
        _raise_logged_error(db, endpoint_id, selected_model, "validate_model", "connection_error", str(exc), start)
    except httpx.RequestError as exc:
        _raise_logged_error(db, endpoint_id, selected_model, "validate_model", "connection_error", str(exc), start)


def _extract_chat_content(response_json: Any) -> str:
    try:
        choices = response_json.get("choices") or []
        first = choices[0] if choices else {}
        message = first.get("message") or {}
        content = message.get("content")
        if isinstance(content, list):
            return "".join(part.get("text", "") if isinstance(part, dict) else str(part) for part in content)
        return str(content or "")
    except Exception:
        return ""


def _strict_json_ok(content: str) -> bool:
    try:
        parsed = json.loads(content.strip())
    except Exception:
        return False
    return parsed == {"ok": True}


def discover_models_preview(payload: dict[str, Any]) -> list[dict]:
    endpoint, api_key = _preview_endpoint(payload)
    url = _join_url(endpoint["base_url"], endpoint["models_endpoint_path"])
    headers = {"Authorization": f"Bearer {api_key}", **(endpoint.get("extra_headers_json") or {})}
    start = time.monotonic()
    try:
        with httpx.Client(timeout=endpoint["timeout_seconds"]) as client:
            response = client.get(url, headers=headers)
        try:
            response_json = response.json()
        except Exception:
            response_json = {"raw": response.text[:1200]}
        if response.status_code >= 400:
            error_type = _classify_error(response.status_code, response_json, response.text)
            raise ValueError(error_type)
        return _preview_models(_extract_models(response_json))
    except httpx.TimeoutException:
        raise ValueError("timeout")
    except httpx.RequestError:
        raise ValueError("connection_error")


def validate_model_preview(payload: dict[str, Any], model_id: str | None = None) -> dict:
    endpoint, api_key = _preview_endpoint(payload)
    selected_model = (model_id or payload.get("model_id") or payload.get("default_model") or "").strip()
    if not selected_model:
        raise ValueError("Debes seleccionar un modelo.")

    url = _join_url(endpoint["base_url"], endpoint["chat_endpoint_path"])
    request_payload = {
        "model": selected_model,
        "messages": [
            {"role": "system", "content": "Responde exclusivamente con JSON válido, sin markdown."},
            {"role": "user", "content": 'Devuelve exactamente este JSON: {"ok":true}'},
        ],
        "temperature": float(payload.get("temperature") if payload.get("temperature") is not None else 0.2),
        "max_tokens": int(payload.get("max_tokens") or 64),
    }
    if endpoint.get("top_p") is not None:
        request_payload["top_p"] = endpoint["top_p"]
    _apply_reasoning_payload(request_payload, endpoint)

    headers = {"Authorization": f"Bearer {api_key}", "Content-Type": "application/json", **(endpoint.get("extra_headers_json") or {})}
    start = time.monotonic()
    try:
        with httpx.Client(timeout=endpoint["timeout_seconds"]) as client:
            response = client.post(url, headers=headers, json=request_payload)
        latency_ms = int((time.monotonic() - start) * 1000)
        try:
            response_json = response.json()
        except Exception:
            response_json = {"raw": response.text[:1200]}

        if response.status_code >= 400:
            error_type = _classify_error(response.status_code, response_json, response.text)
            return {
                "ok": False,
                "status": "error",
                "error_type": error_type,
                "error_message": f"Validación fallida: {error_type}",
                "http_status": response.status_code,
                "latency_ms": latency_ms,
                "strict_json_ok": False,
                "thinking_detected": False,
                "response_text_preview": response.text[:1200],
            }

        raw_content = _extract_chat_content(response_json)
        content, thinking_detected = _strip_thinking_blocks(raw_content)
        strict_json_ok = _strict_json_ok(content)
        ok = strict_json_ok
        error_type = None if ok else "json_not_strict"
        return {
            "ok": ok,
            "status": "ok" if ok else "partial",
            "error_type": error_type,
            "error_message": None if ok else "Modelo accesible, pero la respuesta util no es JSON estricto.",
            "http_status": response.status_code,
            "latency_ms": latency_ms,
            "strict_json_ok": strict_json_ok,
            "thinking_detected": thinking_detected,
            "response_text_preview": content[:1200],
        }
    except httpx.TimeoutException:
        return {
            "ok": False,
            "status": "error",
            "error_type": "timeout",
            "error_message": "Validación fallida: timeout",
            "http_status": None,
            "latency_ms": int((time.monotonic() - start) * 1000),
            "strict_json_ok": False,
            "thinking_detected": False,
            "response_text_preview": None,
        }
    except httpx.RequestError:
        return {
            "ok": False,
            "status": "error",
            "error_type": "connection_error",
            "error_message": "Validación fallida: connection_error",
            "http_status": None,
            "latency_ms": int((time.monotonic() - start) * 1000),
            "strict_json_ok": False,
            "thinking_detected": False,
            "response_text_preview": None,
        }
