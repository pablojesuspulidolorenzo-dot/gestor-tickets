-- ============================================================================
-- Gestor Tickets v2 - PostgreSQL 17 - Esquema completo SIN TRIGGERS con datos
-- ============================================================================
-- Generado desde la base de datos Docker actual.
-- Incluye estructura y datos del esquema gestor_tickets.
-- ADVERTENCIA: contiene datos reales, incluidos valores cifrados/hash.
-- ============================================================================

--
-- PostgreSQL database dump
--

\restrict NQ2PMadBMMwnoDZcP0WGbS8uhQiU3U3P4x0ijr7IFizQKTJdH1DomJCVPaVgvvQ

-- Dumped from database version 17.10 (Debian 17.10-1.pgdg13+1)
-- Dumped by pg_dump version 17.10 (Debian 17.10-1.pgdg13+1)

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET transaction_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

ALTER TABLE IF EXISTS ONLY gestor_tickets.thread_operations DROP CONSTRAINT IF EXISTS thread_operations_target_thread_id_fkey;
ALTER TABLE IF EXISTS ONLY gestor_tickets.thread_operations DROP CONSTRAINT IF EXISTS thread_operations_source_thread_id_fkey;
ALTER TABLE IF EXISTS ONLY gestor_tickets.thread_operations DROP CONSTRAINT IF EXISTS thread_operations_performed_by_user_id_fkey;
ALTER TABLE IF EXISTS ONLY gestor_tickets.thread_operations DROP CONSTRAINT IF EXISTS thread_operations_email_message_id_fkey;
ALTER TABLE IF EXISTS ONLY gestor_tickets.thread_operations DROP CONSTRAINT IF EXISTS thread_operations_account_id_fkey;
ALTER TABLE IF EXISTS ONLY gestor_tickets.thread_merge_history DROP CONSTRAINT IF EXISTS thread_merge_history_target_thread_id_fkey;
ALTER TABLE IF EXISTS ONLY gestor_tickets.thread_merge_history DROP CONSTRAINT IF EXISTS thread_merge_history_source_thread_id_fkey;
ALTER TABLE IF EXISTS ONLY gestor_tickets.thread_merge_history DROP CONSTRAINT IF EXISTS thread_merge_history_merged_by_user_id_fkey;
ALTER TABLE IF EXISTS ONLY gestor_tickets.thread_merge_history DROP CONSTRAINT IF EXISTS thread_merge_history_account_id_fkey;
ALTER TABLE IF EXISTS ONLY gestor_tickets.thread_ai_syntheses DROP CONSTRAINT IF EXISTS thread_ai_syntheses_thread_id_fkey;
ALTER TABLE IF EXISTS ONLY gestor_tickets.thread_ai_syntheses DROP CONSTRAINT IF EXISTS thread_ai_syntheses_prompt_version_id_fkey;
ALTER TABLE IF EXISTS ONLY gestor_tickets.thread_ai_syntheses DROP CONSTRAINT IF EXISTS thread_ai_syntheses_llm_call_history_id_fkey;
ALTER TABLE IF EXISTS ONLY gestor_tickets.thread_ai_syntheses DROP CONSTRAINT IF EXISTS thread_ai_syntheses_latest_email_message_id_fkey;
ALTER TABLE IF EXISTS ONLY gestor_tickets.system_threads DROP CONSTRAINT IF EXISTS system_threads_merged_into_thread_id_fkey;
ALTER TABLE IF EXISTS ONLY gestor_tickets.system_threads DROP CONSTRAINT IF EXISTS system_threads_detected_from_message_id_fkey;
ALTER TABLE IF EXISTS ONLY gestor_tickets.system_threads DROP CONSTRAINT IF EXISTS system_threads_created_by_user_id_fkey;
ALTER TABLE IF EXISTS ONLY gestor_tickets.system_threads DROP CONSTRAINT IF EXISTS system_threads_account_id_fkey;
ALTER TABLE IF EXISTS ONLY gestor_tickets.personal_message_transfer_log DROP CONSTRAINT IF EXISTS personal_message_transfer_log_transferred_email_message_id_fkey;
ALTER TABLE IF EXISTS ONLY gestor_tickets.personal_message_transfer_log DROP CONSTRAINT IF EXISTS personal_message_transfer_log_transferred_by_user_id_fkey;
ALTER TABLE IF EXISTS ONLY gestor_tickets.personal_message_transfer_log DROP CONSTRAINT IF EXISTS personal_message_transfer_log_target_account_id_fkey;
ALTER TABLE IF EXISTS ONLY gestor_tickets.personal_message_transfer_log DROP CONSTRAINT IF EXISTS personal_message_transfer_log_personal_account_id_fkey;
ALTER TABLE IF EXISTS ONLY gestor_tickets.personal_mail_accounts DROP CONSTRAINT IF EXISTS personal_mail_accounts_user_id_fkey;
ALTER TABLE IF EXISTS ONLY gestor_tickets.personal_mail_accounts DROP CONSTRAINT IF EXISTS personal_mail_accounts_account_id_fkey;
ALTER TABLE IF EXISTS ONLY gestor_tickets.mail_ingestion_runs DROP CONSTRAINT IF EXISTS mail_ingestion_runs_job_id_fkey;
ALTER TABLE IF EXISTS ONLY gestor_tickets.mail_ingestion_runs DROP CONSTRAINT IF EXISTS mail_ingestion_runs_account_id_fkey;
ALTER TABLE IF EXISTS ONLY gestor_tickets.mail_ingestion_jobs DROP CONSTRAINT IF EXISTS mail_ingestion_jobs_updated_by_user_id_fkey;
ALTER TABLE IF EXISTS ONLY gestor_tickets.mail_ingestion_jobs DROP CONSTRAINT IF EXISTS mail_ingestion_jobs_created_by_user_id_fkey;
ALTER TABLE IF EXISTS ONLY gestor_tickets.mail_ingestion_jobs DROP CONSTRAINT IF EXISTS mail_ingestion_jobs_account_id_fkey;
ALTER TABLE IF EXISTS ONLY gestor_tickets.glpi_ticket_thread_links DROP CONSTRAINT IF EXISTS glpi_ticket_thread_links_thread_id_fkey;
ALTER TABLE IF EXISTS ONLY gestor_tickets.glpi_ticket_thread_links DROP CONSTRAINT IF EXISTS glpi_ticket_thread_links_glpi_ticket_cache_id_fkey;
ALTER TABLE IF EXISTS ONLY gestor_tickets.glpi_ticket_thread_links DROP CONSTRAINT IF EXISTS glpi_ticket_thread_links_detached_by_user_id_fkey;
ALTER TABLE IF EXISTS ONLY gestor_tickets.glpi_ticket_thread_links DROP CONSTRAINT IF EXISTS glpi_ticket_thread_links_created_by_user_id_fkey;
ALTER TABLE IF EXISTS ONLY gestor_tickets.glpi_ticket_thread_links DROP CONSTRAINT IF EXISTS glpi_ticket_thread_links_account_id_fkey;
ALTER TABLE IF EXISTS ONLY gestor_tickets.glpi_ticket_relationships DROP CONSTRAINT IF EXISTS glpi_ticket_relationships_target_ticket_cache_id_fkey;
ALTER TABLE IF EXISTS ONLY gestor_tickets.glpi_ticket_relationships DROP CONSTRAINT IF EXISTS glpi_ticket_relationships_source_ticket_cache_id_fkey;
ALTER TABLE IF EXISTS ONLY gestor_tickets.glpi_ticket_relationships DROP CONSTRAINT IF EXISTS glpi_ticket_relationships_created_by_user_id_fkey;
ALTER TABLE IF EXISTS ONLY gestor_tickets.glpi_ticket_relationships DROP CONSTRAINT IF EXISTS glpi_ticket_relationships_account_id_fkey;
ALTER TABLE IF EXISTS ONLY gestor_tickets.glpi_ticket_email_links DROP CONSTRAINT IF EXISTS glpi_ticket_email_links_glpi_ticket_cache_id_fkey;
ALTER TABLE IF EXISTS ONLY gestor_tickets.glpi_ticket_email_links DROP CONSTRAINT IF EXISTS glpi_ticket_email_links_email_message_id_fkey;
ALTER TABLE IF EXISTS ONLY gestor_tickets.glpi_ticket_email_links DROP CONSTRAINT IF EXISTS glpi_ticket_email_links_detached_by_user_id_fkey;
ALTER TABLE IF EXISTS ONLY gestor_tickets.glpi_ticket_email_links DROP CONSTRAINT IF EXISTS glpi_ticket_email_links_created_by_user_id_fkey;
ALTER TABLE IF EXISTS ONLY gestor_tickets.glpi_ticket_email_links DROP CONSTRAINT IF EXISTS glpi_ticket_email_links_account_id_fkey;
ALTER TABLE IF EXISTS ONLY gestor_tickets.glpi_ticket_cache DROP CONSTRAINT IF EXISTS glpi_ticket_cache_glpi_instance_id_fkey;
ALTER TABLE IF EXISTS ONLY gestor_tickets.glpi_ticket_cache DROP CONSTRAINT IF EXISTS glpi_ticket_cache_account_id_fkey;
ALTER TABLE IF EXISTS ONLY gestor_tickets.glpi_api_operations DROP CONSTRAINT IF EXISTS glpi_api_operations_requested_by_user_id_fkey;
ALTER TABLE IF EXISTS ONLY gestor_tickets.glpi_api_operations DROP CONSTRAINT IF EXISTS glpi_api_operations_glpi_ticket_cache_id_fkey;
ALTER TABLE IF EXISTS ONLY gestor_tickets.glpi_api_operations DROP CONSTRAINT IF EXISTS glpi_api_operations_glpi_instance_id_fkey;
ALTER TABLE IF EXISTS ONLY gestor_tickets.glpi_api_operations DROP CONSTRAINT IF EXISTS glpi_api_operations_account_id_fkey;
ALTER TABLE IF EXISTS ONLY gestor_tickets.email_thread_members DROP CONSTRAINT IF EXISTS email_thread_members_thread_id_fkey;
ALTER TABLE IF EXISTS ONLY gestor_tickets.email_thread_members DROP CONSTRAINT IF EXISTS email_thread_members_removed_by_user_id_fkey;
ALTER TABLE IF EXISTS ONLY gestor_tickets.email_thread_members DROP CONSTRAINT IF EXISTS email_thread_members_moved_to_thread_id_fkey;
ALTER TABLE IF EXISTS ONLY gestor_tickets.email_thread_members DROP CONSTRAINT IF EXISTS email_thread_members_moved_from_thread_id_fkey;
ALTER TABLE IF EXISTS ONLY gestor_tickets.email_thread_members DROP CONSTRAINT IF EXISTS email_thread_members_email_message_id_fkey;
ALTER TABLE IF EXISTS ONLY gestor_tickets.email_thread_members DROP CONSTRAINT IF EXISTS email_thread_members_added_by_user_id_fkey;
ALTER TABLE IF EXISTS ONLY gestor_tickets.email_recipients DROP CONSTRAINT IF EXISTS email_recipients_email_message_id_fkey;
ALTER TABLE IF EXISTS ONLY gestor_tickets.email_messages DROP CONSTRAINT IF EXISTS email_messages_transferred_by_user_id_fkey;
ALTER TABLE IF EXISTS ONLY gestor_tickets.email_messages DROP CONSTRAINT IF EXISTS email_messages_imported_from_personal_account_id_fkey;
ALTER TABLE IF EXISTS ONLY gestor_tickets.email_messages DROP CONSTRAINT IF EXISTS email_messages_account_id_fkey;
ALTER TABLE IF EXISTS ONLY gestor_tickets.email_message_occurrences DROP CONSTRAINT IF EXISTS email_message_occurrences_ingestion_run_id_fkey;
ALTER TABLE IF EXISTS ONLY gestor_tickets.email_message_occurrences DROP CONSTRAINT IF EXISTS email_message_occurrences_email_message_id_fkey;
ALTER TABLE IF EXISTS ONLY gestor_tickets.email_message_occurrences DROP CONSTRAINT IF EXISTS email_message_occurrences_account_id_fkey;
ALTER TABLE IF EXISTS ONLY gestor_tickets.email_attachments DROP CONSTRAINT IF EXISTS email_attachments_email_message_id_fkey;
ALTER TABLE IF EXISTS ONLY gestor_tickets.email_ai_processing DROP CONSTRAINT IF EXISTS email_ai_processing_prompt_version_id_fkey;
ALTER TABLE IF EXISTS ONLY gestor_tickets.email_ai_processing DROP CONSTRAINT IF EXISTS email_ai_processing_llm_call_history_id_fkey;
ALTER TABLE IF EXISTS ONLY gestor_tickets.email_ai_processing DROP CONSTRAINT IF EXISTS email_ai_processing_email_message_id_fkey;
ALTER TABLE IF EXISTS ONLY gestor_tickets.collaborative_accounts DROP CONSTRAINT IF EXISTS collaborative_accounts_glpi_instance_id_fkey;
ALTER TABLE IF EXISTS ONLY gestor_tickets.audit_log DROP CONSTRAINT IF EXISTS audit_log_actor_user_id_fkey;
ALTER TABLE IF EXISTS ONLY gestor_tickets.audit_log DROP CONSTRAINT IF EXISTS audit_log_account_id_fkey;
ALTER TABLE IF EXISTS ONLY gestor_tickets.ai_prompt_versions DROP CONSTRAINT IF EXISTS ai_prompt_versions_template_id_fkey;
ALTER TABLE IF EXISTS ONLY gestor_tickets.ai_prompt_versions DROP CONSTRAINT IF EXISTS ai_prompt_versions_created_by_user_id_fkey;
ALTER TABLE IF EXISTS ONLY gestor_tickets.ai_llm_endpoint_models DROP CONSTRAINT IF EXISTS ai_llm_endpoint_models_endpoint_id_fkey;
ALTER TABLE IF EXISTS ONLY gestor_tickets.ai_endpoint_validation_logs DROP CONSTRAINT IF EXISTS ai_endpoint_validation_logs_endpoint_id_fkey;
ALTER TABLE IF EXISTS ONLY gestor_tickets.ai_call_history DROP CONSTRAINT IF EXISTS ai_call_history_related_thread_id_fkey;
ALTER TABLE IF EXISTS ONLY gestor_tickets.ai_call_history DROP CONSTRAINT IF EXISTS ai_call_history_related_glpi_ticket_cache_id_fkey;
ALTER TABLE IF EXISTS ONLY gestor_tickets.ai_call_history DROP CONSTRAINT IF EXISTS ai_call_history_related_email_message_id_fkey;
ALTER TABLE IF EXISTS ONLY gestor_tickets.ai_call_history DROP CONSTRAINT IF EXISTS ai_call_history_prompt_version_id_fkey;
ALTER TABLE IF EXISTS ONLY gestor_tickets.ai_call_history DROP CONSTRAINT IF EXISTS ai_call_history_created_by_user_id_fkey;
ALTER TABLE IF EXISTS ONLY gestor_tickets.ai_call_history DROP CONSTRAINT IF EXISTS ai_call_history_account_id_fkey;
ALTER TABLE IF EXISTS ONLY gestor_tickets.account_users DROP CONSTRAINT IF EXISTS account_users_created_by_user_id_fkey;
ALTER TABLE IF EXISTS ONLY gestor_tickets.account_users DROP CONSTRAINT IF EXISTS account_users_account_id_fkey;
DROP INDEX IF EXISTS gestor_tickets.uq_thread_active_email_once;
DROP INDEX IF EXISTS gestor_tickets.uq_email_one_active_thread;
DROP INDEX IF EXISTS gestor_tickets.uq_email_messages_account_message_id_header;
DROP INDEX IF EXISTS gestor_tickets.uq_email_messages_account_eml_sha256;
DROP INDEX IF EXISTS gestor_tickets.uq_ai_prompt_one_active_version;
DROP INDEX IF EXISTS gestor_tickets.uq_ai_llm_endpoints_one_default;
DROP INDEX IF EXISTS gestor_tickets.uq_active_ticket_thread_link;
DROP INDEX IF EXISTS gestor_tickets.uq_active_ticket_email_link;
DROP INDEX IF EXISTS gestor_tickets.uq_account_users_username_per_account;
DROP INDEX IF EXISTS gestor_tickets.ix_ticket_thread_links_ticket;
DROP INDEX IF EXISTS gestor_tickets.ix_ticket_thread_links_thread;
DROP INDEX IF EXISTS gestor_tickets.ix_ticket_email_links_ticket;
DROP INDEX IF EXISTS gestor_tickets.ix_ticket_email_links_email;
DROP INDEX IF EXISTS gestor_tickets.ix_thread_operations_thread;
DROP INDEX IF EXISTS gestor_tickets.ix_thread_operations_account_created;
DROP INDEX IF EXISTS gestor_tickets.ix_thread_ai_syntheses_thread;
DROP INDEX IF EXISTS gestor_tickets.ix_system_threads_subject;
DROP INDEX IF EXISTS gestor_tickets.ix_system_threads_account_status;
DROP INDEX IF EXISTS gestor_tickets.ix_personal_mail_accounts_account_user;
DROP INDEX IF EXISTS gestor_tickets.ix_mail_ingestion_runs_account_started;
DROP INDEX IF EXISTS gestor_tickets.ix_mail_ingestion_jobs_due;
DROP INDEX IF EXISTS gestor_tickets.ix_glpi_ticket_cache_status;
DROP INDEX IF EXISTS gestor_tickets.ix_glpi_ticket_cache_account;
DROP INDEX IF EXISTS gestor_tickets.ix_glpi_api_operations_ticket;
DROP INDEX IF EXISTS gestor_tickets.ix_glpi_api_operations_account_created;
DROP INDEX IF EXISTS gestor_tickets.ix_email_thread_members_thread_position;
DROP INDEX IF EXISTS gestor_tickets.ix_email_thread_members_email;
DROP INDEX IF EXISTS gestor_tickets.ix_email_recipients_message;
DROP INDEX IF EXISTS gestor_tickets.ix_email_recipients_email;
DROP INDEX IF EXISTS gestor_tickets.ix_email_occurrences_email;
DROP INDEX IF EXISTS gestor_tickets.ix_email_occurrences_account_folder;
DROP INDEX IF EXISTS gestor_tickets.ix_email_messages_from_email;
DROP INDEX IF EXISTS gestor_tickets.ix_email_messages_account_subject;
DROP INDEX IF EXISTS gestor_tickets.ix_email_messages_account_date;
DROP INDEX IF EXISTS gestor_tickets.ix_email_attachments_message;
DROP INDEX IF EXISTS gestor_tickets.ix_email_ai_processing_status;
DROP INDEX IF EXISTS gestor_tickets.ix_audit_log_entity;
DROP INDEX IF EXISTS gestor_tickets.ix_audit_log_actor_created;
DROP INDEX IF EXISTS gestor_tickets.ix_audit_log_account_created;
DROP INDEX IF EXISTS gestor_tickets.ix_ai_llm_endpoints_active;
DROP INDEX IF EXISTS gestor_tickets.ix_ai_llm_endpoint_models_endpoint_seen;
DROP INDEX IF EXISTS gestor_tickets.ix_ai_endpoint_validation_logs_endpoint_created;
DROP INDEX IF EXISTS gestor_tickets.ix_ai_call_history_related_thread;
DROP INDEX IF EXISTS gestor_tickets.ix_ai_call_history_related_email;
DROP INDEX IF EXISTS gestor_tickets.ix_ai_call_history_account_created;
DROP INDEX IF EXISTS gestor_tickets.ix_account_users_status;
DROP INDEX IF EXISTS gestor_tickets.ix_account_users_account_role;
ALTER TABLE IF EXISTS ONLY gestor_tickets.ai_llm_endpoint_models DROP CONSTRAINT IF EXISTS uq_ai_llm_endpoint_models_endpoint_model;
ALTER TABLE IF EXISTS ONLY gestor_tickets.thread_operations DROP CONSTRAINT IF EXISTS thread_operations_pkey;
ALTER TABLE IF EXISTS ONLY gestor_tickets.thread_merge_history DROP CONSTRAINT IF EXISTS thread_merge_history_source_thread_id_key;
ALTER TABLE IF EXISTS ONLY gestor_tickets.thread_merge_history DROP CONSTRAINT IF EXISTS thread_merge_history_pkey;
ALTER TABLE IF EXISTS ONLY gestor_tickets.thread_ai_syntheses DROP CONSTRAINT IF EXISTS thread_ai_syntheses_thread_id_latest_email_message_id_promp_key;
ALTER TABLE IF EXISTS ONLY gestor_tickets.thread_ai_syntheses DROP CONSTRAINT IF EXISTS thread_ai_syntheses_pkey;
ALTER TABLE IF EXISTS ONLY gestor_tickets.system_threads DROP CONSTRAINT IF EXISTS system_threads_system_thread_uid_key;
ALTER TABLE IF EXISTS ONLY gestor_tickets.system_threads DROP CONSTRAINT IF EXISTS system_threads_pkey;
ALTER TABLE IF EXISTS ONLY gestor_tickets.personal_message_transfer_log DROP CONSTRAINT IF EXISTS personal_message_transfer_log_pkey;
ALTER TABLE IF EXISTS ONLY gestor_tickets.personal_message_transfer_log DROP CONSTRAINT IF EXISTS personal_message_transfer_log_personal_account_id_original__key;
ALTER TABLE IF EXISTS ONLY gestor_tickets.personal_mail_accounts DROP CONSTRAINT IF EXISTS personal_mail_accounts_user_id_email_key;
ALTER TABLE IF EXISTS ONLY gestor_tickets.personal_mail_accounts DROP CONSTRAINT IF EXISTS personal_mail_accounts_public_uid_key;
ALTER TABLE IF EXISTS ONLY gestor_tickets.personal_mail_accounts DROP CONSTRAINT IF EXISTS personal_mail_accounts_pkey;
ALTER TABLE IF EXISTS ONLY gestor_tickets.mail_ingestion_runs DROP CONSTRAINT IF EXISTS mail_ingestion_runs_pkey;
ALTER TABLE IF EXISTS ONLY gestor_tickets.mail_ingestion_jobs DROP CONSTRAINT IF EXISTS mail_ingestion_jobs_pkey;
ALTER TABLE IF EXISTS ONLY gestor_tickets.mail_ingestion_jobs DROP CONSTRAINT IF EXISTS mail_ingestion_jobs_account_id_key;
ALTER TABLE IF EXISTS ONLY gestor_tickets.glpi_ticket_thread_links DROP CONSTRAINT IF EXISTS glpi_ticket_thread_links_pkey;
ALTER TABLE IF EXISTS ONLY gestor_tickets.glpi_ticket_relationships DROP CONSTRAINT IF EXISTS glpi_ticket_relationships_source_ticket_cache_id_target_tic_key;
ALTER TABLE IF EXISTS ONLY gestor_tickets.glpi_ticket_relationships DROP CONSTRAINT IF EXISTS glpi_ticket_relationships_pkey;
ALTER TABLE IF EXISTS ONLY gestor_tickets.glpi_ticket_email_links DROP CONSTRAINT IF EXISTS glpi_ticket_email_links_pkey;
ALTER TABLE IF EXISTS ONLY gestor_tickets.glpi_ticket_cache DROP CONSTRAINT IF EXISTS glpi_ticket_cache_pkey;
ALTER TABLE IF EXISTS ONLY gestor_tickets.glpi_ticket_cache DROP CONSTRAINT IF EXISTS glpi_ticket_cache_glpi_instance_id_glpi_ticket_id_key;
ALTER TABLE IF EXISTS ONLY gestor_tickets.glpi_instances DROP CONSTRAINT IF EXISTS glpi_instances_pkey;
ALTER TABLE IF EXISTS ONLY gestor_tickets.glpi_instances DROP CONSTRAINT IF EXISTS glpi_instances_base_url_key;
ALTER TABLE IF EXISTS ONLY gestor_tickets.glpi_api_operations DROP CONSTRAINT IF EXISTS glpi_api_operations_pkey;
ALTER TABLE IF EXISTS ONLY gestor_tickets.email_thread_members DROP CONSTRAINT IF EXISTS email_thread_members_pkey;
ALTER TABLE IF EXISTS ONLY gestor_tickets.email_recipients DROP CONSTRAINT IF EXISTS email_recipients_pkey;
ALTER TABLE IF EXISTS ONLY gestor_tickets.email_messages DROP CONSTRAINT IF EXISTS email_messages_system_uid_key;
ALTER TABLE IF EXISTS ONLY gestor_tickets.email_messages DROP CONSTRAINT IF EXISTS email_messages_pkey;
ALTER TABLE IF EXISTS ONLY gestor_tickets.email_messages DROP CONSTRAINT IF EXISTS email_messages_eml_storage_path_key;
ALTER TABLE IF EXISTS ONLY gestor_tickets.email_message_occurrences DROP CONSTRAINT IF EXISTS email_message_occurrences_source_mailbox_email_folder_name__key;
ALTER TABLE IF EXISTS ONLY gestor_tickets.email_message_occurrences DROP CONSTRAINT IF EXISTS email_message_occurrences_pkey;
ALTER TABLE IF EXISTS ONLY gestor_tickets.email_attachments DROP CONSTRAINT IF EXISTS email_attachments_pkey;
ALTER TABLE IF EXISTS ONLY gestor_tickets.email_ai_processing DROP CONSTRAINT IF EXISTS email_ai_processing_pkey;
ALTER TABLE IF EXISTS ONLY gestor_tickets.email_ai_processing DROP CONSTRAINT IF EXISTS email_ai_processing_email_message_id_prompt_version_id_key;
ALTER TABLE IF EXISTS ONLY gestor_tickets.collaborative_accounts DROP CONSTRAINT IF EXISTS collaborative_accounts_public_uid_key;
ALTER TABLE IF EXISTS ONLY gestor_tickets.collaborative_accounts DROP CONSTRAINT IF EXISTS collaborative_accounts_pkey;
ALTER TABLE IF EXISTS ONLY gestor_tickets.collaborative_accounts DROP CONSTRAINT IF EXISTS collaborative_accounts_email_key;
ALTER TABLE IF EXISTS ONLY gestor_tickets.audit_log DROP CONSTRAINT IF EXISTS audit_log_pkey;
ALTER TABLE IF EXISTS ONLY gestor_tickets.app_settings DROP CONSTRAINT IF EXISTS app_settings_pkey;
ALTER TABLE IF EXISTS ONLY gestor_tickets.ai_prompt_versions DROP CONSTRAINT IF EXISTS ai_prompt_versions_template_id_version_number_key;
ALTER TABLE IF EXISTS ONLY gestor_tickets.ai_prompt_versions DROP CONSTRAINT IF EXISTS ai_prompt_versions_pkey;
ALTER TABLE IF EXISTS ONLY gestor_tickets.ai_prompt_templates DROP CONSTRAINT IF EXISTS ai_prompt_templates_pkey;
ALTER TABLE IF EXISTS ONLY gestor_tickets.ai_prompt_templates DROP CONSTRAINT IF EXISTS ai_prompt_templates_key_key;
ALTER TABLE IF EXISTS ONLY gestor_tickets.ai_llm_endpoints DROP CONSTRAINT IF EXISTS ai_llm_endpoints_public_uid_key;
ALTER TABLE IF EXISTS ONLY gestor_tickets.ai_llm_endpoints DROP CONSTRAINT IF EXISTS ai_llm_endpoints_pkey;
ALTER TABLE IF EXISTS ONLY gestor_tickets.ai_llm_endpoint_models DROP CONSTRAINT IF EXISTS ai_llm_endpoint_models_pkey;
ALTER TABLE IF EXISTS ONLY gestor_tickets.ai_endpoint_validation_logs DROP CONSTRAINT IF EXISTS ai_endpoint_validation_logs_pkey;
ALTER TABLE IF EXISTS ONLY gestor_tickets.ai_call_history DROP CONSTRAINT IF EXISTS ai_call_history_pkey;
ALTER TABLE IF EXISTS ONLY gestor_tickets.account_users DROP CONSTRAINT IF EXISTS account_users_public_uid_key;
ALTER TABLE IF EXISTS ONLY gestor_tickets.account_users DROP CONSTRAINT IF EXISTS account_users_pkey;
ALTER TABLE IF EXISTS ONLY gestor_tickets.account_users DROP CONSTRAINT IF EXISTS account_users_login_identifier_key;
ALTER TABLE IF EXISTS gestor_tickets.thread_operations ALTER COLUMN id DROP DEFAULT;
ALTER TABLE IF EXISTS gestor_tickets.thread_merge_history ALTER COLUMN id DROP DEFAULT;
ALTER TABLE IF EXISTS gestor_tickets.thread_ai_syntheses ALTER COLUMN id DROP DEFAULT;
ALTER TABLE IF EXISTS gestor_tickets.system_threads ALTER COLUMN id DROP DEFAULT;
ALTER TABLE IF EXISTS gestor_tickets.personal_message_transfer_log ALTER COLUMN id DROP DEFAULT;
ALTER TABLE IF EXISTS gestor_tickets.personal_mail_accounts ALTER COLUMN id DROP DEFAULT;
ALTER TABLE IF EXISTS gestor_tickets.mail_ingestion_runs ALTER COLUMN id DROP DEFAULT;
ALTER TABLE IF EXISTS gestor_tickets.mail_ingestion_jobs ALTER COLUMN id DROP DEFAULT;
ALTER TABLE IF EXISTS gestor_tickets.glpi_ticket_thread_links ALTER COLUMN id DROP DEFAULT;
ALTER TABLE IF EXISTS gestor_tickets.glpi_ticket_relationships ALTER COLUMN id DROP DEFAULT;
ALTER TABLE IF EXISTS gestor_tickets.glpi_ticket_email_links ALTER COLUMN id DROP DEFAULT;
ALTER TABLE IF EXISTS gestor_tickets.glpi_ticket_cache ALTER COLUMN id DROP DEFAULT;
ALTER TABLE IF EXISTS gestor_tickets.glpi_instances ALTER COLUMN id DROP DEFAULT;
ALTER TABLE IF EXISTS gestor_tickets.glpi_api_operations ALTER COLUMN id DROP DEFAULT;
ALTER TABLE IF EXISTS gestor_tickets.email_thread_members ALTER COLUMN id DROP DEFAULT;
ALTER TABLE IF EXISTS gestor_tickets.email_recipients ALTER COLUMN id DROP DEFAULT;
ALTER TABLE IF EXISTS gestor_tickets.email_messages ALTER COLUMN id DROP DEFAULT;
ALTER TABLE IF EXISTS gestor_tickets.email_message_occurrences ALTER COLUMN id DROP DEFAULT;
ALTER TABLE IF EXISTS gestor_tickets.email_attachments ALTER COLUMN id DROP DEFAULT;
ALTER TABLE IF EXISTS gestor_tickets.email_ai_processing ALTER COLUMN id DROP DEFAULT;
ALTER TABLE IF EXISTS gestor_tickets.collaborative_accounts ALTER COLUMN id DROP DEFAULT;
ALTER TABLE IF EXISTS gestor_tickets.audit_log ALTER COLUMN id DROP DEFAULT;
ALTER TABLE IF EXISTS gestor_tickets.ai_prompt_versions ALTER COLUMN id DROP DEFAULT;
ALTER TABLE IF EXISTS gestor_tickets.ai_prompt_templates ALTER COLUMN id DROP DEFAULT;
ALTER TABLE IF EXISTS gestor_tickets.ai_llm_endpoints ALTER COLUMN id DROP DEFAULT;
ALTER TABLE IF EXISTS gestor_tickets.ai_llm_endpoint_models ALTER COLUMN id DROP DEFAULT;
ALTER TABLE IF EXISTS gestor_tickets.ai_endpoint_validation_logs ALTER COLUMN id DROP DEFAULT;
ALTER TABLE IF EXISTS gestor_tickets.ai_call_history ALTER COLUMN id DROP DEFAULT;
ALTER TABLE IF EXISTS gestor_tickets.account_users ALTER COLUMN id DROP DEFAULT;
DROP VIEW IF EXISTS gestor_tickets.v_ticket_related_tickets_by_email;
DROP VIEW IF EXISTS gestor_tickets.v_ticket_email_context;
DROP VIEW IF EXISTS gestor_tickets.v_thread_related_tickets;
DROP SEQUENCE IF EXISTS gestor_tickets.thread_operations_id_seq;
DROP TABLE IF EXISTS gestor_tickets.thread_operations;
DROP SEQUENCE IF EXISTS gestor_tickets.thread_merge_history_id_seq;
DROP TABLE IF EXISTS gestor_tickets.thread_merge_history;
DROP SEQUENCE IF EXISTS gestor_tickets.thread_ai_syntheses_id_seq;
DROP TABLE IF EXISTS gestor_tickets.thread_ai_syntheses;
DROP SEQUENCE IF EXISTS gestor_tickets.system_threads_id_seq;
DROP TABLE IF EXISTS gestor_tickets.system_threads;
DROP SEQUENCE IF EXISTS gestor_tickets.personal_message_transfer_log_id_seq;
DROP TABLE IF EXISTS gestor_tickets.personal_message_transfer_log;
DROP SEQUENCE IF EXISTS gestor_tickets.personal_mail_accounts_id_seq;
DROP TABLE IF EXISTS gestor_tickets.personal_mail_accounts;
DROP SEQUENCE IF EXISTS gestor_tickets.mail_ingestion_runs_id_seq;
DROP TABLE IF EXISTS gestor_tickets.mail_ingestion_runs;
DROP SEQUENCE IF EXISTS gestor_tickets.mail_ingestion_jobs_id_seq;
DROP TABLE IF EXISTS gestor_tickets.mail_ingestion_jobs;
DROP SEQUENCE IF EXISTS gestor_tickets.glpi_ticket_thread_links_id_seq;
DROP TABLE IF EXISTS gestor_tickets.glpi_ticket_thread_links;
DROP SEQUENCE IF EXISTS gestor_tickets.glpi_ticket_relationships_id_seq;
DROP TABLE IF EXISTS gestor_tickets.glpi_ticket_relationships;
DROP SEQUENCE IF EXISTS gestor_tickets.glpi_ticket_email_links_id_seq;
DROP TABLE IF EXISTS gestor_tickets.glpi_ticket_email_links;
DROP SEQUENCE IF EXISTS gestor_tickets.glpi_ticket_cache_id_seq;
DROP TABLE IF EXISTS gestor_tickets.glpi_ticket_cache;
DROP SEQUENCE IF EXISTS gestor_tickets.glpi_instances_id_seq;
DROP TABLE IF EXISTS gestor_tickets.glpi_instances;
DROP SEQUENCE IF EXISTS gestor_tickets.glpi_api_operations_id_seq;
DROP TABLE IF EXISTS gestor_tickets.glpi_api_operations;
DROP SEQUENCE IF EXISTS gestor_tickets.email_thread_members_id_seq;
DROP TABLE IF EXISTS gestor_tickets.email_thread_members;
DROP SEQUENCE IF EXISTS gestor_tickets.email_recipients_id_seq;
DROP TABLE IF EXISTS gestor_tickets.email_recipients;
DROP SEQUENCE IF EXISTS gestor_tickets.email_messages_id_seq;
DROP TABLE IF EXISTS gestor_tickets.email_messages;
DROP SEQUENCE IF EXISTS gestor_tickets.email_message_occurrences_id_seq;
DROP TABLE IF EXISTS gestor_tickets.email_message_occurrences;
DROP SEQUENCE IF EXISTS gestor_tickets.email_attachments_id_seq;
DROP TABLE IF EXISTS gestor_tickets.email_attachments;
DROP SEQUENCE IF EXISTS gestor_tickets.email_ai_processing_id_seq;
DROP TABLE IF EXISTS gestor_tickets.email_ai_processing;
DROP SEQUENCE IF EXISTS gestor_tickets.collaborative_accounts_id_seq;
DROP TABLE IF EXISTS gestor_tickets.collaborative_accounts;
DROP SEQUENCE IF EXISTS gestor_tickets.audit_log_id_seq;
DROP TABLE IF EXISTS gestor_tickets.audit_log;
DROP TABLE IF EXISTS gestor_tickets.app_settings;
DROP SEQUENCE IF EXISTS gestor_tickets.ai_prompt_versions_id_seq;
DROP TABLE IF EXISTS gestor_tickets.ai_prompt_versions;
DROP SEQUENCE IF EXISTS gestor_tickets.ai_prompt_templates_id_seq;
DROP TABLE IF EXISTS gestor_tickets.ai_prompt_templates;
DROP SEQUENCE IF EXISTS gestor_tickets.ai_llm_endpoints_id_seq;
DROP TABLE IF EXISTS gestor_tickets.ai_llm_endpoints;
DROP SEQUENCE IF EXISTS gestor_tickets.ai_llm_endpoint_models_id_seq;
DROP TABLE IF EXISTS gestor_tickets.ai_llm_endpoint_models;
DROP SEQUENCE IF EXISTS gestor_tickets.ai_endpoint_validation_logs_id_seq;
DROP TABLE IF EXISTS gestor_tickets.ai_endpoint_validation_logs;
DROP SEQUENCE IF EXISTS gestor_tickets.ai_call_history_id_seq;
DROP TABLE IF EXISTS gestor_tickets.ai_call_history;
DROP SEQUENCE IF EXISTS gestor_tickets.account_users_id_seq;
DROP TABLE IF EXISTS gestor_tickets.account_users;
DROP TYPE IF EXISTS gestor_tickets.thread_member_status;
DROP TYPE IF EXISTS gestor_tickets.system_thread_status;
DROP TYPE IF EXISTS gestor_tickets.mail_source;
DROP TYPE IF EXISTS gestor_tickets.mail_folder_kind;
DROP TYPE IF EXISTS gestor_tickets.mail_direction;
DROP TYPE IF EXISTS gestor_tickets.ingestion_run_status;
DROP TYPE IF EXISTS gestor_tickets.ingestion_job_status;
DROP TYPE IF EXISTS gestor_tickets.glpi_link_status;
DROP TYPE IF EXISTS gestor_tickets.glpi_link_origin;
DROP TYPE IF EXISTS gestor_tickets.ai_scope;
DROP TYPE IF EXISTS gestor_tickets.ai_processing_status;
DROP TYPE IF EXISTS gestor_tickets.account_user_status;
DROP TYPE IF EXISTS gestor_tickets.account_user_auth_mode;
DROP TYPE IF EXISTS gestor_tickets.account_status;
DROP TYPE IF EXISTS gestor_tickets.account_role;
CREATE EXTENSION IF NOT EXISTS pgcrypto WITH SCHEMA public;
CREATE EXTENSION IF NOT EXISTS citext WITH SCHEMA public;

DROP SCHEMA IF EXISTS gestor_tickets;
--
-- Name: gestor_tickets; Type: SCHEMA; Schema: -; Owner: -
--

CREATE SCHEMA gestor_tickets;


--
-- Name: SCHEMA gestor_tickets; Type: COMMENT; Schema: -; Owner: -
--

COMMENT ON SCHEMA gestor_tickets IS 'Esquema funcional del gestor de tickets v2 sin triggers. updated_at debe mantenerlo la aplicación.';


--
-- Name: account_role; Type: TYPE; Schema: gestor_tickets; Owner: -
--

CREATE TYPE gestor_tickets.account_role AS ENUM (
    'owner',
    'admin',
    'technician',
    'collaborator',
    'viewer'
);


--
-- Name: account_status; Type: TYPE; Schema: gestor_tickets; Owner: -
--

CREATE TYPE gestor_tickets.account_status AS ENUM (
    'active',
    'disabled',
    'pending_configuration',
    'error_auth',
    'error_connection',
    'error_unknown',
    'archived'
);


--
-- Name: account_user_auth_mode; Type: TYPE; Schema: gestor_tickets; Owner: -
--

CREATE TYPE gestor_tickets.account_user_auth_mode AS ENUM (
    'glpi_account_manager',
    'local_collaborator'
);


--
-- Name: account_user_status; Type: TYPE; Schema: gestor_tickets; Owner: -
--

CREATE TYPE gestor_tickets.account_user_status AS ENUM (
    'active',
    'disabled',
    'locked',
    'pending_password_reset'
);


--
-- Name: ai_processing_status; Type: TYPE; Schema: gestor_tickets; Owner: -
--

CREATE TYPE gestor_tickets.ai_processing_status AS ENUM (
    'pending',
    'processing',
    'processed',
    'skipped',
    'error'
);


--
-- Name: ai_scope; Type: TYPE; Schema: gestor_tickets; Owner: -
--

CREATE TYPE gestor_tickets.ai_scope AS ENUM (
    'email',
    'thread',
    'ticket_context'
);


--
-- Name: glpi_link_origin; Type: TYPE; Schema: gestor_tickets; Owner: -
--

CREATE TYPE gestor_tickets.glpi_link_origin AS ENUM (
    'manual',
    'ai_suggested',
    'created_from_email',
    'created_from_thread',
    'personal_transfer',
    'auto_sync'
);


--
-- Name: glpi_link_status; Type: TYPE; Schema: gestor_tickets; Owner: -
--

CREATE TYPE gestor_tickets.glpi_link_status AS ENUM (
    'active',
    'detached'
);


--
-- Name: ingestion_job_status; Type: TYPE; Schema: gestor_tickets; Owner: -
--

CREATE TYPE gestor_tickets.ingestion_job_status AS ENUM (
    'active',
    'disabled',
    'error_auth',
    'error_connection',
    'error_unknown'
);


--
-- Name: ingestion_run_status; Type: TYPE; Schema: gestor_tickets; Owner: -
--

CREATE TYPE gestor_tickets.ingestion_run_status AS ENUM (
    'running',
    'success',
    'partial_error',
    'failed'
);


--
-- Name: mail_direction; Type: TYPE; Schema: gestor_tickets; Owner: -
--

CREATE TYPE gestor_tickets.mail_direction AS ENUM (
    'inbound',
    'outbound',
    'unknown'
);


--
-- Name: mail_folder_kind; Type: TYPE; Schema: gestor_tickets; Owner: -
--

CREATE TYPE gestor_tickets.mail_folder_kind AS ENUM (
    'inbox',
    'sent',
    'other'
);


--
-- Name: mail_source; Type: TYPE; Schema: gestor_tickets; Owner: -
--

CREATE TYPE gestor_tickets.mail_source AS ENUM (
    'collaborative_ingestion',
    'manual_import',
    'personal_transfer',
    'glpi_import',
    'other'
);


--
-- Name: system_thread_status; Type: TYPE; Schema: gestor_tickets; Owner: -
--

CREATE TYPE gestor_tickets.system_thread_status AS ENUM (
    'active',
    'merged',
    'archived',
    'deleted'
);


--
-- Name: thread_member_status; Type: TYPE; Schema: gestor_tickets; Owner: -
--

CREATE TYPE gestor_tickets.thread_member_status AS ENUM (
    'active',
    'moved',
    'removed'
);


SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- Name: account_users; Type: TABLE; Schema: gestor_tickets; Owner: -
--

CREATE TABLE gestor_tickets.account_users (
    id bigint NOT NULL,
    public_uid uuid DEFAULT gen_random_uuid() NOT NULL,
    account_id bigint NOT NULL,
    auth_mode gestor_tickets.account_user_auth_mode NOT NULL,
    login_identifier public.citext NOT NULL,
    username_local public.citext,
    password_hash text,
    display_name text NOT NULL,
    contact_email public.citext,
    role gestor_tickets.account_role DEFAULT 'collaborator'::gestor_tickets.account_role NOT NULL,
    status gestor_tickets.account_user_status DEFAULT 'active'::gestor_tickets.account_user_status NOT NULL,
    can_manage_users boolean DEFAULT false NOT NULL,
    can_manage_account_config boolean DEFAULT false NOT NULL,
    can_read_account_mail boolean DEFAULT true NOT NULL,
    can_reply_from_account boolean DEFAULT false NOT NULL,
    can_create_glpi_ticket boolean DEFAULT false NOT NULL,
    can_update_glpi_ticket boolean DEFAULT false NOT NULL,
    can_link_tickets boolean DEFAULT false NOT NULL,
    can_manage_ai boolean DEFAULT false NOT NULL,
    failed_login_count integer DEFAULT 0 NOT NULL,
    locked_until timestamp with time zone,
    last_login_at timestamp with time zone,
    created_by_user_id bigint,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    CONSTRAINT account_user_auth_shape CHECK ((((auth_mode = 'glpi_account_manager'::gestor_tickets.account_user_auth_mode) AND (username_local IS NULL) AND (password_hash IS NULL) AND (role = ANY (ARRAY['owner'::gestor_tickets.account_role, 'admin'::gestor_tickets.account_role]))) OR ((auth_mode = 'local_collaborator'::gestor_tickets.account_user_auth_mode) AND (username_local IS NOT NULL) AND (password_hash IS NOT NULL)))),
    CONSTRAINT account_users_failed_login_count_check CHECK ((failed_login_count >= 0))
);


--
-- Name: TABLE account_users; Type: COMMENT; Schema: gestor_tickets; Owner: -
--

COMMENT ON TABLE gestor_tickets.account_users IS 'Usuarios gestores o colaboradores. Los gestores se autentican contra GLPI; los colaboradores contra password_hash local.';


--
-- Name: account_users_id_seq; Type: SEQUENCE; Schema: gestor_tickets; Owner: -
--

CREATE SEQUENCE gestor_tickets.account_users_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: account_users_id_seq; Type: SEQUENCE OWNED BY; Schema: gestor_tickets; Owner: -
--

ALTER SEQUENCE gestor_tickets.account_users_id_seq OWNED BY gestor_tickets.account_users.id;


--
-- Name: ai_call_history; Type: TABLE; Schema: gestor_tickets; Owner: -
--

CREATE TABLE gestor_tickets.ai_call_history (
    id bigint NOT NULL,
    account_id bigint,
    created_by_user_id bigint,
    scope gestor_tickets.ai_scope NOT NULL,
    call_source text,
    call_purpose text,
    prompt_version_id bigint,
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
    related_email_message_id bigint,
    related_thread_id bigint,
    related_glpi_ticket_cache_id bigint,
    created_at timestamp with time zone DEFAULT now() NOT NULL
);


--
-- Name: ai_call_history_id_seq; Type: SEQUENCE; Schema: gestor_tickets; Owner: -
--

CREATE SEQUENCE gestor_tickets.ai_call_history_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: ai_call_history_id_seq; Type: SEQUENCE OWNED BY; Schema: gestor_tickets; Owner: -
--

ALTER SEQUENCE gestor_tickets.ai_call_history_id_seq OWNED BY gestor_tickets.ai_call_history.id;


--
-- Name: ai_endpoint_validation_logs; Type: TABLE; Schema: gestor_tickets; Owner: -
--

CREATE TABLE gestor_tickets.ai_endpoint_validation_logs (
    id bigint NOT NULL,
    endpoint_id bigint NOT NULL,
    model_id text,
    operation_type text NOT NULL,
    http_status integer,
    success boolean DEFAULT false NOT NULL,
    latency_ms integer,
    error_type text,
    error_message text,
    request_json_redacted jsonb DEFAULT '{}'::jsonb NOT NULL,
    response_json jsonb,
    response_text_preview text,
    strict_json_ok boolean,
    thinking_detected boolean DEFAULT false NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL
);


--
-- Name: ai_endpoint_validation_logs_id_seq; Type: SEQUENCE; Schema: gestor_tickets; Owner: -
--

CREATE SEQUENCE gestor_tickets.ai_endpoint_validation_logs_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: ai_endpoint_validation_logs_id_seq; Type: SEQUENCE OWNED BY; Schema: gestor_tickets; Owner: -
--

ALTER SEQUENCE gestor_tickets.ai_endpoint_validation_logs_id_seq OWNED BY gestor_tickets.ai_endpoint_validation_logs.id;


--
-- Name: ai_llm_endpoint_models; Type: TABLE; Schema: gestor_tickets; Owner: -
--

CREATE TABLE gestor_tickets.ai_llm_endpoint_models (
    id bigint NOT NULL,
    endpoint_id bigint NOT NULL,
    model_id text NOT NULL,
    display_name text,
    owned_by text,
    context_length integer,
    model_type text,
    pricing_json jsonb DEFAULT '{}'::jsonb NOT NULL,
    raw_json jsonb DEFAULT '{}'::jsonb NOT NULL,
    is_chat_capable boolean DEFAULT true NOT NULL,
    is_free_hint boolean DEFAULT false NOT NULL,
    last_seen_at timestamp with time zone DEFAULT now() NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL
);


--
-- Name: ai_llm_endpoint_models_id_seq; Type: SEQUENCE; Schema: gestor_tickets; Owner: -
--

CREATE SEQUENCE gestor_tickets.ai_llm_endpoint_models_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: ai_llm_endpoint_models_id_seq; Type: SEQUENCE OWNED BY; Schema: gestor_tickets; Owner: -
--

ALTER SEQUENCE gestor_tickets.ai_llm_endpoint_models_id_seq OWNED BY gestor_tickets.ai_llm_endpoint_models.id;


--
-- Name: ai_llm_endpoints; Type: TABLE; Schema: gestor_tickets; Owner: -
--

CREATE TABLE gestor_tickets.ai_llm_endpoints (
    id bigint NOT NULL,
    public_uid uuid DEFAULT gen_random_uuid() NOT NULL,
    name text NOT NULL,
    provider_kind text DEFAULT 'generic'::text NOT NULL,
    base_url text NOT NULL,
    models_endpoint_path text DEFAULT '/models'::text NOT NULL,
    chat_endpoint_path text DEFAULT '/chat/completions'::text NOT NULL,
    api_key_ciphertext text,
    default_model text,
    is_active boolean DEFAULT true NOT NULL,
    is_default boolean DEFAULT false NOT NULL,
    timeout_seconds integer DEFAULT 60 NOT NULL,
    temperature numeric(4,3) DEFAULT 0.2 NOT NULL,
    top_p numeric(4,3) DEFAULT 1.0 NOT NULL,
    max_tokens integer DEFAULT 1024 NOT NULL,
    enable_thinking boolean DEFAULT false NOT NULL,
    daily_limit integer,
    free_quota_notes text,
    retry_policy_json jsonb DEFAULT '{"retry_on": ["timeout", "connection_error", "rate_limited"], "max_retries": 1, "do_not_retry_on": ["auth_error", "quota_exceeded", "model_not_found", "invalid_request"]}'::jsonb NOT NULL,
    extra_headers_json jsonb DEFAULT '{}'::jsonb NOT NULL,
    last_models_sync_at timestamp with time zone,
    last_validation_at timestamp with time zone,
    last_validation_status text,
    last_validation_error_type text,
    last_validation_error_message text,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    reasoning_effort text DEFAULT 'none'::text NOT NULL,
    CONSTRAINT ai_llm_endpoints_reasoning_effort_check CHECK ((reasoning_effort = ANY (ARRAY['none'::text, 'low'::text, 'medium'::text, 'high'::text]))),
    CONSTRAINT ck_ai_llm_endpoints_max_tokens CHECK (((max_tokens >= 1) AND (max_tokens <= 200000))),
    CONSTRAINT ck_ai_llm_endpoints_temperature CHECK (((temperature >= (0)::numeric) AND (temperature <= (2)::numeric))),
    CONSTRAINT ck_ai_llm_endpoints_timeout CHECK (((timeout_seconds >= 1) AND (timeout_seconds <= 600))),
    CONSTRAINT ck_ai_llm_endpoints_top_p CHECK (((top_p >= (0)::numeric) AND (top_p <= (1)::numeric)))
);


--
-- Name: ai_llm_endpoints_id_seq; Type: SEQUENCE; Schema: gestor_tickets; Owner: -
--

CREATE SEQUENCE gestor_tickets.ai_llm_endpoints_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: ai_llm_endpoints_id_seq; Type: SEQUENCE OWNED BY; Schema: gestor_tickets; Owner: -
--

ALTER SEQUENCE gestor_tickets.ai_llm_endpoints_id_seq OWNED BY gestor_tickets.ai_llm_endpoints.id;


--
-- Name: ai_prompt_templates; Type: TABLE; Schema: gestor_tickets; Owner: -
--

CREATE TABLE gestor_tickets.ai_prompt_templates (
    id bigint NOT NULL,
    key text NOT NULL,
    name text NOT NULL,
    description text,
    category text,
    variables_schema_json jsonb DEFAULT '{}'::jsonb NOT NULL,
    active boolean DEFAULT true NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL
);


--
-- Name: ai_prompt_templates_id_seq; Type: SEQUENCE; Schema: gestor_tickets; Owner: -
--

CREATE SEQUENCE gestor_tickets.ai_prompt_templates_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: ai_prompt_templates_id_seq; Type: SEQUENCE OWNED BY; Schema: gestor_tickets; Owner: -
--

ALTER SEQUENCE gestor_tickets.ai_prompt_templates_id_seq OWNED BY gestor_tickets.ai_prompt_templates.id;


--
-- Name: ai_prompt_versions; Type: TABLE; Schema: gestor_tickets; Owner: -
--

CREATE TABLE gestor_tickets.ai_prompt_versions (
    id bigint NOT NULL,
    template_id bigint NOT NULL,
    version_number integer NOT NULL,
    system_prompt_template text NOT NULL,
    user_prompt_template text NOT NULL,
    response_schema_json jsonb DEFAULT '{}'::jsonb NOT NULL,
    example_input_json jsonb DEFAULT '{}'::jsonb NOT NULL,
    expected_output_example_json jsonb DEFAULT '{}'::jsonb NOT NULL,
    default_llm_params_json jsonb DEFAULT '{}'::jsonb NOT NULL,
    enable_thinking boolean DEFAULT false NOT NULL,
    timeout_seconds integer DEFAULT 300 NOT NULL,
    is_active boolean DEFAULT false NOT NULL,
    created_by_user_id bigint,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    notes text,
    CONSTRAINT ai_prompt_versions_timeout_seconds_check CHECK (((timeout_seconds >= 1) AND (timeout_seconds <= 3600))),
    CONSTRAINT ai_prompt_versions_version_number_check CHECK ((version_number > 0))
);


--
-- Name: ai_prompt_versions_id_seq; Type: SEQUENCE; Schema: gestor_tickets; Owner: -
--

CREATE SEQUENCE gestor_tickets.ai_prompt_versions_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: ai_prompt_versions_id_seq; Type: SEQUENCE OWNED BY; Schema: gestor_tickets; Owner: -
--

ALTER SEQUENCE gestor_tickets.ai_prompt_versions_id_seq OWNED BY gestor_tickets.ai_prompt_versions.id;


--
-- Name: app_settings; Type: TABLE; Schema: gestor_tickets; Owner: -
--

CREATE TABLE gestor_tickets.app_settings (
    id smallint DEFAULT 1 NOT NULL,
    app_name text DEFAULT 'gestor-tickets'::text NOT NULL,
    app_description text,
    default_timezone text DEFAULT 'Atlantic/Canary'::text NOT NULL,
    default_archive_root text DEFAULT '/data/mail_archive'::text NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    CONSTRAINT app_settings_id_check CHECK ((id = 1))
);


--
-- Name: audit_log; Type: TABLE; Schema: gestor_tickets; Owner: -
--

CREATE TABLE gestor_tickets.audit_log (
    id bigint NOT NULL,
    account_id bigint,
    actor_user_id bigint,
    actor_login_identifier public.citext,
    action text NOT NULL,
    entity_type text NOT NULL,
    entity_id text,
    before_json jsonb,
    after_json jsonb,
    ip_address inet,
    user_agent text,
    created_at timestamp with time zone DEFAULT now() NOT NULL
);


--
-- Name: audit_log_id_seq; Type: SEQUENCE; Schema: gestor_tickets; Owner: -
--

CREATE SEQUENCE gestor_tickets.audit_log_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: audit_log_id_seq; Type: SEQUENCE OWNED BY; Schema: gestor_tickets; Owner: -
--

ALTER SEQUENCE gestor_tickets.audit_log_id_seq OWNED BY gestor_tickets.audit_log.id;


--
-- Name: collaborative_accounts; Type: TABLE; Schema: gestor_tickets; Owner: -
--

CREATE TABLE gestor_tickets.collaborative_accounts (
    id bigint NOT NULL,
    public_uid uuid DEFAULT gen_random_uuid() NOT NULL,
    email public.citext NOT NULL,
    display_name text,
    status gestor_tickets.account_status DEFAULT 'pending_configuration'::gestor_tickets.account_status NOT NULL,
    glpi_instance_id bigint,
    glpi_user_id bigint,
    glpi_login public.citext NOT NULL,
    glpi_profile_name text DEFAULT 'Supervisor'::text NOT NULL,
    glpi_entity_id bigint,
    glpi_group_id bigint,
    last_glpi_validation_at timestamp with time zone,
    imap_host text,
    imap_username public.citext,
    imap_password_ciphertext text,
    imap_port integer DEFAULT 993 NOT NULL,
    imap_use_ssl boolean DEFAULT true NOT NULL,
    imap_last_validated_at timestamp with time zone,
    archive_root text DEFAULT '/data/mail_archive'::text NOT NULL,
    archive_subdir text NOT NULL,
    ingestion_enabled boolean DEFAULT false NOT NULL,
    created_by_login public.citext,
    notes text,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    CONSTRAINT collaborative_account_imap_config_complete_or_empty CHECK ((((imap_host IS NULL) AND (imap_username IS NULL) AND (imap_password_ciphertext IS NULL)) OR ((imap_host IS NOT NULL) AND (imap_username IS NOT NULL) AND (imap_password_ciphertext IS NOT NULL)))),
    CONSTRAINT collaborative_accounts_imap_port_check CHECK ((imap_port = 993)),
    CONSTRAINT collaborative_accounts_imap_use_ssl_check CHECK ((imap_use_ssl = true))
);


--
-- Name: TABLE collaborative_accounts; Type: COMMENT; Schema: gestor_tickets; Owner: -
--

COMMENT ON TABLE gestor_tickets.collaborative_accounts IS 'Cuenta colaborativa principal. Login principal validado contra GLPI, contraseña GLPI no almacenada.';


--
-- Name: collaborative_accounts_id_seq; Type: SEQUENCE; Schema: gestor_tickets; Owner: -
--

CREATE SEQUENCE gestor_tickets.collaborative_accounts_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: collaborative_accounts_id_seq; Type: SEQUENCE OWNED BY; Schema: gestor_tickets; Owner: -
--

ALTER SEQUENCE gestor_tickets.collaborative_accounts_id_seq OWNED BY gestor_tickets.collaborative_accounts.id;


--
-- Name: email_ai_processing; Type: TABLE; Schema: gestor_tickets; Owner: -
--

CREATE TABLE gestor_tickets.email_ai_processing (
    id bigint NOT NULL,
    email_message_id bigint NOT NULL,
    prompt_version_id bigint,
    llm_call_history_id bigint,
    status gestor_tickets.ai_processing_status DEFAULT 'pending'::gestor_tickets.ai_processing_status NOT NULL,
    body_new text,
    body_new_found boolean,
    body_new_is_too_short boolean,
    needs_thread_context boolean,
    extraction_confidence double precision,
    summary_json jsonb,
    tipo_correo text,
    accion_sugerida text,
    prioridad_sugerida text,
    requiere_revision_humana boolean,
    processed_at timestamp with time zone,
    error_message text,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    CONSTRAINT email_ai_processing_extraction_confidence_check CHECK (((extraction_confidence IS NULL) OR ((extraction_confidence >= (0)::double precision) AND (extraction_confidence <= (1)::double precision))))
);


--
-- Name: email_ai_processing_id_seq; Type: SEQUENCE; Schema: gestor_tickets; Owner: -
--

CREATE SEQUENCE gestor_tickets.email_ai_processing_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: email_ai_processing_id_seq; Type: SEQUENCE OWNED BY; Schema: gestor_tickets; Owner: -
--

ALTER SEQUENCE gestor_tickets.email_ai_processing_id_seq OWNED BY gestor_tickets.email_ai_processing.id;


--
-- Name: email_attachments; Type: TABLE; Schema: gestor_tickets; Owner: -
--

CREATE TABLE gestor_tickets.email_attachments (
    id bigint NOT NULL,
    email_message_id bigint NOT NULL,
    filename text,
    content_type text,
    size_bytes bigint,
    content_id text,
    is_inline boolean DEFAULT false NOT NULL,
    storage_path text,
    sha256 character(64),
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    CONSTRAINT email_attachments_size_bytes_check CHECK (((size_bytes IS NULL) OR (size_bytes >= 0)))
);


--
-- Name: email_attachments_id_seq; Type: SEQUENCE; Schema: gestor_tickets; Owner: -
--

CREATE SEQUENCE gestor_tickets.email_attachments_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: email_attachments_id_seq; Type: SEQUENCE OWNED BY; Schema: gestor_tickets; Owner: -
--

ALTER SEQUENCE gestor_tickets.email_attachments_id_seq OWNED BY gestor_tickets.email_attachments.id;


--
-- Name: email_message_occurrences; Type: TABLE; Schema: gestor_tickets; Owner: -
--

CREATE TABLE gestor_tickets.email_message_occurrences (
    id bigint NOT NULL,
    email_message_id bigint NOT NULL,
    account_id bigint NOT NULL,
    ingestion_run_id bigint,
    source_mailbox_email public.citext NOT NULL,
    folder_name text NOT NULL,
    folder_kind gestor_tickets.mail_folder_kind DEFAULT 'other'::gestor_tickets.mail_folder_kind NOT NULL,
    imap_uid text NOT NULL,
    imap_uidvalidity text,
    direction gestor_tickets.mail_direction DEFAULT 'unknown'::gestor_tickets.mail_direction NOT NULL,
    flags_json jsonb DEFAULT '[]'::jsonb NOT NULL,
    unread_at_import boolean,
    first_seen_at timestamp with time zone DEFAULT now() NOT NULL,
    last_seen_at timestamp with time zone DEFAULT now() NOT NULL
);


--
-- Name: email_message_occurrences_id_seq; Type: SEQUENCE; Schema: gestor_tickets; Owner: -
--

CREATE SEQUENCE gestor_tickets.email_message_occurrences_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: email_message_occurrences_id_seq; Type: SEQUENCE OWNED BY; Schema: gestor_tickets; Owner: -
--

ALTER SEQUENCE gestor_tickets.email_message_occurrences_id_seq OWNED BY gestor_tickets.email_message_occurrences.id;


--
-- Name: email_messages; Type: TABLE; Schema: gestor_tickets; Owner: -
--

CREATE TABLE gestor_tickets.email_messages (
    id bigint NOT NULL,
    system_uid uuid DEFAULT gen_random_uuid() NOT NULL,
    account_id bigint NOT NULL,
    message_id_header text,
    eml_sha256 character(64) NOT NULL,
    raw_headers_sha256 character(64),
    eml_storage_path text NOT NULL,
    eml_filename text NOT NULL,
    size_bytes bigint,
    source gestor_tickets.mail_source DEFAULT 'collaborative_ingestion'::gestor_tickets.mail_source NOT NULL,
    imported_from_personal_account_id bigint,
    transferred_by_user_id bigint,
    transferred_at timestamp with time zone,
    original_imap_account public.citext,
    original_imap_folder text,
    original_imap_uid text,
    original_imap_uidvalidity text,
    source_description text,
    subject text,
    subject_normalized text,
    from_email public.citext,
    from_name text,
    sent_at timestamp with time zone,
    received_at timestamp with time zone,
    direction gestor_tickets.mail_direction DEFAULT 'unknown'::gestor_tickets.mail_direction NOT NULL,
    has_attachments boolean DEFAULT false NOT NULL,
    body_text_preview text,
    archived_at timestamp with time zone DEFAULT now() NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    CONSTRAINT email_message_transfer_requires_source CHECK (((source <> 'personal_transfer'::gestor_tickets.mail_source) OR ((imported_from_personal_account_id IS NOT NULL) AND (transferred_by_user_id IS NOT NULL) AND (transferred_at IS NOT NULL)))),
    CONSTRAINT email_messages_size_bytes_check CHECK (((size_bytes IS NULL) OR (size_bytes >= 0)))
);


--
-- Name: TABLE email_messages; Type: COMMENT; Schema: gestor_tickets; Owner: -
--

COMMENT ON TABLE gestor_tickets.email_messages IS 'Correos archivados como .eml bajo una cuenta colaborativa principal, con system_uid propio del sistema.';


--
-- Name: email_messages_id_seq; Type: SEQUENCE; Schema: gestor_tickets; Owner: -
--

CREATE SEQUENCE gestor_tickets.email_messages_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: email_messages_id_seq; Type: SEQUENCE OWNED BY; Schema: gestor_tickets; Owner: -
--

ALTER SEQUENCE gestor_tickets.email_messages_id_seq OWNED BY gestor_tickets.email_messages.id;


--
-- Name: email_recipients; Type: TABLE; Schema: gestor_tickets; Owner: -
--

CREATE TABLE gestor_tickets.email_recipients (
    id bigint NOT NULL,
    email_message_id bigint NOT NULL,
    recipient_type text NOT NULL,
    email public.citext NOT NULL,
    display_name text,
    "position" integer DEFAULT 0 NOT NULL,
    CONSTRAINT email_recipients_position_check CHECK (("position" >= 0)),
    CONSTRAINT email_recipients_recipient_type_check CHECK ((recipient_type = ANY (ARRAY['to'::text, 'cc'::text, 'bcc'::text, 'reply_to'::text])))
);


--
-- Name: email_recipients_id_seq; Type: SEQUENCE; Schema: gestor_tickets; Owner: -
--

CREATE SEQUENCE gestor_tickets.email_recipients_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: email_recipients_id_seq; Type: SEQUENCE OWNED BY; Schema: gestor_tickets; Owner: -
--

ALTER SEQUENCE gestor_tickets.email_recipients_id_seq OWNED BY gestor_tickets.email_recipients.id;


--
-- Name: email_thread_members; Type: TABLE; Schema: gestor_tickets; Owner: -
--

CREATE TABLE gestor_tickets.email_thread_members (
    id bigint NOT NULL,
    thread_id bigint NOT NULL,
    email_message_id bigint NOT NULL,
    position_asc integer DEFAULT 0 NOT NULL,
    status gestor_tickets.thread_member_status DEFAULT 'active'::gestor_tickets.thread_member_status NOT NULL,
    added_by_user_id bigint,
    added_reason text,
    added_at timestamp with time zone DEFAULT now() NOT NULL,
    removed_by_user_id bigint,
    removed_reason text,
    removed_at timestamp with time zone,
    moved_from_thread_id bigint,
    moved_to_thread_id bigint,
    CONSTRAINT thread_member_removed_shape CHECK ((((status = 'active'::gestor_tickets.thread_member_status) AND (removed_at IS NULL)) OR ((status = ANY (ARRAY['moved'::gestor_tickets.thread_member_status, 'removed'::gestor_tickets.thread_member_status])) AND (removed_at IS NOT NULL))))
);


--
-- Name: email_thread_members_id_seq; Type: SEQUENCE; Schema: gestor_tickets; Owner: -
--

CREATE SEQUENCE gestor_tickets.email_thread_members_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: email_thread_members_id_seq; Type: SEQUENCE OWNED BY; Schema: gestor_tickets; Owner: -
--

ALTER SEQUENCE gestor_tickets.email_thread_members_id_seq OWNED BY gestor_tickets.email_thread_members.id;


--
-- Name: glpi_api_operations; Type: TABLE; Schema: gestor_tickets; Owner: -
--

CREATE TABLE gestor_tickets.glpi_api_operations (
    id bigint NOT NULL,
    account_id bigint NOT NULL,
    glpi_instance_id bigint,
    glpi_ticket_cache_id bigint,
    operation_type text NOT NULL,
    requested_by_user_id bigint,
    request_payload_json jsonb,
    response_status_code integer,
    response_json jsonb,
    success boolean DEFAULT false NOT NULL,
    error_message text,
    created_at timestamp with time zone DEFAULT now() NOT NULL
);


--
-- Name: glpi_api_operations_id_seq; Type: SEQUENCE; Schema: gestor_tickets; Owner: -
--

CREATE SEQUENCE gestor_tickets.glpi_api_operations_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: glpi_api_operations_id_seq; Type: SEQUENCE OWNED BY; Schema: gestor_tickets; Owner: -
--

ALTER SEQUENCE gestor_tickets.glpi_api_operations_id_seq OWNED BY gestor_tickets.glpi_api_operations.id;


--
-- Name: glpi_instances; Type: TABLE; Schema: gestor_tickets; Owner: -
--

CREATE TABLE gestor_tickets.glpi_instances (
    id bigint NOT NULL,
    name text NOT NULL,
    base_url text NOT NULL,
    app_token_ciphertext text,
    default_entity_id bigint,
    default_group_id bigint,
    verify_tls boolean DEFAULT true NOT NULL,
    active boolean DEFAULT true NOT NULL,
    notes text,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL
);


--
-- Name: glpi_instances_id_seq; Type: SEQUENCE; Schema: gestor_tickets; Owner: -
--

CREATE SEQUENCE gestor_tickets.glpi_instances_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: glpi_instances_id_seq; Type: SEQUENCE OWNED BY; Schema: gestor_tickets; Owner: -
--

ALTER SEQUENCE gestor_tickets.glpi_instances_id_seq OWNED BY gestor_tickets.glpi_instances.id;


--
-- Name: glpi_ticket_cache; Type: TABLE; Schema: gestor_tickets; Owner: -
--

CREATE TABLE gestor_tickets.glpi_ticket_cache (
    id bigint NOT NULL,
    account_id bigint NOT NULL,
    glpi_instance_id bigint,
    glpi_ticket_id bigint NOT NULL,
    title text,
    status text,
    priority text,
    urgency text,
    impact text,
    entity_id bigint,
    group_id bigint,
    requester_json jsonb DEFAULT '[]'::jsonb NOT NULL,
    assignee_json jsonb DEFAULT '[]'::jsonb NOT NULL,
    raw_json jsonb DEFAULT '{}'::jsonb NOT NULL,
    last_sync_at timestamp with time zone,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL
);


--
-- Name: glpi_ticket_cache_id_seq; Type: SEQUENCE; Schema: gestor_tickets; Owner: -
--

CREATE SEQUENCE gestor_tickets.glpi_ticket_cache_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: glpi_ticket_cache_id_seq; Type: SEQUENCE OWNED BY; Schema: gestor_tickets; Owner: -
--

ALTER SEQUENCE gestor_tickets.glpi_ticket_cache_id_seq OWNED BY gestor_tickets.glpi_ticket_cache.id;


--
-- Name: glpi_ticket_email_links; Type: TABLE; Schema: gestor_tickets; Owner: -
--

CREATE TABLE gestor_tickets.glpi_ticket_email_links (
    id bigint NOT NULL,
    account_id bigint NOT NULL,
    glpi_ticket_cache_id bigint NOT NULL,
    email_message_id bigint NOT NULL,
    origin gestor_tickets.glpi_link_origin DEFAULT 'manual'::gestor_tickets.glpi_link_origin NOT NULL,
    status gestor_tickets.glpi_link_status DEFAULT 'active'::gestor_tickets.glpi_link_status NOT NULL,
    created_by_user_id bigint,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    detached_by_user_id bigint,
    detached_at timestamp with time zone,
    notes text,
    CONSTRAINT ticket_email_link_detach_shape CHECK ((((status = 'active'::gestor_tickets.glpi_link_status) AND (detached_at IS NULL)) OR ((status = 'detached'::gestor_tickets.glpi_link_status) AND (detached_at IS NOT NULL))))
);


--
-- Name: TABLE glpi_ticket_email_links; Type: COMMENT; Schema: gestor_tickets; Owner: -
--

COMMENT ON TABLE gestor_tickets.glpi_ticket_email_links IS 'Relación muchos-a-muchos entre tickets GLPI y emails.';


--
-- Name: glpi_ticket_email_links_id_seq; Type: SEQUENCE; Schema: gestor_tickets; Owner: -
--

CREATE SEQUENCE gestor_tickets.glpi_ticket_email_links_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: glpi_ticket_email_links_id_seq; Type: SEQUENCE OWNED BY; Schema: gestor_tickets; Owner: -
--

ALTER SEQUENCE gestor_tickets.glpi_ticket_email_links_id_seq OWNED BY gestor_tickets.glpi_ticket_email_links.id;


--
-- Name: glpi_ticket_relationships; Type: TABLE; Schema: gestor_tickets; Owner: -
--

CREATE TABLE gestor_tickets.glpi_ticket_relationships (
    id bigint NOT NULL,
    account_id bigint NOT NULL,
    source_ticket_cache_id bigint NOT NULL,
    target_ticket_cache_id bigint NOT NULL,
    relationship_type text DEFAULT 'related'::text NOT NULL,
    created_by_user_id bigint,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    notes text,
    CONSTRAINT glpi_ticket_relationship_not_self CHECK ((source_ticket_cache_id <> target_ticket_cache_id))
);


--
-- Name: glpi_ticket_relationships_id_seq; Type: SEQUENCE; Schema: gestor_tickets; Owner: -
--

CREATE SEQUENCE gestor_tickets.glpi_ticket_relationships_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: glpi_ticket_relationships_id_seq; Type: SEQUENCE OWNED BY; Schema: gestor_tickets; Owner: -
--

ALTER SEQUENCE gestor_tickets.glpi_ticket_relationships_id_seq OWNED BY gestor_tickets.glpi_ticket_relationships.id;


--
-- Name: glpi_ticket_thread_links; Type: TABLE; Schema: gestor_tickets; Owner: -
--

CREATE TABLE gestor_tickets.glpi_ticket_thread_links (
    id bigint NOT NULL,
    account_id bigint NOT NULL,
    glpi_ticket_cache_id bigint NOT NULL,
    thread_id bigint NOT NULL,
    origin gestor_tickets.glpi_link_origin DEFAULT 'manual'::gestor_tickets.glpi_link_origin NOT NULL,
    status gestor_tickets.glpi_link_status DEFAULT 'active'::gestor_tickets.glpi_link_status NOT NULL,
    created_by_user_id bigint,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    detached_by_user_id bigint,
    detached_at timestamp with time zone,
    notes text,
    CONSTRAINT ticket_thread_link_detach_shape CHECK ((((status = 'active'::gestor_tickets.glpi_link_status) AND (detached_at IS NULL)) OR ((status = 'detached'::gestor_tickets.glpi_link_status) AND (detached_at IS NOT NULL))))
);


--
-- Name: TABLE glpi_ticket_thread_links; Type: COMMENT; Schema: gestor_tickets; Owner: -
--

COMMENT ON TABLE gestor_tickets.glpi_ticket_thread_links IS 'Relación muchos-a-muchos entre tickets GLPI y hilos del sistema.';


--
-- Name: glpi_ticket_thread_links_id_seq; Type: SEQUENCE; Schema: gestor_tickets; Owner: -
--

CREATE SEQUENCE gestor_tickets.glpi_ticket_thread_links_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: glpi_ticket_thread_links_id_seq; Type: SEQUENCE OWNED BY; Schema: gestor_tickets; Owner: -
--

ALTER SEQUENCE gestor_tickets.glpi_ticket_thread_links_id_seq OWNED BY gestor_tickets.glpi_ticket_thread_links.id;


--
-- Name: mail_ingestion_jobs; Type: TABLE; Schema: gestor_tickets; Owner: -
--

CREATE TABLE gestor_tickets.mail_ingestion_jobs (
    id bigint NOT NULL,
    account_id bigint NOT NULL,
    status gestor_tickets.ingestion_job_status DEFAULT 'disabled'::gestor_tickets.ingestion_job_status NOT NULL,
    scan_inbox boolean DEFAULT true NOT NULL,
    scan_sent boolean DEFAULT true NOT NULL,
    inbox_folder_name text DEFAULT 'INBOX'::text NOT NULL,
    sent_folder_name text DEFAULT 'Sent'::text NOT NULL,
    interval_minutes integer DEFAULT 5 NOT NULL,
    max_messages_per_folder integer DEFAULT 200 NOT NULL,
    last_started_at timestamp with time zone,
    last_success_at timestamp with time zone,
    last_error_at timestamp with time zone,
    next_run_at timestamp with time zone,
    auth_failure_count integer DEFAULT 0 NOT NULL,
    last_error_message text,
    created_by_user_id bigint,
    updated_by_user_id bigint,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    CONSTRAINT mail_ingestion_jobs_auth_failure_count_check CHECK ((auth_failure_count >= 0)),
    CONSTRAINT mail_ingestion_jobs_interval_minutes_check CHECK (((interval_minutes >= 1) AND (interval_minutes <= 1440))),
    CONSTRAINT mail_ingestion_jobs_max_messages_per_folder_check CHECK ((max_messages_per_folder > 0))
);


--
-- Name: mail_ingestion_jobs_id_seq; Type: SEQUENCE; Schema: gestor_tickets; Owner: -
--

CREATE SEQUENCE gestor_tickets.mail_ingestion_jobs_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: mail_ingestion_jobs_id_seq; Type: SEQUENCE OWNED BY; Schema: gestor_tickets; Owner: -
--

ALTER SEQUENCE gestor_tickets.mail_ingestion_jobs_id_seq OWNED BY gestor_tickets.mail_ingestion_jobs.id;


--
-- Name: mail_ingestion_runs; Type: TABLE; Schema: gestor_tickets; Owner: -
--

CREATE TABLE gestor_tickets.mail_ingestion_runs (
    id bigint NOT NULL,
    job_id bigint NOT NULL,
    account_id bigint NOT NULL,
    status gestor_tickets.ingestion_run_status DEFAULT 'running'::gestor_tickets.ingestion_run_status NOT NULL,
    started_at timestamp with time zone DEFAULT now() NOT NULL,
    finished_at timestamp with time zone,
    scanned_inbox_count integer DEFAULT 0 NOT NULL,
    scanned_sent_count integer DEFAULT 0 NOT NULL,
    imported_count integer DEFAULT 0 NOT NULL,
    duplicate_count integer DEFAULT 0 NOT NULL,
    error_count integer DEFAULT 0 NOT NULL,
    error_message text,
    details_json jsonb DEFAULT '{}'::jsonb NOT NULL,
    CONSTRAINT mail_ingestion_runs_duplicate_count_check CHECK ((duplicate_count >= 0)),
    CONSTRAINT mail_ingestion_runs_error_count_check CHECK ((error_count >= 0)),
    CONSTRAINT mail_ingestion_runs_imported_count_check CHECK ((imported_count >= 0)),
    CONSTRAINT mail_ingestion_runs_scanned_inbox_count_check CHECK ((scanned_inbox_count >= 0)),
    CONSTRAINT mail_ingestion_runs_scanned_sent_count_check CHECK ((scanned_sent_count >= 0))
);


--
-- Name: mail_ingestion_runs_id_seq; Type: SEQUENCE; Schema: gestor_tickets; Owner: -
--

CREATE SEQUENCE gestor_tickets.mail_ingestion_runs_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: mail_ingestion_runs_id_seq; Type: SEQUENCE OWNED BY; Schema: gestor_tickets; Owner: -
--

ALTER SEQUENCE gestor_tickets.mail_ingestion_runs_id_seq OWNED BY gestor_tickets.mail_ingestion_runs.id;


--
-- Name: personal_mail_accounts; Type: TABLE; Schema: gestor_tickets; Owner: -
--

CREATE TABLE gestor_tickets.personal_mail_accounts (
    id bigint NOT NULL,
    public_uid uuid DEFAULT gen_random_uuid() NOT NULL,
    account_id bigint NOT NULL,
    user_id bigint NOT NULL,
    email public.citext NOT NULL,
    display_name text,
    imap_host text NOT NULL,
    imap_username public.citext NOT NULL,
    imap_password_ciphertext text NOT NULL,
    imap_port integer DEFAULT 993 NOT NULL,
    imap_use_ssl boolean DEFAULT true NOT NULL,
    active boolean DEFAULT true NOT NULL,
    last_validated_at timestamp with time zone,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    CONSTRAINT personal_mail_accounts_imap_port_check CHECK ((imap_port = 993)),
    CONSTRAINT personal_mail_accounts_imap_use_ssl_check CHECK ((imap_use_ssl = true))
);


--
-- Name: TABLE personal_mail_accounts; Type: COMMENT; Schema: gestor_tickets; Owner: -
--

COMMENT ON TABLE gestor_tickets.personal_mail_accounts IS 'Cuentas personales opcionales de colaboradores. No se archivan ni se procesan por IA salvo transferencia explícita.';


--
-- Name: personal_mail_accounts_id_seq; Type: SEQUENCE; Schema: gestor_tickets; Owner: -
--

CREATE SEQUENCE gestor_tickets.personal_mail_accounts_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: personal_mail_accounts_id_seq; Type: SEQUENCE OWNED BY; Schema: gestor_tickets; Owner: -
--

ALTER SEQUENCE gestor_tickets.personal_mail_accounts_id_seq OWNED BY gestor_tickets.personal_mail_accounts.id;


--
-- Name: personal_message_transfer_log; Type: TABLE; Schema: gestor_tickets; Owner: -
--

CREATE TABLE gestor_tickets.personal_message_transfer_log (
    id bigint NOT NULL,
    personal_account_id bigint NOT NULL,
    target_account_id bigint NOT NULL,
    transferred_email_message_id bigint NOT NULL,
    transferred_by_user_id bigint NOT NULL,
    original_folder text NOT NULL,
    original_imap_uid text NOT NULL,
    original_imap_uidvalidity text,
    original_message_id_header text,
    transfer_reason text,
    transferred_at timestamp with time zone DEFAULT now() NOT NULL
);


--
-- Name: personal_message_transfer_log_id_seq; Type: SEQUENCE; Schema: gestor_tickets; Owner: -
--

CREATE SEQUENCE gestor_tickets.personal_message_transfer_log_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: personal_message_transfer_log_id_seq; Type: SEQUENCE OWNED BY; Schema: gestor_tickets; Owner: -
--

ALTER SEQUENCE gestor_tickets.personal_message_transfer_log_id_seq OWNED BY gestor_tickets.personal_message_transfer_log.id;


--
-- Name: system_threads; Type: TABLE; Schema: gestor_tickets; Owner: -
--

CREATE TABLE gestor_tickets.system_threads (
    id bigint NOT NULL,
    system_thread_uid uuid DEFAULT gen_random_uuid() NOT NULL,
    account_id bigint NOT NULL,
    title text,
    subject_normalized text,
    status gestor_tickets.system_thread_status DEFAULT 'active'::gestor_tickets.system_thread_status NOT NULL,
    detected_from_message_id bigint,
    created_reason text,
    created_by_user_id bigint,
    merged_into_thread_id bigint,
    merged_at timestamp with time zone,
    archived_at timestamp with time zone,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    CONSTRAINT system_thread_merge_shape CHECK ((((status <> 'merged'::gestor_tickets.system_thread_status) AND (merged_into_thread_id IS NULL)) OR ((status = 'merged'::gestor_tickets.system_thread_status) AND (merged_into_thread_id IS NOT NULL))))
);


--
-- Name: TABLE system_threads; Type: COMMENT; Schema: gestor_tickets; Owner: -
--

COMMENT ON TABLE gestor_tickets.system_threads IS 'Hilos operativos propios del sistema, editables, fusionables y separables.';


--
-- Name: system_threads_id_seq; Type: SEQUENCE; Schema: gestor_tickets; Owner: -
--

CREATE SEQUENCE gestor_tickets.system_threads_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: system_threads_id_seq; Type: SEQUENCE OWNED BY; Schema: gestor_tickets; Owner: -
--

ALTER SEQUENCE gestor_tickets.system_threads_id_seq OWNED BY gestor_tickets.system_threads.id;


--
-- Name: thread_ai_syntheses; Type: TABLE; Schema: gestor_tickets; Owner: -
--

CREATE TABLE gestor_tickets.thread_ai_syntheses (
    id bigint NOT NULL,
    thread_id bigint NOT NULL,
    latest_email_message_id bigint,
    prompt_version_id bigint,
    llm_call_history_id bigint,
    status gestor_tickets.ai_processing_status DEFAULT 'pending'::gestor_tickets.ai_processing_status NOT NULL,
    state_summary_json jsonb,
    short_dialogue_text text,
    synthesized_at timestamp with time zone,
    error_message text,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL
);


--
-- Name: thread_ai_syntheses_id_seq; Type: SEQUENCE; Schema: gestor_tickets; Owner: -
--

CREATE SEQUENCE gestor_tickets.thread_ai_syntheses_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: thread_ai_syntheses_id_seq; Type: SEQUENCE OWNED BY; Schema: gestor_tickets; Owner: -
--

ALTER SEQUENCE gestor_tickets.thread_ai_syntheses_id_seq OWNED BY gestor_tickets.thread_ai_syntheses.id;


--
-- Name: thread_merge_history; Type: TABLE; Schema: gestor_tickets; Owner: -
--

CREATE TABLE gestor_tickets.thread_merge_history (
    id bigint NOT NULL,
    account_id bigint NOT NULL,
    source_thread_id bigint NOT NULL,
    target_thread_id bigint NOT NULL,
    merged_by_user_id bigint,
    reason text,
    details_json jsonb DEFAULT '{}'::jsonb NOT NULL,
    merged_at timestamp with time zone DEFAULT now() NOT NULL,
    CONSTRAINT thread_merge_not_same CHECK ((source_thread_id <> target_thread_id))
);


--
-- Name: thread_merge_history_id_seq; Type: SEQUENCE; Schema: gestor_tickets; Owner: -
--

CREATE SEQUENCE gestor_tickets.thread_merge_history_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: thread_merge_history_id_seq; Type: SEQUENCE OWNED BY; Schema: gestor_tickets; Owner: -
--

ALTER SEQUENCE gestor_tickets.thread_merge_history_id_seq OWNED BY gestor_tickets.thread_merge_history.id;


--
-- Name: thread_operations; Type: TABLE; Schema: gestor_tickets; Owner: -
--

CREATE TABLE gestor_tickets.thread_operations (
    id bigint NOT NULL,
    account_id bigint NOT NULL,
    operation_type text NOT NULL,
    source_thread_id bigint,
    target_thread_id bigint,
    email_message_id bigint,
    performed_by_user_id bigint,
    reason text,
    details_json jsonb DEFAULT '{}'::jsonb NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    CONSTRAINT thread_operations_operation_type_check CHECK ((operation_type = ANY (ARRAY['create_thread'::text, 'rename_thread'::text, 'add_email'::text, 'remove_email'::text, 'move_email'::text, 'merge_threads'::text, 'split_thread'::text, 'archive_thread'::text, 'restore_thread'::text])))
);


--
-- Name: thread_operations_id_seq; Type: SEQUENCE; Schema: gestor_tickets; Owner: -
--

CREATE SEQUENCE gestor_tickets.thread_operations_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: thread_operations_id_seq; Type: SEQUENCE OWNED BY; Schema: gestor_tickets; Owner: -
--

ALTER SEQUENCE gestor_tickets.thread_operations_id_seq OWNED BY gestor_tickets.thread_operations.id;


--
-- Name: v_thread_related_tickets; Type: VIEW; Schema: gestor_tickets; Owner: -
--

CREATE VIEW gestor_tickets.v_thread_related_tickets AS
 SELECT DISTINCT st.account_id,
    st.id AS thread_id,
    gtc.id AS glpi_ticket_cache_id,
    gtc.glpi_ticket_id,
    'thread_direct'::text AS relation_source
   FROM ((gestor_tickets.system_threads st
     JOIN gestor_tickets.glpi_ticket_thread_links ttl ON (((ttl.thread_id = st.id) AND (ttl.status = 'active'::gestor_tickets.glpi_link_status))))
     JOIN gestor_tickets.glpi_ticket_cache gtc ON ((gtc.id = ttl.glpi_ticket_cache_id)))
UNION
 SELECT DISTINCT st.account_id,
    st.id AS thread_id,
    gtc.id AS glpi_ticket_cache_id,
    gtc.glpi_ticket_id,
    'email_in_thread'::text AS relation_source
   FROM (((gestor_tickets.system_threads st
     JOIN gestor_tickets.email_thread_members etm ON (((etm.thread_id = st.id) AND (etm.status = 'active'::gestor_tickets.thread_member_status))))
     JOIN gestor_tickets.glpi_ticket_email_links tel ON (((tel.email_message_id = etm.email_message_id) AND (tel.status = 'active'::gestor_tickets.glpi_link_status))))
     JOIN gestor_tickets.glpi_ticket_cache gtc ON ((gtc.id = tel.glpi_ticket_cache_id)));


--
-- Name: v_ticket_email_context; Type: VIEW; Schema: gestor_tickets; Owner: -
--

CREATE VIEW gestor_tickets.v_ticket_email_context AS
 SELECT tel.account_id,
    tel.glpi_ticket_cache_id,
    gtc.glpi_ticket_id,
    tel.email_message_id,
    NULL::bigint AS thread_id,
    'email_direct'::text AS relation_source,
    tel.created_at AS linked_at
   FROM (gestor_tickets.glpi_ticket_email_links tel
     JOIN gestor_tickets.glpi_ticket_cache gtc ON ((gtc.id = tel.glpi_ticket_cache_id)))
  WHERE (tel.status = 'active'::gestor_tickets.glpi_link_status)
UNION
 SELECT ttl.account_id,
    ttl.glpi_ticket_cache_id,
    gtc.glpi_ticket_id,
    etm.email_message_id,
    ttl.thread_id,
    'thread_expanded'::text AS relation_source,
    ttl.created_at AS linked_at
   FROM ((gestor_tickets.glpi_ticket_thread_links ttl
     JOIN gestor_tickets.glpi_ticket_cache gtc ON ((gtc.id = ttl.glpi_ticket_cache_id)))
     JOIN gestor_tickets.email_thread_members etm ON (((etm.thread_id = ttl.thread_id) AND (etm.status = 'active'::gestor_tickets.thread_member_status))))
  WHERE (ttl.status = 'active'::gestor_tickets.glpi_link_status);


--
-- Name: v_ticket_related_tickets_by_email; Type: VIEW; Schema: gestor_tickets; Owner: -
--

CREATE VIEW gestor_tickets.v_ticket_related_tickets_by_email AS
 SELECT DISTINCT a.account_id,
    a.glpi_ticket_cache_id AS source_ticket_cache_id,
    a.glpi_ticket_id AS source_glpi_ticket_id,
    b.glpi_ticket_cache_id AS related_ticket_cache_id,
    b.glpi_ticket_id AS related_glpi_ticket_id,
    a.email_message_id,
    'shared_email'::text AS relation_reason
   FROM (gestor_tickets.v_ticket_email_context a
     JOIN gestor_tickets.v_ticket_email_context b ON (((b.account_id = a.account_id) AND (b.email_message_id = a.email_message_id) AND (b.glpi_ticket_cache_id <> a.glpi_ticket_cache_id))));


--
-- Name: account_users id; Type: DEFAULT; Schema: gestor_tickets; Owner: -
--

ALTER TABLE ONLY gestor_tickets.account_users ALTER COLUMN id SET DEFAULT nextval('gestor_tickets.account_users_id_seq'::regclass);


--
-- Name: ai_call_history id; Type: DEFAULT; Schema: gestor_tickets; Owner: -
--

ALTER TABLE ONLY gestor_tickets.ai_call_history ALTER COLUMN id SET DEFAULT nextval('gestor_tickets.ai_call_history_id_seq'::regclass);


--
-- Name: ai_endpoint_validation_logs id; Type: DEFAULT; Schema: gestor_tickets; Owner: -
--

ALTER TABLE ONLY gestor_tickets.ai_endpoint_validation_logs ALTER COLUMN id SET DEFAULT nextval('gestor_tickets.ai_endpoint_validation_logs_id_seq'::regclass);


--
-- Name: ai_llm_endpoint_models id; Type: DEFAULT; Schema: gestor_tickets; Owner: -
--

ALTER TABLE ONLY gestor_tickets.ai_llm_endpoint_models ALTER COLUMN id SET DEFAULT nextval('gestor_tickets.ai_llm_endpoint_models_id_seq'::regclass);


--
-- Name: ai_llm_endpoints id; Type: DEFAULT; Schema: gestor_tickets; Owner: -
--

ALTER TABLE ONLY gestor_tickets.ai_llm_endpoints ALTER COLUMN id SET DEFAULT nextval('gestor_tickets.ai_llm_endpoints_id_seq'::regclass);


--
-- Name: ai_prompt_templates id; Type: DEFAULT; Schema: gestor_tickets; Owner: -
--

ALTER TABLE ONLY gestor_tickets.ai_prompt_templates ALTER COLUMN id SET DEFAULT nextval('gestor_tickets.ai_prompt_templates_id_seq'::regclass);


--
-- Name: ai_prompt_versions id; Type: DEFAULT; Schema: gestor_tickets; Owner: -
--

ALTER TABLE ONLY gestor_tickets.ai_prompt_versions ALTER COLUMN id SET DEFAULT nextval('gestor_tickets.ai_prompt_versions_id_seq'::regclass);


--
-- Name: audit_log id; Type: DEFAULT; Schema: gestor_tickets; Owner: -
--

ALTER TABLE ONLY gestor_tickets.audit_log ALTER COLUMN id SET DEFAULT nextval('gestor_tickets.audit_log_id_seq'::regclass);


--
-- Name: collaborative_accounts id; Type: DEFAULT; Schema: gestor_tickets; Owner: -
--

ALTER TABLE ONLY gestor_tickets.collaborative_accounts ALTER COLUMN id SET DEFAULT nextval('gestor_tickets.collaborative_accounts_id_seq'::regclass);


--
-- Name: email_ai_processing id; Type: DEFAULT; Schema: gestor_tickets; Owner: -
--

ALTER TABLE ONLY gestor_tickets.email_ai_processing ALTER COLUMN id SET DEFAULT nextval('gestor_tickets.email_ai_processing_id_seq'::regclass);


--
-- Name: email_attachments id; Type: DEFAULT; Schema: gestor_tickets; Owner: -
--

ALTER TABLE ONLY gestor_tickets.email_attachments ALTER COLUMN id SET DEFAULT nextval('gestor_tickets.email_attachments_id_seq'::regclass);


--
-- Name: email_message_occurrences id; Type: DEFAULT; Schema: gestor_tickets; Owner: -
--

ALTER TABLE ONLY gestor_tickets.email_message_occurrences ALTER COLUMN id SET DEFAULT nextval('gestor_tickets.email_message_occurrences_id_seq'::regclass);


--
-- Name: email_messages id; Type: DEFAULT; Schema: gestor_tickets; Owner: -
--

ALTER TABLE ONLY gestor_tickets.email_messages ALTER COLUMN id SET DEFAULT nextval('gestor_tickets.email_messages_id_seq'::regclass);


--
-- Name: email_recipients id; Type: DEFAULT; Schema: gestor_tickets; Owner: -
--

ALTER TABLE ONLY gestor_tickets.email_recipients ALTER COLUMN id SET DEFAULT nextval('gestor_tickets.email_recipients_id_seq'::regclass);


--
-- Name: email_thread_members id; Type: DEFAULT; Schema: gestor_tickets; Owner: -
--

ALTER TABLE ONLY gestor_tickets.email_thread_members ALTER COLUMN id SET DEFAULT nextval('gestor_tickets.email_thread_members_id_seq'::regclass);


--
-- Name: glpi_api_operations id; Type: DEFAULT; Schema: gestor_tickets; Owner: -
--

ALTER TABLE ONLY gestor_tickets.glpi_api_operations ALTER COLUMN id SET DEFAULT nextval('gestor_tickets.glpi_api_operations_id_seq'::regclass);


--
-- Name: glpi_instances id; Type: DEFAULT; Schema: gestor_tickets; Owner: -
--

ALTER TABLE ONLY gestor_tickets.glpi_instances ALTER COLUMN id SET DEFAULT nextval('gestor_tickets.glpi_instances_id_seq'::regclass);


--
-- Name: glpi_ticket_cache id; Type: DEFAULT; Schema: gestor_tickets; Owner: -
--

ALTER TABLE ONLY gestor_tickets.glpi_ticket_cache ALTER COLUMN id SET DEFAULT nextval('gestor_tickets.glpi_ticket_cache_id_seq'::regclass);


--
-- Name: glpi_ticket_email_links id; Type: DEFAULT; Schema: gestor_tickets; Owner: -
--

ALTER TABLE ONLY gestor_tickets.glpi_ticket_email_links ALTER COLUMN id SET DEFAULT nextval('gestor_tickets.glpi_ticket_email_links_id_seq'::regclass);


--
-- Name: glpi_ticket_relationships id; Type: DEFAULT; Schema: gestor_tickets; Owner: -
--

ALTER TABLE ONLY gestor_tickets.glpi_ticket_relationships ALTER COLUMN id SET DEFAULT nextval('gestor_tickets.glpi_ticket_relationships_id_seq'::regclass);


--
-- Name: glpi_ticket_thread_links id; Type: DEFAULT; Schema: gestor_tickets; Owner: -
--

ALTER TABLE ONLY gestor_tickets.glpi_ticket_thread_links ALTER COLUMN id SET DEFAULT nextval('gestor_tickets.glpi_ticket_thread_links_id_seq'::regclass);


--
-- Name: mail_ingestion_jobs id; Type: DEFAULT; Schema: gestor_tickets; Owner: -
--

ALTER TABLE ONLY gestor_tickets.mail_ingestion_jobs ALTER COLUMN id SET DEFAULT nextval('gestor_tickets.mail_ingestion_jobs_id_seq'::regclass);


--
-- Name: mail_ingestion_runs id; Type: DEFAULT; Schema: gestor_tickets; Owner: -
--

ALTER TABLE ONLY gestor_tickets.mail_ingestion_runs ALTER COLUMN id SET DEFAULT nextval('gestor_tickets.mail_ingestion_runs_id_seq'::regclass);


--
-- Name: personal_mail_accounts id; Type: DEFAULT; Schema: gestor_tickets; Owner: -
--

ALTER TABLE ONLY gestor_tickets.personal_mail_accounts ALTER COLUMN id SET DEFAULT nextval('gestor_tickets.personal_mail_accounts_id_seq'::regclass);


--
-- Name: personal_message_transfer_log id; Type: DEFAULT; Schema: gestor_tickets; Owner: -
--

ALTER TABLE ONLY gestor_tickets.personal_message_transfer_log ALTER COLUMN id SET DEFAULT nextval('gestor_tickets.personal_message_transfer_log_id_seq'::regclass);


--
-- Name: system_threads id; Type: DEFAULT; Schema: gestor_tickets; Owner: -
--

ALTER TABLE ONLY gestor_tickets.system_threads ALTER COLUMN id SET DEFAULT nextval('gestor_tickets.system_threads_id_seq'::regclass);


--
-- Name: thread_ai_syntheses id; Type: DEFAULT; Schema: gestor_tickets; Owner: -
--

ALTER TABLE ONLY gestor_tickets.thread_ai_syntheses ALTER COLUMN id SET DEFAULT nextval('gestor_tickets.thread_ai_syntheses_id_seq'::regclass);


--
-- Name: thread_merge_history id; Type: DEFAULT; Schema: gestor_tickets; Owner: -
--

ALTER TABLE ONLY gestor_tickets.thread_merge_history ALTER COLUMN id SET DEFAULT nextval('gestor_tickets.thread_merge_history_id_seq'::regclass);


--
-- Name: thread_operations id; Type: DEFAULT; Schema: gestor_tickets; Owner: -
--

ALTER TABLE ONLY gestor_tickets.thread_operations ALTER COLUMN id SET DEFAULT nextval('gestor_tickets.thread_operations_id_seq'::regclass);


--
-- Data for Name: account_users; Type: TABLE DATA; Schema: gestor_tickets; Owner: -
--

COPY gestor_tickets.account_users (id, public_uid, account_id, auth_mode, login_identifier, username_local, password_hash, display_name, contact_email, role, status, can_manage_users, can_manage_account_config, can_read_account_mail, can_reply_from_account, can_create_glpi_ticket, can_update_glpi_ticket, can_link_tickets, can_manage_ai, failed_login_count, locked_until, last_login_at, created_by_user_id, created_at, updated_at) FROM stdin;
2	04fb9347-3d97-4c52-a231-e6510262173e	3	local_collaborator	fase38#sistemas-tic@gestor-tickets.es	fase38	pbkdf2_sha256$390000$ia9fceJZgNy57wS5JDFHcQ==$e_CpP5YTYpwWcsrOzMo8QKejlQYk2z8FOzjkqIhT4ik=	Colaborador Fase 38	\N	viewer	active	f	f	t	f	f	f	f	f	0	\N	2026-06-14 19:23:30.567742+01	1	2026-06-14 19:22:36.905867+01	2026-06-14 19:23:30.567754+01
1	54f4c7ef-947c-4f87-b999-9f8c1bd7a3b5	3	glpi_account_manager	sistemas-tic@gestor-tickets.es	\N	\N	Sistemas TIC	sistemas-tic@gestor-tickets.es	owner	active	t	t	t	t	t	t	t	t	0	\N	2026-06-17 16:58:00.424523+01	\N	2026-06-14 11:34:11.93862+01	2026-06-17 16:58:00.424523+01
\.


--
-- Data for Name: ai_call_history; Type: TABLE DATA; Schema: gestor_tickets; Owner: -
--

COPY gestor_tickets.ai_call_history (id, account_id, created_by_user_id, scope, call_source, call_purpose, prompt_version_id, model, endpoint_url, enable_thinking, temperature, top_p, top_k, max_tokens, timeout_seconds, duration_ms, status, http_status_code, error_type, error_message, request_payload_json, request_messages_json, response_full_json, response_message_content, response_parsed_json, json_parse_ok, json_validation_ok, json_validation_errors_json, prompt_tokens, completion_tokens, total_tokens, related_email_message_id, related_thread_id, related_glpi_ticket_cache_id, created_at) FROM stdin;
\.


--
-- Data for Name: ai_endpoint_validation_logs; Type: TABLE DATA; Schema: gestor_tickets; Owner: -
--

COPY gestor_tickets.ai_endpoint_validation_logs (id, endpoint_id, model_id, operation_type, http_status, success, latency_ms, error_type, error_message, request_json_redacted, response_json, response_text_preview, strict_json_ok, thinking_detected, created_at) FROM stdin;
3	5	\N	discover_models	200	t	208	\N	\N	{"url": "https://generativelanguage.googleapis.com/v1beta/openai/models", "method": "GET"}	{"model_count": 56}	\N	\N	f	2026-06-15 14:05:31.39474+01
4	5	models/gemma-4-31b-it	validate_model	200	t	5781	thinking_detected	Modelo accesible, pero no devuelve JSON estricto porque incluye bloque thinking.	{"model": "models/gemma-4-31b-it", "top_p": 1.0, "messages": "[technical validation prompt only]", "max_tokens": 1024, "temperature": 0.2}	{"id": "xfgvarDmDvqAkdUP073r8Q8", "model": "models/gemma-4-31b-it", "usage": {"total_tokens": 126, "prompt_tokens": 23, "completion_tokens": 5}, "object": "chat.completion", "choices": [{"index": 0, "message": {"role": "assistant", "content": "<thought>*   Input: \\"Devuelve exactamente este JSON: {\\"ok\\":true}\\" (Return exactly this JSON: {\\"ok\\":true})\\n    *   Constraint: \\"Responde exclusivamente con JSON válido, sin markdown.\\" (Respond exclusively with valid JSON, without markdown.)\\n\\n    *   The user wants the specific JSON object `{\\"ok\\":true}`.\\n    *   The system instruction forbids markdown (no ```json ... ```).\\n\\n    *   `{\\"ok\\":true}`</thought>{\\"ok\\":true}", "extra_content": {"google": {"thought": true}}}, "finish_reason": "stop"}], "created": 1781528778}	<thought>*   Input: "Devuelve exactamente este JSON: {"ok":true}" (Return exactly this JSON: {"ok":true})\n    *   Constraint: "Responde exclusivamente con JSON válido, sin markdown." (Respond exclusively with valid JSON, without markdown.)\n\n    *   The user wants the specific JSON object `{"ok":true}`.\n    *   The system instruction forbids markdown (no ```json ... ```).\n\n    *   `{"ok":true}`</thought>{"ok":true}	f	t	2026-06-15 14:06:13.068896+01
5	5	models/gemma-4-31b-it	validate_model	200	t	4417	thinking_detected	Modelo accesible, pero no devuelve JSON estricto porque incluye bloque thinking.	{"model": "models/gemma-4-31b-it", "top_p": 1.0, "messages": "[technical validation prompt only]", "max_tokens": 1024, "temperature": 0.2}	{"id": "XPsvatbpO5vfvdIPtvqqKQ", "model": "models/gemma-4-31b-it", "usage": {"total_tokens": 123, "prompt_tokens": 23, "completion_tokens": 5}, "object": "chat.completion", "choices": [{"index": 0, "message": {"role": "assistant", "content": "<thought>*   Input: \\"Devuelve exactamente este JSON: {\\"ok\\":true}\\"\\n    *   Constraint: \\"Responde exclusivamente con JSON válido, sin markdown.\\" (Respond exclusively with valid JSON, no markdown).\\n\\n    *   The user wants the specific JSON object `{\\"ok\\":true}`.\\n    *   The system prompt requires *only* valid JSON, no markdown (no ```json ... ``` blocks).\\n\\n    *   `{\\"ok\\":true}`</thought>{\\"ok\\":true}", "extra_content": {"google": {"thought": true}}}, "finish_reason": "stop"}], "created": 1781529441}	<thought>*   Input: "Devuelve exactamente este JSON: {"ok":true}"\n    *   Constraint: "Responde exclusivamente con JSON válido, sin markdown." (Respond exclusively with valid JSON, no markdown).\n\n    *   The user wants the specific JSON object `{"ok":true}`.\n    *   The system prompt requires *only* valid JSON, no markdown (no ```json ... ``` blocks).\n\n    *   `{"ok":true}`</thought>{"ok":true}	f	t	2026-06-15 14:17:16.82861+01
6	5	models/gemma-4-31b-it	validate_model	400	f	337	invalid_request	Validación fallida: invalid_request	{"model": "models/gemma-4-31b-it", "top_p": 1.0, "messages": "[technical validation prompt only]", "max_tokens": 4096, "temperature": 0.2, "reasoning_effort": "none"}	[{"error": {"code": 400, "status": "INVALID_ARGUMENT", "message": "Thinking budget is not supported for this model."}}]	[{\n  "error": {\n    "code": 400,\n    "message": "Thinking budget is not supported for this model.",\n    "status": "INVALID_ARGUMENT"\n  }\n}\n]	f	f	2026-06-15 15:01:28.599867+01
7	5	models/gemini-3.5-flash	validate_model	200	t	1612	\N	\N	{"model": "models/gemini-3.5-flash", "top_p": 1.0, "messages": "[technical validation prompt only]", "max_tokens": 4096, "temperature": 0.2, "reasoning_effort": "none"}	{"id": "zgUwapPhN7ufnsEP1aaJ0AI", "model": "models/gemini-3.5-flash", "usage": {"total_tokens": 28, "prompt_tokens": 23, "completion_tokens": 5}, "object": "chat.completion", "choices": [{"index": 0, "message": {"role": "assistant", "content": "{\\"ok\\":true}", "extra_content": {"google": {"thought_signature": "EjQKMgEMOdbHk7sZHiJjNbvfkMfDeCHXs6aqbrQwTT0yFnDe1nDVOoxaphonnj5/r0VKz2Ql"}}}, "finish_reason": "stop"}], "created": 1781532112}	{"ok":true}	t	f	2026-06-15 15:01:50.724561+01
\.


--
-- Data for Name: ai_llm_endpoint_models; Type: TABLE DATA; Schema: gestor_tickets; Owner: -
--

COPY gestor_tickets.ai_llm_endpoint_models (id, endpoint_id, model_id, display_name, owned_by, context_length, model_type, pricing_json, raw_json, is_chat_capable, is_free_hint, last_seen_at, created_at, updated_at) FROM stdin;
1	5	models/gemini-2.5-flash	Gemini 2.5 Flash	google	\N	model	{}	{"id": "models/gemini-2.5-flash", "object": "model", "owned_by": "google", "display_name": "Gemini 2.5 Flash"}	t	f	2026-06-15 14:05:31.39474+01	2026-06-15 14:05:31.39474+01	2026-06-15 14:05:31.39474+01
2	5	models/gemini-2.5-pro	Gemini 2.5 Pro	google	\N	model	{}	{"id": "models/gemini-2.5-pro", "object": "model", "owned_by": "google", "display_name": "Gemini 2.5 Pro"}	t	f	2026-06-15 14:05:31.39474+01	2026-06-15 14:05:31.39474+01	2026-06-15 14:05:31.39474+01
3	5	models/gemini-2.0-flash	Gemini 2.0 Flash	google	\N	model	{}	{"id": "models/gemini-2.0-flash", "object": "model", "owned_by": "google", "display_name": "Gemini 2.0 Flash"}	t	f	2026-06-15 14:05:31.39474+01	2026-06-15 14:05:31.39474+01	2026-06-15 14:05:31.39474+01
4	5	models/gemini-2.0-flash-001	Gemini 2.0 Flash 001	google	\N	model	{}	{"id": "models/gemini-2.0-flash-001", "object": "model", "owned_by": "google", "display_name": "Gemini 2.0 Flash 001"}	t	f	2026-06-15 14:05:31.39474+01	2026-06-15 14:05:31.39474+01	2026-06-15 14:05:31.39474+01
5	5	models/gemini-2.0-flash-lite-001	Gemini 2.0 Flash-Lite 001	google	\N	model	{}	{"id": "models/gemini-2.0-flash-lite-001", "object": "model", "owned_by": "google", "display_name": "Gemini 2.0 Flash-Lite 001"}	t	f	2026-06-15 14:05:31.39474+01	2026-06-15 14:05:31.39474+01	2026-06-15 14:05:31.39474+01
6	5	models/gemini-2.0-flash-lite	Gemini 2.0 Flash-Lite	google	\N	model	{}	{"id": "models/gemini-2.0-flash-lite", "object": "model", "owned_by": "google", "display_name": "Gemini 2.0 Flash-Lite"}	t	f	2026-06-15 14:05:31.39474+01	2026-06-15 14:05:31.39474+01	2026-06-15 14:05:31.39474+01
7	5	models/gemini-2.5-flash-preview-tts	Gemini 2.5 Flash Preview TTS	google	\N	model	{}	{"id": "models/gemini-2.5-flash-preview-tts", "object": "model", "owned_by": "google", "display_name": "Gemini 2.5 Flash Preview TTS"}	t	f	2026-06-15 14:05:31.39474+01	2026-06-15 14:05:31.39474+01	2026-06-15 14:05:31.39474+01
8	5	models/gemini-2.5-pro-preview-tts	Gemini 2.5 Pro Preview TTS	google	\N	model	{}	{"id": "models/gemini-2.5-pro-preview-tts", "object": "model", "owned_by": "google", "display_name": "Gemini 2.5 Pro Preview TTS"}	t	f	2026-06-15 14:05:31.39474+01	2026-06-15 14:05:31.39474+01	2026-06-15 14:05:31.39474+01
9	5	models/gemma-4-26b-a4b-it	Gemma 4 26B A4B IT	google	\N	model	{}	{"id": "models/gemma-4-26b-a4b-it", "object": "model", "owned_by": "google", "display_name": "Gemma 4 26B A4B IT"}	t	f	2026-06-15 14:05:31.39474+01	2026-06-15 14:05:31.39474+01	2026-06-15 14:05:31.39474+01
10	5	models/gemma-4-31b-it	Gemma 4 31B IT	google	\N	model	{}	{"id": "models/gemma-4-31b-it", "object": "model", "owned_by": "google", "display_name": "Gemma 4 31B IT"}	t	f	2026-06-15 14:05:31.39474+01	2026-06-15 14:05:31.39474+01	2026-06-15 14:05:31.39474+01
11	5	models/gemini-flash-latest	Gemini Flash Latest	google	\N	model	{}	{"id": "models/gemini-flash-latest", "object": "model", "owned_by": "google", "display_name": "Gemini Flash Latest"}	t	f	2026-06-15 14:05:31.39474+01	2026-06-15 14:05:31.39474+01	2026-06-15 14:05:31.39474+01
12	5	models/gemini-flash-lite-latest	Gemini Flash-Lite Latest	google	\N	model	{}	{"id": "models/gemini-flash-lite-latest", "object": "model", "owned_by": "google", "display_name": "Gemini Flash-Lite Latest"}	t	f	2026-06-15 14:05:31.39474+01	2026-06-15 14:05:31.39474+01	2026-06-15 14:05:31.39474+01
13	5	models/gemini-pro-latest	Gemini Pro Latest	google	\N	model	{}	{"id": "models/gemini-pro-latest", "object": "model", "owned_by": "google", "display_name": "Gemini Pro Latest"}	t	f	2026-06-15 14:05:31.39474+01	2026-06-15 14:05:31.39474+01	2026-06-15 14:05:31.39474+01
14	5	models/gemini-2.5-flash-lite	Gemini 2.5 Flash-Lite	google	\N	model	{}	{"id": "models/gemini-2.5-flash-lite", "object": "model", "owned_by": "google", "display_name": "Gemini 2.5 Flash-Lite"}	t	f	2026-06-15 14:05:31.39474+01	2026-06-15 14:05:31.39474+01	2026-06-15 14:05:31.39474+01
15	5	models/gemini-2.5-flash-image	Nano Banana	google	\N	model	{}	{"id": "models/gemini-2.5-flash-image", "object": "model", "owned_by": "google", "display_name": "Nano Banana"}	t	f	2026-06-15 14:05:31.39474+01	2026-06-15 14:05:31.39474+01	2026-06-15 14:05:31.39474+01
16	5	models/gemini-3-pro-preview	Gemini 3 Pro Preview	google	\N	model	{}	{"id": "models/gemini-3-pro-preview", "object": "model", "owned_by": "google", "display_name": "Gemini 3 Pro Preview"}	t	f	2026-06-15 14:05:31.39474+01	2026-06-15 14:05:31.39474+01	2026-06-15 14:05:31.39474+01
17	5	models/gemini-3-flash-preview	Gemini 3 Flash Preview	google	\N	model	{}	{"id": "models/gemini-3-flash-preview", "object": "model", "owned_by": "google", "display_name": "Gemini 3 Flash Preview"}	t	f	2026-06-15 14:05:31.39474+01	2026-06-15 14:05:31.39474+01	2026-06-15 14:05:31.39474+01
18	5	models/gemini-3.1-pro-preview	Gemini 3.1 Pro Preview	google	\N	model	{}	{"id": "models/gemini-3.1-pro-preview", "object": "model", "owned_by": "google", "display_name": "Gemini 3.1 Pro Preview"}	t	f	2026-06-15 14:05:31.39474+01	2026-06-15 14:05:31.39474+01	2026-06-15 14:05:31.39474+01
19	5	models/gemini-3.1-pro-preview-customtools	Gemini 3.1 Pro Preview Custom Tools	google	\N	model	{}	{"id": "models/gemini-3.1-pro-preview-customtools", "object": "model", "owned_by": "google", "display_name": "Gemini 3.1 Pro Preview Custom Tools"}	t	f	2026-06-15 14:05:31.39474+01	2026-06-15 14:05:31.39474+01	2026-06-15 14:05:31.39474+01
20	5	models/gemini-3.1-flash-lite-preview	Gemini 3.1 Flash Lite Preview	google	\N	model	{}	{"id": "models/gemini-3.1-flash-lite-preview", "object": "model", "owned_by": "google", "display_name": "Gemini 3.1 Flash Lite Preview"}	t	f	2026-06-15 14:05:31.39474+01	2026-06-15 14:05:31.39474+01	2026-06-15 14:05:31.39474+01
21	5	models/gemini-3.1-flash-lite	Gemini 3.1 Flash Lite	google	\N	model	{}	{"id": "models/gemini-3.1-flash-lite", "object": "model", "owned_by": "google", "display_name": "Gemini 3.1 Flash Lite"}	t	f	2026-06-15 14:05:31.39474+01	2026-06-15 14:05:31.39474+01	2026-06-15 14:05:31.39474+01
22	5	models/gemini-3-pro-image-preview	Nano Banana Pro	google	\N	model	{}	{"id": "models/gemini-3-pro-image-preview", "object": "model", "owned_by": "google", "display_name": "Nano Banana Pro"}	t	f	2026-06-15 14:05:31.39474+01	2026-06-15 14:05:31.39474+01	2026-06-15 14:05:31.39474+01
23	5	models/gemini-3-pro-image	Nano Banana Pro	google	\N	model	{}	{"id": "models/gemini-3-pro-image", "object": "model", "owned_by": "google", "display_name": "Nano Banana Pro"}	t	f	2026-06-15 14:05:31.39474+01	2026-06-15 14:05:31.39474+01	2026-06-15 14:05:31.39474+01
24	5	models/nano-banana-pro-preview	Nano Banana Pro	google	\N	model	{}	{"id": "models/nano-banana-pro-preview", "object": "model", "owned_by": "google", "display_name": "Nano Banana Pro"}	t	f	2026-06-15 14:05:31.39474+01	2026-06-15 14:05:31.39474+01	2026-06-15 14:05:31.39474+01
25	5	models/gemini-3.1-flash-image-preview	Nano Banana 2	google	\N	model	{}	{"id": "models/gemini-3.1-flash-image-preview", "object": "model", "owned_by": "google", "display_name": "Nano Banana 2"}	t	f	2026-06-15 14:05:31.39474+01	2026-06-15 14:05:31.39474+01	2026-06-15 14:05:31.39474+01
26	5	models/gemini-3.1-flash-image	Nano Banana 2	google	\N	model	{}	{"id": "models/gemini-3.1-flash-image", "object": "model", "owned_by": "google", "display_name": "Nano Banana 2"}	t	f	2026-06-15 14:05:31.39474+01	2026-06-15 14:05:31.39474+01	2026-06-15 14:05:31.39474+01
27	5	models/gemini-3.5-flash	Gemini 3.5 Flash	google	\N	model	{}	{"id": "models/gemini-3.5-flash", "object": "model", "owned_by": "google", "display_name": "Gemini 3.5 Flash"}	t	f	2026-06-15 14:05:31.39474+01	2026-06-15 14:05:31.39474+01	2026-06-15 14:05:31.39474+01
28	5	models/lyria-3-clip-preview	Lyria 3 Clip Preview	google	\N	model	{}	{"id": "models/lyria-3-clip-preview", "object": "model", "owned_by": "google", "display_name": "Lyria 3 Clip Preview"}	t	f	2026-06-15 14:05:31.39474+01	2026-06-15 14:05:31.39474+01	2026-06-15 14:05:31.39474+01
29	5	models/lyria-3-pro-preview	Lyria 3 Pro Preview	google	\N	model	{}	{"id": "models/lyria-3-pro-preview", "object": "model", "owned_by": "google", "display_name": "Lyria 3 Pro Preview"}	t	f	2026-06-15 14:05:31.39474+01	2026-06-15 14:05:31.39474+01	2026-06-15 14:05:31.39474+01
30	5	models/gemini-3.1-flash-tts-preview	Gemini 3.1 Flash TTS Preview	google	\N	model	{}	{"id": "models/gemini-3.1-flash-tts-preview", "object": "model", "owned_by": "google", "display_name": "Gemini 3.1 Flash TTS Preview"}	t	f	2026-06-15 14:05:31.39474+01	2026-06-15 14:05:31.39474+01	2026-06-15 14:05:31.39474+01
31	5	models/gemini-robotics-er-1.5-preview	Gemini Robotics-ER 1.5 Preview	google	\N	model	{}	{"id": "models/gemini-robotics-er-1.5-preview", "object": "model", "owned_by": "google", "display_name": "Gemini Robotics-ER 1.5 Preview"}	t	f	2026-06-15 14:05:31.39474+01	2026-06-15 14:05:31.39474+01	2026-06-15 14:05:31.39474+01
32	5	models/gemini-robotics-er-1.6-preview	Gemini Robotics-ER 1.6 Preview	google	\N	model	{}	{"id": "models/gemini-robotics-er-1.6-preview", "object": "model", "owned_by": "google", "display_name": "Gemini Robotics-ER 1.6 Preview"}	t	f	2026-06-15 14:05:31.39474+01	2026-06-15 14:05:31.39474+01	2026-06-15 14:05:31.39474+01
33	5	models/gemini-2.5-computer-use-preview-10-2025	Gemini 2.5 Computer Use Preview 10-2025	google	\N	model	{}	{"id": "models/gemini-2.5-computer-use-preview-10-2025", "object": "model", "owned_by": "google", "display_name": "Gemini 2.5 Computer Use Preview 10-2025"}	t	f	2026-06-15 14:05:31.39474+01	2026-06-15 14:05:31.39474+01	2026-06-15 14:05:31.39474+01
34	5	models/antigravity-preview-05-2026	Antigravity Agent Preview	google	\N	model	{}	{"id": "models/antigravity-preview-05-2026", "object": "model", "owned_by": "google", "display_name": "Antigravity Agent Preview"}	t	f	2026-06-15 14:05:31.39474+01	2026-06-15 14:05:31.39474+01	2026-06-15 14:05:31.39474+01
35	5	models/deep-research-max-preview-04-2026	Deep Research Max Preview (Apr-21-2026)	google	\N	model	{}	{"id": "models/deep-research-max-preview-04-2026", "object": "model", "owned_by": "google", "display_name": "Deep Research Max Preview (Apr-21-2026)"}	t	f	2026-06-15 14:05:31.39474+01	2026-06-15 14:05:31.39474+01	2026-06-15 14:05:31.39474+01
36	5	models/deep-research-preview-04-2026	Deep Research Preview (Apr-21-2026)	google	\N	model	{}	{"id": "models/deep-research-preview-04-2026", "object": "model", "owned_by": "google", "display_name": "Deep Research Preview (Apr-21-2026)"}	t	f	2026-06-15 14:05:31.39474+01	2026-06-15 14:05:31.39474+01	2026-06-15 14:05:31.39474+01
37	5	models/deep-research-pro-preview-12-2025	Deep Research Pro Preview (Dec-12-2025)	google	\N	model	{}	{"id": "models/deep-research-pro-preview-12-2025", "object": "model", "owned_by": "google", "display_name": "Deep Research Pro Preview (Dec-12-2025)"}	t	f	2026-06-15 14:05:31.39474+01	2026-06-15 14:05:31.39474+01	2026-06-15 14:05:31.39474+01
38	5	models/gemini-embedding-001	Gemini Embedding 001	google	\N	model	{}	{"id": "models/gemini-embedding-001", "object": "model", "owned_by": "google", "display_name": "Gemini Embedding 001"}	f	f	2026-06-15 14:05:31.39474+01	2026-06-15 14:05:31.39474+01	2026-06-15 14:05:31.39474+01
39	5	models/gemini-embedding-2-preview	Gemini Embedding 2 Preview	google	\N	model	{}	{"id": "models/gemini-embedding-2-preview", "object": "model", "owned_by": "google", "display_name": "Gemini Embedding 2 Preview"}	f	f	2026-06-15 14:05:31.39474+01	2026-06-15 14:05:31.39474+01	2026-06-15 14:05:31.39474+01
40	5	models/gemini-embedding-2	Gemini Embedding 2	google	\N	model	{}	{"id": "models/gemini-embedding-2", "object": "model", "owned_by": "google", "display_name": "Gemini Embedding 2"}	f	f	2026-06-15 14:05:31.39474+01	2026-06-15 14:05:31.39474+01	2026-06-15 14:05:31.39474+01
41	5	models/aqa	Model that performs Attributed Question Answering.	google	\N	model	{}	{"id": "models/aqa", "object": "model", "owned_by": "google", "display_name": "Model that performs Attributed Question Answering."}	t	f	2026-06-15 14:05:31.39474+01	2026-06-15 14:05:31.39474+01	2026-06-15 14:05:31.39474+01
42	5	models/imagen-4.0-generate-001	Imagen 4	google	\N	model	{}	{"id": "models/imagen-4.0-generate-001", "object": "model", "owned_by": "google", "display_name": "Imagen 4"}	t	f	2026-06-15 14:05:31.39474+01	2026-06-15 14:05:31.39474+01	2026-06-15 14:05:31.39474+01
43	5	models/imagen-4.0-ultra-generate-001	Imagen 4 Ultra	google	\N	model	{}	{"id": "models/imagen-4.0-ultra-generate-001", "object": "model", "owned_by": "google", "display_name": "Imagen 4 Ultra"}	t	f	2026-06-15 14:05:31.39474+01	2026-06-15 14:05:31.39474+01	2026-06-15 14:05:31.39474+01
44	5	models/imagen-4.0-fast-generate-001	Imagen 4 Fast	google	\N	model	{}	{"id": "models/imagen-4.0-fast-generate-001", "object": "model", "owned_by": "google", "display_name": "Imagen 4 Fast"}	t	f	2026-06-15 14:05:31.39474+01	2026-06-15 14:05:31.39474+01	2026-06-15 14:05:31.39474+01
45	5	models/veo-2.0-generate-001	Veo 2	google	\N	model	{}	{"id": "models/veo-2.0-generate-001", "object": "model", "owned_by": "google", "display_name": "Veo 2"}	t	f	2026-06-15 14:05:31.39474+01	2026-06-15 14:05:31.39474+01	2026-06-15 14:05:31.39474+01
46	5	models/veo-3.0-generate-001	Veo 3	google	\N	model	{}	{"id": "models/veo-3.0-generate-001", "object": "model", "owned_by": "google", "display_name": "Veo 3"}	t	f	2026-06-15 14:05:31.39474+01	2026-06-15 14:05:31.39474+01	2026-06-15 14:05:31.39474+01
47	5	models/veo-3.0-fast-generate-001	Veo 3 fast	google	\N	model	{}	{"id": "models/veo-3.0-fast-generate-001", "object": "model", "owned_by": "google", "display_name": "Veo 3 fast"}	t	f	2026-06-15 14:05:31.39474+01	2026-06-15 14:05:31.39474+01	2026-06-15 14:05:31.39474+01
48	5	models/veo-3.1-generate-preview	Veo 3.1	google	\N	model	{}	{"id": "models/veo-3.1-generate-preview", "object": "model", "owned_by": "google", "display_name": "Veo 3.1"}	t	f	2026-06-15 14:05:31.39474+01	2026-06-15 14:05:31.39474+01	2026-06-15 14:05:31.39474+01
49	5	models/veo-3.1-fast-generate-preview	Veo 3.1 fast	google	\N	model	{}	{"id": "models/veo-3.1-fast-generate-preview", "object": "model", "owned_by": "google", "display_name": "Veo 3.1 fast"}	t	f	2026-06-15 14:05:31.39474+01	2026-06-15 14:05:31.39474+01	2026-06-15 14:05:31.39474+01
50	5	models/veo-3.1-lite-generate-preview	Veo 3.1 lite	google	\N	model	{}	{"id": "models/veo-3.1-lite-generate-preview", "object": "model", "owned_by": "google", "display_name": "Veo 3.1 lite"}	t	f	2026-06-15 14:05:31.39474+01	2026-06-15 14:05:31.39474+01	2026-06-15 14:05:31.39474+01
51	5	models/gemini-2.5-flash-native-audio-latest	Gemini 2.5 Flash Native Audio Latest	google	\N	model	{}	{"id": "models/gemini-2.5-flash-native-audio-latest", "object": "model", "owned_by": "google", "display_name": "Gemini 2.5 Flash Native Audio Latest"}	t	f	2026-06-15 14:05:31.39474+01	2026-06-15 14:05:31.39474+01	2026-06-15 14:05:31.39474+01
52	5	models/gemini-2.5-flash-native-audio-preview-09-2025	Gemini 2.5 Flash Native Audio Preview 09-2025	google	\N	model	{}	{"id": "models/gemini-2.5-flash-native-audio-preview-09-2025", "object": "model", "owned_by": "google", "display_name": "Gemini 2.5 Flash Native Audio Preview 09-2025"}	t	f	2026-06-15 14:05:31.39474+01	2026-06-15 14:05:31.39474+01	2026-06-15 14:05:31.39474+01
53	5	models/gemini-2.5-flash-native-audio-preview-12-2025	Gemini 2.5 Flash Native Audio Preview 12-2025	google	\N	model	{}	{"id": "models/gemini-2.5-flash-native-audio-preview-12-2025", "object": "model", "owned_by": "google", "display_name": "Gemini 2.5 Flash Native Audio Preview 12-2025"}	t	f	2026-06-15 14:05:31.39474+01	2026-06-15 14:05:31.39474+01	2026-06-15 14:05:31.39474+01
54	5	models/gemini-3.1-flash-live-preview	Gemini 3.1 Flash Live Preview	google	\N	model	{}	{"id": "models/gemini-3.1-flash-live-preview", "object": "model", "owned_by": "google", "display_name": "Gemini 3.1 Flash Live Preview"}	t	f	2026-06-15 14:05:31.39474+01	2026-06-15 14:05:31.39474+01	2026-06-15 14:05:31.39474+01
55	5	models/gemini-3.5-live-translate-preview	Gemini 3.5 Live Translate Preview	google	\N	model	{}	{"id": "models/gemini-3.5-live-translate-preview", "object": "model", "owned_by": "google", "display_name": "Gemini 3.5 Live Translate Preview"}	t	f	2026-06-15 14:05:31.39474+01	2026-06-15 14:05:31.39474+01	2026-06-15 14:05:31.39474+01
56	5	models/lyria-realtime-exp	Lyria Realtime Experimental	google	\N	model	{}	{"id": "models/lyria-realtime-exp", "object": "model", "owned_by": "google", "display_name": "Lyria Realtime Experimental"}	t	f	2026-06-15 14:05:31.39474+01	2026-06-15 14:05:31.39474+01	2026-06-15 14:05:31.39474+01
\.


--
-- Data for Name: ai_llm_endpoints; Type: TABLE DATA; Schema: gestor_tickets; Owner: -
--

COPY gestor_tickets.ai_llm_endpoints (id, public_uid, name, provider_kind, base_url, models_endpoint_path, chat_endpoint_path, api_key_ciphertext, default_model, is_active, is_default, timeout_seconds, temperature, top_p, max_tokens, enable_thinking, daily_limit, free_quota_notes, retry_policy_json, extra_headers_json, last_models_sync_at, last_validation_at, last_validation_status, last_validation_error_type, last_validation_error_message, created_at, updated_at, reasoning_effort) FROM stdin;
5	c9743e9c-c4f2-4a8d-a5e0-0f3ae49b9064	Google Compatible OpenAI	gemini	https://generativelanguage.googleapis.com/v1beta/openai	/models	/chat/completions	gAAAAABqLyjD4poEeJFonVNTMgaNDsMptjrMa-9XHEq-bIR6X0kg9o0awhMg8sRkuXIT6Ocnwu8PMQqxYat47S_JlW4tPwJXZiQwBwZ4nWpCPml_FcXb0KRZ0AUR5p7oeI7u9VYRqF5ZS45YYQi5YJz6UeTzIt2Oug==	models/gemini-3.5-flash	t	f	60	0.200	1.000	4096	f	\N	\N	{"retry_on": ["timeout", "connection_error", "rate_limited"], "max_retries": 1, "do_not_retry_on": ["auth_error", "quota_exceeded", "model_not_found", "invalid_request"]}	{}	2026-06-15 14:05:31.39474+01	2026-06-15 15:01:50.724561+01	ok	\N	\N	2026-06-14 23:18:43.546383+01	2026-06-15 15:02:03.219272+01	none
\.


--
-- Data for Name: ai_prompt_templates; Type: TABLE DATA; Schema: gestor_tickets; Owner: -
--

COPY gestor_tickets.ai_prompt_templates (id, key, name, description, category, variables_schema_json, active, created_at, updated_at) FROM stdin;
\.


--
-- Data for Name: ai_prompt_versions; Type: TABLE DATA; Schema: gestor_tickets; Owner: -
--

COPY gestor_tickets.ai_prompt_versions (id, template_id, version_number, system_prompt_template, user_prompt_template, response_schema_json, example_input_json, expected_output_example_json, default_llm_params_json, enable_thinking, timeout_seconds, is_active, created_by_user_id, created_at, notes) FROM stdin;
\.


--
-- Data for Name: app_settings; Type: TABLE DATA; Schema: gestor_tickets; Owner: -
--

COPY gestor_tickets.app_settings (id, app_name, app_description, default_timezone, default_archive_root, created_at, updated_at) FROM stdin;
1	gestor-tickets	Webmail colaborativo con IA e integración GLPI	Atlantic/Canary	/data/mail_archive	2026-06-14 10:34:42.847771+01	2026-06-14 10:34:42.847771+01
\.


--
-- Data for Name: audit_log; Type: TABLE DATA; Schema: gestor_tickets; Owner: -
--

COPY gestor_tickets.audit_log (id, account_id, actor_user_id, actor_login_identifier, action, entity_type, entity_id, before_json, after_json, ip_address, user_agent, created_at) FROM stdin;
1	3	1	sistemas-tic	collaborative_account_upsert	collaborative_account	3	null	{"email": "sistemas-tic@gestor-tickets.es", "is_new": true, "glpi_login": "sistemas-tic", "glpi_user_id": 11, "glpi_profile_name": "Supervisor"}	127.0.0.1	python-httpx/0.28.1	2026-06-14 11:34:11.93862+01
2	3	1	sistemas-tic	collaborative_account_upsert	collaborative_account	3	null	{"email": "sistemas-tic@gestor-tickets.es", "is_new": false, "glpi_login": "sistemas-tic", "glpi_user_id": 11, "glpi_profile_name": "Supervisor"}	127.0.0.1	python-httpx/0.28.1	2026-06-14 11:35:27.758718+01
3	3	1	sistemas-tic@gestor-tickets.es	session_login	account_user	1	null	{"role": "owner", "auth_mode": "glpi_account_manager", "glpi_login": "sistemas-tic", "glpi_user_id": 11}	127.0.0.1	python-httpx/0.28.1	2026-06-14 11:37:46.175195+01
4	3	1	sistemas-tic@gestor-tickets.es	session_login	account_user	1	null	{"role": "owner", "auth_mode": "glpi_account_manager", "glpi_login": "sistemas-tic", "glpi_user_id": 11}	127.0.0.1	python-httpx/0.28.1	2026-06-14 11:39:24.701911+01
5	3	1	sistemas-tic@gestor-tickets.es	session_login	account_user	1	null	{"role": "owner", "auth_mode": "glpi_account_manager", "glpi_login": "sistemas-tic", "glpi_user_id": 11}	172.18.0.1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.0.0 Safari/537.36	2026-06-14 11:40:10.931993+01
6	3	1	sistemas-tic@gestor-tickets.es	session_login	account_user	1	null	{"role": "owner", "auth_mode": "glpi_account_manager", "glpi_login": "sistemas-tic", "glpi_user_id": 11}	127.0.0.1	python-httpx/0.28.1	2026-06-14 11:44:26.395318+01
7	3	1	sistemas-tic@gestor-tickets.es	session_login	account_user	1	null	{"role": "owner", "auth_mode": "glpi_account_manager", "glpi_login": "sistemas-tic", "glpi_user_id": 11}	172.18.0.1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.0.0 Safari/537.36	2026-06-14 11:45:17.80062+01
8	3	1	sistemas-tic@gestor-tickets.es	session_login	account_user	1	null	{"role": "owner", "auth_mode": "glpi_account_manager", "glpi_login": "sistemas-tic", "glpi_user_id": 11}	127.0.0.1	python-httpx/0.28.1	2026-06-14 11:48:00.422888+01
9	3	\N	\N	collaborative_account_imap_configured	collaborative_account	3	null	{"email": "sistemas-tic@gestor-tickets.es", "mailbox": "INBOX", "imap_host": "gestor-tickets.es", "imap_port": 993, "imap_use_ssl": true, "imap_username": "sistemas-tic@gestor-tickets.es", "message_count": 0, "readonly_mode": true}	127.0.0.1	python-httpx/0.28.1	2026-06-14 11:54:15.041641+01
10	3	1	sistemas-tic@gestor-tickets.es	session_login	account_user	1	null	{"role": "owner", "auth_mode": "glpi_account_manager", "glpi_login": "sistemas-tic", "glpi_user_id": 11}	127.0.0.1	python-httpx/0.28.1	2026-06-14 11:56:50.891986+01
11	3	1	sistemas-tic@gestor-tickets.es	session_login	account_user	1	null	{"role": "owner", "auth_mode": "glpi_account_manager", "glpi_login": "sistemas-tic", "glpi_user_id": 11}	127.0.0.1	python-httpx/0.28.1	2026-06-14 12:03:04.802994+01
12	3	1	sistemas-tic@gestor-tickets.es	session_login	account_user	1	null	{"role": "owner", "auth_mode": "glpi_account_manager", "glpi_login": "sistemas-tic", "glpi_user_id": 11}	127.0.0.1	python-httpx/0.28.1	2026-06-14 12:06:18.50728+01
13	3	1	sistemas-tic@gestor-tickets.es	session_login	account_user	1	null	{"role": "owner", "auth_mode": "glpi_account_manager", "glpi_login": "sistemas-tic", "glpi_user_id": 11}	127.0.0.1	python-httpx/0.28.1	2026-06-14 12:17:04.899462+01
14	3	1	sistemas-tic@gestor-tickets.es	session_login	account_user	1	null	{"role": "owner", "auth_mode": "glpi_account_manager", "glpi_login": "sistemas-tic", "glpi_user_id": 11}	127.0.0.1	python-httpx/0.28.1	2026-06-14 12:18:56.3641+01
15	3	1	sistemas-tic@gestor-tickets.es	session_login	account_user	1	null	{"role": "owner", "auth_mode": "glpi_account_manager", "glpi_login": "sistemas-tic", "glpi_user_id": 11}	127.0.0.1	python-httpx/0.28.1	2026-06-14 12:18:57.728591+01
16	3	1	sistemas-tic@gestor-tickets.es	session_login	account_user	1	null	{"role": "owner", "auth_mode": "glpi_account_manager", "glpi_login": "sistemas-tic", "glpi_user_id": 11}	127.0.0.1	python-httpx/0.28.1	2026-06-14 12:23:37.310082+01
17	3	1	sistemas-tic@gestor-tickets.es	session_login	account_user	1	null	{"role": "owner", "auth_mode": "glpi_account_manager", "glpi_login": "sistemas-tic", "glpi_user_id": 11}	127.0.0.1	python-httpx/0.28.1	2026-06-14 12:26:54.211778+01
18	3	1	sistemas-tic@gestor-tickets.es	session_login	account_user	1	null	{"role": "owner", "auth_mode": "glpi_account_manager", "glpi_login": "sistemas-tic", "glpi_user_id": 11}	127.0.0.1	python-httpx/0.28.1	2026-06-14 12:31:42.305143+01
19	3	1	sistemas-tic@gestor-tickets.es	session_login	account_user	1	null	{"role": "owner", "auth_mode": "glpi_account_manager", "glpi_login": "sistemas-tic", "glpi_user_id": 11}	127.0.0.1	python-httpx/0.28.1	2026-06-14 12:33:47.204723+01
20	3	1	sistemas-tic@gestor-tickets.es	session_login	account_user	1	null	{"role": "owner", "auth_mode": "glpi_account_manager", "glpi_login": "sistemas-tic", "glpi_user_id": 11}	127.0.0.1	python-httpx/0.28.1	2026-06-14 12:35:58.885692+01
21	3	1	sistemas-tic@gestor-tickets.es	session_login	account_user	1	null	{"role": "owner", "auth_mode": "glpi_account_manager", "glpi_login": "sistemas-tic", "glpi_user_id": 11}	127.0.0.1	python-httpx/0.28.1	2026-06-14 12:38:47.352927+01
22	3	1	sistemas-tic@gestor-tickets.es	session_login	account_user	1	null	{"role": "owner", "auth_mode": "glpi_account_manager", "glpi_login": "sistemas-tic", "glpi_user_id": 11}	127.0.0.1	python-httpx/0.28.1	2026-06-14 12:43:38.556161+01
23	3	1	sistemas-tic@gestor-tickets.es	session_login	account_user	1	null	{"role": "owner", "auth_mode": "glpi_account_manager", "glpi_login": "sistemas-tic", "glpi_user_id": 11}	127.0.0.1	python-httpx/0.28.1	2026-06-14 12:45:28.387434+01
24	3	1	sistemas-tic@gestor-tickets.es	session_login	account_user	1	null	{"role": "owner", "auth_mode": "glpi_account_manager", "glpi_login": "sistemas-tic", "glpi_user_id": 11}	127.0.0.1	python-httpx/0.28.1	2026-06-14 12:46:59.051507+01
25	3	1	sistemas-tic@gestor-tickets.es	session_login	account_user	1	null	{"role": "owner", "auth_mode": "glpi_account_manager", "glpi_login": "sistemas-tic", "glpi_user_id": 11}	127.0.0.1	python-httpx/0.28.1	2026-06-14 13:04:51.41923+01
26	3	1	sistemas-tic@gestor-tickets.es	session_login	account_user	1	null	{"role": "owner", "auth_mode": "glpi_account_manager", "glpi_login": "sistemas-tic", "glpi_user_id": 11}	127.0.0.1	python-httpx/0.28.1	2026-06-14 13:06:27.592036+01
27	3	1	sistemas-tic@gestor-tickets.es	session_login	account_user	1	null	{"role": "owner", "auth_mode": "glpi_account_manager", "glpi_login": "sistemas-tic", "glpi_user_id": 11}	127.0.0.1	python-httpx/0.28.1	2026-06-14 13:09:39.020516+01
28	3	1	sistemas-tic@gestor-tickets.es	session_login	account_user	1	null	{"role": "owner", "auth_mode": "glpi_account_manager", "glpi_login": "sistemas-tic", "glpi_user_id": 11}	127.0.0.1	python-httpx/0.28.1	2026-06-14 13:11:06.628744+01
29	3	1	sistemas-tic@gestor-tickets.es	session_login	account_user	1	null	{"role": "owner", "auth_mode": "glpi_account_manager", "glpi_login": "sistemas-tic", "glpi_user_id": 11}	127.0.0.1	python-httpx/0.28.1	2026-06-14 13:11:08.084744+01
30	3	1	sistemas-tic@gestor-tickets.es	session_login	account_user	1	null	{"role": "owner", "auth_mode": "glpi_account_manager", "glpi_login": "sistemas-tic", "glpi_user_id": 11}	127.0.0.1	python-httpx/0.28.1	2026-06-14 13:12:37.581976+01
31	3	1	sistemas-tic@gestor-tickets.es	session_login	account_user	1	null	{"role": "owner", "auth_mode": "glpi_account_manager", "glpi_login": "sistemas-tic", "glpi_user_id": 11}	127.0.0.1	python-httpx/0.28.1	2026-06-14 13:17:44.143261+01
32	3	1	sistemas-tic@gestor-tickets.es	session_login	account_user	1	null	{"role": "owner", "auth_mode": "glpi_account_manager", "glpi_login": "sistemas-tic", "glpi_user_id": 11}	127.0.0.1	python-httpx/0.28.1	2026-06-14 14:01:08.438211+01
33	3	1	sistemas-tic@gestor-tickets.es	session_login	account_user	1	null	{"role": "owner", "auth_mode": "glpi_account_manager", "glpi_login": "sistemas-tic", "glpi_user_id": 11}	127.0.0.1	python-httpx/0.28.1	2026-06-14 15:10:57.982803+01
34	3	1	sistemas-tic@gestor-tickets.es	session_login	account_user	1	null	{"role": "owner", "auth_mode": "glpi_account_manager", "glpi_login": "sistemas-tic", "glpi_user_id": 11}	127.0.0.1	python-httpx/0.28.1	2026-06-14 15:28:49.935044+01
35	3	1	sistemas-tic@gestor-tickets.es	session_login	account_user	1	null	{"role": "owner", "auth_mode": "glpi_account_manager", "glpi_login": "sistemas-tic", "glpi_user_id": 11}	127.0.0.1	python-httpx/0.28.1	2026-06-14 15:29:41.117288+01
36	3	1	sistemas-tic@gestor-tickets.es	session_login	account_user	1	null	{"role": "owner", "auth_mode": "glpi_account_manager", "glpi_login": "sistemas-tic", "glpi_user_id": 11}	127.0.0.1	python-httpx/0.28.1	2026-06-14 15:42:01.670416+01
37	3	1	sistemas-tic@gestor-tickets.es	session_login	account_user	1	null	{"role": "owner", "auth_mode": "glpi_account_manager", "glpi_login": "sistemas-tic", "glpi_user_id": 11}	127.0.0.1	python-httpx/0.28.1	2026-06-14 16:04:53.614551+01
38	3	2	fase38#sistemas-tic@gestor-tickets.es	session_login	account_user	2	null	{"role": "viewer", "auth_mode": "local_collaborator"}	\N	\N	2026-06-14 19:22:37.140883+01
39	3	2	fase38#sistemas-tic@gestor-tickets.es	session_login	account_user	2	null	{"role": "viewer", "auth_mode": "local_collaborator"}	127.0.0.1	python-httpx/0.28.1	2026-06-14 19:23:30.402173+01
40	3	1	sistemas-tic@gestor-tickets.es	session_login	account_user	1	null	{"role": "owner", "auth_mode": "glpi_account_manager", "glpi_login": "sistemas-tic", "glpi_user_id": 11}	127.0.0.1	python-httpx/0.28.1	2026-06-14 19:24:02.587491+01
41	3	1	sistemas-tic@gestor-tickets.es	session_login	account_user	1	null	{"role": "owner", "auth_mode": "glpi_account_manager", "glpi_login": "sistemas-tic", "glpi_user_id": 11}	127.0.0.1	python-httpx/0.28.1	2026-06-14 22:10:14.384237+01
42	3	1	sistemas-tic@gestor-tickets.es	session_login	account_user	1	null	{"role": "owner", "auth_mode": "glpi_account_manager", "glpi_login": "sistemas-tic", "glpi_user_id": 11}	127.0.0.1	python-httpx/0.28.1	2026-06-14 22:55:55.00597+01
43	3	1	sistemas-tic@gestor-tickets.es	session_login	account_user	1	null	{"role": "owner", "auth_mode": "glpi_account_manager", "glpi_login": "sistemas-tic", "glpi_user_id": 11}	127.0.0.1	python-httpx/0.28.1	2026-06-14 22:56:46.636926+01
44	3	1	sistemas-tic@gestor-tickets.es	session_login	account_user	1	null	{"role": "owner", "auth_mode": "glpi_account_manager", "glpi_login": "sistemas-tic", "glpi_user_id": 11}	127.0.0.1	python-httpx/0.28.1	2026-06-14 22:56:47.012666+01
45	3	1	sistemas-tic@gestor-tickets.es	session_login	account_user	1	null	{"role": "owner", "auth_mode": "glpi_account_manager", "glpi_login": "sistemas-tic", "glpi_user_id": 11}	127.0.0.1	python-httpx/0.28.1	2026-06-14 22:58:16.717704+01
46	3	1	sistemas-tic@gestor-tickets.es	session_login	account_user	1	null	{"role": "owner", "auth_mode": "glpi_account_manager", "glpi_login": "sistemas-tic", "glpi_user_id": 11}	127.0.0.1	python-httpx/0.28.1	2026-06-14 22:58:17.196952+01
47	3	1	sistemas-tic@gestor-tickets.es	session_login	account_user	1	null	{"role": "owner", "auth_mode": "glpi_account_manager", "glpi_login": "sistemas-tic", "glpi_user_id": 11}	127.0.0.1	python-httpx/0.28.1	2026-06-14 22:58:58.134781+01
48	3	1	sistemas-tic@gestor-tickets.es	session_login	account_user	1	null	{"role": "owner", "auth_mode": "glpi_account_manager", "glpi_login": "sistemas-tic", "glpi_user_id": 11}	127.0.0.1	python-httpx/0.28.1	2026-06-14 22:58:58.499015+01
49	3	1	sistemas-tic@gestor-tickets.es	session_login	account_user	1	null	{"role": "owner", "auth_mode": "glpi_account_manager", "glpi_login": "sistemas-tic", "glpi_user_id": 11}	127.0.0.1	python-httpx/0.28.1	2026-06-14 23:13:46.95231+01
50	3	1	sistemas-tic@gestor-tickets.es	session_login	account_user	1	null	{"role": "owner", "auth_mode": "glpi_account_manager", "glpi_login": "sistemas-tic", "glpi_user_id": 11}	127.0.0.1	python-httpx/0.28.1	2026-06-14 23:15:01.952932+01
51	3	1	sistemas-tic@gestor-tickets.es	session_login	account_user	1	null	{"role": "owner", "auth_mode": "glpi_account_manager", "glpi_login": "sistemas-tic", "glpi_user_id": 11}	127.0.0.1	python-httpx/0.28.1	2026-06-14 23:15:02.350909+01
52	3	1	sistemas-tic@gestor-tickets.es	session_login	account_user	1	null	{"role": "owner", "auth_mode": "glpi_account_manager", "glpi_login": "sistemas-tic", "glpi_user_id": 11}	172.18.0.1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.0.0 Safari/537.36 Edg/149.0.0.0	2026-06-15 06:22:52.364287+01
53	3	1	sistemas-tic@gestor-tickets.es	session_login	account_user	1	null	{"role": "owner", "auth_mode": "glpi_account_manager", "glpi_login": "sistemas-tic", "glpi_user_id": 11}	172.18.0.1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36	2026-06-15 08:56:01.717444+01
54	3	1	sistemas-tic@gestor-tickets.es	session_login	account_user	1	null	{"role": "owner", "auth_mode": "glpi_account_manager", "glpi_login": "sistemas-tic", "glpi_user_id": 11}	127.0.0.1	python-httpx/0.28.1	2026-06-15 13:55:18.798498+01
55	3	1	sistemas-tic@gestor-tickets.es	session_login	account_user	1	null	{"role": "owner", "auth_mode": "glpi_account_manager", "glpi_login": "sistemas-tic", "glpi_user_id": 11}	127.0.0.1	python-httpx/0.28.1	2026-06-15 14:16:18.353328+01
56	3	1	sistemas-tic@gestor-tickets.es	session_login	account_user	1	null	{"role": "owner", "auth_mode": "glpi_account_manager", "glpi_login": "sistemas-tic", "glpi_user_id": 11}	127.0.0.1	python-httpx/0.28.1	2026-06-15 14:56:49.514768+01
57	3	1	sistemas-tic@gestor-tickets.es	session_login	account_user	1	null	{"role": "owner", "auth_mode": "glpi_account_manager", "glpi_login": "sistemas-tic", "glpi_user_id": 11}	127.0.0.1	python-httpx/0.28.1	2026-06-17 16:40:37.480197+01
58	3	1	sistemas-tic@gestor-tickets.es	session_login	account_user	1	null	{"role": "owner", "auth_mode": "glpi_account_manager", "glpi_login": "sistemas-tic", "glpi_user_id": 11}	127.0.0.1	python-httpx/0.28.1	2026-06-17 16:41:07.330338+01
60	3	1	sistemas-tic@gestor-tickets.es	session_login	account_user	1	null	{"role": "owner", "auth_mode": "glpi_account_manager", "glpi_login": "sistemas-tic", "glpi_user_id": 11}	127.0.0.1	python-httpx/0.28.1	2026-06-17 16:58:00.093209+01
59	3	1	sistemas-tic@gestor-tickets.es	session_login	account_user	1	null	{"role": "owner", "auth_mode": "glpi_account_manager", "glpi_login": "sistemas-tic", "glpi_user_id": 11}	127.0.0.1	python-httpx/0.28.1	2026-06-17 16:42:19.916282+01
\.


--
-- Data for Name: collaborative_accounts; Type: TABLE DATA; Schema: gestor_tickets; Owner: -
--

COPY gestor_tickets.collaborative_accounts (id, public_uid, email, display_name, status, glpi_instance_id, glpi_user_id, glpi_login, glpi_profile_name, glpi_entity_id, glpi_group_id, last_glpi_validation_at, imap_host, imap_username, imap_password_ciphertext, imap_port, imap_use_ssl, imap_last_validated_at, archive_root, archive_subdir, ingestion_enabled, created_by_login, notes, created_at, updated_at) FROM stdin;
3	a86d763e-a402-4194-a284-3a3ae1e523f1	sistemas-tic@gestor-tickets.es	Sistemas TIC	active	3	11	sistemas-tic	Supervisor	\N	\N	2026-06-17 16:58:00.424523+01	gestor-tickets.es	sistemas-tic@gestor-tickets.es	gAAAAABqLohXsEAZg5ULUJbE3GkZ4vbvPgDG3TbnZA7S6B0Kq6YnC5fJfIoLBxgVclqwN50-lgm6oSVTyseb4mYmbtC-r7KaPg==	993	t	2026-06-14 11:54:15.90182+01	/data/mail_archive	sistemas-tic__at__gestor-tickets.es	t	sistemas-tic	Cuenta creada desde API interna de gestor-tickets.	2026-06-14 11:34:11.93862+01	2026-06-17 16:58:00.424523+01
\.


--
-- Data for Name: email_ai_processing; Type: TABLE DATA; Schema: gestor_tickets; Owner: -
--

COPY gestor_tickets.email_ai_processing (id, email_message_id, prompt_version_id, llm_call_history_id, status, body_new, body_new_found, body_new_is_too_short, needs_thread_context, extraction_confidence, summary_json, tipo_correo, accion_sugerida, prioridad_sugerida, requiere_revision_humana, processed_at, error_message, created_at, updated_at) FROM stdin;
\.


--
-- Data for Name: email_attachments; Type: TABLE DATA; Schema: gestor_tickets; Owner: -
--

COPY gestor_tickets.email_attachments (id, email_message_id, filename, content_type, size_bytes, content_id, is_inline, storage_path, sha256, created_at) FROM stdin;
\.


--
-- Data for Name: email_message_occurrences; Type: TABLE DATA; Schema: gestor_tickets; Owner: -
--

COPY gestor_tickets.email_message_occurrences (id, email_message_id, account_id, ingestion_run_id, source_mailbox_email, folder_name, folder_kind, imap_uid, imap_uidvalidity, direction, flags_json, unread_at_import, first_seen_at, last_seen_at) FROM stdin;
4	4	3	46	sistemas-tic@gestor-tickets.es	SIMULATED	other	sim-1	simulated_uidvalidity	inbound	[]	t	2026-06-14 16:17:28.128027+01	2026-06-14 16:17:28.159066+01
5	5	3	48	sistemas-tic@gestor-tickets.es	SIMULATED	other	sim-2	simulated_uidvalidity	inbound	[]	t	2026-06-14 16:23:40.071588+01	2026-06-14 16:23:40.126362+01
6	7	3	\N	usuario.personal.simulado@gestor-tickets.es	PERSONAL_SIMULATED	other	personal-sim-1	personal_simulated_uidvalidity	inbound	[]	t	2026-06-14 19:35:11.715095+01	2026-06-14 19:36:45.593002+01
8	8	3	\N	usuario.personal.simulado@gestor-tickets.es	PERSONAL_SIMULATED	other	personal-sim-2	personal_simulated_uidvalidity	inbound	[]	t	2026-06-14 19:38:14.335207+01	2026-06-14 19:38:14.335207+01
9	6	3	\N	usuario.personal.simulado@gestor-tickets.es	PERSONAL_SIMULATED	other	personal-sim-0	personal_simulated_uidvalidity	inbound	[]	t	2026-06-14 19:39:11.808766+01	2026-06-14 19:39:11.808766+01
1	1	3	1	sistemas-tic@gestor-tickets.es	INBOX	inbox	1	unknown_uidvalidity	inbound	["\\\\Recent"]	t	2026-06-14 12:14:53.129969+01	2026-06-17 17:19:34.154908+01
\.


--
-- Data for Name: email_messages; Type: TABLE DATA; Schema: gestor_tickets; Owner: -
--

COPY gestor_tickets.email_messages (id, system_uid, account_id, message_id_header, eml_sha256, raw_headers_sha256, eml_storage_path, eml_filename, size_bytes, source, imported_from_personal_account_id, transferred_by_user_id, transferred_at, original_imap_account, original_imap_folder, original_imap_uid, original_imap_uidvalidity, source_description, subject, subject_normalized, from_email, from_name, sent_at, received_at, direction, has_attachments, body_text_preview, archived_at, created_at, updated_at) FROM stdin;
7	09738a0e-924f-44b7-8529-dfe4de8f664f	3	<178146220559.460.17970706776107867072@gestor-tickets.es>	e062020d9e82b7eee9156d7d8356ec5a4ceb605a73dca061a5131a9a0647c52b	0809435456f28aa5ef37725cb95e70988a495413e532f7fefca34c93d6bc25c6	/data/mail_archive/sistemas-tic__at__gestor-tickets.es/personal_simulated/personal_simulated_uidvalidity/personal-sim-1_e062020d9e82b7ee.eml	personal-sim-1_e062020d9e82b7ee.eml	467	personal_transfer	1	1	2026-06-14 19:36:45.593002+01	usuario.personal.simulado@gestor-tickets.es	PERSONAL_SIMULATED	personal-sim-1	personal_simulated_uidvalidity	Transferencia voluntaria simulada desde cuenta personal sin tocar IMAP.	Re: Solicitud de asistencia técnica	solicitud de asistencia técnica	usuario.personal.simulado@gestor-tickets.es	\N	2026-06-14 19:36:45+01	2026-06-14 19:36:45.593002+01	inbound	f	Segunda transferencia personal simulada para validar source_mailbox_email de origen personal.	2026-06-14 19:36:45.593002+01	2026-06-14 19:36:45.593002+01	2026-06-14 19:36:45.593002+01
1	e6b9a3d0-7aa0-4886-b70a-4ca3e001762e	3	<d4581ac5a147271ca09ccad30656e326@gestor-tickets.es>	a472fbf966c2908d37348d79331c09a424a1fa12075deed9958ab68f3035cdfa	54ee002c014ae5c35c48b131af234bb4aa9aa5c2039b4f0c9de90797421133a1	/data/mail_archive/sistemas-tic__at__gestor-tickets.es/inbox/unknown_uidvalidity/1_a472fbf966c2908d.eml	1_a472fbf966c2908d.eml	3620	collaborative_ingestion	\N	\N	\N	sistemas-tic@gestor-tickets.es	INBOX	1	unknown_uidvalidity	Archivado manual seguro desde preview IMAP BODY.PEEK[].	Solicitud de asistencia técnica	solicitud de asistencia técnica	usuario.demo@gestor-tickets.es	\N	2026-06-14 12:02:32+01	2026-06-14 12:14:53.129969+01	inbound	f	Buenos días, tengo un problema en mi ordenador, cuando trató de acceder a mi carpeta el explorador se cierra por completo sin mostrar mensaje de error alguno. Qué debo hacer? Saludos.	2026-06-14 12:14:53.129969+01	2026-06-14 12:14:53.129969+01	2026-06-14 12:20:40.315461+01
4	ba94bfdb-0bba-497c-867c-81a418c7848f	3	<178145024813.300.11694143536275606479@gestor-tickets.es>	f5d7a0db3d1f3627b2478c529af9dd8f5c29adeab75cb8b861bb29387d9aaf94	270ca8e1a56e14f6f7dd899e1a449c8dc643396872f7f480ce3d98f155eb93d3	/data/mail_archive/sistemas-tic__at__gestor-tickets.es/simulated/simulated_uidvalidity/sim-1_f5d7a0db3d1f3627.eml	sim-1_f5d7a0db3d1f3627.eml	552	collaborative_ingestion	\N	\N	\N	sistemas-tic@gestor-tickets.es	SIMULATED	sim-1	simulated_uidvalidity	Archivado manual seguro desde preview IMAP BODY.PEEK[].	Re: Solicitud de asistencia técnica	solicitud de asistencia técnica	usuario.demo@gestor-tickets.es	\N	2026-06-14 16:17:28+01	2026-06-14 16:17:28.128027+01	inbound	f	Buenos días, añado información adicional para la solicitud de asistencia técnica. Esta respuesta se ha generado como simulación local sin tocar el buzón IMAP.	2026-06-14 16:17:28.128027+01	2026-06-14 16:17:28.128027+01	2026-06-14 16:17:28.128027+01
5	f653e118-2792-49a1-a669-3b395a59c832	3	<178145062010.327.16903024796889684146@gestor-tickets.es>	8bdfad2dca6cbc6c9badae42d821b35cd4897cbf9f55e84b6660b32b19ed7fa6	b8c74cd53f592d9d58d887d58d38cb6d77f0ee3087d020d4c5c3bdd24a6baf95	/data/mail_archive/sistemas-tic__at__gestor-tickets.es/simulated/simulated_uidvalidity/sim-2_8bdfad2dca6cbc6c.eml	sim-2_8bdfad2dca6cbc6c.eml	422	collaborative_ingestion	\N	\N	\N	sistemas-tic@gestor-tickets.es	SIMULATED	sim-2	simulated_uidvalidity	Archivado manual seguro desde preview IMAP BODY.PEEK[].	Re: Solicitud de asistencia técnica	solicitud de asistencia técnica	usuario.demo@gestor-tickets.es	\N	2026-06-14 16:23:40+01	2026-06-14 16:23:40.071588+01	inbound	f	Segunda simulación local para validar detección automática de job activo.	2026-06-14 16:23:40.071588+01	2026-06-14 16:23:40.071588+01	2026-06-14 16:23:40.071588+01
8	ebdf9826-e9a7-48f5-a87e-b3c1769a4ebb	3	<178146229434.481.6551179428778421131@gestor-tickets.es>	c1a9f98bffb76b4fda60c4e29a097e7dd0c52d9d76eb912b621543dc4bfff82a	ed57050193c3aa24161d5dc191a4ee5636ae6e427f93a787fe68e6c172d08ba4	/data/mail_archive/sistemas-tic__at__gestor-tickets.es/personal_simulated/personal_simulated_uidvalidity/personal-sim-2_c1a9f98bffb76b4f.eml	personal-sim-2_c1a9f98bffb76b4f.eml	452	personal_transfer	1	1	2026-06-14 19:38:14.335207+01	usuario.personal.simulado@gestor-tickets.es	PERSONAL_SIMULATED	personal-sim-2	personal_simulated_uidvalidity	Transferencia voluntaria simulada desde cuenta personal sin tocar IMAP.	Re: Solicitud de asistencia técnica	solicitud de asistencia técnica	usuario.personal.simulado@gestor-tickets.es	\N	2026-06-14 19:38:14+01	2026-06-14 19:38:14.335207+01	inbound	f	Tercera transferencia personal simulada para validar incremento de UID por log.	2026-06-14 19:38:14.335207+01	2026-06-14 19:38:14.335207+01	2026-06-14 19:38:14.335207+01
6	99ae59d5-09c0-4917-b38a-addba1b4113b	3	<178146211172.440.16060326031137883735@gestor-tickets.es>	0c2f1ec1f395217071bf29de99be7203738e7870032ffcf56fed9fc3f034f7b4	986a7c1b2a77be8709bf044ab1bc89357ed29e9f64aec1608b4ac9870656bacc	/data/mail_archive/sistemas-tic__at__gestor-tickets.es/personal_simulated/personal_simulated_uidvalidity/personal-sim-1_0c2f1ec1f3952170.eml	personal-sim-1_0c2f1ec1f3952170.eml	502	personal_transfer	1	1	2026-06-14 19:35:11.715095+01	usuario.personal.simulado@gestor-tickets.es	PERSONAL_SIMULATED	personal-sim-0	personal_simulated_uidvalidity	Transferencia voluntaria simulada desde cuenta personal sin tocar IMAP.	Re: Solicitud de asistencia técnica	solicitud de asistencia técnica	usuario.personal.simulado@gestor-tickets.es	\N	2026-06-14 19:35:11+01	2026-06-14 19:35:11.715095+01	inbound	f	Mensaje personal simulado transferido voluntariamente al sistema colaborativo. No se ha tocado ningún buzón IMAP real.	2026-06-14 19:35:11.715095+01	2026-06-14 19:35:11.715095+01	2026-06-14 19:39:11.808766+01
\.


--
-- Data for Name: email_recipients; Type: TABLE DATA; Schema: gestor_tickets; Owner: -
--

COPY gestor_tickets.email_recipients (id, email_message_id, recipient_type, email, display_name, "position") FROM stdin;
3	1	to	sistemas-tic@gestor-tickets.es	\N	0
4	4	to	sistemas-tic@gestor-tickets.es	\N	0
5	5	to	sistemas-tic@gestor-tickets.es	\N	0
6	6	to	sistemas-tic@gestor-tickets.es	\N	0
7	7	to	sistemas-tic@gestor-tickets.es	\N	0
8	8	to	sistemas-tic@gestor-tickets.es	\N	0
\.


--
-- Data for Name: email_thread_members; Type: TABLE DATA; Schema: gestor_tickets; Owner: -
--

COPY gestor_tickets.email_thread_members (id, thread_id, email_message_id, position_asc, status, added_by_user_id, added_reason, added_at, removed_by_user_id, removed_reason, removed_at, moved_from_thread_id, moved_to_thread_id) FROM stdin;
1	1	1	0	active	1	Creación manual desde correo archivado.	2026-06-14 12:23:36.187832+01	\N	\N	\N	\N	\N
4	1	4	1	active	\N	Creación por simulación local de ingesta.	2026-06-14 16:17:28.145513+01	\N	\N	\N	\N	\N
5	1	5	2	active	\N	Creación por simulación local de ingesta.	2026-06-14 16:23:40.113058+01	\N	\N	\N	\N	\N
6	1	6	3	active	1	Creación por transferencia voluntaria desde cuenta personal simulada.	2026-06-14 19:35:11.737002+01	\N	\N	\N	\N	\N
7	1	7	4	active	1	Creación por transferencia voluntaria desde cuenta personal simulada.	2026-06-14 19:36:45.611557+01	\N	\N	\N	\N	\N
8	1	8	5	active	1	Creación por transferencia voluntaria desde cuenta personal simulada.	2026-06-14 19:38:14.356618+01	\N	\N	\N	\N	\N
\.


--
-- Data for Name: glpi_api_operations; Type: TABLE DATA; Schema: gestor_tickets; Owner: -
--

COPY gestor_tickets.glpi_api_operations (id, account_id, glpi_instance_id, glpi_ticket_cache_id, operation_type, requested_by_user_id, request_payload_json, response_status_code, response_json, success, error_message, created_at) FROM stdin;
1	3	3	1	create_ticket_from_thread	1	{"title": "Solicitud de asistencia técnica", "thread_id": 1, "content_preview": "Ticket creado desde gestor-tickets.\\n\\nHilo interno: #1\\nAsunto del hilo: Solicitud de asistencia técnica\\nUID del hilo: 7c69ba87-5dd4-4d16-af4a-bdf90af698e9\\n\\nResumen cronológico de correos archivados:\\n\\n1. Solicitud de asistencia técnica\\n   Fecha: 2026-06-14 12:02:32+01:00\\n   De: usuario.demo@gestor-tickets.es\\n   Carpeta IMAP: INBOX\\n   UID IMAP: 1\\n\\n   Texto del correo:\\n   Buenos días, tengo un problema en mi ordenador, cuando trató de acceder a mi carpeta el explorador se cierra por completo sin mos"}	201	{"id": 2, "message": "Item successfully added: Solicitud de asistencia técnica"}	t	\N	2026-06-14 12:31:40.495581+01
2	3	3	1	refresh_ticket_cache	1	{"operation": "refresh_ticket_cache", "glpi_ticket_id": 2, "ticket_cache_id": 1}	200	{"id": 2, "date": "2026-06-14 11:31:40", "name": "Solicitud de asistencia técnica", "type": 1, "links": [{"rel": "Entity", "href": "http://localhost/api.php/v1/Entity/0"}, {"rel": "User", "href": "http://localhost/api.php/v1/User/11"}, {"rel": "User", "href": "http://localhost/api.php/v1/User/11"}, {"rel": "RequestType", "href": "http://localhost/api.php/v1/RequestType/1"}, {"rel": "Document_Item", "href": "http://localhost/api.php/v1/Ticket/2/Document_Item/"}, {"rel": "TicketTask", "href": "http://localhost/api.php/v1/Ticket/2/TicketTask/"}, {"rel": "TicketValidation", "href": "http://localhost/api.php/v1/Ticket/2/TicketValidation/"}, {"rel": "TicketCost", "href": "http://localhost/api.php/v1/Ticket/2/TicketCost/"}, {"rel": "Problem_Ticket", "href": "http://localhost/api.php/v1/Ticket/2/Problem_Ticket/"}, {"rel": "Change_Ticket", "href": "http://localhost/api.php/v1/Ticket/2/Change_Ticket/"}, {"rel": "Ticket_Ticket", "href": "http://localhost/api.php/v1/Ticket/2/Ticket_Ticket/"}, {"rel": "Item_Ticket", "href": "http://localhost/api.php/v1/Ticket/2/Item_Ticket/"}, {"rel": "ITILSolution", "href": "http://localhost/api.php/v1/Ticket/2/ITILSolution/"}, {"rel": "ITILFollowup", "href": "http://localhost/api.php/v1/Ticket/2/ITILFollowup/"}, {"rel": "Ticket_User", "href": "http://localhost/api.php/v1/Ticket/2/Ticket_User/"}, {"rel": "Group_Ticket", "href": "http://localhost/api.php/v1/Ticket/2/Group_Ticket/"}, {"rel": "Supplier_Ticket", "href": "http://localhost/api.php/v1/Ticket/2/Supplier_Ticket/"}], "impact": 3, "status": 1, "content": "Ticket creado desde gestor-tickets.\\n\\nHilo interno: #1\\nAsunto del hilo: Solicitud de asistencia técnica\\nUID del hilo: 7c69ba87-5dd4-4d16-af4a-bdf90af698e9\\n\\nResumen cronológico de correos archivados:\\n\\n1. Solicitud de asistencia técnica\\n   Fecha: 2026-06-14 12:02:32+01:00\\n   De: usuario.demo@gestor-tickets.es\\n   Carpeta IMAP: INBOX\\n   UID IMAP: 1\\n\\n   Texto del correo:\\n   Buenos días, tengo un problema en mi ordenador, cuando trató de acceder a mi carpeta el explorador se cierra por completo sin mostrar mensaje de error alguno. Qué debo hacer? Saludos.\\n\\n---\\nNota: el correo original .eml queda archivado en gestor-tickets.", "urgency": 3, "date_mod": "2026-06-14 11:31:40", "priority": 3, "closedate": null, "solvedate": null, "actiontime": 0, "externalid": null, "is_deleted": 0, "entities_id": 0, "olas_id_tto": 0, "olas_id_ttr": 0, "slas_id_tto": 0, "slas_id_ttr": 0, "time_to_own": null, "locations_id": 0, "date_creation": "2026-06-14 11:31:40", "requesttypes_id": 1, "time_to_resolve": null, "close_delay_stat": 0, "olalevels_id_ttr": 0, "slalevels_id_ttr": 0, "solve_delay_stat": 0, "waiting_duration": 0, "global_validation": 1, "itilcategories_id": 0, "begin_waiting_date": null, "ola_tto_begin_date": null, "ola_ttr_begin_date": null, "tickettemplates_id": 0, "users_id_recipient": 11, "takeintoaccountdate": null, "internal_time_to_own": null, "ola_waiting_duration": 0, "sla_waiting_duration": 0, "users_id_lastupdater": 11, "internal_time_to_resolve": null, "takeintoaccount_delay_stat": 0}	t	\N	2026-06-14 12:35:57.59615+01
3	3	3	1	refresh_ticket_cache	1	{"operation": "refresh_ticket_cache", "glpi_ticket_id": 2, "ticket_cache_id": 1}	200	{"id": 2, "date": "2026-06-14 11:31:40", "name": "Solicitud de asistencia técnica", "type": 1, "links": [{"rel": "Entity", "href": "http://localhost/api.php/v1/Entity/0"}, {"rel": "User", "href": "http://localhost/api.php/v1/User/11"}, {"rel": "User", "href": "http://localhost/api.php/v1/User/11"}, {"rel": "RequestType", "href": "http://localhost/api.php/v1/RequestType/1"}, {"rel": "Document_Item", "href": "http://localhost/api.php/v1/Ticket/2/Document_Item/"}, {"rel": "TicketTask", "href": "http://localhost/api.php/v1/Ticket/2/TicketTask/"}, {"rel": "TicketValidation", "href": "http://localhost/api.php/v1/Ticket/2/TicketValidation/"}, {"rel": "TicketCost", "href": "http://localhost/api.php/v1/Ticket/2/TicketCost/"}, {"rel": "Problem_Ticket", "href": "http://localhost/api.php/v1/Ticket/2/Problem_Ticket/"}, {"rel": "Change_Ticket", "href": "http://localhost/api.php/v1/Ticket/2/Change_Ticket/"}, {"rel": "Ticket_Ticket", "href": "http://localhost/api.php/v1/Ticket/2/Ticket_Ticket/"}, {"rel": "Item_Ticket", "href": "http://localhost/api.php/v1/Ticket/2/Item_Ticket/"}, {"rel": "ITILSolution", "href": "http://localhost/api.php/v1/Ticket/2/ITILSolution/"}, {"rel": "ITILFollowup", "href": "http://localhost/api.php/v1/Ticket/2/ITILFollowup/"}, {"rel": "Ticket_User", "href": "http://localhost/api.php/v1/Ticket/2/Ticket_User/"}, {"rel": "Group_Ticket", "href": "http://localhost/api.php/v1/Ticket/2/Group_Ticket/"}, {"rel": "Supplier_Ticket", "href": "http://localhost/api.php/v1/Ticket/2/Supplier_Ticket/"}], "impact": 3, "status": 1, "content": "Ticket creado desde gestor-tickets.\\n\\nHilo interno: #1\\nAsunto del hilo: Solicitud de asistencia técnica\\nUID del hilo: 7c69ba87-5dd4-4d16-af4a-bdf90af698e9\\n\\nResumen cronológico de correos archivados:\\n\\n1. Solicitud de asistencia técnica\\n   Fecha: 2026-06-14 12:02:32+01:00\\n   De: usuario.demo@gestor-tickets.es\\n   Carpeta IMAP: INBOX\\n   UID IMAP: 1\\n\\n   Texto del correo:\\n   Buenos días, tengo un problema en mi ordenador, cuando trató de acceder a mi carpeta el explorador se cierra por completo sin mostrar mensaje de error alguno. Qué debo hacer? Saludos.\\n\\n---\\nNota: el correo original .eml queda archivado en gestor-tickets.", "urgency": 3, "date_mod": "2026-06-14 11:31:40", "priority": 3, "closedate": null, "solvedate": null, "actiontime": 0, "externalid": null, "is_deleted": 0, "entities_id": 0, "olas_id_tto": 0, "olas_id_ttr": 0, "slas_id_tto": 0, "slas_id_ttr": 0, "time_to_own": null, "locations_id": 0, "date_creation": "2026-06-14 11:31:40", "requesttypes_id": 1, "time_to_resolve": null, "close_delay_stat": 0, "olalevels_id_ttr": 0, "slalevels_id_ttr": 0, "solve_delay_stat": 0, "waiting_duration": 0, "global_validation": 1, "itilcategories_id": 0, "begin_waiting_date": null, "ola_tto_begin_date": null, "ola_ttr_begin_date": null, "tickettemplates_id": 0, "users_id_recipient": 11, "takeintoaccountdate": null, "internal_time_to_own": null, "ola_waiting_duration": 0, "sla_waiting_duration": 0, "users_id_lastupdater": 11, "internal_time_to_resolve": null, "takeintoaccount_delay_stat": 0}	t	\N	2026-06-14 12:35:59.22076+01
4	3	3	1	add_ticket_followup	1	{"is_private": false, "glpi_ticket_id": 2, "content_preview": "Seguimiento de prueba añadido desde gestor-tickets v0.1.21.", "ticket_cache_id": 1}	201	{"id": 1, "message": ""}	t	\N	2026-06-14 12:38:44.939563+01
5	3	3	1	attach_email_eml	1	{"filename": "ticket_2_email_1_Solicitud_de_asistencia_técnica.eml", "eml_sha256": "a472fbf966c2908d37348d79331c09a424a1fa12075deed9958ab68f3035cdfa", "size_bytes": 3620, "glpi_ticket_id": 2, "ticket_cache_id": 1, "email_message_id": 1}	201	{"link_response": {"id": 1, "message": "Item successfully added: Document item - ID 1"}, "upload_response": {"id": 1, "message": "Item successfully added: Correo original email_messages.id=1", "upload_result": {"filename": [{"id": "docfilename1107029097", "name": "6a2e93e859cef3.23923457ticket_2_email_1_Solicitud_de_asistencia_técnica.eml", "size": 3620, "type": "message/rfc822", "error": "Filetype not allowed", "prefix": "6a2e93e859cef3.23923457", "display": "ticket_2_email_1_Solicitud_de_asistencia_técnica.eml", "filesize": "3.54 KiB"}]}}, "glpi_document_id": 1, "glpi_document_item_id": 1}	t	\N	2026-06-14 12:43:36.067943+01
7	3	3	1	auto_sync_ingested_email	\N	{"source": "mail_ingestion", "thread_id": 1, "email_message_id": 4}	\N	{"reason": "No hay credencial GLPI operacional configurada para ejecución automática.", "local_link_created": true, "external_eml_attached": false, "external_followup_created": false}	t	\N	2026-06-14 16:17:28.153557+01
8	3	3	1	auto_sync_ingested_email	\N	{"source": "mail_ingestion", "thread_id": 1, "email_message_id": 5}	\N	{"reason": "No hay credencial GLPI operacional configurada para ejecución automática.", "local_link_created": true, "external_eml_attached": false, "external_followup_created": false}	t	\N	2026-06-14 16:23:40.121101+01
9	3	3	1	auto_sync_ingested_email	1	{"source": "mail_ingestion", "thread_id": 1, "email_message_id": 6}	\N	{"reason": "No hay credencial GLPI operacional configurada para ejecución automática.", "local_link_created": true, "external_eml_attached": false, "external_followup_created": false}	t	\N	2026-06-14 19:35:11.744791+01
10	3	3	1	auto_sync_ingested_email	1	{"source": "mail_ingestion", "thread_id": 1, "email_message_id": 7}	\N	{"reason": "No hay credencial GLPI operacional configurada para ejecución automática.", "local_link_created": true, "external_eml_attached": false, "external_followup_created": false}	t	\N	2026-06-14 19:36:45.619658+01
11	3	3	1	auto_sync_ingested_email	1	{"source": "mail_ingestion", "thread_id": 1, "email_message_id": 8}	\N	{"reason": "No hay credencial GLPI operacional configurada para ejecución automática.", "local_link_created": true, "external_eml_attached": false, "external_followup_created": false}	t	\N	2026-06-14 19:38:14.364145+01
\.


--
-- Data for Name: glpi_instances; Type: TABLE DATA; Schema: gestor_tickets; Owner: -
--

COPY gestor_tickets.glpi_instances (id, name, base_url, app_token_ciphertext, default_entity_id, default_group_id, verify_tls, active, notes, created_at, updated_at) FROM stdin;
3	GLPI principal	http://glpi	\N	\N	\N	t	t	Instancia GLPI configurada desde .env	2026-06-14 11:34:11.93862+01	2026-06-14 11:34:11.93862+01
\.


--
-- Data for Name: glpi_ticket_cache; Type: TABLE DATA; Schema: gestor_tickets; Owner: -
--

COPY gestor_tickets.glpi_ticket_cache (id, account_id, glpi_instance_id, glpi_ticket_id, title, status, priority, urgency, impact, entity_id, group_id, requester_json, assignee_json, raw_json, last_sync_at, created_at, updated_at) FROM stdin;
1	3	3	2	Solicitud de asistencia técnica	1	3	3	3	0	\N	[]	[]	{"id": 2, "date": "2026-06-14 11:31:40", "name": "Solicitud de asistencia técnica", "type": 1, "links": [{"rel": "Entity", "href": "http://localhost/api.php/v1/Entity/0"}, {"rel": "User", "href": "http://localhost/api.php/v1/User/11"}, {"rel": "User", "href": "http://localhost/api.php/v1/User/11"}, {"rel": "RequestType", "href": "http://localhost/api.php/v1/RequestType/1"}, {"rel": "Document_Item", "href": "http://localhost/api.php/v1/Ticket/2/Document_Item/"}, {"rel": "TicketTask", "href": "http://localhost/api.php/v1/Ticket/2/TicketTask/"}, {"rel": "TicketValidation", "href": "http://localhost/api.php/v1/Ticket/2/TicketValidation/"}, {"rel": "TicketCost", "href": "http://localhost/api.php/v1/Ticket/2/TicketCost/"}, {"rel": "Problem_Ticket", "href": "http://localhost/api.php/v1/Ticket/2/Problem_Ticket/"}, {"rel": "Change_Ticket", "href": "http://localhost/api.php/v1/Ticket/2/Change_Ticket/"}, {"rel": "Ticket_Ticket", "href": "http://localhost/api.php/v1/Ticket/2/Ticket_Ticket/"}, {"rel": "Item_Ticket", "href": "http://localhost/api.php/v1/Ticket/2/Item_Ticket/"}, {"rel": "ITILSolution", "href": "http://localhost/api.php/v1/Ticket/2/ITILSolution/"}, {"rel": "ITILFollowup", "href": "http://localhost/api.php/v1/Ticket/2/ITILFollowup/"}, {"rel": "Ticket_User", "href": "http://localhost/api.php/v1/Ticket/2/Ticket_User/"}, {"rel": "Group_Ticket", "href": "http://localhost/api.php/v1/Ticket/2/Group_Ticket/"}, {"rel": "Supplier_Ticket", "href": "http://localhost/api.php/v1/Ticket/2/Supplier_Ticket/"}], "impact": 3, "status": 1, "content": "Ticket creado desde gestor-tickets.\\n\\nHilo interno: #1\\nAsunto del hilo: Solicitud de asistencia técnica\\nUID del hilo: 7c69ba87-5dd4-4d16-af4a-bdf90af698e9\\n\\nResumen cronológico de correos archivados:\\n\\n1. Solicitud de asistencia técnica\\n   Fecha: 2026-06-14 12:02:32+01:00\\n   De: usuario.demo@gestor-tickets.es\\n   Carpeta IMAP: INBOX\\n   UID IMAP: 1\\n\\n   Texto del correo:\\n   Buenos días, tengo un problema en mi ordenador, cuando trató de acceder a mi carpeta el explorador se cierra por completo sin mostrar mensaje de error alguno. Qué debo hacer? Saludos.\\n\\n---\\nNota: el correo original .eml queda archivado en gestor-tickets.", "urgency": 3, "date_mod": "2026-06-14 11:31:40", "priority": 3, "closedate": null, "solvedate": null, "actiontime": 0, "externalid": null, "is_deleted": 0, "entities_id": 0, "olas_id_tto": 0, "olas_id_ttr": 0, "slas_id_tto": 0, "slas_id_ttr": 0, "time_to_own": null, "locations_id": 0, "date_creation": "2026-06-14 11:31:40", "requesttypes_id": 1, "time_to_resolve": null, "close_delay_stat": 0, "olalevels_id_ttr": 0, "slalevels_id_ttr": 0, "solve_delay_stat": 0, "waiting_duration": 0, "global_validation": 1, "itilcategories_id": 0, "begin_waiting_date": null, "ola_tto_begin_date": null, "ola_ttr_begin_date": null, "tickettemplates_id": 0, "users_id_recipient": 11, "takeintoaccountdate": null, "internal_time_to_own": null, "ola_waiting_duration": 0, "sla_waiting_duration": 0, "users_id_lastupdater": 11, "internal_time_to_resolve": null, "takeintoaccount_delay_stat": 0}	2026-06-14 12:35:59.22076+01	2026-06-14 12:31:40.495581+01	2026-06-14 12:35:59.22076+01
\.


--
-- Data for Name: glpi_ticket_email_links; Type: TABLE DATA; Schema: gestor_tickets; Owner: -
--

COPY gestor_tickets.glpi_ticket_email_links (id, account_id, glpi_ticket_cache_id, email_message_id, origin, status, created_by_user_id, created_at, detached_by_user_id, detached_at, notes) FROM stdin;
1	3	1	1	created_from_thread	active	1	2026-06-14 12:31:40.495581+01	\N	\N	Enlace creado automáticamente al crear ticket desde hilo.
3	3	1	4	auto_sync	active	\N	2026-06-14 16:17:28.153557+01	\N	\N	Correo vinculado automáticamente por ingesta IMAP.
4	3	1	5	auto_sync	active	\N	2026-06-14 16:23:40.121101+01	\N	\N	Correo vinculado automáticamente por ingesta IMAP.
5	3	1	6	auto_sync	active	1	2026-06-14 19:35:11.744791+01	\N	\N	Correo vinculado automáticamente por ingesta IMAP.
6	3	1	7	auto_sync	active	1	2026-06-14 19:36:45.619658+01	\N	\N	Correo vinculado automáticamente por ingesta IMAP.
7	3	1	8	auto_sync	active	1	2026-06-14 19:38:14.364145+01	\N	\N	Correo vinculado automáticamente por ingesta IMAP.
\.


--
-- Data for Name: glpi_ticket_relationships; Type: TABLE DATA; Schema: gestor_tickets; Owner: -
--

COPY gestor_tickets.glpi_ticket_relationships (id, account_id, source_ticket_cache_id, target_ticket_cache_id, relationship_type, created_by_user_id, created_at, notes) FROM stdin;
\.


--
-- Data for Name: glpi_ticket_thread_links; Type: TABLE DATA; Schema: gestor_tickets; Owner: -
--

COPY gestor_tickets.glpi_ticket_thread_links (id, account_id, glpi_ticket_cache_id, thread_id, origin, status, created_by_user_id, created_at, detached_by_user_id, detached_at, notes) FROM stdin;
1	3	1	1	created_from_thread	active	1	2026-06-14 12:31:40.495581+01	\N	\N	Ticket creado desde hilo operativo.
\.


--
-- Data for Name: mail_ingestion_jobs; Type: TABLE DATA; Schema: gestor_tickets; Owner: -
--

COPY gestor_tickets.mail_ingestion_jobs (id, account_id, status, scan_inbox, scan_sent, inbox_folder_name, sent_folder_name, interval_minutes, max_messages_per_folder, last_started_at, last_success_at, last_error_at, next_run_at, auth_failure_count, last_error_message, created_by_user_id, updated_by_user_id, created_at, updated_at) FROM stdin;
1	3	active	t	t	INBOX	INBOX.Sent	5	50	2026-06-17 17:19:34.149302+01	2026-06-17 17:19:34.205556+01	2026-06-16 23:09:17.277994+01	2026-06-17 17:24:34.205556+01	0	\N	1	1	2026-06-14 12:57:21.856675+01	2026-06-17 17:19:34.205556+01
\.


--
-- Data for Name: mail_ingestion_runs; Type: TABLE DATA; Schema: gestor_tickets; Owner: -
--

COPY gestor_tickets.mail_ingestion_runs (id, job_id, account_id, status, started_at, finished_at, scanned_inbox_count, scanned_sent_count, imported_count, duplicate_count, error_count, error_message, details_json) FROM stdin;
1	1	3	success	2026-06-14 12:57:22.749669+01	2026-06-14 12:57:22.880309+01	1	0	0	1	0	\N	{"errors": [], "safety": {"body_peek": true, "store_used": false, "imap_readonly": true, "flags_modified": false}, "imported": [], "mailboxes": ["INBOX", "INBOX.Sent"], "duplicates": [{"uid": "1", "mailbox": "INBOX", "occurrence_id": 1}]}
2	1	3	success	2026-06-14 12:59:27.694076+01	2026-06-14 12:59:27.818571+01	1	0	0	1	0	\N	{"errors": [], "safety": {"body_peek": true, "store_used": false, "imap_readonly": true, "flags_modified": false}, "imported": [], "mailboxes": ["INBOX", "INBOX.Sent"], "duplicates": [{"uid": "1", "mailbox": "INBOX", "occurrence_id": 1}]}
3	1	3	success	2026-06-14 13:04:39.141195+01	2026-06-14 13:04:39.27383+01	1	0	0	1	0	\N	{"errors": [], "safety": {"body_peek": true, "store_used": false, "imap_readonly": true, "flags_modified": false}, "imported": [], "mailboxes": ["INBOX", "INBOX.Sent"], "duplicates": [{"uid": "1", "mailbox": "INBOX", "occurrence_id": 1}]}
4	1	3	success	2026-06-14 13:09:46.637782+01	2026-06-14 13:09:46.693096+01	1	0	0	1	0	\N	{"errors": [], "safety": {"body_peek": true, "store_used": false, "imap_readonly": true, "flags_modified": false}, "imported": [], "mailboxes": ["INBOX", "INBOX.Sent"], "duplicates": [{"uid": "1", "mailbox": "INBOX", "occurrence_id": 1}]}
5	1	3	success	2026-06-14 13:11:08.434199+01	2026-06-14 13:11:08.496811+01	1	0	0	1	0	\N	{"errors": [], "safety": {"body_peek": true, "store_used": false, "imap_readonly": true, "flags_modified": false}, "imported": [], "mailboxes": ["INBOX", "INBOX.Sent"], "duplicates": [{"uid": "1", "mailbox": "INBOX", "occurrence_id": 1}]}
6	1	3	success	2026-06-14 13:16:16.290226+01	2026-06-14 13:16:16.344837+01	1	0	0	1	0	\N	{"errors": [], "safety": {"body_peek": true, "store_used": false, "imap_readonly": true, "flags_modified": false}, "imported": [], "mailboxes": ["INBOX", "INBOX.Sent"], "duplicates": [{"uid": "1", "mailbox": "INBOX", "occurrence_id": 1}]}
7	1	3	success	2026-06-14 13:21:16.450179+01	2026-06-14 13:21:16.504212+01	1	0	0	1	0	\N	{"errors": [], "safety": {"body_peek": true, "store_used": false, "imap_readonly": true, "flags_modified": false}, "imported": [], "mailboxes": ["INBOX", "INBOX.Sent"], "duplicates": [{"uid": "1", "mailbox": "INBOX", "occurrence_id": 1}]}
8	1	3	success	2026-06-14 13:26:18.709789+01	2026-06-14 13:26:18.855524+01	1	0	0	1	0	\N	{"errors": [], "safety": {"body_peek": true, "store_used": false, "imap_readonly": true, "flags_modified": false}, "imported": [], "mailboxes": ["INBOX", "INBOX.Sent"], "duplicates": [{"uid": "1", "mailbox": "INBOX", "occurrence_id": 1}]}
9	1	3	success	2026-06-14 13:31:18.964179+01	2026-06-14 13:31:19.019185+01	1	0	0	1	0	\N	{"errors": [], "safety": {"body_peek": true, "store_used": false, "imap_readonly": true, "flags_modified": false}, "imported": [], "mailboxes": ["INBOX", "INBOX.Sent"], "duplicates": [{"uid": "1", "mailbox": "INBOX", "occurrence_id": 1}]}
10	1	3	success	2026-06-14 13:36:19.122401+01	2026-06-14 13:36:19.225177+01	1	0	0	1	0	\N	{"errors": [], "safety": {"body_peek": true, "store_used": false, "imap_readonly": true, "flags_modified": false}, "imported": [], "mailboxes": ["INBOX", "INBOX.Sent"], "duplicates": [{"uid": "1", "mailbox": "INBOX", "occurrence_id": 1}]}
11	1	3	success	2026-06-14 13:41:19.339624+01	2026-06-14 13:41:19.398686+01	1	0	0	1	0	\N	{"errors": [], "safety": {"body_peek": true, "store_used": false, "imap_readonly": true, "flags_modified": false}, "imported": [], "mailboxes": ["INBOX", "INBOX.Sent"], "duplicates": [{"uid": "1", "mailbox": "INBOX", "occurrence_id": 1}]}
12	1	3	success	2026-06-14 13:46:19.539566+01	2026-06-14 13:46:19.60521+01	1	0	0	1	0	\N	{"errors": [], "safety": {"body_peek": true, "store_used": false, "imap_readonly": true, "flags_modified": false}, "imported": [], "mailboxes": ["INBOX", "INBOX.Sent"], "duplicates": [{"uid": "1", "mailbox": "INBOX", "occurrence_id": 1}]}
13	1	3	success	2026-06-14 13:51:19.711631+01	2026-06-14 13:51:19.800182+01	1	0	0	1	0	\N	{"errors": [], "safety": {"body_peek": true, "store_used": false, "imap_readonly": true, "flags_modified": false}, "imported": [], "mailboxes": ["INBOX", "INBOX.Sent"], "duplicates": [{"uid": "1", "mailbox": "INBOX", "occurrence_id": 1}]}
14	1	3	success	2026-06-14 13:56:19.899042+01	2026-06-14 13:56:19.960786+01	1	0	0	1	0	\N	{"errors": [], "safety": {"body_peek": true, "store_used": false, "imap_readonly": true, "flags_modified": false}, "imported": [], "mailboxes": ["INBOX", "INBOX.Sent"], "duplicates": [{"uid": "1", "mailbox": "INBOX", "occurrence_id": 1}]}
15	1	3	success	2026-06-14 14:01:08.828089+01	2026-06-14 14:01:08.886772+01	1	0	0	1	0	\N	{"errors": [], "safety": {"body_peek": true, "store_used": false, "imap_readonly": true, "flags_modified": false}, "imported": [], "mailboxes": ["INBOX", "INBOX.Sent"], "duplicates": [{"uid": "1", "mailbox": "INBOX", "occurrence_id": 1}]}
16	1	3	success	2026-06-14 14:06:10.421689+01	2026-06-14 14:06:10.490941+01	1	0	0	1	0	\N	{"errors": [], "safety": {"body_peek": true, "store_used": false, "imap_readonly": true, "flags_modified": false}, "imported": [], "mailboxes": ["INBOX", "INBOX.Sent"], "duplicates": [{"uid": "1", "mailbox": "INBOX", "occurrence_id": 1}]}
17	1	3	success	2026-06-14 14:11:10.604373+01	2026-06-14 14:11:10.658617+01	1	0	0	1	0	\N	{"errors": [], "safety": {"body_peek": true, "store_used": false, "imap_readonly": true, "flags_modified": false}, "imported": [], "mailboxes": ["INBOX", "INBOX.Sent"], "duplicates": [{"uid": "1", "mailbox": "INBOX", "occurrence_id": 1}]}
18	1	3	success	2026-06-14 14:16:10.772192+01	2026-06-14 14:16:10.823653+01	1	0	0	1	0	\N	{"errors": [], "safety": {"body_peek": true, "store_used": false, "imap_readonly": true, "flags_modified": false}, "imported": [], "mailboxes": ["INBOX", "INBOX.Sent"], "duplicates": [{"uid": "1", "mailbox": "INBOX", "occurrence_id": 1}]}
19	1	3	success	2026-06-14 14:21:10.945501+01	2026-06-14 14:21:11.000447+01	1	0	0	1	0	\N	{"errors": [], "safety": {"body_peek": true, "store_used": false, "imap_readonly": true, "flags_modified": false}, "imported": [], "mailboxes": ["INBOX", "INBOX.Sent"], "duplicates": [{"uid": "1", "mailbox": "INBOX", "occurrence_id": 1}]}
20	1	3	success	2026-06-14 14:26:11.108001+01	2026-06-14 14:26:11.164698+01	1	0	0	1	0	\N	{"errors": [], "safety": {"body_peek": true, "store_used": false, "imap_readonly": true, "flags_modified": false}, "imported": [], "mailboxes": ["INBOX", "INBOX.Sent"], "duplicates": [{"uid": "1", "mailbox": "INBOX", "occurrence_id": 1}]}
21	1	3	success	2026-06-14 14:31:11.278434+01	2026-06-14 14:31:11.337004+01	1	0	0	1	0	\N	{"errors": [], "safety": {"body_peek": true, "store_used": false, "imap_readonly": true, "flags_modified": false}, "imported": [], "mailboxes": ["INBOX", "INBOX.Sent"], "duplicates": [{"uid": "1", "mailbox": "INBOX", "occurrence_id": 1}]}
22	1	3	success	2026-06-14 14:36:11.430184+01	2026-06-14 14:36:11.484286+01	1	0	0	1	0	\N	{"errors": [], "safety": {"body_peek": true, "store_used": false, "imap_readonly": true, "flags_modified": false}, "imported": [], "mailboxes": ["INBOX", "INBOX.Sent"], "duplicates": [{"uid": "1", "mailbox": "INBOX", "occurrence_id": 1}]}
23	1	3	success	2026-06-14 14:41:11.579429+01	2026-06-14 14:41:11.63483+01	1	0	0	1	0	\N	{"errors": [], "safety": {"body_peek": true, "store_used": false, "imap_readonly": true, "flags_modified": false}, "imported": [], "mailboxes": ["INBOX", "INBOX.Sent"], "duplicates": [{"uid": "1", "mailbox": "INBOX", "occurrence_id": 1}]}
24	1	3	success	2026-06-14 14:46:11.754431+01	2026-06-14 14:46:11.809757+01	1	0	0	1	0	\N	{"errors": [], "safety": {"body_peek": true, "store_used": false, "imap_readonly": true, "flags_modified": false}, "imported": [], "mailboxes": ["INBOX", "INBOX.Sent"], "duplicates": [{"uid": "1", "mailbox": "INBOX", "occurrence_id": 1}]}
25	1	3	success	2026-06-14 14:51:11.89942+01	2026-06-14 14:51:11.99641+01	1	0	0	1	0	\N	{"errors": [], "safety": {"body_peek": true, "store_used": false, "imap_readonly": true, "flags_modified": false}, "imported": [], "mailboxes": ["INBOX", "INBOX.Sent"], "duplicates": [{"uid": "1", "mailbox": "INBOX", "occurrence_id": 1}]}
26	1	3	success	2026-06-14 14:56:12.103635+01	2026-06-14 14:56:12.155783+01	1	0	0	1	0	\N	{"errors": [], "safety": {"body_peek": true, "store_used": false, "imap_readonly": true, "flags_modified": false}, "imported": [], "mailboxes": ["INBOX", "INBOX.Sent"], "duplicates": [{"uid": "1", "mailbox": "INBOX", "occurrence_id": 1}]}
27	1	3	success	2026-06-14 15:01:12.227129+01	2026-06-14 15:01:12.285895+01	1	0	0	1	0	\N	{"errors": [], "safety": {"body_peek": true, "store_used": false, "imap_readonly": true, "flags_modified": false}, "imported": [], "mailboxes": ["INBOX", "INBOX.Sent"], "duplicates": [{"uid": "1", "mailbox": "INBOX", "occurrence_id": 1}]}
28	1	3	success	2026-06-14 15:06:12.365631+01	2026-06-14 15:06:12.420105+01	1	0	0	1	0	\N	{"errors": [], "safety": {"body_peek": true, "store_used": false, "imap_readonly": true, "flags_modified": false}, "imported": [], "mailboxes": ["INBOX", "INBOX.Sent"], "duplicates": [{"uid": "1", "mailbox": "INBOX", "occurrence_id": 1}]}
29	1	3	success	2026-06-14 15:10:58.393982+01	2026-06-14 15:10:58.450009+01	1	0	0	1	0	\N	{"errors": [], "safety": {"body_peek": true, "store_used": false, "imap_readonly": true, "flags_modified": false}, "imported": [], "mailboxes": ["INBOX", "INBOX.Sent"], "duplicates": [{"uid": "1", "mailbox": "INBOX", "occurrence_id": 1}]}
30	1	3	success	2026-06-14 15:16:08.140887+01	2026-06-14 15:16:08.198203+01	1	0	0	1	0	\N	{"errors": [], "safety": {"body_peek": true, "store_used": false, "imap_readonly": true, "flags_modified": false}, "imported": [], "mailboxes": ["INBOX", "INBOX.Sent"], "duplicates": [{"uid": "1", "mailbox": "INBOX", "occurrence_id": 1}]}
31	1	3	success	2026-06-14 15:21:17.723055+01	2026-06-14 15:21:17.896897+01	1	0	0	1	0	\N	{"errors": [], "safety": {"body_peek": true, "store_used": false, "imap_readonly": true, "flags_modified": false}, "imported": [], "mailboxes": ["INBOX", "INBOX.Sent"], "duplicates": [{"uid": "1", "mailbox": "INBOX", "occurrence_id": 1}]}
32	1	3	success	2026-06-14 15:23:57.956664+01	2026-06-14 15:23:58.057726+01	1	0	0	1	0	\N	{"errors": [], "safety": {"body_peek": true, "store_used": false, "imap_readonly": true, "flags_modified": false}, "imported": [], "mailboxes": ["INBOX", "INBOX.Sent"], "duplicates": [{"uid": "1", "mailbox": "INBOX", "occurrence_id": 1}]}
33	1	3	success	2026-06-14 15:25:18.078471+01	2026-06-14 15:25:18.132118+01	1	0	0	1	0	\N	{"errors": [], "safety": {"body_peek": true, "store_used": false, "imap_readonly": true, "flags_modified": false}, "imported": [], "mailboxes": ["INBOX", "INBOX.Sent"], "duplicates": [{"uid": "1", "mailbox": "INBOX", "occurrence_id": 1}]}
34	1	3	success	2026-06-14 15:26:28.157534+01	2026-06-14 15:26:28.216621+01	1	0	0	1	0	\N	{"errors": [], "safety": {"body_peek": true, "store_used": false, "imap_readonly": true, "flags_modified": false}, "imported": [], "mailboxes": ["INBOX", "INBOX.Sent"], "duplicates": [{"uid": "1", "mailbox": "INBOX", "occurrence_id": 1}]}
35	1	3	success	2026-06-14 15:28:50.789241+01	2026-06-14 15:28:50.865662+01	1	0	0	1	0	\N	{"errors": [], "safety": {"body_peek": true, "store_used": false, "imap_readonly": true, "flags_modified": false}, "imported": [], "mailboxes": ["INBOX", "INBOX.Sent"], "duplicates": [{"uid": "1", "mailbox": "INBOX", "occurrence_id": 1}]}
36	1	3	success	2026-06-14 15:29:41.466666+01	2026-06-14 15:29:41.521284+01	1	0	0	1	0	\N	{"errors": [], "safety": {"body_peek": true, "store_used": false, "imap_readonly": true, "flags_modified": false}, "imported": [], "mailboxes": ["INBOX", "INBOX.Sent"], "duplicates": [{"uid": "1", "mailbox": "INBOX", "occurrence_id": 1}]}
37	1	3	success	2026-06-14 15:34:50.979571+01	2026-06-14 15:34:51.03364+01	1	0	0	1	0	\N	{"errors": [], "safety": {"body_peek": true, "store_used": false, "imap_readonly": true, "flags_modified": false}, "imported": [], "mailboxes": ["INBOX", "INBOX.Sent"], "duplicates": [{"uid": "1", "mailbox": "INBOX", "occurrence_id": 1}]}
38	1	3	success	2026-06-14 15:39:51.119931+01	2026-06-14 15:39:51.174302+01	1	0	0	1	0	\N	{"errors": [], "safety": {"body_peek": true, "store_used": false, "imap_readonly": true, "flags_modified": false}, "imported": [], "mailboxes": ["INBOX", "INBOX.Sent"], "duplicates": [{"uid": "1", "mailbox": "INBOX", "occurrence_id": 1}]}
39	1	3	success	2026-06-14 15:45:00.628968+01	2026-06-14 15:45:00.703413+01	1	0	0	1	0	\N	{"errors": [], "safety": {"body_peek": true, "store_used": false, "imap_readonly": true, "flags_modified": false}, "imported": [], "mailboxes": ["INBOX", "INBOX.Sent"], "duplicates": [{"uid": "1", "mailbox": "INBOX", "occurrence_id": 1}]}
40	1	3	success	2026-06-14 15:50:00.808583+01	2026-06-14 15:50:00.86073+01	1	0	0	1	0	\N	{"errors": [], "safety": {"body_peek": true, "store_used": false, "imap_readonly": true, "flags_modified": false}, "imported": [], "mailboxes": ["INBOX", "INBOX.Sent"], "duplicates": [{"uid": "1", "mailbox": "INBOX", "occurrence_id": 1}]}
41	1	3	success	2026-06-14 15:55:00.965901+01	2026-06-14 15:55:01.036888+01	1	0	0	1	0	\N	{"errors": [], "safety": {"body_peek": true, "store_used": false, "imap_readonly": true, "flags_modified": false}, "imported": [], "mailboxes": ["INBOX", "INBOX.Sent"], "duplicates": [{"uid": "1", "mailbox": "INBOX", "occurrence_id": 1}]}
42	1	3	success	2026-06-14 16:00:08.577481+01	2026-06-14 16:00:08.715886+01	1	0	0	1	0	\N	{"errors": [], "safety": {"body_peek": true, "store_used": false, "imap_readonly": true, "flags_modified": false}, "imported": [], "mailboxes": ["INBOX", "INBOX.Sent"], "duplicates": [{"uid": "1", "mailbox": "INBOX", "occurrence_id": 1}]}
43	1	3	success	2026-06-14 16:04:54.045798+01	2026-06-14 16:04:54.111496+01	1	0	0	1	0	\N	{"errors": [], "safety": {"body_peek": true, "store_used": false, "imap_readonly": true, "flags_modified": false}, "imported": [], "mailboxes": ["INBOX", "INBOX.Sent"], "duplicates": [{"uid": "1", "mailbox": "INBOX", "occurrence_id": 1}]}
44	1	3	success	2026-06-14 16:09:55.346863+01	2026-06-14 16:09:55.407094+01	1	0	0	1	0	\N	{"errors": [], "safety": {"body_peek": true, "store_used": false, "imap_readonly": true, "flags_modified": false}, "imported": [], "mailboxes": ["INBOX", "INBOX.Sent"], "duplicates": [{"uid": "1", "mailbox": "INBOX", "occurrence_id": 1}]}
45	1	3	success	2026-06-14 16:15:02.176667+01	2026-06-14 16:15:02.33375+01	1	0	0	1	0	\N	{"errors": [], "safety": {"body_peek": true, "store_used": false, "imap_readonly": true, "flags_modified": false}, "imported": [], "mailboxes": ["INBOX", "INBOX.Sent"], "duplicates": [{"uid": "1", "mailbox": "INBOX", "occurrence_id": 1}]}
46	1	3	success	2026-06-14 16:17:28.159066+01	2026-06-14 16:17:28.159066+01	1	0	1	0	0	\N	{"errors": [], "safety": {"body_peek": true, "store_used": false, "imap_readonly": true, "simulated_eml": true, "flags_modified": false}, "imported": [{"uid": "sim-1", "thread": {"thread_id": 1, "thread_changed": true}, "mailbox": "SIMULATED", "subject": "Re: Solicitud de asistencia técnica", "simulation": true, "ticket_sync": {"glpi_ticket_id": 2, "ticket_cache_id": 1, "operation_created": true, "email_link_created": true, "external_eml_attached": false, "external_followup_created": false}, "occurrence_id": 4, "email_message_id": 4}], "mailboxes": ["SIMULATED"], "duplicates": []}
47	1	3	success	2026-06-14 16:22:29.636182+01	2026-06-14 16:22:29.76638+01	1	0	0	1	0	\N	{"errors": [], "safety": {"body_peek": true, "store_used": false, "imap_readonly": true, "flags_modified": false}, "imported": [], "mailboxes": ["INBOX", "INBOX.Sent"], "duplicates": [{"uid": "1", "mailbox": "INBOX", "occurrence_id": 1}]}
48	1	3	success	2026-06-14 16:23:40.126362+01	2026-06-14 16:23:40.126362+01	1	0	1	0	0	\N	{"errors": [], "safety": {"body_peek": true, "store_used": false, "imap_readonly": true, "simulated_eml": true, "flags_modified": false}, "imported": [{"uid": "sim-2", "thread": {"thread_id": 1, "thread_changed": true}, "mailbox": "SIMULATED", "subject": "Re: Solicitud de asistencia técnica", "simulation": true, "ticket_sync": {"glpi_ticket_id": 2, "ticket_cache_id": 1, "operation_created": true, "email_link_created": true, "external_eml_attached": false, "external_followup_created": false}, "occurrence_id": 5, "email_message_id": 5}], "mailboxes": ["SIMULATED"], "duplicates": []}
49	1	3	success	2026-06-14 16:28:44.180415+01	2026-06-14 16:28:44.302959+01	1	0	0	1	0	\N	{"errors": [], "safety": {"body_peek": true, "store_used": false, "imap_readonly": true, "flags_modified": false}, "imported": [], "mailboxes": ["INBOX", "INBOX.Sent"], "duplicates": [{"uid": "1", "mailbox": "INBOX", "occurrence_id": 1}]}
50	1	3	success	2026-06-14 16:33:44.441057+01	2026-06-14 16:33:44.550735+01	1	0	0	1	0	\N	{"errors": [], "safety": {"body_peek": true, "store_used": false, "imap_readonly": true, "flags_modified": false}, "imported": [], "mailboxes": ["INBOX", "INBOX.Sent"], "duplicates": [{"uid": "1", "mailbox": "INBOX", "occurrence_id": 1}]}
51	1	3	success	2026-06-14 16:38:44.653953+01	2026-06-14 16:38:44.706272+01	1	0	0	1	0	\N	{"errors": [], "safety": {"body_peek": true, "store_used": false, "imap_readonly": true, "flags_modified": false}, "imported": [], "mailboxes": ["INBOX", "INBOX.Sent"], "duplicates": [{"uid": "1", "mailbox": "INBOX", "occurrence_id": 1}]}
52	1	3	success	2026-06-14 16:43:44.817541+01	2026-06-14 16:43:44.867797+01	1	0	0	1	0	\N	{"errors": [], "safety": {"body_peek": true, "store_used": false, "imap_readonly": true, "flags_modified": false}, "imported": [], "mailboxes": ["INBOX", "INBOX.Sent"], "duplicates": [{"uid": "1", "mailbox": "INBOX", "occurrence_id": 1}]}
53	1	3	success	2026-06-14 16:48:44.97076+01	2026-06-14 16:48:45.02246+01	1	0	0	1	0	\N	{"errors": [], "safety": {"body_peek": true, "store_used": false, "imap_readonly": true, "flags_modified": false}, "imported": [], "mailboxes": ["INBOX", "INBOX.Sent"], "duplicates": [{"uid": "1", "mailbox": "INBOX", "occurrence_id": 1}]}
54	1	3	success	2026-06-14 16:53:45.141823+01	2026-06-14 16:53:45.241135+01	1	0	0	1	0	\N	{"errors": [], "safety": {"body_peek": true, "store_used": false, "imap_readonly": true, "flags_modified": false}, "imported": [], "mailboxes": ["INBOX", "INBOX.Sent"], "duplicates": [{"uid": "1", "mailbox": "INBOX", "occurrence_id": 1}]}
55	1	3	success	2026-06-14 16:58:45.341204+01	2026-06-14 16:58:45.397318+01	1	0	0	1	0	\N	{"errors": [], "safety": {"body_peek": true, "store_used": false, "imap_readonly": true, "flags_modified": false}, "imported": [], "mailboxes": ["INBOX", "INBOX.Sent"], "duplicates": [{"uid": "1", "mailbox": "INBOX", "occurrence_id": 1}]}
56	1	3	success	2026-06-14 17:03:45.497813+01	2026-06-14 17:03:45.592756+01	1	0	0	1	0	\N	{"errors": [], "safety": {"body_peek": true, "store_used": false, "imap_readonly": true, "flags_modified": false}, "imported": [], "mailboxes": ["INBOX", "INBOX.Sent"], "duplicates": [{"uid": "1", "mailbox": "INBOX", "occurrence_id": 1}]}
57	1	3	success	2026-06-14 17:08:45.709992+01	2026-06-14 17:08:45.79422+01	1	0	0	1	0	\N	{"errors": [], "safety": {"body_peek": true, "store_used": false, "imap_readonly": true, "flags_modified": false}, "imported": [], "mailboxes": ["INBOX", "INBOX.Sent"], "duplicates": [{"uid": "1", "mailbox": "INBOX", "occurrence_id": 1}]}
58	1	3	success	2026-06-14 17:13:45.904985+01	2026-06-14 17:13:45.98967+01	1	0	0	1	0	\N	{"errors": [], "safety": {"body_peek": true, "store_used": false, "imap_readonly": true, "flags_modified": false}, "imported": [], "mailboxes": ["INBOX", "INBOX.Sent"], "duplicates": [{"uid": "1", "mailbox": "INBOX", "occurrence_id": 1}]}
59	1	3	success	2026-06-14 17:18:46.094258+01	2026-06-14 17:18:46.171665+01	1	0	0	1	0	\N	{"errors": [], "safety": {"body_peek": true, "store_used": false, "imap_readonly": true, "flags_modified": false}, "imported": [], "mailboxes": ["INBOX", "INBOX.Sent"], "duplicates": [{"uid": "1", "mailbox": "INBOX", "occurrence_id": 1}]}
60	1	3	success	2026-06-14 17:23:46.271577+01	2026-06-14 17:23:46.322401+01	1	0	0	1	0	\N	{"errors": [], "safety": {"body_peek": true, "store_used": false, "imap_readonly": true, "flags_modified": false}, "imported": [], "mailboxes": ["INBOX", "INBOX.Sent"], "duplicates": [{"uid": "1", "mailbox": "INBOX", "occurrence_id": 1}]}
61	1	3	success	2026-06-14 17:28:46.427405+01	2026-06-14 17:28:46.492197+01	1	0	0	1	0	\N	{"errors": [], "safety": {"body_peek": true, "store_used": false, "imap_readonly": true, "flags_modified": false}, "imported": [], "mailboxes": ["INBOX", "INBOX.Sent"], "duplicates": [{"uid": "1", "mailbox": "INBOX", "occurrence_id": 1}]}
62	1	3	success	2026-06-14 17:33:46.602364+01	2026-06-14 17:33:46.710723+01	1	0	0	1	0	\N	{"errors": [], "safety": {"body_peek": true, "store_used": false, "imap_readonly": true, "flags_modified": false}, "imported": [], "mailboxes": ["INBOX", "INBOX.Sent"], "duplicates": [{"uid": "1", "mailbox": "INBOX", "occurrence_id": 1}]}
63	1	3	success	2026-06-14 17:38:46.832689+01	2026-06-14 17:38:46.891616+01	1	0	0	1	0	\N	{"errors": [], "safety": {"body_peek": true, "store_used": false, "imap_readonly": true, "flags_modified": false}, "imported": [], "mailboxes": ["INBOX", "INBOX.Sent"], "duplicates": [{"uid": "1", "mailbox": "INBOX", "occurrence_id": 1}]}
64	1	3	success	2026-06-14 17:43:46.997585+01	2026-06-14 17:43:47.110447+01	1	0	0	1	0	\N	{"errors": [], "safety": {"body_peek": true, "store_used": false, "imap_readonly": true, "flags_modified": false}, "imported": [], "mailboxes": ["INBOX", "INBOX.Sent"], "duplicates": [{"uid": "1", "mailbox": "INBOX", "occurrence_id": 1}]}
65	1	3	success	2026-06-14 17:48:47.224208+01	2026-06-14 17:48:47.326012+01	1	0	0	1	0	\N	{"errors": [], "safety": {"body_peek": true, "store_used": false, "imap_readonly": true, "flags_modified": false}, "imported": [], "mailboxes": ["INBOX", "INBOX.Sent"], "duplicates": [{"uid": "1", "mailbox": "INBOX", "occurrence_id": 1}]}
66	1	3	success	2026-06-14 17:53:47.442853+01	2026-06-14 17:53:47.494105+01	1	0	0	1	0	\N	{"errors": [], "safety": {"body_peek": true, "store_used": false, "imap_readonly": true, "flags_modified": false}, "imported": [], "mailboxes": ["INBOX", "INBOX.Sent"], "duplicates": [{"uid": "1", "mailbox": "INBOX", "occurrence_id": 1}]}
67	1	3	success	2026-06-14 17:58:47.587675+01	2026-06-14 17:58:47.638074+01	1	0	0	1	0	\N	{"errors": [], "safety": {"body_peek": true, "store_used": false, "imap_readonly": true, "flags_modified": false}, "imported": [], "mailboxes": ["INBOX", "INBOX.Sent"], "duplicates": [{"uid": "1", "mailbox": "INBOX", "occurrence_id": 1}]}
68	1	3	success	2026-06-14 18:03:47.744018+01	2026-06-14 18:03:47.86128+01	1	0	0	1	0	\N	{"errors": [], "safety": {"body_peek": true, "store_used": false, "imap_readonly": true, "flags_modified": false}, "imported": [], "mailboxes": ["INBOX", "INBOX.Sent"], "duplicates": [{"uid": "1", "mailbox": "INBOX", "occurrence_id": 1}]}
69	1	3	success	2026-06-14 18:08:47.970579+01	2026-06-14 18:08:48.057056+01	1	0	0	1	0	\N	{"errors": [], "safety": {"body_peek": true, "store_used": false, "imap_readonly": true, "flags_modified": false}, "imported": [], "mailboxes": ["INBOX", "INBOX.Sent"], "duplicates": [{"uid": "1", "mailbox": "INBOX", "occurrence_id": 1}]}
70	1	3	success	2026-06-14 18:13:48.165813+01	2026-06-14 18:13:48.213954+01	1	0	0	1	0	\N	{"errors": [], "safety": {"body_peek": true, "store_used": false, "imap_readonly": true, "flags_modified": false}, "imported": [], "mailboxes": ["INBOX", "INBOX.Sent"], "duplicates": [{"uid": "1", "mailbox": "INBOX", "occurrence_id": 1}]}
71	1	3	success	2026-06-14 18:18:48.316555+01	2026-06-14 18:18:48.403857+01	1	0	0	1	0	\N	{"errors": [], "safety": {"body_peek": true, "store_used": false, "imap_readonly": true, "flags_modified": false}, "imported": [], "mailboxes": ["INBOX", "INBOX.Sent"], "duplicates": [{"uid": "1", "mailbox": "INBOX", "occurrence_id": 1}]}
72	1	3	success	2026-06-14 18:23:48.509696+01	2026-06-14 18:23:48.600458+01	1	0	0	1	0	\N	{"errors": [], "safety": {"body_peek": true, "store_used": false, "imap_readonly": true, "flags_modified": false}, "imported": [], "mailboxes": ["INBOX", "INBOX.Sent"], "duplicates": [{"uid": "1", "mailbox": "INBOX", "occurrence_id": 1}]}
73	1	3	success	2026-06-14 18:28:48.698416+01	2026-06-14 18:28:48.792509+01	1	0	0	1	0	\N	{"errors": [], "safety": {"body_peek": true, "store_used": false, "imap_readonly": true, "flags_modified": false}, "imported": [], "mailboxes": ["INBOX", "INBOX.Sent"], "duplicates": [{"uid": "1", "mailbox": "INBOX", "occurrence_id": 1}]}
74	1	3	success	2026-06-14 18:33:48.893439+01	2026-06-14 18:33:48.947486+01	1	0	0	1	0	\N	{"errors": [], "safety": {"body_peek": true, "store_used": false, "imap_readonly": true, "flags_modified": false}, "imported": [], "mailboxes": ["INBOX", "INBOX.Sent"], "duplicates": [{"uid": "1", "mailbox": "INBOX", "occurrence_id": 1}]}
75	1	3	success	2026-06-14 18:38:49.041451+01	2026-06-14 18:38:49.096895+01	1	0	0	1	0	\N	{"errors": [], "safety": {"body_peek": true, "store_used": false, "imap_readonly": true, "flags_modified": false}, "imported": [], "mailboxes": ["INBOX", "INBOX.Sent"], "duplicates": [{"uid": "1", "mailbox": "INBOX", "occurrence_id": 1}]}
76	1	3	success	2026-06-14 18:43:49.198815+01	2026-06-14 18:43:49.409568+01	1	0	0	1	0	\N	{"errors": [], "safety": {"body_peek": true, "store_used": false, "imap_readonly": true, "flags_modified": false}, "imported": [], "mailboxes": ["INBOX", "INBOX.Sent"], "duplicates": [{"uid": "1", "mailbox": "INBOX", "occurrence_id": 1}]}
77	1	3	success	2026-06-14 18:48:49.521385+01	2026-06-14 18:48:49.700807+01	1	0	0	1	0	\N	{"errors": [], "safety": {"body_peek": true, "store_used": false, "imap_readonly": true, "flags_modified": false}, "imported": [], "mailboxes": ["INBOX", "INBOX.Sent"], "duplicates": [{"uid": "1", "mailbox": "INBOX", "occurrence_id": 1}]}
78	1	3	success	2026-06-14 18:53:49.817723+01	2026-06-14 18:53:49.914798+01	1	0	0	1	0	\N	{"errors": [], "safety": {"body_peek": true, "store_used": false, "imap_readonly": true, "flags_modified": false}, "imported": [], "mailboxes": ["INBOX", "INBOX.Sent"], "duplicates": [{"uid": "1", "mailbox": "INBOX", "occurrence_id": 1}]}
79	1	3	success	2026-06-14 18:58:50.045285+01	2026-06-14 18:58:50.135288+01	1	0	0	1	0	\N	{"errors": [], "safety": {"body_peek": true, "store_used": false, "imap_readonly": true, "flags_modified": false}, "imported": [], "mailboxes": ["INBOX", "INBOX.Sent"], "duplicates": [{"uid": "1", "mailbox": "INBOX", "occurrence_id": 1}]}
80	1	3	success	2026-06-14 19:03:50.224864+01	2026-06-14 19:03:50.341423+01	1	0	0	1	0	\N	{"errors": [], "safety": {"body_peek": true, "store_used": false, "imap_readonly": true, "flags_modified": false}, "imported": [], "mailboxes": ["INBOX", "INBOX.Sent"], "duplicates": [{"uid": "1", "mailbox": "INBOX", "occurrence_id": 1}]}
81	1	3	success	2026-06-14 19:08:55.279618+01	2026-06-14 19:08:55.451928+01	1	0	0	1	0	\N	{"errors": [], "safety": {"body_peek": true, "store_used": false, "imap_readonly": true, "flags_modified": false}, "imported": [], "mailboxes": ["INBOX", "INBOX.Sent"], "duplicates": [{"uid": "1", "mailbox": "INBOX", "occurrence_id": 1}]}
82	1	3	success	2026-06-14 19:14:02.461601+01	2026-06-14 19:14:02.616141+01	1	0	0	1	0	\N	{"errors": [], "safety": {"body_peek": true, "store_used": false, "imap_readonly": true, "flags_modified": false}, "imported": [], "mailboxes": ["INBOX", "INBOX.Sent"], "duplicates": [{"uid": "1", "mailbox": "INBOX", "occurrence_id": 1}]}
83	1	3	success	2026-06-14 19:19:08.445617+01	2026-06-14 19:19:08.585889+01	1	0	0	1	0	\N	{"errors": [], "safety": {"body_peek": true, "store_used": false, "imap_readonly": true, "flags_modified": false}, "imported": [], "mailboxes": ["INBOX", "INBOX.Sent"], "duplicates": [{"uid": "1", "mailbox": "INBOX", "occurrence_id": 1}]}
84	1	3	success	2026-06-14 19:24:08.687985+01	2026-06-14 19:24:08.779136+01	1	0	0	1	0	\N	{"errors": [], "safety": {"body_peek": true, "store_used": false, "imap_readonly": true, "flags_modified": false}, "imported": [], "mailboxes": ["INBOX", "INBOX.Sent"], "duplicates": [{"uid": "1", "mailbox": "INBOX", "occurrence_id": 1}]}
85	1	3	success	2026-06-14 19:29:08.877921+01	2026-06-14 19:29:08.931681+01	1	0	0	1	0	\N	{"errors": [], "safety": {"body_peek": true, "store_used": false, "imap_readonly": true, "flags_modified": false}, "imported": [], "mailboxes": ["INBOX", "INBOX.Sent"], "duplicates": [{"uid": "1", "mailbox": "INBOX", "occurrence_id": 1}]}
86	1	3	success	2026-06-14 19:34:13.41634+01	2026-06-14 19:34:13.626928+01	1	0	0	1	0	\N	{"errors": [], "safety": {"body_peek": true, "store_used": false, "imap_readonly": true, "flags_modified": false}, "imported": [], "mailboxes": ["INBOX", "INBOX.Sent"], "duplicates": [{"uid": "1", "mailbox": "INBOX", "occurrence_id": 1}]}
87	1	3	success	2026-06-14 19:39:20.290007+01	2026-06-14 19:39:20.440892+01	1	0	0	1	0	\N	{"errors": [], "safety": {"body_peek": true, "store_used": false, "imap_readonly": true, "flags_modified": false}, "imported": [], "mailboxes": ["INBOX", "INBOX.Sent"], "duplicates": [{"uid": "1", "mailbox": "INBOX", "occurrence_id": 1}]}
88	1	3	success	2026-06-14 19:44:20.545512+01	2026-06-14 19:44:20.595652+01	1	0	0	1	0	\N	{"errors": [], "safety": {"body_peek": true, "store_used": false, "imap_readonly": true, "flags_modified": false}, "imported": [], "mailboxes": ["INBOX", "INBOX.Sent"], "duplicates": [{"uid": "1", "mailbox": "INBOX", "occurrence_id": 1}]}
89	1	3	success	2026-06-14 19:49:20.685409+01	2026-06-14 19:49:20.737829+01	1	0	0	1	0	\N	{"errors": [], "safety": {"body_peek": true, "store_used": false, "imap_readonly": true, "flags_modified": false}, "imported": [], "mailboxes": ["INBOX", "INBOX.Sent"], "duplicates": [{"uid": "1", "mailbox": "INBOX", "occurrence_id": 1}]}
90	1	3	success	2026-06-14 19:54:20.860464+01	2026-06-14 19:54:20.975172+01	1	0	0	1	0	\N	{"errors": [], "safety": {"body_peek": true, "store_used": false, "imap_readonly": true, "flags_modified": false}, "imported": [], "mailboxes": ["INBOX", "INBOX.Sent"], "duplicates": [{"uid": "1", "mailbox": "INBOX", "occurrence_id": 1}]}
91	1	3	success	2026-06-14 19:59:21.087862+01	2026-06-14 19:59:21.152094+01	1	0	0	1	0	\N	{"errors": [], "safety": {"body_peek": true, "store_used": false, "imap_readonly": true, "flags_modified": false}, "imported": [], "mailboxes": ["INBOX", "INBOX.Sent"], "duplicates": [{"uid": "1", "mailbox": "INBOX", "occurrence_id": 1}]}
92	1	3	success	2026-06-14 20:04:21.253495+01	2026-06-14 20:04:21.365055+01	1	0	0	1	0	\N	{"errors": [], "safety": {"body_peek": true, "store_used": false, "imap_readonly": true, "flags_modified": false}, "imported": [], "mailboxes": ["INBOX", "INBOX.Sent"], "duplicates": [{"uid": "1", "mailbox": "INBOX", "occurrence_id": 1}]}
93	1	3	success	2026-06-14 20:09:21.472627+01	2026-06-14 20:09:21.582697+01	1	0	0	1	0	\N	{"errors": [], "safety": {"body_peek": true, "store_used": false, "imap_readonly": true, "flags_modified": false}, "imported": [], "mailboxes": ["INBOX", "INBOX.Sent"], "duplicates": [{"uid": "1", "mailbox": "INBOX", "occurrence_id": 1}]}
94	1	3	success	2026-06-14 20:14:21.693823+01	2026-06-14 20:14:21.745731+01	1	0	0	1	0	\N	{"errors": [], "safety": {"body_peek": true, "store_used": false, "imap_readonly": true, "flags_modified": false}, "imported": [], "mailboxes": ["INBOX", "INBOX.Sent"], "duplicates": [{"uid": "1", "mailbox": "INBOX", "occurrence_id": 1}]}
95	1	3	success	2026-06-14 20:19:21.847601+01	2026-06-14 20:19:21.953133+01	1	0	0	1	0	\N	{"errors": [], "safety": {"body_peek": true, "store_used": false, "imap_readonly": true, "flags_modified": false}, "imported": [], "mailboxes": ["INBOX", "INBOX.Sent"], "duplicates": [{"uid": "1", "mailbox": "INBOX", "occurrence_id": 1}]}
96	1	3	success	2026-06-14 20:24:22.0717+01	2026-06-14 20:24:22.155221+01	1	0	0	1	0	\N	{"errors": [], "safety": {"body_peek": true, "store_used": false, "imap_readonly": true, "flags_modified": false}, "imported": [], "mailboxes": ["INBOX", "INBOX.Sent"], "duplicates": [{"uid": "1", "mailbox": "INBOX", "occurrence_id": 1}]}
97	1	3	success	2026-06-14 20:29:22.28299+01	2026-06-14 20:29:22.448447+01	1	0	0	1	0	\N	{"errors": [], "safety": {"body_peek": true, "store_used": false, "imap_readonly": true, "flags_modified": false}, "imported": [], "mailboxes": ["INBOX", "INBOX.Sent"], "duplicates": [{"uid": "1", "mailbox": "INBOX", "occurrence_id": 1}]}
98	1	3	success	2026-06-14 20:34:22.565849+01	2026-06-14 20:34:22.665858+01	1	0	0	1	0	\N	{"errors": [], "safety": {"body_peek": true, "store_used": false, "imap_readonly": true, "flags_modified": false}, "imported": [], "mailboxes": ["INBOX", "INBOX.Sent"], "duplicates": [{"uid": "1", "mailbox": "INBOX", "occurrence_id": 1}]}
99	1	3	success	2026-06-14 20:39:22.780724+01	2026-06-14 20:39:22.848815+01	1	0	0	1	0	\N	{"errors": [], "safety": {"body_peek": true, "store_used": false, "imap_readonly": true, "flags_modified": false}, "imported": [], "mailboxes": ["INBOX", "INBOX.Sent"], "duplicates": [{"uid": "1", "mailbox": "INBOX", "occurrence_id": 1}]}
100	1	3	success	2026-06-14 20:44:22.967314+01	2026-06-14 20:44:23.017921+01	1	0	0	1	0	\N	{"errors": [], "safety": {"body_peek": true, "store_used": false, "imap_readonly": true, "flags_modified": false}, "imported": [], "mailboxes": ["INBOX", "INBOX.Sent"], "duplicates": [{"uid": "1", "mailbox": "INBOX", "occurrence_id": 1}]}
101	1	3	success	2026-06-14 20:49:23.131063+01	2026-06-14 20:49:23.194666+01	1	0	0	1	0	\N	{"errors": [], "safety": {"body_peek": true, "store_used": false, "imap_readonly": true, "flags_modified": false}, "imported": [], "mailboxes": ["INBOX", "INBOX.Sent"], "duplicates": [{"uid": "1", "mailbox": "INBOX", "occurrence_id": 1}]}
102	1	3	success	2026-06-14 20:54:23.28563+01	2026-06-14 20:54:23.338157+01	1	0	0	1	0	\N	{"errors": [], "safety": {"body_peek": true, "store_used": false, "imap_readonly": true, "flags_modified": false}, "imported": [], "mailboxes": ["INBOX", "INBOX.Sent"], "duplicates": [{"uid": "1", "mailbox": "INBOX", "occurrence_id": 1}]}
103	1	3	success	2026-06-14 20:59:23.410638+01	2026-06-14 20:59:23.492261+01	1	0	0	1	0	\N	{"errors": [], "safety": {"body_peek": true, "store_used": false, "imap_readonly": true, "flags_modified": false}, "imported": [], "mailboxes": ["INBOX", "INBOX.Sent"], "duplicates": [{"uid": "1", "mailbox": "INBOX", "occurrence_id": 1}]}
104	1	3	success	2026-06-14 21:04:23.596128+01	2026-06-14 21:04:23.68997+01	1	0	0	1	0	\N	{"errors": [], "safety": {"body_peek": true, "store_used": false, "imap_readonly": true, "flags_modified": false}, "imported": [], "mailboxes": ["INBOX", "INBOX.Sent"], "duplicates": [{"uid": "1", "mailbox": "INBOX", "occurrence_id": 1}]}
105	1	3	success	2026-06-14 21:09:23.799985+01	2026-06-14 21:09:23.860646+01	1	0	0	1	0	\N	{"errors": [], "safety": {"body_peek": true, "store_used": false, "imap_readonly": true, "flags_modified": false}, "imported": [], "mailboxes": ["INBOX", "INBOX.Sent"], "duplicates": [{"uid": "1", "mailbox": "INBOX", "occurrence_id": 1}]}
106	1	3	success	2026-06-14 21:14:23.981048+01	2026-06-14 21:14:24.079293+01	1	0	0	1	0	\N	{"errors": [], "safety": {"body_peek": true, "store_used": false, "imap_readonly": true, "flags_modified": false}, "imported": [], "mailboxes": ["INBOX", "INBOX.Sent"], "duplicates": [{"uid": "1", "mailbox": "INBOX", "occurrence_id": 1}]}
107	1	3	success	2026-06-14 21:19:24.180467+01	2026-06-14 21:19:24.311802+01	1	0	0	1	0	\N	{"errors": [], "safety": {"body_peek": true, "store_used": false, "imap_readonly": true, "flags_modified": false}, "imported": [], "mailboxes": ["INBOX", "INBOX.Sent"], "duplicates": [{"uid": "1", "mailbox": "INBOX", "occurrence_id": 1}]}
108	1	3	success	2026-06-14 21:24:24.437316+01	2026-06-14 21:24:24.555885+01	1	0	0	1	0	\N	{"errors": [], "safety": {"body_peek": true, "store_used": false, "imap_readonly": true, "flags_modified": false}, "imported": [], "mailboxes": ["INBOX", "INBOX.Sent"], "duplicates": [{"uid": "1", "mailbox": "INBOX", "occurrence_id": 1}]}
109	1	3	success	2026-06-14 21:29:24.659747+01	2026-06-14 21:29:24.709791+01	1	0	0	1	0	\N	{"errors": [], "safety": {"body_peek": true, "store_used": false, "imap_readonly": true, "flags_modified": false}, "imported": [], "mailboxes": ["INBOX", "INBOX.Sent"], "duplicates": [{"uid": "1", "mailbox": "INBOX", "occurrence_id": 1}]}
110	1	3	success	2026-06-14 21:34:24.816671+01	2026-06-14 21:34:24.866122+01	1	0	0	1	0	\N	{"errors": [], "safety": {"body_peek": true, "store_used": false, "imap_readonly": true, "flags_modified": false}, "imported": [], "mailboxes": ["INBOX", "INBOX.Sent"], "duplicates": [{"uid": "1", "mailbox": "INBOX", "occurrence_id": 1}]}
111	1	3	success	2026-06-14 21:39:24.983087+01	2026-06-14 21:39:25.073228+01	1	0	0	1	0	\N	{"errors": [], "safety": {"body_peek": true, "store_used": false, "imap_readonly": true, "flags_modified": false}, "imported": [], "mailboxes": ["INBOX", "INBOX.Sent"], "duplicates": [{"uid": "1", "mailbox": "INBOX", "occurrence_id": 1}]}
112	1	3	success	2026-06-14 21:44:25.189053+01	2026-06-14 21:44:25.254465+01	1	0	0	1	0	\N	{"errors": [], "safety": {"body_peek": true, "store_used": false, "imap_readonly": true, "flags_modified": false}, "imported": [], "mailboxes": ["INBOX", "INBOX.Sent"], "duplicates": [{"uid": "1", "mailbox": "INBOX", "occurrence_id": 1}]}
113	1	3	success	2026-06-14 21:49:25.368415+01	2026-06-14 21:49:25.485621+01	1	0	0	1	0	\N	{"errors": [], "safety": {"body_peek": true, "store_used": false, "imap_readonly": true, "flags_modified": false}, "imported": [], "mailboxes": ["INBOX", "INBOX.Sent"], "duplicates": [{"uid": "1", "mailbox": "INBOX", "occurrence_id": 1}]}
114	1	3	success	2026-06-14 21:54:25.592911+01	2026-06-14 21:54:25.689773+01	1	0	0	1	0	\N	{"errors": [], "safety": {"body_peek": true, "store_used": false, "imap_readonly": true, "flags_modified": false}, "imported": [], "mailboxes": ["INBOX", "INBOX.Sent"], "duplicates": [{"uid": "1", "mailbox": "INBOX", "occurrence_id": 1}]}
115	1	3	success	2026-06-14 21:59:25.794649+01	2026-06-14 21:59:25.893789+01	1	0	0	1	0	\N	{"errors": [], "safety": {"body_peek": true, "store_used": false, "imap_readonly": true, "flags_modified": false}, "imported": [], "mailboxes": ["INBOX", "INBOX.Sent"], "duplicates": [{"uid": "1", "mailbox": "INBOX", "occurrence_id": 1}]}
116	1	3	success	2026-06-14 22:04:25.998686+01	2026-06-14 22:04:26.178427+01	1	0	0	1	0	\N	{"errors": [], "safety": {"body_peek": true, "store_used": false, "imap_readonly": true, "flags_modified": false}, "imported": [], "mailboxes": ["INBOX", "INBOX.Sent"], "duplicates": [{"uid": "1", "mailbox": "INBOX", "occurrence_id": 1}]}
117	1	3	success	2026-06-14 22:09:29.272196+01	2026-06-14 22:09:29.401613+01	1	0	0	1	0	\N	{"errors": [], "safety": {"body_peek": true, "store_used": false, "imap_readonly": true, "flags_modified": false}, "imported": [], "mailboxes": ["INBOX", "INBOX.Sent"], "duplicates": [{"uid": "1", "mailbox": "INBOX", "occurrence_id": 1}]}
118	1	3	success	2026-06-14 22:14:29.520452+01	2026-06-14 22:14:29.575296+01	1	0	0	1	0	\N	{"errors": [], "safety": {"body_peek": true, "store_used": false, "imap_readonly": true, "flags_modified": false}, "imported": [], "mailboxes": ["INBOX", "INBOX.Sent"], "duplicates": [{"uid": "1", "mailbox": "INBOX", "occurrence_id": 1}]}
119	1	3	success	2026-06-14 22:19:29.679406+01	2026-06-14 22:19:29.771131+01	1	0	0	1	0	\N	{"errors": [], "safety": {"body_peek": true, "store_used": false, "imap_readonly": true, "flags_modified": false}, "imported": [], "mailboxes": ["INBOX", "INBOX.Sent"], "duplicates": [{"uid": "1", "mailbox": "INBOX", "occurrence_id": 1}]}
120	1	3	success	2026-06-14 22:24:29.8819+01	2026-06-14 22:24:29.953145+01	1	0	0	1	0	\N	{"errors": [], "safety": {"body_peek": true, "store_used": false, "imap_readonly": true, "flags_modified": false}, "imported": [], "mailboxes": ["INBOX", "INBOX.Sent"], "duplicates": [{"uid": "1", "mailbox": "INBOX", "occurrence_id": 1}]}
121	1	3	success	2026-06-14 22:29:38.396244+01	2026-06-14 22:29:38.588602+01	1	0	0	1	0	\N	{"errors": [], "safety": {"body_peek": true, "store_used": false, "imap_readonly": true, "flags_modified": false}, "imported": [], "mailboxes": ["INBOX", "INBOX.Sent"], "duplicates": [{"uid": "1", "mailbox": "INBOX", "occurrence_id": 1}]}
122	1	3	success	2026-06-14 22:34:38.692713+01	2026-06-14 22:34:38.815119+01	1	0	0	1	0	\N	{"errors": [], "safety": {"body_peek": true, "store_used": false, "imap_readonly": true, "flags_modified": false}, "imported": [], "mailboxes": ["INBOX", "INBOX.Sent"], "duplicates": [{"uid": "1", "mailbox": "INBOX", "occurrence_id": 1}]}
123	1	3	success	2026-06-14 22:39:38.932944+01	2026-06-14 22:39:39.008558+01	1	0	0	1	0	\N	{"errors": [], "safety": {"body_peek": true, "store_used": false, "imap_readonly": true, "flags_modified": false}, "imported": [], "mailboxes": ["INBOX", "INBOX.Sent"], "duplicates": [{"uid": "1", "mailbox": "INBOX", "occurrence_id": 1}]}
124	1	3	success	2026-06-14 22:44:39.13973+01	2026-06-14 22:44:39.192418+01	1	0	0	1	0	\N	{"errors": [], "safety": {"body_peek": true, "store_used": false, "imap_readonly": true, "flags_modified": false}, "imported": [], "mailboxes": ["INBOX", "INBOX.Sent"], "duplicates": [{"uid": "1", "mailbox": "INBOX", "occurrence_id": 1}]}
125	1	3	success	2026-06-14 22:49:40.904286+01	2026-06-14 22:49:40.982167+01	1	0	0	1	0	\N	{"errors": [], "safety": {"body_peek": true, "store_used": false, "imap_readonly": true, "flags_modified": false}, "imported": [], "mailboxes": ["INBOX", "INBOX.Sent"], "duplicates": [{"uid": "1", "mailbox": "INBOX", "occurrence_id": 1}]}
126	1	3	success	2026-06-14 22:54:41.109144+01	2026-06-14 22:54:41.208831+01	1	0	0	1	0	\N	{"errors": [], "safety": {"body_peek": true, "store_used": false, "imap_readonly": true, "flags_modified": false}, "imported": [], "mailboxes": ["INBOX", "INBOX.Sent"], "duplicates": [{"uid": "1", "mailbox": "INBOX", "occurrence_id": 1}]}
127	1	3	success	2026-06-14 22:59:44.633526+01	2026-06-14 22:59:44.76022+01	1	0	0	1	0	\N	{"errors": [], "safety": {"body_peek": true, "store_used": false, "imap_readonly": true, "flags_modified": false}, "imported": [], "mailboxes": ["INBOX", "INBOX.Sent"], "duplicates": [{"uid": "1", "mailbox": "INBOX", "occurrence_id": 1}]}
128	1	3	success	2026-06-14 23:04:44.896728+01	2026-06-14 23:04:44.993019+01	1	0	0	1	0	\N	{"errors": [], "safety": {"body_peek": true, "store_used": false, "imap_readonly": true, "flags_modified": false}, "imported": [], "mailboxes": ["INBOX", "INBOX.Sent"], "duplicates": [{"uid": "1", "mailbox": "INBOX", "occurrence_id": 1}]}
129	1	3	success	2026-06-14 23:09:45.120585+01	2026-06-14 23:09:45.20777+01	1	0	0	1	0	\N	{"errors": [], "safety": {"body_peek": true, "store_used": false, "imap_readonly": true, "flags_modified": false}, "imported": [], "mailboxes": ["INBOX", "INBOX.Sent"], "duplicates": [{"uid": "1", "mailbox": "INBOX", "occurrence_id": 1}]}
130	1	3	success	2026-06-14 23:14:53.163871+01	2026-06-14 23:14:53.22104+01	1	0	0	1	0	\N	{"errors": [], "safety": {"body_peek": true, "store_used": false, "imap_readonly": true, "flags_modified": false}, "imported": [], "mailboxes": ["INBOX", "INBOX.Sent"], "duplicates": [{"uid": "1", "mailbox": "INBOX", "occurrence_id": 1}]}
131	1	3	success	2026-06-14 23:19:53.340657+01	2026-06-14 23:19:53.393884+01	1	0	0	1	0	\N	{"errors": [], "safety": {"body_peek": true, "store_used": false, "imap_readonly": true, "flags_modified": false}, "imported": [], "mailboxes": ["INBOX", "INBOX.Sent"], "duplicates": [{"uid": "1", "mailbox": "INBOX", "occurrence_id": 1}]}
132	1	3	success	2026-06-14 23:24:53.511587+01	2026-06-14 23:24:53.599892+01	1	0	0	1	0	\N	{"errors": [], "safety": {"body_peek": true, "store_used": false, "imap_readonly": true, "flags_modified": false}, "imported": [], "mailboxes": ["INBOX", "INBOX.Sent"], "duplicates": [{"uid": "1", "mailbox": "INBOX", "occurrence_id": 1}]}
133	1	3	success	2026-06-14 23:29:53.727103+01	2026-06-14 23:29:53.820424+01	1	0	0	1	0	\N	{"errors": [], "safety": {"body_peek": true, "store_used": false, "imap_readonly": true, "flags_modified": false}, "imported": [], "mailboxes": ["INBOX", "INBOX.Sent"], "duplicates": [{"uid": "1", "mailbox": "INBOX", "occurrence_id": 1}]}
134	1	3	success	2026-06-14 23:34:53.950905+01	2026-06-14 23:34:54.064443+01	1	0	0	1	0	\N	{"errors": [], "safety": {"body_peek": true, "store_used": false, "imap_readonly": true, "flags_modified": false}, "imported": [], "mailboxes": ["INBOX", "INBOX.Sent"], "duplicates": [{"uid": "1", "mailbox": "INBOX", "occurrence_id": 1}]}
135	1	3	success	2026-06-14 23:39:54.160643+01	2026-06-14 23:39:54.21085+01	1	0	0	1	0	\N	{"errors": [], "safety": {"body_peek": true, "store_used": false, "imap_readonly": true, "flags_modified": false}, "imported": [], "mailboxes": ["INBOX", "INBOX.Sent"], "duplicates": [{"uid": "1", "mailbox": "INBOX", "occurrence_id": 1}]}
136	1	3	success	2026-06-14 23:44:54.337765+01	2026-06-14 23:44:54.392417+01	1	0	0	1	0	\N	{"errors": [], "safety": {"body_peek": true, "store_used": false, "imap_readonly": true, "flags_modified": false}, "imported": [], "mailboxes": ["INBOX", "INBOX.Sent"], "duplicates": [{"uid": "1", "mailbox": "INBOX", "occurrence_id": 1}]}
137	1	3	success	2026-06-14 23:49:54.522413+01	2026-06-14 23:49:54.712121+01	1	0	0	1	0	\N	{"errors": [], "safety": {"body_peek": true, "store_used": false, "imap_readonly": true, "flags_modified": false}, "imported": [], "mailboxes": ["INBOX", "INBOX.Sent"], "duplicates": [{"uid": "1", "mailbox": "INBOX", "occurrence_id": 1}]}
138	1	3	success	2026-06-14 23:54:54.86362+01	2026-06-14 23:54:54.960265+01	1	0	0	1	0	\N	{"errors": [], "safety": {"body_peek": true, "store_used": false, "imap_readonly": true, "flags_modified": false}, "imported": [], "mailboxes": ["INBOX", "INBOX.Sent"], "duplicates": [{"uid": "1", "mailbox": "INBOX", "occurrence_id": 1}]}
139	1	3	success	2026-06-14 23:59:55.075139+01	2026-06-14 23:59:55.186241+01	1	0	0	1	0	\N	{"errors": [], "safety": {"body_peek": true, "store_used": false, "imap_readonly": true, "flags_modified": false}, "imported": [], "mailboxes": ["INBOX", "INBOX.Sent"], "duplicates": [{"uid": "1", "mailbox": "INBOX", "occurrence_id": 1}]}
140	1	3	success	2026-06-15 00:04:55.300332+01	2026-06-15 00:04:55.35269+01	1	0	0	1	0	\N	{"errors": [], "safety": {"body_peek": true, "store_used": false, "imap_readonly": true, "flags_modified": false}, "imported": [], "mailboxes": ["INBOX", "INBOX.Sent"], "duplicates": [{"uid": "1", "mailbox": "INBOX", "occurrence_id": 1}]}
141	1	3	success	2026-06-15 00:09:55.462336+01	2026-06-15 00:09:55.519568+01	1	0	0	1	0	\N	{"errors": [], "safety": {"body_peek": true, "store_used": false, "imap_readonly": true, "flags_modified": false}, "imported": [], "mailboxes": ["INBOX", "INBOX.Sent"], "duplicates": [{"uid": "1", "mailbox": "INBOX", "occurrence_id": 1}]}
142	1	3	success	2026-06-15 00:14:55.619988+01	2026-06-15 00:14:55.670459+01	1	0	0	1	0	\N	{"errors": [], "safety": {"body_peek": true, "store_used": false, "imap_readonly": true, "flags_modified": false}, "imported": [], "mailboxes": ["INBOX", "INBOX.Sent"], "duplicates": [{"uid": "1", "mailbox": "INBOX", "occurrence_id": 1}]}
143	1	3	success	2026-06-15 00:19:55.792157+01	2026-06-15 00:19:55.844486+01	1	0	0	1	0	\N	{"errors": [], "safety": {"body_peek": true, "store_used": false, "imap_readonly": true, "flags_modified": false}, "imported": [], "mailboxes": ["INBOX", "INBOX.Sent"], "duplicates": [{"uid": "1", "mailbox": "INBOX", "occurrence_id": 1}]}
144	1	3	success	2026-06-15 00:24:55.985034+01	2026-06-15 00:24:56.094256+01	1	0	0	1	0	\N	{"errors": [], "safety": {"body_peek": true, "store_used": false, "imap_readonly": true, "flags_modified": false}, "imported": [], "mailboxes": ["INBOX", "INBOX.Sent"], "duplicates": [{"uid": "1", "mailbox": "INBOX", "occurrence_id": 1}]}
145	1	3	success	2026-06-15 00:29:56.232689+01	2026-06-15 00:29:56.33701+01	1	0	0	1	0	\N	{"errors": [], "safety": {"body_peek": true, "store_used": false, "imap_readonly": true, "flags_modified": false}, "imported": [], "mailboxes": ["INBOX", "INBOX.Sent"], "duplicates": [{"uid": "1", "mailbox": "INBOX", "occurrence_id": 1}]}
146	1	3	success	2026-06-15 00:34:56.441063+01	2026-06-15 00:34:56.502637+01	1	0	0	1	0	\N	{"errors": [], "safety": {"body_peek": true, "store_used": false, "imap_readonly": true, "flags_modified": false}, "imported": [], "mailboxes": ["INBOX", "INBOX.Sent"], "duplicates": [{"uid": "1", "mailbox": "INBOX", "occurrence_id": 1}]}
147	1	3	success	2026-06-15 00:39:56.616443+01	2026-06-15 00:39:56.666687+01	1	0	0	1	0	\N	{"errors": [], "safety": {"body_peek": true, "store_used": false, "imap_readonly": true, "flags_modified": false}, "imported": [], "mailboxes": ["INBOX", "INBOX.Sent"], "duplicates": [{"uid": "1", "mailbox": "INBOX", "occurrence_id": 1}]}
148	1	3	success	2026-06-15 00:44:56.776927+01	2026-06-15 00:44:56.868969+01	1	0	0	1	0	\N	{"errors": [], "safety": {"body_peek": true, "store_used": false, "imap_readonly": true, "flags_modified": false}, "imported": [], "mailboxes": ["INBOX", "INBOX.Sent"], "duplicates": [{"uid": "1", "mailbox": "INBOX", "occurrence_id": 1}]}
149	1	3	success	2026-06-15 00:49:57.000241+01	2026-06-15 00:49:57.057677+01	1	0	0	1	0	\N	{"errors": [], "safety": {"body_peek": true, "store_used": false, "imap_readonly": true, "flags_modified": false}, "imported": [], "mailboxes": ["INBOX", "INBOX.Sent"], "duplicates": [{"uid": "1", "mailbox": "INBOX", "occurrence_id": 1}]}
150	1	3	success	2026-06-15 00:54:57.121052+01	2026-06-15 00:54:57.172061+01	1	0	0	1	0	\N	{"errors": [], "safety": {"body_peek": true, "store_used": false, "imap_readonly": true, "flags_modified": false}, "imported": [], "mailboxes": ["INBOX", "INBOX.Sent"], "duplicates": [{"uid": "1", "mailbox": "INBOX", "occurrence_id": 1}]}
151	1	3	success	2026-06-15 00:59:57.268679+01	2026-06-15 00:59:57.375374+01	1	0	0	1	0	\N	{"errors": [], "safety": {"body_peek": true, "store_used": false, "imap_readonly": true, "flags_modified": false}, "imported": [], "mailboxes": ["INBOX", "INBOX.Sent"], "duplicates": [{"uid": "1", "mailbox": "INBOX", "occurrence_id": 1}]}
152	1	3	success	2026-06-15 01:04:57.516925+01	2026-06-15 01:04:57.604918+01	1	0	0	1	0	\N	{"errors": [], "safety": {"body_peek": true, "store_used": false, "imap_readonly": true, "flags_modified": false}, "imported": [], "mailboxes": ["INBOX", "INBOX.Sent"], "duplicates": [{"uid": "1", "mailbox": "INBOX", "occurrence_id": 1}]}
153	1	3	success	2026-06-15 01:09:57.743609+01	2026-06-15 01:09:57.833581+01	1	0	0	1	0	\N	{"errors": [], "safety": {"body_peek": true, "store_used": false, "imap_readonly": true, "flags_modified": false}, "imported": [], "mailboxes": ["INBOX", "INBOX.Sent"], "duplicates": [{"uid": "1", "mailbox": "INBOX", "occurrence_id": 1}]}
154	1	3	success	2026-06-15 01:14:57.969677+01	2026-06-15 01:14:58.188332+01	1	0	0	1	0	\N	{"errors": [], "safety": {"body_peek": true, "store_used": false, "imap_readonly": true, "flags_modified": false}, "imported": [], "mailboxes": ["INBOX", "INBOX.Sent"], "duplicates": [{"uid": "1", "mailbox": "INBOX", "occurrence_id": 1}]}
155	1	3	success	2026-06-15 01:19:58.32444+01	2026-06-15 01:19:58.384282+01	1	0	0	1	0	\N	{"errors": [], "safety": {"body_peek": true, "store_used": false, "imap_readonly": true, "flags_modified": false}, "imported": [], "mailboxes": ["INBOX", "INBOX.Sent"], "duplicates": [{"uid": "1", "mailbox": "INBOX", "occurrence_id": 1}]}
156	1	3	success	2026-06-15 01:24:58.515351+01	2026-06-15 01:24:58.622586+01	1	0	0	1	0	\N	{"errors": [], "safety": {"body_peek": true, "store_used": false, "imap_readonly": true, "flags_modified": false}, "imported": [], "mailboxes": ["INBOX", "INBOX.Sent"], "duplicates": [{"uid": "1", "mailbox": "INBOX", "occurrence_id": 1}]}
157	1	3	success	2026-06-15 01:29:58.763136+01	2026-06-15 01:29:58.853731+01	1	0	0	1	0	\N	{"errors": [], "safety": {"body_peek": true, "store_used": false, "imap_readonly": true, "flags_modified": false}, "imported": [], "mailboxes": ["INBOX", "INBOX.Sent"], "duplicates": [{"uid": "1", "mailbox": "INBOX", "occurrence_id": 1}]}
158	1	3	success	2026-06-15 01:34:58.986804+01	2026-06-15 01:34:59.091572+01	1	0	0	1	0	\N	{"errors": [], "safety": {"body_peek": true, "store_used": false, "imap_readonly": true, "flags_modified": false}, "imported": [], "mailboxes": ["INBOX", "INBOX.Sent"], "duplicates": [{"uid": "1", "mailbox": "INBOX", "occurrence_id": 1}]}
159	1	3	success	2026-06-15 01:39:59.222976+01	2026-06-15 01:39:59.280751+01	1	0	0	1	0	\N	{"errors": [], "safety": {"body_peek": true, "store_used": false, "imap_readonly": true, "flags_modified": false}, "imported": [], "mailboxes": ["INBOX", "INBOX.Sent"], "duplicates": [{"uid": "1", "mailbox": "INBOX", "occurrence_id": 1}]}
160	1	3	success	2026-06-15 01:44:59.407446+01	2026-06-15 01:44:59.461256+01	1	0	0	1	0	\N	{"errors": [], "safety": {"body_peek": true, "store_used": false, "imap_readonly": true, "flags_modified": false}, "imported": [], "mailboxes": ["INBOX", "INBOX.Sent"], "duplicates": [{"uid": "1", "mailbox": "INBOX", "occurrence_id": 1}]}
161	1	3	success	2026-06-15 01:49:59.59473+01	2026-06-15 01:49:59.647317+01	1	0	0	1	0	\N	{"errors": [], "safety": {"body_peek": true, "store_used": false, "imap_readonly": true, "flags_modified": false}, "imported": [], "mailboxes": ["INBOX", "INBOX.Sent"], "duplicates": [{"uid": "1", "mailbox": "INBOX", "occurrence_id": 1}]}
162	1	3	success	2026-06-15 01:54:59.739893+01	2026-06-15 01:54:59.796162+01	1	0	0	1	0	\N	{"errors": [], "safety": {"body_peek": true, "store_used": false, "imap_readonly": true, "flags_modified": false}, "imported": [], "mailboxes": ["INBOX", "INBOX.Sent"], "duplicates": [{"uid": "1", "mailbox": "INBOX", "occurrence_id": 1}]}
163	1	3	success	2026-06-15 01:59:59.913792+01	2026-06-15 02:00:00.02475+01	1	0	0	1	0	\N	{"errors": [], "safety": {"body_peek": true, "store_used": false, "imap_readonly": true, "flags_modified": false}, "imported": [], "mailboxes": ["INBOX", "INBOX.Sent"], "duplicates": [{"uid": "1", "mailbox": "INBOX", "occurrence_id": 1}]}
164	1	3	success	2026-06-15 02:05:00.135176+01	2026-06-15 02:05:00.229624+01	1	0	0	1	0	\N	{"errors": [], "safety": {"body_peek": true, "store_used": false, "imap_readonly": true, "flags_modified": false}, "imported": [], "mailboxes": ["INBOX", "INBOX.Sent"], "duplicates": [{"uid": "1", "mailbox": "INBOX", "occurrence_id": 1}]}
165	1	3	success	2026-06-15 02:10:00.344835+01	2026-06-15 02:10:00.45781+01	1	0	0	1	0	\N	{"errors": [], "safety": {"body_peek": true, "store_used": false, "imap_readonly": true, "flags_modified": false}, "imported": [], "mailboxes": ["INBOX", "INBOX.Sent"], "duplicates": [{"uid": "1", "mailbox": "INBOX", "occurrence_id": 1}]}
166	1	3	success	2026-06-15 02:15:00.526296+01	2026-06-15 02:15:00.588962+01	1	0	0	1	0	\N	{"errors": [], "safety": {"body_peek": true, "store_used": false, "imap_readonly": true, "flags_modified": false}, "imported": [], "mailboxes": ["INBOX", "INBOX.Sent"], "duplicates": [{"uid": "1", "mailbox": "INBOX", "occurrence_id": 1}]}
167	1	3	success	2026-06-15 02:20:00.712661+01	2026-06-15 02:20:00.80477+01	1	0	0	1	0	\N	{"errors": [], "safety": {"body_peek": true, "store_used": false, "imap_readonly": true, "flags_modified": false}, "imported": [], "mailboxes": ["INBOX", "INBOX.Sent"], "duplicates": [{"uid": "1", "mailbox": "INBOX", "occurrence_id": 1}]}
168	1	3	success	2026-06-15 02:25:00.937874+01	2026-06-15 02:25:00.993899+01	1	0	0	1	0	\N	{"errors": [], "safety": {"body_peek": true, "store_used": false, "imap_readonly": true, "flags_modified": false}, "imported": [], "mailboxes": ["INBOX", "INBOX.Sent"], "duplicates": [{"uid": "1", "mailbox": "INBOX", "occurrence_id": 1}]}
169	1	3	success	2026-06-15 02:30:01.149271+01	2026-06-15 02:30:01.242264+01	1	0	0	1	0	\N	{"errors": [], "safety": {"body_peek": true, "store_used": false, "imap_readonly": true, "flags_modified": false}, "imported": [], "mailboxes": ["INBOX", "INBOX.Sent"], "duplicates": [{"uid": "1", "mailbox": "INBOX", "occurrence_id": 1}]}
170	1	3	success	2026-06-15 02:35:01.360855+01	2026-06-15 02:35:01.466409+01	1	0	0	1	0	\N	{"errors": [], "safety": {"body_peek": true, "store_used": false, "imap_readonly": true, "flags_modified": false}, "imported": [], "mailboxes": ["INBOX", "INBOX.Sent"], "duplicates": [{"uid": "1", "mailbox": "INBOX", "occurrence_id": 1}]}
171	1	3	success	2026-06-15 02:40:01.568723+01	2026-06-15 02:40:01.643958+01	1	0	0	1	0	\N	{"errors": [], "safety": {"body_peek": true, "store_used": false, "imap_readonly": true, "flags_modified": false}, "imported": [], "mailboxes": ["INBOX", "INBOX.Sent"], "duplicates": [{"uid": "1", "mailbox": "INBOX", "occurrence_id": 1}]}
172	1	3	success	2026-06-15 02:45:01.741624+01	2026-06-15 02:45:01.86311+01	1	0	0	1	0	\N	{"errors": [], "safety": {"body_peek": true, "store_used": false, "imap_readonly": true, "flags_modified": false}, "imported": [], "mailboxes": ["INBOX", "INBOX.Sent"], "duplicates": [{"uid": "1", "mailbox": "INBOX", "occurrence_id": 1}]}
173	1	3	success	2026-06-15 02:50:01.989047+01	2026-06-15 02:50:02.06551+01	1	0	0	1	0	\N	{"errors": [], "safety": {"body_peek": true, "store_used": false, "imap_readonly": true, "flags_modified": false}, "imported": [], "mailboxes": ["INBOX", "INBOX.Sent"], "duplicates": [{"uid": "1", "mailbox": "INBOX", "occurrence_id": 1}]}
174	1	3	success	2026-06-15 02:55:02.17471+01	2026-06-15 02:55:02.316135+01	1	0	0	1	0	\N	{"errors": [], "safety": {"body_peek": true, "store_used": false, "imap_readonly": true, "flags_modified": false}, "imported": [], "mailboxes": ["INBOX", "INBOX.Sent"], "duplicates": [{"uid": "1", "mailbox": "INBOX", "occurrence_id": 1}]}
175	1	3	success	2026-06-15 03:00:02.420683+01	2026-06-15 03:00:02.51441+01	1	0	0	1	0	\N	{"errors": [], "safety": {"body_peek": true, "store_used": false, "imap_readonly": true, "flags_modified": false}, "imported": [], "mailboxes": ["INBOX", "INBOX.Sent"], "duplicates": [{"uid": "1", "mailbox": "INBOX", "occurrence_id": 1}]}
176	1	3	success	2026-06-15 03:05:02.641877+01	2026-06-15 03:05:02.784547+01	1	0	0	1	0	\N	{"errors": [], "safety": {"body_peek": true, "store_used": false, "imap_readonly": true, "flags_modified": false}, "imported": [], "mailboxes": ["INBOX", "INBOX.Sent"], "duplicates": [{"uid": "1", "mailbox": "INBOX", "occurrence_id": 1}]}
177	1	3	success	2026-06-15 03:10:02.886316+01	2026-06-15 03:10:02.94416+01	1	0	0	1	0	\N	{"errors": [], "safety": {"body_peek": true, "store_used": false, "imap_readonly": true, "flags_modified": false}, "imported": [], "mailboxes": ["INBOX", "INBOX.Sent"], "duplicates": [{"uid": "1", "mailbox": "INBOX", "occurrence_id": 1}]}
178	1	3	success	2026-06-15 03:15:03.061157+01	2026-06-15 03:15:03.115822+01	1	0	0	1	0	\N	{"errors": [], "safety": {"body_peek": true, "store_used": false, "imap_readonly": true, "flags_modified": false}, "imported": [], "mailboxes": ["INBOX", "INBOX.Sent"], "duplicates": [{"uid": "1", "mailbox": "INBOX", "occurrence_id": 1}]}
179	1	3	success	2026-06-15 03:20:03.232217+01	2026-06-15 03:20:03.291821+01	1	0	0	1	0	\N	{"errors": [], "safety": {"body_peek": true, "store_used": false, "imap_readonly": true, "flags_modified": false}, "imported": [], "mailboxes": ["INBOX", "INBOX.Sent"], "duplicates": [{"uid": "1", "mailbox": "INBOX", "occurrence_id": 1}]}
180	1	3	success	2026-06-15 03:25:03.3522+01	2026-06-15 03:25:03.417795+01	1	0	0	1	0	\N	{"errors": [], "safety": {"body_peek": true, "store_used": false, "imap_readonly": true, "flags_modified": false}, "imported": [], "mailboxes": ["INBOX", "INBOX.Sent"], "duplicates": [{"uid": "1", "mailbox": "INBOX", "occurrence_id": 1}]}
181	1	3	success	2026-06-15 03:30:03.469948+01	2026-06-15 03:30:03.632295+01	1	0	0	1	0	\N	{"errors": [], "safety": {"body_peek": true, "store_used": false, "imap_readonly": true, "flags_modified": false}, "imported": [], "mailboxes": ["INBOX", "INBOX.Sent"], "duplicates": [{"uid": "1", "mailbox": "INBOX", "occurrence_id": 1}]}
182	1	3	success	2026-06-15 03:35:03.731063+01	2026-06-15 03:35:03.859075+01	1	0	0	1	0	\N	{"errors": [], "safety": {"body_peek": true, "store_used": false, "imap_readonly": true, "flags_modified": false}, "imported": [], "mailboxes": ["INBOX", "INBOX.Sent"], "duplicates": [{"uid": "1", "mailbox": "INBOX", "occurrence_id": 1}]}
183	1	3	success	2026-06-15 03:40:03.986865+01	2026-06-15 03:40:04.117587+01	1	0	0	1	0	\N	{"errors": [], "safety": {"body_peek": true, "store_used": false, "imap_readonly": true, "flags_modified": false}, "imported": [], "mailboxes": ["INBOX", "INBOX.Sent"], "duplicates": [{"uid": "1", "mailbox": "INBOX", "occurrence_id": 1}]}
184	1	3	success	2026-06-15 03:45:04.255845+01	2026-06-15 03:45:04.38642+01	1	0	0	1	0	\N	{"errors": [], "safety": {"body_peek": true, "store_used": false, "imap_readonly": true, "flags_modified": false}, "imported": [], "mailboxes": ["INBOX", "INBOX.Sent"], "duplicates": [{"uid": "1", "mailbox": "INBOX", "occurrence_id": 1}]}
185	1	3	success	2026-06-15 03:50:04.50672+01	2026-06-15 03:50:04.568956+01	1	0	0	1	0	\N	{"errors": [], "safety": {"body_peek": true, "store_used": false, "imap_readonly": true, "flags_modified": false}, "imported": [], "mailboxes": ["INBOX", "INBOX.Sent"], "duplicates": [{"uid": "1", "mailbox": "INBOX", "occurrence_id": 1}]}
186	1	3	success	2026-06-15 03:55:04.687907+01	2026-06-15 03:55:04.772786+01	1	0	0	1	0	\N	{"errors": [], "safety": {"body_peek": true, "store_used": false, "imap_readonly": true, "flags_modified": false}, "imported": [], "mailboxes": ["INBOX", "INBOX.Sent"], "duplicates": [{"uid": "1", "mailbox": "INBOX", "occurrence_id": 1}]}
187	1	3	success	2026-06-15 04:00:04.887098+01	2026-06-15 04:00:05.000654+01	1	0	0	1	0	\N	{"errors": [], "safety": {"body_peek": true, "store_used": false, "imap_readonly": true, "flags_modified": false}, "imported": [], "mailboxes": ["INBOX", "INBOX.Sent"], "duplicates": [{"uid": "1", "mailbox": "INBOX", "occurrence_id": 1}]}
188	1	3	success	2026-06-15 04:05:05.138764+01	2026-06-15 04:05:05.295642+01	1	0	0	1	0	\N	{"errors": [], "safety": {"body_peek": true, "store_used": false, "imap_readonly": true, "flags_modified": false}, "imported": [], "mailboxes": ["INBOX", "INBOX.Sent"], "duplicates": [{"uid": "1", "mailbox": "INBOX", "occurrence_id": 1}]}
189	1	3	success	2026-06-15 04:10:05.418808+01	2026-06-15 04:10:05.471569+01	1	0	0	1	0	\N	{"errors": [], "safety": {"body_peek": true, "store_used": false, "imap_readonly": true, "flags_modified": false}, "imported": [], "mailboxes": ["INBOX", "INBOX.Sent"], "duplicates": [{"uid": "1", "mailbox": "INBOX", "occurrence_id": 1}]}
190	1	3	success	2026-06-15 04:15:05.604407+01	2026-06-15 04:15:05.657596+01	1	0	0	1	0	\N	{"errors": [], "safety": {"body_peek": true, "store_used": false, "imap_readonly": true, "flags_modified": false}, "imported": [], "mailboxes": ["INBOX", "INBOX.Sent"], "duplicates": [{"uid": "1", "mailbox": "INBOX", "occurrence_id": 1}]}
191	1	3	success	2026-06-15 04:20:05.775981+01	2026-06-15 04:20:05.838105+01	1	0	0	1	0	\N	{"errors": [], "safety": {"body_peek": true, "store_used": false, "imap_readonly": true, "flags_modified": false}, "imported": [], "mailboxes": ["INBOX", "INBOX.Sent"], "duplicates": [{"uid": "1", "mailbox": "INBOX", "occurrence_id": 1}]}
192	1	3	success	2026-06-15 04:25:05.954639+01	2026-06-15 04:25:06.037114+01	1	0	0	1	0	\N	{"errors": [], "safety": {"body_peek": true, "store_used": false, "imap_readonly": true, "flags_modified": false}, "imported": [], "mailboxes": ["INBOX", "INBOX.Sent"], "duplicates": [{"uid": "1", "mailbox": "INBOX", "occurrence_id": 1}]}
193	1	3	success	2026-06-15 04:30:06.13492+01	2026-06-15 04:30:06.224728+01	1	0	0	1	0	\N	{"errors": [], "safety": {"body_peek": true, "store_used": false, "imap_readonly": true, "flags_modified": false}, "imported": [], "mailboxes": ["INBOX", "INBOX.Sent"], "duplicates": [{"uid": "1", "mailbox": "INBOX", "occurrence_id": 1}]}
194	1	3	success	2026-06-15 04:35:06.361525+01	2026-06-15 04:35:06.420502+01	1	0	0	1	0	\N	{"errors": [], "safety": {"body_peek": true, "store_used": false, "imap_readonly": true, "flags_modified": false}, "imported": [], "mailboxes": ["INBOX", "INBOX.Sent"], "duplicates": [{"uid": "1", "mailbox": "INBOX", "occurrence_id": 1}]}
195	1	3	success	2026-06-15 04:40:06.536537+01	2026-06-15 04:40:06.587154+01	1	0	0	1	0	\N	{"errors": [], "safety": {"body_peek": true, "store_used": false, "imap_readonly": true, "flags_modified": false}, "imported": [], "mailboxes": ["INBOX", "INBOX.Sent"], "duplicates": [{"uid": "1", "mailbox": "INBOX", "occurrence_id": 1}]}
196	1	3	success	2026-06-15 04:45:06.680951+01	2026-06-15 04:45:06.73141+01	1	0	0	1	0	\N	{"errors": [], "safety": {"body_peek": true, "store_used": false, "imap_readonly": true, "flags_modified": false}, "imported": [], "mailboxes": ["INBOX", "INBOX.Sent"], "duplicates": [{"uid": "1", "mailbox": "INBOX", "occurrence_id": 1}]}
197	1	3	success	2026-06-15 04:50:06.790267+01	2026-06-15 04:50:06.85477+01	1	0	0	1	0	\N	{"errors": [], "safety": {"body_peek": true, "store_used": false, "imap_readonly": true, "flags_modified": false}, "imported": [], "mailboxes": ["INBOX", "INBOX.Sent"], "duplicates": [{"uid": "1", "mailbox": "INBOX", "occurrence_id": 1}]}
198	1	3	success	2026-06-15 04:55:06.971214+01	2026-06-15 04:55:07.027006+01	1	0	0	1	0	\N	{"errors": [], "safety": {"body_peek": true, "store_used": false, "imap_readonly": true, "flags_modified": false}, "imported": [], "mailboxes": ["INBOX", "INBOX.Sent"], "duplicates": [{"uid": "1", "mailbox": "INBOX", "occurrence_id": 1}]}
199	1	3	success	2026-06-15 05:00:07.142282+01	2026-06-15 05:00:07.196303+01	1	0	0	1	0	\N	{"errors": [], "safety": {"body_peek": true, "store_used": false, "imap_readonly": true, "flags_modified": false}, "imported": [], "mailboxes": ["INBOX", "INBOX.Sent"], "duplicates": [{"uid": "1", "mailbox": "INBOX", "occurrence_id": 1}]}
200	1	3	success	2026-06-15 05:05:07.303273+01	2026-06-15 05:05:07.360991+01	1	0	0	1	0	\N	{"errors": [], "safety": {"body_peek": true, "store_used": false, "imap_readonly": true, "flags_modified": false}, "imported": [], "mailboxes": ["INBOX", "INBOX.Sent"], "duplicates": [{"uid": "1", "mailbox": "INBOX", "occurrence_id": 1}]}
201	1	3	success	2026-06-15 05:10:07.465498+01	2026-06-15 05:10:07.575096+01	1	0	0	1	0	\N	{"errors": [], "safety": {"body_peek": true, "store_used": false, "imap_readonly": true, "flags_modified": false}, "imported": [], "mailboxes": ["INBOX", "INBOX.Sent"], "duplicates": [{"uid": "1", "mailbox": "INBOX", "occurrence_id": 1}]}
202	1	3	success	2026-06-15 05:15:07.701744+01	2026-06-15 05:15:07.761357+01	1	0	0	1	0	\N	{"errors": [], "safety": {"body_peek": true, "store_used": false, "imap_readonly": true, "flags_modified": false}, "imported": [], "mailboxes": ["INBOX", "INBOX.Sent"], "duplicates": [{"uid": "1", "mailbox": "INBOX", "occurrence_id": 1}]}
203	1	3	success	2026-06-15 05:20:07.830015+01	2026-06-15 05:20:07.893511+01	1	0	0	1	0	\N	{"errors": [], "safety": {"body_peek": true, "store_used": false, "imap_readonly": true, "flags_modified": false}, "imported": [], "mailboxes": ["INBOX", "INBOX.Sent"], "duplicates": [{"uid": "1", "mailbox": "INBOX", "occurrence_id": 1}]}
204	1	3	success	2026-06-15 05:25:07.985412+01	2026-06-15 05:25:08.036948+01	1	0	0	1	0	\N	{"errors": [], "safety": {"body_peek": true, "store_used": false, "imap_readonly": true, "flags_modified": false}, "imported": [], "mailboxes": ["INBOX", "INBOX.Sent"], "duplicates": [{"uid": "1", "mailbox": "INBOX", "occurrence_id": 1}]}
205	1	3	success	2026-06-15 05:30:08.176155+01	2026-06-15 05:30:08.233623+01	1	0	0	1	0	\N	{"errors": [], "safety": {"body_peek": true, "store_used": false, "imap_readonly": true, "flags_modified": false}, "imported": [], "mailboxes": ["INBOX", "INBOX.Sent"], "duplicates": [{"uid": "1", "mailbox": "INBOX", "occurrence_id": 1}]}
206	1	3	success	2026-06-15 05:35:08.36011+01	2026-06-15 05:35:08.499556+01	1	0	0	1	0	\N	{"errors": [], "safety": {"body_peek": true, "store_used": false, "imap_readonly": true, "flags_modified": false}, "imported": [], "mailboxes": ["INBOX", "INBOX.Sent"], "duplicates": [{"uid": "1", "mailbox": "INBOX", "occurrence_id": 1}]}
207	1	3	success	2026-06-15 05:40:08.625164+01	2026-06-15 05:40:08.678486+01	1	0	0	1	0	\N	{"errors": [], "safety": {"body_peek": true, "store_used": false, "imap_readonly": true, "flags_modified": false}, "imported": [], "mailboxes": ["INBOX", "INBOX.Sent"], "duplicates": [{"uid": "1", "mailbox": "INBOX", "occurrence_id": 1}]}
208	1	3	success	2026-06-15 05:45:08.821389+01	2026-06-15 05:45:08.873985+01	1	0	0	1	0	\N	{"errors": [], "safety": {"body_peek": true, "store_used": false, "imap_readonly": true, "flags_modified": false}, "imported": [], "mailboxes": ["INBOX", "INBOX.Sent"], "duplicates": [{"uid": "1", "mailbox": "INBOX", "occurrence_id": 1}]}
209	1	3	success	2026-06-15 05:50:09.015048+01	2026-06-15 05:50:09.071973+01	1	0	0	1	0	\N	{"errors": [], "safety": {"body_peek": true, "store_used": false, "imap_readonly": true, "flags_modified": false}, "imported": [], "mailboxes": ["INBOX", "INBOX.Sent"], "duplicates": [{"uid": "1", "mailbox": "INBOX", "occurrence_id": 1}]}
210	1	3	success	2026-06-15 05:55:09.188926+01	2026-06-15 05:55:09.244703+01	1	0	0	1	0	\N	{"errors": [], "safety": {"body_peek": true, "store_used": false, "imap_readonly": true, "flags_modified": false}, "imported": [], "mailboxes": ["INBOX", "INBOX.Sent"], "duplicates": [{"uid": "1", "mailbox": "INBOX", "occurrence_id": 1}]}
211	1	3	success	2026-06-15 06:00:09.370963+01	2026-06-15 06:00:09.426717+01	1	0	0	1	0	\N	{"errors": [], "safety": {"body_peek": true, "store_used": false, "imap_readonly": true, "flags_modified": false}, "imported": [], "mailboxes": ["INBOX", "INBOX.Sent"], "duplicates": [{"uid": "1", "mailbox": "INBOX", "occurrence_id": 1}]}
212	1	3	success	2026-06-15 06:05:09.550421+01	2026-06-15 06:05:09.605174+01	1	0	0	1	0	\N	{"errors": [], "safety": {"body_peek": true, "store_used": false, "imap_readonly": true, "flags_modified": false}, "imported": [], "mailboxes": ["INBOX", "INBOX.Sent"], "duplicates": [{"uid": "1", "mailbox": "INBOX", "occurrence_id": 1}]}
213	1	3	success	2026-06-15 06:10:09.715619+01	2026-06-15 06:10:09.76976+01	1	0	0	1	0	\N	{"errors": [], "safety": {"body_peek": true, "store_used": false, "imap_readonly": true, "flags_modified": false}, "imported": [], "mailboxes": ["INBOX", "INBOX.Sent"], "duplicates": [{"uid": "1", "mailbox": "INBOX", "occurrence_id": 1}]}
214	1	3	success	2026-06-15 06:15:09.89027+01	2026-06-15 06:15:09.997967+01	1	0	0	1	0	\N	{"errors": [], "safety": {"body_peek": true, "store_used": false, "imap_readonly": true, "flags_modified": false}, "imported": [], "mailboxes": ["INBOX", "INBOX.Sent"], "duplicates": [{"uid": "1", "mailbox": "INBOX", "occurrence_id": 1}]}
215	1	3	success	2026-06-15 06:20:10.130711+01	2026-06-15 06:20:10.181947+01	1	0	0	1	0	\N	{"errors": [], "safety": {"body_peek": true, "store_used": false, "imap_readonly": true, "flags_modified": false}, "imported": [], "mailboxes": ["INBOX", "INBOX.Sent"], "duplicates": [{"uid": "1", "mailbox": "INBOX", "occurrence_id": 1}]}
216	1	3	success	2026-06-15 06:25:10.307962+01	2026-06-15 06:25:10.360681+01	1	0	0	1	0	\N	{"errors": [], "safety": {"body_peek": true, "store_used": false, "imap_readonly": true, "flags_modified": false}, "imported": [], "mailboxes": ["INBOX", "INBOX.Sent"], "duplicates": [{"uid": "1", "mailbox": "INBOX", "occurrence_id": 1}]}
217	1	3	success	2026-06-15 06:30:10.492181+01	2026-06-15 06:30:10.60483+01	1	0	0	1	0	\N	{"errors": [], "safety": {"body_peek": true, "store_used": false, "imap_readonly": true, "flags_modified": false}, "imported": [], "mailboxes": ["INBOX", "INBOX.Sent"], "duplicates": [{"uid": "1", "mailbox": "INBOX", "occurrence_id": 1}]}
218	1	3	success	2026-06-15 06:35:10.724834+01	2026-06-15 06:35:10.841507+01	1	0	0	1	0	\N	{"errors": [], "safety": {"body_peek": true, "store_used": false, "imap_readonly": true, "flags_modified": false}, "imported": [], "mailboxes": ["INBOX", "INBOX.Sent"], "duplicates": [{"uid": "1", "mailbox": "INBOX", "occurrence_id": 1}]}
219	1	3	success	2026-06-15 06:40:10.96221+01	2026-06-15 06:40:11.016879+01	1	0	0	1	0	\N	{"errors": [], "safety": {"body_peek": true, "store_used": false, "imap_readonly": true, "flags_modified": false}, "imported": [], "mailboxes": ["INBOX", "INBOX.Sent"], "duplicates": [{"uid": "1", "mailbox": "INBOX", "occurrence_id": 1}]}
220	1	3	success	2026-06-15 06:45:11.160694+01	2026-06-15 06:45:11.252095+01	1	0	0	1	0	\N	{"errors": [], "safety": {"body_peek": true, "store_used": false, "imap_readonly": true, "flags_modified": false}, "imported": [], "mailboxes": ["INBOX", "INBOX.Sent"], "duplicates": [{"uid": "1", "mailbox": "INBOX", "occurrence_id": 1}]}
221	1	3	success	2026-06-15 06:50:11.381822+01	2026-06-15 06:50:11.502617+01	1	0	0	1	0	\N	{"errors": [], "safety": {"body_peek": true, "store_used": false, "imap_readonly": true, "flags_modified": false}, "imported": [], "mailboxes": ["INBOX", "INBOX.Sent"], "duplicates": [{"uid": "1", "mailbox": "INBOX", "occurrence_id": 1}]}
222	1	3	success	2026-06-15 06:55:11.637127+01	2026-06-15 06:55:11.701642+01	1	0	0	1	0	\N	{"errors": [], "safety": {"body_peek": true, "store_used": false, "imap_readonly": true, "flags_modified": false}, "imported": [], "mailboxes": ["INBOX", "INBOX.Sent"], "duplicates": [{"uid": "1", "mailbox": "INBOX", "occurrence_id": 1}]}
223	1	3	success	2026-06-15 07:00:11.813066+01	2026-06-15 07:00:11.924399+01	1	0	0	1	0	\N	{"errors": [], "safety": {"body_peek": true, "store_used": false, "imap_readonly": true, "flags_modified": false}, "imported": [], "mailboxes": ["INBOX", "INBOX.Sent"], "duplicates": [{"uid": "1", "mailbox": "INBOX", "occurrence_id": 1}]}
224	1	3	success	2026-06-15 07:05:12.05713+01	2026-06-15 07:05:12.153564+01	1	0	0	1	0	\N	{"errors": [], "safety": {"body_peek": true, "store_used": false, "imap_readonly": true, "flags_modified": false}, "imported": [], "mailboxes": ["INBOX", "INBOX.Sent"], "duplicates": [{"uid": "1", "mailbox": "INBOX", "occurrence_id": 1}]}
225	1	3	success	2026-06-15 07:10:12.27808+01	2026-06-15 07:10:12.389792+01	1	0	0	1	0	\N	{"errors": [], "safety": {"body_peek": true, "store_used": false, "imap_readonly": true, "flags_modified": false}, "imported": [], "mailboxes": ["INBOX", "INBOX.Sent"], "duplicates": [{"uid": "1", "mailbox": "INBOX", "occurrence_id": 1}]}
226	1	3	success	2026-06-15 07:15:12.495128+01	2026-06-15 07:15:12.651169+01	1	0	0	1	0	\N	{"errors": [], "safety": {"body_peek": true, "store_used": false, "imap_readonly": true, "flags_modified": false}, "imported": [], "mailboxes": ["INBOX", "INBOX.Sent"], "duplicates": [{"uid": "1", "mailbox": "INBOX", "occurrence_id": 1}]}
227	1	3	success	2026-06-15 07:20:12.762107+01	2026-06-15 07:20:12.85203+01	1	0	0	1	0	\N	{"errors": [], "safety": {"body_peek": true, "store_used": false, "imap_readonly": true, "flags_modified": false}, "imported": [], "mailboxes": ["INBOX", "INBOX.Sent"], "duplicates": [{"uid": "1", "mailbox": "INBOX", "occurrence_id": 1}]}
228	1	3	success	2026-06-15 07:25:12.978945+01	2026-06-15 07:25:13.063953+01	1	0	0	1	0	\N	{"errors": [], "safety": {"body_peek": true, "store_used": false, "imap_readonly": true, "flags_modified": false}, "imported": [], "mailboxes": ["INBOX", "INBOX.Sent"], "duplicates": [{"uid": "1", "mailbox": "INBOX", "occurrence_id": 1}]}
229	1	3	success	2026-06-15 07:30:13.185145+01	2026-06-15 07:30:13.248576+01	1	0	0	1	0	\N	{"errors": [], "safety": {"body_peek": true, "store_used": false, "imap_readonly": true, "flags_modified": false}, "imported": [], "mailboxes": ["INBOX", "INBOX.Sent"], "duplicates": [{"uid": "1", "mailbox": "INBOX", "occurrence_id": 1}]}
230	1	3	success	2026-06-15 07:35:13.364043+01	2026-06-15 07:35:13.42792+01	1	0	0	1	0	\N	{"errors": [], "safety": {"body_peek": true, "store_used": false, "imap_readonly": true, "flags_modified": false}, "imported": [], "mailboxes": ["INBOX", "INBOX.Sent"], "duplicates": [{"uid": "1", "mailbox": "INBOX", "occurrence_id": 1}]}
231	1	3	success	2026-06-15 07:40:13.492601+01	2026-06-15 07:40:13.633187+01	1	0	0	1	0	\N	{"errors": [], "safety": {"body_peek": true, "store_used": false, "imap_readonly": true, "flags_modified": false}, "imported": [], "mailboxes": ["INBOX", "INBOX.Sent"], "duplicates": [{"uid": "1", "mailbox": "INBOX", "occurrence_id": 1}]}
232	1	3	success	2026-06-15 07:45:13.695735+01	2026-06-15 07:45:13.764012+01	1	0	0	1	0	\N	{"errors": [], "safety": {"body_peek": true, "store_used": false, "imap_readonly": true, "flags_modified": false}, "imported": [], "mailboxes": ["INBOX", "INBOX.Sent"], "duplicates": [{"uid": "1", "mailbox": "INBOX", "occurrence_id": 1}]}
233	1	3	success	2026-06-15 07:50:13.82682+01	2026-06-15 07:50:13.887849+01	1	0	0	1	0	\N	{"errors": [], "safety": {"body_peek": true, "store_used": false, "imap_readonly": true, "flags_modified": false}, "imported": [], "mailboxes": ["INBOX", "INBOX.Sent"], "duplicates": [{"uid": "1", "mailbox": "INBOX", "occurrence_id": 1}]}
234	1	3	success	2026-06-15 07:55:13.948196+01	2026-06-15 07:55:14.00434+01	1	0	0	1	0	\N	{"errors": [], "safety": {"body_peek": true, "store_used": false, "imap_readonly": true, "flags_modified": false}, "imported": [], "mailboxes": ["INBOX", "INBOX.Sent"], "duplicates": [{"uid": "1", "mailbox": "INBOX", "occurrence_id": 1}]}
235	1	3	success	2026-06-15 08:00:14.064214+01	2026-06-15 08:00:14.116455+01	1	0	0	1	0	\N	{"errors": [], "safety": {"body_peek": true, "store_used": false, "imap_readonly": true, "flags_modified": false}, "imported": [], "mailboxes": ["INBOX", "INBOX.Sent"], "duplicates": [{"uid": "1", "mailbox": "INBOX", "occurrence_id": 1}]}
236	1	3	success	2026-06-15 08:05:14.175804+01	2026-06-15 08:05:14.227806+01	1	0	0	1	0	\N	{"errors": [], "safety": {"body_peek": true, "store_used": false, "imap_readonly": true, "flags_modified": false}, "imported": [], "mailboxes": ["INBOX", "INBOX.Sent"], "duplicates": [{"uid": "1", "mailbox": "INBOX", "occurrence_id": 1}]}
237	1	3	success	2026-06-15 08:10:14.294335+01	2026-06-15 08:10:14.351611+01	1	0	0	1	0	\N	{"errors": [], "safety": {"body_peek": true, "store_used": false, "imap_readonly": true, "flags_modified": false}, "imported": [], "mailboxes": ["INBOX", "INBOX.Sent"], "duplicates": [{"uid": "1", "mailbox": "INBOX", "occurrence_id": 1}]}
238	1	3	success	2026-06-15 08:15:14.41115+01	2026-06-15 08:15:14.491147+01	1	0	0	1	0	\N	{"errors": [], "safety": {"body_peek": true, "store_used": false, "imap_readonly": true, "flags_modified": false}, "imported": [], "mailboxes": ["INBOX", "INBOX.Sent"], "duplicates": [{"uid": "1", "mailbox": "INBOX", "occurrence_id": 1}]}
239	1	3	success	2026-06-15 08:20:14.585728+01	2026-06-15 08:20:14.642157+01	1	0	0	1	0	\N	{"errors": [], "safety": {"body_peek": true, "store_used": false, "imap_readonly": true, "flags_modified": false}, "imported": [], "mailboxes": ["INBOX", "INBOX.Sent"], "duplicates": [{"uid": "1", "mailbox": "INBOX", "occurrence_id": 1}]}
240	1	3	success	2026-06-15 08:25:14.756512+01	2026-06-15 08:25:14.808601+01	1	0	0	1	0	\N	{"errors": [], "safety": {"body_peek": true, "store_used": false, "imap_readonly": true, "flags_modified": false}, "imported": [], "mailboxes": ["INBOX", "INBOX.Sent"], "duplicates": [{"uid": "1", "mailbox": "INBOX", "occurrence_id": 1}]}
241	1	3	success	2026-06-15 08:30:14.92839+01	2026-06-15 08:30:14.983108+01	1	0	0	1	0	\N	{"errors": [], "safety": {"body_peek": true, "store_used": false, "imap_readonly": true, "flags_modified": false}, "imported": [], "mailboxes": ["INBOX", "INBOX.Sent"], "duplicates": [{"uid": "1", "mailbox": "INBOX", "occurrence_id": 1}]}
242	1	3	success	2026-06-15 08:35:15.097993+01	2026-06-15 08:35:15.19882+01	1	0	0	1	0	\N	{"errors": [], "safety": {"body_peek": true, "store_used": false, "imap_readonly": true, "flags_modified": false}, "imported": [], "mailboxes": ["INBOX", "INBOX.Sent"], "duplicates": [{"uid": "1", "mailbox": "INBOX", "occurrence_id": 1}]}
243	1	3	success	2026-06-15 08:40:15.318133+01	2026-06-15 08:40:15.40044+01	1	0	0	1	0	\N	{"errors": [], "safety": {"body_peek": true, "store_used": false, "imap_readonly": true, "flags_modified": false}, "imported": [], "mailboxes": ["INBOX", "INBOX.Sent"], "duplicates": [{"uid": "1", "mailbox": "INBOX", "occurrence_id": 1}]}
244	1	3	success	2026-06-15 08:45:15.526586+01	2026-06-15 08:45:15.578607+01	1	0	0	1	0	\N	{"errors": [], "safety": {"body_peek": true, "store_used": false, "imap_readonly": true, "flags_modified": false}, "imported": [], "mailboxes": ["INBOX", "INBOX.Sent"], "duplicates": [{"uid": "1", "mailbox": "INBOX", "occurrence_id": 1}]}
245	1	3	success	2026-06-15 08:50:15.702468+01	2026-06-15 08:50:15.758709+01	1	0	0	1	0	\N	{"errors": [], "safety": {"body_peek": true, "store_used": false, "imap_readonly": true, "flags_modified": false}, "imported": [], "mailboxes": ["INBOX", "INBOX.Sent"], "duplicates": [{"uid": "1", "mailbox": "INBOX", "occurrence_id": 1}]}
246	1	3	success	2026-06-15 08:55:15.893205+01	2026-06-15 08:55:15.946597+01	1	0	0	1	0	\N	{"errors": [], "safety": {"body_peek": true, "store_used": false, "imap_readonly": true, "flags_modified": false}, "imported": [], "mailboxes": ["INBOX", "INBOX.Sent"], "duplicates": [{"uid": "1", "mailbox": "INBOX", "occurrence_id": 1}]}
247	1	3	success	2026-06-15 09:00:16.079164+01	2026-06-15 09:00:16.177273+01	1	0	0	1	0	\N	{"errors": [], "safety": {"body_peek": true, "store_used": false, "imap_readonly": true, "flags_modified": false}, "imported": [], "mailboxes": ["INBOX", "INBOX.Sent"], "duplicates": [{"uid": "1", "mailbox": "INBOX", "occurrence_id": 1}]}
248	1	3	success	2026-06-15 09:05:16.291407+01	2026-06-15 09:05:16.384484+01	1	0	0	1	0	\N	{"errors": [], "safety": {"body_peek": true, "store_used": false, "imap_readonly": true, "flags_modified": false}, "imported": [], "mailboxes": ["INBOX", "INBOX.Sent"], "duplicates": [{"uid": "1", "mailbox": "INBOX", "occurrence_id": 1}]}
249	1	3	success	2026-06-15 09:10:16.500479+01	2026-06-15 09:10:16.551769+01	1	0	0	1	0	\N	{"errors": [], "safety": {"body_peek": true, "store_used": false, "imap_readonly": true, "flags_modified": false}, "imported": [], "mailboxes": ["INBOX", "INBOX.Sent"], "duplicates": [{"uid": "1", "mailbox": "INBOX", "occurrence_id": 1}]}
250	1	3	success	2026-06-15 09:15:16.655394+01	2026-06-15 09:15:16.707872+01	1	0	0	1	0	\N	{"errors": [], "safety": {"body_peek": true, "store_used": false, "imap_readonly": true, "flags_modified": false}, "imported": [], "mailboxes": ["INBOX", "INBOX.Sent"], "duplicates": [{"uid": "1", "mailbox": "INBOX", "occurrence_id": 1}]}
251	1	3	success	2026-06-15 09:20:16.845147+01	2026-06-15 09:20:16.898775+01	1	0	0	1	0	\N	{"errors": [], "safety": {"body_peek": true, "store_used": false, "imap_readonly": true, "flags_modified": false}, "imported": [], "mailboxes": ["INBOX", "INBOX.Sent"], "duplicates": [{"uid": "1", "mailbox": "INBOX", "occurrence_id": 1}]}
252	1	3	success	2026-06-15 09:25:17.00727+01	2026-06-15 09:25:17.062506+01	1	0	0	1	0	\N	{"errors": [], "safety": {"body_peek": true, "store_used": false, "imap_readonly": true, "flags_modified": false}, "imported": [], "mailboxes": ["INBOX", "INBOX.Sent"], "duplicates": [{"uid": "1", "mailbox": "INBOX", "occurrence_id": 1}]}
253	1	3	success	2026-06-15 09:30:17.196679+01	2026-06-15 09:30:17.253135+01	1	0	0	1	0	\N	{"errors": [], "safety": {"body_peek": true, "store_used": false, "imap_readonly": true, "flags_modified": false}, "imported": [], "mailboxes": ["INBOX", "INBOX.Sent"], "duplicates": [{"uid": "1", "mailbox": "INBOX", "occurrence_id": 1}]}
254	1	3	success	2026-06-15 09:35:17.367652+01	2026-06-15 09:35:17.418667+01	1	0	0	1	0	\N	{"errors": [], "safety": {"body_peek": true, "store_used": false, "imap_readonly": true, "flags_modified": false}, "imported": [], "mailboxes": ["INBOX", "INBOX.Sent"], "duplicates": [{"uid": "1", "mailbox": "INBOX", "occurrence_id": 1}]}
255	1	3	success	2026-06-15 09:40:17.548489+01	2026-06-15 09:40:17.63561+01	1	0	0	1	0	\N	{"errors": [], "safety": {"body_peek": true, "store_used": false, "imap_readonly": true, "flags_modified": false}, "imported": [], "mailboxes": ["INBOX", "INBOX.Sent"], "duplicates": [{"uid": "1", "mailbox": "INBOX", "occurrence_id": 1}]}
256	1	3	success	2026-06-15 09:45:17.760996+01	2026-06-15 09:45:17.826016+01	1	0	0	1	0	\N	{"errors": [], "safety": {"body_peek": true, "store_used": false, "imap_readonly": true, "flags_modified": false}, "imported": [], "mailboxes": ["INBOX", "INBOX.Sent"], "duplicates": [{"uid": "1", "mailbox": "INBOX", "occurrence_id": 1}]}
257	1	3	success	2026-06-15 09:50:17.937423+01	2026-06-15 09:50:17.995755+01	1	0	0	1	0	\N	{"errors": [], "safety": {"body_peek": true, "store_used": false, "imap_readonly": true, "flags_modified": false}, "imported": [], "mailboxes": ["INBOX", "INBOX.Sent"], "duplicates": [{"uid": "1", "mailbox": "INBOX", "occurrence_id": 1}]}
258	1	3	success	2026-06-15 09:55:18.10711+01	2026-06-15 09:55:18.159778+01	1	0	0	1	0	\N	{"errors": [], "safety": {"body_peek": true, "store_used": false, "imap_readonly": true, "flags_modified": false}, "imported": [], "mailboxes": ["INBOX", "INBOX.Sent"], "duplicates": [{"uid": "1", "mailbox": "INBOX", "occurrence_id": 1}]}
259	1	3	success	2026-06-15 10:00:18.254452+01	2026-06-15 10:00:18.309658+01	1	0	0	1	0	\N	{"errors": [], "safety": {"body_peek": true, "store_used": false, "imap_readonly": true, "flags_modified": false}, "imported": [], "mailboxes": ["INBOX", "INBOX.Sent"], "duplicates": [{"uid": "1", "mailbox": "INBOX", "occurrence_id": 1}]}
260	1	3	success	2026-06-15 10:05:18.411966+01	2026-06-15 10:05:18.465208+01	1	0	0	1	0	\N	{"errors": [], "safety": {"body_peek": true, "store_used": false, "imap_readonly": true, "flags_modified": false}, "imported": [], "mailboxes": ["INBOX", "INBOX.Sent"], "duplicates": [{"uid": "1", "mailbox": "INBOX", "occurrence_id": 1}]}
261	1	3	success	2026-06-15 10:10:18.569527+01	2026-06-15 10:10:18.673305+01	1	0	0	1	0	\N	{"errors": [], "safety": {"body_peek": true, "store_used": false, "imap_readonly": true, "flags_modified": false}, "imported": [], "mailboxes": ["INBOX", "INBOX.Sent"], "duplicates": [{"uid": "1", "mailbox": "INBOX", "occurrence_id": 1}]}
262	1	3	success	2026-06-15 10:15:18.797272+01	2026-06-15 10:15:18.853738+01	1	0	0	1	0	\N	{"errors": [], "safety": {"body_peek": true, "store_used": false, "imap_readonly": true, "flags_modified": false}, "imported": [], "mailboxes": ["INBOX", "INBOX.Sent"], "duplicates": [{"uid": "1", "mailbox": "INBOX", "occurrence_id": 1}]}
263	1	3	success	2026-06-15 10:20:18.981975+01	2026-06-15 10:20:19.036026+01	1	0	0	1	0	\N	{"errors": [], "safety": {"body_peek": true, "store_used": false, "imap_readonly": true, "flags_modified": false}, "imported": [], "mailboxes": ["INBOX", "INBOX.Sent"], "duplicates": [{"uid": "1", "mailbox": "INBOX", "occurrence_id": 1}]}
264	1	3	success	2026-06-15 10:25:19.137186+01	2026-06-15 10:25:19.186903+01	1	0	0	1	0	\N	{"errors": [], "safety": {"body_peek": true, "store_used": false, "imap_readonly": true, "flags_modified": false}, "imported": [], "mailboxes": ["INBOX", "INBOX.Sent"], "duplicates": [{"uid": "1", "mailbox": "INBOX", "occurrence_id": 1}]}
265	1	3	success	2026-06-15 10:30:19.316016+01	2026-06-15 10:30:19.387658+01	1	0	0	1	0	\N	{"errors": [], "safety": {"body_peek": true, "store_used": false, "imap_readonly": true, "flags_modified": false}, "imported": [], "mailboxes": ["INBOX", "INBOX.Sent"], "duplicates": [{"uid": "1", "mailbox": "INBOX", "occurrence_id": 1}]}
266	1	3	success	2026-06-15 10:35:19.50214+01	2026-06-15 10:35:19.583812+01	1	0	0	1	0	\N	{"errors": [], "safety": {"body_peek": true, "store_used": false, "imap_readonly": true, "flags_modified": false}, "imported": [], "mailboxes": ["INBOX", "INBOX.Sent"], "duplicates": [{"uid": "1", "mailbox": "INBOX", "occurrence_id": 1}]}
267	1	3	success	2026-06-15 10:40:19.708815+01	2026-06-15 10:40:19.76249+01	1	0	0	1	0	\N	{"errors": [], "safety": {"body_peek": true, "store_used": false, "imap_readonly": true, "flags_modified": false}, "imported": [], "mailboxes": ["INBOX", "INBOX.Sent"], "duplicates": [{"uid": "1", "mailbox": "INBOX", "occurrence_id": 1}]}
268	1	3	success	2026-06-15 10:45:19.880232+01	2026-06-15 10:45:19.981462+01	1	0	0	1	0	\N	{"errors": [], "safety": {"body_peek": true, "store_used": false, "imap_readonly": true, "flags_modified": false}, "imported": [], "mailboxes": ["INBOX", "INBOX.Sent"], "duplicates": [{"uid": "1", "mailbox": "INBOX", "occurrence_id": 1}]}
269	1	3	success	2026-06-15 10:50:20.088288+01	2026-06-15 10:50:20.166188+01	1	0	0	1	0	\N	{"errors": [], "safety": {"body_peek": true, "store_used": false, "imap_readonly": true, "flags_modified": false}, "imported": [], "mailboxes": ["INBOX", "INBOX.Sent"], "duplicates": [{"uid": "1", "mailbox": "INBOX", "occurrence_id": 1}]}
270	1	3	success	2026-06-15 10:55:20.281051+01	2026-06-15 10:55:20.34286+01	1	0	0	1	0	\N	{"errors": [], "safety": {"body_peek": true, "store_used": false, "imap_readonly": true, "flags_modified": false}, "imported": [], "mailboxes": ["INBOX", "INBOX.Sent"], "duplicates": [{"uid": "1", "mailbox": "INBOX", "occurrence_id": 1}]}
271	1	3	success	2026-06-15 11:00:20.458085+01	2026-06-15 11:00:20.517475+01	1	0	0	1	0	\N	{"errors": [], "safety": {"body_peek": true, "store_used": false, "imap_readonly": true, "flags_modified": false}, "imported": [], "mailboxes": ["INBOX", "INBOX.Sent"], "duplicates": [{"uid": "1", "mailbox": "INBOX", "occurrence_id": 1}]}
272	1	3	success	2026-06-15 11:05:20.638423+01	2026-06-15 11:05:20.71008+01	1	0	0	1	0	\N	{"errors": [], "safety": {"body_peek": true, "store_used": false, "imap_readonly": true, "flags_modified": false}, "imported": [], "mailboxes": ["INBOX", "INBOX.Sent"], "duplicates": [{"uid": "1", "mailbox": "INBOX", "occurrence_id": 1}]}
273	1	3	success	2026-06-15 11:10:20.810355+01	2026-06-15 11:10:20.893193+01	1	0	0	1	0	\N	{"errors": [], "safety": {"body_peek": true, "store_used": false, "imap_readonly": true, "flags_modified": false}, "imported": [], "mailboxes": ["INBOX", "INBOX.Sent"], "duplicates": [{"uid": "1", "mailbox": "INBOX", "occurrence_id": 1}]}
274	1	3	success	2026-06-15 11:15:21.015447+01	2026-06-15 11:15:21.082782+01	1	0	0	1	0	\N	{"errors": [], "safety": {"body_peek": true, "store_used": false, "imap_readonly": true, "flags_modified": false}, "imported": [], "mailboxes": ["INBOX", "INBOX.Sent"], "duplicates": [{"uid": "1", "mailbox": "INBOX", "occurrence_id": 1}]}
275	1	3	success	2026-06-15 11:20:21.213173+01	2026-06-15 11:20:21.264671+01	1	0	0	1	0	\N	{"errors": [], "safety": {"body_peek": true, "store_used": false, "imap_readonly": true, "flags_modified": false}, "imported": [], "mailboxes": ["INBOX", "INBOX.Sent"], "duplicates": [{"uid": "1", "mailbox": "INBOX", "occurrence_id": 1}]}
276	1	3	success	2026-06-15 11:25:21.385203+01	2026-06-15 11:25:21.437214+01	1	0	0	1	0	\N	{"errors": [], "safety": {"body_peek": true, "store_used": false, "imap_readonly": true, "flags_modified": false}, "imported": [], "mailboxes": ["INBOX", "INBOX.Sent"], "duplicates": [{"uid": "1", "mailbox": "INBOX", "occurrence_id": 1}]}
277	1	3	success	2026-06-15 11:30:21.547663+01	2026-06-15 11:30:21.60755+01	1	0	0	1	0	\N	{"errors": [], "safety": {"body_peek": true, "store_used": false, "imap_readonly": true, "flags_modified": false}, "imported": [], "mailboxes": ["INBOX", "INBOX.Sent"], "duplicates": [{"uid": "1", "mailbox": "INBOX", "occurrence_id": 1}]}
278	1	3	success	2026-06-15 11:35:21.734619+01	2026-06-15 11:35:21.790723+01	1	0	0	1	0	\N	{"errors": [], "safety": {"body_peek": true, "store_used": false, "imap_readonly": true, "flags_modified": false}, "imported": [], "mailboxes": ["INBOX", "INBOX.Sent"], "duplicates": [{"uid": "1", "mailbox": "INBOX", "occurrence_id": 1}]}
279	1	3	success	2026-06-15 11:40:21.900561+01	2026-06-15 11:40:21.956064+01	1	0	0	1	0	\N	{"errors": [], "safety": {"body_peek": true, "store_used": false, "imap_readonly": true, "flags_modified": false}, "imported": [], "mailboxes": ["INBOX", "INBOX.Sent"], "duplicates": [{"uid": "1", "mailbox": "INBOX", "occurrence_id": 1}]}
280	1	3	success	2026-06-15 11:45:22.049949+01	2026-06-15 11:45:22.103428+01	1	0	0	1	0	\N	{"errors": [], "safety": {"body_peek": true, "store_used": false, "imap_readonly": true, "flags_modified": false}, "imported": [], "mailboxes": ["INBOX", "INBOX.Sent"], "duplicates": [{"uid": "1", "mailbox": "INBOX", "occurrence_id": 1}]}
281	1	3	success	2026-06-15 11:50:22.223428+01	2026-06-15 11:50:22.322553+01	1	0	0	1	0	\N	{"errors": [], "safety": {"body_peek": true, "store_used": false, "imap_readonly": true, "flags_modified": false}, "imported": [], "mailboxes": ["INBOX", "INBOX.Sent"], "duplicates": [{"uid": "1", "mailbox": "INBOX", "occurrence_id": 1}]}
282	1	3	success	2026-06-15 11:55:22.429665+01	2026-06-15 11:55:22.486717+01	1	0	0	1	0	\N	{"errors": [], "safety": {"body_peek": true, "store_used": false, "imap_readonly": true, "flags_modified": false}, "imported": [], "mailboxes": ["INBOX", "INBOX.Sent"], "duplicates": [{"uid": "1", "mailbox": "INBOX", "occurrence_id": 1}]}
283	1	3	success	2026-06-15 12:00:22.594374+01	2026-06-15 12:00:22.650515+01	1	0	0	1	0	\N	{"errors": [], "safety": {"body_peek": true, "store_used": false, "imap_readonly": true, "flags_modified": false}, "imported": [], "mailboxes": ["INBOX", "INBOX.Sent"], "duplicates": [{"uid": "1", "mailbox": "INBOX", "occurrence_id": 1}]}
284	1	3	success	2026-06-15 12:05:22.762461+01	2026-06-15 12:05:22.862231+01	1	0	0	1	0	\N	{"errors": [], "safety": {"body_peek": true, "store_used": false, "imap_readonly": true, "flags_modified": false}, "imported": [], "mailboxes": ["INBOX", "INBOX.Sent"], "duplicates": [{"uid": "1", "mailbox": "INBOX", "occurrence_id": 1}]}
285	1	3	success	2026-06-15 12:10:22.982516+01	2026-06-15 12:10:23.035167+01	1	0	0	1	0	\N	{"errors": [], "safety": {"body_peek": true, "store_used": false, "imap_readonly": true, "flags_modified": false}, "imported": [], "mailboxes": ["INBOX", "INBOX.Sent"], "duplicates": [{"uid": "1", "mailbox": "INBOX", "occurrence_id": 1}]}
286	1	3	success	2026-06-15 12:15:23.105093+01	2026-06-15 12:15:23.161086+01	1	0	0	1	0	\N	{"errors": [], "safety": {"body_peek": true, "store_used": false, "imap_readonly": true, "flags_modified": false}, "imported": [], "mailboxes": ["INBOX", "INBOX.Sent"], "duplicates": [{"uid": "1", "mailbox": "INBOX", "occurrence_id": 1}]}
287	1	3	success	2026-06-15 12:20:23.233208+01	2026-06-15 12:20:23.288118+01	1	0	0	1	0	\N	{"errors": [], "safety": {"body_peek": true, "store_used": false, "imap_readonly": true, "flags_modified": false}, "imported": [], "mailboxes": ["INBOX", "INBOX.Sent"], "duplicates": [{"uid": "1", "mailbox": "INBOX", "occurrence_id": 1}]}
288	1	3	success	2026-06-15 12:25:23.408478+01	2026-06-15 12:25:23.460526+01	1	0	0	1	0	\N	{"errors": [], "safety": {"body_peek": true, "store_used": false, "imap_readonly": true, "flags_modified": false}, "imported": [], "mailboxes": ["INBOX", "INBOX.Sent"], "duplicates": [{"uid": "1", "mailbox": "INBOX", "occurrence_id": 1}]}
289	1	3	success	2026-06-15 12:30:23.580075+01	2026-06-15 12:30:23.690214+01	1	0	0	1	0	\N	{"errors": [], "safety": {"body_peek": true, "store_used": false, "imap_readonly": true, "flags_modified": false}, "imported": [], "mailboxes": ["INBOX", "INBOX.Sent"], "duplicates": [{"uid": "1", "mailbox": "INBOX", "occurrence_id": 1}]}
290	1	3	success	2026-06-15 12:35:23.807627+01	2026-06-15 12:35:23.895712+01	1	0	0	1	0	\N	{"errors": [], "safety": {"body_peek": true, "store_used": false, "imap_readonly": true, "flags_modified": false}, "imported": [], "mailboxes": ["INBOX", "INBOX.Sent"], "duplicates": [{"uid": "1", "mailbox": "INBOX", "occurrence_id": 1}]}
291	1	3	success	2026-06-15 12:40:24.003799+01	2026-06-15 12:40:24.086669+01	1	0	0	1	0	\N	{"errors": [], "safety": {"body_peek": true, "store_used": false, "imap_readonly": true, "flags_modified": false}, "imported": [], "mailboxes": ["INBOX", "INBOX.Sent"], "duplicates": [{"uid": "1", "mailbox": "INBOX", "occurrence_id": 1}]}
292	1	3	success	2026-06-15 12:45:24.202391+01	2026-06-15 12:45:24.311796+01	1	0	0	1	0	\N	{"errors": [], "safety": {"body_peek": true, "store_used": false, "imap_readonly": true, "flags_modified": false}, "imported": [], "mailboxes": ["INBOX", "INBOX.Sent"], "duplicates": [{"uid": "1", "mailbox": "INBOX", "occurrence_id": 1}]}
293	1	3	success	2026-06-15 12:50:24.419938+01	2026-06-15 12:50:24.469472+01	1	0	0	1	0	\N	{"errors": [], "safety": {"body_peek": true, "store_used": false, "imap_readonly": true, "flags_modified": false}, "imported": [], "mailboxes": ["INBOX", "INBOX.Sent"], "duplicates": [{"uid": "1", "mailbox": "INBOX", "occurrence_id": 1}]}
294	1	3	success	2026-06-15 12:55:24.581421+01	2026-06-15 12:55:24.637759+01	1	0	0	1	0	\N	{"errors": [], "safety": {"body_peek": true, "store_used": false, "imap_readonly": true, "flags_modified": false}, "imported": [], "mailboxes": ["INBOX", "INBOX.Sent"], "duplicates": [{"uid": "1", "mailbox": "INBOX", "occurrence_id": 1}]}
295	1	3	success	2026-06-15 13:00:24.754639+01	2026-06-15 13:00:24.84648+01	1	0	0	1	0	\N	{"errors": [], "safety": {"body_peek": true, "store_used": false, "imap_readonly": true, "flags_modified": false}, "imported": [], "mailboxes": ["INBOX", "INBOX.Sent"], "duplicates": [{"uid": "1", "mailbox": "INBOX", "occurrence_id": 1}]}
296	1	3	success	2026-06-15 13:05:24.972241+01	2026-06-15 13:05:25.02472+01	1	0	0	1	0	\N	{"errors": [], "safety": {"body_peek": true, "store_used": false, "imap_readonly": true, "flags_modified": false}, "imported": [], "mailboxes": ["INBOX", "INBOX.Sent"], "duplicates": [{"uid": "1", "mailbox": "INBOX", "occurrence_id": 1}]}
297	1	3	success	2026-06-15 13:10:25.121042+01	2026-06-15 13:10:25.174426+01	1	0	0	1	0	\N	{"errors": [], "safety": {"body_peek": true, "store_used": false, "imap_readonly": true, "flags_modified": false}, "imported": [], "mailboxes": ["INBOX", "INBOX.Sent"], "duplicates": [{"uid": "1", "mailbox": "INBOX", "occurrence_id": 1}]}
298	1	3	success	2026-06-15 13:15:25.281221+01	2026-06-15 13:15:25.333394+01	1	0	0	1	0	\N	{"errors": [], "safety": {"body_peek": true, "store_used": false, "imap_readonly": true, "flags_modified": false}, "imported": [], "mailboxes": ["INBOX", "INBOX.Sent"], "duplicates": [{"uid": "1", "mailbox": "INBOX", "occurrence_id": 1}]}
299	1	3	success	2026-06-15 13:20:25.445161+01	2026-06-15 13:20:25.499132+01	1	0	0	1	0	\N	{"errors": [], "safety": {"body_peek": true, "store_used": false, "imap_readonly": true, "flags_modified": false}, "imported": [], "mailboxes": ["INBOX", "INBOX.Sent"], "duplicates": [{"uid": "1", "mailbox": "INBOX", "occurrence_id": 1}]}
300	1	3	success	2026-06-15 13:25:25.607003+01	2026-06-15 13:25:25.684494+01	1	0	0	1	0	\N	{"errors": [], "safety": {"body_peek": true, "store_used": false, "imap_readonly": true, "flags_modified": false}, "imported": [], "mailboxes": ["INBOX", "INBOX.Sent"], "duplicates": [{"uid": "1", "mailbox": "INBOX", "occurrence_id": 1}]}
301	1	3	success	2026-06-15 13:30:25.785776+01	2026-06-15 13:30:25.8734+01	1	0	0	1	0	\N	{"errors": [], "safety": {"body_peek": true, "store_used": false, "imap_readonly": true, "flags_modified": false}, "imported": [], "mailboxes": ["INBOX", "INBOX.Sent"], "duplicates": [{"uid": "1", "mailbox": "INBOX", "occurrence_id": 1}]}
302	1	3	success	2026-06-15 13:35:25.9619+01	2026-06-15 13:35:26.025132+01	1	0	0	1	0	\N	{"errors": [], "safety": {"body_peek": true, "store_used": false, "imap_readonly": true, "flags_modified": false}, "imported": [], "mailboxes": ["INBOX", "INBOX.Sent"], "duplicates": [{"uid": "1", "mailbox": "INBOX", "occurrence_id": 1}]}
303	1	3	success	2026-06-15 13:40:26.124815+01	2026-06-15 13:40:26.18908+01	1	0	0	1	0	\N	{"errors": [], "safety": {"body_peek": true, "store_used": false, "imap_readonly": true, "flags_modified": false}, "imported": [], "mailboxes": ["INBOX", "INBOX.Sent"], "duplicates": [{"uid": "1", "mailbox": "INBOX", "occurrence_id": 1}]}
304	1	3	success	2026-06-15 13:45:26.288765+01	2026-06-15 13:45:26.366244+01	1	0	0	1	0	\N	{"errors": [], "safety": {"body_peek": true, "store_used": false, "imap_readonly": true, "flags_modified": false}, "imported": [], "mailboxes": ["INBOX", "INBOX.Sent"], "duplicates": [{"uid": "1", "mailbox": "INBOX", "occurrence_id": 1}]}
305	1	3	success	2026-06-15 13:50:33.935145+01	2026-06-15 13:50:34.031499+01	1	0	0	1	0	\N	{"errors": [], "safety": {"body_peek": true, "store_used": false, "imap_readonly": true, "flags_modified": false}, "imported": [], "mailboxes": ["INBOX", "INBOX.Sent"], "duplicates": [{"uid": "1", "mailbox": "INBOX", "occurrence_id": 1}]}
306	1	3	success	2026-06-15 13:55:40.393817+01	2026-06-15 13:55:40.464432+01	1	0	0	1	0	\N	{"errors": [], "safety": {"body_peek": true, "store_used": false, "imap_readonly": true, "flags_modified": false}, "imported": [], "mailboxes": ["INBOX", "INBOX.Sent"], "duplicates": [{"uid": "1", "mailbox": "INBOX", "occurrence_id": 1}]}
307	1	3	success	2026-06-15 14:00:40.5714+01	2026-06-15 14:00:40.626886+01	1	0	0	1	0	\N	{"errors": [], "safety": {"body_peek": true, "store_used": false, "imap_readonly": true, "flags_modified": false}, "imported": [], "mailboxes": ["INBOX", "INBOX.Sent"], "duplicates": [{"uid": "1", "mailbox": "INBOX", "occurrence_id": 1}]}
308	1	3	success	2026-06-15 14:05:40.737069+01	2026-06-15 14:05:40.822931+01	1	0	0	1	0	\N	{"errors": [], "safety": {"body_peek": true, "store_used": false, "imap_readonly": true, "flags_modified": false}, "imported": [], "mailboxes": ["INBOX", "INBOX.Sent"], "duplicates": [{"uid": "1", "mailbox": "INBOX", "occurrence_id": 1}]}
309	1	3	success	2026-06-15 14:10:40.939048+01	2026-06-15 14:10:41.000811+01	1	0	0	1	0	\N	{"errors": [], "safety": {"body_peek": true, "store_used": false, "imap_readonly": true, "flags_modified": false}, "imported": [], "mailboxes": ["INBOX", "INBOX.Sent"], "duplicates": [{"uid": "1", "mailbox": "INBOX", "occurrence_id": 1}]}
310	1	3	success	2026-06-15 14:15:41.118075+01	2026-06-15 14:15:41.19652+01	1	0	0	1	0	\N	{"errors": [], "safety": {"body_peek": true, "store_used": false, "imap_readonly": true, "flags_modified": false}, "imported": [], "mailboxes": ["INBOX", "INBOX.Sent"], "duplicates": [{"uid": "1", "mailbox": "INBOX", "occurrence_id": 1}]}
311	1	3	success	2026-06-15 14:20:41.338987+01	2026-06-15 14:20:41.434823+01	1	0	0	1	0	\N	{"errors": [], "safety": {"body_peek": true, "store_used": false, "imap_readonly": true, "flags_modified": false}, "imported": [], "mailboxes": ["INBOX", "INBOX.Sent"], "duplicates": [{"uid": "1", "mailbox": "INBOX", "occurrence_id": 1}]}
312	1	3	success	2026-06-15 14:25:51.541564+01	2026-06-15 14:25:51.631586+01	1	0	0	1	0	\N	{"errors": [], "safety": {"body_peek": true, "store_used": false, "imap_readonly": true, "flags_modified": false}, "imported": [], "mailboxes": ["INBOX", "INBOX.Sent"], "duplicates": [{"uid": "1", "mailbox": "INBOX", "occurrence_id": 1}]}
313	1	3	success	2026-06-15 14:31:01.734455+01	2026-06-15 14:31:01.792523+01	1	0	0	1	0	\N	{"errors": [], "safety": {"body_peek": true, "store_used": false, "imap_readonly": true, "flags_modified": false}, "imported": [], "mailboxes": ["INBOX", "INBOX.Sent"], "duplicates": [{"uid": "1", "mailbox": "INBOX", "occurrence_id": 1}]}
314	1	3	success	2026-06-15 14:36:11.882764+01	2026-06-15 14:36:11.953806+01	1	0	0	1	0	\N	{"errors": [], "safety": {"body_peek": true, "store_used": false, "imap_readonly": true, "flags_modified": false}, "imported": [], "mailboxes": ["INBOX", "INBOX.Sent"], "duplicates": [{"uid": "1", "mailbox": "INBOX", "occurrence_id": 1}]}
315	1	3	success	2026-06-15 14:41:13.983193+01	2026-06-15 14:41:14.075189+01	1	0	0	1	0	\N	{"errors": [], "safety": {"body_peek": true, "store_used": false, "imap_readonly": true, "flags_modified": false}, "imported": [], "mailboxes": ["INBOX", "INBOX.Sent"], "duplicates": [{"uid": "1", "mailbox": "INBOX", "occurrence_id": 1}]}
316	1	3	success	2026-06-15 14:46:14.212494+01	2026-06-15 14:46:14.268989+01	1	0	0	1	0	\N	{"errors": [], "safety": {"body_peek": true, "store_used": false, "imap_readonly": true, "flags_modified": false}, "imported": [], "mailboxes": ["INBOX", "INBOX.Sent"], "duplicates": [{"uid": "1", "mailbox": "INBOX", "occurrence_id": 1}]}
317	1	3	success	2026-06-15 14:51:14.368121+01	2026-06-15 14:51:14.47249+01	1	0	0	1	0	\N	{"errors": [], "safety": {"body_peek": true, "store_used": false, "imap_readonly": true, "flags_modified": false}, "imported": [], "mailboxes": ["INBOX", "INBOX.Sent"], "duplicates": [{"uid": "1", "mailbox": "INBOX", "occurrence_id": 1}]}
318	1	3	success	2026-06-15 14:56:21.272017+01	2026-06-15 14:56:21.352525+01	1	0	0	1	0	\N	{"errors": [], "safety": {"body_peek": true, "store_used": false, "imap_readonly": true, "flags_modified": false}, "imported": [], "mailboxes": ["INBOX", "INBOX.Sent"], "duplicates": [{"uid": "1", "mailbox": "INBOX", "occurrence_id": 1}]}
319	1	3	success	2026-06-15 15:01:21.442902+01	2026-06-15 15:01:21.547125+01	1	0	0	1	0	\N	{"errors": [], "safety": {"body_peek": true, "store_used": false, "imap_readonly": true, "flags_modified": false}, "imported": [], "mailboxes": ["INBOX", "INBOX.Sent"], "duplicates": [{"uid": "1", "mailbox": "INBOX", "occurrence_id": 1}]}
320	1	3	success	2026-06-15 15:06:21.697992+01	2026-06-15 15:06:21.751795+01	1	0	0	1	0	\N	{"errors": [], "safety": {"body_peek": true, "store_used": false, "imap_readonly": true, "flags_modified": false}, "imported": [], "mailboxes": ["INBOX", "INBOX.Sent"], "duplicates": [{"uid": "1", "mailbox": "INBOX", "occurrence_id": 1}]}
321	1	3	success	2026-06-15 15:11:31.84856+01	2026-06-15 15:11:31.903072+01	1	0	0	1	0	\N	{"errors": [], "safety": {"body_peek": true, "store_used": false, "imap_readonly": true, "flags_modified": false}, "imported": [], "mailboxes": ["INBOX", "INBOX.Sent"], "duplicates": [{"uid": "1", "mailbox": "INBOX", "occurrence_id": 1}]}
322	1	3	success	2026-06-15 15:16:41.99397+01	2026-06-15 15:16:42.05485+01	1	0	0	1	0	\N	{"errors": [], "safety": {"body_peek": true, "store_used": false, "imap_readonly": true, "flags_modified": false}, "imported": [], "mailboxes": ["INBOX", "INBOX.Sent"], "duplicates": [{"uid": "1", "mailbox": "INBOX", "occurrence_id": 1}]}
323	1	3	success	2026-06-15 15:21:52.142508+01	2026-06-15 15:21:52.232752+01	1	0	0	1	0	\N	{"errors": [], "safety": {"body_peek": true, "store_used": false, "imap_readonly": true, "flags_modified": false}, "imported": [], "mailboxes": ["INBOX", "INBOX.Sent"], "duplicates": [{"uid": "1", "mailbox": "INBOX", "occurrence_id": 1}]}
324	1	3	success	2026-06-15 15:27:02.310867+01	2026-06-15 15:27:02.365843+01	1	0	0	1	0	\N	{"errors": [], "safety": {"body_peek": true, "store_used": false, "imap_readonly": true, "flags_modified": false}, "imported": [], "mailboxes": ["INBOX", "INBOX.Sent"], "duplicates": [{"uid": "1", "mailbox": "INBOX", "occurrence_id": 1}]}
325	1	3	success	2026-06-15 15:32:12.443903+01	2026-06-15 15:32:12.495829+01	1	0	0	1	0	\N	{"errors": [], "safety": {"body_peek": true, "store_used": false, "imap_readonly": true, "flags_modified": false}, "imported": [], "mailboxes": ["INBOX", "INBOX.Sent"], "duplicates": [{"uid": "1", "mailbox": "INBOX", "occurrence_id": 1}]}
326	1	3	success	2026-06-15 15:37:22.579697+01	2026-06-15 15:37:22.632746+01	1	0	0	1	0	\N	{"errors": [], "safety": {"body_peek": true, "store_used": false, "imap_readonly": true, "flags_modified": false}, "imported": [], "mailboxes": ["INBOX", "INBOX.Sent"], "duplicates": [{"uid": "1", "mailbox": "INBOX", "occurrence_id": 1}]}
327	1	3	success	2026-06-15 15:42:32.726478+01	2026-06-15 15:42:32.784663+01	1	0	0	1	0	\N	{"errors": [], "safety": {"body_peek": true, "store_used": false, "imap_readonly": true, "flags_modified": false}, "imported": [], "mailboxes": ["INBOX", "INBOX.Sent"], "duplicates": [{"uid": "1", "mailbox": "INBOX", "occurrence_id": 1}]}
328	1	3	success	2026-06-15 15:47:42.878828+01	2026-06-15 15:47:42.932691+01	1	0	0	1	0	\N	{"errors": [], "safety": {"body_peek": true, "store_used": false, "imap_readonly": true, "flags_modified": false}, "imported": [], "mailboxes": ["INBOX", "INBOX.Sent"], "duplicates": [{"uid": "1", "mailbox": "INBOX", "occurrence_id": 1}]}
329	1	3	success	2026-06-15 15:52:53.03014+01	2026-06-15 15:52:53.082044+01	1	0	0	1	0	\N	{"errors": [], "safety": {"body_peek": true, "store_used": false, "imap_readonly": true, "flags_modified": false}, "imported": [], "mailboxes": ["INBOX", "INBOX.Sent"], "duplicates": [{"uid": "1", "mailbox": "INBOX", "occurrence_id": 1}]}
330	1	3	success	2026-06-15 15:58:03.188417+01	2026-06-15 15:58:03.241102+01	1	0	0	1	0	\N	{"errors": [], "safety": {"body_peek": true, "store_used": false, "imap_readonly": true, "flags_modified": false}, "imported": [], "mailboxes": ["INBOX", "INBOX.Sent"], "duplicates": [{"uid": "1", "mailbox": "INBOX", "occurrence_id": 1}]}
331	1	3	success	2026-06-15 16:03:13.349452+01	2026-06-15 16:03:13.411895+01	1	0	0	1	0	\N	{"errors": [], "safety": {"body_peek": true, "store_used": false, "imap_readonly": true, "flags_modified": false}, "imported": [], "mailboxes": ["INBOX", "INBOX.Sent"], "duplicates": [{"uid": "1", "mailbox": "INBOX", "occurrence_id": 1}]}
332	1	3	success	2026-06-15 16:08:23.513293+01	2026-06-15 16:08:23.570566+01	1	0	0	1	0	\N	{"errors": [], "safety": {"body_peek": true, "store_used": false, "imap_readonly": true, "flags_modified": false}, "imported": [], "mailboxes": ["INBOX", "INBOX.Sent"], "duplicates": [{"uid": "1", "mailbox": "INBOX", "occurrence_id": 1}]}
333	1	3	success	2026-06-15 16:13:33.683548+01	2026-06-15 16:13:33.736646+01	1	0	0	1	0	\N	{"errors": [], "safety": {"body_peek": true, "store_used": false, "imap_readonly": true, "flags_modified": false}, "imported": [], "mailboxes": ["INBOX", "INBOX.Sent"], "duplicates": [{"uid": "1", "mailbox": "INBOX", "occurrence_id": 1}]}
334	1	3	success	2026-06-15 16:18:43.841763+01	2026-06-15 16:18:43.93847+01	1	0	0	1	0	\N	{"errors": [], "safety": {"body_peek": true, "store_used": false, "imap_readonly": true, "flags_modified": false}, "imported": [], "mailboxes": ["INBOX", "INBOX.Sent"], "duplicates": [{"uid": "1", "mailbox": "INBOX", "occurrence_id": 1}]}
335	1	3	success	2026-06-15 16:23:54.031282+01	2026-06-15 16:23:54.114964+01	1	0	0	1	0	\N	{"errors": [], "safety": {"body_peek": true, "store_used": false, "imap_readonly": true, "flags_modified": false}, "imported": [], "mailboxes": ["INBOX", "INBOX.Sent"], "duplicates": [{"uid": "1", "mailbox": "INBOX", "occurrence_id": 1}]}
336	1	3	success	2026-06-15 16:29:04.202316+01	2026-06-15 16:29:04.262453+01	1	0	0	1	0	\N	{"errors": [], "safety": {"body_peek": true, "store_used": false, "imap_readonly": true, "flags_modified": false}, "imported": [], "mailboxes": ["INBOX", "INBOX.Sent"], "duplicates": [{"uid": "1", "mailbox": "INBOX", "occurrence_id": 1}]}
337	1	3	success	2026-06-15 16:34:14.373983+01	2026-06-15 16:34:14.47379+01	1	0	0	1	0	\N	{"errors": [], "safety": {"body_peek": true, "store_used": false, "imap_readonly": true, "flags_modified": false}, "imported": [], "mailboxes": ["INBOX", "INBOX.Sent"], "duplicates": [{"uid": "1", "mailbox": "INBOX", "occurrence_id": 1}]}
338	1	3	success	2026-06-15 16:39:24.560411+01	2026-06-15 16:39:24.646944+01	1	0	0	1	0	\N	{"errors": [], "safety": {"body_peek": true, "store_used": false, "imap_readonly": true, "flags_modified": false}, "imported": [], "mailboxes": ["INBOX", "INBOX.Sent"], "duplicates": [{"uid": "1", "mailbox": "INBOX", "occurrence_id": 1}]}
339	1	3	success	2026-06-15 16:44:34.734817+01	2026-06-15 16:44:34.806541+01	1	0	0	1	0	\N	{"errors": [], "safety": {"body_peek": true, "store_used": false, "imap_readonly": true, "flags_modified": false}, "imported": [], "mailboxes": ["INBOX", "INBOX.Sent"], "duplicates": [{"uid": "1", "mailbox": "INBOX", "occurrence_id": 1}]}
340	1	3	success	2026-06-15 16:49:44.911298+01	2026-06-15 16:49:44.965005+01	1	0	0	1	0	\N	{"errors": [], "safety": {"body_peek": true, "store_used": false, "imap_readonly": true, "flags_modified": false}, "imported": [], "mailboxes": ["INBOX", "INBOX.Sent"], "duplicates": [{"uid": "1", "mailbox": "INBOX", "occurrence_id": 1}]}
341	1	3	success	2026-06-15 16:54:55.066767+01	2026-06-15 16:54:55.11867+01	1	0	0	1	0	\N	{"errors": [], "safety": {"body_peek": true, "store_used": false, "imap_readonly": true, "flags_modified": false}, "imported": [], "mailboxes": ["INBOX", "INBOX.Sent"], "duplicates": [{"uid": "1", "mailbox": "INBOX", "occurrence_id": 1}]}
342	1	3	success	2026-06-15 17:00:05.217112+01	2026-06-15 17:00:05.277708+01	1	0	0	1	0	\N	{"errors": [], "safety": {"body_peek": true, "store_used": false, "imap_readonly": true, "flags_modified": false}, "imported": [], "mailboxes": ["INBOX", "INBOX.Sent"], "duplicates": [{"uid": "1", "mailbox": "INBOX", "occurrence_id": 1}]}
343	1	3	success	2026-06-15 17:05:15.373724+01	2026-06-15 17:05:15.48505+01	1	0	0	1	0	\N	{"errors": [], "safety": {"body_peek": true, "store_used": false, "imap_readonly": true, "flags_modified": false}, "imported": [], "mailboxes": ["INBOX", "INBOX.Sent"], "duplicates": [{"uid": "1", "mailbox": "INBOX", "occurrence_id": 1}]}
344	1	3	success	2026-06-15 17:10:25.569039+01	2026-06-15 17:10:25.691823+01	1	0	0	1	0	\N	{"errors": [], "safety": {"body_peek": true, "store_used": false, "imap_readonly": true, "flags_modified": false}, "imported": [], "mailboxes": ["INBOX", "INBOX.Sent"], "duplicates": [{"uid": "1", "mailbox": "INBOX", "occurrence_id": 1}]}
345	1	3	success	2026-06-15 17:15:35.799612+01	2026-06-15 17:15:35.852363+01	1	0	0	1	0	\N	{"errors": [], "safety": {"body_peek": true, "store_used": false, "imap_readonly": true, "flags_modified": false}, "imported": [], "mailboxes": ["INBOX", "INBOX.Sent"], "duplicates": [{"uid": "1", "mailbox": "INBOX", "occurrence_id": 1}]}
346	1	3	success	2026-06-15 17:20:45.962236+01	2026-06-15 17:20:46.065397+01	1	0	0	1	0	\N	{"errors": [], "safety": {"body_peek": true, "store_used": false, "imap_readonly": true, "flags_modified": false}, "imported": [], "mailboxes": ["INBOX", "INBOX.Sent"], "duplicates": [{"uid": "1", "mailbox": "INBOX", "occurrence_id": 1}]}
347	1	3	success	2026-06-15 17:25:56.163556+01	2026-06-15 17:25:56.254262+01	1	0	0	1	0	\N	{"errors": [], "safety": {"body_peek": true, "store_used": false, "imap_readonly": true, "flags_modified": false}, "imported": [], "mailboxes": ["INBOX", "INBOX.Sent"], "duplicates": [{"uid": "1", "mailbox": "INBOX", "occurrence_id": 1}]}
348	1	3	success	2026-06-15 17:31:06.344827+01	2026-06-15 17:31:06.397899+01	1	0	0	1	0	\N	{"errors": [], "safety": {"body_peek": true, "store_used": false, "imap_readonly": true, "flags_modified": false}, "imported": [], "mailboxes": ["INBOX", "INBOX.Sent"], "duplicates": [{"uid": "1", "mailbox": "INBOX", "occurrence_id": 1}]}
349	1	3	success	2026-06-15 17:36:16.521523+01	2026-06-15 17:36:16.572417+01	1	0	0	1	0	\N	{"errors": [], "safety": {"body_peek": true, "store_used": false, "imap_readonly": true, "flags_modified": false}, "imported": [], "mailboxes": ["INBOX", "INBOX.Sent"], "duplicates": [{"uid": "1", "mailbox": "INBOX", "occurrence_id": 1}]}
350	1	3	success	2026-06-15 17:41:26.683543+01	2026-06-15 17:41:26.736711+01	1	0	0	1	0	\N	{"errors": [], "safety": {"body_peek": true, "store_used": false, "imap_readonly": true, "flags_modified": false}, "imported": [], "mailboxes": ["INBOX", "INBOX.Sent"], "duplicates": [{"uid": "1", "mailbox": "INBOX", "occurrence_id": 1}]}
351	1	3	success	2026-06-15 17:46:36.843593+01	2026-06-15 17:46:36.9361+01	1	0	0	1	0	\N	{"errors": [], "safety": {"body_peek": true, "store_used": false, "imap_readonly": true, "flags_modified": false}, "imported": [], "mailboxes": ["INBOX", "INBOX.Sent"], "duplicates": [{"uid": "1", "mailbox": "INBOX", "occurrence_id": 1}]}
352	1	3	success	2026-06-15 17:51:47.023712+01	2026-06-15 17:51:47.090202+01	1	0	0	1	0	\N	{"errors": [], "safety": {"body_peek": true, "store_used": false, "imap_readonly": true, "flags_modified": false}, "imported": [], "mailboxes": ["INBOX", "INBOX.Sent"], "duplicates": [{"uid": "1", "mailbox": "INBOX", "occurrence_id": 1}]}
353	1	3	success	2026-06-15 17:56:57.185159+01	2026-06-15 17:56:57.288995+01	1	0	0	1	0	\N	{"errors": [], "safety": {"body_peek": true, "store_used": false, "imap_readonly": true, "flags_modified": false}, "imported": [], "mailboxes": ["INBOX", "INBOX.Sent"], "duplicates": [{"uid": "1", "mailbox": "INBOX", "occurrence_id": 1}]}
354	1	3	success	2026-06-15 18:02:07.403615+01	2026-06-15 18:02:07.464235+01	1	0	0	1	0	\N	{"errors": [], "safety": {"body_peek": true, "store_used": false, "imap_readonly": true, "flags_modified": false}, "imported": [], "mailboxes": ["INBOX", "INBOX.Sent"], "duplicates": [{"uid": "1", "mailbox": "INBOX", "occurrence_id": 1}]}
355	1	3	success	2026-06-15 18:07:17.567454+01	2026-06-15 18:07:17.662689+01	1	0	0	1	0	\N	{"errors": [], "safety": {"body_peek": true, "store_used": false, "imap_readonly": true, "flags_modified": false}, "imported": [], "mailboxes": ["INBOX", "INBOX.Sent"], "duplicates": [{"uid": "1", "mailbox": "INBOX", "occurrence_id": 1}]}
356	1	3	success	2026-06-15 18:12:27.767745+01	2026-06-15 18:12:27.822497+01	1	0	0	1	0	\N	{"errors": [], "safety": {"body_peek": true, "store_used": false, "imap_readonly": true, "flags_modified": false}, "imported": [], "mailboxes": ["INBOX", "INBOX.Sent"], "duplicates": [{"uid": "1", "mailbox": "INBOX", "occurrence_id": 1}]}
357	1	3	success	2026-06-15 18:17:37.921973+01	2026-06-15 18:17:38.017899+01	1	0	0	1	0	\N	{"errors": [], "safety": {"body_peek": true, "store_used": false, "imap_readonly": true, "flags_modified": false}, "imported": [], "mailboxes": ["INBOX", "INBOX.Sent"], "duplicates": [{"uid": "1", "mailbox": "INBOX", "occurrence_id": 1}]}
358	1	3	success	2026-06-15 18:22:48.129474+01	2026-06-15 18:22:48.19056+01	1	0	0	1	0	\N	{"errors": [], "safety": {"body_peek": true, "store_used": false, "imap_readonly": true, "flags_modified": false}, "imported": [], "mailboxes": ["INBOX", "INBOX.Sent"], "duplicates": [{"uid": "1", "mailbox": "INBOX", "occurrence_id": 1}]}
359	1	3	success	2026-06-15 18:27:58.303861+01	2026-06-15 18:27:58.368784+01	1	0	0	1	0	\N	{"errors": [], "safety": {"body_peek": true, "store_used": false, "imap_readonly": true, "flags_modified": false}, "imported": [], "mailboxes": ["INBOX", "INBOX.Sent"], "duplicates": [{"uid": "1", "mailbox": "INBOX", "occurrence_id": 1}]}
360	1	3	success	2026-06-15 18:33:08.495497+01	2026-06-15 18:33:08.557535+01	1	0	0	1	0	\N	{"errors": [], "safety": {"body_peek": true, "store_used": false, "imap_readonly": true, "flags_modified": false}, "imported": [], "mailboxes": ["INBOX", "INBOX.Sent"], "duplicates": [{"uid": "1", "mailbox": "INBOX", "occurrence_id": 1}]}
361	1	3	success	2026-06-15 18:38:18.683894+01	2026-06-15 18:38:18.733069+01	1	0	0	1	0	\N	{"errors": [], "safety": {"body_peek": true, "store_used": false, "imap_readonly": true, "flags_modified": false}, "imported": [], "mailboxes": ["INBOX", "INBOX.Sent"], "duplicates": [{"uid": "1", "mailbox": "INBOX", "occurrence_id": 1}]}
362	1	3	success	2026-06-15 18:43:28.818748+01	2026-06-15 18:43:28.870612+01	1	0	0	1	0	\N	{"errors": [], "safety": {"body_peek": true, "store_used": false, "imap_readonly": true, "flags_modified": false}, "imported": [], "mailboxes": ["INBOX", "INBOX.Sent"], "duplicates": [{"uid": "1", "mailbox": "INBOX", "occurrence_id": 1}]}
363	1	3	success	2026-06-15 18:48:38.99425+01	2026-06-15 18:48:39.090483+01	1	0	0	1	0	\N	{"errors": [], "safety": {"body_peek": true, "store_used": false, "imap_readonly": true, "flags_modified": false}, "imported": [], "mailboxes": ["INBOX", "INBOX.Sent"], "duplicates": [{"uid": "1", "mailbox": "INBOX", "occurrence_id": 1}]}
364	1	3	success	2026-06-15 18:53:49.188427+01	2026-06-15 18:53:49.302998+01	1	0	0	1	0	\N	{"errors": [], "safety": {"body_peek": true, "store_used": false, "imap_readonly": true, "flags_modified": false}, "imported": [], "mailboxes": ["INBOX", "INBOX.Sent"], "duplicates": [{"uid": "1", "mailbox": "INBOX", "occurrence_id": 1}]}
365	1	3	success	2026-06-15 18:58:59.395126+01	2026-06-15 18:58:59.449614+01	1	0	0	1	0	\N	{"errors": [], "safety": {"body_peek": true, "store_used": false, "imap_readonly": true, "flags_modified": false}, "imported": [], "mailboxes": ["INBOX", "INBOX.Sent"], "duplicates": [{"uid": "1", "mailbox": "INBOX", "occurrence_id": 1}]}
366	1	3	success	2026-06-15 19:04:09.55071+01	2026-06-15 19:04:09.606521+01	1	0	0	1	0	\N	{"errors": [], "safety": {"body_peek": true, "store_used": false, "imap_readonly": true, "flags_modified": false}, "imported": [], "mailboxes": ["INBOX", "INBOX.Sent"], "duplicates": [{"uid": "1", "mailbox": "INBOX", "occurrence_id": 1}]}
367	1	3	success	2026-06-15 19:09:19.702857+01	2026-06-15 19:09:19.804822+01	1	0	0	1	0	\N	{"errors": [], "safety": {"body_peek": true, "store_used": false, "imap_readonly": true, "flags_modified": false}, "imported": [], "mailboxes": ["INBOX", "INBOX.Sent"], "duplicates": [{"uid": "1", "mailbox": "INBOX", "occurrence_id": 1}]}
368	1	3	success	2026-06-15 19:14:29.901164+01	2026-06-15 19:14:29.992646+01	1	0	0	1	0	\N	{"errors": [], "safety": {"body_peek": true, "store_used": false, "imap_readonly": true, "flags_modified": false}, "imported": [], "mailboxes": ["INBOX", "INBOX.Sent"], "duplicates": [{"uid": "1", "mailbox": "INBOX", "occurrence_id": 1}]}
369	1	3	success	2026-06-15 19:19:40.079211+01	2026-06-15 19:19:40.178407+01	1	0	0	1	0	\N	{"errors": [], "safety": {"body_peek": true, "store_used": false, "imap_readonly": true, "flags_modified": false}, "imported": [], "mailboxes": ["INBOX", "INBOX.Sent"], "duplicates": [{"uid": "1", "mailbox": "INBOX", "occurrence_id": 1}]}
370	1	3	success	2026-06-15 19:24:50.279629+01	2026-06-15 19:24:50.333056+01	1	0	0	1	0	\N	{"errors": [], "safety": {"body_peek": true, "store_used": false, "imap_readonly": true, "flags_modified": false}, "imported": [], "mailboxes": ["INBOX", "INBOX.Sent"], "duplicates": [{"uid": "1", "mailbox": "INBOX", "occurrence_id": 1}]}
371	1	3	success	2026-06-15 19:30:00.418813+01	2026-06-15 19:30:00.483854+01	1	0	0	1	0	\N	{"errors": [], "safety": {"body_peek": true, "store_used": false, "imap_readonly": true, "flags_modified": false}, "imported": [], "mailboxes": ["INBOX", "INBOX.Sent"], "duplicates": [{"uid": "1", "mailbox": "INBOX", "occurrence_id": 1}]}
372	1	3	success	2026-06-15 19:35:10.573621+01	2026-06-15 19:35:10.635675+01	1	0	0	1	0	\N	{"errors": [], "safety": {"body_peek": true, "store_used": false, "imap_readonly": true, "flags_modified": false}, "imported": [], "mailboxes": ["INBOX", "INBOX.Sent"], "duplicates": [{"uid": "1", "mailbox": "INBOX", "occurrence_id": 1}]}
373	1	3	success	2026-06-15 19:40:20.705388+01	2026-06-15 19:40:20.756188+01	1	0	0	1	0	\N	{"errors": [], "safety": {"body_peek": true, "store_used": false, "imap_readonly": true, "flags_modified": false}, "imported": [], "mailboxes": ["INBOX", "INBOX.Sent"], "duplicates": [{"uid": "1", "mailbox": "INBOX", "occurrence_id": 1}]}
374	1	3	success	2026-06-15 19:45:30.848347+01	2026-06-15 19:45:30.905707+01	1	0	0	1	0	\N	{"errors": [], "safety": {"body_peek": true, "store_used": false, "imap_readonly": true, "flags_modified": false}, "imported": [], "mailboxes": ["INBOX", "INBOX.Sent"], "duplicates": [{"uid": "1", "mailbox": "INBOX", "occurrence_id": 1}]}
375	1	3	success	2026-06-15 19:50:40.992041+01	2026-06-15 19:50:41.089999+01	1	0	0	1	0	\N	{"errors": [], "safety": {"body_peek": true, "store_used": false, "imap_readonly": true, "flags_modified": false}, "imported": [], "mailboxes": ["INBOX", "INBOX.Sent"], "duplicates": [{"uid": "1", "mailbox": "INBOX", "occurrence_id": 1}]}
376	1	3	success	2026-06-15 19:55:51.185111+01	2026-06-15 19:55:51.278424+01	1	0	0	1	0	\N	{"errors": [], "safety": {"body_peek": true, "store_used": false, "imap_readonly": true, "flags_modified": false}, "imported": [], "mailboxes": ["INBOX", "INBOX.Sent"], "duplicates": [{"uid": "1", "mailbox": "INBOX", "occurrence_id": 1}]}
377	1	3	success	2026-06-15 20:01:01.379975+01	2026-06-15 20:01:01.481831+01	1	0	0	1	0	\N	{"errors": [], "safety": {"body_peek": true, "store_used": false, "imap_readonly": true, "flags_modified": false}, "imported": [], "mailboxes": ["INBOX", "INBOX.Sent"], "duplicates": [{"uid": "1", "mailbox": "INBOX", "occurrence_id": 1}]}
378	1	3	success	2026-06-15 20:06:11.582984+01	2026-06-15 20:06:11.678578+01	1	0	0	1	0	\N	{"errors": [], "safety": {"body_peek": true, "store_used": false, "imap_readonly": true, "flags_modified": false}, "imported": [], "mailboxes": ["INBOX", "INBOX.Sent"], "duplicates": [{"uid": "1", "mailbox": "INBOX", "occurrence_id": 1}]}
379	1	3	success	2026-06-15 20:11:21.77663+01	2026-06-15 20:11:21.847342+01	1	0	0	1	0	\N	{"errors": [], "safety": {"body_peek": true, "store_used": false, "imap_readonly": true, "flags_modified": false}, "imported": [], "mailboxes": ["INBOX", "INBOX.Sent"], "duplicates": [{"uid": "1", "mailbox": "INBOX", "occurrence_id": 1}]}
380	1	3	success	2026-06-15 20:16:31.94587+01	2026-06-15 20:16:32.0524+01	1	0	0	1	0	\N	{"errors": [], "safety": {"body_peek": true, "store_used": false, "imap_readonly": true, "flags_modified": false}, "imported": [], "mailboxes": ["INBOX", "INBOX.Sent"], "duplicates": [{"uid": "1", "mailbox": "INBOX", "occurrence_id": 1}]}
381	1	3	success	2026-06-15 20:21:42.146167+01	2026-06-15 20:21:42.204906+01	1	0	0	1	0	\N	{"errors": [], "safety": {"body_peek": true, "store_used": false, "imap_readonly": true, "flags_modified": false}, "imported": [], "mailboxes": ["INBOX", "INBOX.Sent"], "duplicates": [{"uid": "1", "mailbox": "INBOX", "occurrence_id": 1}]}
382	1	3	success	2026-06-15 20:26:52.295943+01	2026-06-15 20:26:52.347252+01	1	0	0	1	0	\N	{"errors": [], "safety": {"body_peek": true, "store_used": false, "imap_readonly": true, "flags_modified": false}, "imported": [], "mailboxes": ["INBOX", "INBOX.Sent"], "duplicates": [{"uid": "1", "mailbox": "INBOX", "occurrence_id": 1}]}
383	1	3	success	2026-06-15 20:32:02.444852+01	2026-06-15 20:32:02.496839+01	1	0	0	1	0	\N	{"errors": [], "safety": {"body_peek": true, "store_used": false, "imap_readonly": true, "flags_modified": false}, "imported": [], "mailboxes": ["INBOX", "INBOX.Sent"], "duplicates": [{"uid": "1", "mailbox": "INBOX", "occurrence_id": 1}]}
384	1	3	success	2026-06-15 20:37:12.616057+01	2026-06-15 20:37:12.66983+01	1	0	0	1	0	\N	{"errors": [], "safety": {"body_peek": true, "store_used": false, "imap_readonly": true, "flags_modified": false}, "imported": [], "mailboxes": ["INBOX", "INBOX.Sent"], "duplicates": [{"uid": "1", "mailbox": "INBOX", "occurrence_id": 1}]}
385	1	3	success	2026-06-15 20:42:22.760849+01	2026-06-15 20:42:22.816574+01	1	0	0	1	0	\N	{"errors": [], "safety": {"body_peek": true, "store_used": false, "imap_readonly": true, "flags_modified": false}, "imported": [], "mailboxes": ["INBOX", "INBOX.Sent"], "duplicates": [{"uid": "1", "mailbox": "INBOX", "occurrence_id": 1}]}
386	1	3	success	2026-06-15 20:47:32.928198+01	2026-06-15 20:47:32.980494+01	1	0	0	1	0	\N	{"errors": [], "safety": {"body_peek": true, "store_used": false, "imap_readonly": true, "flags_modified": false}, "imported": [], "mailboxes": ["INBOX", "INBOX.Sent"], "duplicates": [{"uid": "1", "mailbox": "INBOX", "occurrence_id": 1}]}
387	1	3	success	2026-06-15 20:52:43.082041+01	2026-06-15 20:52:43.193097+01	1	0	0	1	0	\N	{"errors": [], "safety": {"body_peek": true, "store_used": false, "imap_readonly": true, "flags_modified": false}, "imported": [], "mailboxes": ["INBOX", "INBOX.Sent"], "duplicates": [{"uid": "1", "mailbox": "INBOX", "occurrence_id": 1}]}
388	1	3	success	2026-06-15 20:57:53.29193+01	2026-06-15 20:57:53.392955+01	1	0	0	1	0	\N	{"errors": [], "safety": {"body_peek": true, "store_used": false, "imap_readonly": true, "flags_modified": false}, "imported": [], "mailboxes": ["INBOX", "INBOX.Sent"], "duplicates": [{"uid": "1", "mailbox": "INBOX", "occurrence_id": 1}]}
389	1	3	success	2026-06-15 21:03:03.489035+01	2026-06-15 21:03:03.539722+01	1	0	0	1	0	\N	{"errors": [], "safety": {"body_peek": true, "store_used": false, "imap_readonly": true, "flags_modified": false}, "imported": [], "mailboxes": ["INBOX", "INBOX.Sent"], "duplicates": [{"uid": "1", "mailbox": "INBOX", "occurrence_id": 1}]}
390	1	3	success	2026-06-15 21:08:13.635955+01	2026-06-15 21:08:13.68798+01	1	0	0	1	0	\N	{"errors": [], "safety": {"body_peek": true, "store_used": false, "imap_readonly": true, "flags_modified": false}, "imported": [], "mailboxes": ["INBOX", "INBOX.Sent"], "duplicates": [{"uid": "1", "mailbox": "INBOX", "occurrence_id": 1}]}
391	1	3	success	2026-06-15 21:13:23.793613+01	2026-06-15 21:13:23.846316+01	1	0	0	1	0	\N	{"errors": [], "safety": {"body_peek": true, "store_used": false, "imap_readonly": true, "flags_modified": false}, "imported": [], "mailboxes": ["INBOX", "INBOX.Sent"], "duplicates": [{"uid": "1", "mailbox": "INBOX", "occurrence_id": 1}]}
392	1	3	success	2026-06-15 21:18:33.959208+01	2026-06-15 21:18:34.061379+01	1	0	0	1	0	\N	{"errors": [], "safety": {"body_peek": true, "store_used": false, "imap_readonly": true, "flags_modified": false}, "imported": [], "mailboxes": ["INBOX", "INBOX.Sent"], "duplicates": [{"uid": "1", "mailbox": "INBOX", "occurrence_id": 1}]}
393	1	3	success	2026-06-15 21:23:44.160488+01	2026-06-15 21:23:44.212906+01	1	0	0	1	0	\N	{"errors": [], "safety": {"body_peek": true, "store_used": false, "imap_readonly": true, "flags_modified": false}, "imported": [], "mailboxes": ["INBOX", "INBOX.Sent"], "duplicates": [{"uid": "1", "mailbox": "INBOX", "occurrence_id": 1}]}
394	1	3	success	2026-06-15 21:28:54.322206+01	2026-06-15 21:28:54.383227+01	1	0	0	1	0	\N	{"errors": [], "safety": {"body_peek": true, "store_used": false, "imap_readonly": true, "flags_modified": false}, "imported": [], "mailboxes": ["INBOX", "INBOX.Sent"], "duplicates": [{"uid": "1", "mailbox": "INBOX", "occurrence_id": 1}]}
395	1	3	success	2026-06-15 21:34:04.48729+01	2026-06-15 21:34:04.539634+01	1	0	0	1	0	\N	{"errors": [], "safety": {"body_peek": true, "store_used": false, "imap_readonly": true, "flags_modified": false}, "imported": [], "mailboxes": ["INBOX", "INBOX.Sent"], "duplicates": [{"uid": "1", "mailbox": "INBOX", "occurrence_id": 1}]}
396	1	3	success	2026-06-15 21:39:14.644061+01	2026-06-15 21:39:14.707609+01	1	0	0	1	0	\N	{"errors": [], "safety": {"body_peek": true, "store_used": false, "imap_readonly": true, "flags_modified": false}, "imported": [], "mailboxes": ["INBOX", "INBOX.Sent"], "duplicates": [{"uid": "1", "mailbox": "INBOX", "occurrence_id": 1}]}
397	1	3	success	2026-06-15 21:44:24.786756+01	2026-06-15 21:44:24.850502+01	1	0	0	1	0	\N	{"errors": [], "safety": {"body_peek": true, "store_used": false, "imap_readonly": true, "flags_modified": false}, "imported": [], "mailboxes": ["INBOX", "INBOX.Sent"], "duplicates": [{"uid": "1", "mailbox": "INBOX", "occurrence_id": 1}]}
398	1	3	success	2026-06-15 21:49:34.937451+01	2026-06-15 21:49:34.992933+01	1	0	0	1	0	\N	{"errors": [], "safety": {"body_peek": true, "store_used": false, "imap_readonly": true, "flags_modified": false}, "imported": [], "mailboxes": ["INBOX", "INBOX.Sent"], "duplicates": [{"uid": "1", "mailbox": "INBOX", "occurrence_id": 1}]}
399	1	3	success	2026-06-15 21:54:45.092588+01	2026-06-15 21:54:45.183737+01	1	0	0	1	0	\N	{"errors": [], "safety": {"body_peek": true, "store_used": false, "imap_readonly": true, "flags_modified": false}, "imported": [], "mailboxes": ["INBOX", "INBOX.Sent"], "duplicates": [{"uid": "1", "mailbox": "INBOX", "occurrence_id": 1}]}
400	1	3	success	2026-06-15 21:59:55.279216+01	2026-06-15 21:59:55.381465+01	1	0	0	1	0	\N	{"errors": [], "safety": {"body_peek": true, "store_used": false, "imap_readonly": true, "flags_modified": false}, "imported": [], "mailboxes": ["INBOX", "INBOX.Sent"], "duplicates": [{"uid": "1", "mailbox": "INBOX", "occurrence_id": 1}]}
401	1	3	success	2026-06-15 22:05:05.487628+01	2026-06-15 22:05:05.573614+01	1	0	0	1	0	\N	{"errors": [], "safety": {"body_peek": true, "store_used": false, "imap_readonly": true, "flags_modified": false}, "imported": [], "mailboxes": ["INBOX", "INBOX.Sent"], "duplicates": [{"uid": "1", "mailbox": "INBOX", "occurrence_id": 1}]}
402	1	3	success	2026-06-15 22:10:15.671329+01	2026-06-15 22:10:15.723726+01	1	0	0	1	0	\N	{"errors": [], "safety": {"body_peek": true, "store_used": false, "imap_readonly": true, "flags_modified": false}, "imported": [], "mailboxes": ["INBOX", "INBOX.Sent"], "duplicates": [{"uid": "1", "mailbox": "INBOX", "occurrence_id": 1}]}
403	1	3	success	2026-06-15 22:15:25.806505+01	2026-06-15 22:15:25.859966+01	1	0	0	1	0	\N	{"errors": [], "safety": {"body_peek": true, "store_used": false, "imap_readonly": true, "flags_modified": false}, "imported": [], "mailboxes": ["INBOX", "INBOX.Sent"], "duplicates": [{"uid": "1", "mailbox": "INBOX", "occurrence_id": 1}]}
404	1	3	success	2026-06-15 22:20:35.93566+01	2026-06-15 22:20:35.994682+01	1	0	0	1	0	\N	{"errors": [], "safety": {"body_peek": true, "store_used": false, "imap_readonly": true, "flags_modified": false}, "imported": [], "mailboxes": ["INBOX", "INBOX.Sent"], "duplicates": [{"uid": "1", "mailbox": "INBOX", "occurrence_id": 1}]}
405	1	3	success	2026-06-15 22:25:46.092378+01	2026-06-15 22:25:46.14367+01	1	0	0	1	0	\N	{"errors": [], "safety": {"body_peek": true, "store_used": false, "imap_readonly": true, "flags_modified": false}, "imported": [], "mailboxes": ["INBOX", "INBOX.Sent"], "duplicates": [{"uid": "1", "mailbox": "INBOX", "occurrence_id": 1}]}
406	1	3	success	2026-06-15 22:30:56.259283+01	2026-06-15 22:30:56.313834+01	1	0	0	1	0	\N	{"errors": [], "safety": {"body_peek": true, "store_used": false, "imap_readonly": true, "flags_modified": false}, "imported": [], "mailboxes": ["INBOX", "INBOX.Sent"], "duplicates": [{"uid": "1", "mailbox": "INBOX", "occurrence_id": 1}]}
407	1	3	success	2026-06-15 22:36:06.404259+01	2026-06-15 22:36:06.454672+01	1	0	0	1	0	\N	{"errors": [], "safety": {"body_peek": true, "store_used": false, "imap_readonly": true, "flags_modified": false}, "imported": [], "mailboxes": ["INBOX", "INBOX.Sent"], "duplicates": [{"uid": "1", "mailbox": "INBOX", "occurrence_id": 1}]}
408	1	3	success	2026-06-15 22:41:16.557697+01	2026-06-15 22:41:16.651128+01	1	0	0	1	0	\N	{"errors": [], "safety": {"body_peek": true, "store_used": false, "imap_readonly": true, "flags_modified": false}, "imported": [], "mailboxes": ["INBOX", "INBOX.Sent"], "duplicates": [{"uid": "1", "mailbox": "INBOX", "occurrence_id": 1}]}
409	1	3	success	2026-06-15 22:46:26.735038+01	2026-06-15 22:46:26.787997+01	1	0	0	1	0	\N	{"errors": [], "safety": {"body_peek": true, "store_used": false, "imap_readonly": true, "flags_modified": false}, "imported": [], "mailboxes": ["INBOX", "INBOX.Sent"], "duplicates": [{"uid": "1", "mailbox": "INBOX", "occurrence_id": 1}]}
410	1	3	success	2026-06-15 22:51:36.884598+01	2026-06-15 22:51:36.984876+01	1	0	0	1	0	\N	{"errors": [], "safety": {"body_peek": true, "store_used": false, "imap_readonly": true, "flags_modified": false}, "imported": [], "mailboxes": ["INBOX", "INBOX.Sent"], "duplicates": [{"uid": "1", "mailbox": "INBOX", "occurrence_id": 1}]}
411	1	3	success	2026-06-15 22:56:47.074723+01	2026-06-15 22:56:47.125106+01	1	0	0	1	0	\N	{"errors": [], "safety": {"body_peek": true, "store_used": false, "imap_readonly": true, "flags_modified": false}, "imported": [], "mailboxes": ["INBOX", "INBOX.Sent"], "duplicates": [{"uid": "1", "mailbox": "INBOX", "occurrence_id": 1}]}
412	1	3	success	2026-06-15 23:01:57.21016+01	2026-06-15 23:01:57.261292+01	1	0	0	1	0	\N	{"errors": [], "safety": {"body_peek": true, "store_used": false, "imap_readonly": true, "flags_modified": false}, "imported": [], "mailboxes": ["INBOX", "INBOX.Sent"], "duplicates": [{"uid": "1", "mailbox": "INBOX", "occurrence_id": 1}]}
413	1	3	success	2026-06-15 23:07:07.370956+01	2026-06-15 23:07:07.434299+01	1	0	0	1	0	\N	{"errors": [], "safety": {"body_peek": true, "store_used": false, "imap_readonly": true, "flags_modified": false}, "imported": [], "mailboxes": ["INBOX", "INBOX.Sent"], "duplicates": [{"uid": "1", "mailbox": "INBOX", "occurrence_id": 1}]}
414	1	3	success	2026-06-15 23:12:17.551273+01	2026-06-15 23:12:17.600332+01	1	0	0	1	0	\N	{"errors": [], "safety": {"body_peek": true, "store_used": false, "imap_readonly": true, "flags_modified": false}, "imported": [], "mailboxes": ["INBOX", "INBOX.Sent"], "duplicates": [{"uid": "1", "mailbox": "INBOX", "occurrence_id": 1}]}
415	1	3	success	2026-06-15 23:17:27.706557+01	2026-06-15 23:17:27.791558+01	1	0	0	1	0	\N	{"errors": [], "safety": {"body_peek": true, "store_used": false, "imap_readonly": true, "flags_modified": false}, "imported": [], "mailboxes": ["INBOX", "INBOX.Sent"], "duplicates": [{"uid": "1", "mailbox": "INBOX", "occurrence_id": 1}]}
416	1	3	success	2026-06-15 23:22:37.881624+01	2026-06-15 23:22:37.936187+01	1	0	0	1	0	\N	{"errors": [], "safety": {"body_peek": true, "store_used": false, "imap_readonly": true, "flags_modified": false}, "imported": [], "mailboxes": ["INBOX", "INBOX.Sent"], "duplicates": [{"uid": "1", "mailbox": "INBOX", "occurrence_id": 1}]}
417	1	3	success	2026-06-15 23:27:48.02852+01	2026-06-15 23:27:48.128694+01	1	0	0	1	0	\N	{"errors": [], "safety": {"body_peek": true, "store_used": false, "imap_readonly": true, "flags_modified": false}, "imported": [], "mailboxes": ["INBOX", "INBOX.Sent"], "duplicates": [{"uid": "1", "mailbox": "INBOX", "occurrence_id": 1}]}
418	1	3	success	2026-06-15 23:32:58.231532+01	2026-06-15 23:32:58.283272+01	1	0	0	1	0	\N	{"errors": [], "safety": {"body_peek": true, "store_used": false, "imap_readonly": true, "flags_modified": false}, "imported": [], "mailboxes": ["INBOX", "INBOX.Sent"], "duplicates": [{"uid": "1", "mailbox": "INBOX", "occurrence_id": 1}]}
419	1	3	success	2026-06-15 23:38:08.366861+01	2026-06-15 23:38:08.424499+01	1	0	0	1	0	\N	{"errors": [], "safety": {"body_peek": true, "store_used": false, "imap_readonly": true, "flags_modified": false}, "imported": [], "mailboxes": ["INBOX", "INBOX.Sent"], "duplicates": [{"uid": "1", "mailbox": "INBOX", "occurrence_id": 1}]}
420	1	3	success	2026-06-15 23:43:18.53987+01	2026-06-15 23:43:18.63823+01	1	0	0	1	0	\N	{"errors": [], "safety": {"body_peek": true, "store_used": false, "imap_readonly": true, "flags_modified": false}, "imported": [], "mailboxes": ["INBOX", "INBOX.Sent"], "duplicates": [{"uid": "1", "mailbox": "INBOX", "occurrence_id": 1}]}
421	1	3	success	2026-06-15 23:48:28.742192+01	2026-06-15 23:48:28.833675+01	1	0	0	1	0	\N	{"errors": [], "safety": {"body_peek": true, "store_used": false, "imap_readonly": true, "flags_modified": false}, "imported": [], "mailboxes": ["INBOX", "INBOX.Sent"], "duplicates": [{"uid": "1", "mailbox": "INBOX", "occurrence_id": 1}]}
422	1	3	success	2026-06-15 23:53:38.930029+01	2026-06-15 23:53:38.984626+01	1	0	0	1	0	\N	{"errors": [], "safety": {"body_peek": true, "store_used": false, "imap_readonly": true, "flags_modified": false}, "imported": [], "mailboxes": ["INBOX", "INBOX.Sent"], "duplicates": [{"uid": "1", "mailbox": "INBOX", "occurrence_id": 1}]}
423	1	3	success	2026-06-15 23:58:49.088649+01	2026-06-15 23:58:49.150655+01	1	0	0	1	0	\N	{"errors": [], "safety": {"body_peek": true, "store_used": false, "imap_readonly": true, "flags_modified": false}, "imported": [], "mailboxes": ["INBOX", "INBOX.Sent"], "duplicates": [{"uid": "1", "mailbox": "INBOX", "occurrence_id": 1}]}
424	1	3	success	2026-06-16 00:03:59.240777+01	2026-06-16 00:03:59.321642+01	1	0	0	1	0	\N	{"errors": [], "safety": {"body_peek": true, "store_used": false, "imap_readonly": true, "flags_modified": false}, "imported": [], "mailboxes": ["INBOX", "INBOX.Sent"], "duplicates": [{"uid": "1", "mailbox": "INBOX", "occurrence_id": 1}]}
425	1	3	success	2026-06-16 00:09:09.433706+01	2026-06-16 00:09:09.484458+01	1	0	0	1	0	\N	{"errors": [], "safety": {"body_peek": true, "store_used": false, "imap_readonly": true, "flags_modified": false}, "imported": [], "mailboxes": ["INBOX", "INBOX.Sent"], "duplicates": [{"uid": "1", "mailbox": "INBOX", "occurrence_id": 1}]}
426	1	3	success	2026-06-16 00:14:19.615988+01	2026-06-16 00:14:19.670672+01	1	0	0	1	0	\N	{"errors": [], "safety": {"body_peek": true, "store_used": false, "imap_readonly": true, "flags_modified": false}, "imported": [], "mailboxes": ["INBOX", "INBOX.Sent"], "duplicates": [{"uid": "1", "mailbox": "INBOX", "occurrence_id": 1}]}
427	1	3	success	2026-06-16 00:19:29.783828+01	2026-06-16 00:19:29.890725+01	1	0	0	1	0	\N	{"errors": [], "safety": {"body_peek": true, "store_used": false, "imap_readonly": true, "flags_modified": false}, "imported": [], "mailboxes": ["INBOX", "INBOX.Sent"], "duplicates": [{"uid": "1", "mailbox": "INBOX", "occurrence_id": 1}]}
428	1	3	success	2026-06-16 00:24:40.010235+01	2026-06-16 00:24:40.075259+01	1	0	0	1	0	\N	{"errors": [], "safety": {"body_peek": true, "store_used": false, "imap_readonly": true, "flags_modified": false}, "imported": [], "mailboxes": ["INBOX", "INBOX.Sent"], "duplicates": [{"uid": "1", "mailbox": "INBOX", "occurrence_id": 1}]}
429	1	3	success	2026-06-16 00:29:50.168685+01	2026-06-16 00:29:50.218225+01	1	0	0	1	0	\N	{"errors": [], "safety": {"body_peek": true, "store_used": false, "imap_readonly": true, "flags_modified": false}, "imported": [], "mailboxes": ["INBOX", "INBOX.Sent"], "duplicates": [{"uid": "1", "mailbox": "INBOX", "occurrence_id": 1}]}
430	1	3	success	2026-06-16 00:35:00.33284+01	2026-06-16 00:35:00.384554+01	1	0	0	1	0	\N	{"errors": [], "safety": {"body_peek": true, "store_used": false, "imap_readonly": true, "flags_modified": false}, "imported": [], "mailboxes": ["INBOX", "INBOX.Sent"], "duplicates": [{"uid": "1", "mailbox": "INBOX", "occurrence_id": 1}]}
431	1	3	success	2026-06-16 00:40:10.490778+01	2026-06-16 00:40:10.542826+01	1	0	0	1	0	\N	{"errors": [], "safety": {"body_peek": true, "store_used": false, "imap_readonly": true, "flags_modified": false}, "imported": [], "mailboxes": ["INBOX", "INBOX.Sent"], "duplicates": [{"uid": "1", "mailbox": "INBOX", "occurrence_id": 1}]}
432	1	3	success	2026-06-16 00:45:20.653403+01	2026-06-16 00:45:20.754027+01	1	0	0	1	0	\N	{"errors": [], "safety": {"body_peek": true, "store_used": false, "imap_readonly": true, "flags_modified": false}, "imported": [], "mailboxes": ["INBOX", "INBOX.Sent"], "duplicates": [{"uid": "1", "mailbox": "INBOX", "occurrence_id": 1}]}
433	1	3	success	2026-06-16 00:50:30.850803+01	2026-06-16 00:50:30.959462+01	1	0	0	1	0	\N	{"errors": [], "safety": {"body_peek": true, "store_used": false, "imap_readonly": true, "flags_modified": false}, "imported": [], "mailboxes": ["INBOX", "INBOX.Sent"], "duplicates": [{"uid": "1", "mailbox": "INBOX", "occurrence_id": 1}]}
434	1	3	success	2026-06-16 00:55:41.054963+01	2026-06-16 00:55:41.17238+01	1	0	0	1	0	\N	{"errors": [], "safety": {"body_peek": true, "store_used": false, "imap_readonly": true, "flags_modified": false}, "imported": [], "mailboxes": ["INBOX", "INBOX.Sent"], "duplicates": [{"uid": "1", "mailbox": "INBOX", "occurrence_id": 1}]}
435	1	3	success	2026-06-16 01:00:51.308116+01	2026-06-16 01:00:51.367265+01	1	0	0	1	0	\N	{"errors": [], "safety": {"body_peek": true, "store_used": false, "imap_readonly": true, "flags_modified": false}, "imported": [], "mailboxes": ["INBOX", "INBOX.Sent"], "duplicates": [{"uid": "1", "mailbox": "INBOX", "occurrence_id": 1}]}
436	1	3	success	2026-06-16 01:06:01.471301+01	2026-06-16 01:06:01.535286+01	1	0	0	1	0	\N	{"errors": [], "safety": {"body_peek": true, "store_used": false, "imap_readonly": true, "flags_modified": false}, "imported": [], "mailboxes": ["INBOX", "INBOX.Sent"], "duplicates": [{"uid": "1", "mailbox": "INBOX", "occurrence_id": 1}]}
437	1	3	success	2026-06-16 01:11:11.642395+01	2026-06-16 01:11:11.710704+01	1	0	0	1	0	\N	{"errors": [], "safety": {"body_peek": true, "store_used": false, "imap_readonly": true, "flags_modified": false}, "imported": [], "mailboxes": ["INBOX", "INBOX.Sent"], "duplicates": [{"uid": "1", "mailbox": "INBOX", "occurrence_id": 1}]}
438	1	3	success	2026-06-16 01:16:21.826357+01	2026-06-16 01:16:21.89167+01	1	0	0	1	0	\N	{"errors": [], "safety": {"body_peek": true, "store_used": false, "imap_readonly": true, "flags_modified": false}, "imported": [], "mailboxes": ["INBOX", "INBOX.Sent"], "duplicates": [{"uid": "1", "mailbox": "INBOX", "occurrence_id": 1}]}
439	1	3	success	2026-06-16 01:21:31.997522+01	2026-06-16 01:21:32.052641+01	1	0	0	1	0	\N	{"errors": [], "safety": {"body_peek": true, "store_used": false, "imap_readonly": true, "flags_modified": false}, "imported": [], "mailboxes": ["INBOX", "INBOX.Sent"], "duplicates": [{"uid": "1", "mailbox": "INBOX", "occurrence_id": 1}]}
440	1	3	success	2026-06-16 01:26:42.149012+01	2026-06-16 01:26:42.202776+01	1	0	0	1	0	\N	{"errors": [], "safety": {"body_peek": true, "store_used": false, "imap_readonly": true, "flags_modified": false}, "imported": [], "mailboxes": ["INBOX", "INBOX.Sent"], "duplicates": [{"uid": "1", "mailbox": "INBOX", "occurrence_id": 1}]}
441	1	3	success	2026-06-16 01:31:52.308807+01	2026-06-16 01:31:52.368118+01	1	0	0	1	0	\N	{"errors": [], "safety": {"body_peek": true, "store_used": false, "imap_readonly": true, "flags_modified": false}, "imported": [], "mailboxes": ["INBOX", "INBOX.Sent"], "duplicates": [{"uid": "1", "mailbox": "INBOX", "occurrence_id": 1}]}
442	1	3	success	2026-06-16 01:37:02.463416+01	2026-06-16 01:37:02.514963+01	1	0	0	1	0	\N	{"errors": [], "safety": {"body_peek": true, "store_used": false, "imap_readonly": true, "flags_modified": false}, "imported": [], "mailboxes": ["INBOX", "INBOX.Sent"], "duplicates": [{"uid": "1", "mailbox": "INBOX", "occurrence_id": 1}]}
443	1	3	success	2026-06-16 01:42:12.625861+01	2026-06-16 01:42:12.723821+01	1	0	0	1	0	\N	{"errors": [], "safety": {"body_peek": true, "store_used": false, "imap_readonly": true, "flags_modified": false}, "imported": [], "mailboxes": ["INBOX", "INBOX.Sent"], "duplicates": [{"uid": "1", "mailbox": "INBOX", "occurrence_id": 1}]}
444	1	3	success	2026-06-16 01:47:22.837433+01	2026-06-16 01:47:22.933798+01	1	0	0	1	0	\N	{"errors": [], "safety": {"body_peek": true, "store_used": false, "imap_readonly": true, "flags_modified": false}, "imported": [], "mailboxes": ["INBOX", "INBOX.Sent"], "duplicates": [{"uid": "1", "mailbox": "INBOX", "occurrence_id": 1}]}
445	1	3	success	2026-06-16 01:52:33.044359+01	2026-06-16 01:52:33.12981+01	1	0	0	1	0	\N	{"errors": [], "safety": {"body_peek": true, "store_used": false, "imap_readonly": true, "flags_modified": false}, "imported": [], "mailboxes": ["INBOX", "INBOX.Sent"], "duplicates": [{"uid": "1", "mailbox": "INBOX", "occurrence_id": 1}]}
446	1	3	success	2026-06-16 01:57:43.256932+01	2026-06-16 01:57:43.311753+01	1	0	0	1	0	\N	{"errors": [], "safety": {"body_peek": true, "store_used": false, "imap_readonly": true, "flags_modified": false}, "imported": [], "mailboxes": ["INBOX", "INBOX.Sent"], "duplicates": [{"uid": "1", "mailbox": "INBOX", "occurrence_id": 1}]}
447	1	3	success	2026-06-16 02:02:53.419779+01	2026-06-16 02:02:53.483756+01	1	0	0	1	0	\N	{"errors": [], "safety": {"body_peek": true, "store_used": false, "imap_readonly": true, "flags_modified": false}, "imported": [], "mailboxes": ["INBOX", "INBOX.Sent"], "duplicates": [{"uid": "1", "mailbox": "INBOX", "occurrence_id": 1}]}
448	1	3	success	2026-06-16 02:08:03.585671+01	2026-06-16 02:08:03.637372+01	1	0	0	1	0	\N	{"errors": [], "safety": {"body_peek": true, "store_used": false, "imap_readonly": true, "flags_modified": false}, "imported": [], "mailboxes": ["INBOX", "INBOX.Sent"], "duplicates": [{"uid": "1", "mailbox": "INBOX", "occurrence_id": 1}]}
449	1	3	success	2026-06-16 02:13:13.712031+01	2026-06-16 02:13:13.770561+01	1	0	0	1	0	\N	{"errors": [], "safety": {"body_peek": true, "store_used": false, "imap_readonly": true, "flags_modified": false}, "imported": [], "mailboxes": ["INBOX", "INBOX.Sent"], "duplicates": [{"uid": "1", "mailbox": "INBOX", "occurrence_id": 1}]}
450	1	3	success	2026-06-16 02:18:23.839848+01	2026-06-16 02:18:23.897177+01	1	0	0	1	0	\N	{"errors": [], "safety": {"body_peek": true, "store_used": false, "imap_readonly": true, "flags_modified": false}, "imported": [], "mailboxes": ["INBOX", "INBOX.Sent"], "duplicates": [{"uid": "1", "mailbox": "INBOX", "occurrence_id": 1}]}
451	1	3	success	2026-06-16 02:23:34.004199+01	2026-06-16 02:23:34.056429+01	1	0	0	1	0	\N	{"errors": [], "safety": {"body_peek": true, "store_used": false, "imap_readonly": true, "flags_modified": false}, "imported": [], "mailboxes": ["INBOX", "INBOX.Sent"], "duplicates": [{"uid": "1", "mailbox": "INBOX", "occurrence_id": 1}]}
452	1	3	success	2026-06-16 02:28:44.156656+01	2026-06-16 02:28:44.211921+01	1	0	0	1	0	\N	{"errors": [], "safety": {"body_peek": true, "store_used": false, "imap_readonly": true, "flags_modified": false}, "imported": [], "mailboxes": ["INBOX", "INBOX.Sent"], "duplicates": [{"uid": "1", "mailbox": "INBOX", "occurrence_id": 1}]}
453	1	3	success	2026-06-16 02:33:54.305554+01	2026-06-16 02:33:54.358356+01	1	0	0	1	0	\N	{"errors": [], "safety": {"body_peek": true, "store_used": false, "imap_readonly": true, "flags_modified": false}, "imported": [], "mailboxes": ["INBOX", "INBOX.Sent"], "duplicates": [{"uid": "1", "mailbox": "INBOX", "occurrence_id": 1}]}
454	1	3	success	2026-06-16 02:39:04.464229+01	2026-06-16 02:39:04.51893+01	1	0	0	1	0	\N	{"errors": [], "safety": {"body_peek": true, "store_used": false, "imap_readonly": true, "flags_modified": false}, "imported": [], "mailboxes": ["INBOX", "INBOX.Sent"], "duplicates": [{"uid": "1", "mailbox": "INBOX", "occurrence_id": 1}]}
455	1	3	success	2026-06-16 02:44:14.618989+01	2026-06-16 02:44:14.710254+01	1	0	0	1	0	\N	{"errors": [], "safety": {"body_peek": true, "store_used": false, "imap_readonly": true, "flags_modified": false}, "imported": [], "mailboxes": ["INBOX", "INBOX.Sent"], "duplicates": [{"uid": "1", "mailbox": "INBOX", "occurrence_id": 1}]}
456	1	3	success	2026-06-16 02:49:24.815776+01	2026-06-16 02:49:24.875535+01	1	0	0	1	0	\N	{"errors": [], "safety": {"body_peek": true, "store_used": false, "imap_readonly": true, "flags_modified": false}, "imported": [], "mailboxes": ["INBOX", "INBOX.Sent"], "duplicates": [{"uid": "1", "mailbox": "INBOX", "occurrence_id": 1}]}
457	1	3	success	2026-06-16 02:54:34.978199+01	2026-06-16 02:54:35.08005+01	1	0	0	1	0	\N	{"errors": [], "safety": {"body_peek": true, "store_used": false, "imap_readonly": true, "flags_modified": false}, "imported": [], "mailboxes": ["INBOX", "INBOX.Sent"], "duplicates": [{"uid": "1", "mailbox": "INBOX", "occurrence_id": 1}]}
458	1	3	success	2026-06-16 02:59:45.178161+01	2026-06-16 02:59:45.229765+01	1	0	0	1	0	\N	{"errors": [], "safety": {"body_peek": true, "store_used": false, "imap_readonly": true, "flags_modified": false}, "imported": [], "mailboxes": ["INBOX", "INBOX.Sent"], "duplicates": [{"uid": "1", "mailbox": "INBOX", "occurrence_id": 1}]}
459	1	3	success	2026-06-16 03:04:55.323721+01	2026-06-16 03:04:55.422531+01	1	0	0	1	0	\N	{"errors": [], "safety": {"body_peek": true, "store_used": false, "imap_readonly": true, "flags_modified": false}, "imported": [], "mailboxes": ["INBOX", "INBOX.Sent"], "duplicates": [{"uid": "1", "mailbox": "INBOX", "occurrence_id": 1}]}
460	1	3	success	2026-06-16 03:10:05.507139+01	2026-06-16 03:10:05.592556+01	1	0	0	1	0	\N	{"errors": [], "safety": {"body_peek": true, "store_used": false, "imap_readonly": true, "flags_modified": false}, "imported": [], "mailboxes": ["INBOX", "INBOX.Sent"], "duplicates": [{"uid": "1", "mailbox": "INBOX", "occurrence_id": 1}]}
461	1	3	success	2026-06-16 03:15:15.677427+01	2026-06-16 03:15:15.729878+01	1	0	0	1	0	\N	{"errors": [], "safety": {"body_peek": true, "store_used": false, "imap_readonly": true, "flags_modified": false}, "imported": [], "mailboxes": ["INBOX", "INBOX.Sent"], "duplicates": [{"uid": "1", "mailbox": "INBOX", "occurrence_id": 1}]}
462	1	3	success	2026-06-16 03:20:25.82987+01	2026-06-16 03:20:25.887184+01	1	0	0	1	0	\N	{"errors": [], "safety": {"body_peek": true, "store_used": false, "imap_readonly": true, "flags_modified": false}, "imported": [], "mailboxes": ["INBOX", "INBOX.Sent"], "duplicates": [{"uid": "1", "mailbox": "INBOX", "occurrence_id": 1}]}
463	1	3	success	2026-06-16 03:25:35.939643+01	2026-06-16 03:25:35.993149+01	1	0	0	1	0	\N	{"errors": [], "safety": {"body_peek": true, "store_used": false, "imap_readonly": true, "flags_modified": false}, "imported": [], "mailboxes": ["INBOX", "INBOX.Sent"], "duplicates": [{"uid": "1", "mailbox": "INBOX", "occurrence_id": 1}]}
464	1	3	success	2026-06-16 03:30:46.046121+01	2026-06-16 03:30:46.100614+01	1	0	0	1	0	\N	{"errors": [], "safety": {"body_peek": true, "store_used": false, "imap_readonly": true, "flags_modified": false}, "imported": [], "mailboxes": ["INBOX", "INBOX.Sent"], "duplicates": [{"uid": "1", "mailbox": "INBOX", "occurrence_id": 1}]}
465	1	3	success	2026-06-16 03:35:56.205666+01	2026-06-16 03:35:56.299673+01	1	0	0	1	0	\N	{"errors": [], "safety": {"body_peek": true, "store_used": false, "imap_readonly": true, "flags_modified": false}, "imported": [], "mailboxes": ["INBOX", "INBOX.Sent"], "duplicates": [{"uid": "1", "mailbox": "INBOX", "occurrence_id": 1}]}
466	1	3	success	2026-06-16 03:41:06.414732+01	2026-06-16 03:41:06.468082+01	1	0	0	1	0	\N	{"errors": [], "safety": {"body_peek": true, "store_used": false, "imap_readonly": true, "flags_modified": false}, "imported": [], "mailboxes": ["INBOX", "INBOX.Sent"], "duplicates": [{"uid": "1", "mailbox": "INBOX", "occurrence_id": 1}]}
467	1	3	success	2026-06-16 03:46:16.580955+01	2026-06-16 03:46:16.698936+01	1	0	0	1	0	\N	{"errors": [], "safety": {"body_peek": true, "store_used": false, "imap_readonly": true, "flags_modified": false}, "imported": [], "mailboxes": ["INBOX", "INBOX.Sent"], "duplicates": [{"uid": "1", "mailbox": "INBOX", "occurrence_id": 1}]}
468	1	3	success	2026-06-16 03:51:26.806658+01	2026-06-16 03:51:26.869881+01	1	0	0	1	0	\N	{"errors": [], "safety": {"body_peek": true, "store_used": false, "imap_readonly": true, "flags_modified": false}, "imported": [], "mailboxes": ["INBOX", "INBOX.Sent"], "duplicates": [{"uid": "1", "mailbox": "INBOX", "occurrence_id": 1}]}
469	1	3	success	2026-06-16 03:56:36.982817+01	2026-06-16 03:56:37.035842+01	1	0	0	1	0	\N	{"errors": [], "safety": {"body_peek": true, "store_used": false, "imap_readonly": true, "flags_modified": false}, "imported": [], "mailboxes": ["INBOX", "INBOX.Sent"], "duplicates": [{"uid": "1", "mailbox": "INBOX", "occurrence_id": 1}]}
470	1	3	success	2026-06-16 04:01:47.132408+01	2026-06-16 04:01:47.222657+01	1	0	0	1	0	\N	{"errors": [], "safety": {"body_peek": true, "store_used": false, "imap_readonly": true, "flags_modified": false}, "imported": [], "mailboxes": ["INBOX", "INBOX.Sent"], "duplicates": [{"uid": "1", "mailbox": "INBOX", "occurrence_id": 1}]}
471	1	3	success	2026-06-16 04:06:57.332645+01	2026-06-16 04:06:57.383865+01	1	0	0	1	0	\N	{"errors": [], "safety": {"body_peek": true, "store_used": false, "imap_readonly": true, "flags_modified": false}, "imported": [], "mailboxes": ["INBOX", "INBOX.Sent"], "duplicates": [{"uid": "1", "mailbox": "INBOX", "occurrence_id": 1}]}
472	1	3	success	2026-06-16 04:12:07.486367+01	2026-06-16 04:12:07.54912+01	1	0	0	1	0	\N	{"errors": [], "safety": {"body_peek": true, "store_used": false, "imap_readonly": true, "flags_modified": false}, "imported": [], "mailboxes": ["INBOX", "INBOX.Sent"], "duplicates": [{"uid": "1", "mailbox": "INBOX", "occurrence_id": 1}]}
473	1	3	success	2026-06-16 04:17:17.654443+01	2026-06-16 04:17:17.748512+01	1	0	0	1	0	\N	{"errors": [], "safety": {"body_peek": true, "store_used": false, "imap_readonly": true, "flags_modified": false}, "imported": [], "mailboxes": ["INBOX", "INBOX.Sent"], "duplicates": [{"uid": "1", "mailbox": "INBOX", "occurrence_id": 1}]}
474	1	3	success	2026-06-16 04:22:27.860415+01	2026-06-16 04:22:27.925454+01	1	0	0	1	0	\N	{"errors": [], "safety": {"body_peek": true, "store_used": false, "imap_readonly": true, "flags_modified": false}, "imported": [], "mailboxes": ["INBOX", "INBOX.Sent"], "duplicates": [{"uid": "1", "mailbox": "INBOX", "occurrence_id": 1}]}
475	1	3	success	2026-06-16 04:27:38.030822+01	2026-06-16 04:27:38.096425+01	1	0	0	1	0	\N	{"errors": [], "safety": {"body_peek": true, "store_used": false, "imap_readonly": true, "flags_modified": false}, "imported": [], "mailboxes": ["INBOX", "INBOX.Sent"], "duplicates": [{"uid": "1", "mailbox": "INBOX", "occurrence_id": 1}]}
476	1	3	success	2026-06-16 04:32:48.197182+01	2026-06-16 04:32:48.248702+01	1	0	0	1	0	\N	{"errors": [], "safety": {"body_peek": true, "store_used": false, "imap_readonly": true, "flags_modified": false}, "imported": [], "mailboxes": ["INBOX", "INBOX.Sent"], "duplicates": [{"uid": "1", "mailbox": "INBOX", "occurrence_id": 1}]}
477	1	3	success	2026-06-16 04:37:58.362585+01	2026-06-16 04:37:58.425428+01	1	0	0	1	0	\N	{"errors": [], "safety": {"body_peek": true, "store_used": false, "imap_readonly": true, "flags_modified": false}, "imported": [], "mailboxes": ["INBOX", "INBOX.Sent"], "duplicates": [{"uid": "1", "mailbox": "INBOX", "occurrence_id": 1}]}
478	1	3	success	2026-06-16 04:43:08.515199+01	2026-06-16 04:43:08.570614+01	1	0	0	1	0	\N	{"errors": [], "safety": {"body_peek": true, "store_used": false, "imap_readonly": true, "flags_modified": false}, "imported": [], "mailboxes": ["INBOX", "INBOX.Sent"], "duplicates": [{"uid": "1", "mailbox": "INBOX", "occurrence_id": 1}]}
479	1	3	success	2026-06-16 04:48:18.620175+01	2026-06-16 04:48:18.671791+01	1	0	0	1	0	\N	{"errors": [], "safety": {"body_peek": true, "store_used": false, "imap_readonly": true, "flags_modified": false}, "imported": [], "mailboxes": ["INBOX", "INBOX.Sent"], "duplicates": [{"uid": "1", "mailbox": "INBOX", "occurrence_id": 1}]}
480	1	3	success	2026-06-16 04:53:28.760546+01	2026-06-16 04:53:28.869879+01	1	0	0	1	0	\N	{"errors": [], "safety": {"body_peek": true, "store_used": false, "imap_readonly": true, "flags_modified": false}, "imported": [], "mailboxes": ["INBOX", "INBOX.Sent"], "duplicates": [{"uid": "1", "mailbox": "INBOX", "occurrence_id": 1}]}
481	1	3	success	2026-06-16 04:58:38.973705+01	2026-06-16 04:58:39.076865+01	1	0	0	1	0	\N	{"errors": [], "safety": {"body_peek": true, "store_used": false, "imap_readonly": true, "flags_modified": false}, "imported": [], "mailboxes": ["INBOX", "INBOX.Sent"], "duplicates": [{"uid": "1", "mailbox": "INBOX", "occurrence_id": 1}]}
482	1	3	success	2026-06-16 05:03:49.17627+01	2026-06-16 05:03:49.247825+01	1	0	0	1	0	\N	{"errors": [], "safety": {"body_peek": true, "store_used": false, "imap_readonly": true, "flags_modified": false}, "imported": [], "mailboxes": ["INBOX", "INBOX.Sent"], "duplicates": [{"uid": "1", "mailbox": "INBOX", "occurrence_id": 1}]}
483	1	3	success	2026-06-16 05:08:59.366939+01	2026-06-16 05:08:59.457775+01	1	0	0	1	0	\N	{"errors": [], "safety": {"body_peek": true, "store_used": false, "imap_readonly": true, "flags_modified": false}, "imported": [], "mailboxes": ["INBOX", "INBOX.Sent"], "duplicates": [{"uid": "1", "mailbox": "INBOX", "occurrence_id": 1}]}
484	1	3	success	2026-06-16 05:14:09.536486+01	2026-06-16 05:14:09.588685+01	1	0	0	1	0	\N	{"errors": [], "safety": {"body_peek": true, "store_used": false, "imap_readonly": true, "flags_modified": false}, "imported": [], "mailboxes": ["INBOX", "INBOX.Sent"], "duplicates": [{"uid": "1", "mailbox": "INBOX", "occurrence_id": 1}]}
485	1	3	success	2026-06-16 05:19:19.703033+01	2026-06-16 05:19:19.754637+01	1	0	0	1	0	\N	{"errors": [], "safety": {"body_peek": true, "store_used": false, "imap_readonly": true, "flags_modified": false}, "imported": [], "mailboxes": ["INBOX", "INBOX.Sent"], "duplicates": [{"uid": "1", "mailbox": "INBOX", "occurrence_id": 1}]}
486	1	3	success	2026-06-16 05:24:29.848969+01	2026-06-16 05:24:29.900034+01	1	0	0	1	0	\N	{"errors": [], "safety": {"body_peek": true, "store_used": false, "imap_readonly": true, "flags_modified": false}, "imported": [], "mailboxes": ["INBOX", "INBOX.Sent"], "duplicates": [{"uid": "1", "mailbox": "INBOX", "occurrence_id": 1}]}
487	1	3	success	2026-06-16 05:29:40.010962+01	2026-06-16 05:29:40.059021+01	1	0	0	1	0	\N	{"errors": [], "safety": {"body_peek": true, "store_used": false, "imap_readonly": true, "flags_modified": false}, "imported": [], "mailboxes": ["INBOX", "INBOX.Sent"], "duplicates": [{"uid": "1", "mailbox": "INBOX", "occurrence_id": 1}]}
488	1	3	success	2026-06-16 05:34:50.163318+01	2026-06-16 05:34:50.220978+01	1	0	0	1	0	\N	{"errors": [], "safety": {"body_peek": true, "store_used": false, "imap_readonly": true, "flags_modified": false}, "imported": [], "mailboxes": ["INBOX", "INBOX.Sent"], "duplicates": [{"uid": "1", "mailbox": "INBOX", "occurrence_id": 1}]}
489	1	3	success	2026-06-16 05:40:00.329125+01	2026-06-16 05:40:00.381525+01	1	0	0	1	0	\N	{"errors": [], "safety": {"body_peek": true, "store_used": false, "imap_readonly": true, "flags_modified": false}, "imported": [], "mailboxes": ["INBOX", "INBOX.Sent"], "duplicates": [{"uid": "1", "mailbox": "INBOX", "occurrence_id": 1}]}
490	1	3	success	2026-06-16 05:45:10.482174+01	2026-06-16 05:45:10.535552+01	1	0	0	1	0	\N	{"errors": [], "safety": {"body_peek": true, "store_used": false, "imap_readonly": true, "flags_modified": false}, "imported": [], "mailboxes": ["INBOX", "INBOX.Sent"], "duplicates": [{"uid": "1", "mailbox": "INBOX", "occurrence_id": 1}]}
491	1	3	success	2026-06-16 05:50:20.630927+01	2026-06-16 05:50:20.681852+01	1	0	0	1	0	\N	{"errors": [], "safety": {"body_peek": true, "store_used": false, "imap_readonly": true, "flags_modified": false}, "imported": [], "mailboxes": ["INBOX", "INBOX.Sent"], "duplicates": [{"uid": "1", "mailbox": "INBOX", "occurrence_id": 1}]}
492	1	3	success	2026-06-16 05:55:30.788941+01	2026-06-16 05:55:30.852645+01	1	0	0	1	0	\N	{"errors": [], "safety": {"body_peek": true, "store_used": false, "imap_readonly": true, "flags_modified": false}, "imported": [], "mailboxes": ["INBOX", "INBOX.Sent"], "duplicates": [{"uid": "1", "mailbox": "INBOX", "occurrence_id": 1}]}
493	1	3	success	2026-06-16 06:00:40.959389+01	2026-06-16 06:00:41.027298+01	1	0	0	1	0	\N	{"errors": [], "safety": {"body_peek": true, "store_used": false, "imap_readonly": true, "flags_modified": false}, "imported": [], "mailboxes": ["INBOX", "INBOX.Sent"], "duplicates": [{"uid": "1", "mailbox": "INBOX", "occurrence_id": 1}]}
494	1	3	success	2026-06-16 06:05:51.138877+01	2026-06-16 06:05:51.191408+01	1	0	0	1	0	\N	{"errors": [], "safety": {"body_peek": true, "store_used": false, "imap_readonly": true, "flags_modified": false}, "imported": [], "mailboxes": ["INBOX", "INBOX.Sent"], "duplicates": [{"uid": "1", "mailbox": "INBOX", "occurrence_id": 1}]}
495	1	3	success	2026-06-16 06:11:01.298045+01	2026-06-16 06:11:01.3491+01	1	0	0	1	0	\N	{"errors": [], "safety": {"body_peek": true, "store_used": false, "imap_readonly": true, "flags_modified": false}, "imported": [], "mailboxes": ["INBOX", "INBOX.Sent"], "duplicates": [{"uid": "1", "mailbox": "INBOX", "occurrence_id": 1}]}
496	1	3	success	2026-06-16 06:16:11.463636+01	2026-06-16 06:16:11.516769+01	1	0	0	1	0	\N	{"errors": [], "safety": {"body_peek": true, "store_used": false, "imap_readonly": true, "flags_modified": false}, "imported": [], "mailboxes": ["INBOX", "INBOX.Sent"], "duplicates": [{"uid": "1", "mailbox": "INBOX", "occurrence_id": 1}]}
497	1	3	success	2026-06-16 06:21:21.619704+01	2026-06-16 06:21:21.728897+01	1	0	0	1	0	\N	{"errors": [], "safety": {"body_peek": true, "store_used": false, "imap_readonly": true, "flags_modified": false}, "imported": [], "mailboxes": ["INBOX", "INBOX.Sent"], "duplicates": [{"uid": "1", "mailbox": "INBOX", "occurrence_id": 1}]}
498	1	3	success	2026-06-16 06:26:31.82734+01	2026-06-16 06:26:31.878824+01	1	0	0	1	0	\N	{"errors": [], "safety": {"body_peek": true, "store_used": false, "imap_readonly": true, "flags_modified": false}, "imported": [], "mailboxes": ["INBOX", "INBOX.Sent"], "duplicates": [{"uid": "1", "mailbox": "INBOX", "occurrence_id": 1}]}
499	1	3	success	2026-06-16 06:31:41.982366+01	2026-06-16 06:31:42.067412+01	1	0	0	1	0	\N	{"errors": [], "safety": {"body_peek": true, "store_used": false, "imap_readonly": true, "flags_modified": false}, "imported": [], "mailboxes": ["INBOX", "INBOX.Sent"], "duplicates": [{"uid": "1", "mailbox": "INBOX", "occurrence_id": 1}]}
500	1	3	success	2026-06-16 06:36:52.181713+01	2026-06-16 06:36:52.284246+01	1	0	0	1	0	\N	{"errors": [], "safety": {"body_peek": true, "store_used": false, "imap_readonly": true, "flags_modified": false}, "imported": [], "mailboxes": ["INBOX", "INBOX.Sent"], "duplicates": [{"uid": "1", "mailbox": "INBOX", "occurrence_id": 1}]}
501	1	3	success	2026-06-16 06:42:02.389088+01	2026-06-16 06:42:02.43944+01	1	0	0	1	0	\N	{"errors": [], "safety": {"body_peek": true, "store_used": false, "imap_readonly": true, "flags_modified": false}, "imported": [], "mailboxes": ["INBOX", "INBOX.Sent"], "duplicates": [{"uid": "1", "mailbox": "INBOX", "occurrence_id": 1}]}
502	1	3	success	2026-06-16 06:47:12.541242+01	2026-06-16 06:47:12.604778+01	1	0	0	1	0	\N	{"errors": [], "safety": {"body_peek": true, "store_used": false, "imap_readonly": true, "flags_modified": false}, "imported": [], "mailboxes": ["INBOX", "INBOX.Sent"], "duplicates": [{"uid": "1", "mailbox": "INBOX", "occurrence_id": 1}]}
503	1	3	success	2026-06-16 06:52:22.714634+01	2026-06-16 06:52:22.813748+01	1	0	0	1	0	\N	{"errors": [], "safety": {"body_peek": true, "store_used": false, "imap_readonly": true, "flags_modified": false}, "imported": [], "mailboxes": ["INBOX", "INBOX.Sent"], "duplicates": [{"uid": "1", "mailbox": "INBOX", "occurrence_id": 1}]}
504	1	3	success	2026-06-16 06:57:32.91881+01	2026-06-16 06:57:32.972743+01	1	0	0	1	0	\N	{"errors": [], "safety": {"body_peek": true, "store_used": false, "imap_readonly": true, "flags_modified": false}, "imported": [], "mailboxes": ["INBOX", "INBOX.Sent"], "duplicates": [{"uid": "1", "mailbox": "INBOX", "occurrence_id": 1}]}
505	1	3	success	2026-06-16 07:02:43.056632+01	2026-06-16 07:02:43.116592+01	1	0	0	1	0	\N	{"errors": [], "safety": {"body_peek": true, "store_used": false, "imap_readonly": true, "flags_modified": false}, "imported": [], "mailboxes": ["INBOX", "INBOX.Sent"], "duplicates": [{"uid": "1", "mailbox": "INBOX", "occurrence_id": 1}]}
506	1	3	success	2026-06-16 07:07:53.185277+01	2026-06-16 07:07:53.242155+01	1	0	0	1	0	\N	{"errors": [], "safety": {"body_peek": true, "store_used": false, "imap_readonly": true, "flags_modified": false}, "imported": [], "mailboxes": ["INBOX", "INBOX.Sent"], "duplicates": [{"uid": "1", "mailbox": "INBOX", "occurrence_id": 1}]}
507	1	3	success	2026-06-16 07:13:03.336778+01	2026-06-16 07:13:03.386879+01	1	0	0	1	0	\N	{"errors": [], "safety": {"body_peek": true, "store_used": false, "imap_readonly": true, "flags_modified": false}, "imported": [], "mailboxes": ["INBOX", "INBOX.Sent"], "duplicates": [{"uid": "1", "mailbox": "INBOX", "occurrence_id": 1}]}
508	1	3	success	2026-06-16 07:18:13.494348+01	2026-06-16 07:18:13.547295+01	1	0	0	1	0	\N	{"errors": [], "safety": {"body_peek": true, "store_used": false, "imap_readonly": true, "flags_modified": false}, "imported": [], "mailboxes": ["INBOX", "INBOX.Sent"], "duplicates": [{"uid": "1", "mailbox": "INBOX", "occurrence_id": 1}]}
509	1	3	success	2026-06-16 07:23:23.650221+01	2026-06-16 07:23:23.757815+01	1	0	0	1	0	\N	{"errors": [], "safety": {"body_peek": true, "store_used": false, "imap_readonly": true, "flags_modified": false}, "imported": [], "mailboxes": ["INBOX", "INBOX.Sent"], "duplicates": [{"uid": "1", "mailbox": "INBOX", "occurrence_id": 1}]}
510	1	3	success	2026-06-16 07:28:33.890525+01	2026-06-16 07:28:33.954214+01	1	0	0	1	0	\N	{"errors": [], "safety": {"body_peek": true, "store_used": false, "imap_readonly": true, "flags_modified": false}, "imported": [], "mailboxes": ["INBOX", "INBOX.Sent"], "duplicates": [{"uid": "1", "mailbox": "INBOX", "occurrence_id": 1}]}
511	1	3	success	2026-06-16 07:33:44.028842+01	2026-06-16 07:33:44.090693+01	1	0	0	1	0	\N	{"errors": [], "safety": {"body_peek": true, "store_used": false, "imap_readonly": true, "flags_modified": false}, "imported": [], "mailboxes": ["INBOX", "INBOX.Sent"], "duplicates": [{"uid": "1", "mailbox": "INBOX", "occurrence_id": 1}]}
512	1	3	success	2026-06-16 07:38:54.17384+01	2026-06-16 07:38:54.227679+01	1	0	0	1	0	\N	{"errors": [], "safety": {"body_peek": true, "store_used": false, "imap_readonly": true, "flags_modified": false}, "imported": [], "mailboxes": ["INBOX", "INBOX.Sent"], "duplicates": [{"uid": "1", "mailbox": "INBOX", "occurrence_id": 1}]}
513	1	3	success	2026-06-16 07:44:04.282041+01	2026-06-16 07:44:04.342825+01	1	0	0	1	0	\N	{"errors": [], "safety": {"body_peek": true, "store_used": false, "imap_readonly": true, "flags_modified": false}, "imported": [], "mailboxes": ["INBOX", "INBOX.Sent"], "duplicates": [{"uid": "1", "mailbox": "INBOX", "occurrence_id": 1}]}
514	1	3	success	2026-06-16 07:49:14.399814+01	2026-06-16 07:49:14.463643+01	1	0	0	1	0	\N	{"errors": [], "safety": {"body_peek": true, "store_used": false, "imap_readonly": true, "flags_modified": false}, "imported": [], "mailboxes": ["INBOX", "INBOX.Sent"], "duplicates": [{"uid": "1", "mailbox": "INBOX", "occurrence_id": 1}]}
515	1	3	success	2026-06-16 07:54:24.519272+01	2026-06-16 07:54:24.591371+01	1	0	0	1	0	\N	{"errors": [], "safety": {"body_peek": true, "store_used": false, "imap_readonly": true, "flags_modified": false}, "imported": [], "mailboxes": ["INBOX", "INBOX.Sent"], "duplicates": [{"uid": "1", "mailbox": "INBOX", "occurrence_id": 1}]}
516	1	3	success	2026-06-16 07:59:34.645462+01	2026-06-16 07:59:34.699284+01	1	0	0	1	0	\N	{"errors": [], "safety": {"body_peek": true, "store_used": false, "imap_readonly": true, "flags_modified": false}, "imported": [], "mailboxes": ["INBOX", "INBOX.Sent"], "duplicates": [{"uid": "1", "mailbox": "INBOX", "occurrence_id": 1}]}
517	1	3	success	2026-06-16 08:04:44.755822+01	2026-06-16 08:04:44.811562+01	1	0	0	1	0	\N	{"errors": [], "safety": {"body_peek": true, "store_used": false, "imap_readonly": true, "flags_modified": false}, "imported": [], "mailboxes": ["INBOX", "INBOX.Sent"], "duplicates": [{"uid": "1", "mailbox": "INBOX", "occurrence_id": 1}]}
518	1	3	success	2026-06-16 08:09:54.873787+01	2026-06-16 08:09:54.927318+01	1	0	0	1	0	\N	{"errors": [], "safety": {"body_peek": true, "store_used": false, "imap_readonly": true, "flags_modified": false}, "imported": [], "mailboxes": ["INBOX", "INBOX.Sent"], "duplicates": [{"uid": "1", "mailbox": "INBOX", "occurrence_id": 1}]}
519	1	3	success	2026-06-16 08:15:04.985637+01	2026-06-16 08:15:05.037609+01	1	0	0	1	0	\N	{"errors": [], "safety": {"body_peek": true, "store_used": false, "imap_readonly": true, "flags_modified": false}, "imported": [], "mailboxes": ["INBOX", "INBOX.Sent"], "duplicates": [{"uid": "1", "mailbox": "INBOX", "occurrence_id": 1}]}
520	1	3	success	2026-06-16 08:20:15.154662+01	2026-06-16 08:20:15.251636+01	1	0	0	1	0	\N	{"errors": [], "safety": {"body_peek": true, "store_used": false, "imap_readonly": true, "flags_modified": false}, "imported": [], "mailboxes": ["INBOX", "INBOX.Sent"], "duplicates": [{"uid": "1", "mailbox": "INBOX", "occurrence_id": 1}]}
521	1	3	success	2026-06-16 08:25:25.376997+01	2026-06-16 08:25:25.433276+01	1	0	0	1	0	\N	{"errors": [], "safety": {"body_peek": true, "store_used": false, "imap_readonly": true, "flags_modified": false}, "imported": [], "mailboxes": ["INBOX", "INBOX.Sent"], "duplicates": [{"uid": "1", "mailbox": "INBOX", "occurrence_id": 1}]}
522	1	3	success	2026-06-16 08:30:35.538018+01	2026-06-16 08:30:35.641084+01	1	0	0	1	0	\N	{"errors": [], "safety": {"body_peek": true, "store_used": false, "imap_readonly": true, "flags_modified": false}, "imported": [], "mailboxes": ["INBOX", "INBOX.Sent"], "duplicates": [{"uid": "1", "mailbox": "INBOX", "occurrence_id": 1}]}
523	1	3	success	2026-06-16 08:35:45.743393+01	2026-06-16 08:35:45.808688+01	1	0	0	1	0	\N	{"errors": [], "safety": {"body_peek": true, "store_used": false, "imap_readonly": true, "flags_modified": false}, "imported": [], "mailboxes": ["INBOX", "INBOX.Sent"], "duplicates": [{"uid": "1", "mailbox": "INBOX", "occurrence_id": 1}]}
524	1	3	success	2026-06-16 08:40:55.931491+01	2026-06-16 08:40:56.033701+01	1	0	0	1	0	\N	{"errors": [], "safety": {"body_peek": true, "store_used": false, "imap_readonly": true, "flags_modified": false}, "imported": [], "mailboxes": ["INBOX", "INBOX.Sent"], "duplicates": [{"uid": "1", "mailbox": "INBOX", "occurrence_id": 1}]}
525	1	3	success	2026-06-16 08:46:06.143837+01	2026-06-16 08:46:06.205031+01	1	0	0	1	0	\N	{"errors": [], "safety": {"body_peek": true, "store_used": false, "imap_readonly": true, "flags_modified": false}, "imported": [], "mailboxes": ["INBOX", "INBOX.Sent"], "duplicates": [{"uid": "1", "mailbox": "INBOX", "occurrence_id": 1}]}
526	1	3	success	2026-06-16 08:51:16.321875+01	2026-06-16 08:51:16.410147+01	1	0	0	1	0	\N	{"errors": [], "safety": {"body_peek": true, "store_used": false, "imap_readonly": true, "flags_modified": false}, "imported": [], "mailboxes": ["INBOX", "INBOX.Sent"], "duplicates": [{"uid": "1", "mailbox": "INBOX", "occurrence_id": 1}]}
527	1	3	success	2026-06-16 08:56:26.522054+01	2026-06-16 08:56:26.575486+01	1	0	0	1	0	\N	{"errors": [], "safety": {"body_peek": true, "store_used": false, "imap_readonly": true, "flags_modified": false}, "imported": [], "mailboxes": ["INBOX", "INBOX.Sent"], "duplicates": [{"uid": "1", "mailbox": "INBOX", "occurrence_id": 1}]}
528	1	3	success	2026-06-16 09:01:36.668032+01	2026-06-16 09:01:36.745947+01	1	0	0	1	0	\N	{"errors": [], "safety": {"body_peek": true, "store_used": false, "imap_readonly": true, "flags_modified": false}, "imported": [], "mailboxes": ["INBOX", "INBOX.Sent"], "duplicates": [{"uid": "1", "mailbox": "INBOX", "occurrence_id": 1}]}
529	1	3	success	2026-06-16 09:06:46.838807+01	2026-06-16 09:06:46.891138+01	1	0	0	1	0	\N	{"errors": [], "safety": {"body_peek": true, "store_used": false, "imap_readonly": true, "flags_modified": false}, "imported": [], "mailboxes": ["INBOX", "INBOX.Sent"], "duplicates": [{"uid": "1", "mailbox": "INBOX", "occurrence_id": 1}]}
530	1	3	success	2026-06-16 09:11:56.971366+01	2026-06-16 09:11:57.077947+01	1	0	0	1	0	\N	{"errors": [], "safety": {"body_peek": true, "store_used": false, "imap_readonly": true, "flags_modified": false}, "imported": [], "mailboxes": ["INBOX", "INBOX.Sent"], "duplicates": [{"uid": "1", "mailbox": "INBOX", "occurrence_id": 1}]}
531	1	3	success	2026-06-16 09:17:07.198331+01	2026-06-16 09:17:07.278522+01	1	0	0	1	0	\N	{"errors": [], "safety": {"body_peek": true, "store_used": false, "imap_readonly": true, "flags_modified": false}, "imported": [], "mailboxes": ["INBOX", "INBOX.Sent"], "duplicates": [{"uid": "1", "mailbox": "INBOX", "occurrence_id": 1}]}
532	1	3	success	2026-06-16 09:22:17.385113+01	2026-06-16 09:22:17.461959+01	1	0	0	1	0	\N	{"errors": [], "safety": {"body_peek": true, "store_used": false, "imap_readonly": true, "flags_modified": false}, "imported": [], "mailboxes": ["INBOX", "INBOX.Sent"], "duplicates": [{"uid": "1", "mailbox": "INBOX", "occurrence_id": 1}]}
533	1	3	success	2026-06-16 09:27:27.564909+01	2026-06-16 09:27:27.65845+01	1	0	0	1	0	\N	{"errors": [], "safety": {"body_peek": true, "store_used": false, "imap_readonly": true, "flags_modified": false}, "imported": [], "mailboxes": ["INBOX", "INBOX.Sent"], "duplicates": [{"uid": "1", "mailbox": "INBOX", "occurrence_id": 1}]}
534	1	3	success	2026-06-16 09:32:37.762184+01	2026-06-16 09:32:37.856151+01	1	0	0	1	0	\N	{"errors": [], "safety": {"body_peek": true, "store_used": false, "imap_readonly": true, "flags_modified": false}, "imported": [], "mailboxes": ["INBOX", "INBOX.Sent"], "duplicates": [{"uid": "1", "mailbox": "INBOX", "occurrence_id": 1}]}
535	1	3	success	2026-06-16 09:37:47.960791+01	2026-06-16 09:37:48.04579+01	1	0	0	1	0	\N	{"errors": [], "safety": {"body_peek": true, "store_used": false, "imap_readonly": true, "flags_modified": false}, "imported": [], "mailboxes": ["INBOX", "INBOX.Sent"], "duplicates": [{"uid": "1", "mailbox": "INBOX", "occurrence_id": 1}]}
536	1	3	success	2026-06-16 09:42:58.140263+01	2026-06-16 09:42:58.238213+01	1	0	0	1	0	\N	{"errors": [], "safety": {"body_peek": true, "store_used": false, "imap_readonly": true, "flags_modified": false}, "imported": [], "mailboxes": ["INBOX", "INBOX.Sent"], "duplicates": [{"uid": "1", "mailbox": "INBOX", "occurrence_id": 1}]}
537	1	3	success	2026-06-16 09:48:08.343081+01	2026-06-16 09:48:08.398245+01	1	0	0	1	0	\N	{"errors": [], "safety": {"body_peek": true, "store_used": false, "imap_readonly": true, "flags_modified": false}, "imported": [], "mailboxes": ["INBOX", "INBOX.Sent"], "duplicates": [{"uid": "1", "mailbox": "INBOX", "occurrence_id": 1}]}
538	1	3	success	2026-06-16 09:53:18.494984+01	2026-06-16 09:53:18.571046+01	1	0	0	1	0	\N	{"errors": [], "safety": {"body_peek": true, "store_used": false, "imap_readonly": true, "flags_modified": false}, "imported": [], "mailboxes": ["INBOX", "INBOX.Sent"], "duplicates": [{"uid": "1", "mailbox": "INBOX", "occurrence_id": 1}]}
539	1	3	success	2026-06-16 09:58:28.664561+01	2026-06-16 09:58:28.726832+01	1	0	0	1	0	\N	{"errors": [], "safety": {"body_peek": true, "store_used": false, "imap_readonly": true, "flags_modified": false}, "imported": [], "mailboxes": ["INBOX", "INBOX.Sent"], "duplicates": [{"uid": "1", "mailbox": "INBOX", "occurrence_id": 1}]}
540	1	3	success	2026-06-16 10:03:38.834051+01	2026-06-16 10:03:38.888929+01	1	0	0	1	0	\N	{"errors": [], "safety": {"body_peek": true, "store_used": false, "imap_readonly": true, "flags_modified": false}, "imported": [], "mailboxes": ["INBOX", "INBOX.Sent"], "duplicates": [{"uid": "1", "mailbox": "INBOX", "occurrence_id": 1}]}
541	1	3	success	2026-06-16 10:08:49.006151+01	2026-06-16 10:08:49.108788+01	1	0	0	1	0	\N	{"errors": [], "safety": {"body_peek": true, "store_used": false, "imap_readonly": true, "flags_modified": false}, "imported": [], "mailboxes": ["INBOX", "INBOX.Sent"], "duplicates": [{"uid": "1", "mailbox": "INBOX", "occurrence_id": 1}]}
542	1	3	success	2026-06-16 10:13:59.228677+01	2026-06-16 10:13:59.331783+01	1	0	0	1	0	\N	{"errors": [], "safety": {"body_peek": true, "store_used": false, "imap_readonly": true, "flags_modified": false}, "imported": [], "mailboxes": ["INBOX", "INBOX.Sent"], "duplicates": [{"uid": "1", "mailbox": "INBOX", "occurrence_id": 1}]}
543	1	3	success	2026-06-16 10:19:09.442037+01	2026-06-16 10:19:09.49451+01	1	0	0	1	0	\N	{"errors": [], "safety": {"body_peek": true, "store_used": false, "imap_readonly": true, "flags_modified": false}, "imported": [], "mailboxes": ["INBOX", "INBOX.Sent"], "duplicates": [{"uid": "1", "mailbox": "INBOX", "occurrence_id": 1}]}
544	1	3	success	2026-06-16 10:24:19.614486+01	2026-06-16 10:24:19.700555+01	1	0	0	1	0	\N	{"errors": [], "safety": {"body_peek": true, "store_used": false, "imap_readonly": true, "flags_modified": false}, "imported": [], "mailboxes": ["INBOX", "INBOX.Sent"], "duplicates": [{"uid": "1", "mailbox": "INBOX", "occurrence_id": 1}]}
545	1	3	success	2026-06-16 10:29:19.812837+01	2026-06-16 10:29:19.887713+01	1	0	0	1	0	\N	{"errors": [], "safety": {"body_peek": true, "store_used": false, "imap_readonly": true, "flags_modified": false}, "imported": [], "mailboxes": ["INBOX", "INBOX.Sent"], "duplicates": [{"uid": "1", "mailbox": "INBOX", "occurrence_id": 1}]}
546	1	3	success	2026-06-16 10:34:29.99708+01	2026-06-16 10:34:30.090431+01	1	0	0	1	0	\N	{"errors": [], "safety": {"body_peek": true, "store_used": false, "imap_readonly": true, "flags_modified": false}, "imported": [], "mailboxes": ["INBOX", "INBOX.Sent"], "duplicates": [{"uid": "1", "mailbox": "INBOX", "occurrence_id": 1}]}
547	1	3	success	2026-06-16 10:39:40.19871+01	2026-06-16 10:39:40.27865+01	1	0	0	1	0	\N	{"errors": [], "safety": {"body_peek": true, "store_used": false, "imap_readonly": true, "flags_modified": false}, "imported": [], "mailboxes": ["INBOX", "INBOX.Sent"], "duplicates": [{"uid": "1", "mailbox": "INBOX", "occurrence_id": 1}]}
548	1	3	success	2026-06-16 10:44:50.359358+01	2026-06-16 10:44:50.411404+01	1	0	0	1	0	\N	{"errors": [], "safety": {"body_peek": true, "store_used": false, "imap_readonly": true, "flags_modified": false}, "imported": [], "mailboxes": ["INBOX", "INBOX.Sent"], "duplicates": [{"uid": "1", "mailbox": "INBOX", "occurrence_id": 1}]}
549	1	3	success	2026-06-16 10:50:00.506874+01	2026-06-16 10:50:00.560142+01	1	0	0	1	0	\N	{"errors": [], "safety": {"body_peek": true, "store_used": false, "imap_readonly": true, "flags_modified": false}, "imported": [], "mailboxes": ["INBOX", "INBOX.Sent"], "duplicates": [{"uid": "1", "mailbox": "INBOX", "occurrence_id": 1}]}
550	1	3	success	2026-06-16 10:55:10.651638+01	2026-06-16 10:55:10.707458+01	1	0	0	1	0	\N	{"errors": [], "safety": {"body_peek": true, "store_used": false, "imap_readonly": true, "flags_modified": false}, "imported": [], "mailboxes": ["INBOX", "INBOX.Sent"], "duplicates": [{"uid": "1", "mailbox": "INBOX", "occurrence_id": 1}]}
551	1	3	success	2026-06-16 11:00:20.820955+01	2026-06-16 11:00:20.924158+01	1	0	0	1	0	\N	{"errors": [], "safety": {"body_peek": true, "store_used": false, "imap_readonly": true, "flags_modified": false}, "imported": [], "mailboxes": ["INBOX", "INBOX.Sent"], "duplicates": [{"uid": "1", "mailbox": "INBOX", "occurrence_id": 1}]}
552	1	3	success	2026-06-16 11:05:31.037671+01	2026-06-16 11:05:31.153115+01	1	0	0	1	0	\N	{"errors": [], "safety": {"body_peek": true, "store_used": false, "imap_readonly": true, "flags_modified": false}, "imported": [], "mailboxes": ["INBOX", "INBOX.Sent"], "duplicates": [{"uid": "1", "mailbox": "INBOX", "occurrence_id": 1}]}
553	1	3	success	2026-06-16 11:10:41.264111+01	2026-06-16 11:10:41.363712+01	1	0	0	1	0	\N	{"errors": [], "safety": {"body_peek": true, "store_used": false, "imap_readonly": true, "flags_modified": false}, "imported": [], "mailboxes": ["INBOX", "INBOX.Sent"], "duplicates": [{"uid": "1", "mailbox": "INBOX", "occurrence_id": 1}]}
554	1	3	success	2026-06-16 11:15:51.447904+01	2026-06-16 11:15:51.506942+01	1	0	0	1	0	\N	{"errors": [], "safety": {"body_peek": true, "store_used": false, "imap_readonly": true, "flags_modified": false}, "imported": [], "mailboxes": ["INBOX", "INBOX.Sent"], "duplicates": [{"uid": "1", "mailbox": "INBOX", "occurrence_id": 1}]}
555	1	3	success	2026-06-16 11:21:01.585183+01	2026-06-16 11:21:01.683731+01	1	0	0	1	0	\N	{"errors": [], "safety": {"body_peek": true, "store_used": false, "imap_readonly": true, "flags_modified": false}, "imported": [], "mailboxes": ["INBOX", "INBOX.Sent"], "duplicates": [{"uid": "1", "mailbox": "INBOX", "occurrence_id": 1}]}
556	1	3	success	2026-06-16 11:26:11.769154+01	2026-06-16 11:26:11.85216+01	1	0	0	1	0	\N	{"errors": [], "safety": {"body_peek": true, "store_used": false, "imap_readonly": true, "flags_modified": false}, "imported": [], "mailboxes": ["INBOX", "INBOX.Sent"], "duplicates": [{"uid": "1", "mailbox": "INBOX", "occurrence_id": 1}]}
557	1	3	success	2026-06-16 11:31:21.954038+01	2026-06-16 11:31:22.045835+01	1	0	0	1	0	\N	{"errors": [], "safety": {"body_peek": true, "store_used": false, "imap_readonly": true, "flags_modified": false}, "imported": [], "mailboxes": ["INBOX", "INBOX.Sent"], "duplicates": [{"uid": "1", "mailbox": "INBOX", "occurrence_id": 1}]}
558	1	3	success	2026-06-16 11:36:32.144616+01	2026-06-16 11:36:32.207604+01	1	0	0	1	0	\N	{"errors": [], "safety": {"body_peek": true, "store_used": false, "imap_readonly": true, "flags_modified": false}, "imported": [], "mailboxes": ["INBOX", "INBOX.Sent"], "duplicates": [{"uid": "1", "mailbox": "INBOX", "occurrence_id": 1}]}
559	1	3	success	2026-06-16 11:41:42.303094+01	2026-06-16 11:41:42.386254+01	1	0	0	1	0	\N	{"errors": [], "safety": {"body_peek": true, "store_used": false, "imap_readonly": true, "flags_modified": false}, "imported": [], "mailboxes": ["INBOX", "INBOX.Sent"], "duplicates": [{"uid": "1", "mailbox": "INBOX", "occurrence_id": 1}]}
560	1	3	success	2026-06-16 11:46:52.504753+01	2026-06-16 11:46:52.55615+01	1	0	0	1	0	\N	{"errors": [], "safety": {"body_peek": true, "store_used": false, "imap_readonly": true, "flags_modified": false}, "imported": [], "mailboxes": ["INBOX", "INBOX.Sent"], "duplicates": [{"uid": "1", "mailbox": "INBOX", "occurrence_id": 1}]}
561	1	3	success	2026-06-16 11:52:02.663718+01	2026-06-16 11:52:02.720711+01	1	0	0	1	0	\N	{"errors": [], "safety": {"body_peek": true, "store_used": false, "imap_readonly": true, "flags_modified": false}, "imported": [], "mailboxes": ["INBOX", "INBOX.Sent"], "duplicates": [{"uid": "1", "mailbox": "INBOX", "occurrence_id": 1}]}
562	1	3	success	2026-06-16 11:57:12.81408+01	2026-06-16 11:57:12.910192+01	1	0	0	1	0	\N	{"errors": [], "safety": {"body_peek": true, "store_used": false, "imap_readonly": true, "flags_modified": false}, "imported": [], "mailboxes": ["INBOX", "INBOX.Sent"], "duplicates": [{"uid": "1", "mailbox": "INBOX", "occurrence_id": 1}]}
563	1	3	success	2026-06-16 12:02:23.027377+01	2026-06-16 12:02:23.093919+01	1	0	0	1	0	\N	{"errors": [], "safety": {"body_peek": true, "store_used": false, "imap_readonly": true, "flags_modified": false}, "imported": [], "mailboxes": ["INBOX", "INBOX.Sent"], "duplicates": [{"uid": "1", "mailbox": "INBOX", "occurrence_id": 1}]}
564	1	3	success	2026-06-16 12:07:33.199018+01	2026-06-16 12:07:33.296018+01	1	0	0	1	0	\N	{"errors": [], "safety": {"body_peek": true, "store_used": false, "imap_readonly": true, "flags_modified": false}, "imported": [], "mailboxes": ["INBOX", "INBOX.Sent"], "duplicates": [{"uid": "1", "mailbox": "INBOX", "occurrence_id": 1}]}
565	1	3	success	2026-06-16 12:12:43.401288+01	2026-06-16 12:12:43.506647+01	1	0	0	1	0	\N	{"errors": [], "safety": {"body_peek": true, "store_used": false, "imap_readonly": true, "flags_modified": false}, "imported": [], "mailboxes": ["INBOX", "INBOX.Sent"], "duplicates": [{"uid": "1", "mailbox": "INBOX", "occurrence_id": 1}]}
566	1	3	success	2026-06-16 12:17:53.617804+01	2026-06-16 12:17:53.678306+01	1	0	0	1	0	\N	{"errors": [], "safety": {"body_peek": true, "store_used": false, "imap_readonly": true, "flags_modified": false}, "imported": [], "mailboxes": ["INBOX", "INBOX.Sent"], "duplicates": [{"uid": "1", "mailbox": "INBOX", "occurrence_id": 1}]}
567	1	3	success	2026-06-16 12:23:03.775645+01	2026-06-16 12:23:03.826706+01	1	0	0	1	0	\N	{"errors": [], "safety": {"body_peek": true, "store_used": false, "imap_readonly": true, "flags_modified": false}, "imported": [], "mailboxes": ["INBOX", "INBOX.Sent"], "duplicates": [{"uid": "1", "mailbox": "INBOX", "occurrence_id": 1}]}
568	1	3	success	2026-06-16 12:28:13.924758+01	2026-06-16 12:28:14.003309+01	1	0	0	1	0	\N	{"errors": [], "safety": {"body_peek": true, "store_used": false, "imap_readonly": true, "flags_modified": false}, "imported": [], "mailboxes": ["INBOX", "INBOX.Sent"], "duplicates": [{"uid": "1", "mailbox": "INBOX", "occurrence_id": 1}]}
569	1	3	success	2026-06-16 12:33:24.122419+01	2026-06-16 12:33:24.217641+01	1	0	0	1	0	\N	{"errors": [], "safety": {"body_peek": true, "store_used": false, "imap_readonly": true, "flags_modified": false}, "imported": [], "mailboxes": ["INBOX", "INBOX.Sent"], "duplicates": [{"uid": "1", "mailbox": "INBOX", "occurrence_id": 1}]}
570	1	3	success	2026-06-16 12:38:34.322733+01	2026-06-16 12:38:34.420712+01	1	0	0	1	0	\N	{"errors": [], "safety": {"body_peek": true, "store_used": false, "imap_readonly": true, "flags_modified": false}, "imported": [], "mailboxes": ["INBOX", "INBOX.Sent"], "duplicates": [{"uid": "1", "mailbox": "INBOX", "occurrence_id": 1}]}
571	1	3	success	2026-06-16 12:43:44.533669+01	2026-06-16 12:43:44.6265+01	1	0	0	1	0	\N	{"errors": [], "safety": {"body_peek": true, "store_used": false, "imap_readonly": true, "flags_modified": false}, "imported": [], "mailboxes": ["INBOX", "INBOX.Sent"], "duplicates": [{"uid": "1", "mailbox": "INBOX", "occurrence_id": 1}]}
572	1	3	success	2026-06-16 12:48:54.750228+01	2026-06-16 12:48:54.849635+01	1	0	0	1	0	\N	{"errors": [], "safety": {"body_peek": true, "store_used": false, "imap_readonly": true, "flags_modified": false}, "imported": [], "mailboxes": ["INBOX", "INBOX.Sent"], "duplicates": [{"uid": "1", "mailbox": "INBOX", "occurrence_id": 1}]}
573	1	3	success	2026-06-16 12:54:04.968315+01	2026-06-16 12:54:05.074594+01	1	0	0	1	0	\N	{"errors": [], "safety": {"body_peek": true, "store_used": false, "imap_readonly": true, "flags_modified": false}, "imported": [], "mailboxes": ["INBOX", "INBOX.Sent"], "duplicates": [{"uid": "1", "mailbox": "INBOX", "occurrence_id": 1}]}
574	1	3	success	2026-06-16 12:59:15.180515+01	2026-06-16 12:59:15.26181+01	1	0	0	1	0	\N	{"errors": [], "safety": {"body_peek": true, "store_used": false, "imap_readonly": true, "flags_modified": false}, "imported": [], "mailboxes": ["INBOX", "INBOX.Sent"], "duplicates": [{"uid": "1", "mailbox": "INBOX", "occurrence_id": 1}]}
575	1	3	success	2026-06-16 13:04:25.356435+01	2026-06-16 13:04:25.458908+01	1	0	0	1	0	\N	{"errors": [], "safety": {"body_peek": true, "store_used": false, "imap_readonly": true, "flags_modified": false}, "imported": [], "mailboxes": ["INBOX", "INBOX.Sent"], "duplicates": [{"uid": "1", "mailbox": "INBOX", "occurrence_id": 1}]}
576	1	3	success	2026-06-16 13:09:35.568661+01	2026-06-16 13:09:35.622425+01	1	0	0	1	0	\N	{"errors": [], "safety": {"body_peek": true, "store_used": false, "imap_readonly": true, "flags_modified": false}, "imported": [], "mailboxes": ["INBOX", "INBOX.Sent"], "duplicates": [{"uid": "1", "mailbox": "INBOX", "occurrence_id": 1}]}
577	1	3	success	2026-06-16 13:14:45.73343+01	2026-06-16 13:14:45.787559+01	1	0	0	1	0	\N	{"errors": [], "safety": {"body_peek": true, "store_used": false, "imap_readonly": true, "flags_modified": false}, "imported": [], "mailboxes": ["INBOX", "INBOX.Sent"], "duplicates": [{"uid": "1", "mailbox": "INBOX", "occurrence_id": 1}]}
578	1	3	success	2026-06-16 13:19:55.892703+01	2026-06-16 13:19:55.991946+01	1	0	0	1	0	\N	{"errors": [], "safety": {"body_peek": true, "store_used": false, "imap_readonly": true, "flags_modified": false}, "imported": [], "mailboxes": ["INBOX", "INBOX.Sent"], "duplicates": [{"uid": "1", "mailbox": "INBOX", "occurrence_id": 1}]}
579	1	3	success	2026-06-16 13:25:06.100549+01	2026-06-16 13:25:06.158021+01	1	0	0	1	0	\N	{"errors": [], "safety": {"body_peek": true, "store_used": false, "imap_readonly": true, "flags_modified": false}, "imported": [], "mailboxes": ["INBOX", "INBOX.Sent"], "duplicates": [{"uid": "1", "mailbox": "INBOX", "occurrence_id": 1}]}
580	1	3	success	2026-06-16 13:30:16.27736+01	2026-06-16 13:30:16.335968+01	1	0	0	1	0	\N	{"errors": [], "safety": {"body_peek": true, "store_used": false, "imap_readonly": true, "flags_modified": false}, "imported": [], "mailboxes": ["INBOX", "INBOX.Sent"], "duplicates": [{"uid": "1", "mailbox": "INBOX", "occurrence_id": 1}]}
581	1	3	success	2026-06-16 13:35:26.447252+01	2026-06-16 13:35:26.538674+01	1	0	0	1	0	\N	{"errors": [], "safety": {"body_peek": true, "store_used": false, "imap_readonly": true, "flags_modified": false}, "imported": [], "mailboxes": ["INBOX", "INBOX.Sent"], "duplicates": [{"uid": "1", "mailbox": "INBOX", "occurrence_id": 1}]}
582	1	3	success	2026-06-16 13:40:36.637253+01	2026-06-16 13:40:36.70312+01	1	0	0	1	0	\N	{"errors": [], "safety": {"body_peek": true, "store_used": false, "imap_readonly": true, "flags_modified": false}, "imported": [], "mailboxes": ["INBOX", "INBOX.Sent"], "duplicates": [{"uid": "1", "mailbox": "INBOX", "occurrence_id": 1}]}
583	1	3	success	2026-06-16 13:45:46.787891+01	2026-06-16 13:45:46.884682+01	1	0	0	1	0	\N	{"errors": [], "safety": {"body_peek": true, "store_used": false, "imap_readonly": true, "flags_modified": false}, "imported": [], "mailboxes": ["INBOX", "INBOX.Sent"], "duplicates": [{"uid": "1", "mailbox": "INBOX", "occurrence_id": 1}]}
584	1	3	success	2026-06-16 13:50:56.996474+01	2026-06-16 13:50:57.068389+01	1	0	0	1	0	\N	{"errors": [], "safety": {"body_peek": true, "store_used": false, "imap_readonly": true, "flags_modified": false}, "imported": [], "mailboxes": ["INBOX", "INBOX.Sent"], "duplicates": [{"uid": "1", "mailbox": "INBOX", "occurrence_id": 1}]}
585	1	3	success	2026-06-16 13:56:07.165878+01	2026-06-16 13:56:07.221575+01	1	0	0	1	0	\N	{"errors": [], "safety": {"body_peek": true, "store_used": false, "imap_readonly": true, "flags_modified": false}, "imported": [], "mailboxes": ["INBOX", "INBOX.Sent"], "duplicates": [{"uid": "1", "mailbox": "INBOX", "occurrence_id": 1}]}
586	1	3	success	2026-06-16 14:01:17.309064+01	2026-06-16 14:01:17.361104+01	1	0	0	1	0	\N	{"errors": [], "safety": {"body_peek": true, "store_used": false, "imap_readonly": true, "flags_modified": false}, "imported": [], "mailboxes": ["INBOX", "INBOX.Sent"], "duplicates": [{"uid": "1", "mailbox": "INBOX", "occurrence_id": 1}]}
587	1	3	success	2026-06-16 14:06:27.45816+01	2026-06-16 14:06:27.561051+01	1	0	0	1	0	\N	{"errors": [], "safety": {"body_peek": true, "store_used": false, "imap_readonly": true, "flags_modified": false}, "imported": [], "mailboxes": ["INBOX", "INBOX.Sent"], "duplicates": [{"uid": "1", "mailbox": "INBOX", "occurrence_id": 1}]}
588	1	3	success	2026-06-16 14:11:37.649943+01	2026-06-16 14:11:37.734514+01	1	0	0	1	0	\N	{"errors": [], "safety": {"body_peek": true, "store_used": false, "imap_readonly": true, "flags_modified": false}, "imported": [], "mailboxes": ["INBOX", "INBOX.Sent"], "duplicates": [{"uid": "1", "mailbox": "INBOX", "occurrence_id": 1}]}
589	1	3	success	2026-06-16 14:16:47.8366+01	2026-06-16 14:16:47.886738+01	1	0	0	1	0	\N	{"errors": [], "safety": {"body_peek": true, "store_used": false, "imap_readonly": true, "flags_modified": false}, "imported": [], "mailboxes": ["INBOX", "INBOX.Sent"], "duplicates": [{"uid": "1", "mailbox": "INBOX", "occurrence_id": 1}]}
590	1	3	success	2026-06-16 14:21:57.984378+01	2026-06-16 14:21:58.073297+01	1	0	0	1	0	\N	{"errors": [], "safety": {"body_peek": true, "store_used": false, "imap_readonly": true, "flags_modified": false}, "imported": [], "mailboxes": ["INBOX", "INBOX.Sent"], "duplicates": [{"uid": "1", "mailbox": "INBOX", "occurrence_id": 1}]}
591	1	3	success	2026-06-16 14:27:08.171312+01	2026-06-16 14:27:08.224986+01	1	0	0	1	0	\N	{"errors": [], "safety": {"body_peek": true, "store_used": false, "imap_readonly": true, "flags_modified": false}, "imported": [], "mailboxes": ["INBOX", "INBOX.Sent"], "duplicates": [{"uid": "1", "mailbox": "INBOX", "occurrence_id": 1}]}
592	1	3	success	2026-06-16 14:32:18.317651+01	2026-06-16 14:32:18.368755+01	1	0	0	1	0	\N	{"errors": [], "safety": {"body_peek": true, "store_used": false, "imap_readonly": true, "flags_modified": false}, "imported": [], "mailboxes": ["INBOX", "INBOX.Sent"], "duplicates": [{"uid": "1", "mailbox": "INBOX", "occurrence_id": 1}]}
593	1	3	success	2026-06-16 14:37:28.485368+01	2026-06-16 14:37:28.540138+01	1	0	0	1	0	\N	{"errors": [], "safety": {"body_peek": true, "store_used": false, "imap_readonly": true, "flags_modified": false}, "imported": [], "mailboxes": ["INBOX", "INBOX.Sent"], "duplicates": [{"uid": "1", "mailbox": "INBOX", "occurrence_id": 1}]}
594	1	3	success	2026-06-16 14:42:38.648008+01	2026-06-16 14:42:38.700531+01	1	0	0	1	0	\N	{"errors": [], "safety": {"body_peek": true, "store_used": false, "imap_readonly": true, "flags_modified": false}, "imported": [], "mailboxes": ["INBOX", "INBOX.Sent"], "duplicates": [{"uid": "1", "mailbox": "INBOX", "occurrence_id": 1}]}
595	1	3	success	2026-06-16 14:47:48.808461+01	2026-06-16 14:47:48.907034+01	1	0	0	1	0	\N	{"errors": [], "safety": {"body_peek": true, "store_used": false, "imap_readonly": true, "flags_modified": false}, "imported": [], "mailboxes": ["INBOX", "INBOX.Sent"], "duplicates": [{"uid": "1", "mailbox": "INBOX", "occurrence_id": 1}]}
596	1	3	success	2026-06-16 14:52:59.023122+01	2026-06-16 14:52:59.110853+01	1	0	0	1	0	\N	{"errors": [], "safety": {"body_peek": true, "store_used": false, "imap_readonly": true, "flags_modified": false}, "imported": [], "mailboxes": ["INBOX", "INBOX.Sent"], "duplicates": [{"uid": "1", "mailbox": "INBOX", "occurrence_id": 1}]}
597	1	3	success	2026-06-16 14:58:09.215849+01	2026-06-16 14:58:09.303355+01	1	0	0	1	0	\N	{"errors": [], "safety": {"body_peek": true, "store_used": false, "imap_readonly": true, "flags_modified": false}, "imported": [], "mailboxes": ["INBOX", "INBOX.Sent"], "duplicates": [{"uid": "1", "mailbox": "INBOX", "occurrence_id": 1}]}
598	1	3	success	2026-06-16 15:03:19.43637+01	2026-06-16 15:03:19.527695+01	1	0	0	1	0	\N	{"errors": [], "safety": {"body_peek": true, "store_used": false, "imap_readonly": true, "flags_modified": false}, "imported": [], "mailboxes": ["INBOX", "INBOX.Sent"], "duplicates": [{"uid": "1", "mailbox": "INBOX", "occurrence_id": 1}]}
599	1	3	success	2026-06-16 15:08:29.636183+01	2026-06-16 15:08:29.740516+01	1	0	0	1	0	\N	{"errors": [], "safety": {"body_peek": true, "store_used": false, "imap_readonly": true, "flags_modified": false}, "imported": [], "mailboxes": ["INBOX", "INBOX.Sent"], "duplicates": [{"uid": "1", "mailbox": "INBOX", "occurrence_id": 1}]}
600	1	3	success	2026-06-16 15:13:39.859201+01	2026-06-16 15:13:39.961257+01	1	0	0	1	0	\N	{"errors": [], "safety": {"body_peek": true, "store_used": false, "imap_readonly": true, "flags_modified": false}, "imported": [], "mailboxes": ["INBOX", "INBOX.Sent"], "duplicates": [{"uid": "1", "mailbox": "INBOX", "occurrence_id": 1}]}
601	1	3	success	2026-06-16 15:18:50.061615+01	2026-06-16 15:18:50.168916+01	1	0	0	1	0	\N	{"errors": [], "safety": {"body_peek": true, "store_used": false, "imap_readonly": true, "flags_modified": false}, "imported": [], "mailboxes": ["INBOX", "INBOX.Sent"], "duplicates": [{"uid": "1", "mailbox": "INBOX", "occurrence_id": 1}]}
602	1	3	success	2026-06-16 15:24:00.284763+01	2026-06-16 15:24:00.391963+01	1	0	0	1	0	\N	{"errors": [], "safety": {"body_peek": true, "store_used": false, "imap_readonly": true, "flags_modified": false}, "imported": [], "mailboxes": ["INBOX", "INBOX.Sent"], "duplicates": [{"uid": "1", "mailbox": "INBOX", "occurrence_id": 1}]}
603	1	3	success	2026-06-16 15:29:10.511031+01	2026-06-16 15:29:10.570679+01	1	0	0	1	0	\N	{"errors": [], "safety": {"body_peek": true, "store_used": false, "imap_readonly": true, "flags_modified": false}, "imported": [], "mailboxes": ["INBOX", "INBOX.Sent"], "duplicates": [{"uid": "1", "mailbox": "INBOX", "occurrence_id": 1}]}
604	1	3	success	2026-06-16 15:34:20.688534+01	2026-06-16 15:34:20.750246+01	1	0	0	1	0	\N	{"errors": [], "safety": {"body_peek": true, "store_used": false, "imap_readonly": true, "flags_modified": false}, "imported": [], "mailboxes": ["INBOX", "INBOX.Sent"], "duplicates": [{"uid": "1", "mailbox": "INBOX", "occurrence_id": 1}]}
605	1	3	success	2026-06-16 15:39:30.860163+01	2026-06-16 15:39:30.97876+01	1	0	0	1	0	\N	{"errors": [], "safety": {"body_peek": true, "store_used": false, "imap_readonly": true, "flags_modified": false}, "imported": [], "mailboxes": ["INBOX", "INBOX.Sent"], "duplicates": [{"uid": "1", "mailbox": "INBOX", "occurrence_id": 1}]}
606	1	3	success	2026-06-16 15:44:41.086764+01	2026-06-16 15:44:41.168253+01	1	0	0	1	0	\N	{"errors": [], "safety": {"body_peek": true, "store_used": false, "imap_readonly": true, "flags_modified": false}, "imported": [], "mailboxes": ["INBOX", "INBOX.Sent"], "duplicates": [{"uid": "1", "mailbox": "INBOX", "occurrence_id": 1}]}
607	1	3	success	2026-06-16 15:49:51.28571+01	2026-06-16 15:49:51.368842+01	1	0	0	1	0	\N	{"errors": [], "safety": {"body_peek": true, "store_used": false, "imap_readonly": true, "flags_modified": false}, "imported": [], "mailboxes": ["INBOX", "INBOX.Sent"], "duplicates": [{"uid": "1", "mailbox": "INBOX", "occurrence_id": 1}]}
608	1	3	success	2026-06-16 15:55:01.496094+01	2026-06-16 15:55:01.551703+01	1	0	0	1	0	\N	{"errors": [], "safety": {"body_peek": true, "store_used": false, "imap_readonly": true, "flags_modified": false}, "imported": [], "mailboxes": ["INBOX", "INBOX.Sent"], "duplicates": [{"uid": "1", "mailbox": "INBOX", "occurrence_id": 1}]}
609	1	3	success	2026-06-16 16:00:11.648802+01	2026-06-16 16:00:11.743473+01	1	0	0	1	0	\N	{"errors": [], "safety": {"body_peek": true, "store_used": false, "imap_readonly": true, "flags_modified": false}, "imported": [], "mailboxes": ["INBOX", "INBOX.Sent"], "duplicates": [{"uid": "1", "mailbox": "INBOX", "occurrence_id": 1}]}
610	1	3	success	2026-06-16 16:05:21.839868+01	2026-06-16 16:05:21.922268+01	1	0	0	1	0	\N	{"errors": [], "safety": {"body_peek": true, "store_used": false, "imap_readonly": true, "flags_modified": false}, "imported": [], "mailboxes": ["INBOX", "INBOX.Sent"], "duplicates": [{"uid": "1", "mailbox": "INBOX", "occurrence_id": 1}]}
611	1	3	success	2026-06-16 16:10:32.034502+01	2026-06-16 16:10:32.125301+01	1	0	0	1	0	\N	{"errors": [], "safety": {"body_peek": true, "store_used": false, "imap_readonly": true, "flags_modified": false}, "imported": [], "mailboxes": ["INBOX", "INBOX.Sent"], "duplicates": [{"uid": "1", "mailbox": "INBOX", "occurrence_id": 1}]}
612	1	3	success	2026-06-16 16:15:42.22427+01	2026-06-16 16:15:42.317447+01	1	0	0	1	0	\N	{"errors": [], "safety": {"body_peek": true, "store_used": false, "imap_readonly": true, "flags_modified": false}, "imported": [], "mailboxes": ["INBOX", "INBOX.Sent"], "duplicates": [{"uid": "1", "mailbox": "INBOX", "occurrence_id": 1}]}
613	1	3	success	2026-06-16 16:20:52.435889+01	2026-06-16 16:20:52.550263+01	1	0	0	1	0	\N	{"errors": [], "safety": {"body_peek": true, "store_used": false, "imap_readonly": true, "flags_modified": false}, "imported": [], "mailboxes": ["INBOX", "INBOX.Sent"], "duplicates": [{"uid": "1", "mailbox": "INBOX", "occurrence_id": 1}]}
614	1	3	success	2026-06-16 16:26:02.648503+01	2026-06-16 16:26:02.70235+01	1	0	0	1	0	\N	{"errors": [], "safety": {"body_peek": true, "store_used": false, "imap_readonly": true, "flags_modified": false}, "imported": [], "mailboxes": ["INBOX", "INBOX.Sent"], "duplicates": [{"uid": "1", "mailbox": "INBOX", "occurrence_id": 1}]}
615	1	3	success	2026-06-16 16:31:12.807526+01	2026-06-16 16:31:12.857269+01	1	0	0	1	0	\N	{"errors": [], "safety": {"body_peek": true, "store_used": false, "imap_readonly": true, "flags_modified": false}, "imported": [], "mailboxes": ["INBOX", "INBOX.Sent"], "duplicates": [{"uid": "1", "mailbox": "INBOX", "occurrence_id": 1}]}
616	1	3	success	2026-06-16 16:36:22.955557+01	2026-06-16 16:36:23.022408+01	1	0	0	1	0	\N	{"errors": [], "safety": {"body_peek": true, "store_used": false, "imap_readonly": true, "flags_modified": false}, "imported": [], "mailboxes": ["INBOX", "INBOX.Sent"], "duplicates": [{"uid": "1", "mailbox": "INBOX", "occurrence_id": 1}]}
617	1	3	success	2026-06-16 16:41:33.12148+01	2026-06-16 16:41:33.227251+01	1	0	0	1	0	\N	{"errors": [], "safety": {"body_peek": true, "store_used": false, "imap_readonly": true, "flags_modified": false}, "imported": [], "mailboxes": ["INBOX", "INBOX.Sent"], "duplicates": [{"uid": "1", "mailbox": "INBOX", "occurrence_id": 1}]}
618	1	3	success	2026-06-16 16:46:43.31914+01	2026-06-16 16:46:43.420831+01	1	0	0	1	0	\N	{"errors": [], "safety": {"body_peek": true, "store_used": false, "imap_readonly": true, "flags_modified": false}, "imported": [], "mailboxes": ["INBOX", "INBOX.Sent"], "duplicates": [{"uid": "1", "mailbox": "INBOX", "occurrence_id": 1}]}
619	1	3	success	2026-06-16 16:51:53.524361+01	2026-06-16 16:51:53.588299+01	1	0	0	1	0	\N	{"errors": [], "safety": {"body_peek": true, "store_used": false, "imap_readonly": true, "flags_modified": false}, "imported": [], "mailboxes": ["INBOX", "INBOX.Sent"], "duplicates": [{"uid": "1", "mailbox": "INBOX", "occurrence_id": 1}]}
620	1	3	success	2026-06-16 16:57:03.686761+01	2026-06-16 16:57:03.739679+01	1	0	0	1	0	\N	{"errors": [], "safety": {"body_peek": true, "store_used": false, "imap_readonly": true, "flags_modified": false}, "imported": [], "mailboxes": ["INBOX", "INBOX.Sent"], "duplicates": [{"uid": "1", "mailbox": "INBOX", "occurrence_id": 1}]}
621	1	3	success	2026-06-16 17:02:13.855139+01	2026-06-16 17:02:13.960668+01	1	0	0	1	0	\N	{"errors": [], "safety": {"body_peek": true, "store_used": false, "imap_readonly": true, "flags_modified": false}, "imported": [], "mailboxes": ["INBOX", "INBOX.Sent"], "duplicates": [{"uid": "1", "mailbox": "INBOX", "occurrence_id": 1}]}
622	1	3	success	2026-06-16 17:07:24.068441+01	2026-06-16 17:07:24.179223+01	1	0	0	1	0	\N	{"errors": [], "safety": {"body_peek": true, "store_used": false, "imap_readonly": true, "flags_modified": false}, "imported": [], "mailboxes": ["INBOX", "INBOX.Sent"], "duplicates": [{"uid": "1", "mailbox": "INBOX", "occurrence_id": 1}]}
623	1	3	success	2026-06-16 17:12:34.297408+01	2026-06-16 17:12:34.39121+01	1	0	0	1	0	\N	{"errors": [], "safety": {"body_peek": true, "store_used": false, "imap_readonly": true, "flags_modified": false}, "imported": [], "mailboxes": ["INBOX", "INBOX.Sent"], "duplicates": [{"uid": "1", "mailbox": "INBOX", "occurrence_id": 1}]}
624	1	3	success	2026-06-16 17:17:44.503655+01	2026-06-16 17:17:44.598107+01	1	0	0	1	0	\N	{"errors": [], "safety": {"body_peek": true, "store_used": false, "imap_readonly": true, "flags_modified": false}, "imported": [], "mailboxes": ["INBOX", "INBOX.Sent"], "duplicates": [{"uid": "1", "mailbox": "INBOX", "occurrence_id": 1}]}
625	1	3	success	2026-06-16 17:22:54.702416+01	2026-06-16 17:22:54.783514+01	1	0	0	1	0	\N	{"errors": [], "safety": {"body_peek": true, "store_used": false, "imap_readonly": true, "flags_modified": false}, "imported": [], "mailboxes": ["INBOX", "INBOX.Sent"], "duplicates": [{"uid": "1", "mailbox": "INBOX", "occurrence_id": 1}]}
626	1	3	success	2026-06-16 17:28:04.903019+01	2026-06-16 17:28:04.956725+01	1	0	0	1	0	\N	{"errors": [], "safety": {"body_peek": true, "store_used": false, "imap_readonly": true, "flags_modified": false}, "imported": [], "mailboxes": ["INBOX", "INBOX.Sent"], "duplicates": [{"uid": "1", "mailbox": "INBOX", "occurrence_id": 1}]}
627	1	3	success	2026-06-16 17:33:15.055856+01	2026-06-16 17:33:15.155974+01	1	0	0	1	0	\N	{"errors": [], "safety": {"body_peek": true, "store_used": false, "imap_readonly": true, "flags_modified": false}, "imported": [], "mailboxes": ["INBOX", "INBOX.Sent"], "duplicates": [{"uid": "1", "mailbox": "INBOX", "occurrence_id": 1}]}
628	1	3	success	2026-06-16 17:38:25.264083+01	2026-06-16 17:38:25.368816+01	1	0	0	1	0	\N	{"errors": [], "safety": {"body_peek": true, "store_used": false, "imap_readonly": true, "flags_modified": false}, "imported": [], "mailboxes": ["INBOX", "INBOX.Sent"], "duplicates": [{"uid": "1", "mailbox": "INBOX", "occurrence_id": 1}]}
629	1	3	success	2026-06-16 17:43:35.482844+01	2026-06-16 17:43:35.568466+01	1	0	0	1	0	\N	{"errors": [], "safety": {"body_peek": true, "store_used": false, "imap_readonly": true, "flags_modified": false}, "imported": [], "mailboxes": ["INBOX", "INBOX.Sent"], "duplicates": [{"uid": "1", "mailbox": "INBOX", "occurrence_id": 1}]}
630	1	3	success	2026-06-16 17:48:45.680395+01	2026-06-16 17:48:45.742799+01	1	0	0	1	0	\N	{"errors": [], "safety": {"body_peek": true, "store_used": false, "imap_readonly": true, "flags_modified": false}, "imported": [], "mailboxes": ["INBOX", "INBOX.Sent"], "duplicates": [{"uid": "1", "mailbox": "INBOX", "occurrence_id": 1}]}
631	1	3	success	2026-06-16 17:53:55.864734+01	2026-06-16 17:53:55.916946+01	1	0	0	1	0	\N	{"errors": [], "safety": {"body_peek": true, "store_used": false, "imap_readonly": true, "flags_modified": false}, "imported": [], "mailboxes": ["INBOX", "INBOX.Sent"], "duplicates": [{"uid": "1", "mailbox": "INBOX", "occurrence_id": 1}]}
632	1	3	success	2026-06-16 17:59:06.020457+01	2026-06-16 17:59:06.077436+01	1	0	0	1	0	\N	{"errors": [], "safety": {"body_peek": true, "store_used": false, "imap_readonly": true, "flags_modified": false}, "imported": [], "mailboxes": ["INBOX", "INBOX.Sent"], "duplicates": [{"uid": "1", "mailbox": "INBOX", "occurrence_id": 1}]}
633	1	3	success	2026-06-16 18:04:16.188681+01	2026-06-16 18:04:16.241901+01	1	0	0	1	0	\N	{"errors": [], "safety": {"body_peek": true, "store_used": false, "imap_readonly": true, "flags_modified": false}, "imported": [], "mailboxes": ["INBOX", "INBOX.Sent"], "duplicates": [{"uid": "1", "mailbox": "INBOX", "occurrence_id": 1}]}
634	1	3	success	2026-06-16 18:09:26.360894+01	2026-06-16 18:09:26.445225+01	1	0	0	1	0	\N	{"errors": [], "safety": {"body_peek": true, "store_used": false, "imap_readonly": true, "flags_modified": false}, "imported": [], "mailboxes": ["INBOX", "INBOX.Sent"], "duplicates": [{"uid": "1", "mailbox": "INBOX", "occurrence_id": 1}]}
635	1	3	success	2026-06-16 18:14:36.55371+01	2026-06-16 18:14:36.640571+01	1	0	0	1	0	\N	{"errors": [], "safety": {"body_peek": true, "store_used": false, "imap_readonly": true, "flags_modified": false}, "imported": [], "mailboxes": ["INBOX", "INBOX.Sent"], "duplicates": [{"uid": "1", "mailbox": "INBOX", "occurrence_id": 1}]}
636	1	3	success	2026-06-16 18:19:46.739003+01	2026-06-16 18:19:46.804719+01	1	0	0	1	0	\N	{"errors": [], "safety": {"body_peek": true, "store_used": false, "imap_readonly": true, "flags_modified": false}, "imported": [], "mailboxes": ["INBOX", "INBOX.Sent"], "duplicates": [{"uid": "1", "mailbox": "INBOX", "occurrence_id": 1}]}
637	1	3	success	2026-06-16 18:24:56.899839+01	2026-06-16 18:24:56.988844+01	1	0	0	1	0	\N	{"errors": [], "safety": {"body_peek": true, "store_used": false, "imap_readonly": true, "flags_modified": false}, "imported": [], "mailboxes": ["INBOX", "INBOX.Sent"], "duplicates": [{"uid": "1", "mailbox": "INBOX", "occurrence_id": 1}]}
638	1	3	success	2026-06-16 18:30:07.104294+01	2026-06-16 18:30:07.161288+01	1	0	0	1	0	\N	{"errors": [], "safety": {"body_peek": true, "store_used": false, "imap_readonly": true, "flags_modified": false}, "imported": [], "mailboxes": ["INBOX", "INBOX.Sent"], "duplicates": [{"uid": "1", "mailbox": "INBOX", "occurrence_id": 1}]}
639	1	3	success	2026-06-16 18:35:17.272955+01	2026-06-16 18:35:17.329485+01	1	0	0	1	0	\N	{"errors": [], "safety": {"body_peek": true, "store_used": false, "imap_readonly": true, "flags_modified": false}, "imported": [], "mailboxes": ["INBOX", "INBOX.Sent"], "duplicates": [{"uid": "1", "mailbox": "INBOX", "occurrence_id": 1}]}
640	1	3	success	2026-06-16 18:40:27.421443+01	2026-06-16 18:40:27.483244+01	1	0	0	1	0	\N	{"errors": [], "safety": {"body_peek": true, "store_used": false, "imap_readonly": true, "flags_modified": false}, "imported": [], "mailboxes": ["INBOX", "INBOX.Sent"], "duplicates": [{"uid": "1", "mailbox": "INBOX", "occurrence_id": 1}]}
641	1	3	success	2026-06-16 18:45:37.584993+01	2026-06-16 18:45:37.65379+01	1	0	0	1	0	\N	{"errors": [], "safety": {"body_peek": true, "store_used": false, "imap_readonly": true, "flags_modified": false}, "imported": [], "mailboxes": ["INBOX", "INBOX.Sent"], "duplicates": [{"uid": "1", "mailbox": "INBOX", "occurrence_id": 1}]}
642	1	3	success	2026-06-16 18:50:47.717913+01	2026-06-16 18:50:47.772043+01	1	0	0	1	0	\N	{"errors": [], "safety": {"body_peek": true, "store_used": false, "imap_readonly": true, "flags_modified": false}, "imported": [], "mailboxes": ["INBOX", "INBOX.Sent"], "duplicates": [{"uid": "1", "mailbox": "INBOX", "occurrence_id": 1}]}
643	1	3	success	2026-06-16 18:55:57.86243+01	2026-06-16 18:55:57.914837+01	1	0	0	1	0	\N	{"errors": [], "safety": {"body_peek": true, "store_used": false, "imap_readonly": true, "flags_modified": false}, "imported": [], "mailboxes": ["INBOX", "INBOX.Sent"], "duplicates": [{"uid": "1", "mailbox": "INBOX", "occurrence_id": 1}]}
644	1	3	success	2026-06-16 19:01:08.022524+01	2026-06-16 19:01:08.075449+01	1	0	0	1	0	\N	{"errors": [], "safety": {"body_peek": true, "store_used": false, "imap_readonly": true, "flags_modified": false}, "imported": [], "mailboxes": ["INBOX", "INBOX.Sent"], "duplicates": [{"uid": "1", "mailbox": "INBOX", "occurrence_id": 1}]}
645	1	3	success	2026-06-16 19:06:18.181299+01	2026-06-16 19:06:18.286754+01	1	0	0	1	0	\N	{"errors": [], "safety": {"body_peek": true, "store_used": false, "imap_readonly": true, "flags_modified": false}, "imported": [], "mailboxes": ["INBOX", "INBOX.Sent"], "duplicates": [{"uid": "1", "mailbox": "INBOX", "occurrence_id": 1}]}
646	1	3	success	2026-06-16 19:11:28.377007+01	2026-06-16 19:11:28.430012+01	1	0	0	1	0	\N	{"errors": [], "safety": {"body_peek": true, "store_used": false, "imap_readonly": true, "flags_modified": false}, "imported": [], "mailboxes": ["INBOX", "INBOX.Sent"], "duplicates": [{"uid": "1", "mailbox": "INBOX", "occurrence_id": 1}]}
647	1	3	success	2026-06-16 19:16:38.536285+01	2026-06-16 19:16:38.614182+01	1	0	0	1	0	\N	{"errors": [], "safety": {"body_peek": true, "store_used": false, "imap_readonly": true, "flags_modified": false}, "imported": [], "mailboxes": ["INBOX", "INBOX.Sent"], "duplicates": [{"uid": "1", "mailbox": "INBOX", "occurrence_id": 1}]}
648	1	3	success	2026-06-16 19:21:48.71123+01	2026-06-16 19:21:48.80049+01	1	0	0	1	0	\N	{"errors": [], "safety": {"body_peek": true, "store_used": false, "imap_readonly": true, "flags_modified": false}, "imported": [], "mailboxes": ["INBOX", "INBOX.Sent"], "duplicates": [{"uid": "1", "mailbox": "INBOX", "occurrence_id": 1}]}
649	1	3	success	2026-06-16 19:26:58.903197+01	2026-06-16 19:26:58.958428+01	1	0	0	1	0	\N	{"errors": [], "safety": {"body_peek": true, "store_used": false, "imap_readonly": true, "flags_modified": false}, "imported": [], "mailboxes": ["INBOX", "INBOX.Sent"], "duplicates": [{"uid": "1", "mailbox": "INBOX", "occurrence_id": 1}]}
650	1	3	success	2026-06-16 19:32:09.077217+01	2026-06-16 19:32:09.132416+01	1	0	0	1	0	\N	{"errors": [], "safety": {"body_peek": true, "store_used": false, "imap_readonly": true, "flags_modified": false}, "imported": [], "mailboxes": ["INBOX", "INBOX.Sent"], "duplicates": [{"uid": "1", "mailbox": "INBOX", "occurrence_id": 1}]}
651	1	3	success	2026-06-16 19:37:19.224702+01	2026-06-16 19:37:19.33388+01	1	0	0	1	0	\N	{"errors": [], "safety": {"body_peek": true, "store_used": false, "imap_readonly": true, "flags_modified": false}, "imported": [], "mailboxes": ["INBOX", "INBOX.Sent"], "duplicates": [{"uid": "1", "mailbox": "INBOX", "occurrence_id": 1}]}
652	1	3	success	2026-06-16 19:42:29.443202+01	2026-06-16 19:42:29.525996+01	1	0	0	1	0	\N	{"errors": [], "safety": {"body_peek": true, "store_used": false, "imap_readonly": true, "flags_modified": false}, "imported": [], "mailboxes": ["INBOX", "INBOX.Sent"], "duplicates": [{"uid": "1", "mailbox": "INBOX", "occurrence_id": 1}]}
653	1	3	success	2026-06-16 19:47:39.617552+01	2026-06-16 19:47:39.68245+01	1	0	0	1	0	\N	{"errors": [], "safety": {"body_peek": true, "store_used": false, "imap_readonly": true, "flags_modified": false}, "imported": [], "mailboxes": ["INBOX", "INBOX.Sent"], "duplicates": [{"uid": "1", "mailbox": "INBOX", "occurrence_id": 1}]}
654	1	3	success	2026-06-16 19:52:49.78553+01	2026-06-16 19:52:49.838545+01	1	0	0	1	0	\N	{"errors": [], "safety": {"body_peek": true, "store_used": false, "imap_readonly": true, "flags_modified": false}, "imported": [], "mailboxes": ["INBOX", "INBOX.Sent"], "duplicates": [{"uid": "1", "mailbox": "INBOX", "occurrence_id": 1}]}
655	1	3	success	2026-06-16 19:57:59.951456+01	2026-06-16 19:58:00.028031+01	1	0	0	1	0	\N	{"errors": [], "safety": {"body_peek": true, "store_used": false, "imap_readonly": true, "flags_modified": false}, "imported": [], "mailboxes": ["INBOX", "INBOX.Sent"], "duplicates": [{"uid": "1", "mailbox": "INBOX", "occurrence_id": 1}]}
656	1	3	success	2026-06-16 20:03:10.134546+01	2026-06-16 20:03:10.189786+01	1	0	0	1	0	\N	{"errors": [], "safety": {"body_peek": true, "store_used": false, "imap_readonly": true, "flags_modified": false}, "imported": [], "mailboxes": ["INBOX", "INBOX.Sent"], "duplicates": [{"uid": "1", "mailbox": "INBOX", "occurrence_id": 1}]}
657	1	3	success	2026-06-16 20:08:20.299449+01	2026-06-16 20:08:20.407936+01	1	0	0	1	0	\N	{"errors": [], "safety": {"body_peek": true, "store_used": false, "imap_readonly": true, "flags_modified": false}, "imported": [], "mailboxes": ["INBOX", "INBOX.Sent"], "duplicates": [{"uid": "1", "mailbox": "INBOX", "occurrence_id": 1}]}
658	1	3	success	2026-06-16 20:13:30.512093+01	2026-06-16 20:13:30.62096+01	1	0	0	1	0	\N	{"errors": [], "safety": {"body_peek": true, "store_used": false, "imap_readonly": true, "flags_modified": false}, "imported": [], "mailboxes": ["INBOX", "INBOX.Sent"], "duplicates": [{"uid": "1", "mailbox": "INBOX", "occurrence_id": 1}]}
659	1	3	success	2026-06-16 20:18:40.742236+01	2026-06-16 20:18:40.847636+01	1	0	0	1	0	\N	{"errors": [], "safety": {"body_peek": true, "store_used": false, "imap_readonly": true, "flags_modified": false}, "imported": [], "mailboxes": ["INBOX", "INBOX.Sent"], "duplicates": [{"uid": "1", "mailbox": "INBOX", "occurrence_id": 1}]}
660	1	3	success	2026-06-16 20:23:50.957568+01	2026-06-16 20:23:51.047304+01	1	0	0	1	0	\N	{"errors": [], "safety": {"body_peek": true, "store_used": false, "imap_readonly": true, "flags_modified": false}, "imported": [], "mailboxes": ["INBOX", "INBOX.Sent"], "duplicates": [{"uid": "1", "mailbox": "INBOX", "occurrence_id": 1}]}
661	1	3	success	2026-06-16 20:29:01.158677+01	2026-06-16 20:29:01.27777+01	1	0	0	1	0	\N	{"errors": [], "safety": {"body_peek": true, "store_used": false, "imap_readonly": true, "flags_modified": false}, "imported": [], "mailboxes": ["INBOX", "INBOX.Sent"], "duplicates": [{"uid": "1", "mailbox": "INBOX", "occurrence_id": 1}]}
662	1	3	success	2026-06-16 20:34:11.391169+01	2026-06-16 20:34:11.455487+01	1	0	0	1	0	\N	{"errors": [], "safety": {"body_peek": true, "store_used": false, "imap_readonly": true, "flags_modified": false}, "imported": [], "mailboxes": ["INBOX", "INBOX.Sent"], "duplicates": [{"uid": "1", "mailbox": "INBOX", "occurrence_id": 1}]}
663	1	3	success	2026-06-16 20:39:21.568835+01	2026-06-16 20:39:21.66561+01	1	0	0	1	0	\N	{"errors": [], "safety": {"body_peek": true, "store_used": false, "imap_readonly": true, "flags_modified": false}, "imported": [], "mailboxes": ["INBOX", "INBOX.Sent"], "duplicates": [{"uid": "1", "mailbox": "INBOX", "occurrence_id": 1}]}
664	1	3	success	2026-06-16 20:44:31.77285+01	2026-06-16 20:44:31.838267+01	1	0	0	1	0	\N	{"errors": [], "safety": {"body_peek": true, "store_used": false, "imap_readonly": true, "flags_modified": false}, "imported": [], "mailboxes": ["INBOX", "INBOX.Sent"], "duplicates": [{"uid": "1", "mailbox": "INBOX", "occurrence_id": 1}]}
665	1	3	success	2026-06-16 20:49:41.943621+01	2026-06-16 20:49:42.055963+01	1	0	0	1	0	\N	{"errors": [], "safety": {"body_peek": true, "store_used": false, "imap_readonly": true, "flags_modified": false}, "imported": [], "mailboxes": ["INBOX", "INBOX.Sent"], "duplicates": [{"uid": "1", "mailbox": "INBOX", "occurrence_id": 1}]}
666	1	3	success	2026-06-16 20:54:52.179132+01	2026-06-16 20:54:52.262622+01	1	0	0	1	0	\N	{"errors": [], "safety": {"body_peek": true, "store_used": false, "imap_readonly": true, "flags_modified": false}, "imported": [], "mailboxes": ["INBOX", "INBOX.Sent"], "duplicates": [{"uid": "1", "mailbox": "INBOX", "occurrence_id": 1}]}
667	1	3	success	2026-06-16 21:00:02.386872+01	2026-06-16 21:00:02.525734+01	1	0	0	1	0	\N	{"errors": [], "safety": {"body_peek": true, "store_used": false, "imap_readonly": true, "flags_modified": false}, "imported": [], "mailboxes": ["INBOX", "INBOX.Sent"], "duplicates": [{"uid": "1", "mailbox": "INBOX", "occurrence_id": 1}]}
668	1	3	success	2026-06-16 21:05:12.641244+01	2026-06-16 21:05:12.692653+01	1	0	0	1	0	\N	{"errors": [], "safety": {"body_peek": true, "store_used": false, "imap_readonly": true, "flags_modified": false}, "imported": [], "mailboxes": ["INBOX", "INBOX.Sent"], "duplicates": [{"uid": "1", "mailbox": "INBOX", "occurrence_id": 1}]}
669	1	3	success	2026-06-16 21:10:22.788799+01	2026-06-16 21:10:22.891044+01	1	0	0	1	0	\N	{"errors": [], "safety": {"body_peek": true, "store_used": false, "imap_readonly": true, "flags_modified": false}, "imported": [], "mailboxes": ["INBOX", "INBOX.Sent"], "duplicates": [{"uid": "1", "mailbox": "INBOX", "occurrence_id": 1}]}
670	1	3	success	2026-06-16 21:15:32.9941+01	2026-06-16 21:15:33.099959+01	1	0	0	1	0	\N	{"errors": [], "safety": {"body_peek": true, "store_used": false, "imap_readonly": true, "flags_modified": false}, "imported": [], "mailboxes": ["INBOX", "INBOX.Sent"], "duplicates": [{"uid": "1", "mailbox": "INBOX", "occurrence_id": 1}]}
671	1	3	success	2026-06-16 21:20:43.222083+01	2026-06-16 21:20:43.296521+01	1	0	0	1	0	\N	{"errors": [], "safety": {"body_peek": true, "store_used": false, "imap_readonly": true, "flags_modified": false}, "imported": [], "mailboxes": ["INBOX", "INBOX.Sent"], "duplicates": [{"uid": "1", "mailbox": "INBOX", "occurrence_id": 1}]}
672	1	3	success	2026-06-16 21:25:53.400228+01	2026-06-16 21:25:53.519946+01	1	0	0	1	0	\N	{"errors": [], "safety": {"body_peek": true, "store_used": false, "imap_readonly": true, "flags_modified": false}, "imported": [], "mailboxes": ["INBOX", "INBOX.Sent"], "duplicates": [{"uid": "1", "mailbox": "INBOX", "occurrence_id": 1}]}
673	1	3	success	2026-06-16 21:31:03.612261+01	2026-06-16 21:31:03.668945+01	1	0	0	1	0	\N	{"errors": [], "safety": {"body_peek": true, "store_used": false, "imap_readonly": true, "flags_modified": false}, "imported": [], "mailboxes": ["INBOX", "INBOX.Sent"], "duplicates": [{"uid": "1", "mailbox": "INBOX", "occurrence_id": 1}]}
674	1	3	success	2026-06-16 21:36:13.773958+01	2026-06-16 21:36:13.823574+01	1	0	0	1	0	\N	{"errors": [], "safety": {"body_peek": true, "store_used": false, "imap_readonly": true, "flags_modified": false}, "imported": [], "mailboxes": ["INBOX", "INBOX.Sent"], "duplicates": [{"uid": "1", "mailbox": "INBOX", "occurrence_id": 1}]}
675	1	3	success	2026-06-16 21:41:23.936885+01	2026-06-16 21:41:23.991299+01	1	0	0	1	0	\N	{"errors": [], "safety": {"body_peek": true, "store_used": false, "imap_readonly": true, "flags_modified": false}, "imported": [], "mailboxes": ["INBOX", "INBOX.Sent"], "duplicates": [{"uid": "1", "mailbox": "INBOX", "occurrence_id": 1}]}
676	1	3	success	2026-06-16 21:46:34.105444+01	2026-06-16 21:46:34.157455+01	1	0	0	1	0	\N	{"errors": [], "safety": {"body_peek": true, "store_used": false, "imap_readonly": true, "flags_modified": false}, "imported": [], "mailboxes": ["INBOX", "INBOX.Sent"], "duplicates": [{"uid": "1", "mailbox": "INBOX", "occurrence_id": 1}]}
677	1	3	success	2026-06-16 21:51:44.26134+01	2026-06-16 21:51:44.317696+01	1	0	0	1	0	\N	{"errors": [], "safety": {"body_peek": true, "store_used": false, "imap_readonly": true, "flags_modified": false}, "imported": [], "mailboxes": ["INBOX", "INBOX.Sent"], "duplicates": [{"uid": "1", "mailbox": "INBOX", "occurrence_id": 1}]}
678	1	3	success	2026-06-16 21:56:54.435678+01	2026-06-16 21:56:54.545844+01	1	0	0	1	0	\N	{"errors": [], "safety": {"body_peek": true, "store_used": false, "imap_readonly": true, "flags_modified": false}, "imported": [], "mailboxes": ["INBOX", "INBOX.Sent"], "duplicates": [{"uid": "1", "mailbox": "INBOX", "occurrence_id": 1}]}
679	1	3	success	2026-06-16 22:02:04.662146+01	2026-06-16 22:02:04.769807+01	1	0	0	1	0	\N	{"errors": [], "safety": {"body_peek": true, "store_used": false, "imap_readonly": true, "flags_modified": false}, "imported": [], "mailboxes": ["INBOX", "INBOX.Sent"], "duplicates": [{"uid": "1", "mailbox": "INBOX", "occurrence_id": 1}]}
680	1	3	success	2026-06-16 22:07:14.880765+01	2026-06-16 22:07:14.988811+01	1	0	0	1	0	\N	{"errors": [], "safety": {"body_peek": true, "store_used": false, "imap_readonly": true, "flags_modified": false}, "imported": [], "mailboxes": ["INBOX", "INBOX.Sent"], "duplicates": [{"uid": "1", "mailbox": "INBOX", "occurrence_id": 1}]}
681	1	3	success	2026-06-16 22:12:25.101475+01	2026-06-16 22:12:25.16743+01	1	0	0	1	0	\N	{"errors": [], "safety": {"body_peek": true, "store_used": false, "imap_readonly": true, "flags_modified": false}, "imported": [], "mailboxes": ["INBOX", "INBOX.Sent"], "duplicates": [{"uid": "1", "mailbox": "INBOX", "occurrence_id": 1}]}
682	1	3	success	2026-06-16 22:17:35.264176+01	2026-06-16 22:17:35.317569+01	1	0	0	1	0	\N	{"errors": [], "safety": {"body_peek": true, "store_used": false, "imap_readonly": true, "flags_modified": false}, "imported": [], "mailboxes": ["INBOX", "INBOX.Sent"], "duplicates": [{"uid": "1", "mailbox": "INBOX", "occurrence_id": 1}]}
683	1	3	success	2026-06-16 22:22:45.432473+01	2026-06-16 22:22:45.525533+01	1	0	0	1	0	\N	{"errors": [], "safety": {"body_peek": true, "store_used": false, "imap_readonly": true, "flags_modified": false}, "imported": [], "mailboxes": ["INBOX", "INBOX.Sent"], "duplicates": [{"uid": "1", "mailbox": "INBOX", "occurrence_id": 1}]}
684	1	3	success	2026-06-16 22:27:55.651068+01	2026-06-16 22:27:55.709224+01	1	0	0	1	0	\N	{"errors": [], "safety": {"body_peek": true, "store_used": false, "imap_readonly": true, "flags_modified": false}, "imported": [], "mailboxes": ["INBOX", "INBOX.Sent"], "duplicates": [{"uid": "1", "mailbox": "INBOX", "occurrence_id": 1}]}
685	1	3	success	2026-06-16 22:33:05.827975+01	2026-06-16 22:33:05.886715+01	1	0	0	1	0	\N	{"errors": [], "safety": {"body_peek": true, "store_used": false, "imap_readonly": true, "flags_modified": false}, "imported": [], "mailboxes": ["INBOX", "INBOX.Sent"], "duplicates": [{"uid": "1", "mailbox": "INBOX", "occurrence_id": 1}]}
686	1	3	success	2026-06-16 22:38:15.986373+01	2026-06-16 22:38:16.146014+01	1	0	0	1	0	\N	{"errors": [], "safety": {"body_peek": true, "store_used": false, "imap_readonly": true, "flags_modified": false}, "imported": [], "mailboxes": ["INBOX", "INBOX.Sent"], "duplicates": [{"uid": "1", "mailbox": "INBOX", "occurrence_id": 1}]}
687	1	3	success	2026-06-16 22:43:26.254958+01	2026-06-16 22:43:26.35616+01	1	0	0	1	0	\N	{"errors": [], "safety": {"body_peek": true, "store_used": false, "imap_readonly": true, "flags_modified": false}, "imported": [], "mailboxes": ["INBOX", "INBOX.Sent"], "duplicates": [{"uid": "1", "mailbox": "INBOX", "occurrence_id": 1}]}
688	1	3	success	2026-06-16 22:48:36.468998+01	2026-06-16 22:48:36.565691+01	1	0	0	1	0	\N	{"errors": [], "safety": {"body_peek": true, "store_used": false, "imap_readonly": true, "flags_modified": false}, "imported": [], "mailboxes": ["INBOX", "INBOX.Sent"], "duplicates": [{"uid": "1", "mailbox": "INBOX", "occurrence_id": 1}]}
689	1	3	success	2026-06-16 22:53:46.686934+01	2026-06-16 22:53:46.791422+01	1	0	0	1	0	\N	{"errors": [], "safety": {"body_peek": true, "store_used": false, "imap_readonly": true, "flags_modified": false}, "imported": [], "mailboxes": ["INBOX", "INBOX.Sent"], "duplicates": [{"uid": "1", "mailbox": "INBOX", "occurrence_id": 1}]}
690	1	3	success	2026-06-16 22:58:56.879608+01	2026-06-16 22:58:56.991199+01	1	0	0	1	0	\N	{"errors": [], "safety": {"body_peek": true, "store_used": false, "imap_readonly": true, "flags_modified": false}, "imported": [], "mailboxes": ["INBOX", "INBOX.Sent"], "duplicates": [{"uid": "1", "mailbox": "INBOX", "occurrence_id": 1}]}
691	1	3	success	2026-06-16 23:04:07.091903+01	2026-06-16 23:04:07.142585+01	1	0	0	1	0	\N	{"errors": [], "safety": {"body_peek": true, "store_used": false, "imap_readonly": true, "flags_modified": false}, "imported": [], "mailboxes": ["INBOX", "INBOX.Sent"], "duplicates": [{"uid": "1", "mailbox": "INBOX", "occurrence_id": 1}]}
692	1	3	failed	2026-06-16 23:09:17.266803+01	2026-06-16 23:09:17.277994+01	0	0	0	0	1	Error de conexión IMAP: [Errno -3] Temporary failure in name resolution	{"errors": [{"error": "Error de conexión IMAP: [Errno -3] Temporary failure in name resolution"}], "safety": {"body_peek": true, "store_used": false, "imap_readonly": true, "flags_modified": false}, "imported": [], "mailboxes": ["INBOX", "INBOX.Sent"], "duplicates": []}
693	1	3	success	2026-06-16 23:14:25.406377+01	2026-06-16 23:14:25.487123+01	1	0	0	1	0	\N	{"errors": [], "safety": {"body_peek": true, "store_used": false, "imap_readonly": true, "flags_modified": false}, "imported": [], "mailboxes": ["INBOX", "INBOX.Sent"], "duplicates": [{"uid": "1", "mailbox": "INBOX", "occurrence_id": 1}]}
694	1	3	success	2026-06-16 23:19:35.594637+01	2026-06-16 23:19:35.64547+01	1	0	0	1	0	\N	{"errors": [], "safety": {"body_peek": true, "store_used": false, "imap_readonly": true, "flags_modified": false}, "imported": [], "mailboxes": ["INBOX", "INBOX.Sent"], "duplicates": [{"uid": "1", "mailbox": "INBOX", "occurrence_id": 1}]}
695	1	3	success	2026-06-16 23:24:45.748547+01	2026-06-16 23:24:45.860838+01	1	0	0	1	0	\N	{"errors": [], "safety": {"body_peek": true, "store_used": false, "imap_readonly": true, "flags_modified": false}, "imported": [], "mailboxes": ["INBOX", "INBOX.Sent"], "duplicates": [{"uid": "1", "mailbox": "INBOX", "occurrence_id": 1}]}
696	1	3	success	2026-06-16 23:29:55.978614+01	2026-06-16 23:29:56.030823+01	1	0	0	1	0	\N	{"errors": [], "safety": {"body_peek": true, "store_used": false, "imap_readonly": true, "flags_modified": false}, "imported": [], "mailboxes": ["INBOX", "INBOX.Sent"], "duplicates": [{"uid": "1", "mailbox": "INBOX", "occurrence_id": 1}]}
697	1	3	success	2026-06-16 23:35:06.132831+01	2026-06-16 23:35:06.244508+01	1	0	0	1	0	\N	{"errors": [], "safety": {"body_peek": true, "store_used": false, "imap_readonly": true, "flags_modified": false}, "imported": [], "mailboxes": ["INBOX", "INBOX.Sent"], "duplicates": [{"uid": "1", "mailbox": "INBOX", "occurrence_id": 1}]}
698	1	3	success	2026-06-16 23:40:16.357306+01	2026-06-16 23:40:16.418793+01	1	0	0	1	0	\N	{"errors": [], "safety": {"body_peek": true, "store_used": false, "imap_readonly": true, "flags_modified": false}, "imported": [], "mailboxes": ["INBOX", "INBOX.Sent"], "duplicates": [{"uid": "1", "mailbox": "INBOX", "occurrence_id": 1}]}
699	1	3	success	2026-06-16 23:45:26.539181+01	2026-06-16 23:45:26.647048+01	1	0	0	1	0	\N	{"errors": [], "safety": {"body_peek": true, "store_used": false, "imap_readonly": true, "flags_modified": false}, "imported": [], "mailboxes": ["INBOX", "INBOX.Sent"], "duplicates": [{"uid": "1", "mailbox": "INBOX", "occurrence_id": 1}]}
700	1	3	success	2026-06-16 23:50:36.757864+01	2026-06-16 23:50:36.874921+01	1	0	0	1	0	\N	{"errors": [], "safety": {"body_peek": true, "store_used": false, "imap_readonly": true, "flags_modified": false}, "imported": [], "mailboxes": ["INBOX", "INBOX.Sent"], "duplicates": [{"uid": "1", "mailbox": "INBOX", "occurrence_id": 1}]}
701	1	3	success	2026-06-16 23:55:46.995096+01	2026-06-16 23:55:47.069758+01	1	0	0	1	0	\N	{"errors": [], "safety": {"body_peek": true, "store_used": false, "imap_readonly": true, "flags_modified": false}, "imported": [], "mailboxes": ["INBOX", "INBOX.Sent"], "duplicates": [{"uid": "1", "mailbox": "INBOX", "occurrence_id": 1}]}
702	1	3	success	2026-06-17 00:00:57.174513+01	2026-06-17 00:00:57.289811+01	1	0	0	1	0	\N	{"errors": [], "safety": {"body_peek": true, "store_used": false, "imap_readonly": true, "flags_modified": false}, "imported": [], "mailboxes": ["INBOX", "INBOX.Sent"], "duplicates": [{"uid": "1", "mailbox": "INBOX", "occurrence_id": 1}]}
703	1	3	success	2026-06-17 00:06:07.382879+01	2026-06-17 00:06:07.434354+01	1	0	0	1	0	\N	{"errors": [], "safety": {"body_peek": true, "store_used": false, "imap_readonly": true, "flags_modified": false}, "imported": [], "mailboxes": ["INBOX", "INBOX.Sent"], "duplicates": [{"uid": "1", "mailbox": "INBOX", "occurrence_id": 1}]}
704	1	3	success	2026-06-17 00:11:17.550145+01	2026-06-17 00:11:17.66173+01	1	0	0	1	0	\N	{"errors": [], "safety": {"body_peek": true, "store_used": false, "imap_readonly": true, "flags_modified": false}, "imported": [], "mailboxes": ["INBOX", "INBOX.Sent"], "duplicates": [{"uid": "1", "mailbox": "INBOX", "occurrence_id": 1}]}
705	1	3	success	2026-06-17 00:16:27.769752+01	2026-06-17 00:16:27.884058+01	1	0	0	1	0	\N	{"errors": [], "safety": {"body_peek": true, "store_used": false, "imap_readonly": true, "flags_modified": false}, "imported": [], "mailboxes": ["INBOX", "INBOX.Sent"], "duplicates": [{"uid": "1", "mailbox": "INBOX", "occurrence_id": 1}]}
706	1	3	success	2026-06-17 00:21:38.000519+01	2026-06-17 00:21:38.100491+01	1	0	0	1	0	\N	{"errors": [], "safety": {"body_peek": true, "store_used": false, "imap_readonly": true, "flags_modified": false}, "imported": [], "mailboxes": ["INBOX", "INBOX.Sent"], "duplicates": [{"uid": "1", "mailbox": "INBOX", "occurrence_id": 1}]}
707	1	3	success	2026-06-17 00:26:48.209166+01	2026-06-17 00:26:48.313989+01	1	0	0	1	0	\N	{"errors": [], "safety": {"body_peek": true, "store_used": false, "imap_readonly": true, "flags_modified": false}, "imported": [], "mailboxes": ["INBOX", "INBOX.Sent"], "duplicates": [{"uid": "1", "mailbox": "INBOX", "occurrence_id": 1}]}
708	1	3	success	2026-06-17 00:31:58.430062+01	2026-06-17 00:31:58.519819+01	1	0	0	1	0	\N	{"errors": [], "safety": {"body_peek": true, "store_used": false, "imap_readonly": true, "flags_modified": false}, "imported": [], "mailboxes": ["INBOX", "INBOX.Sent"], "duplicates": [{"uid": "1", "mailbox": "INBOX", "occurrence_id": 1}]}
709	1	3	success	2026-06-17 00:37:08.630169+01	2026-06-17 00:37:08.731401+01	1	0	0	1	0	\N	{"errors": [], "safety": {"body_peek": true, "store_used": false, "imap_readonly": true, "flags_modified": false}, "imported": [], "mailboxes": ["INBOX", "INBOX.Sent"], "duplicates": [{"uid": "1", "mailbox": "INBOX", "occurrence_id": 1}]}
710	1	3	success	2026-06-17 00:42:18.844723+01	2026-06-17 00:42:18.957457+01	1	0	0	1	0	\N	{"errors": [], "safety": {"body_peek": true, "store_used": false, "imap_readonly": true, "flags_modified": false}, "imported": [], "mailboxes": ["INBOX", "INBOX.Sent"], "duplicates": [{"uid": "1", "mailbox": "INBOX", "occurrence_id": 1}]}
711	1	3	success	2026-06-17 00:47:29.086082+01	2026-06-17 00:47:29.139318+01	1	0	0	1	0	\N	{"errors": [], "safety": {"body_peek": true, "store_used": false, "imap_readonly": true, "flags_modified": false}, "imported": [], "mailboxes": ["INBOX", "INBOX.Sent"], "duplicates": [{"uid": "1", "mailbox": "INBOX", "occurrence_id": 1}]}
712	1	3	success	2026-06-17 00:52:39.242146+01	2026-06-17 00:52:39.304008+01	1	0	0	1	0	\N	{"errors": [], "safety": {"body_peek": true, "store_used": false, "imap_readonly": true, "flags_modified": false}, "imported": [], "mailboxes": ["INBOX", "INBOX.Sent"], "duplicates": [{"uid": "1", "mailbox": "INBOX", "occurrence_id": 1}]}
713	1	3	success	2026-06-17 00:57:49.42452+01	2026-06-17 00:57:49.528707+01	1	0	0	1	0	\N	{"errors": [], "safety": {"body_peek": true, "store_used": false, "imap_readonly": true, "flags_modified": false}, "imported": [], "mailboxes": ["INBOX", "INBOX.Sent"], "duplicates": [{"uid": "1", "mailbox": "INBOX", "occurrence_id": 1}]}
714	1	3	success	2026-06-17 01:02:59.635938+01	2026-06-17 01:02:59.690528+01	1	0	0	1	0	\N	{"errors": [], "safety": {"body_peek": true, "store_used": false, "imap_readonly": true, "flags_modified": false}, "imported": [], "mailboxes": ["INBOX", "INBOX.Sent"], "duplicates": [{"uid": "1", "mailbox": "INBOX", "occurrence_id": 1}]}
715	1	3	success	2026-06-17 01:08:09.782117+01	2026-06-17 01:08:09.834476+01	1	0	0	1	0	\N	{"errors": [], "safety": {"body_peek": true, "store_used": false, "imap_readonly": true, "flags_modified": false}, "imported": [], "mailboxes": ["INBOX", "INBOX.Sent"], "duplicates": [{"uid": "1", "mailbox": "INBOX", "occurrence_id": 1}]}
716	1	3	success	2026-06-17 01:13:19.958418+01	2026-06-17 01:13:20.050912+01	1	0	0	1	0	\N	{"errors": [], "safety": {"body_peek": true, "store_used": false, "imap_readonly": true, "flags_modified": false}, "imported": [], "mailboxes": ["INBOX", "INBOX.Sent"], "duplicates": [{"uid": "1", "mailbox": "INBOX", "occurrence_id": 1}]}
717	1	3	success	2026-06-17 01:18:30.179836+01	2026-06-17 01:18:30.238799+01	1	0	0	1	0	\N	{"errors": [], "safety": {"body_peek": true, "store_used": false, "imap_readonly": true, "flags_modified": false}, "imported": [], "mailboxes": ["INBOX", "INBOX.Sent"], "duplicates": [{"uid": "1", "mailbox": "INBOX", "occurrence_id": 1}]}
718	1	3	success	2026-06-17 01:23:40.372788+01	2026-06-17 01:23:40.42599+01	1	0	0	1	0	\N	{"errors": [], "safety": {"body_peek": true, "store_used": false, "imap_readonly": true, "flags_modified": false}, "imported": [], "mailboxes": ["INBOX", "INBOX.Sent"], "duplicates": [{"uid": "1", "mailbox": "INBOX", "occurrence_id": 1}]}
719	1	3	success	2026-06-17 01:28:50.520017+01	2026-06-17 01:28:50.625075+01	1	0	0	1	0	\N	{"errors": [], "safety": {"body_peek": true, "store_used": false, "imap_readonly": true, "flags_modified": false}, "imported": [], "mailboxes": ["INBOX", "INBOX.Sent"], "duplicates": [{"uid": "1", "mailbox": "INBOX", "occurrence_id": 1}]}
720	1	3	success	2026-06-17 01:34:00.74091+01	2026-06-17 01:34:00.833104+01	1	0	0	1	0	\N	{"errors": [], "safety": {"body_peek": true, "store_used": false, "imap_readonly": true, "flags_modified": false}, "imported": [], "mailboxes": ["INBOX", "INBOX.Sent"], "duplicates": [{"uid": "1", "mailbox": "INBOX", "occurrence_id": 1}]}
721	1	3	success	2026-06-17 01:39:10.948251+01	2026-06-17 01:39:11.011474+01	1	0	0	1	0	\N	{"errors": [], "safety": {"body_peek": true, "store_used": false, "imap_readonly": true, "flags_modified": false}, "imported": [], "mailboxes": ["INBOX", "INBOX.Sent"], "duplicates": [{"uid": "1", "mailbox": "INBOX", "occurrence_id": 1}]}
722	1	3	success	2026-06-17 01:44:21.114707+01	2026-06-17 01:44:21.245865+01	1	0	0	1	0	\N	{"errors": [], "safety": {"body_peek": true, "store_used": false, "imap_readonly": true, "flags_modified": false}, "imported": [], "mailboxes": ["INBOX", "INBOX.Sent"], "duplicates": [{"uid": "1", "mailbox": "INBOX", "occurrence_id": 1}]}
723	1	3	success	2026-06-17 01:49:31.331165+01	2026-06-17 01:49:31.380458+01	1	0	0	1	0	\N	{"errors": [], "safety": {"body_peek": true, "store_used": false, "imap_readonly": true, "flags_modified": false}, "imported": [], "mailboxes": ["INBOX", "INBOX.Sent"], "duplicates": [{"uid": "1", "mailbox": "INBOX", "occurrence_id": 1}]}
724	1	3	success	2026-06-17 01:54:41.468927+01	2026-06-17 01:54:41.526037+01	1	0	0	1	0	\N	{"errors": [], "safety": {"body_peek": true, "store_used": false, "imap_readonly": true, "flags_modified": false}, "imported": [], "mailboxes": ["INBOX", "INBOX.Sent"], "duplicates": [{"uid": "1", "mailbox": "INBOX", "occurrence_id": 1}]}
725	1	3	success	2026-06-17 01:59:51.636432+01	2026-06-17 01:59:51.832768+01	1	0	0	1	0	\N	{"errors": [], "safety": {"body_peek": true, "store_used": false, "imap_readonly": true, "flags_modified": false}, "imported": [], "mailboxes": ["INBOX", "INBOX.Sent"], "duplicates": [{"uid": "1", "mailbox": "INBOX", "occurrence_id": 1}]}
726	1	3	success	2026-06-17 02:05:01.92325+01	2026-06-17 02:05:02.042797+01	1	0	0	1	0	\N	{"errors": [], "safety": {"body_peek": true, "store_used": false, "imap_readonly": true, "flags_modified": false}, "imported": [], "mailboxes": ["INBOX", "INBOX.Sent"], "duplicates": [{"uid": "1", "mailbox": "INBOX", "occurrence_id": 1}]}
727	1	3	success	2026-06-17 02:10:12.136761+01	2026-06-17 02:10:12.194596+01	1	0	0	1	0	\N	{"errors": [], "safety": {"body_peek": true, "store_used": false, "imap_readonly": true, "flags_modified": false}, "imported": [], "mailboxes": ["INBOX", "INBOX.Sent"], "duplicates": [{"uid": "1", "mailbox": "INBOX", "occurrence_id": 1}]}
728	1	3	success	2026-06-17 02:15:22.251171+01	2026-06-17 02:15:22.315718+01	1	0	0	1	0	\N	{"errors": [], "safety": {"body_peek": true, "store_used": false, "imap_readonly": true, "flags_modified": false}, "imported": [], "mailboxes": ["INBOX", "INBOX.Sent"], "duplicates": [{"uid": "1", "mailbox": "INBOX", "occurrence_id": 1}]}
729	1	3	success	2026-06-17 02:20:32.428163+01	2026-06-17 02:20:32.529914+01	1	0	0	1	0	\N	{"errors": [], "safety": {"body_peek": true, "store_used": false, "imap_readonly": true, "flags_modified": false}, "imported": [], "mailboxes": ["INBOX", "INBOX.Sent"], "duplicates": [{"uid": "1", "mailbox": "INBOX", "occurrence_id": 1}]}
730	1	3	success	2026-06-17 02:25:42.632797+01	2026-06-17 02:25:42.68417+01	1	0	0	1	0	\N	{"errors": [], "safety": {"body_peek": true, "store_used": false, "imap_readonly": true, "flags_modified": false}, "imported": [], "mailboxes": ["INBOX", "INBOX.Sent"], "duplicates": [{"uid": "1", "mailbox": "INBOX", "occurrence_id": 1}]}
731	1	3	success	2026-06-17 02:30:52.802601+01	2026-06-17 02:30:52.902483+01	1	0	0	1	0	\N	{"errors": [], "safety": {"body_peek": true, "store_used": false, "imap_readonly": true, "flags_modified": false}, "imported": [], "mailboxes": ["INBOX", "INBOX.Sent"], "duplicates": [{"uid": "1", "mailbox": "INBOX", "occurrence_id": 1}]}
732	1	3	success	2026-06-17 02:36:03.013516+01	2026-06-17 02:36:03.06984+01	1	0	0	1	0	\N	{"errors": [], "safety": {"body_peek": true, "store_used": false, "imap_readonly": true, "flags_modified": false}, "imported": [], "mailboxes": ["INBOX", "INBOX.Sent"], "duplicates": [{"uid": "1", "mailbox": "INBOX", "occurrence_id": 1}]}
733	1	3	success	2026-06-17 02:41:13.174824+01	2026-06-17 02:41:13.286091+01	1	0	0	1	0	\N	{"errors": [], "safety": {"body_peek": true, "store_used": false, "imap_readonly": true, "flags_modified": false}, "imported": [], "mailboxes": ["INBOX", "INBOX.Sent"], "duplicates": [{"uid": "1", "mailbox": "INBOX", "occurrence_id": 1}]}
734	1	3	success	2026-06-17 02:46:23.398036+01	2026-06-17 02:46:23.479678+01	1	0	0	1	0	\N	{"errors": [], "safety": {"body_peek": true, "store_used": false, "imap_readonly": true, "flags_modified": false}, "imported": [], "mailboxes": ["INBOX", "INBOX.Sent"], "duplicates": [{"uid": "1", "mailbox": "INBOX", "occurrence_id": 1}]}
735	1	3	success	2026-06-17 02:51:33.585719+01	2026-06-17 02:51:33.651913+01	1	0	0	1	0	\N	{"errors": [], "safety": {"body_peek": true, "store_used": false, "imap_readonly": true, "flags_modified": false}, "imported": [], "mailboxes": ["INBOX", "INBOX.Sent"], "duplicates": [{"uid": "1", "mailbox": "INBOX", "occurrence_id": 1}]}
736	1	3	success	2026-06-17 02:56:43.773006+01	2026-06-17 02:56:43.840413+01	1	0	0	1	0	\N	{"errors": [], "safety": {"body_peek": true, "store_used": false, "imap_readonly": true, "flags_modified": false}, "imported": [], "mailboxes": ["INBOX", "INBOX.Sent"], "duplicates": [{"uid": "1", "mailbox": "INBOX", "occurrence_id": 1}]}
737	1	3	success	2026-06-17 03:01:53.958581+01	2026-06-17 03:01:54.113979+01	1	0	0	1	0	\N	{"errors": [], "safety": {"body_peek": true, "store_used": false, "imap_readonly": true, "flags_modified": false}, "imported": [], "mailboxes": ["INBOX", "INBOX.Sent"], "duplicates": [{"uid": "1", "mailbox": "INBOX", "occurrence_id": 1}]}
738	1	3	success	2026-06-17 03:07:04.226251+01	2026-06-17 03:07:04.333471+01	1	0	0	1	0	\N	{"errors": [], "safety": {"body_peek": true, "store_used": false, "imap_readonly": true, "flags_modified": false}, "imported": [], "mailboxes": ["INBOX", "INBOX.Sent"], "duplicates": [{"uid": "1", "mailbox": "INBOX", "occurrence_id": 1}]}
739	1	3	success	2026-06-17 03:12:14.431047+01	2026-06-17 03:12:14.536415+01	1	0	0	1	0	\N	{"errors": [], "safety": {"body_peek": true, "store_used": false, "imap_readonly": true, "flags_modified": false}, "imported": [], "mailboxes": ["INBOX", "INBOX.Sent"], "duplicates": [{"uid": "1", "mailbox": "INBOX", "occurrence_id": 1}]}
740	1	3	success	2026-06-17 03:17:24.648585+01	2026-06-17 03:17:24.743823+01	1	0	0	1	0	\N	{"errors": [], "safety": {"body_peek": true, "store_used": false, "imap_readonly": true, "flags_modified": false}, "imported": [], "mailboxes": ["INBOX", "INBOX.Sent"], "duplicates": [{"uid": "1", "mailbox": "INBOX", "occurrence_id": 1}]}
741	1	3	success	2026-06-17 03:22:34.838779+01	2026-06-17 03:22:34.893379+01	1	0	0	1	0	\N	{"errors": [], "safety": {"body_peek": true, "store_used": false, "imap_readonly": true, "flags_modified": false}, "imported": [], "mailboxes": ["INBOX", "INBOX.Sent"], "duplicates": [{"uid": "1", "mailbox": "INBOX", "occurrence_id": 1}]}
742	1	3	success	2026-06-17 03:27:44.95184+01	2026-06-17 03:27:45.004893+01	1	0	0	1	0	\N	{"errors": [], "safety": {"body_peek": true, "store_used": false, "imap_readonly": true, "flags_modified": false}, "imported": [], "mailboxes": ["INBOX", "INBOX.Sent"], "duplicates": [{"uid": "1", "mailbox": "INBOX", "occurrence_id": 1}]}
743	1	3	success	2026-06-17 03:32:55.07515+01	2026-06-17 03:32:55.14249+01	1	0	0	1	0	\N	{"errors": [], "safety": {"body_peek": true, "store_used": false, "imap_readonly": true, "flags_modified": false}, "imported": [], "mailboxes": ["INBOX", "INBOX.Sent"], "duplicates": [{"uid": "1", "mailbox": "INBOX", "occurrence_id": 1}]}
744	1	3	success	2026-06-17 03:38:05.264272+01	2026-06-17 03:38:05.324562+01	1	0	0	1	0	\N	{"errors": [], "safety": {"body_peek": true, "store_used": false, "imap_readonly": true, "flags_modified": false}, "imported": [], "mailboxes": ["INBOX", "INBOX.Sent"], "duplicates": [{"uid": "1", "mailbox": "INBOX", "occurrence_id": 1}]}
745	1	3	success	2026-06-17 03:43:15.448693+01	2026-06-17 03:43:15.594823+01	1	0	0	1	0	\N	{"errors": [], "safety": {"body_peek": true, "store_used": false, "imap_readonly": true, "flags_modified": false}, "imported": [], "mailboxes": ["INBOX", "INBOX.Sent"], "duplicates": [{"uid": "1", "mailbox": "INBOX", "occurrence_id": 1}]}
746	1	3	success	2026-06-17 03:48:25.711481+01	2026-06-17 03:48:25.76697+01	1	0	0	1	0	\N	{"errors": [], "safety": {"body_peek": true, "store_used": false, "imap_readonly": true, "flags_modified": false}, "imported": [], "mailboxes": ["INBOX", "INBOX.Sent"], "duplicates": [{"uid": "1", "mailbox": "INBOX", "occurrence_id": 1}]}
747	1	3	success	2026-06-17 03:53:35.875791+01	2026-06-17 03:53:35.933842+01	1	0	0	1	0	\N	{"errors": [], "safety": {"body_peek": true, "store_used": false, "imap_readonly": true, "flags_modified": false}, "imported": [], "mailboxes": ["INBOX", "INBOX.Sent"], "duplicates": [{"uid": "1", "mailbox": "INBOX", "occurrence_id": 1}]}
748	1	3	success	2026-06-17 03:58:46.054223+01	2026-06-17 03:58:46.153248+01	1	0	0	1	0	\N	{"errors": [], "safety": {"body_peek": true, "store_used": false, "imap_readonly": true, "flags_modified": false}, "imported": [], "mailboxes": ["INBOX", "INBOX.Sent"], "duplicates": [{"uid": "1", "mailbox": "INBOX", "occurrence_id": 1}]}
749	1	3	success	2026-06-17 04:03:56.256062+01	2026-06-17 04:03:56.326836+01	1	0	0	1	0	\N	{"errors": [], "safety": {"body_peek": true, "store_used": false, "imap_readonly": true, "flags_modified": false}, "imported": [], "mailboxes": ["INBOX", "INBOX.Sent"], "duplicates": [{"uid": "1", "mailbox": "INBOX", "occurrence_id": 1}]}
750	1	3	success	2026-06-17 04:09:06.444209+01	2026-06-17 04:09:06.496708+01	1	0	0	1	0	\N	{"errors": [], "safety": {"body_peek": true, "store_used": false, "imap_readonly": true, "flags_modified": false}, "imported": [], "mailboxes": ["INBOX", "INBOX.Sent"], "duplicates": [{"uid": "1", "mailbox": "INBOX", "occurrence_id": 1}]}
751	1	3	success	2026-06-17 04:14:16.624194+01	2026-06-17 04:14:16.693037+01	1	0	0	1	0	\N	{"errors": [], "safety": {"body_peek": true, "store_used": false, "imap_readonly": true, "flags_modified": false}, "imported": [], "mailboxes": ["INBOX", "INBOX.Sent"], "duplicates": [{"uid": "1", "mailbox": "INBOX", "occurrence_id": 1}]}
752	1	3	success	2026-06-17 04:19:26.805993+01	2026-06-17 04:19:26.866386+01	1	0	0	1	0	\N	{"errors": [], "safety": {"body_peek": true, "store_used": false, "imap_readonly": true, "flags_modified": false}, "imported": [], "mailboxes": ["INBOX", "INBOX.Sent"], "duplicates": [{"uid": "1", "mailbox": "INBOX", "occurrence_id": 1}]}
753	1	3	success	2026-06-17 04:24:36.979099+01	2026-06-17 04:24:37.08791+01	1	0	0	1	0	\N	{"errors": [], "safety": {"body_peek": true, "store_used": false, "imap_readonly": true, "flags_modified": false}, "imported": [], "mailboxes": ["INBOX", "INBOX.Sent"], "duplicates": [{"uid": "1", "mailbox": "INBOX", "occurrence_id": 1}]}
754	1	3	success	2026-06-17 04:29:47.192895+01	2026-06-17 04:29:47.300034+01	1	0	0	1	0	\N	{"errors": [], "safety": {"body_peek": true, "store_used": false, "imap_readonly": true, "flags_modified": false}, "imported": [], "mailboxes": ["INBOX", "INBOX.Sent"], "duplicates": [{"uid": "1", "mailbox": "INBOX", "occurrence_id": 1}]}
755	1	3	success	2026-06-17 04:34:57.407404+01	2026-06-17 04:34:57.558867+01	1	0	0	1	0	\N	{"errors": [], "safety": {"body_peek": true, "store_used": false, "imap_readonly": true, "flags_modified": false}, "imported": [], "mailboxes": ["INBOX", "INBOX.Sent"], "duplicates": [{"uid": "1", "mailbox": "INBOX", "occurrence_id": 1}]}
756	1	3	success	2026-06-17 04:40:07.661285+01	2026-06-17 04:40:07.777443+01	1	0	0	1	0	\N	{"errors": [], "safety": {"body_peek": true, "store_used": false, "imap_readonly": true, "flags_modified": false}, "imported": [], "mailboxes": ["INBOX", "INBOX.Sent"], "duplicates": [{"uid": "1", "mailbox": "INBOX", "occurrence_id": 1}]}
757	1	3	success	2026-06-17 04:45:17.850394+01	2026-06-17 04:45:17.90226+01	1	0	0	1	0	\N	{"errors": [], "safety": {"body_peek": true, "store_used": false, "imap_readonly": true, "flags_modified": false}, "imported": [], "mailboxes": ["INBOX", "INBOX.Sent"], "duplicates": [{"uid": "1", "mailbox": "INBOX", "occurrence_id": 1}]}
758	1	3	success	2026-06-17 04:50:27.954551+01	2026-06-17 04:50:28.007774+01	1	0	0	1	0	\N	{"errors": [], "safety": {"body_peek": true, "store_used": false, "imap_readonly": true, "flags_modified": false}, "imported": [], "mailboxes": ["INBOX", "INBOX.Sent"], "duplicates": [{"uid": "1", "mailbox": "INBOX", "occurrence_id": 1}]}
759	1	3	success	2026-06-17 04:55:38.126102+01	2026-06-17 04:55:38.228636+01	1	0	0	1	0	\N	{"errors": [], "safety": {"body_peek": true, "store_used": false, "imap_readonly": true, "flags_modified": false}, "imported": [], "mailboxes": ["INBOX", "INBOX.Sent"], "duplicates": [{"uid": "1", "mailbox": "INBOX", "occurrence_id": 1}]}
760	1	3	success	2026-06-17 05:00:48.337207+01	2026-06-17 05:00:48.447054+01	1	0	0	1	0	\N	{"errors": [], "safety": {"body_peek": true, "store_used": false, "imap_readonly": true, "flags_modified": false}, "imported": [], "mailboxes": ["INBOX", "INBOX.Sent"], "duplicates": [{"uid": "1", "mailbox": "INBOX", "occurrence_id": 1}]}
761	1	3	success	2026-06-17 05:05:58.561853+01	2026-06-17 05:05:58.61625+01	1	0	0	1	0	\N	{"errors": [], "safety": {"body_peek": true, "store_used": false, "imap_readonly": true, "flags_modified": false}, "imported": [], "mailboxes": ["INBOX", "INBOX.Sent"], "duplicates": [{"uid": "1", "mailbox": "INBOX", "occurrence_id": 1}]}
762	1	3	success	2026-06-17 05:11:08.748998+01	2026-06-17 05:11:08.814841+01	1	0	0	1	0	\N	{"errors": [], "safety": {"body_peek": true, "store_used": false, "imap_readonly": true, "flags_modified": false}, "imported": [], "mailboxes": ["INBOX", "INBOX.Sent"], "duplicates": [{"uid": "1", "mailbox": "INBOX", "occurrence_id": 1}]}
763	1	3	success	2026-06-17 05:16:18.915062+01	2026-06-17 05:16:18.976806+01	1	0	0	1	0	\N	{"errors": [], "safety": {"body_peek": true, "store_used": false, "imap_readonly": true, "flags_modified": false}, "imported": [], "mailboxes": ["INBOX", "INBOX.Sent"], "duplicates": [{"uid": "1", "mailbox": "INBOX", "occurrence_id": 1}]}
764	1	3	success	2026-06-17 05:21:29.074455+01	2026-06-17 05:21:29.180384+01	1	0	0	1	0	\N	{"errors": [], "safety": {"body_peek": true, "store_used": false, "imap_readonly": true, "flags_modified": false}, "imported": [], "mailboxes": ["INBOX", "INBOX.Sent"], "duplicates": [{"uid": "1", "mailbox": "INBOX", "occurrence_id": 1}]}
765	1	3	success	2026-06-17 05:26:39.288669+01	2026-06-17 05:26:39.346805+01	1	0	0	1	0	\N	{"errors": [], "safety": {"body_peek": true, "store_used": false, "imap_readonly": true, "flags_modified": false}, "imported": [], "mailboxes": ["INBOX", "INBOX.Sent"], "duplicates": [{"uid": "1", "mailbox": "INBOX", "occurrence_id": 1}]}
766	1	3	success	2026-06-17 05:31:49.454089+01	2026-06-17 05:31:49.558399+01	1	0	0	1	0	\N	{"errors": [], "safety": {"body_peek": true, "store_used": false, "imap_readonly": true, "flags_modified": false}, "imported": [], "mailboxes": ["INBOX", "INBOX.Sent"], "duplicates": [{"uid": "1", "mailbox": "INBOX", "occurrence_id": 1}]}
767	1	3	success	2026-06-17 05:36:59.66153+01	2026-06-17 05:36:59.714648+01	1	0	0	1	0	\N	{"errors": [], "safety": {"body_peek": true, "store_used": false, "imap_readonly": true, "flags_modified": false}, "imported": [], "mailboxes": ["INBOX", "INBOX.Sent"], "duplicates": [{"uid": "1", "mailbox": "INBOX", "occurrence_id": 1}]}
768	1	3	success	2026-06-17 05:42:09.798174+01	2026-06-17 05:42:09.849116+01	1	0	0	1	0	\N	{"errors": [], "safety": {"body_peek": true, "store_used": false, "imap_readonly": true, "flags_modified": false}, "imported": [], "mailboxes": ["INBOX", "INBOX.Sent"], "duplicates": [{"uid": "1", "mailbox": "INBOX", "occurrence_id": 1}]}
769	1	3	success	2026-06-17 05:47:19.962928+01	2026-06-17 05:47:20.069797+01	1	0	0	1	0	\N	{"errors": [], "safety": {"body_peek": true, "store_used": false, "imap_readonly": true, "flags_modified": false}, "imported": [], "mailboxes": ["INBOX", "INBOX.Sent"], "duplicates": [{"uid": "1", "mailbox": "INBOX", "occurrence_id": 1}]}
770	1	3	success	2026-06-17 05:52:30.169299+01	2026-06-17 05:52:30.35421+01	1	0	0	1	0	\N	{"errors": [], "safety": {"body_peek": true, "store_used": false, "imap_readonly": true, "flags_modified": false}, "imported": [], "mailboxes": ["INBOX", "INBOX.Sent"], "duplicates": [{"uid": "1", "mailbox": "INBOX", "occurrence_id": 1}]}
771	1	3	success	2026-06-17 05:57:40.462862+01	2026-06-17 05:57:40.522934+01	1	0	0	1	0	\N	{"errors": [], "safety": {"body_peek": true, "store_used": false, "imap_readonly": true, "flags_modified": false}, "imported": [], "mailboxes": ["INBOX", "INBOX.Sent"], "duplicates": [{"uid": "1", "mailbox": "INBOX", "occurrence_id": 1}]}
772	1	3	success	2026-06-17 06:02:50.648009+01	2026-06-17 06:02:50.833663+01	1	0	0	1	0	\N	{"errors": [], "safety": {"body_peek": true, "store_used": false, "imap_readonly": true, "flags_modified": false}, "imported": [], "mailboxes": ["INBOX", "INBOX.Sent"], "duplicates": [{"uid": "1", "mailbox": "INBOX", "occurrence_id": 1}]}
773	1	3	success	2026-06-17 06:08:00.954136+01	2026-06-17 06:08:01.060608+01	1	0	0	1	0	\N	{"errors": [], "safety": {"body_peek": true, "store_used": false, "imap_readonly": true, "flags_modified": false}, "imported": [], "mailboxes": ["INBOX", "INBOX.Sent"], "duplicates": [{"uid": "1", "mailbox": "INBOX", "occurrence_id": 1}]}
774	1	3	success	2026-06-17 06:13:11.164175+01	2026-06-17 06:13:11.269526+01	1	0	0	1	0	\N	{"errors": [], "safety": {"body_peek": true, "store_used": false, "imap_readonly": true, "flags_modified": false}, "imported": [], "mailboxes": ["INBOX", "INBOX.Sent"], "duplicates": [{"uid": "1", "mailbox": "INBOX", "occurrence_id": 1}]}
775	1	3	success	2026-06-17 06:18:21.372998+01	2026-06-17 06:18:21.554403+01	1	0	0	1	0	\N	{"errors": [], "safety": {"body_peek": true, "store_used": false, "imap_readonly": true, "flags_modified": false}, "imported": [], "mailboxes": ["INBOX", "INBOX.Sent"], "duplicates": [{"uid": "1", "mailbox": "INBOX", "occurrence_id": 1}]}
776	1	3	success	2026-06-17 06:23:31.680808+01	2026-06-17 06:23:31.781942+01	1	0	0	1	0	\N	{"errors": [], "safety": {"body_peek": true, "store_used": false, "imap_readonly": true, "flags_modified": false}, "imported": [], "mailboxes": ["INBOX", "INBOX.Sent"], "duplicates": [{"uid": "1", "mailbox": "INBOX", "occurrence_id": 1}]}
777	1	3	success	2026-06-17 06:28:41.890469+01	2026-06-17 06:28:42.005654+01	1	0	0	1	0	\N	{"errors": [], "safety": {"body_peek": true, "store_used": false, "imap_readonly": true, "flags_modified": false}, "imported": [], "mailboxes": ["INBOX", "INBOX.Sent"], "duplicates": [{"uid": "1", "mailbox": "INBOX", "occurrence_id": 1}]}
778	1	3	success	2026-06-17 06:33:52.118985+01	2026-06-17 06:33:52.175667+01	1	0	0	1	0	\N	{"errors": [], "safety": {"body_peek": true, "store_used": false, "imap_readonly": true, "flags_modified": false}, "imported": [], "mailboxes": ["INBOX", "INBOX.Sent"], "duplicates": [{"uid": "1", "mailbox": "INBOX", "occurrence_id": 1}]}
779	1	3	success	2026-06-17 06:39:02.293743+01	2026-06-17 06:39:02.348411+01	1	0	0	1	0	\N	{"errors": [], "safety": {"body_peek": true, "store_used": false, "imap_readonly": true, "flags_modified": false}, "imported": [], "mailboxes": ["INBOX", "INBOX.Sent"], "duplicates": [{"uid": "1", "mailbox": "INBOX", "occurrence_id": 1}]}
780	1	3	success	2026-06-17 06:44:12.469859+01	2026-06-17 06:44:12.617815+01	1	0	0	1	0	\N	{"errors": [], "safety": {"body_peek": true, "store_used": false, "imap_readonly": true, "flags_modified": false}, "imported": [], "mailboxes": ["INBOX", "INBOX.Sent"], "duplicates": [{"uid": "1", "mailbox": "INBOX", "occurrence_id": 1}]}
781	1	3	success	2026-06-17 06:49:22.718886+01	2026-06-17 06:49:22.899605+01	1	0	0	1	0	\N	{"errors": [], "safety": {"body_peek": true, "store_used": false, "imap_readonly": true, "flags_modified": false}, "imported": [], "mailboxes": ["INBOX", "INBOX.Sent"], "duplicates": [{"uid": "1", "mailbox": "INBOX", "occurrence_id": 1}]}
782	1	3	success	2026-06-17 06:54:32.990684+01	2026-06-17 06:54:33.05189+01	1	0	0	1	0	\N	{"errors": [], "safety": {"body_peek": true, "store_used": false, "imap_readonly": true, "flags_modified": false}, "imported": [], "mailboxes": ["INBOX", "INBOX.Sent"], "duplicates": [{"uid": "1", "mailbox": "INBOX", "occurrence_id": 1}]}
783	1	3	success	2026-06-17 06:59:43.129996+01	2026-06-17 06:59:43.19495+01	1	0	0	1	0	\N	{"errors": [], "safety": {"body_peek": true, "store_used": false, "imap_readonly": true, "flags_modified": false}, "imported": [], "mailboxes": ["INBOX", "INBOX.Sent"], "duplicates": [{"uid": "1", "mailbox": "INBOX", "occurrence_id": 1}]}
784	1	3	success	2026-06-17 07:04:53.3119+01	2026-06-17 07:04:53.420194+01	1	0	0	1	0	\N	{"errors": [], "safety": {"body_peek": true, "store_used": false, "imap_readonly": true, "flags_modified": false}, "imported": [], "mailboxes": ["INBOX", "INBOX.Sent"], "duplicates": [{"uid": "1", "mailbox": "INBOX", "occurrence_id": 1}]}
785	1	3	success	2026-06-17 07:10:03.514203+01	2026-06-17 07:10:03.591329+01	1	0	0	1	0	\N	{"errors": [], "safety": {"body_peek": true, "store_used": false, "imap_readonly": true, "flags_modified": false}, "imported": [], "mailboxes": ["INBOX", "INBOX.Sent"], "duplicates": [{"uid": "1", "mailbox": "INBOX", "occurrence_id": 1}]}
786	1	3	success	2026-06-17 07:15:13.698559+01	2026-06-17 07:15:13.828498+01	1	0	0	1	0	\N	{"errors": [], "safety": {"body_peek": true, "store_used": false, "imap_readonly": true, "flags_modified": false}, "imported": [], "mailboxes": ["INBOX", "INBOX.Sent"], "duplicates": [{"uid": "1", "mailbox": "INBOX", "occurrence_id": 1}]}
787	1	3	success	2026-06-17 07:20:23.937769+01	2026-06-17 07:20:24.038356+01	1	0	0	1	0	\N	{"errors": [], "safety": {"body_peek": true, "store_used": false, "imap_readonly": true, "flags_modified": false}, "imported": [], "mailboxes": ["INBOX", "INBOX.Sent"], "duplicates": [{"uid": "1", "mailbox": "INBOX", "occurrence_id": 1}]}
788	1	3	success	2026-06-17 07:25:34.155015+01	2026-06-17 07:25:34.225271+01	1	0	0	1	0	\N	{"errors": [], "safety": {"body_peek": true, "store_used": false, "imap_readonly": true, "flags_modified": false}, "imported": [], "mailboxes": ["INBOX", "INBOX.Sent"], "duplicates": [{"uid": "1", "mailbox": "INBOX", "occurrence_id": 1}]}
789	1	3	success	2026-06-17 07:30:44.322987+01	2026-06-17 07:30:44.408419+01	1	0	0	1	0	\N	{"errors": [], "safety": {"body_peek": true, "store_used": false, "imap_readonly": true, "flags_modified": false}, "imported": [], "mailboxes": ["INBOX", "INBOX.Sent"], "duplicates": [{"uid": "1", "mailbox": "INBOX", "occurrence_id": 1}]}
790	1	3	success	2026-06-17 07:35:54.473533+01	2026-06-17 07:35:54.560023+01	1	0	0	1	0	\N	{"errors": [], "safety": {"body_peek": true, "store_used": false, "imap_readonly": true, "flags_modified": false}, "imported": [], "mailboxes": ["INBOX", "INBOX.Sent"], "duplicates": [{"uid": "1", "mailbox": "INBOX", "occurrence_id": 1}]}
791	1	3	success	2026-06-17 07:41:04.623082+01	2026-06-17 07:41:04.685854+01	1	0	0	1	0	\N	{"errors": [], "safety": {"body_peek": true, "store_used": false, "imap_readonly": true, "flags_modified": false}, "imported": [], "mailboxes": ["INBOX", "INBOX.Sent"], "duplicates": [{"uid": "1", "mailbox": "INBOX", "occurrence_id": 1}]}
792	1	3	success	2026-06-17 07:46:14.741069+01	2026-06-17 07:46:14.800603+01	1	0	0	1	0	\N	{"errors": [], "safety": {"body_peek": true, "store_used": false, "imap_readonly": true, "flags_modified": false}, "imported": [], "mailboxes": ["INBOX", "INBOX.Sent"], "duplicates": [{"uid": "1", "mailbox": "INBOX", "occurrence_id": 1}]}
793	1	3	success	2026-06-17 07:51:24.856128+01	2026-06-17 07:51:24.909159+01	1	0	0	1	0	\N	{"errors": [], "safety": {"body_peek": true, "store_used": false, "imap_readonly": true, "flags_modified": false}, "imported": [], "mailboxes": ["INBOX", "INBOX.Sent"], "duplicates": [{"uid": "1", "mailbox": "INBOX", "occurrence_id": 1}]}
794	1	3	success	2026-06-17 07:56:34.968567+01	2026-06-17 07:56:35.025918+01	1	0	0	1	0	\N	{"errors": [], "safety": {"body_peek": true, "store_used": false, "imap_readonly": true, "flags_modified": false}, "imported": [], "mailboxes": ["INBOX", "INBOX.Sent"], "duplicates": [{"uid": "1", "mailbox": "INBOX", "occurrence_id": 1}]}
795	1	3	success	2026-06-17 08:01:45.079652+01	2026-06-17 08:01:45.143102+01	1	0	0	1	0	\N	{"errors": [], "safety": {"body_peek": true, "store_used": false, "imap_readonly": true, "flags_modified": false}, "imported": [], "mailboxes": ["INBOX", "INBOX.Sent"], "duplicates": [{"uid": "1", "mailbox": "INBOX", "occurrence_id": 1}]}
796	1	3	success	2026-06-17 08:06:55.196931+01	2026-06-17 08:06:55.255468+01	1	0	0	1	0	\N	{"errors": [], "safety": {"body_peek": true, "store_used": false, "imap_readonly": true, "flags_modified": false}, "imported": [], "mailboxes": ["INBOX", "INBOX.Sent"], "duplicates": [{"uid": "1", "mailbox": "INBOX", "occurrence_id": 1}]}
797	1	3	success	2026-06-17 08:12:05.312489+01	2026-06-17 08:12:05.365986+01	1	0	0	1	0	\N	{"errors": [], "safety": {"body_peek": true, "store_used": false, "imap_readonly": true, "flags_modified": false}, "imported": [], "mailboxes": ["INBOX", "INBOX.Sent"], "duplicates": [{"uid": "1", "mailbox": "INBOX", "occurrence_id": 1}]}
798	1	3	success	2026-06-17 08:17:15.440355+01	2026-06-17 08:17:15.494723+01	1	0	0	1	0	\N	{"errors": [], "safety": {"body_peek": true, "store_used": false, "imap_readonly": true, "flags_modified": false}, "imported": [], "mailboxes": ["INBOX", "INBOX.Sent"], "duplicates": [{"uid": "1", "mailbox": "INBOX", "occurrence_id": 1}]}
799	1	3	success	2026-06-17 08:22:25.590534+01	2026-06-17 08:22:25.644849+01	1	0	0	1	0	\N	{"errors": [], "safety": {"body_peek": true, "store_used": false, "imap_readonly": true, "flags_modified": false}, "imported": [], "mailboxes": ["INBOX", "INBOX.Sent"], "duplicates": [{"uid": "1", "mailbox": "INBOX", "occurrence_id": 1}]}
800	1	3	success	2026-06-17 08:27:35.752385+01	2026-06-17 08:27:35.854028+01	1	0	0	1	0	\N	{"errors": [], "safety": {"body_peek": true, "store_used": false, "imap_readonly": true, "flags_modified": false}, "imported": [], "mailboxes": ["INBOX", "INBOX.Sent"], "duplicates": [{"uid": "1", "mailbox": "INBOX", "occurrence_id": 1}]}
801	1	3	success	2026-06-17 08:32:45.952334+01	2026-06-17 08:32:46.005802+01	1	0	0	1	0	\N	{"errors": [], "safety": {"body_peek": true, "store_used": false, "imap_readonly": true, "flags_modified": false}, "imported": [], "mailboxes": ["INBOX", "INBOX.Sent"], "duplicates": [{"uid": "1", "mailbox": "INBOX", "occurrence_id": 1}]}
802	1	3	success	2026-06-17 08:37:56.103254+01	2026-06-17 08:37:56.159961+01	1	0	0	1	0	\N	{"errors": [], "safety": {"body_peek": true, "store_used": false, "imap_readonly": true, "flags_modified": false}, "imported": [], "mailboxes": ["INBOX", "INBOX.Sent"], "duplicates": [{"uid": "1", "mailbox": "INBOX", "occurrence_id": 1}]}
803	1	3	success	2026-06-17 08:43:06.269492+01	2026-06-17 08:43:06.322951+01	1	0	0	1	0	\N	{"errors": [], "safety": {"body_peek": true, "store_used": false, "imap_readonly": true, "flags_modified": false}, "imported": [], "mailboxes": ["INBOX", "INBOX.Sent"], "duplicates": [{"uid": "1", "mailbox": "INBOX", "occurrence_id": 1}]}
804	1	3	success	2026-06-17 08:48:16.421708+01	2026-06-17 08:48:16.474535+01	1	0	0	1	0	\N	{"errors": [], "safety": {"body_peek": true, "store_used": false, "imap_readonly": true, "flags_modified": false}, "imported": [], "mailboxes": ["INBOX", "INBOX.Sent"], "duplicates": [{"uid": "1", "mailbox": "INBOX", "occurrence_id": 1}]}
805	1	3	success	2026-06-17 08:53:26.563564+01	2026-06-17 08:53:26.624549+01	1	0	0	1	0	\N	{"errors": [], "safety": {"body_peek": true, "store_used": false, "imap_readonly": true, "flags_modified": false}, "imported": [], "mailboxes": ["INBOX", "INBOX.Sent"], "duplicates": [{"uid": "1", "mailbox": "INBOX", "occurrence_id": 1}]}
806	1	3	success	2026-06-17 08:58:36.712836+01	2026-06-17 08:58:36.76635+01	1	0	0	1	0	\N	{"errors": [], "safety": {"body_peek": true, "store_used": false, "imap_readonly": true, "flags_modified": false}, "imported": [], "mailboxes": ["INBOX", "INBOX.Sent"], "duplicates": [{"uid": "1", "mailbox": "INBOX", "occurrence_id": 1}]}
807	1	3	success	2026-06-17 09:03:46.857862+01	2026-06-17 09:03:46.921523+01	1	0	0	1	0	\N	{"errors": [], "safety": {"body_peek": true, "store_used": false, "imap_readonly": true, "flags_modified": false}, "imported": [], "mailboxes": ["INBOX", "INBOX.Sent"], "duplicates": [{"uid": "1", "mailbox": "INBOX", "occurrence_id": 1}]}
808	1	3	success	2026-06-17 09:08:57.021114+01	2026-06-17 09:08:57.074214+01	1	0	0	1	0	\N	{"errors": [], "safety": {"body_peek": true, "store_used": false, "imap_readonly": true, "flags_modified": false}, "imported": [], "mailboxes": ["INBOX", "INBOX.Sent"], "duplicates": [{"uid": "1", "mailbox": "INBOX", "occurrence_id": 1}]}
809	1	3	success	2026-06-17 09:14:07.168325+01	2026-06-17 09:14:07.222088+01	1	0	0	1	0	\N	{"errors": [], "safety": {"body_peek": true, "store_used": false, "imap_readonly": true, "flags_modified": false}, "imported": [], "mailboxes": ["INBOX", "INBOX.Sent"], "duplicates": [{"uid": "1", "mailbox": "INBOX", "occurrence_id": 1}]}
810	1	3	success	2026-06-17 09:19:17.319085+01	2026-06-17 09:19:17.374177+01	1	0	0	1	0	\N	{"errors": [], "safety": {"body_peek": true, "store_used": false, "imap_readonly": true, "flags_modified": false}, "imported": [], "mailboxes": ["INBOX", "INBOX.Sent"], "duplicates": [{"uid": "1", "mailbox": "INBOX", "occurrence_id": 1}]}
811	1	3	success	2026-06-17 09:24:27.466666+01	2026-06-17 09:24:27.558612+01	1	0	0	1	0	\N	{"errors": [], "safety": {"body_peek": true, "store_used": false, "imap_readonly": true, "flags_modified": false}, "imported": [], "mailboxes": ["INBOX", "INBOX.Sent"], "duplicates": [{"uid": "1", "mailbox": "INBOX", "occurrence_id": 1}]}
812	1	3	success	2026-06-17 09:29:37.671445+01	2026-06-17 09:29:37.726202+01	1	0	0	1	0	\N	{"errors": [], "safety": {"body_peek": true, "store_used": false, "imap_readonly": true, "flags_modified": false}, "imported": [], "mailboxes": ["INBOX", "INBOX.Sent"], "duplicates": [{"uid": "1", "mailbox": "INBOX", "occurrence_id": 1}]}
813	1	3	success	2026-06-17 09:34:47.824515+01	2026-06-17 09:34:47.894267+01	1	0	0	1	0	\N	{"errors": [], "safety": {"body_peek": true, "store_used": false, "imap_readonly": true, "flags_modified": false}, "imported": [], "mailboxes": ["INBOX", "INBOX.Sent"], "duplicates": [{"uid": "1", "mailbox": "INBOX", "occurrence_id": 1}]}
814	1	3	success	2026-06-17 09:39:57.981035+01	2026-06-17 09:39:58.086652+01	1	0	0	1	0	\N	{"errors": [], "safety": {"body_peek": true, "store_used": false, "imap_readonly": true, "flags_modified": false}, "imported": [], "mailboxes": ["INBOX", "INBOX.Sent"], "duplicates": [{"uid": "1", "mailbox": "INBOX", "occurrence_id": 1}]}
815	1	3	success	2026-06-17 09:45:08.197876+01	2026-06-17 09:45:08.25418+01	1	0	0	1	0	\N	{"errors": [], "safety": {"body_peek": true, "store_used": false, "imap_readonly": true, "flags_modified": false}, "imported": [], "mailboxes": ["INBOX", "INBOX.Sent"], "duplicates": [{"uid": "1", "mailbox": "INBOX", "occurrence_id": 1}]}
816	1	3	success	2026-06-17 09:50:18.358104+01	2026-06-17 09:50:18.450889+01	1	0	0	1	0	\N	{"errors": [], "safety": {"body_peek": true, "store_used": false, "imap_readonly": true, "flags_modified": false}, "imported": [], "mailboxes": ["INBOX", "INBOX.Sent"], "duplicates": [{"uid": "1", "mailbox": "INBOX", "occurrence_id": 1}]}
817	1	3	success	2026-06-17 09:55:28.551186+01	2026-06-17 09:55:28.626013+01	1	0	0	1	0	\N	{"errors": [], "safety": {"body_peek": true, "store_used": false, "imap_readonly": true, "flags_modified": false}, "imported": [], "mailboxes": ["INBOX", "INBOX.Sent"], "duplicates": [{"uid": "1", "mailbox": "INBOX", "occurrence_id": 1}]}
818	1	3	success	2026-06-17 10:00:38.746157+01	2026-06-17 10:00:38.842865+01	1	0	0	1	0	\N	{"errors": [], "safety": {"body_peek": true, "store_used": false, "imap_readonly": true, "flags_modified": false}, "imported": [], "mailboxes": ["INBOX", "INBOX.Sent"], "duplicates": [{"uid": "1", "mailbox": "INBOX", "occurrence_id": 1}]}
819	1	3	success	2026-06-17 10:05:48.936206+01	2026-06-17 10:05:48.986721+01	1	0	0	1	0	\N	{"errors": [], "safety": {"body_peek": true, "store_used": false, "imap_readonly": true, "flags_modified": false}, "imported": [], "mailboxes": ["INBOX", "INBOX.Sent"], "duplicates": [{"uid": "1", "mailbox": "INBOX", "occurrence_id": 1}]}
820	1	3	success	2026-06-17 10:10:59.098626+01	2026-06-17 10:10:59.186307+01	1	0	0	1	0	\N	{"errors": [], "safety": {"body_peek": true, "store_used": false, "imap_readonly": true, "flags_modified": false}, "imported": [], "mailboxes": ["INBOX", "INBOX.Sent"], "duplicates": [{"uid": "1", "mailbox": "INBOX", "occurrence_id": 1}]}
821	1	3	success	2026-06-17 10:16:09.289841+01	2026-06-17 10:16:09.345922+01	1	0	0	1	0	\N	{"errors": [], "safety": {"body_peek": true, "store_used": false, "imap_readonly": true, "flags_modified": false}, "imported": [], "mailboxes": ["INBOX", "INBOX.Sent"], "duplicates": [{"uid": "1", "mailbox": "INBOX", "occurrence_id": 1}]}
822	1	3	success	2026-06-17 10:21:19.446296+01	2026-06-17 10:21:19.500081+01	1	0	0	1	0	\N	{"errors": [], "safety": {"body_peek": true, "store_used": false, "imap_readonly": true, "flags_modified": false}, "imported": [], "mailboxes": ["INBOX", "INBOX.Sent"], "duplicates": [{"uid": "1", "mailbox": "INBOX", "occurrence_id": 1}]}
823	1	3	success	2026-06-17 10:26:29.600923+01	2026-06-17 10:26:29.708261+01	1	0	0	1	0	\N	{"errors": [], "safety": {"body_peek": true, "store_used": false, "imap_readonly": true, "flags_modified": false}, "imported": [], "mailboxes": ["INBOX", "INBOX.Sent"], "duplicates": [{"uid": "1", "mailbox": "INBOX", "occurrence_id": 1}]}
824	1	3	success	2026-06-17 10:31:39.800018+01	2026-06-17 10:31:39.907435+01	1	0	0	1	0	\N	{"errors": [], "safety": {"body_peek": true, "store_used": false, "imap_readonly": true, "flags_modified": false}, "imported": [], "mailboxes": ["INBOX", "INBOX.Sent"], "duplicates": [{"uid": "1", "mailbox": "INBOX", "occurrence_id": 1}]}
825	1	3	success	2026-06-17 10:36:50.01463+01	2026-06-17 10:36:50.079306+01	1	0	0	1	0	\N	{"errors": [], "safety": {"body_peek": true, "store_used": false, "imap_readonly": true, "flags_modified": false}, "imported": [], "mailboxes": ["INBOX", "INBOX.Sent"], "duplicates": [{"uid": "1", "mailbox": "INBOX", "occurrence_id": 1}]}
826	1	3	success	2026-06-17 10:42:00.185307+01	2026-06-17 10:42:00.278684+01	1	0	0	1	0	\N	{"errors": [], "safety": {"body_peek": true, "store_used": false, "imap_readonly": true, "flags_modified": false}, "imported": [], "mailboxes": ["INBOX", "INBOX.Sent"], "duplicates": [{"uid": "1", "mailbox": "INBOX", "occurrence_id": 1}]}
827	1	3	success	2026-06-17 10:47:10.375281+01	2026-06-17 10:47:10.470289+01	1	0	0	1	0	\N	{"errors": [], "safety": {"body_peek": true, "store_used": false, "imap_readonly": true, "flags_modified": false}, "imported": [], "mailboxes": ["INBOX", "INBOX.Sent"], "duplicates": [{"uid": "1", "mailbox": "INBOX", "occurrence_id": 1}]}
828	1	3	success	2026-06-17 10:52:20.564778+01	2026-06-17 10:52:20.644667+01	1	0	0	1	0	\N	{"errors": [], "safety": {"body_peek": true, "store_used": false, "imap_readonly": true, "flags_modified": false}, "imported": [], "mailboxes": ["INBOX", "INBOX.Sent"], "duplicates": [{"uid": "1", "mailbox": "INBOX", "occurrence_id": 1}]}
829	1	3	success	2026-06-17 10:57:30.749624+01	2026-06-17 10:57:30.848139+01	1	0	0	1	0	\N	{"errors": [], "safety": {"body_peek": true, "store_used": false, "imap_readonly": true, "flags_modified": false}, "imported": [], "mailboxes": ["INBOX", "INBOX.Sent"], "duplicates": [{"uid": "1", "mailbox": "INBOX", "occurrence_id": 1}]}
830	1	3	success	2026-06-17 11:02:40.927876+01	2026-06-17 11:02:41.0212+01	1	0	0	1	0	\N	{"errors": [], "safety": {"body_peek": true, "store_used": false, "imap_readonly": true, "flags_modified": false}, "imported": [], "mailboxes": ["INBOX", "INBOX.Sent"], "duplicates": [{"uid": "1", "mailbox": "INBOX", "occurrence_id": 1}]}
831	1	3	success	2026-06-17 11:07:51.125525+01	2026-06-17 11:07:51.228916+01	1	0	0	1	0	\N	{"errors": [], "safety": {"body_peek": true, "store_used": false, "imap_readonly": true, "flags_modified": false}, "imported": [], "mailboxes": ["INBOX", "INBOX.Sent"], "duplicates": [{"uid": "1", "mailbox": "INBOX", "occurrence_id": 1}]}
832	1	3	success	2026-06-17 11:13:01.328524+01	2026-06-17 11:13:01.389663+01	1	0	0	1	0	\N	{"errors": [], "safety": {"body_peek": true, "store_used": false, "imap_readonly": true, "flags_modified": false}, "imported": [], "mailboxes": ["INBOX", "INBOX.Sent"], "duplicates": [{"uid": "1", "mailbox": "INBOX", "occurrence_id": 1}]}
833	1	3	success	2026-06-17 11:18:11.474267+01	2026-06-17 11:18:11.570997+01	1	0	0	1	0	\N	{"errors": [], "safety": {"body_peek": true, "store_used": false, "imap_readonly": true, "flags_modified": false}, "imported": [], "mailboxes": ["INBOX", "INBOX.Sent"], "duplicates": [{"uid": "1", "mailbox": "INBOX", "occurrence_id": 1}]}
834	1	3	success	2026-06-17 11:23:21.668979+01	2026-06-17 11:23:21.765763+01	1	0	0	1	0	\N	{"errors": [], "safety": {"body_peek": true, "store_used": false, "imap_readonly": true, "flags_modified": false}, "imported": [], "mailboxes": ["INBOX", "INBOX.Sent"], "duplicates": [{"uid": "1", "mailbox": "INBOX", "occurrence_id": 1}]}
835	1	3	success	2026-06-17 11:28:31.867695+01	2026-06-17 11:28:31.956687+01	1	0	0	1	0	\N	{"errors": [], "safety": {"body_peek": true, "store_used": false, "imap_readonly": true, "flags_modified": false}, "imported": [], "mailboxes": ["INBOX", "INBOX.Sent"], "duplicates": [{"uid": "1", "mailbox": "INBOX", "occurrence_id": 1}]}
836	1	3	success	2026-06-17 11:33:42.063196+01	2026-06-17 11:33:42.134754+01	1	0	0	1	0	\N	{"errors": [], "safety": {"body_peek": true, "store_used": false, "imap_readonly": true, "flags_modified": false}, "imported": [], "mailboxes": ["INBOX", "INBOX.Sent"], "duplicates": [{"uid": "1", "mailbox": "INBOX", "occurrence_id": 1}]}
837	1	3	success	2026-06-17 11:38:52.242751+01	2026-06-17 11:38:52.302043+01	1	0	0	1	0	\N	{"errors": [], "safety": {"body_peek": true, "store_used": false, "imap_readonly": true, "flags_modified": false}, "imported": [], "mailboxes": ["INBOX", "INBOX.Sent"], "duplicates": [{"uid": "1", "mailbox": "INBOX", "occurrence_id": 1}]}
838	1	3	success	2026-06-17 11:44:02.409886+01	2026-06-17 11:44:02.463982+01	1	0	0	1	0	\N	{"errors": [], "safety": {"body_peek": true, "store_used": false, "imap_readonly": true, "flags_modified": false}, "imported": [], "mailboxes": ["INBOX", "INBOX.Sent"], "duplicates": [{"uid": "1", "mailbox": "INBOX", "occurrence_id": 1}]}
839	1	3	success	2026-06-17 11:49:12.596662+01	2026-06-17 11:49:12.668104+01	1	0	0	1	0	\N	{"errors": [], "safety": {"body_peek": true, "store_used": false, "imap_readonly": true, "flags_modified": false}, "imported": [], "mailboxes": ["INBOX", "INBOX.Sent"], "duplicates": [{"uid": "1", "mailbox": "INBOX", "occurrence_id": 1}]}
840	1	3	success	2026-06-17 11:54:22.774706+01	2026-06-17 11:54:22.881944+01	1	0	0	1	0	\N	{"errors": [], "safety": {"body_peek": true, "store_used": false, "imap_readonly": true, "flags_modified": false}, "imported": [], "mailboxes": ["INBOX", "INBOX.Sent"], "duplicates": [{"uid": "1", "mailbox": "INBOX", "occurrence_id": 1}]}
841	1	3	success	2026-06-17 11:59:32.988287+01	2026-06-17 11:59:33.086816+01	1	0	0	1	0	\N	{"errors": [], "safety": {"body_peek": true, "store_used": false, "imap_readonly": true, "flags_modified": false}, "imported": [], "mailboxes": ["INBOX", "INBOX.Sent"], "duplicates": [{"uid": "1", "mailbox": "INBOX", "occurrence_id": 1}]}
842	1	3	success	2026-06-17 12:04:43.188258+01	2026-06-17 12:04:43.240935+01	1	0	0	1	0	\N	{"errors": [], "safety": {"body_peek": true, "store_used": false, "imap_readonly": true, "flags_modified": false}, "imported": [], "mailboxes": ["INBOX", "INBOX.Sent"], "duplicates": [{"uid": "1", "mailbox": "INBOX", "occurrence_id": 1}]}
843	1	3	success	2026-06-17 12:09:53.330606+01	2026-06-17 12:09:53.454986+01	1	0	0	1	0	\N	{"errors": [], "safety": {"body_peek": true, "store_used": false, "imap_readonly": true, "flags_modified": false}, "imported": [], "mailboxes": ["INBOX", "INBOX.Sent"], "duplicates": [{"uid": "1", "mailbox": "INBOX", "occurrence_id": 1}]}
844	1	3	success	2026-06-17 12:15:03.551685+01	2026-06-17 12:15:03.609528+01	1	0	0	1	0	\N	{"errors": [], "safety": {"body_peek": true, "store_used": false, "imap_readonly": true, "flags_modified": false}, "imported": [], "mailboxes": ["INBOX", "INBOX.Sent"], "duplicates": [{"uid": "1", "mailbox": "INBOX", "occurrence_id": 1}]}
845	1	3	success	2026-06-17 12:20:13.713222+01	2026-06-17 12:20:13.770296+01	1	0	0	1	0	\N	{"errors": [], "safety": {"body_peek": true, "store_used": false, "imap_readonly": true, "flags_modified": false}, "imported": [], "mailboxes": ["INBOX", "INBOX.Sent"], "duplicates": [{"uid": "1", "mailbox": "INBOX", "occurrence_id": 1}]}
846	1	3	success	2026-06-17 12:25:23.862379+01	2026-06-17 12:25:23.977092+01	1	0	0	1	0	\N	{"errors": [], "safety": {"body_peek": true, "store_used": false, "imap_readonly": true, "flags_modified": false}, "imported": [], "mailboxes": ["INBOX", "INBOX.Sent"], "duplicates": [{"uid": "1", "mailbox": "INBOX", "occurrence_id": 1}]}
847	1	3	success	2026-06-17 12:30:34.072104+01	2026-06-17 12:30:34.176605+01	1	0	0	1	0	\N	{"errors": [], "safety": {"body_peek": true, "store_used": false, "imap_readonly": true, "flags_modified": false}, "imported": [], "mailboxes": ["INBOX", "INBOX.Sent"], "duplicates": [{"uid": "1", "mailbox": "INBOX", "occurrence_id": 1}]}
848	1	3	success	2026-06-17 12:35:44.280761+01	2026-06-17 12:35:44.379389+01	1	0	0	1	0	\N	{"errors": [], "safety": {"body_peek": true, "store_used": false, "imap_readonly": true, "flags_modified": false}, "imported": [], "mailboxes": ["INBOX", "INBOX.Sent"], "duplicates": [{"uid": "1", "mailbox": "INBOX", "occurrence_id": 1}]}
849	1	3	success	2026-06-17 12:40:54.492964+01	2026-06-17 12:40:54.546527+01	1	0	0	1	0	\N	{"errors": [], "safety": {"body_peek": true, "store_used": false, "imap_readonly": true, "flags_modified": false}, "imported": [], "mailboxes": ["INBOX", "INBOX.Sent"], "duplicates": [{"uid": "1", "mailbox": "INBOX", "occurrence_id": 1}]}
850	1	3	success	2026-06-17 12:46:04.652438+01	2026-06-17 12:46:04.703683+01	1	0	0	1	0	\N	{"errors": [], "safety": {"body_peek": true, "store_used": false, "imap_readonly": true, "flags_modified": false}, "imported": [], "mailboxes": ["INBOX", "INBOX.Sent"], "duplicates": [{"uid": "1", "mailbox": "INBOX", "occurrence_id": 1}]}
851	1	3	success	2026-06-17 12:51:14.815853+01	2026-06-17 12:51:14.869642+01	1	0	0	1	0	\N	{"errors": [], "safety": {"body_peek": true, "store_used": false, "imap_readonly": true, "flags_modified": false}, "imported": [], "mailboxes": ["INBOX", "INBOX.Sent"], "duplicates": [{"uid": "1", "mailbox": "INBOX", "occurrence_id": 1}]}
852	1	3	success	2026-06-17 12:56:24.985518+01	2026-06-17 12:56:25.048799+01	1	0	0	1	0	\N	{"errors": [], "safety": {"body_peek": true, "store_used": false, "imap_readonly": true, "flags_modified": false}, "imported": [], "mailboxes": ["INBOX", "INBOX.Sent"], "duplicates": [{"uid": "1", "mailbox": "INBOX", "occurrence_id": 1}]}
853	1	3	success	2026-06-17 13:01:35.13074+01	2026-06-17 13:01:35.181851+01	1	0	0	1	0	\N	{"errors": [], "safety": {"body_peek": true, "store_used": false, "imap_readonly": true, "flags_modified": false}, "imported": [], "mailboxes": ["INBOX", "INBOX.Sent"], "duplicates": [{"uid": "1", "mailbox": "INBOX", "occurrence_id": 1}]}
854	1	3	success	2026-06-17 13:06:45.294347+01	2026-06-17 13:06:45.392449+01	1	0	0	1	0	\N	{"errors": [], "safety": {"body_peek": true, "store_used": false, "imap_readonly": true, "flags_modified": false}, "imported": [], "mailboxes": ["INBOX", "INBOX.Sent"], "duplicates": [{"uid": "1", "mailbox": "INBOX", "occurrence_id": 1}]}
855	1	3	success	2026-06-17 13:11:55.492968+01	2026-06-17 13:11:55.585648+01	1	0	0	1	0	\N	{"errors": [], "safety": {"body_peek": true, "store_used": false, "imap_readonly": true, "flags_modified": false}, "imported": [], "mailboxes": ["INBOX", "INBOX.Sent"], "duplicates": [{"uid": "1", "mailbox": "INBOX", "occurrence_id": 1}]}
856	1	3	success	2026-06-17 13:17:05.687997+01	2026-06-17 13:17:05.76067+01	1	0	0	1	0	\N	{"errors": [], "safety": {"body_peek": true, "store_used": false, "imap_readonly": true, "flags_modified": false}, "imported": [], "mailboxes": ["INBOX", "INBOX.Sent"], "duplicates": [{"uid": "1", "mailbox": "INBOX", "occurrence_id": 1}]}
857	1	3	success	2026-06-17 13:22:15.882976+01	2026-06-17 13:22:15.977244+01	1	0	0	1	0	\N	{"errors": [], "safety": {"body_peek": true, "store_used": false, "imap_readonly": true, "flags_modified": false}, "imported": [], "mailboxes": ["INBOX", "INBOX.Sent"], "duplicates": [{"uid": "1", "mailbox": "INBOX", "occurrence_id": 1}]}
858	1	3	success	2026-06-17 13:27:26.064034+01	2026-06-17 13:27:26.117751+01	1	0	0	1	0	\N	{"errors": [], "safety": {"body_peek": true, "store_used": false, "imap_readonly": true, "flags_modified": false}, "imported": [], "mailboxes": ["INBOX", "INBOX.Sent"], "duplicates": [{"uid": "1", "mailbox": "INBOX", "occurrence_id": 1}]}
859	1	3	success	2026-06-17 13:32:36.195425+01	2026-06-17 13:32:36.270233+01	1	0	0	1	0	\N	{"errors": [], "safety": {"body_peek": true, "store_used": false, "imap_readonly": true, "flags_modified": false}, "imported": [], "mailboxes": ["INBOX", "INBOX.Sent"], "duplicates": [{"uid": "1", "mailbox": "INBOX", "occurrence_id": 1}]}
860	1	3	success	2026-06-17 13:37:46.349014+01	2026-06-17 13:37:46.405486+01	1	0	0	1	0	\N	{"errors": [], "safety": {"body_peek": true, "store_used": false, "imap_readonly": true, "flags_modified": false}, "imported": [], "mailboxes": ["INBOX", "INBOX.Sent"], "duplicates": [{"uid": "1", "mailbox": "INBOX", "occurrence_id": 1}]}
861	1	3	success	2026-06-17 13:42:56.518062+01	2026-06-17 13:42:56.57206+01	1	0	0	1	0	\N	{"errors": [], "safety": {"body_peek": true, "store_used": false, "imap_readonly": true, "flags_modified": false}, "imported": [], "mailboxes": ["INBOX", "INBOX.Sent"], "duplicates": [{"uid": "1", "mailbox": "INBOX", "occurrence_id": 1}]}
862	1	3	success	2026-06-17 13:48:06.658649+01	2026-06-17 13:48:06.76736+01	1	0	0	1	0	\N	{"errors": [], "safety": {"body_peek": true, "store_used": false, "imap_readonly": true, "flags_modified": false}, "imported": [], "mailboxes": ["INBOX", "INBOX.Sent"], "duplicates": [{"uid": "1", "mailbox": "INBOX", "occurrence_id": 1}]}
863	1	3	success	2026-06-17 13:53:16.84131+01	2026-06-17 13:53:16.893914+01	1	0	0	1	0	\N	{"errors": [], "safety": {"body_peek": true, "store_used": false, "imap_readonly": true, "flags_modified": false}, "imported": [], "mailboxes": ["INBOX", "INBOX.Sent"], "duplicates": [{"uid": "1", "mailbox": "INBOX", "occurrence_id": 1}]}
864	1	3	success	2026-06-17 13:58:26.953662+01	2026-06-17 13:58:27.058694+01	1	0	0	1	0	\N	{"errors": [], "safety": {"body_peek": true, "store_used": false, "imap_readonly": true, "flags_modified": false}, "imported": [], "mailboxes": ["INBOX", "INBOX.Sent"], "duplicates": [{"uid": "1", "mailbox": "INBOX", "occurrence_id": 1}]}
865	1	3	success	2026-06-17 14:03:37.164661+01	2026-06-17 14:03:37.221478+01	1	0	0	1	0	\N	{"errors": [], "safety": {"body_peek": true, "store_used": false, "imap_readonly": true, "flags_modified": false}, "imported": [], "mailboxes": ["INBOX", "INBOX.Sent"], "duplicates": [{"uid": "1", "mailbox": "INBOX", "occurrence_id": 1}]}
866	1	3	success	2026-06-17 14:08:47.314225+01	2026-06-17 14:08:47.40078+01	1	0	0	1	0	\N	{"errors": [], "safety": {"body_peek": true, "store_used": false, "imap_readonly": true, "flags_modified": false}, "imported": [], "mailboxes": ["INBOX", "INBOX.Sent"], "duplicates": [{"uid": "1", "mailbox": "INBOX", "occurrence_id": 1}]}
867	1	3	success	2026-06-17 14:13:57.495182+01	2026-06-17 14:13:57.585927+01	1	0	0	1	0	\N	{"errors": [], "safety": {"body_peek": true, "store_used": false, "imap_readonly": true, "flags_modified": false}, "imported": [], "mailboxes": ["INBOX", "INBOX.Sent"], "duplicates": [{"uid": "1", "mailbox": "INBOX", "occurrence_id": 1}]}
868	1	3	success	2026-06-17 14:19:07.698024+01	2026-06-17 14:19:07.752872+01	1	0	0	1	0	\N	{"errors": [], "safety": {"body_peek": true, "store_used": false, "imap_readonly": true, "flags_modified": false}, "imported": [], "mailboxes": ["INBOX", "INBOX.Sent"], "duplicates": [{"uid": "1", "mailbox": "INBOX", "occurrence_id": 1}]}
869	1	3	success	2026-06-17 14:24:17.859382+01	2026-06-17 14:24:17.917005+01	1	0	0	1	0	\N	{"errors": [], "safety": {"body_peek": true, "store_used": false, "imap_readonly": true, "flags_modified": false}, "imported": [], "mailboxes": ["INBOX", "INBOX.Sent"], "duplicates": [{"uid": "1", "mailbox": "INBOX", "occurrence_id": 1}]}
870	1	3	success	2026-06-17 14:29:28.026393+01	2026-06-17 14:29:28.095568+01	1	0	0	1	0	\N	{"errors": [], "safety": {"body_peek": true, "store_used": false, "imap_readonly": true, "flags_modified": false}, "imported": [], "mailboxes": ["INBOX", "INBOX.Sent"], "duplicates": [{"uid": "1", "mailbox": "INBOX", "occurrence_id": 1}]}
871	1	3	success	2026-06-17 14:34:38.186728+01	2026-06-17 14:34:38.239497+01	1	0	0	1	0	\N	{"errors": [], "safety": {"body_peek": true, "store_used": false, "imap_readonly": true, "flags_modified": false}, "imported": [], "mailboxes": ["INBOX", "INBOX.Sent"], "duplicates": [{"uid": "1", "mailbox": "INBOX", "occurrence_id": 1}]}
872	1	3	success	2026-06-17 14:39:48.340107+01	2026-06-17 14:39:48.443821+01	1	0	0	1	0	\N	{"errors": [], "safety": {"body_peek": true, "store_used": false, "imap_readonly": true, "flags_modified": false}, "imported": [], "mailboxes": ["INBOX", "INBOX.Sent"], "duplicates": [{"uid": "1", "mailbox": "INBOX", "occurrence_id": 1}]}
873	1	3	success	2026-06-17 14:44:58.556938+01	2026-06-17 14:44:58.659635+01	1	0	0	1	0	\N	{"errors": [], "safety": {"body_peek": true, "store_used": false, "imap_readonly": true, "flags_modified": false}, "imported": [], "mailboxes": ["INBOX", "INBOX.Sent"], "duplicates": [{"uid": "1", "mailbox": "INBOX", "occurrence_id": 1}]}
874	1	3	success	2026-06-17 14:50:08.765817+01	2026-06-17 14:50:08.820844+01	1	0	0	1	0	\N	{"errors": [], "safety": {"body_peek": true, "store_used": false, "imap_readonly": true, "flags_modified": false}, "imported": [], "mailboxes": ["INBOX", "INBOX.Sent"], "duplicates": [{"uid": "1", "mailbox": "INBOX", "occurrence_id": 1}]}
875	1	3	success	2026-06-17 14:55:18.927309+01	2026-06-17 14:55:19.014063+01	1	0	0	1	0	\N	{"errors": [], "safety": {"body_peek": true, "store_used": false, "imap_readonly": true, "flags_modified": false}, "imported": [], "mailboxes": ["INBOX", "INBOX.Sent"], "duplicates": [{"uid": "1", "mailbox": "INBOX", "occurrence_id": 1}]}
876	1	3	success	2026-06-17 15:00:29.126636+01	2026-06-17 15:00:29.177648+01	1	0	0	1	0	\N	{"errors": [], "safety": {"body_peek": true, "store_used": false, "imap_readonly": true, "flags_modified": false}, "imported": [], "mailboxes": ["INBOX", "INBOX.Sent"], "duplicates": [{"uid": "1", "mailbox": "INBOX", "occurrence_id": 1}]}
877	1	3	success	2026-06-17 15:05:39.282257+01	2026-06-17 15:05:39.351717+01	1	0	0	1	0	\N	{"errors": [], "safety": {"body_peek": true, "store_used": false, "imap_readonly": true, "flags_modified": false}, "imported": [], "mailboxes": ["INBOX", "INBOX.Sent"], "duplicates": [{"uid": "1", "mailbox": "INBOX", "occurrence_id": 1}]}
878	1	3	success	2026-06-17 15:10:49.430013+01	2026-06-17 15:10:49.542645+01	1	0	0	1	0	\N	{"errors": [], "safety": {"body_peek": true, "store_used": false, "imap_readonly": true, "flags_modified": false}, "imported": [], "mailboxes": ["INBOX", "INBOX.Sent"], "duplicates": [{"uid": "1", "mailbox": "INBOX", "occurrence_id": 1}]}
879	1	3	success	2026-06-17 15:15:59.653935+01	2026-06-17 15:15:59.74612+01	1	0	0	1	0	\N	{"errors": [], "safety": {"body_peek": true, "store_used": false, "imap_readonly": true, "flags_modified": false}, "imported": [], "mailboxes": ["INBOX", "INBOX.Sent"], "duplicates": [{"uid": "1", "mailbox": "INBOX", "occurrence_id": 1}]}
880	1	3	success	2026-06-17 15:21:09.857163+01	2026-06-17 15:21:09.911581+01	1	0	0	1	0	\N	{"errors": [], "safety": {"body_peek": true, "store_used": false, "imap_readonly": true, "flags_modified": false}, "imported": [], "mailboxes": ["INBOX", "INBOX.Sent"], "duplicates": [{"uid": "1", "mailbox": "INBOX", "occurrence_id": 1}]}
881	1	3	success	2026-06-17 15:26:19.999636+01	2026-06-17 15:26:20.105522+01	1	0	0	1	0	\N	{"errors": [], "safety": {"body_peek": true, "store_used": false, "imap_readonly": true, "flags_modified": false}, "imported": [], "mailboxes": ["INBOX", "INBOX.Sent"], "duplicates": [{"uid": "1", "mailbox": "INBOX", "occurrence_id": 1}]}
882	1	3	success	2026-06-17 15:31:30.213633+01	2026-06-17 15:31:30.328598+01	1	0	0	1	0	\N	{"errors": [], "safety": {"body_peek": true, "store_used": false, "imap_readonly": true, "flags_modified": false}, "imported": [], "mailboxes": ["INBOX", "INBOX.Sent"], "duplicates": [{"uid": "1", "mailbox": "INBOX", "occurrence_id": 1}]}
883	1	3	success	2026-06-17 15:36:40.453285+01	2026-06-17 15:36:40.505182+01	1	0	0	1	0	\N	{"errors": [], "safety": {"body_peek": true, "store_used": false, "imap_readonly": true, "flags_modified": false}, "imported": [], "mailboxes": ["INBOX", "INBOX.Sent"], "duplicates": [{"uid": "1", "mailbox": "INBOX", "occurrence_id": 1}]}
884	1	3	success	2026-06-17 15:41:50.595266+01	2026-06-17 15:41:50.675985+01	1	0	0	1	0	\N	{"errors": [], "safety": {"body_peek": true, "store_used": false, "imap_readonly": true, "flags_modified": false}, "imported": [], "mailboxes": ["INBOX", "INBOX.Sent"], "duplicates": [{"uid": "1", "mailbox": "INBOX", "occurrence_id": 1}]}
885	1	3	success	2026-06-17 15:47:00.778987+01	2026-06-17 15:47:00.881464+01	1	0	0	1	0	\N	{"errors": [], "safety": {"body_peek": true, "store_used": false, "imap_readonly": true, "flags_modified": false}, "imported": [], "mailboxes": ["INBOX", "INBOX.Sent"], "duplicates": [{"uid": "1", "mailbox": "INBOX", "occurrence_id": 1}]}
886	1	3	success	2026-06-17 15:52:10.993727+01	2026-06-17 15:52:11.043786+01	1	0	0	1	0	\N	{"errors": [], "safety": {"body_peek": true, "store_used": false, "imap_readonly": true, "flags_modified": false}, "imported": [], "mailboxes": ["INBOX", "INBOX.Sent"], "duplicates": [{"uid": "1", "mailbox": "INBOX", "occurrence_id": 1}]}
887	1	3	success	2026-06-17 15:57:21.164539+01	2026-06-17 15:57:21.259217+01	1	0	0	1	0	\N	{"errors": [], "safety": {"body_peek": true, "store_used": false, "imap_readonly": true, "flags_modified": false}, "imported": [], "mailboxes": ["INBOX", "INBOX.Sent"], "duplicates": [{"uid": "1", "mailbox": "INBOX", "occurrence_id": 1}]}
888	1	3	success	2026-06-17 16:02:31.360084+01	2026-06-17 16:02:31.410563+01	1	0	0	1	0	\N	{"errors": [], "safety": {"body_peek": true, "store_used": false, "imap_readonly": true, "flags_modified": false}, "imported": [], "mailboxes": ["INBOX", "INBOX.Sent"], "duplicates": [{"uid": "1", "mailbox": "INBOX", "occurrence_id": 1}]}
889	1	3	success	2026-06-17 16:07:41.515985+01	2026-06-17 16:07:41.575564+01	1	0	0	1	0	\N	{"errors": [], "safety": {"body_peek": true, "store_used": false, "imap_readonly": true, "flags_modified": false}, "imported": [], "mailboxes": ["INBOX", "INBOX.Sent"], "duplicates": [{"uid": "1", "mailbox": "INBOX", "occurrence_id": 1}]}
890	1	3	success	2026-06-17 16:12:51.678405+01	2026-06-17 16:12:51.728643+01	1	0	0	1	0	\N	{"errors": [], "safety": {"body_peek": true, "store_used": false, "imap_readonly": true, "flags_modified": false}, "imported": [], "mailboxes": ["INBOX", "INBOX.Sent"], "duplicates": [{"uid": "1", "mailbox": "INBOX", "occurrence_id": 1}]}
891	1	3	success	2026-06-17 16:18:01.828361+01	2026-06-17 16:18:01.921208+01	1	0	0	1	0	\N	{"errors": [], "safety": {"body_peek": true, "store_used": false, "imap_readonly": true, "flags_modified": false}, "imported": [], "mailboxes": ["INBOX", "INBOX.Sent"], "duplicates": [{"uid": "1", "mailbox": "INBOX", "occurrence_id": 1}]}
892	1	3	success	2026-06-17 16:23:12.031077+01	2026-06-17 16:23:12.090413+01	1	0	0	1	0	\N	{"errors": [], "safety": {"body_peek": true, "store_used": false, "imap_readonly": true, "flags_modified": false}, "imported": [], "mailboxes": ["INBOX", "INBOX.Sent"], "duplicates": [{"uid": "1", "mailbox": "INBOX", "occurrence_id": 1}]}
893	1	3	success	2026-06-17 16:28:22.196292+01	2026-06-17 16:28:22.309583+01	1	0	0	1	0	\N	{"errors": [], "safety": {"body_peek": true, "store_used": false, "imap_readonly": true, "flags_modified": false}, "imported": [], "mailboxes": ["INBOX", "INBOX.Sent"], "duplicates": [{"uid": "1", "mailbox": "INBOX", "occurrence_id": 1}]}
894	1	3	success	2026-06-17 16:33:32.411719+01	2026-06-17 16:33:32.474254+01	1	0	0	1	0	\N	{"errors": [], "safety": {"body_peek": true, "store_used": false, "imap_readonly": true, "flags_modified": false}, "imported": [], "mailboxes": ["INBOX", "INBOX.Sent"], "duplicates": [{"uid": "1", "mailbox": "INBOX", "occurrence_id": 1}]}
895	1	3	success	2026-06-17 16:38:42.581577+01	2026-06-17 16:38:42.686914+01	1	0	0	1	0	\N	{"errors": [], "safety": {"body_peek": true, "store_used": false, "imap_readonly": true, "flags_modified": false}, "imported": [], "mailboxes": ["INBOX", "INBOX.Sent"], "duplicates": [{"uid": "1", "mailbox": "INBOX", "occurrence_id": 1}]}
896	1	3	success	2026-06-17 16:43:42.775588+01	2026-06-17 16:43:42.879828+01	1	0	0	1	0	\N	{"errors": [], "safety": {"body_peek": true, "store_used": false, "imap_readonly": true, "flags_modified": false}, "imported": [], "mailboxes": ["INBOX", "INBOX.Sent"], "duplicates": [{"uid": "1", "mailbox": "INBOX", "occurrence_id": 1}]}
897	1	3	success	2026-06-17 16:48:52.987781+01	2026-06-17 16:48:53.03976+01	1	0	0	1	0	\N	{"errors": [], "safety": {"body_peek": true, "store_used": false, "imap_readonly": true, "flags_modified": false}, "imported": [], "mailboxes": ["INBOX", "INBOX.Sent"], "duplicates": [{"uid": "1", "mailbox": "INBOX", "occurrence_id": 1}]}
898	1	3	success	2026-06-17 16:54:03.133487+01	2026-06-17 16:54:03.184768+01	1	0	0	1	0	\N	{"errors": [], "safety": {"body_peek": true, "store_used": false, "imap_readonly": true, "flags_modified": false}, "imported": [], "mailboxes": ["INBOX", "INBOX.Sent"], "duplicates": [{"uid": "1", "mailbox": "INBOX", "occurrence_id": 1}]}
899	1	3	success	2026-06-17 16:59:03.296682+01	2026-06-17 16:59:03.353775+01	1	0	0	1	0	\N	{"errors": [], "safety": {"body_peek": true, "store_used": false, "imap_readonly": true, "flags_modified": false}, "imported": [], "mailboxes": ["INBOX", "INBOX.Sent"], "duplicates": [{"uid": "1", "mailbox": "INBOX", "occurrence_id": 1}]}
900	1	3	success	2026-06-17 17:04:13.463922+01	2026-06-17 17:04:13.600045+01	1	0	0	1	0	\N	{"errors": [], "safety": {"body_peek": true, "store_used": false, "imap_readonly": true, "flags_modified": false}, "imported": [], "mailboxes": ["INBOX", "INBOX.Sent"], "duplicates": [{"uid": "1", "mailbox": "INBOX", "occurrence_id": 1}]}
901	1	3	success	2026-06-17 17:09:13.71415+01	2026-06-17 17:09:13.767959+01	1	0	0	1	0	\N	{"errors": [], "safety": {"body_peek": true, "store_used": false, "imap_readonly": true, "flags_modified": false}, "imported": [], "mailboxes": ["INBOX", "INBOX.Sent"], "duplicates": [{"uid": "1", "mailbox": "INBOX", "occurrence_id": 1}]}
902	1	3	success	2026-06-17 17:14:23.874888+01	2026-06-17 17:14:24.022737+01	1	0	0	1	0	\N	{"errors": [], "safety": {"body_peek": true, "store_used": false, "imap_readonly": true, "flags_modified": false}, "imported": [], "mailboxes": ["INBOX", "INBOX.Sent"], "duplicates": [{"uid": "1", "mailbox": "INBOX", "occurrence_id": 1}]}
903	1	3	success	2026-06-17 17:19:34.149302+01	2026-06-17 17:19:34.205556+01	1	0	0	1	0	\N	{"errors": [], "safety": {"body_peek": true, "store_used": false, "imap_readonly": true, "flags_modified": false}, "imported": [], "mailboxes": ["INBOX", "INBOX.Sent"], "duplicates": [{"uid": "1", "mailbox": "INBOX", "occurrence_id": 1}]}
\.


--
-- Data for Name: personal_mail_accounts; Type: TABLE DATA; Schema: gestor_tickets; Owner: -
--

COPY gestor_tickets.personal_mail_accounts (id, public_uid, account_id, user_id, email, display_name, imap_host, imap_username, imap_password_ciphertext, imap_port, imap_use_ssl, active, last_validated_at, created_at, updated_at) FROM stdin;
1	e40729ab-993b-4c29-a149-88f03cf9a41f	3	1	usuario.personal.simulado@gestor-tickets.es	Cuenta personal simulada	simulated.local	usuario.personal.simulado@gestor-tickets.es	gAAAAABqLvRf0FD3mY4MFpkr4Qgu2Cvoa35XaZ0ggp8zIJruxImbPPiyGTN50lbzQYAzOEvM6u8rQ0h0eJPOXJ5GWaUwXX9yP2SsWJfzYNNVjS47n30vdkMngKNwonFc74Icp8MBpK6s	993	t	t	2026-06-14 19:35:11.715095+01	2026-06-14 19:35:11.715095+01	2026-06-14 19:35:11.715095+01
\.


--
-- Data for Name: personal_message_transfer_log; Type: TABLE DATA; Schema: gestor_tickets; Owner: -
--

COPY gestor_tickets.personal_message_transfer_log (id, personal_account_id, target_account_id, transferred_email_message_id, transferred_by_user_id, original_folder, original_imap_uid, original_imap_uidvalidity, original_message_id_header, transfer_reason, transferred_at) FROM stdin;
1	1	3	7	1	PERSONAL_SIMULATED	personal-sim-1	personal_simulated_uidvalidity	<178146220559.460.17970706776107867072@gestor-tickets.es>	Simulación local de transferencia personal.	2026-06-14 19:35:11.715095+01
3	1	3	8	1	PERSONAL_SIMULATED	personal-sim-2	personal_simulated_uidvalidity	<178146229434.481.6551179428778421131@gestor-tickets.es>	Simulación local de transferencia personal.	2026-06-14 19:38:14.335207+01
4	1	3	6	1	PERSONAL_SIMULATED	personal-sim-0	personal_simulated_uidvalidity	<178146211172.440.16060326031137883735@gestor-tickets.es>	Reparación de dato simulado tras validar idempotencia.	2026-06-14 19:39:11.808766+01
\.


--
-- Data for Name: system_threads; Type: TABLE DATA; Schema: gestor_tickets; Owner: -
--

COPY gestor_tickets.system_threads (id, system_thread_uid, account_id, title, subject_normalized, status, detected_from_message_id, created_reason, created_by_user_id, merged_into_thread_id, merged_at, archived_at, created_at, updated_at) FROM stdin;
1	7c69ba87-5dd4-4d16-af4a-bdf90af698e9	3	Solicitud de asistencia técnica	solicitud de asistencia técnica	active	1	Creación manual desde correo archivado.	1	\N	\N	\N	2026-06-14 12:23:36.187832+01	2026-06-14 19:38:14.356618+01
\.


--
-- Data for Name: thread_ai_syntheses; Type: TABLE DATA; Schema: gestor_tickets; Owner: -
--

COPY gestor_tickets.thread_ai_syntheses (id, thread_id, latest_email_message_id, prompt_version_id, llm_call_history_id, status, state_summary_json, short_dialogue_text, synthesized_at, error_message, created_at, updated_at) FROM stdin;
\.


--
-- Data for Name: thread_merge_history; Type: TABLE DATA; Schema: gestor_tickets; Owner: -
--

COPY gestor_tickets.thread_merge_history (id, account_id, source_thread_id, target_thread_id, merged_by_user_id, reason, details_json, merged_at) FROM stdin;
\.


--
-- Data for Name: thread_operations; Type: TABLE DATA; Schema: gestor_tickets; Owner: -
--

COPY gestor_tickets.thread_operations (id, account_id, operation_type, source_thread_id, target_thread_id, email_message_id, performed_by_user_id, reason, details_json, created_at) FROM stdin;
1	3	create_thread	\N	1	1	1	Creación manual desde correo archivado.	{"source": "mailbox_message_detail", "subject": "Solicitud de asistencia técnica", "email_message_id": 1}	2026-06-14 12:23:36.187832+01
3	3	add_email	\N	1	\N	\N	Prueba controlada Fase 36A.	{"source": "mail_ingestion", "subject": "Re: Solicitud de asistencia técnica", "email_message_id": 3}	2026-06-14 16:04:08.381581+01
4	3	add_email	\N	1	4	\N	Creación por simulación local de ingesta.	{"source": "mail_ingestion", "subject": "Re: Solicitud de asistencia técnica", "email_message_id": 4}	2026-06-14 16:17:28.145513+01
5	3	add_email	\N	1	5	\N	Creación por simulación local de ingesta.	{"source": "mail_ingestion", "subject": "Re: Solicitud de asistencia técnica", "email_message_id": 5}	2026-06-14 16:23:40.113058+01
6	3	add_email	\N	1	6	1	Creación por transferencia voluntaria desde cuenta personal simulada.	{"source": "mail_ingestion", "subject": "Re: Solicitud de asistencia técnica", "email_message_id": 6}	2026-06-14 19:35:11.737002+01
7	3	add_email	\N	1	7	1	Creación por transferencia voluntaria desde cuenta personal simulada.	{"source": "mail_ingestion", "subject": "Re: Solicitud de asistencia técnica", "email_message_id": 7}	2026-06-14 19:36:45.611557+01
8	3	add_email	\N	1	8	1	Creación por transferencia voluntaria desde cuenta personal simulada.	{"source": "mail_ingestion", "subject": "Re: Solicitud de asistencia técnica", "email_message_id": 8}	2026-06-14 19:38:14.356618+01
\.


--
-- Name: account_users_id_seq; Type: SEQUENCE SET; Schema: gestor_tickets; Owner: -
--

SELECT pg_catalog.setval('gestor_tickets.account_users_id_seq', 2, true);


--
-- Name: ai_call_history_id_seq; Type: SEQUENCE SET; Schema: gestor_tickets; Owner: -
--

SELECT pg_catalog.setval('gestor_tickets.ai_call_history_id_seq', 1, false);


--
-- Name: ai_endpoint_validation_logs_id_seq; Type: SEQUENCE SET; Schema: gestor_tickets; Owner: -
--

SELECT pg_catalog.setval('gestor_tickets.ai_endpoint_validation_logs_id_seq', 7, true);


--
-- Name: ai_llm_endpoint_models_id_seq; Type: SEQUENCE SET; Schema: gestor_tickets; Owner: -
--

SELECT pg_catalog.setval('gestor_tickets.ai_llm_endpoint_models_id_seq', 56, true);


--
-- Name: ai_llm_endpoints_id_seq; Type: SEQUENCE SET; Schema: gestor_tickets; Owner: -
--

SELECT pg_catalog.setval('gestor_tickets.ai_llm_endpoints_id_seq', 6, true);


--
-- Name: ai_prompt_templates_id_seq; Type: SEQUENCE SET; Schema: gestor_tickets; Owner: -
--

SELECT pg_catalog.setval('gestor_tickets.ai_prompt_templates_id_seq', 1, false);


--
-- Name: ai_prompt_versions_id_seq; Type: SEQUENCE SET; Schema: gestor_tickets; Owner: -
--

SELECT pg_catalog.setval('gestor_tickets.ai_prompt_versions_id_seq', 1, false);


--
-- Name: audit_log_id_seq; Type: SEQUENCE SET; Schema: gestor_tickets; Owner: -
--

SELECT pg_catalog.setval('gestor_tickets.audit_log_id_seq', 60, true);


--
-- Name: collaborative_accounts_id_seq; Type: SEQUENCE SET; Schema: gestor_tickets; Owner: -
--

SELECT pg_catalog.setval('gestor_tickets.collaborative_accounts_id_seq', 3, true);


--
-- Name: email_ai_processing_id_seq; Type: SEQUENCE SET; Schema: gestor_tickets; Owner: -
--

SELECT pg_catalog.setval('gestor_tickets.email_ai_processing_id_seq', 1, false);


--
-- Name: email_attachments_id_seq; Type: SEQUENCE SET; Schema: gestor_tickets; Owner: -
--

SELECT pg_catalog.setval('gestor_tickets.email_attachments_id_seq', 1, false);


--
-- Name: email_message_occurrences_id_seq; Type: SEQUENCE SET; Schema: gestor_tickets; Owner: -
--

SELECT pg_catalog.setval('gestor_tickets.email_message_occurrences_id_seq', 9, true);


--
-- Name: email_messages_id_seq; Type: SEQUENCE SET; Schema: gestor_tickets; Owner: -
--

SELECT pg_catalog.setval('gestor_tickets.email_messages_id_seq', 8, true);


--
-- Name: email_recipients_id_seq; Type: SEQUENCE SET; Schema: gestor_tickets; Owner: -
--

SELECT pg_catalog.setval('gestor_tickets.email_recipients_id_seq', 8, true);


--
-- Name: email_thread_members_id_seq; Type: SEQUENCE SET; Schema: gestor_tickets; Owner: -
--

SELECT pg_catalog.setval('gestor_tickets.email_thread_members_id_seq', 8, true);


--
-- Name: glpi_api_operations_id_seq; Type: SEQUENCE SET; Schema: gestor_tickets; Owner: -
--

SELECT pg_catalog.setval('gestor_tickets.glpi_api_operations_id_seq', 11, true);


--
-- Name: glpi_instances_id_seq; Type: SEQUENCE SET; Schema: gestor_tickets; Owner: -
--

SELECT pg_catalog.setval('gestor_tickets.glpi_instances_id_seq', 3, true);


--
-- Name: glpi_ticket_cache_id_seq; Type: SEQUENCE SET; Schema: gestor_tickets; Owner: -
--

SELECT pg_catalog.setval('gestor_tickets.glpi_ticket_cache_id_seq', 3, true);


--
-- Name: glpi_ticket_email_links_id_seq; Type: SEQUENCE SET; Schema: gestor_tickets; Owner: -
--

SELECT pg_catalog.setval('gestor_tickets.glpi_ticket_email_links_id_seq', 7, true);


--
-- Name: glpi_ticket_relationships_id_seq; Type: SEQUENCE SET; Schema: gestor_tickets; Owner: -
--

SELECT pg_catalog.setval('gestor_tickets.glpi_ticket_relationships_id_seq', 1, false);


--
-- Name: glpi_ticket_thread_links_id_seq; Type: SEQUENCE SET; Schema: gestor_tickets; Owner: -
--

SELECT pg_catalog.setval('gestor_tickets.glpi_ticket_thread_links_id_seq', 1, true);


--
-- Name: mail_ingestion_jobs_id_seq; Type: SEQUENCE SET; Schema: gestor_tickets; Owner: -
--

SELECT pg_catalog.setval('gestor_tickets.mail_ingestion_jobs_id_seq', 1, true);


--
-- Name: mail_ingestion_runs_id_seq; Type: SEQUENCE SET; Schema: gestor_tickets; Owner: -
--

SELECT pg_catalog.setval('gestor_tickets.mail_ingestion_runs_id_seq', 903, true);


--
-- Name: personal_mail_accounts_id_seq; Type: SEQUENCE SET; Schema: gestor_tickets; Owner: -
--

SELECT pg_catalog.setval('gestor_tickets.personal_mail_accounts_id_seq', 1, true);


--
-- Name: personal_message_transfer_log_id_seq; Type: SEQUENCE SET; Schema: gestor_tickets; Owner: -
--

SELECT pg_catalog.setval('gestor_tickets.personal_message_transfer_log_id_seq', 4, true);


--
-- Name: system_threads_id_seq; Type: SEQUENCE SET; Schema: gestor_tickets; Owner: -
--

SELECT pg_catalog.setval('gestor_tickets.system_threads_id_seq', 1, true);


--
-- Name: thread_ai_syntheses_id_seq; Type: SEQUENCE SET; Schema: gestor_tickets; Owner: -
--

SELECT pg_catalog.setval('gestor_tickets.thread_ai_syntheses_id_seq', 1, false);


--
-- Name: thread_merge_history_id_seq; Type: SEQUENCE SET; Schema: gestor_tickets; Owner: -
--

SELECT pg_catalog.setval('gestor_tickets.thread_merge_history_id_seq', 1, false);


--
-- Name: thread_operations_id_seq; Type: SEQUENCE SET; Schema: gestor_tickets; Owner: -
--

SELECT pg_catalog.setval('gestor_tickets.thread_operations_id_seq', 8, true);


--
-- Name: account_users account_users_login_identifier_key; Type: CONSTRAINT; Schema: gestor_tickets; Owner: -
--

ALTER TABLE ONLY gestor_tickets.account_users
    ADD CONSTRAINT account_users_login_identifier_key UNIQUE (login_identifier);


--
-- Name: account_users account_users_pkey; Type: CONSTRAINT; Schema: gestor_tickets; Owner: -
--

ALTER TABLE ONLY gestor_tickets.account_users
    ADD CONSTRAINT account_users_pkey PRIMARY KEY (id);


--
-- Name: account_users account_users_public_uid_key; Type: CONSTRAINT; Schema: gestor_tickets; Owner: -
--

ALTER TABLE ONLY gestor_tickets.account_users
    ADD CONSTRAINT account_users_public_uid_key UNIQUE (public_uid);


--
-- Name: ai_call_history ai_call_history_pkey; Type: CONSTRAINT; Schema: gestor_tickets; Owner: -
--

ALTER TABLE ONLY gestor_tickets.ai_call_history
    ADD CONSTRAINT ai_call_history_pkey PRIMARY KEY (id);


--
-- Name: ai_endpoint_validation_logs ai_endpoint_validation_logs_pkey; Type: CONSTRAINT; Schema: gestor_tickets; Owner: -
--

ALTER TABLE ONLY gestor_tickets.ai_endpoint_validation_logs
    ADD CONSTRAINT ai_endpoint_validation_logs_pkey PRIMARY KEY (id);


--
-- Name: ai_llm_endpoint_models ai_llm_endpoint_models_pkey; Type: CONSTRAINT; Schema: gestor_tickets; Owner: -
--

ALTER TABLE ONLY gestor_tickets.ai_llm_endpoint_models
    ADD CONSTRAINT ai_llm_endpoint_models_pkey PRIMARY KEY (id);


--
-- Name: ai_llm_endpoints ai_llm_endpoints_pkey; Type: CONSTRAINT; Schema: gestor_tickets; Owner: -
--

ALTER TABLE ONLY gestor_tickets.ai_llm_endpoints
    ADD CONSTRAINT ai_llm_endpoints_pkey PRIMARY KEY (id);


--
-- Name: ai_llm_endpoints ai_llm_endpoints_public_uid_key; Type: CONSTRAINT; Schema: gestor_tickets; Owner: -
--

ALTER TABLE ONLY gestor_tickets.ai_llm_endpoints
    ADD CONSTRAINT ai_llm_endpoints_public_uid_key UNIQUE (public_uid);


--
-- Name: ai_prompt_templates ai_prompt_templates_key_key; Type: CONSTRAINT; Schema: gestor_tickets; Owner: -
--

ALTER TABLE ONLY gestor_tickets.ai_prompt_templates
    ADD CONSTRAINT ai_prompt_templates_key_key UNIQUE (key);


--
-- Name: ai_prompt_templates ai_prompt_templates_pkey; Type: CONSTRAINT; Schema: gestor_tickets; Owner: -
--

ALTER TABLE ONLY gestor_tickets.ai_prompt_templates
    ADD CONSTRAINT ai_prompt_templates_pkey PRIMARY KEY (id);


--
-- Name: ai_prompt_versions ai_prompt_versions_pkey; Type: CONSTRAINT; Schema: gestor_tickets; Owner: -
--

ALTER TABLE ONLY gestor_tickets.ai_prompt_versions
    ADD CONSTRAINT ai_prompt_versions_pkey PRIMARY KEY (id);


--
-- Name: ai_prompt_versions ai_prompt_versions_template_id_version_number_key; Type: CONSTRAINT; Schema: gestor_tickets; Owner: -
--

ALTER TABLE ONLY gestor_tickets.ai_prompt_versions
    ADD CONSTRAINT ai_prompt_versions_template_id_version_number_key UNIQUE (template_id, version_number);


--
-- Name: app_settings app_settings_pkey; Type: CONSTRAINT; Schema: gestor_tickets; Owner: -
--

ALTER TABLE ONLY gestor_tickets.app_settings
    ADD CONSTRAINT app_settings_pkey PRIMARY KEY (id);


--
-- Name: audit_log audit_log_pkey; Type: CONSTRAINT; Schema: gestor_tickets; Owner: -
--

ALTER TABLE ONLY gestor_tickets.audit_log
    ADD CONSTRAINT audit_log_pkey PRIMARY KEY (id);


--
-- Name: collaborative_accounts collaborative_accounts_email_key; Type: CONSTRAINT; Schema: gestor_tickets; Owner: -
--

ALTER TABLE ONLY gestor_tickets.collaborative_accounts
    ADD CONSTRAINT collaborative_accounts_email_key UNIQUE (email);


--
-- Name: collaborative_accounts collaborative_accounts_pkey; Type: CONSTRAINT; Schema: gestor_tickets; Owner: -
--

ALTER TABLE ONLY gestor_tickets.collaborative_accounts
    ADD CONSTRAINT collaborative_accounts_pkey PRIMARY KEY (id);


--
-- Name: collaborative_accounts collaborative_accounts_public_uid_key; Type: CONSTRAINT; Schema: gestor_tickets; Owner: -
--

ALTER TABLE ONLY gestor_tickets.collaborative_accounts
    ADD CONSTRAINT collaborative_accounts_public_uid_key UNIQUE (public_uid);


--
-- Name: email_ai_processing email_ai_processing_email_message_id_prompt_version_id_key; Type: CONSTRAINT; Schema: gestor_tickets; Owner: -
--

ALTER TABLE ONLY gestor_tickets.email_ai_processing
    ADD CONSTRAINT email_ai_processing_email_message_id_prompt_version_id_key UNIQUE (email_message_id, prompt_version_id);


--
-- Name: email_ai_processing email_ai_processing_pkey; Type: CONSTRAINT; Schema: gestor_tickets; Owner: -
--

ALTER TABLE ONLY gestor_tickets.email_ai_processing
    ADD CONSTRAINT email_ai_processing_pkey PRIMARY KEY (id);


--
-- Name: email_attachments email_attachments_pkey; Type: CONSTRAINT; Schema: gestor_tickets; Owner: -
--

ALTER TABLE ONLY gestor_tickets.email_attachments
    ADD CONSTRAINT email_attachments_pkey PRIMARY KEY (id);


--
-- Name: email_message_occurrences email_message_occurrences_pkey; Type: CONSTRAINT; Schema: gestor_tickets; Owner: -
--

ALTER TABLE ONLY gestor_tickets.email_message_occurrences
    ADD CONSTRAINT email_message_occurrences_pkey PRIMARY KEY (id);


--
-- Name: email_message_occurrences email_message_occurrences_source_mailbox_email_folder_name__key; Type: CONSTRAINT; Schema: gestor_tickets; Owner: -
--

ALTER TABLE ONLY gestor_tickets.email_message_occurrences
    ADD CONSTRAINT email_message_occurrences_source_mailbox_email_folder_name__key UNIQUE (source_mailbox_email, folder_name, imap_uidvalidity, imap_uid);


--
-- Name: email_messages email_messages_eml_storage_path_key; Type: CONSTRAINT; Schema: gestor_tickets; Owner: -
--

ALTER TABLE ONLY gestor_tickets.email_messages
    ADD CONSTRAINT email_messages_eml_storage_path_key UNIQUE (eml_storage_path);


--
-- Name: email_messages email_messages_pkey; Type: CONSTRAINT; Schema: gestor_tickets; Owner: -
--

ALTER TABLE ONLY gestor_tickets.email_messages
    ADD CONSTRAINT email_messages_pkey PRIMARY KEY (id);


--
-- Name: email_messages email_messages_system_uid_key; Type: CONSTRAINT; Schema: gestor_tickets; Owner: -
--

ALTER TABLE ONLY gestor_tickets.email_messages
    ADD CONSTRAINT email_messages_system_uid_key UNIQUE (system_uid);


--
-- Name: email_recipients email_recipients_pkey; Type: CONSTRAINT; Schema: gestor_tickets; Owner: -
--

ALTER TABLE ONLY gestor_tickets.email_recipients
    ADD CONSTRAINT email_recipients_pkey PRIMARY KEY (id);


--
-- Name: email_thread_members email_thread_members_pkey; Type: CONSTRAINT; Schema: gestor_tickets; Owner: -
--

ALTER TABLE ONLY gestor_tickets.email_thread_members
    ADD CONSTRAINT email_thread_members_pkey PRIMARY KEY (id);


--
-- Name: glpi_api_operations glpi_api_operations_pkey; Type: CONSTRAINT; Schema: gestor_tickets; Owner: -
--

ALTER TABLE ONLY gestor_tickets.glpi_api_operations
    ADD CONSTRAINT glpi_api_operations_pkey PRIMARY KEY (id);


--
-- Name: glpi_instances glpi_instances_base_url_key; Type: CONSTRAINT; Schema: gestor_tickets; Owner: -
--

ALTER TABLE ONLY gestor_tickets.glpi_instances
    ADD CONSTRAINT glpi_instances_base_url_key UNIQUE (base_url);


--
-- Name: glpi_instances glpi_instances_pkey; Type: CONSTRAINT; Schema: gestor_tickets; Owner: -
--

ALTER TABLE ONLY gestor_tickets.glpi_instances
    ADD CONSTRAINT glpi_instances_pkey PRIMARY KEY (id);


--
-- Name: glpi_ticket_cache glpi_ticket_cache_glpi_instance_id_glpi_ticket_id_key; Type: CONSTRAINT; Schema: gestor_tickets; Owner: -
--

ALTER TABLE ONLY gestor_tickets.glpi_ticket_cache
    ADD CONSTRAINT glpi_ticket_cache_glpi_instance_id_glpi_ticket_id_key UNIQUE (glpi_instance_id, glpi_ticket_id);


--
-- Name: glpi_ticket_cache glpi_ticket_cache_pkey; Type: CONSTRAINT; Schema: gestor_tickets; Owner: -
--

ALTER TABLE ONLY gestor_tickets.glpi_ticket_cache
    ADD CONSTRAINT glpi_ticket_cache_pkey PRIMARY KEY (id);


--
-- Name: glpi_ticket_email_links glpi_ticket_email_links_pkey; Type: CONSTRAINT; Schema: gestor_tickets; Owner: -
--

ALTER TABLE ONLY gestor_tickets.glpi_ticket_email_links
    ADD CONSTRAINT glpi_ticket_email_links_pkey PRIMARY KEY (id);


--
-- Name: glpi_ticket_relationships glpi_ticket_relationships_pkey; Type: CONSTRAINT; Schema: gestor_tickets; Owner: -
--

ALTER TABLE ONLY gestor_tickets.glpi_ticket_relationships
    ADD CONSTRAINT glpi_ticket_relationships_pkey PRIMARY KEY (id);


--
-- Name: glpi_ticket_relationships glpi_ticket_relationships_source_ticket_cache_id_target_tic_key; Type: CONSTRAINT; Schema: gestor_tickets; Owner: -
--

ALTER TABLE ONLY gestor_tickets.glpi_ticket_relationships
    ADD CONSTRAINT glpi_ticket_relationships_source_ticket_cache_id_target_tic_key UNIQUE (source_ticket_cache_id, target_ticket_cache_id, relationship_type);


--
-- Name: glpi_ticket_thread_links glpi_ticket_thread_links_pkey; Type: CONSTRAINT; Schema: gestor_tickets; Owner: -
--

ALTER TABLE ONLY gestor_tickets.glpi_ticket_thread_links
    ADD CONSTRAINT glpi_ticket_thread_links_pkey PRIMARY KEY (id);


--
-- Name: mail_ingestion_jobs mail_ingestion_jobs_account_id_key; Type: CONSTRAINT; Schema: gestor_tickets; Owner: -
--

ALTER TABLE ONLY gestor_tickets.mail_ingestion_jobs
    ADD CONSTRAINT mail_ingestion_jobs_account_id_key UNIQUE (account_id);


--
-- Name: mail_ingestion_jobs mail_ingestion_jobs_pkey; Type: CONSTRAINT; Schema: gestor_tickets; Owner: -
--

ALTER TABLE ONLY gestor_tickets.mail_ingestion_jobs
    ADD CONSTRAINT mail_ingestion_jobs_pkey PRIMARY KEY (id);


--
-- Name: mail_ingestion_runs mail_ingestion_runs_pkey; Type: CONSTRAINT; Schema: gestor_tickets; Owner: -
--

ALTER TABLE ONLY gestor_tickets.mail_ingestion_runs
    ADD CONSTRAINT mail_ingestion_runs_pkey PRIMARY KEY (id);


--
-- Name: personal_mail_accounts personal_mail_accounts_pkey; Type: CONSTRAINT; Schema: gestor_tickets; Owner: -
--

ALTER TABLE ONLY gestor_tickets.personal_mail_accounts
    ADD CONSTRAINT personal_mail_accounts_pkey PRIMARY KEY (id);


--
-- Name: personal_mail_accounts personal_mail_accounts_public_uid_key; Type: CONSTRAINT; Schema: gestor_tickets; Owner: -
--

ALTER TABLE ONLY gestor_tickets.personal_mail_accounts
    ADD CONSTRAINT personal_mail_accounts_public_uid_key UNIQUE (public_uid);


--
-- Name: personal_mail_accounts personal_mail_accounts_user_id_email_key; Type: CONSTRAINT; Schema: gestor_tickets; Owner: -
--

ALTER TABLE ONLY gestor_tickets.personal_mail_accounts
    ADD CONSTRAINT personal_mail_accounts_user_id_email_key UNIQUE (user_id, email);


--
-- Name: personal_message_transfer_log personal_message_transfer_log_personal_account_id_original__key; Type: CONSTRAINT; Schema: gestor_tickets; Owner: -
--

ALTER TABLE ONLY gestor_tickets.personal_message_transfer_log
    ADD CONSTRAINT personal_message_transfer_log_personal_account_id_original__key UNIQUE (personal_account_id, original_folder, original_imap_uidvalidity, original_imap_uid);


--
-- Name: personal_message_transfer_log personal_message_transfer_log_pkey; Type: CONSTRAINT; Schema: gestor_tickets; Owner: -
--

ALTER TABLE ONLY gestor_tickets.personal_message_transfer_log
    ADD CONSTRAINT personal_message_transfer_log_pkey PRIMARY KEY (id);


--
-- Name: system_threads system_threads_pkey; Type: CONSTRAINT; Schema: gestor_tickets; Owner: -
--

ALTER TABLE ONLY gestor_tickets.system_threads
    ADD CONSTRAINT system_threads_pkey PRIMARY KEY (id);


--
-- Name: system_threads system_threads_system_thread_uid_key; Type: CONSTRAINT; Schema: gestor_tickets; Owner: -
--

ALTER TABLE ONLY gestor_tickets.system_threads
    ADD CONSTRAINT system_threads_system_thread_uid_key UNIQUE (system_thread_uid);


--
-- Name: thread_ai_syntheses thread_ai_syntheses_pkey; Type: CONSTRAINT; Schema: gestor_tickets; Owner: -
--

ALTER TABLE ONLY gestor_tickets.thread_ai_syntheses
    ADD CONSTRAINT thread_ai_syntheses_pkey PRIMARY KEY (id);


--
-- Name: thread_ai_syntheses thread_ai_syntheses_thread_id_latest_email_message_id_promp_key; Type: CONSTRAINT; Schema: gestor_tickets; Owner: -
--

ALTER TABLE ONLY gestor_tickets.thread_ai_syntheses
    ADD CONSTRAINT thread_ai_syntheses_thread_id_latest_email_message_id_promp_key UNIQUE (thread_id, latest_email_message_id, prompt_version_id);


--
-- Name: thread_merge_history thread_merge_history_pkey; Type: CONSTRAINT; Schema: gestor_tickets; Owner: -
--

ALTER TABLE ONLY gestor_tickets.thread_merge_history
    ADD CONSTRAINT thread_merge_history_pkey PRIMARY KEY (id);


--
-- Name: thread_merge_history thread_merge_history_source_thread_id_key; Type: CONSTRAINT; Schema: gestor_tickets; Owner: -
--

ALTER TABLE ONLY gestor_tickets.thread_merge_history
    ADD CONSTRAINT thread_merge_history_source_thread_id_key UNIQUE (source_thread_id);


--
-- Name: thread_operations thread_operations_pkey; Type: CONSTRAINT; Schema: gestor_tickets; Owner: -
--

ALTER TABLE ONLY gestor_tickets.thread_operations
    ADD CONSTRAINT thread_operations_pkey PRIMARY KEY (id);


--
-- Name: ai_llm_endpoint_models uq_ai_llm_endpoint_models_endpoint_model; Type: CONSTRAINT; Schema: gestor_tickets; Owner: -
--

ALTER TABLE ONLY gestor_tickets.ai_llm_endpoint_models
    ADD CONSTRAINT uq_ai_llm_endpoint_models_endpoint_model UNIQUE (endpoint_id, model_id);


--
-- Name: ix_account_users_account_role; Type: INDEX; Schema: gestor_tickets; Owner: -
--

CREATE INDEX ix_account_users_account_role ON gestor_tickets.account_users USING btree (account_id, role);


--
-- Name: ix_account_users_status; Type: INDEX; Schema: gestor_tickets; Owner: -
--

CREATE INDEX ix_account_users_status ON gestor_tickets.account_users USING btree (status);


--
-- Name: ix_ai_call_history_account_created; Type: INDEX; Schema: gestor_tickets; Owner: -
--

CREATE INDEX ix_ai_call_history_account_created ON gestor_tickets.ai_call_history USING btree (account_id, created_at DESC);


--
-- Name: ix_ai_call_history_related_email; Type: INDEX; Schema: gestor_tickets; Owner: -
--

CREATE INDEX ix_ai_call_history_related_email ON gestor_tickets.ai_call_history USING btree (related_email_message_id);


--
-- Name: ix_ai_call_history_related_thread; Type: INDEX; Schema: gestor_tickets; Owner: -
--

CREATE INDEX ix_ai_call_history_related_thread ON gestor_tickets.ai_call_history USING btree (related_thread_id);


--
-- Name: ix_ai_endpoint_validation_logs_endpoint_created; Type: INDEX; Schema: gestor_tickets; Owner: -
--

CREATE INDEX ix_ai_endpoint_validation_logs_endpoint_created ON gestor_tickets.ai_endpoint_validation_logs USING btree (endpoint_id, created_at DESC);


--
-- Name: ix_ai_llm_endpoint_models_endpoint_seen; Type: INDEX; Schema: gestor_tickets; Owner: -
--

CREATE INDEX ix_ai_llm_endpoint_models_endpoint_seen ON gestor_tickets.ai_llm_endpoint_models USING btree (endpoint_id, last_seen_at DESC);


--
-- Name: ix_ai_llm_endpoints_active; Type: INDEX; Schema: gestor_tickets; Owner: -
--

CREATE INDEX ix_ai_llm_endpoints_active ON gestor_tickets.ai_llm_endpoints USING btree (is_active, provider_kind);


--
-- Name: ix_audit_log_account_created; Type: INDEX; Schema: gestor_tickets; Owner: -
--

CREATE INDEX ix_audit_log_account_created ON gestor_tickets.audit_log USING btree (account_id, created_at DESC);


--
-- Name: ix_audit_log_actor_created; Type: INDEX; Schema: gestor_tickets; Owner: -
--

CREATE INDEX ix_audit_log_actor_created ON gestor_tickets.audit_log USING btree (actor_user_id, created_at DESC);


--
-- Name: ix_audit_log_entity; Type: INDEX; Schema: gestor_tickets; Owner: -
--

CREATE INDEX ix_audit_log_entity ON gestor_tickets.audit_log USING btree (entity_type, entity_id);


--
-- Name: ix_email_ai_processing_status; Type: INDEX; Schema: gestor_tickets; Owner: -
--

CREATE INDEX ix_email_ai_processing_status ON gestor_tickets.email_ai_processing USING btree (status, created_at);


--
-- Name: ix_email_attachments_message; Type: INDEX; Schema: gestor_tickets; Owner: -
--

CREATE INDEX ix_email_attachments_message ON gestor_tickets.email_attachments USING btree (email_message_id);


--
-- Name: ix_email_messages_account_date; Type: INDEX; Schema: gestor_tickets; Owner: -
--

CREATE INDEX ix_email_messages_account_date ON gestor_tickets.email_messages USING btree (account_id, sent_at DESC NULLS LAST, id DESC);


--
-- Name: ix_email_messages_account_subject; Type: INDEX; Schema: gestor_tickets; Owner: -
--

CREATE INDEX ix_email_messages_account_subject ON gestor_tickets.email_messages USING btree (account_id, subject_normalized);


--
-- Name: ix_email_messages_from_email; Type: INDEX; Schema: gestor_tickets; Owner: -
--

CREATE INDEX ix_email_messages_from_email ON gestor_tickets.email_messages USING btree (from_email);


--
-- Name: ix_email_occurrences_account_folder; Type: INDEX; Schema: gestor_tickets; Owner: -
--

CREATE INDEX ix_email_occurrences_account_folder ON gestor_tickets.email_message_occurrences USING btree (account_id, folder_name, imap_uid);


--
-- Name: ix_email_occurrences_email; Type: INDEX; Schema: gestor_tickets; Owner: -
--

CREATE INDEX ix_email_occurrences_email ON gestor_tickets.email_message_occurrences USING btree (email_message_id);


--
-- Name: ix_email_recipients_email; Type: INDEX; Schema: gestor_tickets; Owner: -
--

CREATE INDEX ix_email_recipients_email ON gestor_tickets.email_recipients USING btree (email);


--
-- Name: ix_email_recipients_message; Type: INDEX; Schema: gestor_tickets; Owner: -
--

CREATE INDEX ix_email_recipients_message ON gestor_tickets.email_recipients USING btree (email_message_id, recipient_type, "position");


--
-- Name: ix_email_thread_members_email; Type: INDEX; Schema: gestor_tickets; Owner: -
--

CREATE INDEX ix_email_thread_members_email ON gestor_tickets.email_thread_members USING btree (email_message_id);


--
-- Name: ix_email_thread_members_thread_position; Type: INDEX; Schema: gestor_tickets; Owner: -
--

CREATE INDEX ix_email_thread_members_thread_position ON gestor_tickets.email_thread_members USING btree (thread_id, position_asc, email_message_id);


--
-- Name: ix_glpi_api_operations_account_created; Type: INDEX; Schema: gestor_tickets; Owner: -
--

CREATE INDEX ix_glpi_api_operations_account_created ON gestor_tickets.glpi_api_operations USING btree (account_id, created_at DESC);


--
-- Name: ix_glpi_api_operations_ticket; Type: INDEX; Schema: gestor_tickets; Owner: -
--

CREATE INDEX ix_glpi_api_operations_ticket ON gestor_tickets.glpi_api_operations USING btree (glpi_ticket_cache_id, created_at DESC);


--
-- Name: ix_glpi_ticket_cache_account; Type: INDEX; Schema: gestor_tickets; Owner: -
--

CREATE INDEX ix_glpi_ticket_cache_account ON gestor_tickets.glpi_ticket_cache USING btree (account_id, glpi_ticket_id);


--
-- Name: ix_glpi_ticket_cache_status; Type: INDEX; Schema: gestor_tickets; Owner: -
--

CREATE INDEX ix_glpi_ticket_cache_status ON gestor_tickets.glpi_ticket_cache USING btree (account_id, status);


--
-- Name: ix_mail_ingestion_jobs_due; Type: INDEX; Schema: gestor_tickets; Owner: -
--

CREATE INDEX ix_mail_ingestion_jobs_due ON gestor_tickets.mail_ingestion_jobs USING btree (status, next_run_at);


--
-- Name: ix_mail_ingestion_runs_account_started; Type: INDEX; Schema: gestor_tickets; Owner: -
--

CREATE INDEX ix_mail_ingestion_runs_account_started ON gestor_tickets.mail_ingestion_runs USING btree (account_id, started_at DESC);


--
-- Name: ix_personal_mail_accounts_account_user; Type: INDEX; Schema: gestor_tickets; Owner: -
--

CREATE INDEX ix_personal_mail_accounts_account_user ON gestor_tickets.personal_mail_accounts USING btree (account_id, user_id);


--
-- Name: ix_system_threads_account_status; Type: INDEX; Schema: gestor_tickets; Owner: -
--

CREATE INDEX ix_system_threads_account_status ON gestor_tickets.system_threads USING btree (account_id, status, updated_at DESC);


--
-- Name: ix_system_threads_subject; Type: INDEX; Schema: gestor_tickets; Owner: -
--

CREATE INDEX ix_system_threads_subject ON gestor_tickets.system_threads USING btree (account_id, subject_normalized);


--
-- Name: ix_thread_ai_syntheses_thread; Type: INDEX; Schema: gestor_tickets; Owner: -
--

CREATE INDEX ix_thread_ai_syntheses_thread ON gestor_tickets.thread_ai_syntheses USING btree (thread_id, synthesized_at DESC);


--
-- Name: ix_thread_operations_account_created; Type: INDEX; Schema: gestor_tickets; Owner: -
--

CREATE INDEX ix_thread_operations_account_created ON gestor_tickets.thread_operations USING btree (account_id, created_at DESC);


--
-- Name: ix_thread_operations_thread; Type: INDEX; Schema: gestor_tickets; Owner: -
--

CREATE INDEX ix_thread_operations_thread ON gestor_tickets.thread_operations USING btree (source_thread_id, target_thread_id);


--
-- Name: ix_ticket_email_links_email; Type: INDEX; Schema: gestor_tickets; Owner: -
--

CREATE INDEX ix_ticket_email_links_email ON gestor_tickets.glpi_ticket_email_links USING btree (email_message_id, status);


--
-- Name: ix_ticket_email_links_ticket; Type: INDEX; Schema: gestor_tickets; Owner: -
--

CREATE INDEX ix_ticket_email_links_ticket ON gestor_tickets.glpi_ticket_email_links USING btree (glpi_ticket_cache_id, status);


--
-- Name: ix_ticket_thread_links_thread; Type: INDEX; Schema: gestor_tickets; Owner: -
--

CREATE INDEX ix_ticket_thread_links_thread ON gestor_tickets.glpi_ticket_thread_links USING btree (thread_id, status);


--
-- Name: ix_ticket_thread_links_ticket; Type: INDEX; Schema: gestor_tickets; Owner: -
--

CREATE INDEX ix_ticket_thread_links_ticket ON gestor_tickets.glpi_ticket_thread_links USING btree (glpi_ticket_cache_id, status);


--
-- Name: uq_account_users_username_per_account; Type: INDEX; Schema: gestor_tickets; Owner: -
--

CREATE UNIQUE INDEX uq_account_users_username_per_account ON gestor_tickets.account_users USING btree (account_id, username_local) WHERE (username_local IS NOT NULL);


--
-- Name: uq_active_ticket_email_link; Type: INDEX; Schema: gestor_tickets; Owner: -
--

CREATE UNIQUE INDEX uq_active_ticket_email_link ON gestor_tickets.glpi_ticket_email_links USING btree (glpi_ticket_cache_id, email_message_id) WHERE (status = 'active'::gestor_tickets.glpi_link_status);


--
-- Name: uq_active_ticket_thread_link; Type: INDEX; Schema: gestor_tickets; Owner: -
--

CREATE UNIQUE INDEX uq_active_ticket_thread_link ON gestor_tickets.glpi_ticket_thread_links USING btree (glpi_ticket_cache_id, thread_id) WHERE (status = 'active'::gestor_tickets.glpi_link_status);


--
-- Name: uq_ai_llm_endpoints_one_default; Type: INDEX; Schema: gestor_tickets; Owner: -
--

CREATE UNIQUE INDEX uq_ai_llm_endpoints_one_default ON gestor_tickets.ai_llm_endpoints USING btree (is_default) WHERE (is_default IS TRUE);


--
-- Name: uq_ai_prompt_one_active_version; Type: INDEX; Schema: gestor_tickets; Owner: -
--

CREATE UNIQUE INDEX uq_ai_prompt_one_active_version ON gestor_tickets.ai_prompt_versions USING btree (template_id) WHERE (is_active = true);


--
-- Name: uq_email_messages_account_eml_sha256; Type: INDEX; Schema: gestor_tickets; Owner: -
--

CREATE UNIQUE INDEX uq_email_messages_account_eml_sha256 ON gestor_tickets.email_messages USING btree (account_id, eml_sha256);


--
-- Name: uq_email_messages_account_message_id_header; Type: INDEX; Schema: gestor_tickets; Owner: -
--

CREATE UNIQUE INDEX uq_email_messages_account_message_id_header ON gestor_tickets.email_messages USING btree (account_id, message_id_header) WHERE (message_id_header IS NOT NULL);


--
-- Name: uq_email_one_active_thread; Type: INDEX; Schema: gestor_tickets; Owner: -
--

CREATE UNIQUE INDEX uq_email_one_active_thread ON gestor_tickets.email_thread_members USING btree (email_message_id) WHERE (status = 'active'::gestor_tickets.thread_member_status);


--
-- Name: uq_thread_active_email_once; Type: INDEX; Schema: gestor_tickets; Owner: -
--

CREATE UNIQUE INDEX uq_thread_active_email_once ON gestor_tickets.email_thread_members USING btree (thread_id, email_message_id) WHERE (status = 'active'::gestor_tickets.thread_member_status);


--
-- Name: account_users account_users_account_id_fkey; Type: FK CONSTRAINT; Schema: gestor_tickets; Owner: -
--

ALTER TABLE ONLY gestor_tickets.account_users
    ADD CONSTRAINT account_users_account_id_fkey FOREIGN KEY (account_id) REFERENCES gestor_tickets.collaborative_accounts(id) ON DELETE CASCADE;


--
-- Name: account_users account_users_created_by_user_id_fkey; Type: FK CONSTRAINT; Schema: gestor_tickets; Owner: -
--

ALTER TABLE ONLY gestor_tickets.account_users
    ADD CONSTRAINT account_users_created_by_user_id_fkey FOREIGN KEY (created_by_user_id) REFERENCES gestor_tickets.account_users(id) ON DELETE SET NULL;


--
-- Name: ai_call_history ai_call_history_account_id_fkey; Type: FK CONSTRAINT; Schema: gestor_tickets; Owner: -
--

ALTER TABLE ONLY gestor_tickets.ai_call_history
    ADD CONSTRAINT ai_call_history_account_id_fkey FOREIGN KEY (account_id) REFERENCES gestor_tickets.collaborative_accounts(id) ON DELETE SET NULL;


--
-- Name: ai_call_history ai_call_history_created_by_user_id_fkey; Type: FK CONSTRAINT; Schema: gestor_tickets; Owner: -
--

ALTER TABLE ONLY gestor_tickets.ai_call_history
    ADD CONSTRAINT ai_call_history_created_by_user_id_fkey FOREIGN KEY (created_by_user_id) REFERENCES gestor_tickets.account_users(id) ON DELETE SET NULL;


--
-- Name: ai_call_history ai_call_history_prompt_version_id_fkey; Type: FK CONSTRAINT; Schema: gestor_tickets; Owner: -
--

ALTER TABLE ONLY gestor_tickets.ai_call_history
    ADD CONSTRAINT ai_call_history_prompt_version_id_fkey FOREIGN KEY (prompt_version_id) REFERENCES gestor_tickets.ai_prompt_versions(id) ON DELETE SET NULL;


--
-- Name: ai_call_history ai_call_history_related_email_message_id_fkey; Type: FK CONSTRAINT; Schema: gestor_tickets; Owner: -
--

ALTER TABLE ONLY gestor_tickets.ai_call_history
    ADD CONSTRAINT ai_call_history_related_email_message_id_fkey FOREIGN KEY (related_email_message_id) REFERENCES gestor_tickets.email_messages(id) ON DELETE SET NULL;


--
-- Name: ai_call_history ai_call_history_related_glpi_ticket_cache_id_fkey; Type: FK CONSTRAINT; Schema: gestor_tickets; Owner: -
--

ALTER TABLE ONLY gestor_tickets.ai_call_history
    ADD CONSTRAINT ai_call_history_related_glpi_ticket_cache_id_fkey FOREIGN KEY (related_glpi_ticket_cache_id) REFERENCES gestor_tickets.glpi_ticket_cache(id) ON DELETE SET NULL;


--
-- Name: ai_call_history ai_call_history_related_thread_id_fkey; Type: FK CONSTRAINT; Schema: gestor_tickets; Owner: -
--

ALTER TABLE ONLY gestor_tickets.ai_call_history
    ADD CONSTRAINT ai_call_history_related_thread_id_fkey FOREIGN KEY (related_thread_id) REFERENCES gestor_tickets.system_threads(id) ON DELETE SET NULL;


--
-- Name: ai_endpoint_validation_logs ai_endpoint_validation_logs_endpoint_id_fkey; Type: FK CONSTRAINT; Schema: gestor_tickets; Owner: -
--

ALTER TABLE ONLY gestor_tickets.ai_endpoint_validation_logs
    ADD CONSTRAINT ai_endpoint_validation_logs_endpoint_id_fkey FOREIGN KEY (endpoint_id) REFERENCES gestor_tickets.ai_llm_endpoints(id) ON DELETE CASCADE;


--
-- Name: ai_llm_endpoint_models ai_llm_endpoint_models_endpoint_id_fkey; Type: FK CONSTRAINT; Schema: gestor_tickets; Owner: -
--

ALTER TABLE ONLY gestor_tickets.ai_llm_endpoint_models
    ADD CONSTRAINT ai_llm_endpoint_models_endpoint_id_fkey FOREIGN KEY (endpoint_id) REFERENCES gestor_tickets.ai_llm_endpoints(id) ON DELETE CASCADE;


--
-- Name: ai_prompt_versions ai_prompt_versions_created_by_user_id_fkey; Type: FK CONSTRAINT; Schema: gestor_tickets; Owner: -
--

ALTER TABLE ONLY gestor_tickets.ai_prompt_versions
    ADD CONSTRAINT ai_prompt_versions_created_by_user_id_fkey FOREIGN KEY (created_by_user_id) REFERENCES gestor_tickets.account_users(id) ON DELETE SET NULL;


--
-- Name: ai_prompt_versions ai_prompt_versions_template_id_fkey; Type: FK CONSTRAINT; Schema: gestor_tickets; Owner: -
--

ALTER TABLE ONLY gestor_tickets.ai_prompt_versions
    ADD CONSTRAINT ai_prompt_versions_template_id_fkey FOREIGN KEY (template_id) REFERENCES gestor_tickets.ai_prompt_templates(id) ON DELETE CASCADE;


--
-- Name: audit_log audit_log_account_id_fkey; Type: FK CONSTRAINT; Schema: gestor_tickets; Owner: -
--

ALTER TABLE ONLY gestor_tickets.audit_log
    ADD CONSTRAINT audit_log_account_id_fkey FOREIGN KEY (account_id) REFERENCES gestor_tickets.collaborative_accounts(id) ON DELETE SET NULL;


--
-- Name: audit_log audit_log_actor_user_id_fkey; Type: FK CONSTRAINT; Schema: gestor_tickets; Owner: -
--

ALTER TABLE ONLY gestor_tickets.audit_log
    ADD CONSTRAINT audit_log_actor_user_id_fkey FOREIGN KEY (actor_user_id) REFERENCES gestor_tickets.account_users(id) ON DELETE SET NULL;


--
-- Name: collaborative_accounts collaborative_accounts_glpi_instance_id_fkey; Type: FK CONSTRAINT; Schema: gestor_tickets; Owner: -
--

ALTER TABLE ONLY gestor_tickets.collaborative_accounts
    ADD CONSTRAINT collaborative_accounts_glpi_instance_id_fkey FOREIGN KEY (glpi_instance_id) REFERENCES gestor_tickets.glpi_instances(id) ON DELETE SET NULL;


--
-- Name: email_ai_processing email_ai_processing_email_message_id_fkey; Type: FK CONSTRAINT; Schema: gestor_tickets; Owner: -
--

ALTER TABLE ONLY gestor_tickets.email_ai_processing
    ADD CONSTRAINT email_ai_processing_email_message_id_fkey FOREIGN KEY (email_message_id) REFERENCES gestor_tickets.email_messages(id) ON DELETE CASCADE;


--
-- Name: email_ai_processing email_ai_processing_llm_call_history_id_fkey; Type: FK CONSTRAINT; Schema: gestor_tickets; Owner: -
--

ALTER TABLE ONLY gestor_tickets.email_ai_processing
    ADD CONSTRAINT email_ai_processing_llm_call_history_id_fkey FOREIGN KEY (llm_call_history_id) REFERENCES gestor_tickets.ai_call_history(id) ON DELETE SET NULL;


--
-- Name: email_ai_processing email_ai_processing_prompt_version_id_fkey; Type: FK CONSTRAINT; Schema: gestor_tickets; Owner: -
--

ALTER TABLE ONLY gestor_tickets.email_ai_processing
    ADD CONSTRAINT email_ai_processing_prompt_version_id_fkey FOREIGN KEY (prompt_version_id) REFERENCES gestor_tickets.ai_prompt_versions(id) ON DELETE SET NULL;


--
-- Name: email_attachments email_attachments_email_message_id_fkey; Type: FK CONSTRAINT; Schema: gestor_tickets; Owner: -
--

ALTER TABLE ONLY gestor_tickets.email_attachments
    ADD CONSTRAINT email_attachments_email_message_id_fkey FOREIGN KEY (email_message_id) REFERENCES gestor_tickets.email_messages(id) ON DELETE CASCADE;


--
-- Name: email_message_occurrences email_message_occurrences_account_id_fkey; Type: FK CONSTRAINT; Schema: gestor_tickets; Owner: -
--

ALTER TABLE ONLY gestor_tickets.email_message_occurrences
    ADD CONSTRAINT email_message_occurrences_account_id_fkey FOREIGN KEY (account_id) REFERENCES gestor_tickets.collaborative_accounts(id) ON DELETE CASCADE;


--
-- Name: email_message_occurrences email_message_occurrences_email_message_id_fkey; Type: FK CONSTRAINT; Schema: gestor_tickets; Owner: -
--

ALTER TABLE ONLY gestor_tickets.email_message_occurrences
    ADD CONSTRAINT email_message_occurrences_email_message_id_fkey FOREIGN KEY (email_message_id) REFERENCES gestor_tickets.email_messages(id) ON DELETE CASCADE;


--
-- Name: email_message_occurrences email_message_occurrences_ingestion_run_id_fkey; Type: FK CONSTRAINT; Schema: gestor_tickets; Owner: -
--

ALTER TABLE ONLY gestor_tickets.email_message_occurrences
    ADD CONSTRAINT email_message_occurrences_ingestion_run_id_fkey FOREIGN KEY (ingestion_run_id) REFERENCES gestor_tickets.mail_ingestion_runs(id) ON DELETE SET NULL;


--
-- Name: email_messages email_messages_account_id_fkey; Type: FK CONSTRAINT; Schema: gestor_tickets; Owner: -
--

ALTER TABLE ONLY gestor_tickets.email_messages
    ADD CONSTRAINT email_messages_account_id_fkey FOREIGN KEY (account_id) REFERENCES gestor_tickets.collaborative_accounts(id) ON DELETE CASCADE;


--
-- Name: email_messages email_messages_imported_from_personal_account_id_fkey; Type: FK CONSTRAINT; Schema: gestor_tickets; Owner: -
--

ALTER TABLE ONLY gestor_tickets.email_messages
    ADD CONSTRAINT email_messages_imported_from_personal_account_id_fkey FOREIGN KEY (imported_from_personal_account_id) REFERENCES gestor_tickets.personal_mail_accounts(id) ON DELETE SET NULL;


--
-- Name: email_messages email_messages_transferred_by_user_id_fkey; Type: FK CONSTRAINT; Schema: gestor_tickets; Owner: -
--

ALTER TABLE ONLY gestor_tickets.email_messages
    ADD CONSTRAINT email_messages_transferred_by_user_id_fkey FOREIGN KEY (transferred_by_user_id) REFERENCES gestor_tickets.account_users(id) ON DELETE SET NULL;


--
-- Name: email_recipients email_recipients_email_message_id_fkey; Type: FK CONSTRAINT; Schema: gestor_tickets; Owner: -
--

ALTER TABLE ONLY gestor_tickets.email_recipients
    ADD CONSTRAINT email_recipients_email_message_id_fkey FOREIGN KEY (email_message_id) REFERENCES gestor_tickets.email_messages(id) ON DELETE CASCADE;


--
-- Name: email_thread_members email_thread_members_added_by_user_id_fkey; Type: FK CONSTRAINT; Schema: gestor_tickets; Owner: -
--

ALTER TABLE ONLY gestor_tickets.email_thread_members
    ADD CONSTRAINT email_thread_members_added_by_user_id_fkey FOREIGN KEY (added_by_user_id) REFERENCES gestor_tickets.account_users(id) ON DELETE SET NULL;


--
-- Name: email_thread_members email_thread_members_email_message_id_fkey; Type: FK CONSTRAINT; Schema: gestor_tickets; Owner: -
--

ALTER TABLE ONLY gestor_tickets.email_thread_members
    ADD CONSTRAINT email_thread_members_email_message_id_fkey FOREIGN KEY (email_message_id) REFERENCES gestor_tickets.email_messages(id) ON DELETE CASCADE;


--
-- Name: email_thread_members email_thread_members_moved_from_thread_id_fkey; Type: FK CONSTRAINT; Schema: gestor_tickets; Owner: -
--

ALTER TABLE ONLY gestor_tickets.email_thread_members
    ADD CONSTRAINT email_thread_members_moved_from_thread_id_fkey FOREIGN KEY (moved_from_thread_id) REFERENCES gestor_tickets.system_threads(id) ON DELETE SET NULL;


--
-- Name: email_thread_members email_thread_members_moved_to_thread_id_fkey; Type: FK CONSTRAINT; Schema: gestor_tickets; Owner: -
--

ALTER TABLE ONLY gestor_tickets.email_thread_members
    ADD CONSTRAINT email_thread_members_moved_to_thread_id_fkey FOREIGN KEY (moved_to_thread_id) REFERENCES gestor_tickets.system_threads(id) ON DELETE SET NULL;


--
-- Name: email_thread_members email_thread_members_removed_by_user_id_fkey; Type: FK CONSTRAINT; Schema: gestor_tickets; Owner: -
--

ALTER TABLE ONLY gestor_tickets.email_thread_members
    ADD CONSTRAINT email_thread_members_removed_by_user_id_fkey FOREIGN KEY (removed_by_user_id) REFERENCES gestor_tickets.account_users(id) ON DELETE SET NULL;


--
-- Name: email_thread_members email_thread_members_thread_id_fkey; Type: FK CONSTRAINT; Schema: gestor_tickets; Owner: -
--

ALTER TABLE ONLY gestor_tickets.email_thread_members
    ADD CONSTRAINT email_thread_members_thread_id_fkey FOREIGN KEY (thread_id) REFERENCES gestor_tickets.system_threads(id) ON DELETE CASCADE;


--
-- Name: glpi_api_operations glpi_api_operations_account_id_fkey; Type: FK CONSTRAINT; Schema: gestor_tickets; Owner: -
--

ALTER TABLE ONLY gestor_tickets.glpi_api_operations
    ADD CONSTRAINT glpi_api_operations_account_id_fkey FOREIGN KEY (account_id) REFERENCES gestor_tickets.collaborative_accounts(id) ON DELETE CASCADE;


--
-- Name: glpi_api_operations glpi_api_operations_glpi_instance_id_fkey; Type: FK CONSTRAINT; Schema: gestor_tickets; Owner: -
--

ALTER TABLE ONLY gestor_tickets.glpi_api_operations
    ADD CONSTRAINT glpi_api_operations_glpi_instance_id_fkey FOREIGN KEY (glpi_instance_id) REFERENCES gestor_tickets.glpi_instances(id) ON DELETE SET NULL;


--
-- Name: glpi_api_operations glpi_api_operations_glpi_ticket_cache_id_fkey; Type: FK CONSTRAINT; Schema: gestor_tickets; Owner: -
--

ALTER TABLE ONLY gestor_tickets.glpi_api_operations
    ADD CONSTRAINT glpi_api_operations_glpi_ticket_cache_id_fkey FOREIGN KEY (glpi_ticket_cache_id) REFERENCES gestor_tickets.glpi_ticket_cache(id) ON DELETE SET NULL;


--
-- Name: glpi_api_operations glpi_api_operations_requested_by_user_id_fkey; Type: FK CONSTRAINT; Schema: gestor_tickets; Owner: -
--

ALTER TABLE ONLY gestor_tickets.glpi_api_operations
    ADD CONSTRAINT glpi_api_operations_requested_by_user_id_fkey FOREIGN KEY (requested_by_user_id) REFERENCES gestor_tickets.account_users(id) ON DELETE SET NULL;


--
-- Name: glpi_ticket_cache glpi_ticket_cache_account_id_fkey; Type: FK CONSTRAINT; Schema: gestor_tickets; Owner: -
--

ALTER TABLE ONLY gestor_tickets.glpi_ticket_cache
    ADD CONSTRAINT glpi_ticket_cache_account_id_fkey FOREIGN KEY (account_id) REFERENCES gestor_tickets.collaborative_accounts(id) ON DELETE CASCADE;


--
-- Name: glpi_ticket_cache glpi_ticket_cache_glpi_instance_id_fkey; Type: FK CONSTRAINT; Schema: gestor_tickets; Owner: -
--

ALTER TABLE ONLY gestor_tickets.glpi_ticket_cache
    ADD CONSTRAINT glpi_ticket_cache_glpi_instance_id_fkey FOREIGN KEY (glpi_instance_id) REFERENCES gestor_tickets.glpi_instances(id) ON DELETE SET NULL;


--
-- Name: glpi_ticket_email_links glpi_ticket_email_links_account_id_fkey; Type: FK CONSTRAINT; Schema: gestor_tickets; Owner: -
--

ALTER TABLE ONLY gestor_tickets.glpi_ticket_email_links
    ADD CONSTRAINT glpi_ticket_email_links_account_id_fkey FOREIGN KEY (account_id) REFERENCES gestor_tickets.collaborative_accounts(id) ON DELETE CASCADE;


--
-- Name: glpi_ticket_email_links glpi_ticket_email_links_created_by_user_id_fkey; Type: FK CONSTRAINT; Schema: gestor_tickets; Owner: -
--

ALTER TABLE ONLY gestor_tickets.glpi_ticket_email_links
    ADD CONSTRAINT glpi_ticket_email_links_created_by_user_id_fkey FOREIGN KEY (created_by_user_id) REFERENCES gestor_tickets.account_users(id) ON DELETE SET NULL;


--
-- Name: glpi_ticket_email_links glpi_ticket_email_links_detached_by_user_id_fkey; Type: FK CONSTRAINT; Schema: gestor_tickets; Owner: -
--

ALTER TABLE ONLY gestor_tickets.glpi_ticket_email_links
    ADD CONSTRAINT glpi_ticket_email_links_detached_by_user_id_fkey FOREIGN KEY (detached_by_user_id) REFERENCES gestor_tickets.account_users(id) ON DELETE SET NULL;


--
-- Name: glpi_ticket_email_links glpi_ticket_email_links_email_message_id_fkey; Type: FK CONSTRAINT; Schema: gestor_tickets; Owner: -
--

ALTER TABLE ONLY gestor_tickets.glpi_ticket_email_links
    ADD CONSTRAINT glpi_ticket_email_links_email_message_id_fkey FOREIGN KEY (email_message_id) REFERENCES gestor_tickets.email_messages(id) ON DELETE CASCADE;


--
-- Name: glpi_ticket_email_links glpi_ticket_email_links_glpi_ticket_cache_id_fkey; Type: FK CONSTRAINT; Schema: gestor_tickets; Owner: -
--

ALTER TABLE ONLY gestor_tickets.glpi_ticket_email_links
    ADD CONSTRAINT glpi_ticket_email_links_glpi_ticket_cache_id_fkey FOREIGN KEY (glpi_ticket_cache_id) REFERENCES gestor_tickets.glpi_ticket_cache(id) ON DELETE CASCADE;


--
-- Name: glpi_ticket_relationships glpi_ticket_relationships_account_id_fkey; Type: FK CONSTRAINT; Schema: gestor_tickets; Owner: -
--

ALTER TABLE ONLY gestor_tickets.glpi_ticket_relationships
    ADD CONSTRAINT glpi_ticket_relationships_account_id_fkey FOREIGN KEY (account_id) REFERENCES gestor_tickets.collaborative_accounts(id) ON DELETE CASCADE;


--
-- Name: glpi_ticket_relationships glpi_ticket_relationships_created_by_user_id_fkey; Type: FK CONSTRAINT; Schema: gestor_tickets; Owner: -
--

ALTER TABLE ONLY gestor_tickets.glpi_ticket_relationships
    ADD CONSTRAINT glpi_ticket_relationships_created_by_user_id_fkey FOREIGN KEY (created_by_user_id) REFERENCES gestor_tickets.account_users(id) ON DELETE SET NULL;


--
-- Name: glpi_ticket_relationships glpi_ticket_relationships_source_ticket_cache_id_fkey; Type: FK CONSTRAINT; Schema: gestor_tickets; Owner: -
--

ALTER TABLE ONLY gestor_tickets.glpi_ticket_relationships
    ADD CONSTRAINT glpi_ticket_relationships_source_ticket_cache_id_fkey FOREIGN KEY (source_ticket_cache_id) REFERENCES gestor_tickets.glpi_ticket_cache(id) ON DELETE CASCADE;


--
-- Name: glpi_ticket_relationships glpi_ticket_relationships_target_ticket_cache_id_fkey; Type: FK CONSTRAINT; Schema: gestor_tickets; Owner: -
--

ALTER TABLE ONLY gestor_tickets.glpi_ticket_relationships
    ADD CONSTRAINT glpi_ticket_relationships_target_ticket_cache_id_fkey FOREIGN KEY (target_ticket_cache_id) REFERENCES gestor_tickets.glpi_ticket_cache(id) ON DELETE CASCADE;


--
-- Name: glpi_ticket_thread_links glpi_ticket_thread_links_account_id_fkey; Type: FK CONSTRAINT; Schema: gestor_tickets; Owner: -
--

ALTER TABLE ONLY gestor_tickets.glpi_ticket_thread_links
    ADD CONSTRAINT glpi_ticket_thread_links_account_id_fkey FOREIGN KEY (account_id) REFERENCES gestor_tickets.collaborative_accounts(id) ON DELETE CASCADE;


--
-- Name: glpi_ticket_thread_links glpi_ticket_thread_links_created_by_user_id_fkey; Type: FK CONSTRAINT; Schema: gestor_tickets; Owner: -
--

ALTER TABLE ONLY gestor_tickets.glpi_ticket_thread_links
    ADD CONSTRAINT glpi_ticket_thread_links_created_by_user_id_fkey FOREIGN KEY (created_by_user_id) REFERENCES gestor_tickets.account_users(id) ON DELETE SET NULL;


--
-- Name: glpi_ticket_thread_links glpi_ticket_thread_links_detached_by_user_id_fkey; Type: FK CONSTRAINT; Schema: gestor_tickets; Owner: -
--

ALTER TABLE ONLY gestor_tickets.glpi_ticket_thread_links
    ADD CONSTRAINT glpi_ticket_thread_links_detached_by_user_id_fkey FOREIGN KEY (detached_by_user_id) REFERENCES gestor_tickets.account_users(id) ON DELETE SET NULL;


--
-- Name: glpi_ticket_thread_links glpi_ticket_thread_links_glpi_ticket_cache_id_fkey; Type: FK CONSTRAINT; Schema: gestor_tickets; Owner: -
--

ALTER TABLE ONLY gestor_tickets.glpi_ticket_thread_links
    ADD CONSTRAINT glpi_ticket_thread_links_glpi_ticket_cache_id_fkey FOREIGN KEY (glpi_ticket_cache_id) REFERENCES gestor_tickets.glpi_ticket_cache(id) ON DELETE CASCADE;


--
-- Name: glpi_ticket_thread_links glpi_ticket_thread_links_thread_id_fkey; Type: FK CONSTRAINT; Schema: gestor_tickets; Owner: -
--

ALTER TABLE ONLY gestor_tickets.glpi_ticket_thread_links
    ADD CONSTRAINT glpi_ticket_thread_links_thread_id_fkey FOREIGN KEY (thread_id) REFERENCES gestor_tickets.system_threads(id) ON DELETE CASCADE;


--
-- Name: mail_ingestion_jobs mail_ingestion_jobs_account_id_fkey; Type: FK CONSTRAINT; Schema: gestor_tickets; Owner: -
--

ALTER TABLE ONLY gestor_tickets.mail_ingestion_jobs
    ADD CONSTRAINT mail_ingestion_jobs_account_id_fkey FOREIGN KEY (account_id) REFERENCES gestor_tickets.collaborative_accounts(id) ON DELETE CASCADE;


--
-- Name: mail_ingestion_jobs mail_ingestion_jobs_created_by_user_id_fkey; Type: FK CONSTRAINT; Schema: gestor_tickets; Owner: -
--

ALTER TABLE ONLY gestor_tickets.mail_ingestion_jobs
    ADD CONSTRAINT mail_ingestion_jobs_created_by_user_id_fkey FOREIGN KEY (created_by_user_id) REFERENCES gestor_tickets.account_users(id) ON DELETE SET NULL;


--
-- Name: mail_ingestion_jobs mail_ingestion_jobs_updated_by_user_id_fkey; Type: FK CONSTRAINT; Schema: gestor_tickets; Owner: -
--

ALTER TABLE ONLY gestor_tickets.mail_ingestion_jobs
    ADD CONSTRAINT mail_ingestion_jobs_updated_by_user_id_fkey FOREIGN KEY (updated_by_user_id) REFERENCES gestor_tickets.account_users(id) ON DELETE SET NULL;


--
-- Name: mail_ingestion_runs mail_ingestion_runs_account_id_fkey; Type: FK CONSTRAINT; Schema: gestor_tickets; Owner: -
--

ALTER TABLE ONLY gestor_tickets.mail_ingestion_runs
    ADD CONSTRAINT mail_ingestion_runs_account_id_fkey FOREIGN KEY (account_id) REFERENCES gestor_tickets.collaborative_accounts(id) ON DELETE CASCADE;


--
-- Name: mail_ingestion_runs mail_ingestion_runs_job_id_fkey; Type: FK CONSTRAINT; Schema: gestor_tickets; Owner: -
--

ALTER TABLE ONLY gestor_tickets.mail_ingestion_runs
    ADD CONSTRAINT mail_ingestion_runs_job_id_fkey FOREIGN KEY (job_id) REFERENCES gestor_tickets.mail_ingestion_jobs(id) ON DELETE CASCADE;


--
-- Name: personal_mail_accounts personal_mail_accounts_account_id_fkey; Type: FK CONSTRAINT; Schema: gestor_tickets; Owner: -
--

ALTER TABLE ONLY gestor_tickets.personal_mail_accounts
    ADD CONSTRAINT personal_mail_accounts_account_id_fkey FOREIGN KEY (account_id) REFERENCES gestor_tickets.collaborative_accounts(id) ON DELETE CASCADE;


--
-- Name: personal_mail_accounts personal_mail_accounts_user_id_fkey; Type: FK CONSTRAINT; Schema: gestor_tickets; Owner: -
--

ALTER TABLE ONLY gestor_tickets.personal_mail_accounts
    ADD CONSTRAINT personal_mail_accounts_user_id_fkey FOREIGN KEY (user_id) REFERENCES gestor_tickets.account_users(id) ON DELETE CASCADE;


--
-- Name: personal_message_transfer_log personal_message_transfer_log_personal_account_id_fkey; Type: FK CONSTRAINT; Schema: gestor_tickets; Owner: -
--

ALTER TABLE ONLY gestor_tickets.personal_message_transfer_log
    ADD CONSTRAINT personal_message_transfer_log_personal_account_id_fkey FOREIGN KEY (personal_account_id) REFERENCES gestor_tickets.personal_mail_accounts(id) ON DELETE RESTRICT;


--
-- Name: personal_message_transfer_log personal_message_transfer_log_target_account_id_fkey; Type: FK CONSTRAINT; Schema: gestor_tickets; Owner: -
--

ALTER TABLE ONLY gestor_tickets.personal_message_transfer_log
    ADD CONSTRAINT personal_message_transfer_log_target_account_id_fkey FOREIGN KEY (target_account_id) REFERENCES gestor_tickets.collaborative_accounts(id) ON DELETE CASCADE;


--
-- Name: personal_message_transfer_log personal_message_transfer_log_transferred_by_user_id_fkey; Type: FK CONSTRAINT; Schema: gestor_tickets; Owner: -
--

ALTER TABLE ONLY gestor_tickets.personal_message_transfer_log
    ADD CONSTRAINT personal_message_transfer_log_transferred_by_user_id_fkey FOREIGN KEY (transferred_by_user_id) REFERENCES gestor_tickets.account_users(id) ON DELETE RESTRICT;


--
-- Name: personal_message_transfer_log personal_message_transfer_log_transferred_email_message_id_fkey; Type: FK CONSTRAINT; Schema: gestor_tickets; Owner: -
--

ALTER TABLE ONLY gestor_tickets.personal_message_transfer_log
    ADD CONSTRAINT personal_message_transfer_log_transferred_email_message_id_fkey FOREIGN KEY (transferred_email_message_id) REFERENCES gestor_tickets.email_messages(id) ON DELETE CASCADE;


--
-- Name: system_threads system_threads_account_id_fkey; Type: FK CONSTRAINT; Schema: gestor_tickets; Owner: -
--

ALTER TABLE ONLY gestor_tickets.system_threads
    ADD CONSTRAINT system_threads_account_id_fkey FOREIGN KEY (account_id) REFERENCES gestor_tickets.collaborative_accounts(id) ON DELETE CASCADE;


--
-- Name: system_threads system_threads_created_by_user_id_fkey; Type: FK CONSTRAINT; Schema: gestor_tickets; Owner: -
--

ALTER TABLE ONLY gestor_tickets.system_threads
    ADD CONSTRAINT system_threads_created_by_user_id_fkey FOREIGN KEY (created_by_user_id) REFERENCES gestor_tickets.account_users(id) ON DELETE SET NULL;


--
-- Name: system_threads system_threads_detected_from_message_id_fkey; Type: FK CONSTRAINT; Schema: gestor_tickets; Owner: -
--

ALTER TABLE ONLY gestor_tickets.system_threads
    ADD CONSTRAINT system_threads_detected_from_message_id_fkey FOREIGN KEY (detected_from_message_id) REFERENCES gestor_tickets.email_messages(id) ON DELETE SET NULL;


--
-- Name: system_threads system_threads_merged_into_thread_id_fkey; Type: FK CONSTRAINT; Schema: gestor_tickets; Owner: -
--

ALTER TABLE ONLY gestor_tickets.system_threads
    ADD CONSTRAINT system_threads_merged_into_thread_id_fkey FOREIGN KEY (merged_into_thread_id) REFERENCES gestor_tickets.system_threads(id) ON DELETE SET NULL;


--
-- Name: thread_ai_syntheses thread_ai_syntheses_latest_email_message_id_fkey; Type: FK CONSTRAINT; Schema: gestor_tickets; Owner: -
--

ALTER TABLE ONLY gestor_tickets.thread_ai_syntheses
    ADD CONSTRAINT thread_ai_syntheses_latest_email_message_id_fkey FOREIGN KEY (latest_email_message_id) REFERENCES gestor_tickets.email_messages(id) ON DELETE SET NULL;


--
-- Name: thread_ai_syntheses thread_ai_syntheses_llm_call_history_id_fkey; Type: FK CONSTRAINT; Schema: gestor_tickets; Owner: -
--

ALTER TABLE ONLY gestor_tickets.thread_ai_syntheses
    ADD CONSTRAINT thread_ai_syntheses_llm_call_history_id_fkey FOREIGN KEY (llm_call_history_id) REFERENCES gestor_tickets.ai_call_history(id) ON DELETE SET NULL;


--
-- Name: thread_ai_syntheses thread_ai_syntheses_prompt_version_id_fkey; Type: FK CONSTRAINT; Schema: gestor_tickets; Owner: -
--

ALTER TABLE ONLY gestor_tickets.thread_ai_syntheses
    ADD CONSTRAINT thread_ai_syntheses_prompt_version_id_fkey FOREIGN KEY (prompt_version_id) REFERENCES gestor_tickets.ai_prompt_versions(id) ON DELETE SET NULL;


--
-- Name: thread_ai_syntheses thread_ai_syntheses_thread_id_fkey; Type: FK CONSTRAINT; Schema: gestor_tickets; Owner: -
--

ALTER TABLE ONLY gestor_tickets.thread_ai_syntheses
    ADD CONSTRAINT thread_ai_syntheses_thread_id_fkey FOREIGN KEY (thread_id) REFERENCES gestor_tickets.system_threads(id) ON DELETE CASCADE;


--
-- Name: thread_merge_history thread_merge_history_account_id_fkey; Type: FK CONSTRAINT; Schema: gestor_tickets; Owner: -
--

ALTER TABLE ONLY gestor_tickets.thread_merge_history
    ADD CONSTRAINT thread_merge_history_account_id_fkey FOREIGN KEY (account_id) REFERENCES gestor_tickets.collaborative_accounts(id) ON DELETE CASCADE;


--
-- Name: thread_merge_history thread_merge_history_merged_by_user_id_fkey; Type: FK CONSTRAINT; Schema: gestor_tickets; Owner: -
--

ALTER TABLE ONLY gestor_tickets.thread_merge_history
    ADD CONSTRAINT thread_merge_history_merged_by_user_id_fkey FOREIGN KEY (merged_by_user_id) REFERENCES gestor_tickets.account_users(id) ON DELETE SET NULL;


--
-- Name: thread_merge_history thread_merge_history_source_thread_id_fkey; Type: FK CONSTRAINT; Schema: gestor_tickets; Owner: -
--

ALTER TABLE ONLY gestor_tickets.thread_merge_history
    ADD CONSTRAINT thread_merge_history_source_thread_id_fkey FOREIGN KEY (source_thread_id) REFERENCES gestor_tickets.system_threads(id) ON DELETE RESTRICT;


--
-- Name: thread_merge_history thread_merge_history_target_thread_id_fkey; Type: FK CONSTRAINT; Schema: gestor_tickets; Owner: -
--

ALTER TABLE ONLY gestor_tickets.thread_merge_history
    ADD CONSTRAINT thread_merge_history_target_thread_id_fkey FOREIGN KEY (target_thread_id) REFERENCES gestor_tickets.system_threads(id) ON DELETE RESTRICT;


--
-- Name: thread_operations thread_operations_account_id_fkey; Type: FK CONSTRAINT; Schema: gestor_tickets; Owner: -
--

ALTER TABLE ONLY gestor_tickets.thread_operations
    ADD CONSTRAINT thread_operations_account_id_fkey FOREIGN KEY (account_id) REFERENCES gestor_tickets.collaborative_accounts(id) ON DELETE CASCADE;


--
-- Name: thread_operations thread_operations_email_message_id_fkey; Type: FK CONSTRAINT; Schema: gestor_tickets; Owner: -
--

ALTER TABLE ONLY gestor_tickets.thread_operations
    ADD CONSTRAINT thread_operations_email_message_id_fkey FOREIGN KEY (email_message_id) REFERENCES gestor_tickets.email_messages(id) ON DELETE SET NULL;


--
-- Name: thread_operations thread_operations_performed_by_user_id_fkey; Type: FK CONSTRAINT; Schema: gestor_tickets; Owner: -
--

ALTER TABLE ONLY gestor_tickets.thread_operations
    ADD CONSTRAINT thread_operations_performed_by_user_id_fkey FOREIGN KEY (performed_by_user_id) REFERENCES gestor_tickets.account_users(id) ON DELETE SET NULL;


--
-- Name: thread_operations thread_operations_source_thread_id_fkey; Type: FK CONSTRAINT; Schema: gestor_tickets; Owner: -
--

ALTER TABLE ONLY gestor_tickets.thread_operations
    ADD CONSTRAINT thread_operations_source_thread_id_fkey FOREIGN KEY (source_thread_id) REFERENCES gestor_tickets.system_threads(id) ON DELETE SET NULL;


--
-- Name: thread_operations thread_operations_target_thread_id_fkey; Type: FK CONSTRAINT; Schema: gestor_tickets; Owner: -
--

ALTER TABLE ONLY gestor_tickets.thread_operations
    ADD CONSTRAINT thread_operations_target_thread_id_fkey FOREIGN KEY (target_thread_id) REFERENCES gestor_tickets.system_threads(id) ON DELETE SET NULL;


--
-- PostgreSQL database dump complete
--

\unrestrict NQ2PMadBMMwnoDZcP0WGbS8uhQiU3U3P4x0ijr7IFizQKTJdH1DomJCVPaVgvvQ
