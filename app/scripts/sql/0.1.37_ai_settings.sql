CREATE TABLE IF NOT EXISTS gestor_tickets.ai_llm_endpoints (
    id bigserial PRIMARY KEY,
    public_uid uuid NOT NULL UNIQUE DEFAULT gen_random_uuid(),
    name text NOT NULL,
    provider_kind text NOT NULL DEFAULT 'generic',
    base_url text NOT NULL,
    models_endpoint_path text NOT NULL DEFAULT '/models',
    chat_endpoint_path text NOT NULL DEFAULT '/chat/completions',
    api_key_ciphertext text,
    default_model text,
    is_active boolean NOT NULL DEFAULT true,
    is_default boolean NOT NULL DEFAULT false,
    timeout_seconds integer NOT NULL DEFAULT 60,
    temperature numeric(4,3) NOT NULL DEFAULT 0.2,
    top_p numeric(4,3) NOT NULL DEFAULT 1.0,
    max_tokens integer NOT NULL DEFAULT 1024,
    enable_thinking boolean NOT NULL DEFAULT false,
    daily_limit integer,
    free_quota_notes text,
    retry_policy_json jsonb NOT NULL DEFAULT '{"max_retries":1,"retry_on":["timeout","connection_error","rate_limited"],"do_not_retry_on":["auth_error","quota_exceeded","model_not_found","invalid_request"]}'::jsonb,
    extra_headers_json jsonb NOT NULL DEFAULT '{}'::jsonb,
    last_models_sync_at timestamptz,
    last_validation_at timestamptz,
    last_validation_status text,
    last_validation_error_type text,
    last_validation_error_message text,
    created_at timestamptz NOT NULL DEFAULT now(),
    updated_at timestamptz NOT NULL DEFAULT now(),
    CONSTRAINT ck_ai_llm_endpoints_timeout CHECK (timeout_seconds BETWEEN 1 AND 600),
    CONSTRAINT ck_ai_llm_endpoints_temperature CHECK (temperature >= 0 AND temperature <= 2),
    CONSTRAINT ck_ai_llm_endpoints_top_p CHECK (top_p >= 0 AND top_p <= 1),
    CONSTRAINT ck_ai_llm_endpoints_max_tokens CHECK (max_tokens BETWEEN 1 AND 200000)
);

CREATE UNIQUE INDEX IF NOT EXISTS uq_ai_llm_endpoints_one_default
ON gestor_tickets.ai_llm_endpoints (is_default)
WHERE is_default IS TRUE;

CREATE INDEX IF NOT EXISTS ix_ai_llm_endpoints_active
ON gestor_tickets.ai_llm_endpoints (is_active, provider_kind);

CREATE TABLE IF NOT EXISTS gestor_tickets.ai_llm_endpoint_models (
    id bigserial PRIMARY KEY,
    endpoint_id bigint NOT NULL REFERENCES gestor_tickets.ai_llm_endpoints(id) ON DELETE CASCADE,
    model_id text NOT NULL,
    display_name text,
    owned_by text,
    context_length integer,
    model_type text,
    pricing_json jsonb NOT NULL DEFAULT '{}'::jsonb,
    raw_json jsonb NOT NULL DEFAULT '{}'::jsonb,
    is_chat_capable boolean NOT NULL DEFAULT true,
    is_free_hint boolean NOT NULL DEFAULT false,
    last_seen_at timestamptz NOT NULL DEFAULT now(),
    created_at timestamptz NOT NULL DEFAULT now(),
    updated_at timestamptz NOT NULL DEFAULT now(),
    CONSTRAINT uq_ai_llm_endpoint_models_endpoint_model UNIQUE (endpoint_id, model_id)
);

CREATE INDEX IF NOT EXISTS ix_ai_llm_endpoint_models_endpoint_seen
ON gestor_tickets.ai_llm_endpoint_models (endpoint_id, last_seen_at DESC);

CREATE TABLE IF NOT EXISTS gestor_tickets.ai_endpoint_validation_logs (
    id bigserial PRIMARY KEY,
    endpoint_id bigint NOT NULL REFERENCES gestor_tickets.ai_llm_endpoints(id) ON DELETE CASCADE,
    model_id text,
    operation_type text NOT NULL,
    http_status integer,
    success boolean NOT NULL DEFAULT false,
    latency_ms integer,
    error_type text,
    error_message text,
    request_json_redacted jsonb NOT NULL DEFAULT '{}'::jsonb,
    response_json jsonb,
    response_text_preview text,
    strict_json_ok boolean,
    thinking_detected boolean NOT NULL DEFAULT false,
    created_at timestamptz NOT NULL DEFAULT now()
);

CREATE INDEX IF NOT EXISTS ix_ai_endpoint_validation_logs_endpoint_created
ON gestor_tickets.ai_endpoint_validation_logs (endpoint_id, created_at DESC);
