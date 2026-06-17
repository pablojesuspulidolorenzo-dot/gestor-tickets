from sqlalchemy.orm import Session
from sqlalchemy import text
from datetime import datetime, timezone

from app.core.security import decrypt_text, encrypt_text


def _now() -> datetime:
    return datetime.now(timezone.utc)


def get_account_settings(db: Session, *, account_id: int) -> dict:
    row = db.execute(
        text("""
            SELECT
                ca.id,
                ca.email,
                ca.display_name,
                ca.status,
                ca.glpi_login,
                ca.glpi_profile_name,
                ca.notes,
                ca.imap_host,
                ca.imap_username,
                ca.imap_password_ciphertext,
                ca.imap_port,
                ca.imap_use_ssl,
                ca.imap_last_validated_at,
                ca.ingestion_enabled,
                ca.last_glpi_validation_at,
                gi.id AS glpi_instance_id,
                gi.name AS glpi_name,
                gi.base_url AS glpi_base_url,
                gi.app_token_ciphertext,
                gi.default_entity_id,
                gi.default_group_id,
                gi.verify_tls,
                gi.active AS glpi_active
            FROM gestor_tickets.collaborative_accounts ca
            LEFT JOIN gestor_tickets.glpi_instances gi
              ON gi.id = ca.glpi_instance_id
            WHERE ca.id = :account_id
            LIMIT 1
        """),
        {"account_id": account_id},
    ).mappings().first()

    if not row:
        raise ValueError("Cuenta no encontrada.")

    d = dict(row)
    d["imap_password_masked"] = "••••••••" if d.get("imap_password_ciphertext") else ""
    d["glpi_token_masked"] = "••••••••" if d.get("app_token_ciphertext") else ""
    d.pop("imap_password_ciphertext", None)
    d.pop("app_token_ciphertext", None)
    return d


def update_account_info(
    db: Session,
    *,
    account_id: int,
    display_name: str,
    notes: str | None = None,
) -> None:
    db.execute(
        text("""
            UPDATE gestor_tickets.collaborative_accounts
            SET display_name = :display_name,
                notes = :notes,
                updated_at = :now
            WHERE id = :account_id
        """),
        {"account_id": account_id, "display_name": display_name, "notes": notes, "now": _now()},
    )
    db.commit()


def update_account_imap(
    db: Session,
    *,
    account_id: int,
    imap_host: str,
    imap_username: str,
    imap_password: str | None,
) -> None:
    if imap_password and imap_password.strip():
        ciphertext = encrypt_text(imap_password.strip())
        db.execute(
            text("""
                UPDATE gestor_tickets.collaborative_accounts
                SET imap_host = :host,
                    imap_username = :username,
                    imap_password_ciphertext = :ciphertext,
                    updated_at = :now
                WHERE id = :account_id
            """),
            {
                "account_id": account_id,
                "host": imap_host.strip(),
                "username": imap_username.strip(),
                "ciphertext": ciphertext,
                "now": _now(),
            },
        )
    else:
        db.execute(
            text("""
                UPDATE gestor_tickets.collaborative_accounts
                SET imap_host = :host,
                    imap_username = :username,
                    updated_at = :now
                WHERE id = :account_id
            """),
            {
                "account_id": account_id,
                "host": imap_host.strip(),
                "username": imap_username.strip(),
                "now": _now(),
            },
        )
    db.commit()


def update_account_glpi(
    db: Session,
    *,
    account_id: int,
    glpi_instance_id: int,
    base_url: str,
    glpi_name: str,
    app_token: str | None,
    verify_tls: bool,
) -> None:
    if app_token and app_token.strip():
        ciphertext = encrypt_text(app_token.strip())
        db.execute(
            text("""
                UPDATE gestor_tickets.glpi_instances
                SET base_url = :base_url,
                    name = :name,
                    app_token_ciphertext = :ciphertext,
                    verify_tls = :verify_tls,
                    updated_at = :now
                WHERE id = :glpi_instance_id
            """),
            {
                "glpi_instance_id": glpi_instance_id,
                "base_url": base_url.strip(),
                "name": glpi_name.strip(),
                "ciphertext": ciphertext,
                "verify_tls": verify_tls,
                "now": _now(),
            },
        )
    else:
        db.execute(
            text("""
                UPDATE gestor_tickets.glpi_instances
                SET base_url = :base_url,
                    name = :name,
                    verify_tls = :verify_tls,
                    updated_at = :now
                WHERE id = :glpi_instance_id
            """),
            {
                "glpi_instance_id": glpi_instance_id,
                "base_url": base_url.strip(),
                "name": glpi_name.strip(),
                "verify_tls": verify_tls,
                "now": _now(),
            },
        )
    db.commit()
