from __future__ import annotations

import json
from dataclasses import dataclass
from typing import Any
from urllib.parse import urljoin

import httpx
from sqlalchemy import text
from sqlalchemy.orm import Session

from app.core.config import settings
from app.services.thread_service import get_thread_detail


@dataclass(frozen=True)
class GlpiTicketResult:
    ok: bool
    created: bool
    thread_id: int
    glpi_ticket_cache: dict[str, Any]
    message: str


def _clean_text(value: str | None) -> str:
    return (value or "").strip()


def _api_url(path: str) -> str:
    base_url = settings.GLPI_BASE_URL.rstrip("/") + "/"
    return urljoin(base_url, f"apirest.php/{path.lstrip('/')}")


def _headers(session_token: str | None = None) -> dict[str, str]:
    headers = {
        "Content-Type": "application/json",
        "Accept": "application/json",
    }

    if settings.GLPI_APP_TOKEN:
        headers["App-Token"] = settings.GLPI_APP_TOKEN

    if session_token:
        headers["Session-Token"] = session_token

    return headers


def _params() -> dict[str, str]:
    if not settings.GLPI_APP_TOKEN:
        return {}
    return {"app_token": settings.GLPI_APP_TOKEN}


def _init_session(login: str, password: str) -> str:
    with httpx.Client(timeout=settings.GLPI_TIMEOUT_SECONDS) as client:
        response = client.get(
            _api_url("initSession"),
            headers=_headers(),
            params=_params(),
            auth=httpx.BasicAuth(login, password),
        )

    if response.status_code != 200:
        raise ValueError(
            f"GLPI rechazó la autenticación para crear ticket "
            f"(HTTP {response.status_code}): {response.text[:500]}"
        )

    data = response.json()
    token = data.get("session_token")
    if not token:
        raise ValueError(f"GLPI no devolvió session_token: {data}")

    return token


def _kill_session(session_token: str) -> None:
    try:
        with httpx.Client(timeout=settings.GLPI_TIMEOUT_SECONDS) as client:
            client.get(
                _api_url("killSession"),
                headers=_headers(session_token),
                params=_params(),
            )
    except Exception:
        pass


def _get_account(db: Session, *, account_id: int) -> dict:
    row = db.execute(
        text("""
            SELECT
                ca.id,
                ca.email::text AS email,
                ca.display_name,
                ca.glpi_login::text AS glpi_login,
                ca.glpi_instance_id,
                ca.glpi_entity_id,
                ca.glpi_group_id
            FROM gestor_tickets.collaborative_accounts ca
            WHERE ca.id = :account_id
            LIMIT 1
        """),
        {"account_id": account_id},
    ).mappings().first()

    if not row:
        raise ValueError("La cuenta colaborativa no existe.")

    return dict(row)


def _ensure_glpi_instance(db: Session, *, account: dict) -> int:
    instance_id = account.get("glpi_instance_id")

    if instance_id:
        return int(instance_id)

    base_url = settings.GLPI_BASE_URL.rstrip("/")

    existing = db.execute(
        text("""
            SELECT id
            FROM gestor_tickets.glpi_instances
            WHERE base_url = :base_url
            LIMIT 1
        """),
        {"base_url": base_url},
    ).scalar_one_or_none()

    if existing:
        instance_id = int(existing)
    else:
        instance_id = db.execute(
            text("""
                INSERT INTO gestor_tickets.glpi_instances (
                    name,
                    base_url,
                    active,
                    notes
                )
                VALUES (
                    'GLPI local',
                    :base_url,
                    true,
                    'Instancia creada automáticamente por gestor-tickets para cachear tickets.'
                )
                RETURNING id
            """),
            {"base_url": base_url},
        ).scalar_one()

    db.execute(
        text("""
            UPDATE gestor_tickets.collaborative_accounts
            SET glpi_instance_id = :glpi_instance_id,
                updated_at = now()
            WHERE id = :account_id
        """),
        {
            "glpi_instance_id": instance_id,
            "account_id": account["id"],
        },
    )

    return int(instance_id)


def _existing_active_ticket_for_thread(
    db: Session,
    *,
    account_id: int,
    thread_id: int,
) -> dict | None:
    row = db.execute(
        text("""
            SELECT
                gtc.id,
                gtc.glpi_ticket_id,
                gtc.title,
                gtc.status,
                gtc.priority,
                gtc.urgency,
                gtc.impact
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


def _build_ticket_content(*, thread: dict, messages: list[dict]) -> str:
    lines = [
        "Ticket creado desde gestor-tickets.",
        "",
        f"Hilo interno: #{thread['id']}",
        f"Asunto del hilo: {thread.get('title') or '(Sin asunto)'}",
        f"UID del hilo: {thread.get('system_thread_uid')}",
        "",
        "Resumen cronológico de correos archivados:",
        "",
    ]

    for index, message in enumerate(messages, start=1):
        lines.extend(
            [
                f"{index}. {message.get('subject') or '(Sin asunto)'}",
                f"   Fecha: {message.get('sent_at') or 'No disponible'}",
                f"   De: {message.get('from_email') or 'No disponible'}",
                f"   Carpeta IMAP: {message.get('original_imap_folder') or 'No disponible'}",
                f"   UID IMAP: {message.get('original_imap_uid') or 'No disponible'}",
                "",
            ]
        )

        preview = _clean_text(message.get("body_text_preview"))
        if preview:
            lines.extend(
                [
                    "   Texto del correo:",
                    f"   {preview}",
                    "",
                ]
            )

    lines.extend(
        [
            "---",
            "Nota: el correo original .eml queda archivado en gestor-tickets.",
        ]
    )

    return "\n".join(lines)


def _create_glpi_ticket(
    *,
    session_token: str,
    title: str,
    content: str,
    entity_id: int | None,
) -> tuple[int, dict, int]:
    payload_input: dict[str, Any] = {
        "name": title,
        "content": content,
        "type": 1,
        "urgency": 3,
        "impact": 3,
        "priority": 3,
    }

    if entity_id is not None:
        payload_input["entities_id"] = entity_id

    payload = {"input": payload_input}

    with httpx.Client(timeout=settings.GLPI_TIMEOUT_SECONDS) as client:
        response = client.post(
            _api_url("Ticket"),
            headers=_headers(session_token),
            params=_params(),
            json=payload,
        )

    if response.status_code not in {200, 201}:
        raise ValueError(
            f"No se pudo crear ticket GLPI "
            f"(HTTP {response.status_code}): {response.text[:1000]}"
        )

    data = response.json()
    ticket_id = data.get("id") or data.get("item", {}).get("id")

    if not ticket_id:
        raise ValueError(f"GLPI no devolvió id de ticket al crear: {data}")

    return int(ticket_id), data, response.status_code


def _get_glpi_ticket(*, session_token: str, ticket_id: int) -> dict:
    with httpx.Client(timeout=settings.GLPI_TIMEOUT_SECONDS) as client:
        response = client.get(
            _api_url(f"Ticket/{ticket_id}"),
            headers=_headers(session_token),
            params=_params(),
        )

    if response.status_code != 200:
        return {"id": ticket_id}

    data = response.json()
    return data if isinstance(data, dict) else {"id": ticket_id, "raw": data}


def _cache_ticket(
    db: Session,
    *,
    account_id: int,
    glpi_instance_id: int,
    ticket_id: int,
    raw_ticket: dict,
) -> dict:
    title = raw_ticket.get("name") or raw_ticket.get("title")
    status = raw_ticket.get("status")
    priority = raw_ticket.get("priority")
    urgency = raw_ticket.get("urgency")
    impact = raw_ticket.get("impact")
    entity_id = raw_ticket.get("entities_id")
    group_id = raw_ticket.get("groups_id_assign") or raw_ticket.get("group_id")

    cache_id = db.execute(
        text("""
            INSERT INTO gestor_tickets.glpi_ticket_cache (
                account_id,
                glpi_instance_id,
                glpi_ticket_id,
                title,
                status,
                priority,
                urgency,
                impact,
                entity_id,
                group_id,
                raw_json,
                last_sync_at
            )
            VALUES (
                :account_id,
                :glpi_instance_id,
                :glpi_ticket_id,
                :title,
                :status,
                :priority,
                :urgency,
                :impact,
                :entity_id,
                :group_id,
                CAST(:raw_json AS jsonb),
                now()
            )
            ON CONFLICT (glpi_instance_id, glpi_ticket_id)
            DO UPDATE SET
                account_id = EXCLUDED.account_id,
                title = EXCLUDED.title,
                status = EXCLUDED.status,
                priority = EXCLUDED.priority,
                urgency = EXCLUDED.urgency,
                impact = EXCLUDED.impact,
                entity_id = EXCLUDED.entity_id,
                group_id = EXCLUDED.group_id,
                raw_json = EXCLUDED.raw_json,
                last_sync_at = now(),
                updated_at = now()
            RETURNING id
        """),
        {
            "account_id": account_id,
            "glpi_instance_id": glpi_instance_id,
            "glpi_ticket_id": ticket_id,
            "title": title,
            "status": str(status) if status is not None else None,
            "priority": str(priority) if priority is not None else None,
            "urgency": str(urgency) if urgency is not None else None,
            "impact": str(impact) if impact is not None else None,
            "entity_id": entity_id,
            "group_id": group_id,
            "raw_json": json.dumps(raw_ticket),
        },
    ).scalar_one()

    row = db.execute(
        text("""
            SELECT
                id,
                glpi_ticket_id,
                title,
                status,
                priority,
                urgency,
                impact
            FROM gestor_tickets.glpi_ticket_cache
            WHERE id = :id
        """),
        {"id": cache_id},
    ).mappings().first()

    return dict(row)


def _link_ticket_to_thread_and_messages(
    db: Session,
    *,
    account_id: int,
    ticket_cache_id: int,
    thread_id: int,
    user_id: int | None,
) -> None:
    db.execute(
        text("""
            INSERT INTO gestor_tickets.glpi_ticket_thread_links (
                account_id,
                glpi_ticket_cache_id,
                thread_id,
                origin,
                status,
                created_by_user_id,
                notes
            )
            SELECT
                :account_id,
                :glpi_ticket_cache_id,
                :thread_id,
                'created_from_thread',
                'active',
                :created_by_user_id,
                'Ticket creado desde hilo operativo.'
            WHERE NOT EXISTS (
                SELECT 1
                FROM gestor_tickets.glpi_ticket_thread_links
                WHERE glpi_ticket_cache_id = :glpi_ticket_cache_id
                  AND thread_id = :thread_id
                  AND status = 'active'
            )
        """),
        {
            "account_id": account_id,
            "glpi_ticket_cache_id": ticket_cache_id,
            "thread_id": thread_id,
            "created_by_user_id": user_id,
        },
    )

    db.execute(
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
                :glpi_ticket_cache_id,
                etm.email_message_id,
                'created_from_thread',
                'active',
                :created_by_user_id,
                'Enlace creado automáticamente al crear ticket desde hilo.'
            FROM gestor_tickets.email_thread_members etm
            WHERE etm.thread_id = :thread_id
              AND etm.status = 'active'
              AND NOT EXISTS (
                  SELECT 1
                  FROM gestor_tickets.glpi_ticket_email_links existing
                  WHERE existing.glpi_ticket_cache_id = :glpi_ticket_cache_id
                    AND existing.email_message_id = etm.email_message_id
                    AND existing.status = 'active'
              )
        """),
        {
            "account_id": account_id,
            "glpi_ticket_cache_id": ticket_cache_id,
            "thread_id": thread_id,
            "created_by_user_id": user_id,
        },
    )


def _log_glpi_operation(
    db: Session,
    *,
    account_id: int,
    glpi_instance_id: int,
    glpi_ticket_cache_id: int | None,
    operation_type: str,
    requested_by_user_id: int | None,
    request_payload: dict,
    response_status_code: int | None,
    response_json: dict | None,
    success: bool,
    error_message: str | None = None,
) -> None:
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
                :glpi_ticket_cache_id,
                :operation_type,
                :requested_by_user_id,
                CAST(:request_payload_json AS jsonb),
                :response_status_code,
                CAST(:response_json AS jsonb),
                :success,
                :error_message
            )
        """),
        {
            "account_id": account_id,
            "glpi_instance_id": glpi_instance_id,
            "glpi_ticket_cache_id": glpi_ticket_cache_id,
            "operation_type": operation_type,
            "requested_by_user_id": requested_by_user_id,
            "request_payload_json": json.dumps(request_payload),
            "response_status_code": response_status_code,
            "response_json": json.dumps(response_json or {}),
            "success": success,
            "error_message": error_message,
        },
    )


def create_glpi_ticket_from_thread(
    db: Session,
    *,
    account_id: int,
    thread_id: int,
    user_id: int | None,
    glpi_password: str,
    title_override: str | None = None,
) -> GlpiTicketResult:
    account = _get_account(db, account_id=account_id)
    glpi_instance_id = _ensure_glpi_instance(db, account=account)

    existing = _existing_active_ticket_for_thread(
        db,
        account_id=account_id,
        thread_id=thread_id,
    )
    if existing:
        return GlpiTicketResult(
            ok=True,
            created=False,
            thread_id=thread_id,
            glpi_ticket_cache=existing,
            message="El hilo ya tiene un ticket GLPI activo relacionado.",
        )

    thread, messages = get_thread_detail(
        db,
        account_id=account_id,
        thread_id=thread_id,
    )

    title = _clean_text(title_override) or _clean_text(thread.get("title")) or f"Hilo #{thread_id}"
    content = _build_ticket_content(thread=thread, messages=messages)

    session_token: str | None = None
    request_payload = {
        "thread_id": thread_id,
        "title": title,
        "content_preview": content[:500],
    }

    try:
        session_token = _init_session(account["glpi_login"], glpi_password)

        ticket_id, create_response, status_code = _create_glpi_ticket(
            session_token=session_token,
            title=title,
            content=content,
            entity_id=account.get("glpi_entity_id") or 0,
        )

        raw_ticket = _get_glpi_ticket(
            session_token=session_token,
            ticket_id=ticket_id,
        )

        cache = _cache_ticket(
            db,
            account_id=account_id,
            glpi_instance_id=glpi_instance_id,
            ticket_id=ticket_id,
            raw_ticket=raw_ticket,
        )

        _link_ticket_to_thread_and_messages(
            db,
            account_id=account_id,
            ticket_cache_id=int(cache["id"]),
            thread_id=thread_id,
            user_id=user_id,
        )

        _log_glpi_operation(
            db,
            account_id=account_id,
            glpi_instance_id=glpi_instance_id,
            glpi_ticket_cache_id=int(cache["id"]),
            operation_type="create_ticket_from_thread",
            requested_by_user_id=user_id,
            request_payload=request_payload,
            response_status_code=status_code,
            response_json=create_response,
            success=True,
        )

        db.commit()

        return GlpiTicketResult(
            ok=True,
            created=True,
            thread_id=thread_id,
            glpi_ticket_cache=cache,
            message="Ticket GLPI creado y relacionado con el hilo.",
        )

    except Exception as exc:
        db.rollback()

        try:
            _log_glpi_operation(
                db,
                account_id=account_id,
                glpi_instance_id=glpi_instance_id,
                glpi_ticket_cache_id=None,
                operation_type="create_ticket_from_thread",
                requested_by_user_id=user_id,
                request_payload=request_payload,
                response_status_code=None,
                response_json={},
                success=False,
                error_message=str(exc),
            )
            db.commit()
        except Exception:
            db.rollback()

        raise

    finally:
        if session_token:
            _kill_session(session_token)


def list_glpi_tickets_for_thread(
    db: Session,
    *,
    account_id: int,
    thread_id: int,
) -> list[dict]:
    rows = db.execute(
        text("""
            SELECT
                gtc.id,
                gtc.glpi_ticket_id,
                gtc.title,
                gtc.status,
                gtc.priority,
                gtc.urgency,
                gtc.impact,
                gttl.origin::text AS origin,
                gttl.created_at
            FROM gestor_tickets.glpi_ticket_thread_links gttl
            JOIN gestor_tickets.glpi_ticket_cache gtc
              ON gtc.id = gttl.glpi_ticket_cache_id
            WHERE gttl.account_id = :account_id
              AND gttl.thread_id = :thread_id
              AND gttl.status = 'active'
            ORDER BY gttl.id DESC
        """),
        {
            "account_id": account_id,
            "thread_id": thread_id,
        },
    ).mappings().all()

    return [dict(row) for row in rows]


def list_glpi_ticket_cache(
    db: Session,
    *,
    account_id: int,
) -> list[dict]:
    rows = db.execute(
        text("""
            SELECT
                gtc.id,
                gtc.account_id,
                gtc.glpi_instance_id,
                gtc.glpi_ticket_id,
                gtc.title,
                gtc.status,
                gtc.priority,
                gtc.urgency,
                gtc.impact,
                count(distinct gttl.id)::int AS thread_count,
                count(distinct gtel.id)::int AS email_count,
                gtc.last_sync_at,
                gtc.updated_at
            FROM gestor_tickets.glpi_ticket_cache gtc
            LEFT JOIN gestor_tickets.glpi_ticket_thread_links gttl
              ON gttl.glpi_ticket_cache_id = gtc.id
             AND gttl.status = 'active'
            LEFT JOIN gestor_tickets.glpi_ticket_email_links gtel
              ON gtel.glpi_ticket_cache_id = gtc.id
             AND gtel.status = 'active'
            WHERE gtc.account_id = :account_id
            GROUP BY gtc.id
            ORDER BY coalesce(gtc.last_sync_at, gtc.updated_at) DESC, gtc.id DESC
        """),
        {"account_id": account_id},
    ).mappings().all()

    return [dict(row) for row in rows]


def get_glpi_ticket_detail(
    db: Session,
    *,
    account_id: int,
    ticket_cache_id: int,
) -> tuple[dict, list[dict], list[dict]]:
    ticket = db.execute(
        text("""
            SELECT
                gtc.id,
                gtc.account_id,
                gtc.glpi_instance_id,
                gtc.glpi_ticket_id,
                gtc.title,
                gtc.status,
                gtc.priority,
                gtc.urgency,
                gtc.impact,
                (
                    SELECT count(distinct gttl.id)::int
                    FROM gestor_tickets.glpi_ticket_thread_links gttl
                    WHERE gttl.glpi_ticket_cache_id = gtc.id
                      AND gttl.status = 'active'
                ) AS thread_count,
                (
                    SELECT count(distinct gtel.id)::int
                    FROM gestor_tickets.glpi_ticket_email_links gtel
                    WHERE gtel.glpi_ticket_cache_id = gtc.id
                      AND gtel.status = 'active'
                ) AS email_count,
                gtc.last_sync_at,
                gtc.updated_at
            FROM gestor_tickets.glpi_ticket_cache gtc
            WHERE gtc.id = :ticket_cache_id
              AND gtc.account_id = :account_id
            LIMIT 1
        """),
        {
            "account_id": account_id,
            "ticket_cache_id": ticket_cache_id,
        },
    ).mappings().first()

    if not ticket:
        raise ValueError("El ticket GLPI cacheado no existe para esta cuenta.")

    threads = db.execute(
        text("""
            SELECT
                gttl.id AS link_id,
                st.id AS thread_id,
                st.title AS thread_title,
                st.status::text AS thread_status,
                gttl.origin::text AS origin,
                gttl.created_at
            FROM gestor_tickets.glpi_ticket_thread_links gttl
            JOIN gestor_tickets.system_threads st
              ON st.id = gttl.thread_id
            WHERE gttl.glpi_ticket_cache_id = :ticket_cache_id
              AND gttl.account_id = :account_id
              AND gttl.status = 'active'
            ORDER BY gttl.created_at DESC, gttl.id DESC
        """),
        {
            "account_id": account_id,
            "ticket_cache_id": ticket_cache_id,
        },
    ).mappings().all()

    emails = db.execute(
        text("""
            SELECT
                gtel.id AS link_id,
                em.id AS email_message_id,
                em.subject,
                em.from_email,
                em.sent_at,
                gtel.origin::text AS origin,
                gtel.created_at
            FROM gestor_tickets.glpi_ticket_email_links gtel
            JOIN gestor_tickets.email_messages em
              ON em.id = gtel.email_message_id
            WHERE gtel.glpi_ticket_cache_id = :ticket_cache_id
              AND gtel.account_id = :account_id
              AND gtel.status = 'active'
            ORDER BY coalesce(em.sent_at, gtel.created_at) ASC, gtel.id ASC
        """),
        {
            "account_id": account_id,
            "ticket_cache_id": ticket_cache_id,
        },
    ).mappings().all()

    return dict(ticket), [dict(row) for row in threads], [dict(row) for row in emails]


def refresh_glpi_ticket_cache(
    db: Session,
    *,
    account_id: int,
    ticket_cache_id: int,
    user_id: int | None,
    glpi_password: str,
) -> dict:
    ticket = db.execute(
        text("""
            SELECT
                id,
                account_id,
                glpi_instance_id,
                glpi_ticket_id
            FROM gestor_tickets.glpi_ticket_cache
            WHERE id = :ticket_cache_id
              AND account_id = :account_id
            LIMIT 1
        """),
        {
            "account_id": account_id,
            "ticket_cache_id": ticket_cache_id,
        },
    ).mappings().first()

    if not ticket:
        raise ValueError("El ticket GLPI cacheado no existe para esta cuenta.")

    account = _get_account(db, account_id=account_id)
    glpi_instance_id = int(ticket["glpi_instance_id"])
    glpi_ticket_id = int(ticket["glpi_ticket_id"])

    session_token: str | None = None

    request_payload = {
        "ticket_cache_id": ticket_cache_id,
        "glpi_ticket_id": glpi_ticket_id,
        "operation": "refresh_ticket_cache",
    }

    try:
        session_token = _init_session(account["glpi_login"], glpi_password)

        raw_ticket = _get_glpi_ticket(
            session_token=session_token,
            ticket_id=glpi_ticket_id,
        )

        cache = _cache_ticket(
            db,
            account_id=account_id,
            glpi_instance_id=glpi_instance_id,
            ticket_id=glpi_ticket_id,
            raw_ticket=raw_ticket,
        )

        _log_glpi_operation(
            db,
            account_id=account_id,
            glpi_instance_id=glpi_instance_id,
            glpi_ticket_cache_id=int(cache["id"]),
            operation_type="refresh_ticket_cache",
            requested_by_user_id=user_id,
            request_payload=request_payload,
            response_status_code=200,
            response_json=raw_ticket,
            success=True,
        )

        db.commit()

        row = db.execute(
            text("""
                SELECT
                    gtc.id,
                    gtc.account_id,
                    gtc.glpi_instance_id,
                    gtc.glpi_ticket_id,
                    gtc.title,
                    gtc.status,
                    gtc.priority,
                    gtc.urgency,
                    gtc.impact,
                    (
                        SELECT count(distinct gttl.id)::int
                        FROM gestor_tickets.glpi_ticket_thread_links gttl
                        WHERE gttl.glpi_ticket_cache_id = gtc.id
                          AND gttl.status = 'active'
                    ) AS thread_count,
                    (
                        SELECT count(distinct gtel.id)::int
                        FROM gestor_tickets.glpi_ticket_email_links gtel
                        WHERE gtel.glpi_ticket_cache_id = gtc.id
                          AND gtel.status = 'active'
                    ) AS email_count,
                    gtc.last_sync_at,
                    gtc.updated_at
                FROM gestor_tickets.glpi_ticket_cache gtc
                WHERE gtc.id = :ticket_cache_id
            """),
            {"ticket_cache_id": int(cache["id"])},
        ).mappings().first()

        if not row:
            raise ValueError("No se pudo recuperar el ticket actualizado.")

        return dict(row)

    except Exception as exc:
        db.rollback()

        try:
            _log_glpi_operation(
                db,
                account_id=account_id,
                glpi_instance_id=glpi_instance_id,
                glpi_ticket_cache_id=ticket_cache_id,
                operation_type="refresh_ticket_cache",
                requested_by_user_id=user_id,
                request_payload=request_payload,
                response_status_code=None,
                response_json={},
                success=False,
                error_message=str(exc),
            )
            db.commit()
        except Exception:
            db.rollback()

        raise

    finally:
        if session_token:
            _kill_session(session_token)
