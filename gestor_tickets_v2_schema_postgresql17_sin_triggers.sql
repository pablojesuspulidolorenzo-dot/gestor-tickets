-- ============================================================================
-- Gestor Tickets v2 - Esquema PostgreSQL 17 SIN TRIGGERS
-- ============================================================================
-- Objetivo:
--   - Reiniciar por completo el esquema gestor_tickets.
--   - Crear un modelo limpio, relacional y funcional sin triggers.
--   - El mantenimiento de updated_at queda delegado a la aplicación/ORM.
--
-- ADVERTENCIA:
--   Este script elimina TODO el esquema gestor_tickets existente.
-- ============================================================================

BEGIN;

DROP SCHEMA IF EXISTS gestor_tickets CASCADE;

CREATE EXTENSION IF NOT EXISTS pgcrypto;
CREATE EXTENSION IF NOT EXISTS citext;

CREATE SCHEMA gestor_tickets;
SET search_path = gestor_tickets, public;

-- ============================================================================
-- 1. Tipos controlados
-- ============================================================================

CREATE TYPE account_status AS ENUM (
    'active',
    'disabled',
    'pending_configuration',
    'error_auth',
    'error_connection',
    'error_unknown',
    'archived'
);

CREATE TYPE account_role AS ENUM (
    'owner',
    'admin',
    'technician',
    'collaborator',
    'viewer'
);

CREATE TYPE account_user_auth_mode AS ENUM (
    'glpi_account_manager',
    'local_collaborator'
);

CREATE TYPE account_user_status AS ENUM (
    'active',
    'disabled',
    'locked',
    'pending_password_reset'
);

CREATE TYPE mail_direction AS ENUM (
    'inbound',
    'outbound',
    'unknown'
);

CREATE TYPE mail_folder_kind AS ENUM (
    'inbox',
    'sent',
    'other'
);

CREATE TYPE mail_source AS ENUM (
    'collaborative_ingestion',
    'manual_import',
    'personal_transfer',
    'glpi_import',
    'other'
);

CREATE TYPE ingestion_job_status AS ENUM (
    'active',
    'disabled',
    'error_auth',
    'error_connection',
    'error_unknown'
);

CREATE TYPE ingestion_run_status AS ENUM (
    'running',
    'success',
    'partial_error',
    'failed'
);

CREATE TYPE system_thread_status AS ENUM (
    'active',
    'merged',
    'archived',
    'deleted'
);

CREATE TYPE thread_member_status AS ENUM (
    'active',
    'moved',
    'removed'
);

CREATE TYPE glpi_link_origin AS ENUM (
    'manual',
    'ai_suggested',
    'created_from_email',
    'created_from_thread',
    'personal_transfer',
    'auto_sync'
);

CREATE TYPE glpi_link_status AS ENUM (
    'active',
    'detached'
);

CREATE TYPE ai_scope AS ENUM (
    'email',
    'thread',
    'ticket_context'
);

CREATE TYPE ai_processing_status AS ENUM (
    'pending',
    'processing',
    'processed',
    'skipped',
    'error'
);

-- ============================================================================
-- 2. Configuración general e integración GLPI
-- ============================================================================

CREATE TABLE app_settings (
    id smallint PRIMARY KEY DEFAULT 1 CHECK (id = 1),
    app_name text NOT NULL DEFAULT 'gestor-tickets',
    app_description text,
    default_timezone text NOT NULL DEFAULT 'Atlantic/Canary',
    default_archive_root text NOT NULL DEFAULT '/data/mail_archive',
    created_at timestamptz NOT NULL DEFAULT now(),
    updated_at timestamptz NOT NULL DEFAULT now()
);

INSERT INTO app_settings (id, app_name, app_description)
VALUES (1, 'gestor-tickets', 'Webmail colaborativo con IA e integración GLPI')
ON CONFLICT (id) DO NOTHING;

CREATE TABLE glpi_instances (
    id bigserial PRIMARY KEY,
    name text NOT NULL,
    base_url text NOT NULL UNIQUE,
    app_token_ciphertext text,
    default_entity_id bigint,
    default_group_id bigint,
    verify_tls boolean NOT NULL DEFAULT true,
    active boolean NOT NULL DEFAULT true,
    notes text,
    created_at timestamptz NOT NULL DEFAULT now(),
    updated_at timestamptz NOT NULL DEFAULT now()
);

-- ============================================================================
-- 3. Cuentas colaborativas principales y usuarios
-- ============================================================================

CREATE TABLE collaborative_accounts (
    id bigserial PRIMARY KEY,
    public_uid uuid NOT NULL DEFAULT gen_random_uuid() UNIQUE,
    email citext NOT NULL UNIQUE,
    display_name text,
    status account_status NOT NULL DEFAULT 'pending_configuration',

    -- Validación contra GLPI. La contraseña GLPI NO se guarda aquí.
    glpi_instance_id bigint REFERENCES glpi_instances(id) ON DELETE SET NULL,
    glpi_user_id bigint,
    glpi_login citext NOT NULL,
    glpi_profile_name text NOT NULL DEFAULT 'Supervisor',
    glpi_entity_id bigint,
    glpi_group_id bigint,
    last_glpi_validation_at timestamptz,

    -- Configuración IMAP principal. La aplicación cifra la contraseña usando un secreto del .env.
    imap_host text,
    imap_username citext,
    imap_password_ciphertext text,
    imap_port integer NOT NULL DEFAULT 993 CHECK (imap_port = 993),
    imap_use_ssl boolean NOT NULL DEFAULT true CHECK (imap_use_ssl = true),
    imap_last_validated_at timestamptz,

    -- Archivo físico de .eml. Cada cuenta tendrá su subcarpeta.
    archive_root text NOT NULL DEFAULT '/data/mail_archive',
    archive_subdir text NOT NULL,

    ingestion_enabled boolean NOT NULL DEFAULT false,
    created_by_login citext,
    notes text,
    created_at timestamptz NOT NULL DEFAULT now(),
    updated_at timestamptz NOT NULL DEFAULT now(),

    CONSTRAINT collaborative_account_glpi_login_matches_email
        CHECK (lower(glpi_login::text) = lower(email::text)),
    CONSTRAINT collaborative_account_imap_config_complete_or_empty
        CHECK (
            (imap_host IS NULL AND imap_username IS NULL AND imap_password_ciphertext IS NULL)
            OR
            (imap_host IS NOT NULL AND imap_username IS NOT NULL AND imap_password_ciphertext IS NOT NULL)
        )
);

CREATE TABLE account_users (
    id bigserial PRIMARY KEY,
    public_uid uuid NOT NULL DEFAULT gen_random_uuid() UNIQUE,
    account_id bigint NOT NULL REFERENCES collaborative_accounts(id) ON DELETE CASCADE,

    -- Para el gestor principal, login_identifier = email de la cuenta y se valida contra GLPI.
    -- Para colaboradores, login_identifier = usuario#cuenta@email y se valida contra password_hash local.
    auth_mode account_user_auth_mode NOT NULL,
    login_identifier citext NOT NULL UNIQUE,
    username_local citext,
    password_hash text,

    display_name text NOT NULL,
    contact_email citext,
    role account_role NOT NULL DEFAULT 'collaborator',
    status account_user_status NOT NULL DEFAULT 'active',

    can_manage_users boolean NOT NULL DEFAULT false,
    can_manage_account_config boolean NOT NULL DEFAULT false,
    can_read_account_mail boolean NOT NULL DEFAULT true,
    can_reply_from_account boolean NOT NULL DEFAULT false,
    can_create_glpi_ticket boolean NOT NULL DEFAULT false,
    can_update_glpi_ticket boolean NOT NULL DEFAULT false,
    can_link_tickets boolean NOT NULL DEFAULT false,
    can_manage_ai boolean NOT NULL DEFAULT false,

    failed_login_count integer NOT NULL DEFAULT 0 CHECK (failed_login_count >= 0),
    locked_until timestamptz,
    last_login_at timestamptz,
    created_by_user_id bigint REFERENCES account_users(id) ON DELETE SET NULL,
    created_at timestamptz NOT NULL DEFAULT now(),
    updated_at timestamptz NOT NULL DEFAULT now(),

    CONSTRAINT account_user_auth_shape CHECK (
        (
            auth_mode = 'glpi_account_manager'
            AND username_local IS NULL
            AND password_hash IS NULL
            AND role IN ('owner', 'admin')
        )
        OR
        (
            auth_mode = 'local_collaborator'
            AND username_local IS NOT NULL
            AND password_hash IS NOT NULL
        )
    )
);

CREATE UNIQUE INDEX uq_account_users_username_per_account
ON account_users (account_id, username_local)
WHERE username_local IS NOT NULL;

CREATE INDEX ix_account_users_account_role ON account_users (account_id, role);
CREATE INDEX ix_account_users_status ON account_users (status);

-- Cuentas personales opcionales de colaboradores.
-- No se archivan, no se procesan por IA y no tienen job automático.
CREATE TABLE personal_mail_accounts (
    id bigserial PRIMARY KEY,
    public_uid uuid NOT NULL DEFAULT gen_random_uuid() UNIQUE,
    account_id bigint NOT NULL REFERENCES collaborative_accounts(id) ON DELETE CASCADE,
    user_id bigint NOT NULL REFERENCES account_users(id) ON DELETE CASCADE,
    email citext NOT NULL,
    display_name text,
    imap_host text NOT NULL,
    imap_username citext NOT NULL,
    imap_password_ciphertext text NOT NULL,
    imap_port integer NOT NULL DEFAULT 993 CHECK (imap_port = 993),
    imap_use_ssl boolean NOT NULL DEFAULT true CHECK (imap_use_ssl = true),
    active boolean NOT NULL DEFAULT true,
    last_validated_at timestamptz,
    created_at timestamptz NOT NULL DEFAULT now(),
    updated_at timestamptz NOT NULL DEFAULT now(),
    UNIQUE (user_id, email)
);

CREATE INDEX ix_personal_mail_accounts_account_user ON personal_mail_accounts (account_id, user_id);

-- ============================================================================
-- 4. Tareas de incorporación automática de Entrada y Enviados
-- ============================================================================

CREATE TABLE mail_ingestion_jobs (
    id bigserial PRIMARY KEY,
    account_id bigint NOT NULL UNIQUE REFERENCES collaborative_accounts(id) ON DELETE CASCADE,
    status ingestion_job_status NOT NULL DEFAULT 'disabled',
    scan_inbox boolean NOT NULL DEFAULT true,
    scan_sent boolean NOT NULL DEFAULT true,
    inbox_folder_name text NOT NULL DEFAULT 'INBOX',
    sent_folder_name text NOT NULL DEFAULT 'Sent',
    interval_minutes integer NOT NULL DEFAULT 5 CHECK (interval_minutes BETWEEN 1 AND 1440),
    max_messages_per_folder integer NOT NULL DEFAULT 200 CHECK (max_messages_per_folder > 0),
    last_started_at timestamptz,
    last_success_at timestamptz,
    last_error_at timestamptz,
    next_run_at timestamptz,
    auth_failure_count integer NOT NULL DEFAULT 0 CHECK (auth_failure_count >= 0),
    last_error_message text,
    created_by_user_id bigint REFERENCES account_users(id) ON DELETE SET NULL,
    updated_by_user_id bigint REFERENCES account_users(id) ON DELETE SET NULL,
    created_at timestamptz NOT NULL DEFAULT now(),
    updated_at timestamptz NOT NULL DEFAULT now()
);

CREATE INDEX ix_mail_ingestion_jobs_due ON mail_ingestion_jobs (status, next_run_at);

CREATE TABLE mail_ingestion_runs (
    id bigserial PRIMARY KEY,
    job_id bigint NOT NULL REFERENCES mail_ingestion_jobs(id) ON DELETE CASCADE,
    account_id bigint NOT NULL REFERENCES collaborative_accounts(id) ON DELETE CASCADE,
    status ingestion_run_status NOT NULL DEFAULT 'running',
    started_at timestamptz NOT NULL DEFAULT now(),
    finished_at timestamptz,
    scanned_inbox_count integer NOT NULL DEFAULT 0 CHECK (scanned_inbox_count >= 0),
    scanned_sent_count integer NOT NULL DEFAULT 0 CHECK (scanned_sent_count >= 0),
    imported_count integer NOT NULL DEFAULT 0 CHECK (imported_count >= 0),
    duplicate_count integer NOT NULL DEFAULT 0 CHECK (duplicate_count >= 0),
    error_count integer NOT NULL DEFAULT 0 CHECK (error_count >= 0),
    error_message text,
    details_json jsonb NOT NULL DEFAULT '{}'::jsonb
);

CREATE INDEX ix_mail_ingestion_runs_account_started ON mail_ingestion_runs (account_id, started_at DESC);

-- ============================================================================
-- 5. Correos archivados .eml e información normalizada
-- ============================================================================

CREATE TABLE email_messages (
    id bigserial PRIMARY KEY,
    system_uid uuid NOT NULL DEFAULT gen_random_uuid() UNIQUE,
    account_id bigint NOT NULL REFERENCES collaborative_accounts(id) ON DELETE CASCADE,

    -- Identificadores y archivo físico.
    message_id_header text,
    eml_sha256 char(64) NOT NULL,
    raw_headers_sha256 char(64),
    eml_storage_path text NOT NULL UNIQUE,
    eml_filename text NOT NULL,
    size_bytes bigint CHECK (size_bytes IS NULL OR size_bytes >= 0),

    -- Procedencia.
    source mail_source NOT NULL DEFAULT 'collaborative_ingestion',
    imported_from_personal_account_id bigint REFERENCES personal_mail_accounts(id) ON DELETE SET NULL,
    transferred_by_user_id bigint REFERENCES account_users(id) ON DELETE SET NULL,
    transferred_at timestamptz,
    original_imap_account citext,
    original_imap_folder text,
    original_imap_uid text,
    original_imap_uidvalidity text,
    source_description text,

    -- Metadatos de email.
    subject text,
    subject_normalized text,
    from_email citext,
    from_name text,
    sent_at timestamptz,
    received_at timestamptz,
    direction mail_direction NOT NULL DEFAULT 'unknown',
    has_attachments boolean NOT NULL DEFAULT false,
    body_text_preview text,

    archived_at timestamptz NOT NULL DEFAULT now(),
    created_at timestamptz NOT NULL DEFAULT now(),
    updated_at timestamptz NOT NULL DEFAULT now(),

    CONSTRAINT email_message_transfer_requires_source CHECK (
        source <> 'personal_transfer'
        OR (imported_from_personal_account_id IS NOT NULL AND transferred_by_user_id IS NOT NULL AND transferred_at IS NOT NULL)
    )
);

CREATE UNIQUE INDEX uq_email_messages_account_message_id_header
ON email_messages (account_id, message_id_header)
WHERE message_id_header IS NOT NULL;

CREATE UNIQUE INDEX uq_email_messages_account_eml_sha256
ON email_messages (account_id, eml_sha256);

CREATE INDEX ix_email_messages_account_date ON email_messages (account_id, sent_at DESC NULLS LAST, id DESC);
CREATE INDEX ix_email_messages_account_subject ON email_messages (account_id, subject_normalized);
CREATE INDEX ix_email_messages_from_email ON email_messages (from_email);

CREATE TABLE email_message_occurrences (
    id bigserial PRIMARY KEY,
    email_message_id bigint NOT NULL REFERENCES email_messages(id) ON DELETE CASCADE,
    account_id bigint NOT NULL REFERENCES collaborative_accounts(id) ON DELETE CASCADE,
    ingestion_run_id bigint REFERENCES mail_ingestion_runs(id) ON DELETE SET NULL,
    source_mailbox_email citext NOT NULL,
    folder_name text NOT NULL,
    folder_kind mail_folder_kind NOT NULL DEFAULT 'other',
    imap_uid text NOT NULL,
    imap_uidvalidity text,
    direction mail_direction NOT NULL DEFAULT 'unknown',
    flags_json jsonb NOT NULL DEFAULT '[]'::jsonb,
    unread_at_import boolean,
    first_seen_at timestamptz NOT NULL DEFAULT now(),
    last_seen_at timestamptz NOT NULL DEFAULT now(),
    UNIQUE (source_mailbox_email, folder_name, imap_uidvalidity, imap_uid)
);

CREATE INDEX ix_email_occurrences_email ON email_message_occurrences (email_message_id);
CREATE INDEX ix_email_occurrences_account_folder ON email_message_occurrences (account_id, folder_name, imap_uid);

CREATE TABLE email_recipients (
    id bigserial PRIMARY KEY,
    email_message_id bigint NOT NULL REFERENCES email_messages(id) ON DELETE CASCADE,
    recipient_type text NOT NULL CHECK (recipient_type IN ('to', 'cc', 'bcc', 'reply_to')),
    email citext NOT NULL,
    display_name text,
    position integer NOT NULL DEFAULT 0 CHECK (position >= 0)
);

CREATE INDEX ix_email_recipients_email ON email_recipients (email);
CREATE INDEX ix_email_recipients_message ON email_recipients (email_message_id, recipient_type, position);

CREATE TABLE email_attachments (
    id bigserial PRIMARY KEY,
    email_message_id bigint NOT NULL REFERENCES email_messages(id) ON DELETE CASCADE,
    filename text,
    content_type text,
    size_bytes bigint CHECK (size_bytes IS NULL OR size_bytes >= 0),
    content_id text,
    is_inline boolean NOT NULL DEFAULT false,
    storage_path text,
    sha256 char(64),
    created_at timestamptz NOT NULL DEFAULT now()
);

CREATE INDEX ix_email_attachments_message ON email_attachments (email_message_id);

CREATE TABLE personal_message_transfer_log (
    id bigserial PRIMARY KEY,
    personal_account_id bigint NOT NULL REFERENCES personal_mail_accounts(id) ON DELETE RESTRICT,
    target_account_id bigint NOT NULL REFERENCES collaborative_accounts(id) ON DELETE CASCADE,
    transferred_email_message_id bigint NOT NULL REFERENCES email_messages(id) ON DELETE CASCADE,
    transferred_by_user_id bigint NOT NULL REFERENCES account_users(id) ON DELETE RESTRICT,
    original_folder text NOT NULL,
    original_imap_uid text NOT NULL,
    original_imap_uidvalidity text,
    original_message_id_header text,
    transfer_reason text,
    transferred_at timestamptz NOT NULL DEFAULT now(),
    UNIQUE (personal_account_id, original_folder, original_imap_uidvalidity, original_imap_uid)
);

-- ============================================================================
-- 6. Hilos operativos del sistema
-- ============================================================================

CREATE TABLE system_threads (
    id bigserial PRIMARY KEY,
    system_thread_uid uuid NOT NULL DEFAULT gen_random_uuid() UNIQUE,
    account_id bigint NOT NULL REFERENCES collaborative_accounts(id) ON DELETE CASCADE,
    title text,
    subject_normalized text,
    status system_thread_status NOT NULL DEFAULT 'active',
    detected_from_message_id bigint REFERENCES email_messages(id) ON DELETE SET NULL,
    created_reason text,
    created_by_user_id bigint REFERENCES account_users(id) ON DELETE SET NULL,
    merged_into_thread_id bigint REFERENCES system_threads(id) ON DELETE SET NULL,
    merged_at timestamptz,
    archived_at timestamptz,
    created_at timestamptz NOT NULL DEFAULT now(),
    updated_at timestamptz NOT NULL DEFAULT now(),

    CONSTRAINT system_thread_merge_shape CHECK (
        (status <> 'merged' AND merged_into_thread_id IS NULL)
        OR
        (status = 'merged' AND merged_into_thread_id IS NOT NULL)
    )
);

CREATE INDEX ix_system_threads_account_status ON system_threads (account_id, status, updated_at DESC);
CREATE INDEX ix_system_threads_subject ON system_threads (account_id, subject_normalized);

CREATE TABLE email_thread_members (
    id bigserial PRIMARY KEY,
    thread_id bigint NOT NULL REFERENCES system_threads(id) ON DELETE CASCADE,
    email_message_id bigint NOT NULL REFERENCES email_messages(id) ON DELETE CASCADE,
    position_asc integer NOT NULL DEFAULT 0,
    status thread_member_status NOT NULL DEFAULT 'active',
    added_by_user_id bigint REFERENCES account_users(id) ON DELETE SET NULL,
    added_reason text,
    added_at timestamptz NOT NULL DEFAULT now(),
    removed_by_user_id bigint REFERENCES account_users(id) ON DELETE SET NULL,
    removed_reason text,
    removed_at timestamptz,
    moved_from_thread_id bigint REFERENCES system_threads(id) ON DELETE SET NULL,
    moved_to_thread_id bigint REFERENCES system_threads(id) ON DELETE SET NULL,

    CONSTRAINT thread_member_removed_shape CHECK (
        (status = 'active' AND removed_at IS NULL)
        OR
        (status IN ('moved', 'removed') AND removed_at IS NOT NULL)
    )
);

-- Un correo archivado solo puede pertenecer a un hilo activo a la vez.
CREATE UNIQUE INDEX uq_email_one_active_thread
ON email_thread_members (email_message_id)
WHERE status = 'active';

CREATE UNIQUE INDEX uq_thread_active_email_once
ON email_thread_members (thread_id, email_message_id)
WHERE status = 'active';

CREATE INDEX ix_email_thread_members_thread_position ON email_thread_members (thread_id, position_asc, email_message_id);
CREATE INDEX ix_email_thread_members_email ON email_thread_members (email_message_id);

CREATE TABLE thread_operations (
    id bigserial PRIMARY KEY,
    account_id bigint NOT NULL REFERENCES collaborative_accounts(id) ON DELETE CASCADE,
    operation_type text NOT NULL CHECK (operation_type IN (
        'create_thread', 'rename_thread', 'add_email', 'remove_email', 'move_email',
        'merge_threads', 'split_thread', 'archive_thread', 'restore_thread'
    )),
    source_thread_id bigint REFERENCES system_threads(id) ON DELETE SET NULL,
    target_thread_id bigint REFERENCES system_threads(id) ON DELETE SET NULL,
    email_message_id bigint REFERENCES email_messages(id) ON DELETE SET NULL,
    performed_by_user_id bigint REFERENCES account_users(id) ON DELETE SET NULL,
    reason text,
    details_json jsonb NOT NULL DEFAULT '{}'::jsonb,
    created_at timestamptz NOT NULL DEFAULT now()
);

CREATE INDEX ix_thread_operations_account_created ON thread_operations (account_id, created_at DESC);
CREATE INDEX ix_thread_operations_thread ON thread_operations (source_thread_id, target_thread_id);

CREATE TABLE thread_merge_history (
    id bigserial PRIMARY KEY,
    account_id bigint NOT NULL REFERENCES collaborative_accounts(id) ON DELETE CASCADE,
    source_thread_id bigint NOT NULL REFERENCES system_threads(id) ON DELETE RESTRICT,
    target_thread_id bigint NOT NULL REFERENCES system_threads(id) ON DELETE RESTRICT,
    merged_by_user_id bigint REFERENCES account_users(id) ON DELETE SET NULL,
    reason text,
    details_json jsonb NOT NULL DEFAULT '{}'::jsonb,
    merged_at timestamptz NOT NULL DEFAULT now(),
    UNIQUE (source_thread_id),
    CONSTRAINT thread_merge_not_same CHECK (source_thread_id <> target_thread_id)
);

-- ============================================================================
-- 7. Tickets GLPI y relaciones muchos-a-muchos
-- ============================================================================

CREATE TABLE glpi_ticket_cache (
    id bigserial PRIMARY KEY,
    account_id bigint NOT NULL REFERENCES collaborative_accounts(id) ON DELETE CASCADE,
    glpi_instance_id bigint REFERENCES glpi_instances(id) ON DELETE SET NULL,
    glpi_ticket_id bigint NOT NULL,
    title text,
    status text,
    priority text,
    urgency text,
    impact text,
    entity_id bigint,
    group_id bigint,
    requester_json jsonb NOT NULL DEFAULT '[]'::jsonb,
    assignee_json jsonb NOT NULL DEFAULT '[]'::jsonb,
    raw_json jsonb NOT NULL DEFAULT '{}'::jsonb,
    last_sync_at timestamptz,
    created_at timestamptz NOT NULL DEFAULT now(),
    updated_at timestamptz NOT NULL DEFAULT now(),
    UNIQUE (glpi_instance_id, glpi_ticket_id)
);

CREATE INDEX ix_glpi_ticket_cache_account ON glpi_ticket_cache (account_id, glpi_ticket_id);
CREATE INDEX ix_glpi_ticket_cache_status ON glpi_ticket_cache (account_id, status);

CREATE TABLE glpi_ticket_email_links (
    id bigserial PRIMARY KEY,
    account_id bigint NOT NULL REFERENCES collaborative_accounts(id) ON DELETE CASCADE,
    glpi_ticket_cache_id bigint NOT NULL REFERENCES glpi_ticket_cache(id) ON DELETE CASCADE,
    email_message_id bigint NOT NULL REFERENCES email_messages(id) ON DELETE CASCADE,
    origin glpi_link_origin NOT NULL DEFAULT 'manual',
    status glpi_link_status NOT NULL DEFAULT 'active',
    created_by_user_id bigint REFERENCES account_users(id) ON DELETE SET NULL,
    created_at timestamptz NOT NULL DEFAULT now(),
    detached_by_user_id bigint REFERENCES account_users(id) ON DELETE SET NULL,
    detached_at timestamptz,
    notes text,
    CONSTRAINT ticket_email_link_detach_shape CHECK (
        (status = 'active' AND detached_at IS NULL)
        OR
        (status = 'detached' AND detached_at IS NOT NULL)
    )
);

CREATE UNIQUE INDEX uq_active_ticket_email_link
ON glpi_ticket_email_links (glpi_ticket_cache_id, email_message_id)
WHERE status = 'active';

CREATE INDEX ix_ticket_email_links_email ON glpi_ticket_email_links (email_message_id, status);
CREATE INDEX ix_ticket_email_links_ticket ON glpi_ticket_email_links (glpi_ticket_cache_id, status);

CREATE TABLE glpi_ticket_thread_links (
    id bigserial PRIMARY KEY,
    account_id bigint NOT NULL REFERENCES collaborative_accounts(id) ON DELETE CASCADE,
    glpi_ticket_cache_id bigint NOT NULL REFERENCES glpi_ticket_cache(id) ON DELETE CASCADE,
    thread_id bigint NOT NULL REFERENCES system_threads(id) ON DELETE CASCADE,
    origin glpi_link_origin NOT NULL DEFAULT 'manual',
    status glpi_link_status NOT NULL DEFAULT 'active',
    created_by_user_id bigint REFERENCES account_users(id) ON DELETE SET NULL,
    created_at timestamptz NOT NULL DEFAULT now(),
    detached_by_user_id bigint REFERENCES account_users(id) ON DELETE SET NULL,
    detached_at timestamptz,
    notes text,
    CONSTRAINT ticket_thread_link_detach_shape CHECK (
        (status = 'active' AND detached_at IS NULL)
        OR
        (status = 'detached' AND detached_at IS NOT NULL)
    )
);

CREATE UNIQUE INDEX uq_active_ticket_thread_link
ON glpi_ticket_thread_links (glpi_ticket_cache_id, thread_id)
WHERE status = 'active';

CREATE INDEX ix_ticket_thread_links_thread ON glpi_ticket_thread_links (thread_id, status);
CREATE INDEX ix_ticket_thread_links_ticket ON glpi_ticket_thread_links (glpi_ticket_cache_id, status);

CREATE TABLE glpi_ticket_relationships (
    id bigserial PRIMARY KEY,
    account_id bigint NOT NULL REFERENCES collaborative_accounts(id) ON DELETE CASCADE,
    source_ticket_cache_id bigint NOT NULL REFERENCES glpi_ticket_cache(id) ON DELETE CASCADE,
    target_ticket_cache_id bigint NOT NULL REFERENCES glpi_ticket_cache(id) ON DELETE CASCADE,
    relationship_type text NOT NULL DEFAULT 'related',
    created_by_user_id bigint REFERENCES account_users(id) ON DELETE SET NULL,
    created_at timestamptz NOT NULL DEFAULT now(),
    notes text,
    CONSTRAINT glpi_ticket_relationship_not_self CHECK (source_ticket_cache_id <> target_ticket_cache_id),
    UNIQUE (source_ticket_cache_id, target_ticket_cache_id, relationship_type)
);

CREATE TABLE glpi_api_operations (
    id bigserial PRIMARY KEY,
    account_id bigint NOT NULL REFERENCES collaborative_accounts(id) ON DELETE CASCADE,
    glpi_instance_id bigint REFERENCES glpi_instances(id) ON DELETE SET NULL,
    glpi_ticket_cache_id bigint REFERENCES glpi_ticket_cache(id) ON DELETE SET NULL,
    operation_type text NOT NULL,
    requested_by_user_id bigint REFERENCES account_users(id) ON DELETE SET NULL,
    request_payload_json jsonb,
    response_status_code integer,
    response_json jsonb,
    success boolean NOT NULL DEFAULT false,
    error_message text,
    created_at timestamptz NOT NULL DEFAULT now()
);

CREATE INDEX ix_glpi_api_operations_account_created ON glpi_api_operations (account_id, created_at DESC);
CREATE INDEX ix_glpi_api_operations_ticket ON glpi_api_operations (glpi_ticket_cache_id, created_at DESC);

-- ============================================================================
-- 8. Prompts, IA, procesamiento y trazabilidad LLM
-- ============================================================================

CREATE TABLE ai_prompt_templates (
    id bigserial PRIMARY KEY,
    key text NOT NULL UNIQUE,
    name text NOT NULL,
    description text,
    category text,
    variables_schema_json jsonb NOT NULL DEFAULT '{}'::jsonb,
    active boolean NOT NULL DEFAULT true,
    created_at timestamptz NOT NULL DEFAULT now(),
    updated_at timestamptz NOT NULL DEFAULT now()
);

CREATE TABLE ai_prompt_versions (
    id bigserial PRIMARY KEY,
    template_id bigint NOT NULL REFERENCES ai_prompt_templates(id) ON DELETE CASCADE,
    version_number integer NOT NULL CHECK (version_number > 0),
    system_prompt_template text NOT NULL,
    user_prompt_template text NOT NULL,
    response_schema_json jsonb NOT NULL DEFAULT '{}'::jsonb,
    example_input_json jsonb NOT NULL DEFAULT '{}'::jsonb,
    expected_output_example_json jsonb NOT NULL DEFAULT '{}'::jsonb,
    default_llm_params_json jsonb NOT NULL DEFAULT '{}'::jsonb,
    enable_thinking boolean NOT NULL DEFAULT false,
    timeout_seconds integer NOT NULL DEFAULT 300 CHECK (timeout_seconds BETWEEN 1 AND 3600),
    is_active boolean NOT NULL DEFAULT false,
    created_by_user_id bigint REFERENCES account_users(id) ON DELETE SET NULL,
    created_at timestamptz NOT NULL DEFAULT now(),
    notes text,
    UNIQUE (template_id, version_number)
);

CREATE UNIQUE INDEX uq_ai_prompt_one_active_version
ON ai_prompt_versions (template_id)
WHERE is_active = true;

CREATE TABLE ai_call_history (
    id bigserial PRIMARY KEY,
    account_id bigint REFERENCES collaborative_accounts(id) ON DELETE SET NULL,
    created_by_user_id bigint REFERENCES account_users(id) ON DELETE SET NULL,
    scope ai_scope NOT NULL,
    call_source text,
    call_purpose text,
    prompt_version_id bigint REFERENCES ai_prompt_versions(id) ON DELETE SET NULL,
    model text,
    endpoint_url text,
    enable_thinking boolean,
    temperature numeric,
    top_p numeric,
    top_k integer,
    max_tokens integer,
    timeout_seconds integer,
    duration_ms integer,
    status text NOT NULL,
    http_status_code integer,
    error_type text,
    error_message text,
    request_payload_json jsonb,
    request_messages_json jsonb,
    response_full_json jsonb,
    response_message_content text,
    response_parsed_json jsonb,
    json_parse_ok boolean,
    json_validation_ok boolean,
    json_validation_errors_json jsonb,
    prompt_tokens integer,
    completion_tokens integer,
    total_tokens integer,
    related_email_message_id bigint REFERENCES email_messages(id) ON DELETE SET NULL,
    related_thread_id bigint REFERENCES system_threads(id) ON DELETE SET NULL,
    related_glpi_ticket_cache_id bigint REFERENCES glpi_ticket_cache(id) ON DELETE SET NULL,
    created_at timestamptz NOT NULL DEFAULT now()
);

CREATE INDEX ix_ai_call_history_account_created ON ai_call_history (account_id, created_at DESC);
CREATE INDEX ix_ai_call_history_related_email ON ai_call_history (related_email_message_id);
CREATE INDEX ix_ai_call_history_related_thread ON ai_call_history (related_thread_id);

CREATE TABLE email_ai_processing (
    id bigserial PRIMARY KEY,
    email_message_id bigint NOT NULL REFERENCES email_messages(id) ON DELETE CASCADE,
    prompt_version_id bigint REFERENCES ai_prompt_versions(id) ON DELETE SET NULL,
    llm_call_history_id bigint REFERENCES ai_call_history(id) ON DELETE SET NULL,
    status ai_processing_status NOT NULL DEFAULT 'pending',
    body_new text,
    body_new_found boolean,
    body_new_is_too_short boolean,
    needs_thread_context boolean,
    extraction_confidence double precision CHECK (extraction_confidence IS NULL OR extraction_confidence BETWEEN 0 AND 1),
    summary_json jsonb,
    tipo_correo text,
    accion_sugerida text,
    prioridad_sugerida text,
    requiere_revision_humana boolean,
    processed_at timestamptz,
    error_message text,
    created_at timestamptz NOT NULL DEFAULT now(),
    updated_at timestamptz NOT NULL DEFAULT now(),
    UNIQUE (email_message_id, prompt_version_id)
);

CREATE INDEX ix_email_ai_processing_status ON email_ai_processing (status, created_at);

CREATE TABLE thread_ai_syntheses (
    id bigserial PRIMARY KEY,
    thread_id bigint NOT NULL REFERENCES system_threads(id) ON DELETE CASCADE,
    latest_email_message_id bigint REFERENCES email_messages(id) ON DELETE SET NULL,
    prompt_version_id bigint REFERENCES ai_prompt_versions(id) ON DELETE SET NULL,
    llm_call_history_id bigint REFERENCES ai_call_history(id) ON DELETE SET NULL,
    status ai_processing_status NOT NULL DEFAULT 'pending',
    state_summary_json jsonb,
    short_dialogue_text text,
    synthesized_at timestamptz,
    error_message text,
    created_at timestamptz NOT NULL DEFAULT now(),
    updated_at timestamptz NOT NULL DEFAULT now(),
    UNIQUE (thread_id, latest_email_message_id, prompt_version_id)
);

CREATE INDEX ix_thread_ai_syntheses_thread ON thread_ai_syntheses (thread_id, synthesized_at DESC);

-- ============================================================================
-- 9. Auditoría funcional de aplicación
-- ============================================================================

CREATE TABLE audit_log (
    id bigserial PRIMARY KEY,
    account_id bigint REFERENCES collaborative_accounts(id) ON DELETE SET NULL,
    actor_user_id bigint REFERENCES account_users(id) ON DELETE SET NULL,
    actor_login_identifier citext,
    action text NOT NULL,
    entity_type text NOT NULL,
    entity_id text,
    before_json jsonb,
    after_json jsonb,
    ip_address inet,
    user_agent text,
    created_at timestamptz NOT NULL DEFAULT now()
);

CREATE INDEX ix_audit_log_account_created ON audit_log (account_id, created_at DESC);
CREATE INDEX ix_audit_log_actor_created ON audit_log (actor_user_id, created_at DESC);
CREATE INDEX ix_audit_log_entity ON audit_log (entity_type, entity_id);

-- ============================================================================
-- 10. Vistas de consulta para ticket -> emails -> hilos -> tickets relacionados
-- ============================================================================

CREATE VIEW v_ticket_email_context AS
SELECT
    tel.account_id,
    tel.glpi_ticket_cache_id,
    gtc.glpi_ticket_id,
    tel.email_message_id,
    NULL::bigint AS thread_id,
    'email_direct'::text AS relation_source,
    tel.created_at AS linked_at
FROM glpi_ticket_email_links tel
JOIN glpi_ticket_cache gtc ON gtc.id = tel.glpi_ticket_cache_id
WHERE tel.status = 'active'

UNION

SELECT
    ttl.account_id,
    ttl.glpi_ticket_cache_id,
    gtc.glpi_ticket_id,
    etm.email_message_id,
    ttl.thread_id,
    'thread_expanded'::text AS relation_source,
    ttl.created_at AS linked_at
FROM glpi_ticket_thread_links ttl
JOIN glpi_ticket_cache gtc ON gtc.id = ttl.glpi_ticket_cache_id
JOIN email_thread_members etm ON etm.thread_id = ttl.thread_id AND etm.status = 'active'
WHERE ttl.status = 'active';

CREATE VIEW v_ticket_related_tickets_by_email AS
SELECT DISTINCT
    a.account_id,
    a.glpi_ticket_cache_id AS source_ticket_cache_id,
    a.glpi_ticket_id AS source_glpi_ticket_id,
    b.glpi_ticket_cache_id AS related_ticket_cache_id,
    b.glpi_ticket_id AS related_glpi_ticket_id,
    a.email_message_id,
    'shared_email'::text AS relation_reason
FROM v_ticket_email_context a
JOIN v_ticket_email_context b
  ON b.account_id = a.account_id
 AND b.email_message_id = a.email_message_id
 AND b.glpi_ticket_cache_id <> a.glpi_ticket_cache_id;

CREATE VIEW v_thread_related_tickets AS
SELECT DISTINCT
    st.account_id,
    st.id AS thread_id,
    gtc.id AS glpi_ticket_cache_id,
    gtc.glpi_ticket_id,
    'thread_direct'::text AS relation_source
FROM system_threads st
JOIN glpi_ticket_thread_links ttl ON ttl.thread_id = st.id AND ttl.status = 'active'
JOIN glpi_ticket_cache gtc ON gtc.id = ttl.glpi_ticket_cache_id

UNION

SELECT DISTINCT
    st.account_id,
    st.id AS thread_id,
    gtc.id AS glpi_ticket_cache_id,
    gtc.glpi_ticket_id,
    'email_in_thread'::text AS relation_source
FROM system_threads st
JOIN email_thread_members etm ON etm.thread_id = st.id AND etm.status = 'active'
JOIN glpi_ticket_email_links tel ON tel.email_message_id = etm.email_message_id AND tel.status = 'active'
JOIN glpi_ticket_cache gtc ON gtc.id = tel.glpi_ticket_cache_id;

-- ============================================================================
-- 11. Comentarios de diseño
-- ============================================================================

COMMENT ON SCHEMA gestor_tickets IS 'Esquema funcional del gestor de tickets v2 sin triggers. updated_at debe mantenerlo la aplicación.';
COMMENT ON TABLE collaborative_accounts IS 'Cuenta colaborativa principal. Login principal validado contra GLPI, contraseña GLPI no almacenada.';
COMMENT ON TABLE account_users IS 'Usuarios gestores o colaboradores. Los gestores se autentican contra GLPI; los colaboradores contra password_hash local.';
COMMENT ON TABLE personal_mail_accounts IS 'Cuentas personales opcionales de colaboradores. No se archivan ni se procesan por IA salvo transferencia explícita.';
COMMENT ON TABLE email_messages IS 'Correos archivados como .eml bajo una cuenta colaborativa principal, con system_uid propio del sistema.';
COMMENT ON TABLE system_threads IS 'Hilos operativos propios del sistema, editables, fusionables y separables.';
COMMENT ON TABLE glpi_ticket_email_links IS 'Relación muchos-a-muchos entre tickets GLPI y emails.';
COMMENT ON TABLE glpi_ticket_thread_links IS 'Relación muchos-a-muchos entre tickets GLPI y hilos del sistema.';

COMMIT;
