from __future__ import annotations

from typing import Any

from pydantic import BaseModel, Field, SecretStr


class AiEndpointBase(BaseModel):
    name: str
    provider_kind: str = "generic"
    base_url: str
    models_endpoint_path: str = "/models"
    chat_endpoint_path: str = "/chat/completions"
    default_model: str | None = None
    is_active: bool = True
    is_default: bool = False
    timeout_seconds: int = Field(default=60, ge=1, le=600)
    temperature: float = Field(default=0.2, ge=0, le=2)
    top_p: float = Field(default=1.0, ge=0, le=1)
    max_tokens: int = Field(default=1024, ge=1, le=200000)
    enable_thinking: bool = False
    reasoning_effort: str = "none"
    daily_limit: int | None = None
    free_quota_notes: str | None = None
    retry_policy_json: dict[str, Any] | None = None
    extra_headers_json: dict[str, Any] | None = None


class AiEndpointCreate(AiEndpointBase):
    api_key: SecretStr | None = None


class AiEndpointUpdate(AiEndpointBase):
    api_key: SecretStr | None = None
    keep_existing_api_key: bool = True


class AiEndpointPreviewRequest(AiEndpointBase):
    api_key: SecretStr


class AiValidateModelPreviewRequest(AiEndpointPreviewRequest):
    model_id: str | None = None


class AiEndpointResponse(AiEndpointBase):
    id: int
    api_key_masked: str | None = None
    last_models_sync_at: str | None = None
    last_validation_at: str | None = None
    last_validation_status: str | None = None
    last_validation_error_type: str | None = None
    last_validation_error_message: str | None = None
    created_at: str
    updated_at: str


class AiModelResponse(BaseModel):
    id: int | None = None
    endpoint_id: int | None = None
    model_id: str
    display_name: str | None = None
    owned_by: str | None = None
    context_length: int | None = None
    model_type: str | None = None
    pricing_json: dict[str, Any] = {}
    raw_json: dict[str, Any] = {}
    is_chat_capable: bool = True
    is_free_hint: bool = False
    last_seen_at: str | None = None


class AiValidationResponse(BaseModel):
    ok: bool
    status: str
    error_type: str | None = None
    error_message: str | None = None
    http_status: int | None = None
    latency_ms: int | None = None
    strict_json_ok: bool | None = None
    thinking_detected: bool = False
    response_text_preview: str | None = None


class AiEndpointListResponse(BaseModel):
    ok: bool = True
    endpoints: list[AiEndpointResponse]


class AiModelListResponse(BaseModel):
    ok: bool = True
    endpoint_id: int
    models: list[AiModelResponse]


class AiEndpointDetailResponse(BaseModel):
    ok: bool = True
    endpoint: AiEndpointResponse
    models: list[AiModelResponse]
    validation_logs: list[dict[str, Any]]


class AiValidateModelRequest(BaseModel):
    model_id: str | None = None


class AiOperationResponse(BaseModel):
    ok: bool
    message: str
    endpoint: AiEndpointResponse | None = None
