from __future__ import annotations

from dataclasses import dataclass
from datetime import datetime, timezone

from sqlalchemy import select
from sqlalchemy.orm import Session

from app.core.security import verify_password
from app.models import AccountUser, CollaborativeAccount
from app.services.audit_service import create_audit_log
from app.services.glpi_service import GlpiService


RECOVERABLE_ACCOUNT_STATUSES = {"active", "error_auth", "error_connection", "error_unknown"}


@dataclass(frozen=True)
class AuthenticatedSessionUser:
    account_id: int
    user_id: int
    account_email: str
    login_identifier: str
    display_name: str
    role: str
    auth_mode: str
    can_manage_users: bool
    can_manage_account_config: bool
    can_read_account_mail: bool
    can_reply_from_account: bool
    can_create_glpi_ticket: bool
    can_update_glpi_ticket: bool
    can_link_tickets: bool
    can_manage_ai: bool
    assistant_mode: bool = True


def _now() -> datetime:
    return datetime.now(timezone.utc)


def _normalize_login(value: str) -> str:
    return (value or "").strip().lower()


def _split_collaborator_login(login_identifier: str) -> tuple[str, str] | None:
    if "#" not in login_identifier:
        return None

    username, account_email = login_identifier.split("#", 1)
    username = username.strip().lower()
    account_email = account_email.strip().lower()

    if not username or not account_email:
        return None

    return username, account_email


async def authenticate_session_user(
    db: Session,
    *,
    login_identifier: str,
    password: str,
    ip_address: str | None = None,
    user_agent: str | None = None,
) -> AuthenticatedSessionUser:
    """
    Autentica usuarios de la aplicación.

    Modos soportados:
      - Cuenta principal: sistemas-tic@gestor-tickets.es
        Se valida contra GLPI usando collaborative_accounts.glpi_login.
      - Colaborador local: usuario#sistemas-tic@gestor-tickets.es
        Se validará contra password_hash local cuando creemos colaboradores.

    No se guarda la contraseña introducida.
    """
    clean_login = _normalize_login(login_identifier)
    if not clean_login:
        raise ValueError("Debes indicar un usuario.")

    if not password:
        raise ValueError("Debes indicar una contraseña.")

    collaborator = _split_collaborator_login(clean_login)

    if collaborator:
        username_local, account_email = collaborator

        account = db.execute(
            select(CollaborativeAccount).where(CollaborativeAccount.email == account_email)
        ).scalar_one_or_none()

        if not account or account.status not in RECOVERABLE_ACCOUNT_STATUSES:
            raise ValueError("La cuenta colaborativa no existe o no permite acceso.")

        user = db.execute(
            select(AccountUser).where(
                AccountUser.account_id == account.id,
                AccountUser.username_local == username_local,
                AccountUser.auth_mode == "local_collaborator",
            )
        ).scalar_one_or_none()

        if not user or user.status != "active" or not user.password_hash:
            raise ValueError("Usuario colaborador no válido o no activo.")

        if not verify_password(password, user.password_hash):
            user.failed_login_count = (user.failed_login_count or 0) + 1
            user.updated_at = _now()
            db.commit()
            raise ValueError("Credenciales incorrectas.")

        user.failed_login_count = 0
        user.last_login_at = _now()
        user.updated_at = _now()

        create_audit_log(
            db,
            action="session_login",
            entity_type="account_user",
            entity_id=user.id,
            account_id=account.id,
            actor_user_id=user.id,
            actor_login_identifier=clean_login,
            after={"auth_mode": user.auth_mode, "role": user.role},
            ip_address=ip_address,
            user_agent=user_agent,
        )

        db.commit()

        return AuthenticatedSessionUser(
            account_id=account.id,
            user_id=user.id,
            account_email=account.email,
            login_identifier=clean_login,
            display_name=user.display_name,
            role=user.role,
            auth_mode=user.auth_mode,
            can_manage_users=bool(user.can_manage_users),
            can_manage_account_config=bool(user.can_manage_account_config),
            can_read_account_mail=bool(user.can_read_account_mail),
            can_reply_from_account=bool(user.can_reply_from_account),
            can_create_glpi_ticket=bool(user.can_create_glpi_ticket),
            can_update_glpi_ticket=bool(user.can_update_glpi_ticket),
            can_link_tickets=bool(user.can_link_tickets),
            can_manage_ai=bool(user.can_manage_ai),
            assistant_mode=bool(user.assistant_mode) if user.assistant_mode is not None else True,
        )

    account = db.execute(
        select(CollaborativeAccount).where(CollaborativeAccount.email == clean_login)
    ).scalar_one_or_none()

    if not account or account.status not in RECOVERABLE_ACCOUNT_STATUSES:
        raise ValueError("La cuenta colaborativa no existe o no permite acceso.")

    glpi_result = await GlpiService().validate_account_manager_login(
        login=account.glpi_login,
        password=password,
    )

    if not glpi_result.ok:
        raise ValueError(glpi_result.message)

    user = db.execute(
        select(AccountUser).where(
            AccountUser.account_id == account.id,
            AccountUser.auth_mode == "glpi_account_manager",
            AccountUser.login_identifier == account.email,
        )
    ).scalar_one_or_none()

    if not user or user.status != "active":
        raise ValueError("La cuenta existe, pero no tiene usuario propietario activo.")

    now = _now()
    user.failed_login_count = 0
    user.last_login_at = now
    user.updated_at = now
    account.last_glpi_validation_at = now
    account.updated_at = now

    create_audit_log(
        db,
        action="session_login",
        entity_type="account_user",
        entity_id=user.id,
        account_id=account.id,
        actor_user_id=user.id,
        actor_login_identifier=clean_login,
        after={
            "auth_mode": user.auth_mode,
            "role": user.role,
            "glpi_login": account.glpi_login,
            "glpi_user_id": account.glpi_user_id,
        },
        ip_address=ip_address,
        user_agent=user_agent,
    )

    db.commit()

    return AuthenticatedSessionUser(
        account_id=account.id,
        user_id=user.id,
        account_email=account.email,
        login_identifier=clean_login,
        display_name=user.display_name,
        role=user.role,
        auth_mode=user.auth_mode,
        can_manage_users=bool(user.can_manage_users),
        can_manage_account_config=bool(user.can_manage_account_config),
        can_read_account_mail=bool(user.can_read_account_mail),
        can_reply_from_account=bool(user.can_reply_from_account),
        can_create_glpi_ticket=bool(user.can_create_glpi_ticket),
        can_update_glpi_ticket=bool(user.can_update_glpi_ticket),
        can_link_tickets=bool(user.can_link_tickets),
        can_manage_ai=bool(user.can_manage_ai),
        assistant_mode=bool(user.assistant_mode) if user.assistant_mode is not None else True,
    )
