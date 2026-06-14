from __future__ import annotations

import email
import imaplib
import re
from dataclasses import dataclass
from email.header import decode_header, make_header

from sqlalchemy import select
from sqlalchemy.orm import Session

from app.core.security import decrypt_text
from app.models import CollaborativeAccount


SAFETY_NOTES = [
    "La bandeja se abre con EXAMINE mediante select(..., readonly=True).",
    "La búsqueda usa UID SEARCH ALL.",
    "La lectura de cabeceras usa BODY.PEEK[HEADER.FIELDS ...].",
    "No se ejecuta BODY[] normal.",
    "No se ejecuta STORE.",
    "No se modifican FLAGS.",
    "No se marca ningún correo como leído.",
]


@dataclass(frozen=True)
class PreviewMessage:
    uid: str
    message_id: str | None
    subject: str
    from_: str
    to: str | None
    cc: str | None
    date: str | None
    flags: list[str]
    seen: bool
    answered: bool
    has_references: bool


@dataclass(frozen=True)
class MailboxPreview:
    ok: bool
    account: CollaborativeAccount
    mailbox: str
    total_messages: int | None
    messages: list[PreviewMessage]


def _clean_text(value: str | None) -> str:
    return (value or "").strip()


def _decode_header_value(value: str | None) -> str:
    value = _clean_text(value)
    if not value:
        return ""

    try:
        return str(make_header(decode_header(value)))
    except Exception:
        return value


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


def _parse_flags(raw) -> list[str]:
    if raw is None:
        return []

    if isinstance(raw, bytes):
        text = raw.decode("utf-8", errors="ignore")
    else:
        text = str(raw)

    match = re.search(r"FLAGS \((.*?)\)", text, re.IGNORECASE)
    if not match:
        return []

    return [item.strip() for item in match.group(1).split() if item.strip()]


def _extract_header_bytes(fetch_data) -> tuple[bytes | None, list[str]]:
    header_bytes = None
    flags: list[str] = []

    for part in fetch_data or []:
        if isinstance(part, tuple):
            meta = part[0]
            body = part[1]

            if isinstance(body, bytes):
                header_bytes = body

            parsed_flags = _parse_flags(meta)
            if parsed_flags:
                flags = parsed_flags

        elif isinstance(part, bytes):
            parsed_flags = _parse_flags(part)
            if parsed_flags:
                flags = parsed_flags

    return header_bytes, flags


def preview_collaborative_mailbox(
    db: Session,
    *,
    account_id: int,
    mailbox: str = "INBOX",
    limit: int = 20,
) -> MailboxPreview:
    account = db.execute(
        select(CollaborativeAccount).where(CollaborativeAccount.id == account_id)
    ).scalar_one_or_none()

    if account is None:
        raise ValueError("La cuenta colaborativa no existe.")

    if not account.imap_host or not account.imap_username or not account.imap_password_ciphertext:
        raise ValueError("La cuenta colaborativa no tiene configuración IMAP completa.")

    mailbox = _clean_text(mailbox) or "INBOX"
    limit = max(1, min(int(limit), 50))

    password = decrypt_text(account.imap_password_ciphertext)

    connection = None

    try:
        if account.imap_use_ssl:
            connection = imaplib.IMAP4_SSL(
                host=account.imap_host,
                port=account.imap_port,
                timeout=30,
            )
        else:
            connection = imaplib.IMAP4(
                host=account.imap_host,
                port=account.imap_port,
                timeout=30,
            )

        login_status, login_data = connection.login(account.imap_username, password)
        if login_status != "OK":
            raise ValueError(f"Login IMAP rechazado: {login_data!r}")

        status, select_data = connection.select(mailbox=mailbox, readonly=True)
        if status != "OK":
            raise ValueError(f"No se pudo abrir el buzón en solo lectura: {select_data!r}")

        total_messages = _parse_message_count(select_data)

        search_status, search_data = connection.uid("SEARCH", None, "ALL")
        if search_status != "OK":
            raise ValueError(f"No se pudo buscar en el buzón: {search_data!r}")

        uid_blob = search_data[0] if search_data else b""
        if isinstance(uid_blob, bytes):
            all_uids = uid_blob.decode("ascii", errors="ignore").split()
        else:
            all_uids = str(uid_blob).split()

        selected_uids = list(reversed(all_uids[-limit:]))

        messages: list[PreviewMessage] = []

        header_fields = (
            "BODY.PEEK[HEADER.FIELDS "
            "(MESSAGE-ID DATE FROM TO CC SUBJECT REFERENCES IN-REPLY-TO)]"
        )

        for uid in selected_uids:
            fetch_status, fetch_data = connection.uid(
                "FETCH",
                uid,
                f"(UID FLAGS {header_fields})",
            )

            if fetch_status != "OK":
                continue

            header_bytes, flags = _extract_header_bytes(fetch_data)
            if not header_bytes:
                continue

            msg = email.message_from_bytes(header_bytes)

            references = _clean_text(msg.get("References"))
            in_reply_to = _clean_text(msg.get("In-Reply-To"))

            messages.append(
                PreviewMessage(
                    uid=uid,
                    message_id=_clean_text(msg.get("Message-ID")) or None,
                    subject=_decode_header_value(msg.get("Subject")) or "(Sin asunto)",
                    from_=_decode_header_value(msg.get("From")) or "(Sin remitente)",
                    to=_decode_header_value(msg.get("To")) or None,
                    cc=_decode_header_value(msg.get("Cc")) or None,
                    date=_decode_header_value(msg.get("Date")) or None,
                    flags=flags,
                    seen="\\Seen" in flags,
                    answered="\\Answered" in flags,
                    has_references=bool(references or in_reply_to),
                )
            )

        try:
            connection.close()
        except Exception:
            pass

        return MailboxPreview(
            ok=True,
            account=account,
            mailbox=mailbox,
            total_messages=total_messages,
            messages=messages,
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
