"""
Servicio de cuentas personales de correo y transferencia a cuenta colaborativa.

Principios:
- Las cuentas personales son privadas: no se almacenan correos en BD hasta que el usuario lo decide.
- La navegación IMAP personal es siempre readonly (EXAMINE, BODY.PEEK).
- La transferencia descarga el correo, lo archiva en la cuenta colaborativa y activa el pipeline IA.
- El correo transferido puede moverse automáticamente a una carpeta destino en el servidor IMAP personal.
"""
from __future__ import annotations

import email as email_lib
import imaplib
import re
from email.header import decode_header, make_header

from sqlalchemy import text
from sqlalchemy.orm import Session

from app.core.security import decrypt_text, encrypt_text


def _decode_header_value(value: str | None) -> str:
    value = (value or "").strip()
    if not value:
        return ""
    try:
        return str(make_header(decode_header(value)))
    except Exception:
        return value


def _connect_personal(account: dict) -> imaplib.IMAP4_SSL | imaplib.IMAP4:
    password = decrypt_text(account["imap_password_ciphertext"])
    if account.get("imap_use_ssl", True):
        conn = imaplib.IMAP4_SSL(host=account["imap_host"], port=account["imap_port"] or 993, timeout=20)
    else:
        conn = imaplib.IMAP4(host=account["imap_host"], port=account["imap_port"] or 993, timeout=20)
    conn.login(account["imap_username"], password)
    return conn


def _get_personal_account(db: Session, *, personal_account_id: int, user_id: int) -> dict:
    row = db.execute(
        text("""
            SELECT id, account_id, user_id, email, display_name,
                   imap_host, imap_username, imap_password_ciphertext,
                   imap_port, imap_use_ssl, active, transfer_folder
            FROM gestor_tickets.personal_mail_accounts
            WHERE id = :id AND user_id = :user_id AND active = true
            LIMIT 1
        """),
        {"id": personal_account_id, "user_id": user_id},
    ).mappings().first()
    if not row:
        raise ValueError("Cuenta personal no encontrada o no activa.")
    return dict(row)


def list_personal_accounts(db: Session, *, user_id: int) -> list[dict]:
    rows = db.execute(
        text("""
            SELECT id, account_id, email, display_name, imap_host, imap_port, active, transfer_folder, created_at
            FROM gestor_tickets.personal_mail_accounts
            WHERE user_id = :user_id
            ORDER BY id
        """),
        {"user_id": user_id},
    ).mappings().all()
    return [dict(r) for r in rows]


def create_personal_account(
    db: Session,
    *,
    account_id: int,
    user_id: int,
    email: str,
    display_name: str | None,
    imap_host: str,
    imap_username: str,
    imap_password: str,
    imap_port: int = 993,
    imap_use_ssl: bool = True,
    transfer_folder: str = "Transferidos",
) -> dict:
    ciphertext = encrypt_text(imap_password)
    row_id = db.execute(
        text("""
            INSERT INTO gestor_tickets.personal_mail_accounts
                (account_id, user_id, email, display_name, imap_host, imap_username,
                 imap_password_ciphertext, imap_port, imap_use_ssl, transfer_folder, updated_at)
            VALUES
                (:account_id, :user_id, :email, :display_name, :imap_host, :imap_username,
                 :ciphertext, :imap_port, :imap_use_ssl, :transfer_folder, now())
            ON CONFLICT (user_id, email) DO UPDATE SET
                display_name = EXCLUDED.display_name,
                imap_host = EXCLUDED.imap_host,
                imap_username = EXCLUDED.imap_username,
                imap_password_ciphertext = EXCLUDED.imap_password_ciphertext,
                imap_port = EXCLUDED.imap_port,
                imap_use_ssl = EXCLUDED.imap_use_ssl,
                transfer_folder = EXCLUDED.transfer_folder,
                updated_at = now()
            RETURNING id
        """),
        {
            "account_id": account_id, "user_id": user_id, "email": email,
            "display_name": display_name, "imap_host": imap_host, "imap_username": imap_username,
            "ciphertext": ciphertext, "imap_port": imap_port, "imap_use_ssl": imap_use_ssl,
            "transfer_folder": transfer_folder,
        },
    ).scalar_one()
    db.commit()
    return {"id": int(row_id)}


def preview_personal_mailbox(
    db: Session,
    *,
    personal_account_id: int,
    user_id: int,
    mailbox: str = "INBOX",
    limit: int = 30,
) -> dict:
    """Lee cabeceras del buzón personal en modo readonly. No modifica nada."""
    account = _get_personal_account(db, personal_account_id=personal_account_id, user_id=user_id)

    conn = _connect_personal(account)
    try:
        status, _ = conn.select(mailbox=mailbox, readonly=True)
        if status != "OK":
            raise ValueError(f"No se pudo abrir el buzón: {mailbox}")

        _, uid_data = conn.uid("SEARCH", "ALL")
        uid_list = uid_data[0].decode().split() if uid_data and uid_data[0] else []
        uid_list = uid_list[-limit:]

        messages = []
        if uid_list:
            uid_str = ",".join(uid_list)
            _, fetch_data = conn.uid(
                "FETCH", uid_str,
                "(UID FLAGS BODY.PEEK[HEADER.FIELDS (SUBJECT FROM DATE MESSAGE-ID REFERENCES IN-REPLY-TO)])",
            )

            already_transferred = _get_transferred_uids(db, personal_account_id=personal_account_id)

            i = 0
            while i < len(fetch_data):
                part = fetch_data[i]
                if not isinstance(part, tuple) or len(part) < 2:
                    i += 1
                    continue
                meta_raw, header_bytes = part[0], part[1]
                uid_match = re.search(rb"UID (\d+)", meta_raw)
                uid = uid_match.group(1).decode() if uid_match else None
                if not uid or not isinstance(header_bytes, bytes):
                    i += 1
                    continue
                parsed = email_lib.message_from_bytes(header_bytes)
                message_id = _decode_header_value(parsed.get("Message-ID")) or None
                references = _decode_header_value(parsed.get("References")) or None
                messages.append({
                    "uid": uid,
                    "subject": _decode_header_value(parsed.get("Subject")) or "(Sin asunto)",
                    "from_": _decode_header_value(parsed.get("From")) or "",
                    "date": _decode_header_value(parsed.get("Date")) or None,
                    "message_id": message_id,
                    "references": references,
                    "already_transferred": uid in already_transferred,
                })
                i += 1

        return {"ok": True, "account": account, "mailbox": mailbox, "messages": messages}

    finally:
        try:
            conn.logout()
        except Exception:
            pass


def _get_transferred_uids(db: Session, *, personal_account_id: int) -> set[str]:
    rows = db.execute(
        text("""
            SELECT original_imap_uid
            FROM gestor_tickets.personal_message_transfer_log
            WHERE personal_account_id = :id
        """),
        {"id": personal_account_id},
    ).scalars().all()
    return set(str(r) for r in rows)


def detect_thread_siblings(
    db: Session,
    *,
    personal_account_id: int,
    user_id: int,
    mailbox: str,
    uid: str,
) -> list[dict]:
    """
    Detecta correos en el mismo hilo IMAP que el UID indicado.
    Busca por asunto normalizado y cabeceras References/In-Reply-To.
    Devuelve lista de UIDs relacionados no transferidos todavía.
    """
    account = _get_personal_account(db, personal_account_id=personal_account_id, user_id=user_id)
    conn = _connect_personal(account)
    try:
        status, _ = conn.select(mailbox=mailbox, readonly=True)
        if status != "OK":
            return []

        _, fetch_data = conn.uid(
            "FETCH", uid,
            "(UID BODY.PEEK[HEADER.FIELDS (SUBJECT MESSAGE-ID REFERENCES IN-REPLY-TO)])",
        )

        subject_normalized = None
        message_id = None
        for part in (fetch_data or []):
            if not isinstance(part, tuple):
                continue
            parsed = email_lib.message_from_bytes(part[1]) if isinstance(part[1], bytes) else None
            if parsed:
                raw_subject = _decode_header_value(parsed.get("Subject")) or ""
                subject_normalized = re.sub(r"^\s*(re|rv|fw|fwd)\s*:\s*", "", raw_subject, flags=re.IGNORECASE).strip().lower()
                message_id = _decode_header_value(parsed.get("Message-ID")) or None

        if not subject_normalized and not message_id:
            return []

        _, uid_data = conn.uid("SEARCH", "ALL")
        all_uids = uid_data[0].decode().split() if uid_data and uid_data[0] else []

        if len(all_uids) > 200:
            all_uids = all_uids[-200:]

        already_transferred = _get_transferred_uids(db, personal_account_id=personal_account_id)
        siblings = []

        if all_uids:
            uid_str = ",".join(all_uids)
            _, all_fetch = conn.uid(
                "FETCH", uid_str,
                "(UID BODY.PEEK[HEADER.FIELDS (SUBJECT MESSAGE-ID REFERENCES IN-REPLY-TO)])",
            )
            i = 0
            while i < len(all_fetch):
                part = all_fetch[i]
                if not isinstance(part, tuple) or len(part) < 2:
                    i += 1
                    continue
                meta_raw, header_bytes = part[0], part[1]
                uid_match = re.search(rb"UID (\d+)", meta_raw)
                other_uid = uid_match.group(1).decode() if uid_match else None
                if not other_uid or other_uid == uid or not isinstance(header_bytes, bytes):
                    i += 1
                    continue
                parsed = email_lib.message_from_bytes(header_bytes)
                other_subject = _decode_header_value(parsed.get("Subject")) or ""
                other_normalized = re.sub(r"^\s*(re|rv|fw|fwd)\s*:\s*", "", other_subject, flags=re.IGNORECASE).strip().lower()
                other_refs = (_decode_header_value(parsed.get("References")) or "") + " " + (_decode_header_value(parsed.get("In-Reply-To")) or "")

                is_sibling = (
                    (subject_normalized and other_normalized == subject_normalized)
                    or (message_id and message_id in other_refs)
                )

                if is_sibling and other_uid not in already_transferred:
                    siblings.append({
                        "uid": other_uid,
                        "subject": _decode_header_value(parsed.get("Subject")) or "(Sin asunto)",
                        "from_": _decode_header_value(parsed.get("From")) or "",
                    })
                i += 1

        return siblings

    finally:
        try:
            conn.logout()
        except Exception:
            pass


def _fetch_raw_eml(account: dict, *, mailbox: str, uid: str) -> bytes:
    """Descarga el .eml completo del servidor personal en modo readonly."""
    conn = _connect_personal(account)
    try:
        status, _ = conn.select(mailbox=mailbox, readonly=True)
        if status != "OK":
            raise ValueError(f"No se pudo abrir el buzón: {mailbox}")

        _, fetch_data = conn.uid("FETCH", uid, "(UID BODY.PEEK[])")

        for part in (fetch_data or []):
            if isinstance(part, tuple) and len(part) >= 2 and isinstance(part[1], bytes):
                return part[1]

        raise ValueError(f"No se pudo obtener el contenido del mensaje UID={uid}")
    finally:
        try:
            conn.logout()
        except Exception:
            pass


def transfer_personal_email(
    db: Session,
    *,
    personal_account_id: int,
    user_id: int,
    mailbox: str,
    uid: str,
    target_account_id: int,
    move_after_transfer: bool = True,
) -> dict:
    """
    Transfiere un correo personal a la cuenta colaborativa.
    1. Descarga el .eml completo en modo readonly desde el servidor personal.
    2. Archiva los bytes en la cuenta colaborativa (sin abrir IMAP colaborativo).
    3. Ejecuta pipeline IA.
    4. Registra en personal_message_transfer_log.
    5. Opcionalmente, mueve el correo a la carpeta transfer_folder en servidor personal.
    """
    from app.services.email_archive_service import archive_raw_eml_for_account
    from app.services.thread_service import create_thread_from_email
    from app.services.email_ai_processing_service import process_email as ai_process

    account = _get_personal_account(db, personal_account_id=personal_account_id, user_id=user_id)
    raw_message = _fetch_raw_eml(account, mailbox=mailbox, uid=uid)

    archive_result = archive_raw_eml_for_account(
        db,
        account_id=target_account_id,
        raw_message=raw_message,
        mailbox=mailbox,
        uid=uid,
    )

    email_message_id = archive_result.email_message_id
    occurrence_id = archive_result.occurrence_id

    thread, _ = create_thread_from_email(
        db,
        account_id=target_account_id,
        email_message_id=int(email_message_id),
        created_by_user_id=user_id,
        reason=f"Transferencia desde cuenta personal #{personal_account_id}",
    )

    ai_result = None
    try:
        ai_result = ai_process(db, email_message_id=int(email_message_id), account_id=target_account_id, user_id=user_id)
    except Exception:
        pass

    db.execute(
        text("""
            INSERT INTO gestor_tickets.personal_message_transfer_log
                (personal_account_id, target_account_id, transferred_email_message_id,
                 transferred_by_user_id, original_folder, original_imap_uid,
                 original_imap_uidvalidity, original_message_id_header, transfer_reason)
            VALUES
                (:personal_account_id, :target_account_id, :email_message_id,
                 :user_id, :folder, :uid,
                 'personal', :message_id_header,
                 'Transferencia manual desde bandeja personal')
            ON CONFLICT (personal_account_id, original_folder, original_imap_uidvalidity, original_imap_uid)
            DO NOTHING
        """),
        {
            "personal_account_id": personal_account_id,
            "target_account_id": target_account_id,
            "email_message_id": int(email_message_id),
            "user_id": user_id,
            "folder": mailbox,
            "uid": uid,
            "message_id_header": archive_result.message_id,
        },
    )
    db.commit()

    moved = False
    if move_after_transfer and account.get("transfer_folder"):
        try:
            moved = _move_imap_message(account, mailbox=mailbox, uid=uid, destination=account["transfer_folder"])
        except Exception:
            pass

    return {
        "ok": True,
        "email_message_id": int(email_message_id),
        "occurrence_id": int(occurrence_id),
        "thread_id": thread.get("id"),
        "ai_ok": bool(ai_result and ai_result.get("ok")),
        "moved_in_imap": moved,
    }


def _move_imap_message(account: dict, *, mailbox: str, uid: str, destination: str) -> bool:
    """
    Mueve un correo a la carpeta destino usando IMAP COPY + STORE \\Deleted + EXPUNGE.
    IMPORTANTE: Esta es la UNICA funcion del proyecto que modifica FLAGS (para mover).
    Solo se llama tras confirmar que la transferencia fue exitosa.
    """
    conn = _connect_personal(account)
    try:
        status, _ = conn.select(mailbox=mailbox, readonly=False)
        if status != "OK":
            return False

        status, _ = conn.uid("CREATE", destination)

        copy_status, _ = conn.uid("COPY", uid, destination)
        if copy_status != "OK":
            return False

        conn.uid("STORE", uid, "+FLAGS", "(\\Deleted)")
        conn.expunge()
        return True
    finally:
        try:
            conn.logout()
        except Exception:
            pass
