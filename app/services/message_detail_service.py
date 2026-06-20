from __future__ import annotations

import email
import imaplib
import re
from dataclasses import dataclass
from email.header import decode_header, make_header
from email.policy import default

import bleach
from bs4 import BeautifulSoup
from sqlalchemy import select
from sqlalchemy.orm import Session

from app.core.security import decrypt_text
from app.models import CollaborativeAccount


MESSAGE_DETAIL_SAFETY_NOTES = [
    "El buzón se abre con EXAMINE mediante select(..., readonly=True).",
    "El mensaje se obtiene con UID FETCH y BODY.PEEK[].",
    "No se ejecuta BODY[] normal.",
    "No se ejecuta STORE.",
    "No se modifican FLAGS.",
    "No se marca ningún correo como leído.",
    "El HTML se sanitiza antes de renderizarse.",
    "Se eliminan scripts, iframes, object, embed, formularios y eventos on*.",
]


DANGEROUS_TAGS = {
    "script",
    "object",
    "embed",
    "applet",
    "base",
    "meta",
    "form",
    "input",
    "button",
    "textarea",
    "select",
    "option",
    "noscript",
}

ALLOWED_TAGS = [
    "a", "abbr", "acronym", "b", "blockquote", "body", "br", "caption", "cite",
    "code", "col", "colgroup", "div", "em", "font",
    "h1", "h2", "h3", "h4", "h5", "h6",
    "head", "hr", "html", "i", "img", "li", "ol", "p", "pre",
    "s", "small", "span", "strike", "strong", "style", "sub", "sup",
    "table", "tbody", "td", "tfoot", "th", "thead", "tr",
    "u", "ul",
]

ALLOWED_ATTRIBUTES = {
    "*": ["class", "style", "id", "dir", "lang", "width", "height", "align", "valign",
          "bgcolor", "color", "border", "cellpadding", "cellspacing"],
    "a": ["href", "title", "target", "rel", "name"],
    "abbr": ["title"],
    "acronym": ["title"],
    "body": ["bgcolor", "style", "text", "link", "vlink"],
    "head": [],
    "html": ["lang", "dir", "xmlns"],
    "img": ["src", "alt", "title", "width", "height", "style"],
    "style": ["type", "media"],
    "table": ["summary", "width", "border", "cellpadding", "cellspacing", "bgcolor"],
    "td": ["colspan", "rowspan", "width", "nowrap"],
    "th": ["colspan", "rowspan", "width"],
    "col": ["span", "width"],
    "font": ["face", "size", "color"],
}


@dataclass(frozen=True)
class MessageDetail:
    ok: bool
    account: CollaborativeAccount
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
    text_body: str | None
    sanitized_html_body: str | None
    blocked_active_content: bool


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


def _extract_bodies(message) -> tuple[str | None, str | None]:
    text_parts: list[str] = []
    html_parts: list[str] = []

    if message.is_multipart():
        for part in message.walk():
            if part.is_multipart():
                continue

            disposition = part.get_content_disposition()
            if disposition == "attachment":
                continue

            content_type = part.get_content_type()
            content = _part_text(part).strip()

            if not content:
                continue

            if content_type == "text/plain":
                text_parts.append(content)
            elif content_type == "text/html":
                html_parts.append(content)

    else:
        content = _part_text(message).strip()
        content_type = message.get_content_type()

        if content_type == "text/html":
            html_parts.append(content)
        elif content:
            text_parts.append(content)

    text_body = "\n\n".join(text_parts).strip() or None
    html_body = "\n\n".join(html_parts).strip() or None

    return text_body, html_body


def sanitize_html_body(
    html_body: str | None,
    *,
    email_message_id: int | None = None,
    cid_map: dict | None = None,
) -> tuple[str | None, bool]:
    """
    Sanitiza el HTML del correo para renderizado seguro en iframe sandbox.
    Permite estilos inline, <style> y estructura completa del documento.
    Elimina tags activos peligrosos, eventos JavaScript y <link> externos.
    cid_map: dict de content_id → data URI para imágenes embebidas.
    Si no hay cid_map pero hay email_message_id, usa URLs proxy CID.
    """
    if not html_body:
        return None, False

    blocked = False
    soup = BeautifulSoup(html_body, "html.parser")

    for tag in soup.find_all(DANGEROUS_TAGS):
        tag.decompose()
        blocked = True

    for tag in soup.find_all("iframe"):
        tag.decompose()
        blocked = True

    # Eliminar <link> externos (tracking, stylesheets remotas) sin alarmar al usuario
    for tag in soup.find_all("link"):
        tag.decompose()

    for tag in soup.find_all(True):
        for attr in list(tag.attrs):
            attr_lower = attr.lower()
            value = tag.attrs.get(attr)

            if attr_lower.startswith("on"):
                del tag.attrs[attr]
                blocked = True
                continue

            if attr_lower in {"href", "src", "xlink:href", "formaction", "action", "data"}:
                values = value if isinstance(value, list) else [value]
                joined = " ".join(str(item) for item in values).strip()

                joined_lower = joined.lower()
                if joined_lower.startswith(("javascript:", "vbscript:", "file:")):
                    del tag.attrs[attr]
                    blocked = True
                    continue

                if joined_lower.startswith("cid:"):
                    cid_value = joined[4:].strip().strip("<>")
                    if cid_map:
                        data_uri = (
                            cid_map.get(cid_value)
                            or cid_map.get(f"<{cid_value}>")
                        )
                        if data_uri:
                            tag.attrs[attr] = data_uri
                        else:
                            del tag.attrs[attr]
                    elif email_message_id:
                        tag.attrs[attr] = f"/api/emails/{email_message_id}/cid/{cid_value}"
                    else:
                        del tag.attrs[attr]
                    continue

    cleaned = bleach.clean(
        str(soup),
        tags=ALLOWED_TAGS,
        attributes=ALLOWED_ATTRIBUTES,
        protocols=["http", "https", "mailto", "tel", "data"],
        strip=True,
    )

    return cleaned.strip() or None, blocked


def fetch_message_detail_readonly(
    db: Session,
    *,
    account_id: int,
    mailbox: str,
    uid: str,
) -> MessageDetail:
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

        fetch_status, fetch_data = connection.uid(
            "FETCH",
            uid,
            "(UID FLAGS BODY.PEEK[])",
        )

        if fetch_status != "OK":
            raise ValueError(f"No se pudo leer el mensaje en modo seguro: {fetch_data!r}")

        raw_message, flags = _extract_raw_message_and_flags(fetch_data)

        if not raw_message:
            raise ValueError("No se recibió contenido del mensaje.")

        parsed = email.message_from_bytes(raw_message, policy=default)
        text_body, html_body = _extract_bodies(parsed)
        sanitized_html_body, blocked_active_content = sanitize_html_body(html_body)

        return MessageDetail(
            ok=True,
            account=account,
            mailbox=mailbox,
            uid=uid,
            message_id=_clean_text(parsed.get("Message-ID")) or None,
            subject=_decode_header_value(parsed.get("Subject")) or "(Sin asunto)",
            from_=_decode_header_value(parsed.get("From")) or "(Sin remitente)",
            to=_decode_header_value(parsed.get("To")) or None,
            cc=_decode_header_value(parsed.get("Cc")) or None,
            date=_decode_header_value(parsed.get("Date")) or None,
            flags=flags,
            seen="\\Seen" in flags,
            answered="\\Answered" in flags,
            text_body=text_body,
            sanitized_html_body=sanitized_html_body,
            blocked_active_content=blocked_active_content,
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
