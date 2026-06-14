from __future__ import annotations

import argparse
import hashlib
import json
import secrets
from datetime import datetime, timezone
from email import message_from_bytes
from email.message import EmailMessage
from email.policy import SMTP, default
from email.utils import format_datetime, make_msgid

from sqlalchemy import text

from app.core.db import SessionLocal
from app.core.security import encrypt_text
from app.models import CollaborativeAccount
from app.services.email_archive_service import _archive_path, _insert_or_update_message
from app.services.mail_ingestion_service import _active_glpi_ticket_for_thread, _auto_sync_ingested_email_to_ticket
from app.services.thread_service import create_thread_from_email


DEFAULT_ACCOUNT_ID = 3
DEFAULT_USER_ID = 1
DEFAULT_PERSONAL_EMAIL = "usuario.personal.simulado@gestor-tickets.es"
DEFAULT_MAILBOX = "PERSONAL_SIMULATED"
DEFAULT_UIDVALIDITY = "personal_simulated_uidvalidity"


def _build_message(*, subject: str, from_email: str, to_email: str, body: str, message_id: str | None) -> bytes:
    message = EmailMessage()
    message["From"] = from_email
    message["To"] = to_email
    message["Subject"] = subject
    message["Date"] = format_datetime(datetime.now(timezone.utc))
    message["Message-ID"] = message_id or make_msgid(domain="gestor-tickets.es")
    message.set_content(body)
    return message.as_bytes(policy=SMTP)


def _ensure_personal_account(db, *, account_id: int, user_id: int, email: str) -> int:
    existing = db.execute(
        text("""
            SELECT id
            FROM gestor_tickets.personal_mail_accounts
            WHERE account_id = :account_id
              AND user_id = :user_id
              AND email = :email
            LIMIT 1
        """),
        {"account_id": account_id, "user_id": user_id, "email": email},
    ).scalar_one_or_none()
    if existing:
        return int(existing)

    return int(
        db.execute(
            text("""
                INSERT INTO gestor_tickets.personal_mail_accounts (
                    account_id,
                    user_id,
                    email,
                    display_name,
                    imap_host,
                    imap_username,
                    imap_password_ciphertext,
                    imap_port,
                    imap_use_ssl,
                    active,
                    last_validated_at,
                    updated_at
                )
                VALUES (
                    :account_id,
                    :user_id,
                    :email,
                    'Cuenta personal simulada',
                    'simulated.local',
                    :email,
                    :password_ciphertext,
                    993,
                    true,
                    true,
                    now(),
                    now()
                )
                RETURNING id
            """),
            {
                "account_id": account_id,
                "user_id": user_id,
                "email": email,
                "password_ciphertext": encrypt_text(secrets.token_urlsafe(32)),
            },
        ).scalar_one()
    )


def _latest_simulated_uid(db, *, personal_account_id: int) -> int:
    value = db.execute(
        text("""
            SELECT coalesce(max(nullif(regexp_replace(original_imap_uid, '\\D', '', 'g'), '')::int), 0)
            FROM gestor_tickets.personal_message_transfer_log
            WHERE personal_account_id = :personal_account_id
              AND original_folder = :folder_name
              AND original_imap_uidvalidity = :uidvalidity
        """),
        {
            "personal_account_id": personal_account_id,
            "folder_name": DEFAULT_MAILBOX,
            "uidvalidity": DEFAULT_UIDVALIDITY,
        },
    ).scalar_one()
    return int(value or 0)


def _mark_personal_transfer(
    db,
    *,
    email_message_id: int,
    personal_account_id: int,
    transferred_by_user_id: int,
    personal_email: str,
    folder: str,
    uid: str,
    uidvalidity: str,
    message_id: str | None,
    transfer_reason: str,
) -> None:
    db.execute(
        text("""
            UPDATE gestor_tickets.email_messages
            SET source = 'personal_transfer',
                imported_from_personal_account_id = :personal_account_id,
                transferred_by_user_id = :transferred_by_user_id,
                transferred_at = COALESCE(transferred_at, now()),
                original_imap_account = :personal_email,
                original_imap_folder = :folder,
                original_imap_uid = :uid,
                original_imap_uidvalidity = :uidvalidity,
                source_description = :source_description,
                updated_at = now()
            WHERE id = :email_message_id
        """),
        {
            "email_message_id": email_message_id,
            "personal_account_id": personal_account_id,
            "transferred_by_user_id": transferred_by_user_id,
            "personal_email": personal_email,
            "folder": folder,
            "uid": uid,
            "uidvalidity": uidvalidity,
            "source_description": "Transferencia voluntaria simulada desde cuenta personal sin tocar IMAP.",
        },
    )

    db.execute(
        text("""
            INSERT INTO gestor_tickets.personal_message_transfer_log (
                personal_account_id,
                target_account_id,
                transferred_email_message_id,
                transferred_by_user_id,
                original_folder,
                original_imap_uid,
                original_imap_uidvalidity,
                original_message_id_header,
                transfer_reason
            )
            SELECT
                :personal_account_id,
                em.account_id,
                :email_message_id,
                :transferred_by_user_id,
                :folder,
                :uid,
                :uidvalidity,
                :message_id,
                :transfer_reason
            FROM gestor_tickets.email_messages em
            WHERE em.id = :email_message_id
            ON CONFLICT (personal_account_id, original_folder, original_imap_uidvalidity, original_imap_uid)
            DO UPDATE SET
                transferred_email_message_id = EXCLUDED.transferred_email_message_id,
                transferred_by_user_id = EXCLUDED.transferred_by_user_id,
                original_message_id_header = EXCLUDED.original_message_id_header,
                transfer_reason = EXCLUDED.transfer_reason
        """),
        {
            "personal_account_id": personal_account_id,
            "email_message_id": email_message_id,
            "transferred_by_user_id": transferred_by_user_id,
            "folder": folder,
            "uid": uid,
            "uidvalidity": uidvalidity,
            "message_id": message_id,
            "transfer_reason": transfer_reason,
        },
    )


def simulate_transfer(
    *,
    account_id: int,
    user_id: int,
    personal_email: str,
    subject: str,
    body: str,
    message_id: str | None,
    transfer_reason: str,
) -> dict:
    db = SessionLocal()
    try:
        account = db.get(CollaborativeAccount, account_id)
        if not account:
            raise ValueError(f"No existe la cuenta colaborativa {account_id}.")

        personal_account_id = _ensure_personal_account(
            db,
            account_id=account_id,
            user_id=user_id,
            email=personal_email,
        )

        uid = f"personal-sim-{_latest_simulated_uid(db, personal_account_id=personal_account_id) + 1}"
        raw_message = _build_message(
            subject=subject,
            from_email=personal_email,
            to_email=account.email,
            body=body,
            message_id=message_id,
        )
        eml_sha256 = hashlib.sha256(raw_message).hexdigest()
        eml_storage_path, eml_filename = _archive_path(
            account,
            DEFAULT_MAILBOX,
            DEFAULT_UIDVALIDITY,
            uid,
            eml_sha256,
        )
        with open(eml_storage_path, "wb") as fh:
            fh.write(raw_message)

        parsed = message_from_bytes(raw_message, policy=default)
        email_message_id, occurrence_id = _insert_or_update_message(
            db,
            account=account,
            parsed=parsed,
            raw_message=raw_message,
            mailbox=DEFAULT_MAILBOX,
            uid=uid,
            uidvalidity=DEFAULT_UIDVALIDITY,
            flags=[],
            eml_storage_path=eml_storage_path,
            eml_filename=eml_filename,
            eml_sha256=eml_sha256,
        )

        db.execute(
            text("""
                UPDATE gestor_tickets.email_message_occurrences
                SET source_mailbox_email = :personal_email,
                    last_seen_at = now()
                WHERE id = :occurrence_id
            """),
            {
                "personal_email": personal_email,
                "occurrence_id": occurrence_id,
            },
        )

        _mark_personal_transfer(
            db,
            email_message_id=email_message_id,
            personal_account_id=personal_account_id,
            transferred_by_user_id=user_id,
            personal_email=personal_email,
            folder=DEFAULT_MAILBOX,
            uid=uid,
            uidvalidity=DEFAULT_UIDVALIDITY,
            message_id=parsed.get("Message-ID"),
            transfer_reason=transfer_reason,
        )
        db.commit()

        thread, thread_changed = create_thread_from_email(
            db,
            account_id=account_id,
            email_message_id=email_message_id,
            created_by_user_id=user_id,
            reason="Creación por transferencia voluntaria desde cuenta personal simulada.",
        )
        thread_info = {
            "thread_id": thread.get("id"),
            "thread_changed": thread_changed,
        }

        ticket_sync = None
        ticket = _active_glpi_ticket_for_thread(
            db,
            account_id=account_id,
            thread_id=int(thread["id"]),
        )
        if ticket:
            ticket_sync = _auto_sync_ingested_email_to_ticket(
                db,
                account_id=account_id,
                ticket=ticket,
                thread_id=int(thread["id"]),
                email_message_id=email_message_id,
                user_id=user_id,
            )

        db.commit()

        return {
            "personal_account_id": personal_account_id,
            "email_message_id": email_message_id,
            "occurrence_id": occurrence_id,
            "thread": thread_info,
            "ticket_sync": ticket_sync,
            "eml_storage_path": eml_storage_path,
            "uid": uid,
            "message_id": parsed.get("Message-ID"),
            "safety": {
                "simulated_personal_transfer": True,
                "imap_touched": False,
                "store_used": False,
                "flags_modified": False,
                "body_peek_required_for_real_flow": True,
            },
        }
    except Exception:
        db.rollback()
        raise
    finally:
        db.close()


def main() -> None:
    parser = argparse.ArgumentParser(description="Simula una transferencia voluntaria desde cuenta personal sin tocar IMAP.")
    parser.add_argument("--account-id", type=int, default=DEFAULT_ACCOUNT_ID)
    parser.add_argument("--user-id", type=int, default=DEFAULT_USER_ID)
    parser.add_argument("--personal-email", default=DEFAULT_PERSONAL_EMAIL)
    parser.add_argument("--subject", default="Re: Solicitud de asistencia técnica")
    parser.add_argument(
        "--body",
        default=(
            "Mensaje personal simulado transferido voluntariamente al sistema colaborativo. "
            "No se ha tocado ningún buzón IMAP real."
        ),
    )
    parser.add_argument("--message-id", default=None)
    parser.add_argument("--reason", default="Simulación local de transferencia personal.")
    args = parser.parse_args()

    result = simulate_transfer(
        account_id=args.account_id,
        user_id=args.user_id,
        personal_email=args.personal_email,
        subject=args.subject,
        body=args.body,
        message_id=args.message_id,
        transfer_reason=args.reason,
    )
    print(json.dumps(result, ensure_ascii=False, indent=2, default=str))


if __name__ == "__main__":
    main()
