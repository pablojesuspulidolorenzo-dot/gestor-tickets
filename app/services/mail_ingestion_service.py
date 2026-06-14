from __future__ import annotations

import json
from dataclasses import asdict, is_dataclass
from typing import Any

from sqlalchemy import text
from sqlalchemy.orm import Session

from app.services.email_archive_service import archive_message_from_imap_readonly
from app.services.mailbox_preview_service import preview_unified_collaborative_mailbox
from app.services.thread_service import create_thread_from_email


VALID_JOB_STATUSES = {
    "active",
    "disabled",
    "error_auth",
    "error_connection",
    "error_unknown",
}


AUTH_ERROR_MARKERS = (
    "authentication failed",
    "authenticationfailure",
    "login failed",
    "invalid credentials",
    "invalid password",
    "username and password not accepted",
    "credentials rejected",
    "auth failed",
    "password",
    "contraseña",
    "autentic",
    "credencial",
)


def _classify_ingestion_error(exc: Exception) -> str:
    message = f"{type(exc).__name__}: {exc}".lower()

    if any(marker in message for marker in AUTH_ERROR_MARKERS):
        return "auth"

    if any(marker in message for marker in ("timeout", "connection", "network", "refused", "unreachable")):
        return "connection"

    return "unknown"


def _apply_auth_failure_policy(
    db: Session,
    *,
    job: dict,
    exc: Exception,
) -> None:
    error_kind = _classify_ingestion_error(exc)

    if error_kind != "auth":
        return

    account_id = int(job["account_id"])
    job_id = int(job["id"])
    previous_failures = int(job.get("auth_failure_count") or 0)
    new_failures = previous_failures + 1
    message = f"{type(exc).__name__}: {exc}"[:1500]

    if new_failures >= 2:
        db.execute(
            text("""
                UPDATE gestor_tickets.mail_ingestion_jobs
                SET status = 'error_auth',
                    auth_failure_count = :auth_failure_count,
                    last_error_at = now(),
                    last_error_message = :message,
                    next_run_at = NULL,
                    updated_at = now()
                WHERE id = :job_id
            """),
            {
                "job_id": job_id,
                "auth_failure_count": new_failures,
                "message": message,
            },
        )

        db.execute(
            text("""
                UPDATE gestor_tickets.collaborative_accounts
                SET status = 'error_auth',
                    ingestion_enabled = false,
                    updated_at = now()
                WHERE id = :account_id
            """),
            {"account_id": account_id},
        )

    else:
        db.execute(
            text("""
                UPDATE gestor_tickets.mail_ingestion_jobs
                SET status = 'active',
                    auth_failure_count = :auth_failure_count,
                    last_error_at = now(),
                    last_error_message = :message,
                    next_run_at = now() + interval '2 minutes',
                    updated_at = now()
                WHERE id = :job_id
            """),
            {
                "job_id": job_id,
                "auth_failure_count": new_failures,
                "message": message,
            },
        )

    db.commit()


def _plain(value: Any) -> Any:
    if hasattr(value, "model_dump"):
        return value.model_dump()
    if hasattr(value, "dict"):
        return value.dict()
    if is_dataclass(value):
        return asdict(value)
    if isinstance(value, list):
        return [_plain(item) for item in value]
    if isinstance(value, tuple):
        return [_plain(item) for item in value]
    if isinstance(value, dict):
        return {key: _plain(item) for key, item in value.items()}
    return value


def _row_dict(row) -> dict | None:
    return dict(row) if row else None


def _get_account_email(db: Session, *, account_id: int) -> str:
    value = db.execute(
        text("""
            SELECT email::text
            FROM gestor_tickets.collaborative_accounts
            WHERE id = :account_id
            LIMIT 1
        """),
        {"account_id": account_id},
    ).scalar_one_or_none()

    if not value:
        raise ValueError("La cuenta colaborativa no existe.")

    return str(value)


def _job_summary(db: Session, *, job_id: int) -> dict:
    row = db.execute(
        text("""
            SELECT
                id,
                account_id,
                status::text AS status,
                scan_inbox,
                scan_sent,
                inbox_folder_name,
                sent_folder_name,
                interval_minutes,
                max_messages_per_folder,
                last_started_at,
                last_success_at,
                last_error_at,
                next_run_at,
                auth_failure_count,
                last_error_message,
                created_by_user_id,
                updated_by_user_id,
                created_at,
                updated_at
            FROM gestor_tickets.mail_ingestion_jobs
            WHERE id = :job_id
        """),
        {"job_id": job_id},
    ).mappings().first()

    if not row:
        raise ValueError("El job de ingesta no existe.")

    return dict(row)


def _run_summary(db: Session, *, run_id: int) -> dict:
    row = db.execute(
        text("""
            SELECT
                id,
                job_id,
                account_id,
                status::text AS status,
                started_at,
                finished_at,
                scanned_inbox_count,
                scanned_sent_count,
                imported_count,
                duplicate_count,
                error_count,
                error_message,
                details_json
            FROM gestor_tickets.mail_ingestion_runs
            WHERE id = :run_id
        """),
        {"run_id": run_id},
    ).mappings().first()

    if not row:
        raise ValueError("La ejecución de ingesta no existe.")

    item = dict(row)
    item["details_json"] = item.get("details_json") or {}
    return item


def list_mail_ingestion_jobs(db: Session, *, account_id: int | None = None) -> list[dict]:
    params: dict[str, Any] = {}
    where = ""

    if account_id is not None:
        where = "WHERE account_id = :account_id"
        params["account_id"] = account_id

    rows = db.execute(
        text(f"""
            SELECT
                id,
                account_id,
                status::text AS status,
                scan_inbox,
                scan_sent,
                inbox_folder_name,
                sent_folder_name,
                interval_minutes,
                max_messages_per_folder,
                last_started_at,
                last_success_at,
                last_error_at,
                next_run_at,
                auth_failure_count,
                last_error_message,
                created_by_user_id,
                updated_by_user_id,
                created_at,
                updated_at
            FROM gestor_tickets.mail_ingestion_jobs
            {where}
            ORDER BY id
        """),
        params,
    ).mappings().all()

    return [dict(row) for row in rows]


def configure_mail_ingestion_job(
    db: Session,
    *,
    account_id: int,
    user_id: int | None,
    status: str = "active",
    scan_inbox: bool = True,
    scan_sent: bool = True,
    inbox_folder_name: str = "INBOX",
    sent_folder_name: str = "INBOX.Sent",
    interval_minutes: int = 5,
    max_messages_per_folder: int = 200,
) -> dict:
    if status not in VALID_JOB_STATUSES:
        raise ValueError(f"Estado de ingesta no válido: {status}")

    _get_account_email(db, account_id=account_id)

    job_id = db.execute(
        text("""
            INSERT INTO gestor_tickets.mail_ingestion_jobs (
                account_id,
                status,
                scan_inbox,
                scan_sent,
                inbox_folder_name,
                sent_folder_name,
                interval_minutes,
                max_messages_per_folder,
                next_run_at,
                created_by_user_id,
                updated_by_user_id,
                updated_at
            )
            VALUES (
                :account_id,
                CAST(:status AS gestor_tickets.ingestion_job_status),
                :scan_inbox,
                :scan_sent,
                :inbox_folder_name,
                :sent_folder_name,
                :interval_minutes,
                :max_messages_per_folder,
                now(),
                :user_id,
                :user_id,
                now()
            )
            ON CONFLICT (account_id)
            DO UPDATE SET
                status = CAST(:status AS gestor_tickets.ingestion_job_status),
                scan_inbox = EXCLUDED.scan_inbox,
                scan_sent = EXCLUDED.scan_sent,
                inbox_folder_name = EXCLUDED.inbox_folder_name,
                sent_folder_name = EXCLUDED.sent_folder_name,
                interval_minutes = EXCLUDED.interval_minutes,
                max_messages_per_folder = EXCLUDED.max_messages_per_folder,
                next_run_at = CASE
                    WHEN gestor_tickets.mail_ingestion_jobs.next_run_at IS NULL THEN now()
                    ELSE gestor_tickets.mail_ingestion_jobs.next_run_at
                END,
                updated_by_user_id = :user_id,
                updated_at = now()
            RETURNING id
        """),
        {
            "account_id": account_id,
            "status": status,
            "scan_inbox": scan_inbox,
            "scan_sent": scan_sent,
            "inbox_folder_name": inbox_folder_name,
            "sent_folder_name": sent_folder_name,
            "interval_minutes": interval_minutes,
            "max_messages_per_folder": max_messages_per_folder,
            "user_id": user_id,
        },
    ).scalar_one()

    db.execute(
        text("""
            UPDATE gestor_tickets.collaborative_accounts
            SET ingestion_enabled = :enabled,
                updated_at = now()
            WHERE id = :account_id
        """),
        {
            "account_id": account_id,
            "enabled": status == "active",
        },
    )

    db.commit()
    return _job_summary(db, job_id=job_id)


def reactivate_mail_ingestion_job(
    db: Session,
    *,
    account_id: int,
    user_id: int | None,
) -> dict:
    _get_account_email(db, account_id=account_id)

    job_id = db.execute(
        text("""
            SELECT id
            FROM gestor_tickets.mail_ingestion_jobs
            WHERE account_id = :account_id
            LIMIT 1
        """),
        {"account_id": account_id},
    ).scalar_one_or_none()

    if not job_id:
        raise ValueError("No hay job de ingesta configurado para esta cuenta.")

    db.execute(
        text("""
            UPDATE gestor_tickets.mail_ingestion_jobs
            SET status = 'active',
                auth_failure_count = 0,
                last_error_message = NULL,
                next_run_at = now(),
                updated_by_user_id = :user_id,
                updated_at = now()
            WHERE id = :job_id
        """),
        {"job_id": job_id, "user_id": user_id},
    )

    db.execute(
        text("""
            UPDATE gestor_tickets.collaborative_accounts
            SET status = 'active',
                ingestion_enabled = true,
                updated_at = now()
            WHERE id = :account_id
        """),
        {"account_id": account_id},
    )

    db.commit()
    return _job_summary(db, job_id=job_id)


def _create_run(db: Session, *, job: dict) -> int:
    run_id = db.execute(
        text("""
            INSERT INTO gestor_tickets.mail_ingestion_runs (
                job_id,
                account_id,
                status,
                details_json
            )
            VALUES (
                :job_id,
                :account_id,
                'running',
                '{}'::jsonb
            )
            RETURNING id
        """),
        {
            "job_id": job["id"],
            "account_id": job["account_id"],
        },
    ).scalar_one()

    db.execute(
        text("""
            UPDATE gestor_tickets.mail_ingestion_jobs
            SET last_started_at = now(),
                updated_at = now()
            WHERE id = :job_id
        """),
        {"job_id": job["id"]},
    )

    db.commit()
    return int(run_id)


def _existing_occurrence_id(
    db: Session,
    *,
    account_id: int,
    account_email: str,
    mailbox: str,
    uid: str,
) -> int | None:
    row = db.execute(
        text("""
            SELECT id
            FROM gestor_tickets.email_message_occurrences
            WHERE account_id = :account_id
              AND source_mailbox_email = :account_email
              AND folder_name = :mailbox
              AND imap_uid = :uid
            ORDER BY id
            LIMIT 1
        """),
        {
            "account_id": account_id,
            "account_email": account_email,
            "mailbox": mailbox,
            "uid": uid,
        },
    ).scalar_one_or_none()

    return int(row) if row is not None else None


def _mark_duplicate_seen(
    db: Session,
    *,
    occurrence_id: int,
    run_id: int,
) -> None:
    db.execute(
        text("""
            UPDATE gestor_tickets.email_message_occurrences
            SET last_seen_at = now(),
                ingestion_run_id = COALESCE(ingestion_run_id, :run_id)
            WHERE id = :occurrence_id
        """),
        {
            "occurrence_id": occurrence_id,
            "run_id": run_id,
        },
    )
    db.commit()


def _active_glpi_ticket_for_thread(
    db: Session,
    *,
    account_id: int,
    thread_id: int,
) -> dict | None:
    row = db.execute(
        text("""
            SELECT
                gtc.id,
                gtc.glpi_instance_id,
                gtc.glpi_ticket_id,
                gtc.title
            FROM gestor_tickets.glpi_ticket_thread_links gttl
            JOIN gestor_tickets.glpi_ticket_cache gtc
              ON gtc.id = gttl.glpi_ticket_cache_id
            WHERE gttl.account_id = :account_id
              AND gttl.thread_id = :thread_id
              AND gttl.status = 'active'
            ORDER BY gttl.id DESC
            LIMIT 1
        """),
        {
            "account_id": account_id,
            "thread_id": thread_id,
        },
    ).mappings().first()

    return dict(row) if row else None


def _auto_sync_ingested_email_to_ticket(
    db: Session,
    *,
    account_id: int,
    ticket: dict,
    thread_id: int,
    email_message_id: int,
    user_id: int | None,
) -> dict:
    ticket_cache_id = int(ticket["id"])

    link_created = db.execute(
        text("""
            INSERT INTO gestor_tickets.glpi_ticket_email_links (
                account_id,
                glpi_ticket_cache_id,
                email_message_id,
                origin,
                status,
                created_by_user_id,
                notes
            )
            SELECT
                :account_id,
                :ticket_cache_id,
                :email_message_id,
                'auto_sync',
                'active',
                :user_id,
                'Correo vinculado automáticamente por ingesta IMAP.'
            WHERE NOT EXISTS (
                SELECT 1
                FROM gestor_tickets.glpi_ticket_email_links
                WHERE glpi_ticket_cache_id = :ticket_cache_id
                  AND email_message_id = :email_message_id
                  AND status = 'active'
            )
            RETURNING id
        """),
        {
            "account_id": account_id,
            "ticket_cache_id": ticket_cache_id,
            "email_message_id": email_message_id,
            "user_id": user_id,
        },
    ).scalar_one_or_none()

    operation_exists = db.execute(
        text("""
            SELECT id
            FROM gestor_tickets.glpi_api_operations
            WHERE glpi_ticket_cache_id = :ticket_cache_id
              AND operation_type = 'auto_sync_ingested_email'
              AND request_payload_json->>'email_message_id' = :email_message_id
              AND success = true
            LIMIT 1
        """),
        {
            "ticket_cache_id": ticket_cache_id,
            "email_message_id": str(email_message_id),
        },
    ).scalar_one_or_none()

    operation_created = False
    if not operation_exists:
        db.execute(
            text("""
                INSERT INTO gestor_tickets.glpi_api_operations (
                    account_id,
                    glpi_instance_id,
                    glpi_ticket_cache_id,
                    operation_type,
                    requested_by_user_id,
                    request_payload_json,
                    response_status_code,
                    response_json,
                    success,
                    error_message
                )
                VALUES (
                    :account_id,
                    :glpi_instance_id,
                    :ticket_cache_id,
                    'auto_sync_ingested_email',
                    :user_id,
                    CAST(:request_payload_json AS jsonb),
                    NULL,
                    CAST(:response_json AS jsonb),
                    true,
                    NULL
                )
            """),
            {
                "account_id": account_id,
                "glpi_instance_id": ticket.get("glpi_instance_id"),
                "ticket_cache_id": ticket_cache_id,
                "user_id": user_id,
                "request_payload_json": json.dumps(
                    {
                        "thread_id": thread_id,
                        "email_message_id": email_message_id,
                        "source": "mail_ingestion",
                    },
                    ensure_ascii=False,
                ),
                "response_json": json.dumps(
                    {
                        "local_link_created": bool(link_created),
                        "external_followup_created": False,
                        "external_eml_attached": False,
                        "reason": "No hay credencial GLPI operacional configurada para ejecución automática.",
                    },
                    ensure_ascii=False,
                ),
            },
        )
        operation_created = True

    db.commit()

    return {
        "ticket_cache_id": ticket_cache_id,
        "glpi_ticket_id": ticket.get("glpi_ticket_id"),
        "email_link_created": bool(link_created),
        "operation_created": operation_created,
        "external_followup_created": False,
        "external_eml_attached": False,
    }


def _extract_result_value(result: Any, key: str) -> Any:
    if isinstance(result, dict):
        return result.get(key)
    if hasattr(result, key):
        return getattr(result, key)
    if hasattr(result, "model_dump"):
        return result.model_dump().get(key)
    if hasattr(result, "dict"):
        return result.dict().get(key)
    return None


def _finish_run(
    db: Session,
    *,
    job: dict,
    run_id: int,
    status: str,
    scanned_inbox_count: int,
    scanned_sent_count: int,
    imported_count: int,
    duplicate_count: int,
    error_count: int,
    error_message: str | None,
    details: dict[str, Any],
) -> None:
    db.execute(
        text("""
            UPDATE gestor_tickets.mail_ingestion_runs
            SET status = CAST(:status AS gestor_tickets.ingestion_run_status),
                finished_at = now(),
                scanned_inbox_count = :scanned_inbox_count,
                scanned_sent_count = :scanned_sent_count,
                imported_count = :imported_count,
                duplicate_count = :duplicate_count,
                error_count = :error_count,
                error_message = :error_message,
                details_json = CAST(:details_json AS jsonb)
            WHERE id = :run_id
        """),
        {
            "run_id": run_id,
            "status": status,
            "scanned_inbox_count": scanned_inbox_count,
            "scanned_sent_count": scanned_sent_count,
            "imported_count": imported_count,
            "duplicate_count": duplicate_count,
            "error_count": error_count,
            "error_message": error_message,
            "details_json": json.dumps(details, ensure_ascii=False),
        },
    )

    if status == "success":
        db.execute(
            text("""
                UPDATE gestor_tickets.mail_ingestion_jobs
                SET last_success_at = now(),
                    last_error_message = NULL,
                    auth_failure_count = 0,
                    next_run_at = now() + (:interval_minutes * interval '1 minute'),
                    status = 'active',
                    updated_at = now()
                WHERE id = :job_id
            """),
            {
                "job_id": job["id"],
                "interval_minutes": job["interval_minutes"],
            },
        )
    else:
        db.execute(
            text("""
                UPDATE gestor_tickets.mail_ingestion_jobs
                SET last_error_at = now(),
                    last_error_message = :error_message,
                    next_run_at = now() + (:interval_minutes * interval '1 minute'),
                    updated_at = now()
                WHERE id = :job_id
            """),
            {
                "job_id": job["id"],
                "interval_minutes": job["interval_minutes"],
                "error_message": error_message,
            },
        )

    db.commit()


def run_mail_ingestion_job(
    db: Session,
    *,
    job_id: int,
    user_id: int | None = None,
) -> tuple[dict, dict]:
    job = _job_summary(db, job_id=job_id)

    if job["status"] != "active":
        raise ValueError(f"El job no está activo. Estado actual: {job['status']}")

    account_id = int(job["account_id"])
    account_email = _get_account_email(db, account_id=account_id)
    run_id = _create_run(db, job=job)

    mailboxes: list[str] = []
    if job["scan_inbox"]:
        mailboxes.append(job["inbox_folder_name"])
    if job["scan_sent"] and job["sent_folder_name"] not in mailboxes:
        mailboxes.append(job["sent_folder_name"])

    imported_count = 0
    duplicate_count = 0
    error_count = 0
    errors: list[dict[str, Any]] = []
    imported: list[dict[str, Any]] = []
    duplicates: list[dict[str, Any]] = []
    scanned_inbox_count = 0
    scanned_sent_count = 0

    try:
        preview = preview_unified_collaborative_mailbox(
            db,
            account_id=account_id,
            mailboxes=mailboxes,
            limit_per_mailbox=int(job["max_messages_per_folder"]),
            total_limit=int(job["max_messages_per_folder"]) * max(len(mailboxes), 1),
        )
        preview_data = _plain(preview)

        totals = preview_data.get("total_messages_by_mailbox") or {}
        scanned_inbox_count = int(totals.get(job["inbox_folder_name"], 0) or 0)
        scanned_sent_count = int(totals.get(job["sent_folder_name"], 0) or 0)

        messages = preview_data.get("messages") or []

        for item in messages:
            message = _plain(item)
            mailbox = str(message.get("mailbox") or "").strip()
            uid = str(message.get("uid") or "").strip()

            if not mailbox or not uid:
                error_count += 1
                errors.append({"mailbox": mailbox, "uid": uid, "error": "Mensaje sin mailbox o uid."})
                continue

            existing_id = _existing_occurrence_id(
                db,
                account_id=account_id,
                account_email=account_email,
                mailbox=mailbox,
                uid=uid,
            )

            if existing_id:
                duplicate_count += 1
                _mark_duplicate_seen(
                    db,
                    occurrence_id=existing_id,
                    run_id=run_id,
                )
                duplicates.append({"mailbox": mailbox, "uid": uid, "occurrence_id": existing_id})
                continue

            try:
                archive_result = archive_message_from_imap_readonly(
                    db,
                    account_id=account_id,
                    mailbox=mailbox,
                    uid=uid,
                )

                email_message_id = _extract_result_value(archive_result, "email_message_id")
                occurrence_id = _extract_result_value(archive_result, "occurrence_id")

                if occurrence_id:
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
                    db.commit()

                thread_info = None
                ticket_sync = None
                if email_message_id:
                    thread, thread_changed = create_thread_from_email(
                        db,
                        account_id=account_id,
                        email_message_id=int(email_message_id),
                        created_by_user_id=user_id,
                        reason="Creación automática por ingesta programada IMAP.",
                    )
                    thread_info = {
                        "thread_id": thread.get("id"),
                        "thread_changed": thread_changed,
                    }

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
                            email_message_id=int(email_message_id),
                            user_id=user_id,
                        )

                imported_count += 1
                imported.append(
                    {
                        "mailbox": mailbox,
                        "uid": uid,
                        "email_message_id": email_message_id,
                        "occurrence_id": occurrence_id,
                        "thread": thread_info,
                        "ticket_sync": ticket_sync,
                    }
                )

            except Exception as exc:
                error_count += 1
                errors.append({"mailbox": mailbox, "uid": uid, "error": str(exc)})

        run_status = "success" if error_count == 0 else ("partial_error" if imported_count or duplicate_count else "failed")
        error_message = None if error_count == 0 else f"{error_count} error(es) durante la ingesta."

        details = {
            "mailboxes": mailboxes,
            "imported": imported,
            "duplicates": duplicates,
            "errors": errors,
            "safety": {
                "imap_readonly": True,
                "body_peek": True,
                "store_used": False,
                "flags_modified": False,
            },
        }

        _finish_run(
            db,
            job=job,
            run_id=run_id,
            status=run_status,
            scanned_inbox_count=scanned_inbox_count,
            scanned_sent_count=scanned_sent_count,
            imported_count=imported_count,
            duplicate_count=duplicate_count,
            error_count=error_count,
            error_message=error_message,
            details=details,
        )

        return _job_summary(db, job_id=job_id), _run_summary(db, run_id=run_id)

    except Exception as exc:
        details = {
            "mailboxes": mailboxes,
            "imported": imported,
            "duplicates": duplicates,
            "errors": errors + [{"error": str(exc)}],
            "safety": {
                "imap_readonly": True,
                "body_peek": True,
                "store_used": False,
                "flags_modified": False,
            },
        }

        _finish_run(
            db,
            job=job,
            run_id=run_id,
            status="failed",
            scanned_inbox_count=scanned_inbox_count,
            scanned_sent_count=scanned_sent_count,
            imported_count=imported_count,
            duplicate_count=duplicate_count,
            error_count=max(error_count, 1),
            error_message=str(exc),
            details=details,
        )

        _apply_auth_failure_policy(db, job=job, exc=exc)

        raise


def run_due_mail_ingestion_jobs(db: Session) -> list[tuple[dict, dict]]:
    rows = db.execute(
        text("""
            SELECT id
            FROM gestor_tickets.mail_ingestion_jobs
            WHERE status = 'active'
              AND (next_run_at IS NULL OR next_run_at <= now())
            ORDER BY next_run_at NULLS FIRST, id
        """)
    ).scalars().all()

    results: list[tuple[dict, dict]] = []
    for job_id in rows:
        results.append(run_mail_ingestion_job(db, job_id=int(job_id), user_id=None))

    return results
