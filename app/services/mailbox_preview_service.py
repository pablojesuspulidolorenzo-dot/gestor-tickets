from __future__ import annotations

import email
import imaplib
import re
from dataclasses import dataclass
from email.header import decode_header, make_header
from email.utils import parsedate_to_datetime

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

FOLDER_SAFETY_NOTES = [
    "La detección de carpetas usa únicamente IMAP LIST.",
    "No se abre ningún buzón.",
    "No se leen mensajes.",
    "No se ejecuta FETCH.",
    "No se ejecuta STORE.",
    "No se modifican FLAGS.",
]


@dataclass(frozen=True)
class ImapFolder:
    name: str
    delimiter: str | None
    flags: list[str]
    is_inbox: bool
    is_sent_candidate: bool


@dataclass(frozen=True)
class ImapFoldersResult:
    ok: bool
    account: CollaborativeAccount
    folders: list[ImapFolder]
    detected_inbox: str | None
    sent_candidates: list[str]


@dataclass(frozen=True)
class PreviewMessage:
    mailbox: str
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
    direction: str


@dataclass(frozen=True)
class MailboxPreview:
    ok: bool
    account: CollaborativeAccount
    mailbox: str
    total_messages: int | None
    messages: list[PreviewMessage]


@dataclass(frozen=True)
class UnifiedMailboxPreview:
    ok: bool
    account: CollaborativeAccount
    mailboxes: list[str]
    total_messages_by_mailbox: dict[str, int | None]
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


def _get_account_and_password(db: Session, account_id: int) -> tuple[CollaborativeAccount, str]:
    account = db.execute(
        select(CollaborativeAccount).where(CollaborativeAccount.id == account_id)
    ).scalar_one_or_none()

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


def _parse_list_line(raw_line) -> ImapFolder | None:
    if isinstance(raw_line, bytes):
        line = raw_line.decode("utf-8", errors="ignore")
    else:
        line = str(raw_line)

    line = line.strip()
    if not line:
        return None

    match = re.match(r'^\((?P<flags>.*?)\)\s+"?(?P<delimiter>[^"\s]*)"?\s+"?(?P<name>.*)"?$', line)
    if not match:
        return ImapFolder(
            name=line.strip('"'),
            delimiter=None,
            flags=[],
            is_inbox=line.upper() == "INBOX",
            is_sent_candidate=False,
        )

    flags_text = match.group("flags") or ""
    delimiter = match.group("delimiter") or None
    name = (match.group("name") or "").strip().strip('"')

    flags = [item.strip() for item in flags_text.split() if item.strip()]
    lowered = name.lower()
    flags_lowered = " ".join(flags).lower()

    sent_terms = [
        "sent",
        "sent items",
        "sent messages",
        "enviados",
        "enviado",
        "elementos enviados",
        "correo enviado",
        "correos enviados",
    ]

    is_sent_candidate = (
        "\\sent" in flags_lowered
        or lowered in sent_terms
        or lowered.endswith("/sent")
        or lowered.endswith(".sent")
        or lowered.endswith("/enviados")
        or lowered.endswith(".enviados")
        or "sent" in lowered
        or "enviad" in lowered
    )

    return ImapFolder(
        name=name,
        delimiter=delimiter,
        flags=flags,
        is_inbox=lowered == "inbox",
        is_sent_candidate=is_sent_candidate,
    )


def _message_sort_key(message: PreviewMessage):
    if message.date:
        try:
            parsed = parsedate_to_datetime(message.date)
            return parsed.timestamp()
        except Exception:
            pass

    try:
        return float(message.uid)
    except Exception:
        return 0.0


def _direction_for_mailbox(mailbox: str) -> str:
    lowered = mailbox.lower()
    if "sent" in lowered or "enviad" in lowered:
        return "sent"
    return "received"


def list_collaborative_imap_folders(
    db: Session,
    *,
    account_id: int,
) -> ImapFoldersResult:
    account, password = _get_account_and_password(db, account_id)
    connection = None

    try:
        connection = _connect(account, password)

        status, data = connection.list()
        if status != "OK":
            raise ValueError(f"No se pudo listar carpetas IMAP: {data!r}")

        folders = [
            folder
            for folder in (_parse_list_line(line) for line in data or [])
            if folder is not None and folder.name
        ]

        folders = sorted(folders, key=lambda item: (not item.is_inbox, item.name.lower()))

        detected_inbox = next((item.name for item in folders if item.is_inbox), None)
        sent_candidates = [item.name for item in folders if item.is_sent_candidate]

        return ImapFoldersResult(
            ok=True,
            account=account,
            folders=folders,
            detected_inbox=detected_inbox,
            sent_candidates=sent_candidates,
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


def preview_collaborative_mailbox(
    db: Session,
    *,
    account_id: int,
    mailbox: str = "INBOX",
    limit: int = 20,
) -> MailboxPreview:
    account, password = _get_account_and_password(db, account_id)

    mailbox = _clean_text(mailbox) or "INBOX"
    limit = max(1, min(int(limit), 50))

    connection = None

    try:
        connection = _connect(account, password)

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
                    mailbox=mailbox,
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
                    direction=_direction_for_mailbox(mailbox),
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


def preview_unified_collaborative_mailbox(
    db: Session,
    *,
    account_id: int,
    mailboxes: list[str] | None = None,
    limit_per_mailbox: int = 20,
    total_limit: int = 50,
) -> UnifiedMailboxPreview:
    mailboxes = mailboxes or ["INBOX", "INBOX.Sent"]
    clean_mailboxes = []
    for mailbox in mailboxes:
        mailbox = _clean_text(mailbox)
        if mailbox and mailbox not in clean_mailboxes:
            clean_mailboxes.append(mailbox)

    if not clean_mailboxes:
        clean_mailboxes = ["INBOX"]

    total_messages_by_mailbox: dict[str, int | None] = {}
    all_messages: list[PreviewMessage] = []
    account = None

    for mailbox in clean_mailboxes:
        preview = preview_collaborative_mailbox(
            db,
            account_id=account_id,
            mailbox=mailbox,
            limit=limit_per_mailbox,
        )
        account = preview.account
        total_messages_by_mailbox[mailbox] = preview.total_messages
        all_messages.extend(preview.messages)

    all_messages = sorted(all_messages, key=_message_sort_key, reverse=True)
    total_limit = max(1, min(int(total_limit), 100))
    all_messages = all_messages[:total_limit]

    if account is None:
        account, _ = _get_account_and_password(db, account_id)

    return UnifiedMailboxPreview(
        ok=True,
        account=account,
        mailboxes=clean_mailboxes,
        total_messages_by_mailbox=total_messages_by_mailbox,
        messages=all_messages,
    )
