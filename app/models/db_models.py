from sqlalchemy import (
    BigInteger,
    Boolean,
    CheckConstraint,
    Column,
    DateTime,
    Float,
    ForeignKey,
    Index,
    Integer,
    Numeric,
    SmallInteger,
    String,
    Text,
    UniqueConstraint,
    text,
)
from sqlalchemy.dialects.postgresql import ENUM as PGEnum
from sqlalchemy.dialects.postgresql import INET, JSONB, UUID

from app.core.config import settings
from app.core.db import Base


def _fk(target: str) -> str:
    return f"{settings.DB_SCHEMA}.{target}"


def _enum(name: str, *values: str) -> PGEnum:
    return PGEnum(*values, name=name, schema=settings.DB_SCHEMA, create_type=False)


ACCOUNT_STATUS = _enum(
    "account_status",
    "active",
    "disabled",
    "pending_configuration",
    "error_auth",
    "error_connection",
    "error_unknown",
    "archived",
)

ACCOUNT_ROLE = _enum(
    "account_role",
    "owner",
    "admin",
    "technician",
    "collaborator",
    "viewer",
)

ACCOUNT_USER_AUTH_MODE = _enum(
    "account_user_auth_mode",
    "glpi_account_manager",
    "local_collaborator",
)

ACCOUNT_USER_STATUS = _enum(
    "account_user_status",
    "active",
    "disabled",
    "locked",
    "pending_password_reset",
)

MAIL_DIRECTION = _enum("mail_direction", "inbound", "outbound", "unknown")
MAIL_FOLDER_KIND = _enum("mail_folder_kind", "inbox", "sent", "other")

MAIL_SOURCE = _enum(
    "mail_source",
    "collaborative_ingestion",
    "manual_import",
    "personal_transfer",
    "glpi_import",
    "other",
)

INGESTION_JOB_STATUS = _enum(
    "ingestion_job_status",
    "active",
    "disabled",
    "error_auth",
    "error_connection",
    "error_unknown",
)

INGESTION_RUN_STATUS = _enum(
    "ingestion_run_status",
    "running",
    "success",
    "partial_error",
    "failed",
)

SYSTEM_THREAD_STATUS = _enum(
    "system_thread_status",
    "active",
    "merged",
    "archived",
    "deleted",
)

THREAD_MEMBER_STATUS = _enum(
    "thread_member_status",
    "active",
    "moved",
    "removed",
)

GLPI_LINK_ORIGIN = _enum(
    "glpi_link_origin",
    "manual",
    "ai_suggested",
    "created_from_email",
    "created_from_thread",
    "personal_transfer",
    "auto_sync",
)

GLPI_LINK_STATUS = _enum("glpi_link_status", "active", "detached")
AI_SCOPE = _enum("ai_scope", "email", "thread", "ticket_context")

AI_PROCESSING_STATUS = _enum(
    "ai_processing_status",
    "pending",
    "processing",
    "processed",
    "skipped",
    "error",
)


class AppSetting(Base):
    __tablename__ = "app_settings"
    __table_args__ = {"schema": settings.DB_SCHEMA}

    id = Column(SmallInteger, primary_key=True, server_default=text("1"))
    app_name = Column(Text, nullable=False, server_default=text("'gestor-tickets'"))
    app_description = Column(Text)
    default_timezone = Column(Text, nullable=False, server_default=text("'Atlantic/Canary'"))
    default_archive_root = Column(Text, nullable=False, server_default=text("'/data/mail_archive'"))
    created_at = Column(DateTime(timezone=True), nullable=False, server_default=text("now()"))
    updated_at = Column(DateTime(timezone=True), nullable=False, server_default=text("now()"))


class GlpiInstance(Base):
    __tablename__ = "glpi_instances"
    __table_args__ = {"schema": settings.DB_SCHEMA}

    id = Column(BigInteger, primary_key=True)
    name = Column(Text, nullable=False)
    base_url = Column(Text, nullable=False, unique=True)
    app_token_ciphertext = Column(Text)
    default_entity_id = Column(BigInteger)
    default_group_id = Column(BigInteger)
    verify_tls = Column(Boolean, nullable=False, server_default=text("true"))
    active = Column(Boolean, nullable=False, server_default=text("true"))
    notes = Column(Text)
    created_at = Column(DateTime(timezone=True), nullable=False, server_default=text("now()"))
    updated_at = Column(DateTime(timezone=True), nullable=False, server_default=text("now()"))


class CollaborativeAccount(Base):
    __tablename__ = "collaborative_accounts"
    __table_args__ = (
        CheckConstraint("imap_port = 993", name="ck_collaborative_accounts_imap_port_993"),
        CheckConstraint("imap_use_ssl = true", name="ck_collaborative_accounts_imap_ssl_true"),
        {"schema": settings.DB_SCHEMA},
    )

    id = Column(BigInteger, primary_key=True)
    public_uid = Column(UUID(as_uuid=True), nullable=False, unique=True, server_default=text("gen_random_uuid()"))
    email = Column(Text, nullable=False, unique=True, index=True)
    display_name = Column(Text)
    status = Column(ACCOUNT_STATUS, nullable=False, server_default=text("'pending_configuration'"))

    glpi_instance_id = Column(BigInteger, ForeignKey(_fk("glpi_instances.id"), ondelete="SET NULL"))
    glpi_user_id = Column(BigInteger)
    glpi_login = Column(Text, nullable=False)
    glpi_profile_name = Column(Text, nullable=False, server_default=text("'Supervisor'"))
    glpi_entity_id = Column(BigInteger)
    glpi_group_id = Column(BigInteger)
    last_glpi_validation_at = Column(DateTime(timezone=True))

    imap_host = Column(Text)
    imap_username = Column(Text)
    imap_password_ciphertext = Column(Text)
    imap_port = Column(Integer, nullable=False, server_default=text("993"))
    imap_use_ssl = Column(Boolean, nullable=False, server_default=text("true"))
    imap_last_validated_at = Column(DateTime(timezone=True))

    archive_root = Column(Text, nullable=False, server_default=text("'/data/mail_archive'"))
    archive_subdir = Column(Text, nullable=False)

    ingestion_enabled = Column(Boolean, nullable=False, server_default=text("false"))
    created_by_login = Column(Text)
    notes = Column(Text)
    created_at = Column(DateTime(timezone=True), nullable=False, server_default=text("now()"))
    updated_at = Column(DateTime(timezone=True), nullable=False, server_default=text("now()"))


class AccountUser(Base):
    __tablename__ = "account_users"
    __table_args__ = (
        Index(
            "uq_account_users_username_per_account",
            "account_id",
            "username_local",
            unique=True,
            postgresql_where=text("username_local IS NOT NULL"),
        ),
        Index("ix_account_users_account_role", "account_id", "role"),
        Index("ix_account_users_status", "status"),
        {"schema": settings.DB_SCHEMA},
    )

    id = Column(BigInteger, primary_key=True)
    public_uid = Column(UUID(as_uuid=True), nullable=False, unique=True, server_default=text("gen_random_uuid()"))
    account_id = Column(BigInteger, ForeignKey(_fk("collaborative_accounts.id"), ondelete="CASCADE"), nullable=False)

    auth_mode = Column(ACCOUNT_USER_AUTH_MODE, nullable=False)
    login_identifier = Column(Text, nullable=False, unique=True)
    username_local = Column(Text)
    password_hash = Column(Text)

    display_name = Column(Text, nullable=False)
    contact_email = Column(Text)
    role = Column(ACCOUNT_ROLE, nullable=False, server_default=text("'collaborator'"))
    status = Column(ACCOUNT_USER_STATUS, nullable=False, server_default=text("'active'"))

    can_manage_users = Column(Boolean, nullable=False, server_default=text("false"))
    can_manage_account_config = Column(Boolean, nullable=False, server_default=text("false"))
    can_read_account_mail = Column(Boolean, nullable=False, server_default=text("true"))
    can_reply_from_account = Column(Boolean, nullable=False, server_default=text("false"))
    can_create_glpi_ticket = Column(Boolean, nullable=False, server_default=text("false"))
    can_update_glpi_ticket = Column(Boolean, nullable=False, server_default=text("false"))
    can_link_tickets = Column(Boolean, nullable=False, server_default=text("false"))
    can_manage_ai = Column(Boolean, nullable=False, server_default=text("false"))
    assistant_mode = Column(Boolean, nullable=False, server_default=text("true"))

    failed_login_count = Column(Integer, nullable=False, server_default=text("0"))
    locked_until = Column(DateTime(timezone=True))
    last_login_at = Column(DateTime(timezone=True))
    created_by_user_id = Column(BigInteger, ForeignKey(_fk("account_users.id"), ondelete="SET NULL"))
    created_at = Column(DateTime(timezone=True), nullable=False, server_default=text("now()"))
    updated_at = Column(DateTime(timezone=True), nullable=False, server_default=text("now()"))


class PersonalMailAccount(Base):
    __tablename__ = "personal_mail_accounts"
    __table_args__ = (
        UniqueConstraint("user_id", "email", name="uq_personal_mail_accounts_user_email"),
        Index("ix_personal_mail_accounts_account_user", "account_id", "user_id"),
        {"schema": settings.DB_SCHEMA},
    )

    id = Column(BigInteger, primary_key=True)
    public_uid = Column(UUID(as_uuid=True), nullable=False, unique=True, server_default=text("gen_random_uuid()"))
    account_id = Column(BigInteger, ForeignKey(_fk("collaborative_accounts.id"), ondelete="CASCADE"), nullable=False)
    user_id = Column(BigInteger, ForeignKey(_fk("account_users.id"), ondelete="CASCADE"), nullable=False)
    email = Column(Text, nullable=False)
    display_name = Column(Text)
    imap_host = Column(Text, nullable=False)
    imap_username = Column(Text, nullable=False)
    imap_password_ciphertext = Column(Text, nullable=False)
    imap_port = Column(Integer, nullable=False, server_default=text("993"))
    imap_use_ssl = Column(Boolean, nullable=False, server_default=text("true"))
    active = Column(Boolean, nullable=False, server_default=text("true"))
    last_validated_at = Column(DateTime(timezone=True))
    created_at = Column(DateTime(timezone=True), nullable=False, server_default=text("now()"))
    updated_at = Column(DateTime(timezone=True), nullable=False, server_default=text("now()"))


class MailIngestionJob(Base):
    __tablename__ = "mail_ingestion_jobs"
    __table_args__ = (
        Index("ix_mail_ingestion_jobs_due", "status", "next_run_at"),
        {"schema": settings.DB_SCHEMA},
    )

    id = Column(BigInteger, primary_key=True)
    account_id = Column(BigInteger, ForeignKey(_fk("collaborative_accounts.id"), ondelete="CASCADE"), nullable=False, unique=True)
    status = Column(INGESTION_JOB_STATUS, nullable=False, server_default=text("'disabled'"))
    scan_inbox = Column(Boolean, nullable=False, server_default=text("true"))
    scan_sent = Column(Boolean, nullable=False, server_default=text("true"))
    inbox_folder_name = Column(Text, nullable=False, server_default=text("'INBOX'"))
    sent_folder_name = Column(Text, nullable=False, server_default=text("'Sent'"))
    interval_minutes = Column(Integer, nullable=False, server_default=text("5"))
    max_messages_per_folder = Column(Integer, nullable=False, server_default=text("200"))
    last_started_at = Column(DateTime(timezone=True))
    last_success_at = Column(DateTime(timezone=True))
    last_error_at = Column(DateTime(timezone=True))
    next_run_at = Column(DateTime(timezone=True))
    auth_failure_count = Column(Integer, nullable=False, server_default=text("0"))
    last_error_message = Column(Text)
    created_by_user_id = Column(BigInteger, ForeignKey(_fk("account_users.id"), ondelete="SET NULL"))
    updated_by_user_id = Column(BigInteger, ForeignKey(_fk("account_users.id"), ondelete="SET NULL"))
    created_at = Column(DateTime(timezone=True), nullable=False, server_default=text("now()"))
    updated_at = Column(DateTime(timezone=True), nullable=False, server_default=text("now()"))


class MailIngestionRun(Base):
    __tablename__ = "mail_ingestion_runs"
    __table_args__ = (
        Index("ix_mail_ingestion_runs_account_started", "account_id", text("started_at DESC")),
        {"schema": settings.DB_SCHEMA},
    )

    id = Column(BigInteger, primary_key=True)
    job_id = Column(BigInteger, ForeignKey(_fk("mail_ingestion_jobs.id"), ondelete="CASCADE"), nullable=False)
    account_id = Column(BigInteger, ForeignKey(_fk("collaborative_accounts.id"), ondelete="CASCADE"), nullable=False)
    status = Column(INGESTION_RUN_STATUS, nullable=False, server_default=text("'running'"))
    started_at = Column(DateTime(timezone=True), nullable=False, server_default=text("now()"))
    finished_at = Column(DateTime(timezone=True))
    scanned_inbox_count = Column(Integer, nullable=False, server_default=text("0"))
    scanned_sent_count = Column(Integer, nullable=False, server_default=text("0"))
    imported_count = Column(Integer, nullable=False, server_default=text("0"))
    duplicate_count = Column(Integer, nullable=False, server_default=text("0"))
    error_count = Column(Integer, nullable=False, server_default=text("0"))
    error_message = Column(Text)
    details_json = Column(JSONB, nullable=False, server_default=text("'{}'::jsonb"))


class EmailMessage(Base):
    __tablename__ = "email_messages"
    __table_args__ = (
        Index(
            "uq_email_messages_account_message_id_header",
            "account_id",
            "message_id_header",
            unique=True,
            postgresql_where=text("message_id_header IS NOT NULL"),
        ),
        Index("uq_email_messages_account_eml_sha256", "account_id", "eml_sha256", unique=True),
        Index("ix_email_messages_account_date", "account_id", text("sent_at DESC NULLS LAST"), text("id DESC")),
        Index("ix_email_messages_account_subject", "account_id", "subject_normalized"),
        Index("ix_email_messages_from_email", "from_email"),
        {"schema": settings.DB_SCHEMA},
    )

    id = Column(BigInteger, primary_key=True)
    system_uid = Column(UUID(as_uuid=True), nullable=False, unique=True, server_default=text("gen_random_uuid()"))
    account_id = Column(BigInteger, ForeignKey(_fk("collaborative_accounts.id"), ondelete="CASCADE"), nullable=False)

    message_id_header = Column(Text)
    eml_sha256 = Column(String(64), nullable=False)
    raw_headers_sha256 = Column(String(64))
    eml_storage_path = Column(Text, nullable=False, unique=True)
    eml_filename = Column(Text, nullable=False)
    size_bytes = Column(BigInteger)

    source = Column(MAIL_SOURCE, nullable=False, server_default=text("'collaborative_ingestion'"))
    imported_from_personal_account_id = Column(BigInteger, ForeignKey(_fk("personal_mail_accounts.id"), ondelete="SET NULL"))
    transferred_by_user_id = Column(BigInteger, ForeignKey(_fk("account_users.id"), ondelete="SET NULL"))
    transferred_at = Column(DateTime(timezone=True))
    original_imap_account = Column(Text)
    original_imap_folder = Column(Text)
    original_imap_uid = Column(Text)
    original_imap_uidvalidity = Column(Text)
    source_description = Column(Text)

    subject = Column(Text)
    subject_normalized = Column(Text)
    from_email = Column(Text)
    from_name = Column(Text)
    sent_at = Column(DateTime(timezone=True))
    received_at = Column(DateTime(timezone=True))
    direction = Column(MAIL_DIRECTION, nullable=False, server_default=text("'unknown'"))
    has_attachments = Column(Boolean, nullable=False, server_default=text("false"))
    body_text_preview = Column(Text)

    archived_at = Column(DateTime(timezone=True), nullable=False, server_default=text("now()"))
    created_at = Column(DateTime(timezone=True), nullable=False, server_default=text("now()"))
    updated_at = Column(DateTime(timezone=True), nullable=False, server_default=text("now()"))


class EmailMessageOccurrence(Base):
    __tablename__ = "email_message_occurrences"
    __table_args__ = (
        UniqueConstraint(
            "source_mailbox_email",
            "folder_name",
            "imap_uidvalidity",
            "imap_uid",
            name="uq_email_message_occurrence_imap_identity",
        ),
        Index("ix_email_occurrences_email", "email_message_id"),
        Index("ix_email_occurrences_account_folder", "account_id", "folder_name", "imap_uid"),
        {"schema": settings.DB_SCHEMA},
    )

    id = Column(BigInteger, primary_key=True)
    email_message_id = Column(BigInteger, ForeignKey(_fk("email_messages.id"), ondelete="CASCADE"), nullable=False)
    account_id = Column(BigInteger, ForeignKey(_fk("collaborative_accounts.id"), ondelete="CASCADE"), nullable=False)
    ingestion_run_id = Column(BigInteger, ForeignKey(_fk("mail_ingestion_runs.id"), ondelete="SET NULL"))
    source_mailbox_email = Column(Text, nullable=False)
    folder_name = Column(Text, nullable=False)
    folder_kind = Column(MAIL_FOLDER_KIND, nullable=False, server_default=text("'other'"))
    imap_uid = Column(Text, nullable=False)
    imap_uidvalidity = Column(Text)
    direction = Column(MAIL_DIRECTION, nullable=False, server_default=text("'unknown'"))
    flags_json = Column(JSONB, nullable=False, server_default=text("'[]'::jsonb"))
    unread_at_import = Column(Boolean)
    first_seen_at = Column(DateTime(timezone=True), nullable=False, server_default=text("now()"))
    last_seen_at = Column(DateTime(timezone=True), nullable=False, server_default=text("now()"))


class EmailRecipient(Base):
    __tablename__ = "email_recipients"
    __table_args__ = (
        Index("ix_email_recipients_email", "email"),
        Index("ix_email_recipients_message", "email_message_id", "recipient_type", "position"),
        {"schema": settings.DB_SCHEMA},
    )

    id = Column(BigInteger, primary_key=True)
    email_message_id = Column(BigInteger, ForeignKey(_fk("email_messages.id"), ondelete="CASCADE"), nullable=False)
    recipient_type = Column(Text, nullable=False)
    email = Column(Text, nullable=False)
    display_name = Column(Text)
    position = Column(Integer, nullable=False, server_default=text("0"))


class EmailAttachment(Base):
    __tablename__ = "email_attachments"
    __table_args__ = (
        Index("ix_email_attachments_message", "email_message_id"),
        {"schema": settings.DB_SCHEMA},
    )

    id = Column(BigInteger, primary_key=True)
    email_message_id = Column(BigInteger, ForeignKey(_fk("email_messages.id"), ondelete="CASCADE"), nullable=False)
    filename = Column(Text)
    content_type = Column(Text)
    size_bytes = Column(BigInteger)
    content_id = Column(Text)
    is_inline = Column(Boolean, nullable=False, server_default=text("false"))
    storage_path = Column(Text)
    sha256 = Column(String(64))
    created_at = Column(DateTime(timezone=True), nullable=False, server_default=text("now()"))


class PersonalMessageTransferLog(Base):
    __tablename__ = "personal_message_transfer_log"
    __table_args__ = (
        UniqueConstraint(
            "personal_account_id",
            "original_folder",
            "original_imap_uidvalidity",
            "original_imap_uid",
            name="uq_personal_transfer_original",
        ),
        {"schema": settings.DB_SCHEMA},
    )

    id = Column(BigInteger, primary_key=True)
    personal_account_id = Column(BigInteger, ForeignKey(_fk("personal_mail_accounts.id"), ondelete="RESTRICT"), nullable=False)
    target_account_id = Column(BigInteger, ForeignKey(_fk("collaborative_accounts.id"), ondelete="CASCADE"), nullable=False)
    transferred_email_message_id = Column(BigInteger, ForeignKey(_fk("email_messages.id"), ondelete="CASCADE"), nullable=False)
    transferred_by_user_id = Column(BigInteger, ForeignKey(_fk("account_users.id"), ondelete="RESTRICT"), nullable=False)
    original_folder = Column(Text, nullable=False)
    original_imap_uid = Column(Text, nullable=False)
    original_imap_uidvalidity = Column(Text)
    original_message_id_header = Column(Text)
    transfer_reason = Column(Text)
    transferred_at = Column(DateTime(timezone=True), nullable=False, server_default=text("now()"))


class SystemThread(Base):
    __tablename__ = "system_threads"
    __table_args__ = (
        Index("ix_system_threads_account_status", "account_id", "status", text("updated_at DESC")),
        Index("ix_system_threads_subject", "account_id", "subject_normalized"),
        {"schema": settings.DB_SCHEMA},
    )

    id = Column(BigInteger, primary_key=True)
    system_thread_uid = Column(UUID(as_uuid=True), nullable=False, unique=True, server_default=text("gen_random_uuid()"))
    account_id = Column(BigInteger, ForeignKey(_fk("collaborative_accounts.id"), ondelete="CASCADE"), nullable=False)
    title = Column(Text)
    subject_normalized = Column(Text)
    status = Column(SYSTEM_THREAD_STATUS, nullable=False, server_default=text("'active'"))
    detected_from_message_id = Column(BigInteger, ForeignKey(_fk("email_messages.id"), ondelete="SET NULL"))
    created_reason = Column(Text)
    created_by_user_id = Column(BigInteger, ForeignKey(_fk("account_users.id"), ondelete="SET NULL"))
    merged_into_thread_id = Column(BigInteger, ForeignKey(_fk("system_threads.id"), ondelete="SET NULL"))
    merged_at = Column(DateTime(timezone=True))
    archived_at = Column(DateTime(timezone=True))
    created_at = Column(DateTime(timezone=True), nullable=False, server_default=text("now()"))
    updated_at = Column(DateTime(timezone=True), nullable=False, server_default=text("now()"))


class EmailThreadMember(Base):
    __tablename__ = "email_thread_members"
    __table_args__ = (
        Index(
            "uq_thread_active_email_once",
            "thread_id",
            "email_message_id",
            unique=True,
            postgresql_where=text("status = 'active'"),
        ),
        Index("ix_email_thread_members_thread_position", "thread_id", "position_asc", "email_message_id"),
        Index("ix_email_thread_members_email", "email_message_id"),
        {"schema": settings.DB_SCHEMA},
    )

    id = Column(BigInteger, primary_key=True)
    thread_id = Column(BigInteger, ForeignKey(_fk("system_threads.id"), ondelete="CASCADE"), nullable=False)
    email_message_id = Column(BigInteger, ForeignKey(_fk("email_messages.id"), ondelete="CASCADE"), nullable=False)
    position_asc = Column(Integer, nullable=False, server_default=text("0"))
    status = Column(THREAD_MEMBER_STATUS, nullable=False, server_default=text("'active'"))
    added_by_user_id = Column(BigInteger, ForeignKey(_fk("account_users.id"), ondelete="SET NULL"))
    added_reason = Column(Text)
    added_at = Column(DateTime(timezone=True), nullable=False, server_default=text("now()"))
    removed_by_user_id = Column(BigInteger, ForeignKey(_fk("account_users.id"), ondelete="SET NULL"))
    removed_reason = Column(Text)
    removed_at = Column(DateTime(timezone=True))
    moved_from_thread_id = Column(BigInteger, ForeignKey(_fk("system_threads.id"), ondelete="SET NULL"))
    moved_to_thread_id = Column(BigInteger, ForeignKey(_fk("system_threads.id"), ondelete="SET NULL"))


class ThreadOperation(Base):
    __tablename__ = "thread_operations"
    __table_args__ = (
        Index("ix_thread_operations_account_created", "account_id", text("created_at DESC")),
        Index("ix_thread_operations_thread", "source_thread_id", "target_thread_id"),
        {"schema": settings.DB_SCHEMA},
    )

    id = Column(BigInteger, primary_key=True)
    account_id = Column(BigInteger, ForeignKey(_fk("collaborative_accounts.id"), ondelete="CASCADE"), nullable=False)
    operation_type = Column(Text, nullable=False)
    source_thread_id = Column(BigInteger, ForeignKey(_fk("system_threads.id"), ondelete="SET NULL"))
    target_thread_id = Column(BigInteger, ForeignKey(_fk("system_threads.id"), ondelete="SET NULL"))
    email_message_id = Column(BigInteger, ForeignKey(_fk("email_messages.id"), ondelete="SET NULL"))
    performed_by_user_id = Column(BigInteger, ForeignKey(_fk("account_users.id"), ondelete="SET NULL"))
    reason = Column(Text)
    details_json = Column(JSONB, nullable=False, server_default=text("'{}'::jsonb"))
    created_at = Column(DateTime(timezone=True), nullable=False, server_default=text("now()"))


class ThreadMergeHistory(Base):
    __tablename__ = "thread_merge_history"
    __table_args__ = (
        UniqueConstraint("source_thread_id", name="uq_thread_merge_history_source"),
        {"schema": settings.DB_SCHEMA},
    )

    id = Column(BigInteger, primary_key=True)
    account_id = Column(BigInteger, ForeignKey(_fk("collaborative_accounts.id"), ondelete="CASCADE"), nullable=False)
    source_thread_id = Column(BigInteger, ForeignKey(_fk("system_threads.id"), ondelete="RESTRICT"), nullable=False)
    target_thread_id = Column(BigInteger, ForeignKey(_fk("system_threads.id"), ondelete="RESTRICT"), nullable=False)
    merged_by_user_id = Column(BigInteger, ForeignKey(_fk("account_users.id"), ondelete="SET NULL"))
    reason = Column(Text)
    details_json = Column(JSONB, nullable=False, server_default=text("'{}'::jsonb"))
    merged_at = Column(DateTime(timezone=True), nullable=False, server_default=text("now()"))


class GlpiTicketCache(Base):
    __tablename__ = "glpi_ticket_cache"
    __table_args__ = (
        UniqueConstraint("glpi_instance_id", "glpi_ticket_id", name="uq_glpi_ticket_cache_instance_ticket"),
        Index("ix_glpi_ticket_cache_account", "account_id", "glpi_ticket_id"),
        Index("ix_glpi_ticket_cache_status", "account_id", "status"),
        {"schema": settings.DB_SCHEMA},
    )

    id = Column(BigInteger, primary_key=True)
    account_id = Column(BigInteger, ForeignKey(_fk("collaborative_accounts.id"), ondelete="CASCADE"), nullable=False)
    glpi_instance_id = Column(BigInteger, ForeignKey(_fk("glpi_instances.id"), ondelete="SET NULL"))
    glpi_ticket_id = Column(BigInteger, nullable=False)
    title = Column(Text)
    status = Column(Text)
    priority = Column(Text)
    urgency = Column(Text)
    impact = Column(Text)
    entity_id = Column(BigInteger)
    group_id = Column(BigInteger)
    requester_json = Column(JSONB, nullable=False, server_default=text("'[]'::jsonb"))
    assignee_json = Column(JSONB, nullable=False, server_default=text("'[]'::jsonb"))
    raw_json = Column(JSONB, nullable=False, server_default=text("'{}'::jsonb"))
    last_sync_at = Column(DateTime(timezone=True))
    created_at = Column(DateTime(timezone=True), nullable=False, server_default=text("now()"))
    updated_at = Column(DateTime(timezone=True), nullable=False, server_default=text("now()"))


class GlpiTicketEmailLink(Base):
    __tablename__ = "glpi_ticket_email_links"
    __table_args__ = (
        Index(
            "uq_active_ticket_email_link",
            "glpi_ticket_cache_id",
            "email_message_id",
            unique=True,
            postgresql_where=text("status = 'active'"),
        ),
        Index("ix_ticket_email_links_email", "email_message_id", "status"),
        Index("ix_ticket_email_links_ticket", "glpi_ticket_cache_id", "status"),
        {"schema": settings.DB_SCHEMA},
    )

    id = Column(BigInteger, primary_key=True)
    account_id = Column(BigInteger, ForeignKey(_fk("collaborative_accounts.id"), ondelete="CASCADE"), nullable=False)
    glpi_ticket_cache_id = Column(BigInteger, ForeignKey(_fk("glpi_ticket_cache.id"), ondelete="CASCADE"), nullable=False)
    email_message_id = Column(BigInteger, ForeignKey(_fk("email_messages.id"), ondelete="CASCADE"), nullable=False)
    origin = Column(GLPI_LINK_ORIGIN, nullable=False, server_default=text("'manual'"))
    status = Column(GLPI_LINK_STATUS, nullable=False, server_default=text("'active'"))
    created_by_user_id = Column(BigInteger, ForeignKey(_fk("account_users.id"), ondelete="SET NULL"))
    created_at = Column(DateTime(timezone=True), nullable=False, server_default=text("now()"))
    detached_by_user_id = Column(BigInteger, ForeignKey(_fk("account_users.id"), ondelete="SET NULL"))
    detached_at = Column(DateTime(timezone=True))
    notes = Column(Text)


class GlpiTicketThreadLink(Base):
    __tablename__ = "glpi_ticket_thread_links"
    __table_args__ = (
        Index(
            "uq_active_ticket_thread_link",
            "glpi_ticket_cache_id",
            "thread_id",
            unique=True,
            postgresql_where=text("status = 'active'"),
        ),
        Index("ix_ticket_thread_links_thread", "thread_id", "status"),
        Index("ix_ticket_thread_links_ticket", "glpi_ticket_cache_id", "status"),
        {"schema": settings.DB_SCHEMA},
    )

    id = Column(BigInteger, primary_key=True)
    account_id = Column(BigInteger, ForeignKey(_fk("collaborative_accounts.id"), ondelete="CASCADE"), nullable=False)
    glpi_ticket_cache_id = Column(BigInteger, ForeignKey(_fk("glpi_ticket_cache.id"), ondelete="CASCADE"), nullable=False)
    thread_id = Column(BigInteger, ForeignKey(_fk("system_threads.id"), ondelete="CASCADE"), nullable=False)
    origin = Column(GLPI_LINK_ORIGIN, nullable=False, server_default=text("'manual'"))
    status = Column(GLPI_LINK_STATUS, nullable=False, server_default=text("'active'"))
    created_by_user_id = Column(BigInteger, ForeignKey(_fk("account_users.id"), ondelete="SET NULL"))
    created_at = Column(DateTime(timezone=True), nullable=False, server_default=text("now()"))
    detached_by_user_id = Column(BigInteger, ForeignKey(_fk("account_users.id"), ondelete="SET NULL"))
    detached_at = Column(DateTime(timezone=True))
    notes = Column(Text)


class GlpiTicketRelationship(Base):
    __tablename__ = "glpi_ticket_relationships"
    __table_args__ = (
        UniqueConstraint(
            "source_ticket_cache_id",
            "target_ticket_cache_id",
            "relationship_type",
            name="uq_glpi_ticket_relationship",
        ),
        {"schema": settings.DB_SCHEMA},
    )

    id = Column(BigInteger, primary_key=True)
    account_id = Column(BigInteger, ForeignKey(_fk("collaborative_accounts.id"), ondelete="CASCADE"), nullable=False)
    source_ticket_cache_id = Column(BigInteger, ForeignKey(_fk("glpi_ticket_cache.id"), ondelete="CASCADE"), nullable=False)
    target_ticket_cache_id = Column(BigInteger, ForeignKey(_fk("glpi_ticket_cache.id"), ondelete="CASCADE"), nullable=False)
    relationship_type = Column(Text, nullable=False, server_default=text("'related'"))
    created_by_user_id = Column(BigInteger, ForeignKey(_fk("account_users.id"), ondelete="SET NULL"))
    created_at = Column(DateTime(timezone=True), nullable=False, server_default=text("now()"))
    notes = Column(Text)


class GlpiApiOperation(Base):
    __tablename__ = "glpi_api_operations"
    __table_args__ = (
        Index("ix_glpi_api_operations_account_created", "account_id", text("created_at DESC")),
        Index("ix_glpi_api_operations_ticket", "glpi_ticket_cache_id", text("created_at DESC")),
        {"schema": settings.DB_SCHEMA},
    )

    id = Column(BigInteger, primary_key=True)
    account_id = Column(BigInteger, ForeignKey(_fk("collaborative_accounts.id"), ondelete="CASCADE"), nullable=False)
    glpi_instance_id = Column(BigInteger, ForeignKey(_fk("glpi_instances.id"), ondelete="SET NULL"))
    glpi_ticket_cache_id = Column(BigInteger, ForeignKey(_fk("glpi_ticket_cache.id"), ondelete="SET NULL"))
    operation_type = Column(Text, nullable=False)
    requested_by_user_id = Column(BigInteger, ForeignKey(_fk("account_users.id"), ondelete="SET NULL"))
    request_payload_json = Column(JSONB)
    response_status_code = Column(Integer)
    response_json = Column(JSONB)
    success = Column(Boolean, nullable=False, server_default=text("false"))
    error_message = Column(Text)
    created_at = Column(DateTime(timezone=True), nullable=False, server_default=text("now()"))


class AiPromptTemplate(Base):
    __tablename__ = "ai_prompt_templates"
    __table_args__ = {"schema": settings.DB_SCHEMA}

    id = Column(BigInteger, primary_key=True)
    key = Column(Text, nullable=False, unique=True)
    name = Column(Text, nullable=False)
    description = Column(Text)
    category = Column(Text)
    variables_schema_json = Column(JSONB, nullable=False, server_default=text("'{}'::jsonb"))
    active = Column(Boolean, nullable=False, server_default=text("true"))
    created_at = Column(DateTime(timezone=True), nullable=False, server_default=text("now()"))
    updated_at = Column(DateTime(timezone=True), nullable=False, server_default=text("now()"))


class AiPromptVersion(Base):
    __tablename__ = "ai_prompt_versions"
    __table_args__ = (
        UniqueConstraint("template_id", "version_number", name="uq_ai_prompt_versions_template_version"),
        Index(
            "uq_ai_prompt_one_active_version",
            "template_id",
            unique=True,
            postgresql_where=text("is_active = true"),
        ),
        {"schema": settings.DB_SCHEMA},
    )

    id = Column(BigInteger, primary_key=True)
    template_id = Column(BigInteger, ForeignKey(_fk("ai_prompt_templates.id"), ondelete="CASCADE"), nullable=False)
    version_number = Column(Integer, nullable=False)
    system_prompt_template = Column(Text, nullable=False)
    user_prompt_template = Column(Text, nullable=False)
    response_schema_json = Column(JSONB, nullable=False, server_default=text("'{}'::jsonb"))
    example_input_json = Column(JSONB, nullable=False, server_default=text("'{}'::jsonb"))
    expected_output_example_json = Column(JSONB, nullable=False, server_default=text("'{}'::jsonb"))
    default_llm_params_json = Column(JSONB, nullable=False, server_default=text("'{}'::jsonb"))
    enable_thinking = Column(Boolean, nullable=False, server_default=text("false"))
    timeout_seconds = Column(Integer, nullable=False, server_default=text("300"))
    is_active = Column(Boolean, nullable=False, server_default=text("false"))
    created_by_user_id = Column(BigInteger, ForeignKey(_fk("account_users.id"), ondelete="SET NULL"))
    created_at = Column(DateTime(timezone=True), nullable=False, server_default=text("now()"))
    notes = Column(Text)


class AiCallHistory(Base):
    __tablename__ = "ai_call_history"
    __table_args__ = (
        Index("ix_ai_call_history_account_created", "account_id", text("created_at DESC")),
        Index("ix_ai_call_history_related_email", "related_email_message_id"),
        Index("ix_ai_call_history_related_thread", "related_thread_id"),
        {"schema": settings.DB_SCHEMA},
    )

    id = Column(BigInteger, primary_key=True)
    account_id = Column(BigInteger, ForeignKey(_fk("collaborative_accounts.id"), ondelete="SET NULL"))
    created_by_user_id = Column(BigInteger, ForeignKey(_fk("account_users.id"), ondelete="SET NULL"))
    scope = Column(AI_SCOPE, nullable=False)
    call_source = Column(Text)
    call_purpose = Column(Text)
    prompt_version_id = Column(BigInteger, ForeignKey(_fk("ai_prompt_versions.id"), ondelete="SET NULL"))
    model = Column(Text)
    endpoint_url = Column(Text)
    enable_thinking = Column(Boolean)
    temperature = Column(Numeric)
    top_p = Column(Numeric)
    top_k = Column(Integer)
    max_tokens = Column(Integer)
    timeout_seconds = Column(Integer)
    duration_ms = Column(Integer)
    status = Column(Text, nullable=False)
    http_status_code = Column(Integer)
    error_type = Column(Text)
    error_message = Column(Text)
    request_payload_json = Column(JSONB)
    request_messages_json = Column(JSONB)
    response_full_json = Column(JSONB)
    response_message_content = Column(Text)
    response_parsed_json = Column(JSONB)
    json_parse_ok = Column(Boolean)
    json_validation_ok = Column(Boolean)
    json_validation_errors_json = Column(JSONB)
    prompt_tokens = Column(Integer)
    completion_tokens = Column(Integer)
    total_tokens = Column(Integer)
    related_email_message_id = Column(BigInteger, ForeignKey(_fk("email_messages.id"), ondelete="SET NULL"))
    related_thread_id = Column(BigInteger, ForeignKey(_fk("system_threads.id"), ondelete="SET NULL"))
    related_glpi_ticket_cache_id = Column(BigInteger, ForeignKey(_fk("glpi_ticket_cache.id"), ondelete="SET NULL"))
    created_at = Column(DateTime(timezone=True), nullable=False, server_default=text("now()"))


class EmailAiProcessing(Base):
    __tablename__ = "email_ai_processing"
    __table_args__ = (
        UniqueConstraint("email_message_id", "prompt_version_id", name="uq_email_ai_processing_message_prompt"),
        Index("ix_email_ai_processing_status", "status", "created_at"),
        {"schema": settings.DB_SCHEMA},
    )

    id = Column(BigInteger, primary_key=True)
    email_message_id = Column(BigInteger, ForeignKey(_fk("email_messages.id"), ondelete="CASCADE"), nullable=False)
    prompt_version_id = Column(BigInteger, ForeignKey(_fk("ai_prompt_versions.id"), ondelete="SET NULL"))
    llm_call_history_id = Column(BigInteger, ForeignKey(_fk("ai_call_history.id"), ondelete="SET NULL"))
    status = Column(AI_PROCESSING_STATUS, nullable=False, server_default=text("'pending'"))
    body_new = Column(Text)
    body_new_found = Column(Boolean)
    body_new_is_too_short = Column(Boolean)
    needs_thread_context = Column(Boolean)
    extraction_confidence = Column(Float)
    summary_json = Column(JSONB)
    tipo_correo = Column(Text)
    accion_sugerida = Column(Text)
    prioridad_sugerida = Column(Text)
    requiere_revision_humana = Column(Boolean)
    processed_at = Column(DateTime(timezone=True))
    error_message = Column(Text)
    created_at = Column(DateTime(timezone=True), nullable=False, server_default=text("now()"))
    updated_at = Column(DateTime(timezone=True), nullable=False, server_default=text("now()"))


class ThreadAiSynthesis(Base):
    __tablename__ = "thread_ai_syntheses"
    __table_args__ = (
        UniqueConstraint(
            "thread_id",
            "latest_email_message_id",
            "prompt_version_id",
            name="uq_thread_ai_synthesis_thread_latest_prompt",
        ),
        Index("ix_thread_ai_syntheses_thread", "thread_id", text("synthesized_at DESC")),
        {"schema": settings.DB_SCHEMA},
    )

    id = Column(BigInteger, primary_key=True)
    thread_id = Column(BigInteger, ForeignKey(_fk("system_threads.id"), ondelete="CASCADE"), nullable=False)
    latest_email_message_id = Column(BigInteger, ForeignKey(_fk("email_messages.id"), ondelete="SET NULL"))
    prompt_version_id = Column(BigInteger, ForeignKey(_fk("ai_prompt_versions.id"), ondelete="SET NULL"))
    llm_call_history_id = Column(BigInteger, ForeignKey(_fk("ai_call_history.id"), ondelete="SET NULL"))
    status = Column(AI_PROCESSING_STATUS, nullable=False, server_default=text("'pending'"))
    state_summary_json = Column(JSONB)
    short_dialogue_text = Column(Text)
    synthesized_at = Column(DateTime(timezone=True))
    error_message = Column(Text)
    created_at = Column(DateTime(timezone=True), nullable=False, server_default=text("now()"))
    updated_at = Column(DateTime(timezone=True), nullable=False, server_default=text("now()"))


class AuditLog(Base):
    __tablename__ = "audit_log"
    __table_args__ = (
        Index("ix_audit_log_account_created", "account_id", text("created_at DESC")),
        Index("ix_audit_log_actor_created", "actor_user_id", text("created_at DESC")),
        Index("ix_audit_log_entity", "entity_type", "entity_id"),
        {"schema": settings.DB_SCHEMA},
    )

    id = Column(BigInteger, primary_key=True)
    account_id = Column(BigInteger, ForeignKey(_fk("collaborative_accounts.id"), ondelete="SET NULL"))
    actor_user_id = Column(BigInteger, ForeignKey(_fk("account_users.id"), ondelete="SET NULL"))
    actor_login_identifier = Column(Text)
    action = Column(Text, nullable=False)
    entity_type = Column(Text, nullable=False)
    entity_id = Column(Text)
    before_json = Column(JSONB)
    after_json = Column(JSONB)
    ip_address = Column(INET)
    user_agent = Column(Text)
    created_at = Column(DateTime(timezone=True), nullable=False, server_default=text("now()"))


# Las vistas del esquema SQL se consultarán con SQL textual o vistas ORM específicas más adelante.
