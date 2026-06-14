from __future__ import annotations

from sqlalchemy import text
from sqlalchemy.orm import Session

from app.core.security import hash_password


PERMISSION_FIELDS = {
    "can_manage_users",
    "can_manage_account_config",
    "can_read_account_mail",
    "can_reply_from_account",
    "can_create_glpi_ticket",
    "can_update_glpi_ticket",
    "can_link_tickets",
    "can_manage_ai",
}


def list_account_users(db: Session, *, account_id: int) -> list[dict]:
    rows = db.execute(
        text("""
            SELECT
                id,
                auth_mode::text AS auth_mode,
                login_identifier,
                username_local,
                display_name,
                contact_email,
                role::text AS role,
                status::text AS status,
                can_manage_users,
                can_manage_account_config,
                can_read_account_mail,
                can_reply_from_account,
                can_create_glpi_ticket,
                can_update_glpi_ticket,
                can_link_tickets,
                can_manage_ai,
                failed_login_count,
                last_login_at,
                created_at,
                updated_at
            FROM gestor_tickets.account_users
            WHERE account_id = :account_id
            ORDER BY
                CASE role::text
                    WHEN 'owner' THEN 1
                    WHEN 'admin' THEN 2
                    WHEN 'technician' THEN 3
                    WHEN 'collaborator' THEN 4
                    ELSE 5
                END,
                display_name,
                id
        """),
        {"account_id": account_id},
    ).mappings().all()
    return [dict(row) for row in rows]


def get_user_permissions(db: Session, *, user_id: int, account_id: int) -> dict:
    row = db.execute(
        text("""
            SELECT
                can_manage_users,
                can_manage_account_config,
                can_read_account_mail,
                can_reply_from_account,
                can_create_glpi_ticket,
                can_update_glpi_ticket,
                can_link_tickets,
                can_manage_ai
            FROM gestor_tickets.account_users
            WHERE id = :user_id
              AND account_id = :account_id
              AND status = 'active'
        """),
        {"user_id": user_id, "account_id": account_id},
    ).mappings().first()
    return dict(row) if row else {field: False for field in PERMISSION_FIELDS}


def create_local_collaborator(
    db: Session,
    *,
    account_id: int,
    username_local: str,
    display_name: str,
    password: str,
    contact_email: str | None,
    role: str,
    permissions: dict[str, bool],
    created_by_user_id: int,
) -> int:
    username = (username_local or "").strip().lower()
    if not username:
        raise ValueError("El usuario local es obligatorio.")
    if "#" in username or "@" in username:
        raise ValueError("El usuario local no debe incluir # ni @.")
    if not display_name.strip():
        raise ValueError("El nombre visible es obligatorio.")
    if not password:
        raise ValueError("La contraseña local es obligatoria.")

    account_email = db.execute(
        text("SELECT email FROM gestor_tickets.collaborative_accounts WHERE id = :account_id"),
        {"account_id": account_id},
    ).scalar_one_or_none()
    if not account_email:
        raise ValueError("La cuenta colaborativa no existe.")

    login_identifier = f"{username}#{account_email}".lower()
    values = {field: bool(permissions.get(field)) for field in PERMISSION_FIELDS}

    user_id = db.execute(
        text("""
            INSERT INTO gestor_tickets.account_users (
                account_id,
                auth_mode,
                login_identifier,
                username_local,
                password_hash,
                display_name,
                contact_email,
                role,
                status,
                can_manage_users,
                can_manage_account_config,
                can_read_account_mail,
                can_reply_from_account,
                can_create_glpi_ticket,
                can_update_glpi_ticket,
                can_link_tickets,
                can_manage_ai,
                created_by_user_id,
                updated_at
            )
            VALUES (
                :account_id,
                'local_collaborator',
                :login_identifier,
                :username_local,
                :password_hash,
                :display_name,
                :contact_email,
                :role,
                'active',
                :can_manage_users,
                :can_manage_account_config,
                :can_read_account_mail,
                :can_reply_from_account,
                :can_create_glpi_ticket,
                :can_update_glpi_ticket,
                :can_link_tickets,
                :can_manage_ai,
                :created_by_user_id,
                now()
            )
            RETURNING id
        """),
        {
            "account_id": account_id,
            "login_identifier": login_identifier,
            "username_local": username,
            "password_hash": hash_password(password),
            "display_name": display_name.strip(),
            "contact_email": (contact_email or "").strip() or None,
            "role": role,
            "created_by_user_id": created_by_user_id,
            **values,
        },
    ).scalar_one()
    db.commit()
    return int(user_id)


def update_local_collaborator(
    db: Session,
    *,
    account_id: int,
    user_id: int,
    display_name: str,
    contact_email: str | None,
    role: str,
    permissions: dict[str, bool],
) -> None:
    values = {field: bool(permissions.get(field)) for field in PERMISSION_FIELDS}
    result = db.execute(
        text("""
            UPDATE gestor_tickets.account_users
            SET display_name = :display_name,
                contact_email = :contact_email,
                role = :role,
                can_manage_users = :can_manage_users,
                can_manage_account_config = :can_manage_account_config,
                can_read_account_mail = :can_read_account_mail,
                can_reply_from_account = :can_reply_from_account,
                can_create_glpi_ticket = :can_create_glpi_ticket,
                can_update_glpi_ticket = :can_update_glpi_ticket,
                can_link_tickets = :can_link_tickets,
                can_manage_ai = :can_manage_ai,
                updated_at = now()
            WHERE id = :user_id
              AND account_id = :account_id
              AND auth_mode = 'local_collaborator'
        """),
        {
            "account_id": account_id,
            "user_id": user_id,
            "display_name": display_name.strip(),
            "contact_email": (contact_email or "").strip() or None,
            "role": role,
            **values,
        },
    )
    if result.rowcount != 1:
        raise ValueError("No se encontró el colaborador local.")
    db.commit()


def set_local_collaborator_status(db: Session, *, account_id: int, user_id: int, status: str) -> None:
    if status not in {"active", "disabled"}:
        raise ValueError("Estado no permitido.")

    result = db.execute(
        text("""
            UPDATE gestor_tickets.account_users
            SET status = :status,
                updated_at = now()
            WHERE id = :user_id
              AND account_id = :account_id
              AND auth_mode = 'local_collaborator'
        """),
        {"account_id": account_id, "user_id": user_id, "status": status},
    )
    if result.rowcount != 1:
        raise ValueError("No se encontró el colaborador local.")
    db.commit()
