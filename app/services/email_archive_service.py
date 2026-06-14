from __future__ import annotations

import hashlib
import imaplib
import json
import re
from dataclasses import dataclass
from datetime import datetime, timezone
from email import message_from_bytes
from email.header import decode_header, make_header
from email.policy import default
from email.utils import getaddresses, parsedate_to_datetime, parseaddr
from pathlib import Path

from sqlalchemy import text
from sqlalchemy.orm import Session

from app.core.config import settings
from app.core.security import decrypt_text
from app.models import CollaborativeAccount


ARCHIVE_SAFETY_NOTES = [
    "El buzón se abre con EXAMINE mediante select(..., readonly=True).",
    "El mensaje se obtiene con UID FETCH y BODY.PEEK[].",
    "No se ejecuta BODY[] normal.",
    "No se ejecuta STORE.",
    "No se modifican FLAGS.",
    "No se marca ningún correo como leído.",
    "El .eml se guarda en archivo local del sistema.",
]


@dataclass(frozen=True)
class ArchivedEmailResult:
    ok: bool
    account: CollaborativeAccount
    email_message_id: int
    occurrence_id: int
    mailbox: str
    uid: str
    message_id: str | None
    subject: str | None
    eml_storage_path: str
    eml_sha256: str
    size_bytes: int
    seen_before: bool
    seen_after: bool
    message: str


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


def _normalize_subject(value: str | None) -> str | None:
    value = _decode_header_value(value)
    value = re.sub(r"^\s*(re|rv|fw|fwd)\s*:\s*", "", value, flags=re.IGNORECASE)
    value = re.sub(r"\s+", " ", value).strip().lower()
    return value or None


def _parse_flags(raw) -> list[str]:
    if raw is None:
        return []

    if isinstance(raw, bytes):
        text_value = raw.decode("utf-8", errors="ignore")
    else:
        text_value = str(raw)

    match = re.search(r"FLAGS \((.*?)\)", text_value, re.IGNORECASE)
    if not match:
        return []

    return [item.strip() for item in match.group(1).split() if item.strip()]


def _extract_raw_message_and_flags(fetch_data) -> tuple[bytes | None, list[str]]:
    raw_message = None
    flags: list[str] = []

    for part in fetch_data or []:
        if isinstance(part, tuple):
            meta = part[0]
            body = part[1]

            parsed_flags = _parse_flags(meta)
            if parsed_flags:
                flags = parsed_flags

            if isinstance(body, bytes) and body:
                raw_message = body

        elif isinstance(part, bytes):
            parsed_flags = _parse_flags(part)
            if parsed_flags:
                flags = parsed_flags

    return raw_message, flags


def _get_uidvalidity(connection) -> str | None:
    try:
        status, data = connection.response("UIDVALIDITY")
        if status == "OK" and data:
            first = data[0]
            if isinstance(first, bytes):
                return first.decode("ascii", errors="ignore").strip()
            return str(first).strip()
    except Exception:
        return None

    return None


def _get_account_and_password(db: Session, account_id: int) -> tuple[CollaborativeAccount, str]:
    account = db.get(CollaborativeAccount, account_id)

    if account is None:
        raise ValueError("La cuenta colaborativa no existe.")

    if not account.imap_host or not account.imap_username or not account.imap_password_ciphertext:
        raise ValueError("La cuenta colaborativa no tiene configuración IMAP completa.")

    return account, decrypt_text(account.imap_password_ciphertext)


def _connect(account: CollaborativeAccount, password: str):
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

    return connection


def _safe_path_part(value: str) -> str:
    value = value.strip().lower()
    value = value.replace("@", "__at__")
    value = re.sub(r"[^a-z0-9_.-]+", "_", value)
    value = value.strip("._-")
    return value or "item"


def _direction_for_mailbox(mailbox: str) -> str:
    lowered = mailbox.lower()
    if "sent" in lowered or "enviad" in lowered:
        return "outbound"
    return "inbound"


def _folder_kind_for_mailbox(mailbox: str) -> str:
    lowered = mailbox.lower()
    if lowered == "inbox":
        return "inbox"
    if "sent" in lowered or "enviad" in lowered:
        return "sent"
    return "other"


def _part_text(part) -> str:
    try:
        content = part.get_content()
        if isinstance(content, str):
            return content
    except Exception:
        pass

    payload = part.get_payload(decode=True)
    if not payload:
        return ""

    charset = part.get_content_charset() or "utf-8"

    try:
        return payload.decode(charset, errors="replace")
    except Exception:
        return payload.decode("utf-8", errors="replace")


def _extract_text_preview(message) -> str | None:
    parts: list[str] = []

    if message.is_multipart():
        for part in message.walk():
            if part.is_multipart():
                continue

            if part.get_content_disposition() == "attachment":
                continue

            if part.get_content_type() == "text/plain":
                text_value = _part_text(part).strip()
                if text_value:
                    parts.append(text_value)
    else:
        if message.get_content_type() in {"text/plain", "text/html"}:
            text_value = _part_text(message).strip()
            if text_value:
                parts.append(text_value)

    preview = "\n\n".join(parts).strip()
    if not preview:
        return None

    preview = re.sub(r"\s+", " ", preview).strip()
    return preview[:1200]


def _has_attachments(message) -> bool:
    for part in message.walk():
        if part.get_content_disposition() == "attachment":
            return True
    return False


def _parsed_datetime(value: str | None):
    value = _clean_text(value)
    if not value:
        return None

    try:
        parsed = parsedate_to_datetime(value)
        if parsed.tzinfo is None:
            parsed = parsed.replace(tzinfo=timezone.utc)
        return parsed
    except Exception:
        return None


def _archive_path(account: CollaborativeAccount, mailbox: str, uidvalidity: str | None, uid: str, eml_sha256: str) -> tuple[str, str]:
    mailbox_part = _safe_path_part(mailbox)
    uidvalidity_part = _safe_path_part(uidvalidity or "unknown_uidvalidity")
    filename = f"{uid}_{eml_sha256[:16]}.eml"

    root = Path(settings.MAIL_ARCHIVE_ROOT)
    account_dir = _safe_path_part(account.archive_subdir or account.email)
    folder = root / account_dir / mailbox_part / uidvalidity_part
    folder.mkdir(parents=True, exist_ok=True)

    path = folder / filename
    return str(path), filename


def _insert_or_update_message(
    db: Session,
    *,
    account: CollaborativeAccount,
    parsed,
    raw_message: bytes,
    mailbox: str,
    uid: str,
    uidvalidity: str | None,
    flags: list[str],
    eml_storage_path: str,
    eml_filename: str,
    eml_sha256: str,
) -> tuple[int, int]:
    headers_blob = raw_message.split(b"\r\n\r\n", 1)[0]
    if headers_blob == raw_message:
        headers_blob = raw_message.split(b"\n\n", 1)[0]

    raw_headers_sha256 = hashlib.sha256(headers_blob).hexdigest()

    message_id = _clean_text(parsed.get("Message-ID")) or None
    subject = _decode_header_value(parsed.get("Subject")) or None
    subject_normalized = _normalize_subject(subject)
    from_name, from_email = parseaddr(_decode_header_value(parsed.get("From")))

    from_email = _clean_text(from_email).lower() or None
    from_name = _clean_text(from_name) or None

    sent_at = _parsed_datetime(parsed.get("Date"))
    direction = _direction_for_mailbox(mailbox)
    folder_kind = _folder_kind_for_mailbox(mailbox)
    body_preview = _extract_text_preview(parsed)
    has_attachments = _has_attachments(parsed)

    existing_id = None

    if message_id:
        existing_id = db.execute(
            text("""
                SELECT id
                FROM gestor_tickets.email_messages
                WHERE account_id = :account_id
                  AND message_id_header = :message_id_header
                LIMIT 1
            """),
            {
                "account_id": account.id,
                "message_id_header": message_id,
            },
        ).scalar_one_or_none()

    if existing_id is None:
        existing_id = db.execute(
            text("""
                SELECT id
                FROM gestor_tickets.email_messages
                WHERE account_id = :account_id
                  AND eml_sha256 = :eml_sha256
                LIMIT 1
            """),
            {
                "account_id": account.id,
                "eml_sha256": eml_sha256,
            },
        ).scalar_one_or_none()

    if existing_id is None:
        email_message_id = db.execute(
            text("""
                INSERT INTO gestor_tickets.email_messages (
                    account_id,
                    message_id_header,
                    eml_sha256,
                    raw_headers_sha256,
                    eml_storage_path,
                    eml_filename,
                    size_bytes,
                    source,
                    original_imap_account,
                    original_imap_folder,
                    original_imap_uid,
                    original_imap_uidvalidity,
                    source_description,
                    subject,
                    subject_normalized,
                    from_email,
                    from_name,
                    sent_at,
                    received_at,
                    direction,
                    has_attachments,
                    body_text_preview
                )
                VALUES (
                    :account_id,
                    :message_id_header,
                    :eml_sha256,
                    :raw_headers_sha256,
                    :eml_storage_path,
                    :eml_filename,
                    :size_bytes,
                    'collaborative_ingestion',
                    :original_imap_account,
                    :original_imap_folder,
                    :original_imap_uid,
                    :original_imap_uidvalidity,
                    :source_description,
                    :subject,
                    :subject_normalized,
                    :from_email,
                    :from_name,
                    :sent_at,
                    now(),
                    :direction,
                    :has_attachments,
                    :body_text_preview
                )
                RETURNING id
            """),
            {
                "account_id": account.id,
                "message_id_header": message_id,
                "eml_sha256": eml_sha256,
                "raw_headers_sha256": raw_headers_sha256,
                "eml_storage_path": eml_storage_path,
                "eml_filename": eml_filename,
                "size_bytes": len(raw_message),
                "original_imap_account": account.email,
                "original_imap_folder": mailbox,
                "original_imap_uid": uid,
                "original_imap_uidvalidity": uidvalidity,
                "source_description": "Archivado manual seguro desde preview IMAP BODY.PEEK[].",
                "subject": subject,
                "subject_normalized": subject_normalized,
                "from_email": from_email,
                "from_name": from_name,
                "sent_at": sent_at,
                "direction": direction,
                "has_attachments": has_attachments,
                "body_text_preview": body_preview,
            },
        ).scalar_one()
    else:
        email_message_id = int(existing_id)
        db.execute(
            text("""
                UPDATE gestor_tickets.email_messages
                SET
                    original_imap_folder = COALESCE(original_imap_folder, :original_imap_folder),
                    original_imap_uid = COALESCE(original_imap_uid, :original_imap_uid),
                    original_imap_uidvalidity = COALESCE(original_imap_uidvalidity, :original_imap_uidvalidity),
                    updated_at = now()
                WHERE id = :id
            """),
            {
                "id": email_message_id,
                "original_imap_folder": mailbox,
                "original_imap_uid": uid,
                "original_imap_uidvalidity": uidvalidity,
            },
        )

    unread_at_import = "\\Seen" not in flags

    occurrence_id = db.execute(
        text("""
            INSERT INTO gestor_tickets.email_message_occurrences (
                email_message_id,
                account_id,
                source_mailbox_email,
                folder_name,
                folder_kind,
                imap_uid,
                imap_uidvalidity,
                direction,
                flags_json,
                unread_at_import
            )
            VALUES (
                :email_message_id,
                :account_id,
                :source_mailbox_email,
                :folder_name,
                :folder_kind,
                :imap_uid,
                :imap_uidvalidity,
                :direction,
                CAST(:flags_json AS jsonb),
                :unread_at_import
            )
            ON CONFLICT (source_mailbox_email, folder_name, imap_uidvalidity, imap_uid)
            DO UPDATE SET
                email_message_id = EXCLUDED.email_message_id,
                account_id = EXCLUDED.account_id,
                direction = EXCLUDED.direction,
                flags_json = EXCLUDED.flags_json,
                unread_at_import = EXCLUDED.unread_at_import,
                last_seen_at = now()
            RETURNING id
        """),
        {
            "email_message_id": email_message_id,
            "account_id": account.id,
            "source_mailbox_email": account.email,
            "folder_name": mailbox,
            "folder_kind": folder_kind,
            "imap_uid": uid,
            "imap_uidvalidity": uidvalidity,
            "direction": direction,
            "flags_json": json.dumps(flags),
            "unread_at_import": unread_at_import,
        },
    ).scalar_one()

    db.execute(
        text("DELETE FROM gestor_tickets.email_recipients WHERE email_message_id = :id"),
        {"id": email_message_id},
    )

    position = 0
    for recipient_type, header_name in [("to", "To"), ("cc", "Cc"), ("reply_to", "Reply-To")]:
        raw_header = _decode_header_value(parsed.get(header_name))
        for display_name, addr in getaddresses([raw_header]):
            addr = _clean_text(addr).lower()
            display_name = _clean_text(display_name) or None
            if not addr:
                continue

            db.execute(
                text("""
                    INSERT INTO gestor_tickets.email_recipients (
                        email_message_id,
                        recipient_type,
                        email,
                        display_name,
                        position
                    )
                    VALUES (
                        :email_message_id,
                        :recipient_type,
                        :email,
                        :display_name,
                        :position
                    )
                """),
                {
                    "email_message_id": email_message_id,
                    "recipient_type": recipient_type,
                    "email": addr,
                    "display_name": display_name,
                    "position": position,
                },
            )
            position += 1

    return email_message_id, int(occurrence_id)


def archive_message_from_imap_readonly(
    db: Session,
    *,
    account_id: int,
    mailbox: str,
    uid: str,
) -> ArchivedEmailResult:
    account, password = _get_account_and_password(db, account_id)

    mailbox = _clean_text(mailbox) or "INBOX"
    uid = _clean_text(uid)

    if not uid:
        raise ValueError("Debes indicar el UID del mensaje.")

    connection = None

    try:
        connection = _connect(account, password)

        status, select_data = connection.select(mailbox=mailbox, readonly=True)
        if status != "OK":
            raise ValueError(f"No se pudo abrir el buzón en solo lectura: {select_data!r}")

        uidvalidity = _get_uidvalidity(connection)

        fetch_status, fetch_data = connection.uid(
            "FETCH",
            uid,
            "(UID FLAGS BODY.PEEK[])",
        )

        if fetch_status != "OK":
            raise ValueError(f"No se pudo leer el mensaje en modo seguro: {fetch_data!r}")

        raw_message, flags_before = _extract_raw_message_and_flags(fetch_data)

        if not raw_message:
            raise ValueError("No se recibió contenido del mensaje.")

        seen_before = "\\Seen" in flags_before

        eml_sha256 = hashlib.sha256(raw_message).hexdigest()
        eml_storage_path, eml_filename = _archive_path(
            account,
            mailbox,
            uidvalidity,
            uid,
            eml_sha256,
        )

        Path(eml_storage_path).write_bytes(raw_message)

        parsed = message_from_bytes(raw_message, policy=default)

        email_message_id, occurrence_id = _insert_or_update_message(
            db,
            account=account,
            parsed=parsed,
            raw_message=raw_message,
            mailbox=mailbox,
            uid=uid,
            uidvalidity=uidvalidity,
            flags=flags_before,
            eml_storage_path=eml_storage_path,
            eml_filename=eml_filename,
            eml_sha256=eml_sha256,
        )

        check_status, check_data = connection.uid(
            "FETCH",
            uid,
            "(UID FLAGS BODY.PEEK[HEADER.FIELDS (MESSAGE-ID)])",
        )
        if check_status == "OK":
            _, flags_after = _extract_raw_message_and_flags(check_data)
        else:
            flags_after = flags_before

        seen_after = "\\Seen" in flags_after

        db.commit()

        return ArchivedEmailResult(
            ok=True,
            account=account,
            email_message_id=email_message_id,
            occurrence_id=occurrence_id,
            mailbox=mailbox,
            uid=uid,
            message_id=_clean_text(parsed.get("Message-ID")) or None,
            subject=_decode_header_value(parsed.get("Subject")) or None,
            eml_storage_path=eml_storage_path,
            eml_sha256=eml_sha256,
            size_bytes=len(raw_message),
            seen_before=seen_before,
            seen_after=seen_after,
            message="Correo archivado en el sistema sin modificar el estado IMAP.",
        )

    except Exception:
        db.rollback()
        raise

    finally:
        if connection is not None:
            try:
                connection.logout()
            except Exception:
                pass


def find_archived_message_for_occurrence(
    db: Session,
    *,
    account_id: int,
    mailbox: str,
    uid: str,
) -> dict | None:
    """
    Busca si una ocurrencia IMAP ya está archivada en el sistema.

    No toca IMAP. Solo consulta PostgreSQL.
    """
    row = db.execute(
        text("""
            SELECT
                em.id AS email_message_id,
                emo.id AS occurrence_id,
                em.subject,
                em.message_id_header,
                em.eml_storage_path,
                em.eml_sha256,
                em.size_bytes,
                emo.unread_at_import,
                em.created_at AS archived_at
            FROM gestor_tickets.email_message_occurrences emo
            JOIN gestor_tickets.email_messages em
              ON em.id = emo.email_message_id
            WHERE emo.account_id = :account_id
              AND emo.folder_name = :folder_name
              AND emo.imap_uid = :imap_uid
            ORDER BY emo.id DESC
            LIMIT 1
        """),
        {
            "account_id": account_id,
            "folder_name": mailbox,
            "imap_uid": uid,
        },
    ).mappings().first()

    if not row:
        return None

    return dict(row)
