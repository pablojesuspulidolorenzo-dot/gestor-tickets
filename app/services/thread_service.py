from __future__ import annotations

import json
import re

from sqlalchemy import text
from sqlalchemy.orm import Session


def _clean_text(value: str | None) -> str:
    return (value or "").strip()


def normalize_subject(value: str | None) -> str | None:
    value = _clean_text(value)
    if not value:
        return None

    value = re.sub(r"^\s*(re|rv|fw|fwd)\s*:\s*", "", value, flags=re.IGNORECASE)
    value = re.sub(r"\s+", " ", value).strip().lower()
    return value or None


def _row_to_dict(row) -> dict | None:
    if row is None:
        return None
    return dict(row)


def get_thread_summary(db: Session, *, thread_id: int) -> dict | None:
    row = db.execute(
        text("""
            SELECT
                st.id,
                st.system_thread_uid::text AS system_thread_uid,
                st.account_id,
                st.title,
                st.subject_normalized,
                st.status::text AS status,
                count(etm.id)::int AS message_count,
                max(em.sent_at) AS last_message_at,
                st.updated_at
            FROM gestor_tickets.system_threads st
            LEFT JOIN gestor_tickets.email_thread_members etm
              ON etm.thread_id = st.id
             AND etm.status = 'active'
            LEFT JOIN gestor_tickets.email_messages em
              ON em.id = etm.email_message_id
            WHERE st.id = :thread_id
            GROUP BY st.id
        """),
        {"thread_id": thread_id},
    ).mappings().first()

    return _row_to_dict(row)


def list_system_threads(db: Session, *, account_id: int) -> list[dict]:
    rows = db.execute(
        text("""
            SELECT
                st.id,
                st.system_thread_uid::text AS system_thread_uid,
                st.account_id,
                st.title,
                st.subject_normalized,
                st.status::text AS status,
                count(etm.id)::int AS message_count,
                max(em.sent_at) AS last_message_at,
                st.updated_at
            FROM gestor_tickets.system_threads st
            LEFT JOIN gestor_tickets.email_thread_members etm
              ON etm.thread_id = st.id
             AND etm.status = 'active'
            LEFT JOIN gestor_tickets.email_messages em
              ON em.id = etm.email_message_id
            WHERE st.account_id = :account_id
              AND st.status = 'active'
            GROUP BY st.id
            ORDER BY coalesce(max(em.sent_at), st.updated_at) DESC, st.id DESC
        """),
        {"account_id": account_id},
    ).mappings().all()

    return [dict(row) for row in rows]


def get_active_thread_for_email(db: Session, *, email_message_id: int) -> dict | None:
    row = db.execute(
        text("""
            SELECT
                st.id,
                st.system_thread_uid::text AS system_thread_uid,
                st.account_id,
                st.title,
                st.subject_normalized,
                st.status::text AS status,
                count(etm_all.id)::int AS message_count,
                max(em_all.sent_at) AS last_message_at,
                st.updated_at
            FROM gestor_tickets.email_thread_members etm
            JOIN gestor_tickets.system_threads st
              ON st.id = etm.thread_id
            LEFT JOIN gestor_tickets.email_thread_members etm_all
              ON etm_all.thread_id = st.id
             AND etm_all.status = 'active'
            LEFT JOIN gestor_tickets.email_messages em_all
              ON em_all.id = etm_all.email_message_id
            WHERE etm.email_message_id = :email_message_id
              AND etm.status = 'active'
              AND st.status = 'active'
            GROUP BY st.id
            LIMIT 1
        """),
        {"email_message_id": email_message_id},
    ).mappings().first()

    return _row_to_dict(row)


def _get_email_message(db: Session, *, account_id: int, email_message_id: int) -> dict:
    row = db.execute(
        text("""
            SELECT
                id,
                account_id,
                subject,
                subject_normalized,
                message_id_header,
                sent_at,
                direction
            FROM gestor_tickets.email_messages
            WHERE id = :email_message_id
              AND account_id = :account_id
            LIMIT 1
        """),
        {
            "account_id": account_id,
            "email_message_id": email_message_id,
        },
    ).mappings().first()

    if not row:
        raise ValueError("El correo archivado no existe para esta cuenta.")

    return dict(row)


def create_thread_from_email(
    db: Session,
    *,
    account_id: int,
    email_message_id: int,
    created_by_user_id: int | None = None,
    reason: str = "Creación manual desde correo archivado.",
) -> tuple[dict, bool]:
    email_message = _get_email_message(
        db,
        account_id=account_id,
        email_message_id=email_message_id,
    )

    existing = get_active_thread_for_email(db, email_message_id=email_message_id)
    if existing:
        return existing, False

    title = _clean_text(email_message.get("subject")) or "(Sin asunto)"
    subject_normalized = (
        _clean_text(email_message.get("subject_normalized"))
        or normalize_subject(title)
    )

    thread_id = db.execute(
        text("""
            INSERT INTO gestor_tickets.system_threads (
                account_id,
                title,
                subject_normalized,
                detected_from_message_id,
                created_reason,
                created_by_user_id
            )
            VALUES (
                :account_id,
                :title,
                :subject_normalized,
                :detected_from_message_id,
                :created_reason,
                :created_by_user_id
            )
            RETURNING id
        """),
        {
            "account_id": account_id,
            "title": title,
            "subject_normalized": subject_normalized,
            "detected_from_message_id": email_message_id,
            "created_reason": reason,
            "created_by_user_id": created_by_user_id,
        },
    ).scalar_one()

    db.execute(
        text("""
            INSERT INTO gestor_tickets.email_thread_members (
                thread_id,
                email_message_id,
                position_asc,
                added_by_user_id,
                added_reason
            )
            VALUES (
                :thread_id,
                :email_message_id,
                0,
                :added_by_user_id,
                :added_reason
            )
        """),
        {
            "thread_id": thread_id,
            "email_message_id": email_message_id,
            "added_by_user_id": created_by_user_id,
            "added_reason": reason,
        },
    )

    db.execute(
        text("""
            INSERT INTO gestor_tickets.thread_operations (
                account_id,
                operation_type,
                target_thread_id,
                email_message_id,
                performed_by_user_id,
                reason,
                details_json
            )
            VALUES (
                :account_id,
                'create_thread',
                :target_thread_id,
                :email_message_id,
                :performed_by_user_id,
                :reason,
                CAST(:details_json AS jsonb)
            )
        """),
        {
            "account_id": account_id,
            "target_thread_id": thread_id,
            "email_message_id": email_message_id,
            "performed_by_user_id": created_by_user_id,
            "reason": reason,
            "details_json": json.dumps(
                {
                    "source": "mailbox_message_detail",
                    "email_message_id": email_message_id,
                    "subject": title,
                }
            ),
        },
    )

    db.commit()

    created = get_thread_summary(db, thread_id=thread_id)
    if not created:
        raise ValueError("No se pudo recuperar el hilo creado.")

    return created, True


def list_thread_messages(
    db: Session,
    *,
    account_id: int,
    thread_id: int,
) -> list[dict]:
    rows = db.execute(
        text("""
            SELECT
                etm.id AS member_id,
                etm.email_message_id,
                etm.position_asc,
                em.subject,
                em.from_email,
                em.from_name,
                em.direction::text AS direction,
                em.sent_at,
                em.original_imap_folder,
                em.original_imap_uid,
                em.body_text_preview
            FROM gestor_tickets.email_thread_members etm
            JOIN gestor_tickets.email_messages em
              ON em.id = etm.email_message_id
            JOIN gestor_tickets.system_threads st
              ON st.id = etm.thread_id
            WHERE etm.thread_id = :thread_id
              AND st.account_id = :account_id
              AND etm.status = 'active'
            ORDER BY
                coalesce(em.sent_at, em.created_at) ASC,
                etm.position_asc ASC,
                etm.id ASC
        """),
        {
            "account_id": account_id,
            "thread_id": thread_id,
        },
    ).mappings().all()

    return [dict(row) for row in rows]


def get_thread_detail(
    db: Session,
    *,
    account_id: int,
    thread_id: int,
) -> tuple[dict, list[dict]]:
    summary = get_thread_summary(db, thread_id=thread_id)

    if not summary or int(summary["account_id"]) != int(account_id):
        raise ValueError("El hilo no existe para esta cuenta.")

    messages = list_thread_messages(
        db,
        account_id=account_id,
        thread_id=thread_id,
    )

    return summary, messages
