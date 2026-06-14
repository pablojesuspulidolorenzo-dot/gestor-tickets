from __future__ import annotations

import re
from dataclasses import dataclass
from datetime import datetime, timezone

from sqlalchemy import select
from sqlalchemy.orm import Session

from app.core.config import settings
from app.core.security import encrypt_text
from app.models import (
    AccountUser,
    CollaborativeAccount,
    GlpiInstance,
)
from app.services.audit_service import create_audit_log
from app.services.glpi_service import GlpiService


@dataclass(frozen=True)
class CollaborativeAccountUpsertResult:
    account: CollaborativeAccount
    owner_user: AccountUser | None
    message: str


def _now() -> datetime:
    return datetime.now(timezone.utc)


def normalize_email(value: str) -> str:
    return (value or "").strip().lower()


def normalize_login(value: str) -> str:
    return (value or "").strip()


def make_archive_subdir(account_email: str) -> str:
    clean = normalize_email(account_email)
    clean = clean.replace("@", "__at__")
    clean = re.sub(r"[^a-z0-9_.-]+", "_", clean)
    clean = clean.strip("._-")
    return clean or "cuenta"


def _get_or_create_default_glpi_instance(db: Session) -> GlpiInstance:
    base_url = settings.GLPI_BASE_URL.rstrip("/")

    existing = db.execute(
        select(GlpiInstance).where(GlpiInstance.base_url == base_url)
    ).scalar_one_or_none()

    if existing:
        return existing

    item = GlpiInstance(
        name="GLPI principal",
        base_url=base_url,
        default_entity_id=None,
        default_group_id=None,
        verify_tls=True,
        active=True,
        notes="Instancia GLPI configurada desde .env",
    )
    db.add(item)
    db.flush()
    return item


def _get_or_create_owner_user(
    db: Session,
    *,
    account: CollaborativeAccount,
    display_name: str,
) -> AccountUser:
    existing = db.execute(
        select(AccountUser).where(
            AccountUser.account_id == account.id,
            AccountUser.auth_mode == "glpi_account_manager",
            AccountUser.login_identifier == account.email,
        )
    ).scalar_one_or_none()

    now = _now()

    if existing:
        existing.display_name = display_name
        existing.contact_email = account.email
        existing.role = "owner"
        existing.status = "active"
        existing.can_manage_users = True
        existing.can_manage_account_config = True
        existing.can_read_account_mail = True
        existing.can_reply_from_account = True
        existing.can_create_glpi_ticket = True
        existing.can_update_glpi_ticket = True
        existing.can_link_tickets = True
        existing.can_manage_ai = True
        existing.updated_at = now
        db.flush()
        return existing

    owner = AccountUser(
        account_id=account.id,
        auth_mode="glpi_account_manager",
        login_identifier=account.email,
        username_local=None,
        password_hash=None,
        display_name=display_name,
        contact_email=account.email,
        role="owner",
        status="active",
        can_manage_users=True,
        can_manage_account_config=True,
        can_read_account_mail=True,
        can_reply_from_account=True,
        can_create_glpi_ticket=True,
        can_update_glpi_ticket=True,
        can_link_tickets=True,
        can_manage_ai=True,
    )
    db.add(owner)
    db.flush()
    return owner


async def upsert_collaborative_account(
    db: Session,
    *,
    account_email: str,
    glpi_login: str,
    glpi_password: str,
    display_name: str | None = None,
    imap_host: str | None = None,
    imap_username: str | None = None,
    imap_password: str | None = None,
    ingestion_enabled: bool = False,
    actor_ip: str | None = None,
    actor_user_agent: str | None = None,
) -> CollaborativeAccountUpsertResult:
    """
    Crea o actualiza una cuenta colaborativa validándola contra GLPI.

    La contraseña GLPI no se guarda.
    La contraseña IMAP sí se guarda cifrada si se proporciona.
    No se usan triggers: updated_at se modifica explícitamente desde la aplicación.
    """
    email = normalize_email(account_email)
    login = normalize_login(glpi_login)

    glpi_result = await GlpiService().validate_account_manager_login(
        login=login,
        password=glpi_password,
    )

    if not glpi_result.ok:
        raise ValueError(glpi_result.message)

    glpi_instance = _get_or_create_default_glpi_instance(db)
    now = _now()

    account = db.execute(
        select(CollaborativeAccount).where(CollaborativeAccount.email == email)
    ).scalar_one_or_none()

    is_new = account is None

    if account is None:
        account = CollaborativeAccount(
            email=email,
            display_name=display_name or email,
            status="active",
            glpi_instance_id=glpi_instance.id,
            glpi_user_id=glpi_result.glpi_user_id,
            glpi_login=login,
            glpi_profile_name=glpi_result.required_profile,
            last_glpi_validation_at=now,
            archive_root=settings.MAIL_ARCHIVE_ROOT,
            archive_subdir=make_archive_subdir(email),
            ingestion_enabled=ingestion_enabled,
            created_by_login=login,
            notes="Cuenta creada desde API interna de gestor-tickets.",
        )
        db.add(account)
    else:
        account.display_name = display_name or account.display_name or email
        account.status = "active"
        account.glpi_instance_id = glpi_instance.id
        account.glpi_user_id = glpi_result.glpi_user_id
        account.glpi_login = login
        account.glpi_profile_name = glpi_result.required_profile
        account.last_glpi_validation_at = now
        account.ingestion_enabled = ingestion_enabled
        account.updated_at = now

    if imap_host:
        account.imap_host = imap_host.strip()
    if imap_username:
        account.imap_username = imap_username.strip()
    if imap_password:
        account.imap_password_ciphertext = encrypt_text(imap_password)
        account.imap_last_validated_at = now

    db.flush()

    owner_user = _get_or_create_owner_user(
        db,
        account=account,
        display_name=display_name or glpi_result.glpi_user_name or login,
    )

    create_audit_log(
        db,
        action="collaborative_account_upsert",
        entity_type="collaborative_account",
        entity_id=account.id,
        account_id=account.id,
        actor_user_id=owner_user.id,
        actor_login_identifier=login,
        before=None,
        after={
            "email": account.email,
            "glpi_login": account.glpi_login,
            "glpi_user_id": account.glpi_user_id,
            "glpi_profile_name": account.glpi_profile_name,
            "is_new": is_new,
        },
        ip_address=actor_ip,
        user_agent=actor_user_agent,
    )

    db.commit()
    db.refresh(account)
    db.refresh(owner_user)

    message = (
        "Cuenta colaborativa creada correctamente."
        if is_new
        else "Cuenta colaborativa actualizada correctamente."
    )

    return CollaborativeAccountUpsertResult(
        account=account,
        owner_user=owner_user,
        message=message,
    )


def list_collaborative_accounts(db: Session) -> list[CollaborativeAccount]:
    return list(
        db.execute(
            select(CollaborativeAccount).order_by(CollaborativeAccount.email.asc())
        ).scalars()
    )
