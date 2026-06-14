from __future__ import annotations

import argparse
import hashlib
import json
from datetime import datetime, timezone
from email.message import EmailMessage
from email.policy import SMTP
from email.utils import format_datetime, make_msgid

from sqlalchemy import text

from app.core.db import SessionLocal
from app.models import CollaborativeAccount
from app.services.email_archive_service import _archive_path, _insert_or_update_message
from app.services.mail_ingestion_service import _active_glpi_ticket_for_thread, _auto_sync_ingested_email_to_ticket
from app.services.thread_service import create_thread_from_email


DEFAULT_MAILBOX = "SIMULATED"
DEFAULT_UIDVALIDITY = "simulated_uidvalidity"


def _default_active_job(db) -> dict:
    row = db.execute(
        text("""
            SELECT j.id AS job_id,
                   j.account_id AS account_id
            FROM gestor_tickets.mail_ingestion_jobs j
            JOIN gestor_tickets.collaborative_accounts a ON a.id = j.account_id
            WHERE j.status = 'active'
              AND a.status = 'active'
              AND a.ingestion_enabled IS TRUE
            ORDER BY j.id
            LIMIT 1
        """)
    ).mappings().first()
    if not row:
        raise ValueError("No hay jobs de ingesta activos para simular.")
    return dict(row)


def _build_message(*, subject: str, from_email: str, to_email: str, body: str, message_id: str | None) -> bytes:
    message = EmailMessage()
    message["From"] = from_email
    message["To"] = to_email
    message["Subject"] = subject
    message["Date"] = format_datetime(datetime.now(timezone.utc))
    message["Message-ID"] = message_id or make_msgid(domain="gestor-tickets.es")
    message.set_content(body)
    return message.as_bytes(policy=SMTP)


def _latest_simulated_uid(db, *, account_email: str) -> int:
    value = db.execute(
        text("""
            SELECT coalesce(max(nullif(regexp_replace(imap_uid, '\\D', '', 'g'), '')::int), 0)
            FROM gestor_tickets.email_message_occurrences
            WHERE source_mailbox_email = :account_email
              AND folder_name = :folder_name
              AND imap_uidvalidity = :uidvalidity
        """),
        {
            "account_email": account_email,
            "folder_name": DEFAULT_MAILBOX,
            "uidvalidity": DEFAULT_UIDVALIDITY,
        },
    ).scalar_one()
    return int(value or 0)


def _create_synthetic_run(
    db,
    *,
    job_id: int,
    account_id: int,
    email_message_id: int,
    occurrence_id: int,
    subject: str,
    mailbox: str,
    uid: str,
    thread_info: dict | None,
    ticket_sync: dict | None,
) -> int:
    details = {
        "mailboxes": [mailbox],
        "imported": [
            {
                "mailbox": mailbox,
                "uid": uid,
                "email_message_id": email_message_id,
                "occurrence_id": occurrence_id,
                "subject": subject,
                "thread": thread_info,
                "ticket_sync": ticket_sync,
                "simulation": True,
            }
        ],
        "duplicates": [],
        "errors": [],
        "safety": {
            "imap_readonly": True,
            "body_peek": True,
            "store_used": False,
            "flags_modified": False,
            "simulated_eml": True,
        },
    }

    run_id = db.execute(
        text("""
            INSERT INTO gestor_tickets.mail_ingestion_runs (
                job_id,
                account_id,
                status,
                finished_at,
                scanned_inbox_count,
                scanned_sent_count,
                imported_count,
                duplicate_count,
                error_count,
                error_message,
                details_json
            )
            VALUES (
                :job_id,
                :account_id,
                'success',
                now(),
                1,
                0,
                1,
                0,
                0,
                NULL,
                CAST(:details_json AS jsonb)
            )
            RETURNING id
        """),
        {
            "job_id": job_id,
            "account_id": account_id,
            "details_json": json.dumps(details, ensure_ascii=False),
        },
    ).scalar_one()

    db.execute(
        text("""
            UPDATE gestor_tickets.email_message_occurrences
            SET ingestion_run_id = :run_id,
                last_seen_at = now()
            WHERE id = :occurrence_id
        """),
        {
            "run_id": run_id,
            "occurrence_id": occurrence_id,
        },
    )

    db.execute(
        text("""
            UPDATE gestor_tickets.mail_ingestion_jobs
            SET last_success_at = now(),
                last_error_message = NULL,
                auth_failure_count = 0,
                next_run_at = now() + (interval_minutes * interval '1 minute'),
                status = 'active',
                updated_at = now()
            WHERE id = :job_id
        """),
        {"job_id": job_id},
    )

    return int(run_id)


def simulate(
    *,
    account_id: int | None,
    job_id: int | None,
    subject: str,
    from_email: str,
    body: str,
    message_id: str | None,
) -> dict:
    db = SessionLocal()
    try:
        if account_id is None or job_id is None:
            defaults = _default_active_job(db)
            account_id = account_id if account_id is not None else int(defaults["account_id"])
            job_id = job_id if job_id is not None else int(defaults["job_id"])

        account = db.get(CollaborativeAccount, account_id)
        if not account:
            raise ValueError(f"No existe la cuenta colaborativa {account_id}.")

        next_uid = _latest_simulated_uid(db, account_email=account.email) + 1
        uid = f"sim-{next_uid}"

        raw_message = _build_message(
            subject=subject,
            from_email=from_email,
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

        from email import message_from_bytes
        from email.policy import default
        parsed_policy_message = message_from_bytes(raw_message, policy=default)

        email_message_id, occurrence_id = _insert_or_update_message(
            db,
            account=account,
            parsed=parsed_policy_message,
            raw_message=raw_message,
            mailbox=DEFAULT_MAILBOX,
            uid=uid,
            uidvalidity=DEFAULT_UIDVALIDITY,
            flags=[],
            eml_storage_path=eml_storage_path,
            eml_filename=eml_filename,
            eml_sha256=eml_sha256,
        )
        db.commit()

        thread, thread_changed = create_thread_from_email(
            db,
            account_id=account_id,
            email_message_id=email_message_id,
            created_by_user_id=None,
            reason="Creación por simulación local de ingesta.",
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
                user_id=None,
            )

        run_id = _create_synthetic_run(
            db,
            job_id=job_id,
            account_id=account_id,
            email_message_id=email_message_id,
            occurrence_id=occurrence_id,
            subject=subject,
            mailbox=DEFAULT_MAILBOX,
            uid=uid,
            thread_info=thread_info,
            ticket_sync=ticket_sync,
        )
        db.commit()

        return {
            "run_id": run_id,
            "email_message_id": email_message_id,
            "occurrence_id": occurrence_id,
            "thread": thread_info,
            "ticket_sync": ticket_sync,
            "eml_storage_path": eml_storage_path,
            "uid": uid,
            "message_id": parsed_policy_message.get("Message-ID"),
        }
    except Exception:
        db.rollback()
        raise
    finally:
        db.close()


def main() -> None:
    parser = argparse.ArgumentParser(description="Simula un correo ingerido sin tocar IMAP.")
    parser.add_argument("--account-id", type=int, default=None)
    parser.add_argument("--job-id", type=int, default=None)
    parser.add_argument("--subject", default="Re: Solicitud de asistencia técnica")
    parser.add_argument("--from-email", default="usuario.demo@gestor-tickets.es")
    parser.add_argument(
        "--body",
        default=(
            "Buenos días, añado información adicional para la solicitud de asistencia técnica. "
            "Esta respuesta se ha generado como simulación local sin tocar el buzón IMAP."
        ),
    )
    parser.add_argument("--message-id", default=None)
    args = parser.parse_args()

    result = simulate(
        account_id=args.account_id,
        job_id=args.job_id,
        subject=args.subject,
        from_email=args.from_email,
        body=args.body,
        message_id=args.message_id,
    )
    print(json.dumps(result, ensure_ascii=False, indent=2, default=str))


if __name__ == "__main__":
    main()
