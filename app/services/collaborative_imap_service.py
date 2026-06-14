from __future__ import annotations

import imaplib
from dataclasses import dataclass
from datetime import datetime, timezone

from sqlalchemy import select
from sqlalchemy.orm import Session

from app.core.security import decrypt_text, encrypt_text
from app.models import CollaborativeAccount
from app.services.audit_service import create_audit_log


@dataclass(frozen=True)
class ImapTestResult:
    ok: bool
    message_count: int | None
    message: str


def _now() -> datetime:
    return datetime.now(timezone.utc)


def _clean_text(value: str) -> str:
    return (value or "").strip()


def _parse_message_count(data) -> int | None:
    if not data:
        return None

    first = data[0]

    if isinstance(first, bytes):
        first = first.decode("utf-8", errors="ignore")

    try:
        return int(str(first).strip())
    except Exception:
        return None


def test_imap_connection_readonly(
    *,
    host: str,
    port: int,
    use_ssl: bool,
    username: str,
    password: str,
    mailbox: str = "INBOX",
    timeout_seconds: int = 30,
) -> ImapTestResult:
    """
    Prueba la conexión IMAP en modo seguro.

    Garantías de esta función:
      - Usa EXAMINE mediante select(..., readonly=True).
      - No ejecuta FETCH.
      - No ejecuta STORE.
      - No modifica FLAGS.
      - No marca mensajes como leídos.
    """
    host = _clean_text(host)
    username = _clean_text(username)
    mailbox = _clean_text(mailbox) or "INBOX"

    if not host:
        raise ValueError("Debes indicar el host IMAP.")

    if not username:
        raise ValueError("Debes indicar el usuario IMAP.")

    if not password:
        raise ValueError("Debes indicar la contraseña IMAP.")

    connection = None

    try:
        if use_ssl:
            connection = imaplib.IMAP4_SSL(host=host, port=port, timeout=timeout_seconds)
        else:
            connection = imaplib.IMAP4(host=host, port=port, timeout=timeout_seconds)

        login_status, login_data = connection.login(username, password)
        if login_status != "OK":
            raise ValueError(f"Login IMAP rechazado: {login_data!r}")

        status, data = connection.select(mailbox=mailbox, readonly=True)
        if status != "OK":
            raise ValueError(f"No se pudo abrir el buzón en solo lectura: {data!r}")

        message_count = _parse_message_count(data)

        try:
            connection.close()
        except Exception:
            pass

        return ImapTestResult(
            ok=True,
            message_count=message_count,
            message="Conexión IMAP válida usando modo solo lectura.",
        )

    except imaplib.IMAP4.error as exc:
        raise ValueError(f"Error IMAP: {exc}") from exc

    except OSError as exc:
        raise ValueError(f"Error de conexión IMAP: {exc}") from exc

    finally:
        if connection is not None:
            try:
                connection.logout()
            except Exception:
                pass


def configure_collaborative_account_imap(
    db: Session,
    *,
    account_id: int,
    imap_host: str,
    imap_port: int,
    imap_use_ssl: bool,
    imap_username: str,
    imap_password: str,
    mailbox: str = "INBOX",
    actor_login_identifier: str | None = None,
    ip_address: str | None = None,
    user_agent: str | None = None,
) -> tuple[CollaborativeAccount, ImapTestResult]:
    account = db.execute(
        select(CollaborativeAccount).where(CollaborativeAccount.id == account_id)
    ).scalar_one_or_none()

    if account is None:
        raise ValueError("La cuenta colaborativa no existe.")

    result = test_imap_connection_readonly(
        host=imap_host,
        port=imap_port,
        use_ssl=imap_use_ssl,
        username=imap_username,
        password=imap_password,
        mailbox=mailbox,
    )

    now = _now()

    account.imap_host = _clean_text(imap_host)
    account.imap_port = imap_port
    account.imap_use_ssl = imap_use_ssl
    account.imap_username = _clean_text(imap_username)
    account.imap_password_ciphertext = encrypt_text(imap_password)
    account.imap_last_validated_at = now
    account.updated_at = now

    create_audit_log(
        db,
        action="collaborative_account_imap_configured",
        entity_type="collaborative_account",
        entity_id=account.id,
        account_id=account.id,
        actor_login_identifier=actor_login_identifier,
        after={
            "email": account.email,
            "imap_host": account.imap_host,
            "imap_port": account.imap_port,
            "imap_use_ssl": account.imap_use_ssl,
            "imap_username": account.imap_username,
            "mailbox": mailbox,
            "readonly_mode": True,
            "message_count": result.message_count,
        },
        ip_address=ip_address,
        user_agent=user_agent,
    )

    db.commit()
    db.refresh(account)

    return account, result


def test_stored_collaborative_account_imap(
    db: Session,
    *,
    account_id: int,
    mailbox: str = "INBOX",
) -> tuple[CollaborativeAccount, ImapTestResult]:
    account = db.execute(
        select(CollaborativeAccount).where(CollaborativeAccount.id == account_id)
    ).scalar_one_or_none()

    if account is None:
        raise ValueError("La cuenta colaborativa no existe.")

    if not account.imap_host or not account.imap_username or not account.imap_password_ciphertext:
        raise ValueError("La cuenta colaborativa no tiene configuración IMAP completa.")

    password = decrypt_text(account.imap_password_ciphertext)

    result = test_imap_connection_readonly(
        host=account.imap_host,
        port=account.imap_port,
        use_ssl=account.imap_use_ssl,
        username=account.imap_username,
        password=password,
        mailbox=mailbox,
    )

    account.imap_last_validated_at = _now()
    account.updated_at = _now()
    db.commit()
    db.refresh(account)

    return account, result
