"""Servicio de envío de correo saliente vía SMTP."""
from __future__ import annotations

import smtplib
import ssl
from email import encoders as _encoders
from email.mime.base import MIMEBase
from email.mime.multipart import MIMEMultipart
from email.mime.text import MIMEText
from email.utils import formataddr, formatdate, make_msgid

from app.models import CollaborativeAccount


def _derive_smtp_host(imap_host: str) -> str:
    """Deduce el host SMTP a partir del host IMAP."""
    if not imap_host:
        return ""
    h = imap_host.lower()
    if h.startswith("imap."):
        return "smtp." + imap_host[5:]
    if "imap" in h:
        return imap_host.replace("imap", "smtp", 1)
    return imap_host


def send_email(
    *,
    account: CollaborativeAccount,
    plain_password: str,
    to: list[str],
    cc: list[str] | None = None,
    bcc: list[str] | None = None,
    subject: str,
    body_text: str = "",
    body_html: str | None = None,
    in_reply_to: str | None = None,
    references: str | None = None,
    attachments: list[tuple[str, str, bytes]] | None = None,
) -> None:
    """
    Envía un correo vía SMTP usando las credenciales IMAP de la cuenta.

    attachments: lista de (filename, content_type, data_bytes)
    Lanza ValueError si no puede conectar o autenticar.
    Intenta primero STARTTLS en 587, luego SSL en 465.
    """
    smtp_host = _derive_smtp_host(account.imap_host or "")
    if not smtp_host:
        raise ValueError(
            "No se puede deducir el servidor SMTP. "
            "Comprueba la configuración IMAP de la cuenta."
        )

    from_addr = account.email
    domain = from_addr.split("@")[-1] if "@" in from_addr else "localhost"
    from_display = formataddr((account.display_name or "", from_addr))

    # Construir mensaje
    if attachments:
        outer = MIMEMultipart("mixed")
        alt = MIMEMultipart("alternative")
        alt.attach(MIMEText(body_text or "", "plain", "utf-8"))
        if body_html:
            alt.attach(MIMEText(body_html, "html", "utf-8"))
        outer.attach(alt)
    else:
        outer = MIMEMultipart("alternative")
        outer.attach(MIMEText(body_text or "", "plain", "utf-8"))
        if body_html:
            outer.attach(MIMEText(body_html, "html", "utf-8"))

    outer["From"] = from_display
    outer["To"] = ", ".join(to)
    if cc:
        outer["Cc"] = ", ".join(cc)
    outer["Subject"] = subject
    outer["Date"] = formatdate(localtime=True)
    outer["Message-ID"] = make_msgid(domain=domain)
    if in_reply_to:
        outer["In-Reply-To"] = in_reply_to
    if references:
        outer["References"] = references

    if attachments:
        for filename, content_type, data in attachments:
            maintype, subtype = (content_type or "application/octet-stream").split("/", 1)
            part = MIMEBase(maintype, subtype)
            part.set_payload(data)
            _encoders.encode_base64(part)
            part.add_header(
                "Content-Disposition",
                "attachment",
                filename=filename.replace('"', "'"),
            )
            outer.attach(part)

    all_recipients = list(to) + (cc or []) + (bcc or [])
    username = account.imap_username or from_addr
    raw_msg = outer.as_bytes()

    last_exc: Exception | None = None

    # Intento 1: STARTTLS en puerto 587
    try:
        with smtplib.SMTP(smtp_host, 587, timeout=30) as srv:
            srv.ehlo()
            srv.starttls(context=ssl.create_default_context())
            srv.ehlo()
            srv.login(username, plain_password)
            srv.sendmail(from_addr, all_recipients, raw_msg)
        return
    except Exception as exc:
        last_exc = exc

    # Intento 2: SSL en puerto 465
    try:
        ctx = ssl.create_default_context()
        with smtplib.SMTP_SSL(smtp_host, 465, context=ctx, timeout=30) as srv:
            srv.login(username, plain_password)
            srv.sendmail(from_addr, all_recipients, raw_msg)
        return
    except Exception as exc:
        last_exc = exc

    raise ValueError(
        f"No se pudo enviar el correo mediante {smtp_host} (puertos 587/465). "
        f"Detalle: {last_exc}"
    )
