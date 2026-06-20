import json
import mimetypes
import os
from typing import Optional

from fastapi import APIRouter, Depends, Form, Request
from fastapi.responses import FileResponse, HTMLResponse, RedirectResponse, Response
from fastapi.templating import Jinja2Templates
from sqlalchemy.orm import Session
from sqlalchemy import text

from app.core.config import settings
from app.core.db import get_db
from app.core.versioning import get_version_metadata
from app.services.ai_model_discovery_service import discover_models, validate_model
from app.services.ai_settings_service import (
    PROVIDER_PRESETS,
    clone_endpoint,
    create_endpoint,
    get_endpoint,
    list_endpoints,
    list_models,
    list_validation_logs,
    move_endpoint,
    set_default_endpoint,
    set_endpoint_active,
    update_endpoint,
)
from app.services.collaborator_service import (
    create_local_collaborator,
    get_user_permissions,
    list_account_users,
    set_local_collaborator_status,
    update_local_collaborator,
)
from app.services.email_archive_service import (
    archive_message_from_imap_readonly,
    find_archived_message_for_occurrence,
)
from app.services.mailbox_preview_service import SAFETY_NOTES, preview_unified_collaborative_mailbox
from app.services.message_detail_service import MESSAGE_DETAIL_SAFETY_NOTES, fetch_message_detail_readonly
from app.services.glpi_ticket_service import (
    add_glpi_followup_to_ticket,
    attach_email_eml_to_glpi_ticket,
    create_glpi_ticket_from_thread,
    get_glpi_ticket_detail,
    list_glpi_ticket_cache,
    list_glpi_tickets_for_thread,
    refresh_glpi_ticket_cache,
)
from app.services.session_auth_service import authenticate_session_user
from app.services.mail_ingestion_scheduler import get_mail_ingestion_scheduler_state
from app.services.mail_ingestion_service import (
    configure_mail_ingestion_job,
    list_mail_ingestion_jobs,
    reactivate_mail_ingestion_job,
    run_mail_ingestion_job,
)
from app.services.thread_service import (
    copy_email_to_thread,
    create_thread_from_email,
    fork_email_to_new_thread,
    get_active_thread_for_email,
    get_thread_detail,
    list_active_threads_for_email,
    list_system_threads,
    merge_thread_into,
)
from app.services.email_ai_processing_service import get_email_ai_result, process_email
from app.services.thread_ai_synthesis_service import get_thread_ai_synthesis, synthesize_thread
from app.services.ai_prompt_service import (
    activate_version,
    create_version,
    get_template_with_versions,
    list_templates,
)
from app.services.ai_call_history_service import get_call_detail, list_call_history
from app.services.personal_account_service import (
    create_personal_account,
    detect_thread_siblings,
    list_personal_accounts,
    preview_personal_mailbox,
    transfer_personal_email,
)
from app.services.account_settings_service import (
    get_account_settings,
    update_account_glpi,
    update_account_imap,
    update_account_info,
)

router = APIRouter()
templates = Jinja2Templates(directory="/app/templates")


SECTION_DEFINITIONS = {
    "tickets": {
        "title": "Tickets GLPI",
        "icon": "🎫",
        "description": "Aquí se relacionarán correos e hilos con tickets de GLPI.",
        "next_steps": [
            "Consultar tickets GLPI desde la API.",
            "Crear tickets desde correos seleccionados.",
            "Relacionar múltiples correos e hilos con múltiples tickets.",
        ],
    },
    "accounts": {
        "title": "Cuentas",
        "icon": "👥",
        "description": "Aquí se gestionarán la cuenta colaborativa y sus colaboradores.",
        "next_steps": [
            "Mostrar la cuenta colaborativa activa.",
            "Crear usuarios colaboradores locales.",
            "Gestionar permisos por colaborador.",
        ],
    },
    "settings": {
        "title": "Configuración",
        "icon": "⚙️",
        "description": "Aquí se configurarán parámetros de correo, GLPI e IA.",
        "next_steps": [
            "Configurar acceso IMAP de la cuenta colaborativa.",
            "Configurar prompts de IA.",
            "Validar endpoints externos antes de guardar cambios.",
        ],
    },
}


def _template_context(request: Request, **extra):
    session_user = request.session.get("user") or {}
    context = {
        "request": request,
        "app_name": settings.APP_NAME,
        "app_env": settings.APP_ENV,
        "version": get_version_metadata(),
        "htmx_local": True,
        "assistant_mode": bool(session_user.get("assistant_mode", True)),
    }
    context.update(extra)
    return context


def get_session_user(request: Request) -> dict | None:
    user = request.session.get("user")
    return user if isinstance(user, dict) else None


def require_session_user(request: Request) -> dict | RedirectResponse:
    user = get_session_user(request)
    if not user:
        return RedirectResponse(url="/login", status_code=303)
    return user


def _ensure_session_permissions(user: dict, db: Session) -> dict:
    permission_keys = {
        "can_manage_users",
        "can_manage_account_config",
        "can_read_account_mail",
        "can_reply_from_account",
        "can_create_glpi_ticket",
        "can_update_glpi_ticket",
        "can_link_tickets",
        "can_manage_ai",
    }
    if permission_keys.issubset(user.keys()):
        return user

    permissions = get_user_permissions(
        db,
        user_id=int(user["user_id"]),
        account_id=int(user["account_id"]),
    )
    user.update(permissions)
    return user


def _require_permission(user: dict, permission: str):
    if not user.get(permission):
        return RedirectResponse(url="/app", status_code=303)
    return None


@router.get("/login", response_class=HTMLResponse)
def login_form(request: Request):
    if get_session_user(request):
        return RedirectResponse(url="/app", status_code=303)

    return templates.TemplateResponse(
        request=request,
        name="login.html",
        context=_template_context(
            request,
            error=None,
            login_identifier="sistemas-tic@gestor-tickets.es",
        ),
    )


@router.post("/login", response_class=HTMLResponse)
async def login_submit(
    request: Request,
    login_identifier: str = Form(...),
    password: str = Form(...),
    db: Session = Depends(get_db),
):
    try:
        user = await authenticate_session_user(
            db,
            login_identifier=login_identifier,
            password=password,
            ip_address=request.client.host if request.client else None,
            user_agent=request.headers.get("user-agent"),
        )

        request.session["user"] = {
            "account_id": user.account_id,
            "user_id": user.user_id,
            "account_email": user.account_email,
            "login_identifier": user.login_identifier,
            "display_name": user.display_name,
            "role": user.role,
            "auth_mode": user.auth_mode,
            "can_manage_users": user.can_manage_users,
            "can_manage_account_config": user.can_manage_account_config,
            "can_read_account_mail": user.can_read_account_mail,
            "can_reply_from_account": user.can_reply_from_account,
            "can_create_glpi_ticket": user.can_create_glpi_ticket,
            "can_update_glpi_ticket": user.can_update_glpi_ticket,
            "can_link_tickets": user.can_link_tickets,
            "can_manage_ai": user.can_manage_ai,
            "assistant_mode": user.assistant_mode,
        }

        return RedirectResponse(url="/app", status_code=303)

    except ValueError as exc:
        return templates.TemplateResponse(
            request=request,
            name="login.html",
            context=_template_context(
                request,
                error=str(exc),
                login_identifier=login_identifier,
            ),
            status_code=400,
        )


@router.post("/logout")
def logout_submit(request: Request):
    request.session.clear()
    return RedirectResponse(url="/login", status_code=303)


@router.get("/logout")
def logout_get(request: Request):
    request.session.clear()
    return RedirectResponse(url="/login", status_code=303)


@router.get("/app", response_class=HTMLResponse)
def app_home(request: Request):
    user = require_session_user(request)
    if isinstance(user, RedirectResponse):
        return user

    return templates.TemplateResponse(
        request=request,
        name="app_home.html",
        context=_template_context(request, user=user, active_section="panel"),
    )


@router.get("/mailbox", response_class=HTMLResponse)
def mailbox_page(
    request: Request,
    db: Session = Depends(get_db),
):
    user = require_session_user(request)
    if isinstance(user, RedirectResponse):
        return user
    user = _ensure_session_permissions(user, db)
    denied = _require_permission(user, "can_read_account_mail")
    if denied:
        return denied

    try:
        preview = preview_unified_collaborative_mailbox(
            db,
            account_id=int(user["account_id"]),
            mailboxes=["INBOX", "INBOX.Sent"],
            limit_per_mailbox=20,
            total_limit=50,
        )
        error = None
    except ValueError as exc:
        preview = None
        error = str(exc)

    if error:
        return templates.TemplateResponse(
            request=request,
            name="section_page.html",
            context=_template_context(
                request,
                user=user,
                active_section="mailbox",
                section_key="mailbox",
                section={
                    "title": "Bandeja",
                    "icon": "📥",
                    "description": error,
                    "next_steps": [
                        "Revisar la configuración IMAP de la cuenta.",
                        "Validar host, puerto, usuario y contraseña.",
                        "Mantener siempre lectura en modo readonly.",
                    ],
                },
            ),
            status_code=400,
        )

    # Módulo 7: cruce de inteligencia IMAP vs base de datos colaborativa
    imap_intelligence: dict[str, str] = {}
    if preview and preview.messages:
        msg_ids = [m.message_id for m in preview.messages if m.message_id]
        if msg_ids:
            rows = db.execute(
                text("""
                    SELECT message_id_header, 'exact' AS match_type
                    FROM gestor_tickets.email_messages
                    WHERE account_id = :account_id
                      AND message_id_header = ANY(:ids)
                """),
                {"account_id": int(user["account_id"]), "ids": msg_ids},
            ).mappings().all()
            for row in rows:
                imap_intelligence[row["message_id_header"]] = row["match_type"]

    return templates.TemplateResponse(
        request=request,
        name="mailbox.html",
        context=_template_context(
            request,
            user=user,
            active_section="mailbox",
            preview=preview,
            safety_notes=SAFETY_NOTES,
            imap_intelligence=imap_intelligence,
        ),
    )


@router.get("/mailbox/message", response_class=HTMLResponse)
def mailbox_message_page(
    request: Request,
    mailbox: str,
    uid: str,
    db: Session = Depends(get_db),
):
    user = require_session_user(request)
    if isinstance(user, RedirectResponse):
        return user
    user = _ensure_session_permissions(user, db)
    denied = _require_permission(user, "can_read_account_mail")
    if denied:
        return denied

    try:
        detail = fetch_message_detail_readonly(
            db,
            account_id=int(user["account_id"]),
            mailbox=mailbox,
            uid=uid,
        )
        archived = find_archived_message_for_occurrence(
            db,
            account_id=int(user["account_id"]),
            mailbox=mailbox,
            uid=uid,
        )
        thread = None
        ai_email_result = None
        if archived:
            thread = get_active_thread_for_email(
                db,
                email_message_id=int(archived["email_message_id"]),
            )
            ai_email_result = get_email_ai_result(db, int(archived["email_message_id"]))
        error = None
    except ValueError as exc:
        detail = None
        archived = None
        thread = None
        ai_email_result = None
        error = str(exc)

    if error:
        return templates.TemplateResponse(
            request=request,
            name="section_page.html",
            context=_template_context(
                request,
                user=user,
                active_section="mailbox",
                section_key="mailbox",
                section={
                    "title": "Bandeja",
                    "icon": "📥",
                    "description": error,
                    "next_steps": [
                        "Volver a la bandeja y seleccionar otro mensaje.",
                        "Comprobar que el UID sigue existiendo en el buzón.",
                        "Mantener siempre lectura en modo readonly.",
                    ],
                },
            ),
            status_code=400,
        )

    return templates.TemplateResponse(
        request=request,
        name="message_detail.html",
        context=_template_context(
            request,
            user=user,
            active_section="mailbox",
            message=detail,
            archived=archived,
            thread=thread,
            ai_email_result=ai_email_result,
            safety_notes=MESSAGE_DETAIL_SAFETY_NOTES,
        ),
    )


@router.post("/mailbox/message/archive", response_class=HTMLResponse)
def mailbox_message_archive_web(
    request: Request,
    mailbox: str,
    uid: str,
    db: Session = Depends(get_db),
):
    user = require_session_user(request)
    if isinstance(user, RedirectResponse):
        return user
    user = _ensure_session_permissions(user, db)
    denied = _require_permission(user, "can_link_tickets")
    if denied:
        return denied

    try:
        archive_message_from_imap_readonly(
            db,
            account_id=int(user["account_id"]),
            mailbox=mailbox,
            uid=uid,
        )
    except ValueError:
        return RedirectResponse(
            url=f"/mailbox/message?mailbox={mailbox}&uid={uid}",
            status_code=303,
        )

    return RedirectResponse(
        url=f"/mailbox/message?mailbox={mailbox}&uid={uid}&archived=1",
        status_code=303,
    )


@router.post("/mailbox/message/create-thread", response_class=HTMLResponse)
def mailbox_message_create_thread_web(
    request: Request,
    mailbox: str,
    uid: str,
    email_message_id: int,
    db: Session = Depends(get_db),
):
    user = require_session_user(request)
    if isinstance(user, RedirectResponse):
        return user
    user = _ensure_session_permissions(user, db)
    denied = _require_permission(user, "can_link_tickets")
    if denied:
        return denied

    try:
        create_thread_from_email(
            db,
            account_id=int(user["account_id"]),
            email_message_id=email_message_id,
            created_by_user_id=int(user["user_id"]),
            reason="Creación manual desde detalle de correo.",
        )
    except ValueError:
        return RedirectResponse(
            url=f"/mailbox/message?mailbox={mailbox}&uid={uid}",
            status_code=303,
        )

    return RedirectResponse(url="/threads", status_code=303)


@router.get("/inbox", response_class=HTMLResponse)
def inbox_page(
    request: Request,
    thread_id: int | None = None,
    page: int = 1,
    db: Session = Depends(get_db),
):
    user = require_session_user(request)
    if isinstance(user, RedirectResponse):
        return user
    user = _ensure_session_permissions(user, db)
    denied = _require_permission(user, "can_read_account_mail")
    if denied:
        return denied

    page_size = 25
    offset = (page - 1) * page_size
    account_id = int(user["account_id"])

    threads = list_system_threads(db, account_id=account_id)
    total_threads = len(threads)
    threads_page = threads[offset:offset + page_size]
    has_more = (offset + page_size) < total_threads

    selected_thread = None
    thread_messages = []
    thread_attachments = []
    glpi_tickets = []
    ai_thread_result = None

    if thread_id:
        try:
            selected_thread, thread_messages = get_thread_detail(
                db, account_id=account_id, thread_id=thread_id,
            )
            glpi_tickets = list_glpi_tickets_for_thread(
                db, account_id=account_id, thread_id=thread_id,
            )
            ai_thread_result = get_thread_ai_synthesis(db, thread_id)
            thread_attachments = _get_thread_attachments(db, account_id=account_id, thread_id=thread_id)
        except ValueError:
            pass

    return templates.TemplateResponse(
        request=request,
        name="inbox.html",
        context=_template_context(
            request,
            user=user,
            active_section="inbox",
            threads=threads_page,
            total_threads=total_threads,
            page=page,
            page_size=page_size,
            has_more=has_more,
            selected_thread=selected_thread,
            thread_messages=thread_messages,
            thread_attachments=thread_attachments,
            glpi_tickets=glpi_tickets,
            ai_thread_result=ai_thread_result,
            thread_id=thread_id,
        ),
    )


@router.get("/inbox/threads", response_class=HTMLResponse)
def inbox_threads_partial(
    request: Request,
    page: int = 1,
    db: Session = Depends(get_db),
):
    """Partial HTMX: carga más hilos para el scroll infinito."""
    user = require_session_user(request)
    if isinstance(user, RedirectResponse):
        return user
    user = _ensure_session_permissions(user, db)
    denied = _require_permission(user, "can_read_account_mail")
    if denied:
        return denied

    page_size = 25
    offset = (page - 1) * page_size
    account_id = int(user["account_id"])

    threads = list_system_threads(db, account_id=account_id)
    total_threads = len(threads)
    threads_page = threads[offset:offset + page_size]
    has_more = (offset + page_size) < total_threads

    return templates.TemplateResponse(
        request=request,
        name="partials/inbox_thread_rows.html",
        context=_template_context(
            request,
            threads=threads_page,
            page=page,
            page_size=page_size,
            has_more=has_more,
        ),
    )


@router.get("/inbox/thread/{thread_id}", response_class=HTMLResponse)
def inbox_thread_panel(
    request: Request,
    thread_id: int,
    db: Session = Depends(get_db),
):
    """Partial HTMX: carga el panel derecho del hilo seleccionado."""
    user = require_session_user(request)
    if isinstance(user, RedirectResponse):
        return user
    user = _ensure_session_permissions(user, db)
    denied = _require_permission(user, "can_read_account_mail")
    if denied:
        return denied

    account_id = int(user["account_id"])

    try:
        thread, messages = get_thread_detail(db, account_id=account_id, thread_id=thread_id)
        glpi_tickets = list_glpi_tickets_for_thread(db, account_id=account_id, thread_id=thread_id)
        ai_thread_result = get_thread_ai_synthesis(db, thread_id)
        thread_attachments = _get_thread_attachments(db, account_id=account_id, thread_id=thread_id)
        all_threads = list_system_threads(db, account_id=account_id)
    except ValueError:
        return HTMLResponse("<p class='pane-empty-text'>Hilo no encontrado.</p>")

    return templates.TemplateResponse(
        request=request,
        name="partials/inbox_thread_panel.html",
        context=_template_context(
            request,
            user=user,
            thread=thread,
            messages=messages,
            thread_attachments=thread_attachments,
            glpi_tickets=glpi_tickets,
            ai_thread_result=ai_thread_result,
            threads=all_threads,
            all_threads=all_threads,
            include_email_sidebar_oob=True,
        ),
    )


def _get_thread_attachments(db: Session, *, account_id: int, thread_id: int) -> list[dict]:
    rows = db.execute(
        text("""
            SELECT DISTINCT
                ea.id,
                ea.email_message_id,
                ea.filename,
                ea.content_type,
                ea.size_bytes,
                ea.is_inline,
                ea.content_id,
                em.subject AS email_subject,
                em.sent_at
            FROM gestor_tickets.email_thread_members etm
            JOIN gestor_tickets.email_messages em ON em.id = etm.email_message_id
            JOIN gestor_tickets.email_attachments ea ON ea.email_message_id = em.id
            JOIN gestor_tickets.system_threads st ON st.id = etm.thread_id
            WHERE etm.thread_id = :thread_id
              AND st.account_id = :account_id
              AND etm.status = 'active'
              AND ea.is_inline = false
            ORDER BY em.sent_at, ea.filename
        """),
        {"thread_id": thread_id, "account_id": account_id},
    ).mappings().all()
    return [dict(r) for r in rows]


@router.get("/threads", response_class=HTMLResponse)
def threads_page(
    request: Request,
    db: Session = Depends(get_db),
):
    user = require_session_user(request)
    if isinstance(user, RedirectResponse):
        return user
    user = _ensure_session_permissions(user, db)
    denied = _require_permission(user, "can_read_account_mail")
    if denied:
        return denied

    threads = list_system_threads(db, account_id=int(user["account_id"]))

    return templates.TemplateResponse(
        request=request,
        name="threads.html",
        context=_template_context(
            request,
            user=user,
            active_section="threads",
            threads=threads,
        ),
    )



@router.get("/threads/{thread_id}", response_class=HTMLResponse)
def thread_detail_page(
    request: Request,
    thread_id: int,
    db: Session = Depends(get_db),
):
    user = require_session_user(request)
    if isinstance(user, RedirectResponse):
        return user
    user = _ensure_session_permissions(user, db)
    denied = _require_permission(user, "can_read_account_mail")
    if denied:
        return denied

    try:
        thread, messages = get_thread_detail(
            db,
            account_id=int(user["account_id"]),
            thread_id=thread_id,
        )
        glpi_tickets = list_glpi_tickets_for_thread(
            db,
            account_id=int(user["account_id"]),
            thread_id=thread_id,
        )
        ai_thread_result = get_thread_ai_synthesis(db, thread_id)
    except ValueError:
        return RedirectResponse(url="/threads", status_code=303)

    return templates.TemplateResponse(
        request=request,
        name="thread_detail.html",
        context=_template_context(
            request,
            user=user,
            active_section="threads",
            thread=thread,
            messages=messages,
            glpi_tickets=glpi_tickets,
            ai_thread_result=ai_thread_result,
        ),
    )



@router.post("/threads/{thread_id}/glpi/create-ticket", response_class=HTMLResponse)
def thread_create_glpi_ticket_web(
    request: Request,
    thread_id: int,
    glpi_password: str = Form(...),
    title: str | None = Form(None),
    db: Session = Depends(get_db),
):
    user = require_session_user(request)
    if isinstance(user, RedirectResponse):
        return user
    user = _ensure_session_permissions(user, db)
    denied = _require_permission(user, "can_create_glpi_ticket")
    if denied:
        return denied

    try:
        create_glpi_ticket_from_thread(
            db,
            account_id=int(user["account_id"]),
            thread_id=thread_id,
            user_id=int(user["user_id"]),
            glpi_password=glpi_password,
            title_override=title,
        )
    except ValueError:
        return RedirectResponse(url=f"/threads/{thread_id}", status_code=303)

    return RedirectResponse(url=f"/threads/{thread_id}", status_code=303)


@router.post("/mailbox/message/process-ai", response_class=HTMLResponse)
def mailbox_message_process_ai(
    request: Request,
    email_message_id: int,
    db: Session = Depends(get_db),
):
    user = require_session_user(request)
    if isinstance(user, RedirectResponse):
        return user
    user = _ensure_session_permissions(user, db)

    outcome = process_email(
        db,
        email_message_id=email_message_id,
        account_id=int(user["account_id"]),
        user_id=int(user["user_id"]),
    )
    context = _template_context(request, **outcome)
    return templates.TemplateResponse(
        request=request,
        name="partials/ai_email_result.html",
        context=context,
    )


@router.post("/threads/{thread_id}/synthesize-ai", response_class=HTMLResponse)
def thread_synthesize_ai(
    request: Request,
    thread_id: int,
    db: Session = Depends(get_db),
):
    user = require_session_user(request)
    if isinstance(user, RedirectResponse):
        return user
    user = _ensure_session_permissions(user, db)

    outcome = synthesize_thread(
        db,
        thread_id=thread_id,
        account_id=int(user["account_id"]),
        user_id=int(user["user_id"]),
    )
    context = _template_context(request, **outcome)
    return templates.TemplateResponse(
        request=request,
        name="partials/ai_thread_result.html",
        context=context,
    )


@router.get("/tickets", response_class=HTMLResponse)
def tickets_page(
    request: Request,
    q: str | None = None,
    status: str | None = None,
    db: Session = Depends(get_db),
):
    user = require_session_user(request)
    if isinstance(user, RedirectResponse):
        return user
    user = _ensure_session_permissions(user, db)
    denied = _require_permission(user, "can_read_account_mail")
    if denied:
        return denied

    all_tickets = list_glpi_ticket_cache(db, account_id=int(user["account_id"]))

    # Estadísticas por estado (sobre el total sin filtrar)
    stats: dict[int, int] = {}
    for t in all_tickets:
        st = int(t["status"]) if t.get("status") else 0
        stats[st] = stats.get(st, 0) + 1

    # Aplicar filtros en Python (la lista ya está en memoria)
    filtered = all_tickets
    if status:
        filtered = [t for t in filtered if str(t.get("status") or "") == status]
    if q:
        q_lower = q.lower()
        filtered = [t for t in filtered if q_lower in (t.get("title") or "").lower()]

    return templates.TemplateResponse(
        request=request,
        name="tickets.html",
        context=_template_context(
            request,
            user=user,
            active_section="tickets",
            tickets=filtered,
            tickets_total=len(all_tickets),
            tickets_stats=stats,
            q=q or "",
            status_filter=status or "",
        ),
    )


@router.get("/tickets/{ticket_cache_id}", response_class=HTMLResponse)
def ticket_detail_page(
    request: Request,
    ticket_cache_id: int,
    db: Session = Depends(get_db),
):
    user = require_session_user(request)
    if isinstance(user, RedirectResponse):
        return user
    user = _ensure_session_permissions(user, db)
    denied = _require_permission(user, "can_read_account_mail")
    if denied:
        return denied

    try:
        ticket, threads, emails, operations = get_glpi_ticket_detail(
            db,
            account_id=int(user["account_id"]),
            ticket_cache_id=ticket_cache_id,
        )
    except ValueError:
        return RedirectResponse(url="/tickets", status_code=303)

    return templates.TemplateResponse(
        request=request,
        name="ticket_detail.html",
        context=_template_context(
            request,
            user=user,
            active_section="tickets",
            ticket=ticket,
            threads=threads,
            emails=emails,
            operations=operations,
        ),
    )



@router.post("/tickets/{ticket_cache_id}/refresh", response_class=HTMLResponse)
def ticket_refresh_web(
    request: Request,
    ticket_cache_id: int,
    glpi_password: str = Form(...),
    db: Session = Depends(get_db),
):
    user = require_session_user(request)
    if isinstance(user, RedirectResponse):
        return user
    user = _ensure_session_permissions(user, db)
    denied = _require_permission(user, "can_update_glpi_ticket")
    if denied:
        return denied

    try:
        refresh_glpi_ticket_cache(
            db,
            account_id=int(user["account_id"]),
            ticket_cache_id=ticket_cache_id,
            user_id=int(user["user_id"]),
            glpi_password=glpi_password,
        )
    except ValueError:
        return RedirectResponse(url=f"/tickets/{ticket_cache_id}", status_code=303)

    return RedirectResponse(url=f"/tickets/{ticket_cache_id}", status_code=303)



@router.post("/tickets/{ticket_cache_id}/followup", response_class=HTMLResponse)
def ticket_followup_web(
    request: Request,
    ticket_cache_id: int,
    glpi_password: str = Form(...),
    content: str = Form(...),
    is_private: str | None = Form(None),
    db: Session = Depends(get_db),
):
    user = require_session_user(request)
    if isinstance(user, RedirectResponse):
        return user
    user = _ensure_session_permissions(user, db)
    denied = _require_permission(user, "can_update_glpi_ticket")
    if denied:
        return denied

    try:
        add_glpi_followup_to_ticket(
            db,
            account_id=int(user["account_id"]),
            ticket_cache_id=ticket_cache_id,
            user_id=int(user["user_id"]),
            glpi_password=glpi_password,
            content=content,
            is_private=bool(is_private),
        )
    except ValueError:
        return RedirectResponse(url=f"/tickets/{ticket_cache_id}", status_code=303)

    return RedirectResponse(url=f"/tickets/{ticket_cache_id}", status_code=303)



@router.post("/tickets/{ticket_cache_id}/attach-email/{email_message_id}", response_class=HTMLResponse)
def ticket_attach_email_web(
    request: Request,
    ticket_cache_id: int,
    email_message_id: int,
    glpi_password: str = Form(...),
    db: Session = Depends(get_db),
):
    user = require_session_user(request)
    if isinstance(user, RedirectResponse):
        return user
    user = _ensure_session_permissions(user, db)
    denied = _require_permission(user, "can_update_glpi_ticket")
    if denied:
        return denied

    try:
        attach_email_eml_to_glpi_ticket(
            db,
            account_id=int(user["account_id"]),
            ticket_cache_id=ticket_cache_id,
            email_message_id=email_message_id,
            user_id=int(user["user_id"]),
            glpi_password=glpi_password,
        )
    except ValueError:
        return RedirectResponse(url=f"/tickets/{ticket_cache_id}", status_code=303)

    return RedirectResponse(url=f"/tickets/{ticket_cache_id}", status_code=303)




def _pretty_json(value) -> str:
    return json.dumps(value or {}, ensure_ascii=False, indent=2, default=str)


def _get_ingestion_run_for_account(db: Session, *, account_id: int, run_id: int) -> dict | None:
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
            WHERE account_id = :account_id
              AND id = :run_id
            LIMIT 1
        """),
        {
            "account_id": account_id,
            "run_id": run_id,
        },
    ).mappings().first()

    if not row:
        return None

    item = dict(row)
    item["details_json"] = item.get("details_json") or {}
    item["details_json_pretty"] = _pretty_json(item["details_json"])
    return item


def _get_ingestion_runs_for_account(db: Session, *, account_id: int) -> list[dict]:
    rows = db.execute(
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
            WHERE account_id = :account_id
            ORDER BY id DESC
            LIMIT 20
        """),
        {"account_id": account_id},
    ).mappings().all()

    return [dict(row) for row in rows]


@router.get("/ingestion", response_class=HTMLResponse)
def ingestion_page(
    request: Request,
    db: Session = Depends(get_db),
):
    user = require_session_user(request)
    if isinstance(user, RedirectResponse):
        return user
    user = _ensure_session_permissions(user, db)
    denied = _require_permission(user, "can_manage_account_config")
    if denied:
        return denied

    account_id = int(user["account_id"])
    jobs = list_mail_ingestion_jobs(db, account_id=account_id)
    job = jobs[0] if jobs else None
    runs = _get_ingestion_runs_for_account(db, account_id=account_id)
    scheduler = get_mail_ingestion_scheduler_state()

    return templates.TemplateResponse(
        request,
        "ingestion.html",
        {
            "user": user,
            "version": get_version_metadata(),
            "scheduler": scheduler,
            "job": job,
            "runs": runs,
        },
    )


@router.get("/ingestion/runs/{run_id}", response_class=HTMLResponse)
def ingestion_run_detail_page(
    request: Request,
    run_id: int,
    db: Session = Depends(get_db),
):
    user = require_session_user(request)
    if isinstance(user, RedirectResponse):
        return user
    user = _ensure_session_permissions(user, db)
    denied = _require_permission(user, "can_manage_account_config")
    if denied:
        return denied

    account_id = int(user["account_id"])
    run = _get_ingestion_run_for_account(db, account_id=account_id, run_id=run_id)
    if not run:
        return RedirectResponse(url="/ingestion", status_code=303)

    details = run["details_json"]
    safety = details.get("safety") if isinstance(details, dict) else {}
    if not isinstance(safety, dict):
        safety = {}

    return templates.TemplateResponse(
        request,
        "ingestion_run_detail.html",
        {
            "user": user,
            "version": get_version_metadata(),
            "run": run,
            "details": details,
            "mailboxes": details.get("mailboxes", []) if isinstance(details, dict) else [],
            "imported": details.get("imported", []) if isinstance(details, dict) else [],
            "duplicates": details.get("duplicates", []) if isinstance(details, dict) else [],
            "errors": details.get("errors", []) if isinstance(details, dict) else [],
            "safety": safety,
        },
    )


@router.post("/ingestion/configure", response_class=HTMLResponse)
def ingestion_configure_web(
    request: Request,
    status: str = Form("active"),
    scan_inbox: str | None = Form(None),
    scan_sent: str | None = Form(None),
    inbox_folder_name: str = Form("INBOX"),
    sent_folder_name: str = Form("INBOX.Sent"),
    interval_minutes: int = Form(5),
    max_messages_per_folder: int = Form(50),
    db: Session = Depends(get_db),
):
    user = require_session_user(request)
    if isinstance(user, RedirectResponse):
        return user
    user = _ensure_session_permissions(user, db)
    denied = _require_permission(user, "can_manage_account_config")
    if denied:
        return denied

    configure_mail_ingestion_job(
        db,
        account_id=int(user["account_id"]),
        user_id=int(user["user_id"]),
        status=status,
        scan_inbox=bool(scan_inbox),
        scan_sent=bool(scan_sent),
        inbox_folder_name=inbox_folder_name,
        sent_folder_name=sent_folder_name,
        interval_minutes=interval_minutes,
        max_messages_per_folder=max_messages_per_folder,
    )

    return RedirectResponse(url="/ingestion", status_code=303)


@router.post("/ingestion/reactivate", response_class=HTMLResponse)
def ingestion_reactivate_web(
    request: Request,
    db: Session = Depends(get_db),
):
    user = require_session_user(request)
    if isinstance(user, RedirectResponse):
        return user
    user = _ensure_session_permissions(user, db)
    denied = _require_permission(user, "can_manage_account_config")
    if denied:
        return denied

    reactivate_mail_ingestion_job(
        db,
        account_id=int(user["account_id"]),
        user_id=int(user["user_id"]),
    )

    return RedirectResponse(url="/ingestion", status_code=303)


@router.post("/ingestion/run-now", response_class=HTMLResponse)
def ingestion_run_now_web(
    request: Request,
    db: Session = Depends(get_db),
):
    user = require_session_user(request)
    if isinstance(user, RedirectResponse):
        return user
    user = _ensure_session_permissions(user, db)
    denied = _require_permission(user, "can_manage_account_config")
    if denied:
        return denied

    account_id = int(user["account_id"])
    jobs = list_mail_ingestion_jobs(db, account_id=account_id)

    if jobs:
        try:
            run_mail_ingestion_job(
                db,
                job_id=int(jobs[0]["id"]),
                user_id=int(user["user_id"]),
            )
        except Exception:
            # La ejecución ya queda registrada en mail_ingestion_runs y en el estado del job.
            pass

    return RedirectResponse(url="/ingestion", status_code=303)


def _require_manage_ai(user: dict):
    if not user.get("can_manage_ai"):
        return RedirectResponse(url="/app", status_code=303)
    return None


def _parse_json_field(value: str | None, default: dict) -> dict:
    value = (value or "").strip()
    if not value:
        return default
    parsed = json.loads(value)
    if not isinstance(parsed, dict):
        raise ValueError("El campo JSON debe ser un objeto.")
    return parsed


def _ai_form_payload(
    *,
    name: str,
    provider_kind: str,
    base_url: str,
    models_endpoint_path: str,
    chat_endpoint_path: str,
    api_key: str | None,
    default_model: str | None,
    manual_model: str | None,
    is_active: str | None,
    is_default: str | None,
    timeout_seconds: int,
    temperature: float,
    top_p: float,
    max_tokens: int,
    enable_thinking: str | None,
    reasoning_effort: str | None,
    daily_limit: int | None,
    free_quota_notes: str | None,
    retry_policy_json: str | None,
    extra_headers_json: str | None,
    keep_existing_api_key: bool = True,
) -> dict:
    selected_model = (manual_model or "").strip() or (default_model or "").strip() or None
    return {
        "name": name,
        "provider_kind": provider_kind,
        "base_url": base_url,
        "models_endpoint_path": models_endpoint_path,
        "chat_endpoint_path": chat_endpoint_path,
        "api_key": api_key.strip() if api_key and api_key.strip() else None,
        "keep_existing_api_key": keep_existing_api_key,
        "default_model": selected_model,
        "is_active": bool(is_active),
        "is_default": bool(is_default),
        "timeout_seconds": timeout_seconds,
        "temperature": temperature,
        "top_p": top_p,
        "max_tokens": max_tokens,
        "enable_thinking": bool(enable_thinking),
        "reasoning_effort": (reasoning_effort or "none").strip().lower(),
        "daily_limit": daily_limit,
        "free_quota_notes": free_quota_notes,
        "retry_policy_json": _parse_json_field(retry_policy_json, {
            "max_retries": 1,
            "retry_on": ["timeout", "connection_error", "rate_limited"],
            "do_not_retry_on": ["auth_error", "quota_exceeded", "model_not_found", "invalid_request"],
        }),
        "extra_headers_json": _parse_json_field(extra_headers_json, {}),
    }


@router.get("/settings/ai", response_class=HTMLResponse)
def ai_settings_page(request: Request, db: Session = Depends(get_db)):
    user = require_session_user(request)
    if isinstance(user, RedirectResponse):
        return user

    user = _ensure_session_permissions(user, db)
    denied = _require_manage_ai(user)
    if denied:
        return denied

    endpoints = list_endpoints(db)
    selected_endpoint_id = request.query_params.get("endpoint_id")
    selected_endpoint = None
    models = []
    validation_logs = []
    if selected_endpoint_id:
        try:
            selected_endpoint = get_endpoint(db, int(selected_endpoint_id))
            models = list_models(db, int(selected_endpoint_id))
            validation_logs = list_validation_logs(db, int(selected_endpoint_id))
        except ValueError:
            selected_endpoint = None

    force_new = request.query_params.get("new") == "1"
    if selected_endpoint is None and endpoints and not force_new:
        selected_endpoint = endpoints[0]
        models = list_models(db, int(selected_endpoint["id"]))
        validation_logs = list_validation_logs(db, int(selected_endpoint["id"]))

    return templates.TemplateResponse(
        request=request,
        name="ai_settings.html",
        context=_template_context(
            request,
            user=user,
            active_section="ai_settings",
            endpoints=endpoints,
            selected_endpoint=selected_endpoint,
            models=models,
            validation_logs=validation_logs,
            provider_presets=PROVIDER_PRESETS,
            error=request.query_params.get("error"),
            message=request.query_params.get("message"),
        ),
    )


@router.post("/settings/ai/endpoints", response_class=HTMLResponse)
def ai_create_endpoint_web(
    request: Request,
    name: str = Form(...),
    provider_kind: str = Form("generic"),
    base_url: str = Form(...),
    models_endpoint_path: str = Form("/models"),
    chat_endpoint_path: str = Form("/chat/completions"),
    api_key: str | None = Form(None),
    default_model: str | None = Form(None),
    manual_model: str | None = Form(None),
    is_active: str | None = Form(None),
    is_default: str | None = Form(None),
    timeout_seconds: int = Form(60),
    temperature: float = Form(0.2),
    top_p: float = Form(1.0),
    max_tokens: int = Form(1024),
    enable_thinking: str | None = Form(None),
    reasoning_effort: str | None = Form("none"),
    daily_limit: int | None = Form(None),
    free_quota_notes: str | None = Form(None),
    retry_policy_json: str | None = Form(None),
    extra_headers_json: str | None = Form(None),
    db: Session = Depends(get_db),
):
    user = require_session_user(request)
    if isinstance(user, RedirectResponse):
        return user
    user = _ensure_session_permissions(user, db)
    denied = _require_manage_ai(user)
    if denied:
        return denied

    try:
        endpoint = create_endpoint(
            db,
            _ai_form_payload(
                name=name,
                provider_kind=provider_kind,
                base_url=base_url,
                models_endpoint_path=models_endpoint_path,
                chat_endpoint_path=chat_endpoint_path,
                api_key=api_key,
                default_model=default_model,
                manual_model=manual_model,
                is_active=is_active,
                is_default=is_default,
                timeout_seconds=timeout_seconds,
                temperature=temperature,
                top_p=top_p,
                max_tokens=max_tokens,
                enable_thinking=enable_thinking,
                reasoning_effort=reasoning_effort,
                daily_limit=daily_limit,
                free_quota_notes=free_quota_notes,
                retry_policy_json=retry_policy_json,
                extra_headers_json=extra_headers_json,
                keep_existing_api_key=False,
            ),
        )
        return RedirectResponse(url=f"/settings/ai?endpoint_id={endpoint['id']}&message=created", status_code=303)
    except ValueError:
        return RedirectResponse(url="/settings/ai?error=save_error", status_code=303)


@router.post("/settings/ai/endpoints/{endpoint_id}", response_class=HTMLResponse)
def ai_update_endpoint_web(
    request: Request,
    endpoint_id: int,
    name: str = Form(...),
    provider_kind: str = Form("generic"),
    base_url: str = Form(...),
    models_endpoint_path: str = Form("/models"),
    chat_endpoint_path: str = Form("/chat/completions"),
    api_key: str | None = Form(None),
    default_model: str | None = Form(None),
    manual_model: str | None = Form(None),
    is_active: str | None = Form(None),
    is_default: str | None = Form(None),
    timeout_seconds: int = Form(60),
    temperature: float = Form(0.2),
    top_p: float = Form(1.0),
    max_tokens: int = Form(1024),
    enable_thinking: str | None = Form(None),
    reasoning_effort: str | None = Form("none"),
    daily_limit: int | None = Form(None),
    free_quota_notes: str | None = Form(None),
    retry_policy_json: str | None = Form(None),
    extra_headers_json: str | None = Form(None),
    db: Session = Depends(get_db),
):
    user = require_session_user(request)
    if isinstance(user, RedirectResponse):
        return user
    user = _ensure_session_permissions(user, db)
    denied = _require_manage_ai(user)
    if denied:
        return denied

    try:
        update_endpoint(
            db,
            endpoint_id,
            _ai_form_payload(
                name=name,
                provider_kind=provider_kind,
                base_url=base_url,
                models_endpoint_path=models_endpoint_path,
                chat_endpoint_path=chat_endpoint_path,
                api_key=api_key,
                default_model=default_model,
                manual_model=manual_model,
                is_active=is_active,
                is_default=is_default,
                timeout_seconds=timeout_seconds,
                temperature=temperature,
                top_p=top_p,
                max_tokens=max_tokens,
                enable_thinking=enable_thinking,
                reasoning_effort=reasoning_effort,
                daily_limit=daily_limit,
                free_quota_notes=free_quota_notes,
                retry_policy_json=retry_policy_json,
                extra_headers_json=extra_headers_json,
            ),
        )
        return RedirectResponse(url=f"/settings/ai?endpoint_id={endpoint_id}&message=updated", status_code=303)
    except ValueError:
        return RedirectResponse(url=f"/settings/ai?endpoint_id={endpoint_id}&error=save_error", status_code=303)


@router.post("/settings/ai/endpoints/{endpoint_id}/discover-models", response_class=HTMLResponse)
def ai_discover_models_web(request: Request, endpoint_id: int, db: Session = Depends(get_db)):
    user = require_session_user(request)
    if isinstance(user, RedirectResponse):
        return user
    user = _ensure_session_permissions(user, db)
    denied = _require_manage_ai(user)
    if denied:
        return denied

    try:
        discover_models(db, endpoint_id)
        return RedirectResponse(url=f"/settings/ai?endpoint_id={endpoint_id}&message=models", status_code=303)
    except ValueError as exc:
        return RedirectResponse(url=f"/settings/ai?endpoint_id={endpoint_id}&error={str(exc)}", status_code=303)


@router.post("/settings/ai/endpoints/{endpoint_id}/validate-model", response_class=HTMLResponse)
def ai_validate_model_web(
    request: Request,
    endpoint_id: int,
    model_id: str | None = Form(None),
    manual_model: str | None = Form(None),
    db: Session = Depends(get_db),
):
    user = require_session_user(request)
    if isinstance(user, RedirectResponse):
        return user
    user = _ensure_session_permissions(user, db)
    denied = _require_manage_ai(user)
    if denied:
        return denied

    try:
        validate_model(db, endpoint_id, (manual_model or "").strip() or model_id)
        return RedirectResponse(url=f"/settings/ai?endpoint_id={endpoint_id}&message=validated", status_code=303)
    except ValueError as exc:
        return RedirectResponse(url=f"/settings/ai?endpoint_id={endpoint_id}&error={str(exc)}", status_code=303)


@router.post("/settings/ai/endpoints/{endpoint_id}/set-default", response_class=HTMLResponse)
def ai_set_default_web(request: Request, endpoint_id: int, db: Session = Depends(get_db)):
    user = require_session_user(request)
    if isinstance(user, RedirectResponse):
        return user
    user = _ensure_session_permissions(user, db)
    denied = _require_manage_ai(user)
    if denied:
        return denied

    set_default_endpoint(db, endpoint_id)
    return RedirectResponse(url=f"/settings/ai?endpoint_id={endpoint_id}&message=default", status_code=303)


@router.post("/settings/ai/endpoints/{endpoint_id}/disable", response_class=HTMLResponse)
def ai_disable_endpoint_web(request: Request, endpoint_id: int, db: Session = Depends(get_db)):
    user = require_session_user(request)
    if isinstance(user, RedirectResponse):
        return user
    user = _ensure_session_permissions(user, db)
    denied = _require_manage_ai(user)
    if denied:
        return denied

    endpoint = get_endpoint(db, endpoint_id)
    set_endpoint_active(db, endpoint_id, not endpoint["is_active"])
    return RedirectResponse(url=f"/settings/ai?endpoint_id={endpoint_id}&message=active", status_code=303)


@router.post("/settings/ai/endpoints/{endpoint_id}/clone", response_class=HTMLResponse)
def ai_clone_endpoint_web(request: Request, endpoint_id: int, db: Session = Depends(get_db)):
    user = require_session_user(request)
    if isinstance(user, RedirectResponse):
        return user
    user = _ensure_session_permissions(user, db)
    denied = _require_manage_ai(user)
    if denied:
        return denied

    try:
        new_endpoint = clone_endpoint(db, endpoint_id)
        return RedirectResponse(url=f"/settings/ai?endpoint_id={new_endpoint['id']}&message=cloned", status_code=303)
    except ValueError as exc:
        return RedirectResponse(url=f"/settings/ai?endpoint_id={endpoint_id}&error={str(exc)}", status_code=303)


@router.post("/settings/ai/endpoints/{endpoint_id}/move-up", response_class=HTMLResponse)
def ai_move_up_web(request: Request, endpoint_id: int, db: Session = Depends(get_db)):
    user = require_session_user(request)
    if isinstance(user, RedirectResponse):
        return user
    user = _ensure_session_permissions(user, db)
    denied = _require_manage_ai(user)
    if denied:
        return denied

    move_endpoint(db, endpoint_id, "up")
    return RedirectResponse(url=f"/settings/ai?endpoint_id={endpoint_id}", status_code=303)


@router.post("/settings/ai/endpoints/{endpoint_id}/move-down", response_class=HTMLResponse)
def ai_move_down_web(request: Request, endpoint_id: int, db: Session = Depends(get_db)):
    user = require_session_user(request)
    if isinstance(user, RedirectResponse):
        return user
    user = _ensure_session_permissions(user, db)
    denied = _require_manage_ai(user)
    if denied:
        return denied

    move_endpoint(db, endpoint_id, "down")
    return RedirectResponse(url=f"/settings/ai?endpoint_id={endpoint_id}", status_code=303)


# ── Prompts IA ────────────────────────────────────────────────────────────────

@router.get("/settings/ai/prompts", response_class=HTMLResponse)
def ai_prompts_page(request: Request, template_id: int | None = None, db: Session = Depends(get_db)):
    user = require_session_user(request)
    if isinstance(user, RedirectResponse):
        return user
    user = _ensure_session_permissions(user, db)
    denied = _require_manage_ai(user)
    if denied:
        return denied

    templates_list = list_templates(db)
    selected_template = None
    versions = []

    if template_id:
        selected_template, versions = get_template_with_versions(db, template_id)
    elif templates_list:
        selected_template, versions = get_template_with_versions(db, int(templates_list[0]["id"]))

    return templates.TemplateResponse(
        request=request,
        name="ai_prompts.html",
        context=_template_context(
            request,
            user=user,
            active_section="ai_settings",
            active_ai_section="prompts",
            templates_list=templates_list,
            selected_template=selected_template,
            versions=versions,
            message=request.query_params.get("message"),
            error=request.query_params.get("error"),
        ),
    )


@router.post("/settings/ai/prompts/{tmpl_id}/versions", response_class=HTMLResponse)
def ai_create_version_web(
    request: Request,
    tmpl_id: int,
    system_prompt: str = Form(...),
    user_prompt_template: str = Form(""),
    notes: str | None = Form(None),
    db: Session = Depends(get_db),
):
    user = require_session_user(request)
    if isinstance(user, RedirectResponse):
        return user
    user = _ensure_session_permissions(user, db)
    denied = _require_manage_ai(user)
    if denied:
        return denied

    if not system_prompt.strip():
        return RedirectResponse(
            url=f"/settings/ai/prompts?template_id={tmpl_id}&error=El+system+prompt+no+puede+estar+vacío",
            status_code=303,
        )

    create_version(
        db,
        tmpl_id,
        system_prompt=system_prompt,
        user_prompt_template=user_prompt_template,
        notes=notes,
        user_id=int(user["user_id"]),
    )
    return RedirectResponse(
        url=f"/settings/ai/prompts?template_id={tmpl_id}&message=version_created",
        status_code=303,
    )


@router.post("/settings/ai/prompts/{tmpl_id}/versions/{version_id}/activate", response_class=HTMLResponse)
def ai_activate_version_web(
    request: Request,
    tmpl_id: int,
    version_id: int,
    db: Session = Depends(get_db),
):
    user = require_session_user(request)
    if isinstance(user, RedirectResponse):
        return user
    user = _ensure_session_permissions(user, db)
    denied = _require_manage_ai(user)
    if denied:
        return denied

    activate_version(db, version_id, tmpl_id)
    return RedirectResponse(
        url=f"/settings/ai/prompts?template_id={tmpl_id}&message=version_activated",
        status_code=303,
    )


# ── Histórico LLM ────────────────────────────────────────────────────────────

@router.get("/settings/ai/history", response_class=HTMLResponse)
def ai_history_page(request: Request, db: Session = Depends(get_db)):
    user = require_session_user(request)
    if isinstance(user, RedirectResponse):
        return user
    user = _ensure_session_permissions(user, db)
    denied = _require_manage_ai(user)
    if denied:
        return denied

    calls = list_call_history(db, limit=60)
    return templates.TemplateResponse(
        request=request,
        name="ai_history.html",
        context=_template_context(
            request,
            user=user,
            active_section="ai_settings",
            active_ai_section="history",
            calls=calls,
        ),
    )


@router.get("/settings/ai/history/{call_id}/detail", response_class=HTMLResponse)
def ai_call_detail_htmx(request: Request, call_id: int, db: Session = Depends(get_db)):
    user = require_session_user(request)
    if isinstance(user, RedirectResponse):
        return user
    user = _ensure_session_permissions(user, db)
    denied = _require_manage_ai(user)
    if denied:
        return denied

    call = get_call_detail(db, call_id)
    return templates.TemplateResponse(
        request=request,
        name="partials/ai_call_detail.html",
        context=_template_context(request, call=call),
    )


def _selected_permissions(values: set[str]) -> dict[str, bool]:
    return {
        "can_manage_users": "can_manage_users" in values,
        "can_manage_account_config": "can_manage_account_config" in values,
        "can_read_account_mail": "can_read_account_mail" in values,
        "can_reply_from_account": "can_reply_from_account" in values,
        "can_create_glpi_ticket": "can_create_glpi_ticket" in values,
        "can_update_glpi_ticket": "can_update_glpi_ticket" in values,
        "can_link_tickets": "can_link_tickets" in values,
        "can_manage_ai": "can_manage_ai" in values,
    }


def _require_manage_users(user: dict):
    if not user.get("can_manage_users"):
        return RedirectResponse(url="/app", status_code=303)
    return None


@router.get("/accounts", response_class=HTMLResponse)
def accounts_page(
    request: Request,
    collaborator_id: int | None = None,
    message: str | None = None,
    error: str | None = None,
    db: Session = Depends(get_db),
):
    user = require_session_user(request)
    if isinstance(user, RedirectResponse):
        return user

    user = _ensure_session_permissions(user, db)
    denied = _require_manage_users(user)
    if denied:
        return denied

    collaborators = list_account_users(db, account_id=int(user["account_id"]))
    selected = next((c for c in collaborators if c["id"] == collaborator_id), None) if collaborator_id else None

    return templates.TemplateResponse(
        request=request,
        name="accounts.html",
        context=_template_context(
            request,
            user=user,
            active_section="accounts",
            collaborators=collaborators,
            selected=selected,
            message=message,
            error=error,
        ),
    )


@router.post("/accounts/collaborators", response_class=HTMLResponse)
def accounts_create_collaborator(
    request: Request,
    username_local: str = Form(...),
    display_name: str = Form(...),
    password: str = Form(...),
    contact_email: str | None = Form(None),
    role: str = Form("collaborator"),
    permissions: list[str] = Form([]),
    db: Session = Depends(get_db),
):
    user = require_session_user(request)
    if isinstance(user, RedirectResponse):
        return user

    user = _ensure_session_permissions(user, db)
    denied = _require_manage_users(user)
    if denied:
        return denied

    try:
        create_local_collaborator(
            db,
            account_id=int(user["account_id"]),
            username_local=username_local,
            display_name=display_name,
            password=password,
            contact_email=contact_email,
            role=role,
            permissions=_selected_permissions(set(permissions)),
            created_by_user_id=int(user["user_id"]),
        )
    except ValueError:
        pass

    return RedirectResponse(url="/accounts?message=created", status_code=303)


@router.post("/accounts/collaborators/{collaborator_id}/update", response_class=HTMLResponse)
def accounts_update_collaborator(
    request: Request,
    collaborator_id: int,
    display_name: str = Form(...),
    contact_email: str | None = Form(None),
    role: str = Form("collaborator"),
    permissions: list[str] = Form([]),
    db: Session = Depends(get_db),
):
    user = require_session_user(request)
    if isinstance(user, RedirectResponse):
        return user

    user = _ensure_session_permissions(user, db)
    denied = _require_manage_users(user)
    if denied:
        return denied

    try:
        update_local_collaborator(
            db,
            account_id=int(user["account_id"]),
            user_id=collaborator_id,
            display_name=display_name,
            contact_email=contact_email,
            role=role,
            permissions=_selected_permissions(set(permissions)),
        )
    except ValueError:
        pass

    return RedirectResponse(url=f"/accounts?collaborator_id={collaborator_id}&message=updated", status_code=303)


@router.post("/accounts/collaborators/{collaborator_id}/status", response_class=HTMLResponse)
def accounts_set_collaborator_status(
    request: Request,
    collaborator_id: int,
    status: str = Form(...),
    db: Session = Depends(get_db),
):
    user = require_session_user(request)
    if isinstance(user, RedirectResponse):
        return user

    user = _ensure_session_permissions(user, db)
    denied = _require_manage_users(user)
    if denied:
        return denied

    try:
        set_local_collaborator_status(
            db,
            account_id=int(user["account_id"]),
            user_id=collaborator_id,
            status=status,
        )
    except ValueError:
        pass

    return RedirectResponse(url=f"/accounts?collaborator_id={collaborator_id}&message=status_changed", status_code=303)


@router.get("/settings", response_class=HTMLResponse)
def settings_page(
    request: Request,
    tab: str | None = None,
    message: str | None = None,
    error: str | None = None,
    db: Session = Depends(get_db),
):
    user = require_session_user(request)
    if isinstance(user, RedirectResponse):
        return user
    user = _ensure_session_permissions(user, db)
    denied = _require_permission(user, "can_manage_account_config")
    if denied:
        return denied

    active_tab = tab if tab in ("cuenta", "imap", "glpi") else "cuenta"
    try:
        account = get_account_settings(db, account_id=int(user["account_id"]))
    except ValueError:
        account = {}

    return templates.TemplateResponse(
        request=request,
        name="settings.html",
        context=_template_context(
            request,
            user=user,
            active_section="settings",
            active_settings_section="cuenta",
            tab=active_tab,
            account=account,
            message=message,
            error=error,
        ),
    )


@router.post("/settings/cuenta", response_class=HTMLResponse)
def settings_update_cuenta(
    request: Request,
    display_name: str = Form(...),
    notes: str | None = Form(None),
    db: Session = Depends(get_db),
):
    user = require_session_user(request)
    if isinstance(user, RedirectResponse):
        return user
    user = _ensure_session_permissions(user, db)
    denied = _require_permission(user, "can_manage_account_config")
    if denied:
        return denied

    try:
        update_account_info(db, account_id=int(user["account_id"]), display_name=display_name, notes=notes)
    except Exception as exc:
        return RedirectResponse(url=f"/settings?error={exc}", status_code=303)
    return RedirectResponse(url="/settings?message=saved", status_code=303)


@router.post("/settings/imap", response_class=HTMLResponse)
def settings_update_imap(
    request: Request,
    imap_host: str = Form(...),
    imap_username: str = Form(...),
    imap_password: str | None = Form(None),
    db: Session = Depends(get_db),
):
    user = require_session_user(request)
    if isinstance(user, RedirectResponse):
        return user
    user = _ensure_session_permissions(user, db)
    denied = _require_permission(user, "can_manage_account_config")
    if denied:
        return denied

    try:
        update_account_imap(
            db,
            account_id=int(user["account_id"]),
            imap_host=imap_host,
            imap_username=imap_username,
            imap_password=imap_password,
        )
    except Exception as exc:
        return RedirectResponse(url=f"/settings?tab=imap&error={exc}", status_code=303)
    return RedirectResponse(url="/settings?tab=imap&message=saved", status_code=303)


@router.post("/settings/glpi", response_class=HTMLResponse)
def settings_update_glpi(
    request: Request,
    glpi_instance_id: int = Form(...),
    base_url: str = Form(...),
    glpi_name: str = Form(...),
    app_token: str | None = Form(None),
    verify_tls: str | None = Form(None),
    db: Session = Depends(get_db),
):
    user = require_session_user(request)
    if isinstance(user, RedirectResponse):
        return user
    user = _ensure_session_permissions(user, db)
    denied = _require_permission(user, "can_manage_account_config")
    if denied:
        return denied

    try:
        update_account_glpi(
            db,
            account_id=int(user["account_id"]),
            glpi_instance_id=glpi_instance_id,
            base_url=base_url,
            glpi_name=glpi_name,
            app_token=app_token,
            verify_tls=bool(verify_tls),
        )
    except Exception as exc:
        return RedirectResponse(url=f"/settings?tab=glpi&error={exc}", status_code=303)
    return RedirectResponse(url="/settings?tab=glpi&message=saved", status_code=303)


@router.get("/api/emails/{email_message_id}/ai-tags", response_class=HTMLResponse)
def email_ai_tags(
    request: Request,
    email_message_id: int,
    db: Session = Depends(get_db),
):
    """Partial HTMX: devuelve las etiquetas IA de un correo archivado."""
    user = require_session_user(request)
    if isinstance(user, RedirectResponse):
        return HTMLResponse("")
    result = get_email_ai_result(db, email_message_id)
    if not result or result.get("status") != "processed":
        return HTMLResponse("")
    tipo = result.get("tipo_correo", "")
    prior = result.get("prioridad_sugerida", "")
    accion = result.get("accion_sugerida", "")
    html = (
        f'<span class="ai-badge ai-tipo-{tipo.replace("_", "-")}">{tipo}</span> '
        f'<span class="ai-badge ai-prioridad-{prior}">{prior}</span>'
    )
    if accion:
        html += f'<span class="ai-hint" style="margin-left:6px;">{accion[:80]}</span>'
    return HTMLResponse(html)


@router.get("/api/emails/{email_message_id}/viewer-panel", response_class=HTMLResponse)
def email_viewer_panel(
    request: Request,
    email_message_id: int,
    thread_id: Optional[int] = None,
    db: Session = Depends(get_db),
):
    """
    Partial HTMX: devuelve el visor de iframe de un correo archivado para la superbandeja.
    Lee el .eml del disco, sanitiza y devuelve cabecera + iframe sandbox.
    """
    import email as email_lib
    from email.policy import default as email_default
    from pathlib import Path
    from app.services.message_detail_service import sanitize_html_body

    user = require_session_user(request)
    if isinstance(user, RedirectResponse):
        return HTMLResponse('<p class="pane-empty-text">Sesión no válida.</p>', status_code=403)

    row = db.execute(
        text("""
            SELECT id, subject, from_name, from_email, sent_at, direction,
                   eml_storage_path, has_attachments, body_text_preview, account_id
            FROM gestor_tickets.email_messages
            WHERE id = :id AND account_id = :account_id
            LIMIT 1
        """),
        {"id": email_message_id, "account_id": int(user["account_id"])},
    ).mappings().first()

    if not row:
        return HTMLResponse('<p class="pane-empty-text">Correo no encontrado.</p>', status_code=404)

    eml_path = row["eml_storage_path"]
    html_body = None
    text_body = None
    blocked_active_content = False

    try:
        raw = Path(eml_path).read_bytes()
        parsed = email_lib.message_from_bytes(raw, policy=email_default)
        for part in parsed.walk():
            ct = part.get_content_type()
            if ct == "text/html" and html_body is None:
                payload = part.get_payload(decode=True)
                charset = part.get_content_charset() or "utf-8"
                try:
                    html_body = payload.decode(charset, errors="replace")
                except Exception:
                    html_body = payload.decode("latin-1", errors="replace")
            elif ct == "text/plain" and text_body is None:
                payload = part.get_payload(decode=True)
                charset = part.get_content_charset() or "utf-8"
                try:
                    text_body = payload.decode(charset, errors="replace")
                except Exception:
                    text_body = payload.decode("latin-1", errors="replace")

        if html_body:
            html_body, blocked_active_content = sanitize_html_body(
                html_body, email_message_id=email_message_id
            )
    except Exception:
        pass

    ai_result = get_email_ai_result(db, email_message_id)
    tipo = (ai_result or {}).get("tipo_correo", "")
    prior = (ai_result or {}).get("prioridad_sugerida", "")
    accion = (ai_result or {}).get("accion_sugerida", "")

    dir_class = "is-in" if row["direction"] == "inbound" else "is-out"
    dir_label = "Recibido" if row["direction"] == "inbound" else "Enviado"
    sent_at = str(row["sent_at"])[:16] if row["sent_at"] else "Sin fecha"

    ai_tags_html = ""
    if tipo:
        ai_tags_html += f'<span class="ai-badge ai-tipo-{tipo.replace("_", "-")}">{tipo}</span> '
    if prior:
        ai_tags_html += f'<span class="ai-badge ai-prioridad-{prior}">{prior}</span>'
    if accion:
        ai_tags_html += f'<span class="ai-hint" style="margin-left:6px;">{accion[:90]}</span>'

    blocked_banner = ""
    if blocked_active_content:
        blocked_banner = (
            '<div class="blocked-content-banner">'
            '<span class="blocked-icon">🛡</span>'
            '<span>Scripts y recursos activos bloqueados por seguridad. El contenido se muestra de forma segura.</span>'
            '</div>'
        )

    if html_body:
        import html as html_lib
        srcdoc = html_lib.escape(html_body, quote=True)
        body_section = (
            f'{blocked_banner}'
            f'<iframe class="inbox-email-iframe" '
            f'sandbox="allow-popups allow-same-origin" '
            f'srcdoc="{srcdoc}" '
            f'style="width:100%;min-height:420px;border:none;display:block;">'
            f'</iframe>'
        )
    elif text_body:
        import html as html_lib
        safe_text = html_lib.escape(text_body)
        body_section = f'<pre class="inbox-email-preview" style="white-space:pre-wrap;">{safe_text}</pre>'
    else:
        body_section = '<p class="pane-empty-text">Este correo no tiene cuerpo de texto.</p>'

    subject_safe = (row["subject"] or "(Sin asunto)").replace("<", "&lt;").replace(">", "&gt;")
    from_safe = (f'{row["from_name"]} &lt;{row["from_email"]}&gt;' if row["from_name"] else (row["from_email"] or "?")).replace("<", "&lt;").replace(">", "&gt;")

    # Menú ⋮ de acciones — solo si se conoce el hilo de contexto
    action_menu_html = ""
    if thread_id:
        import html as html_lib2
        threads_rows = db.execute(
            text("""
                SELECT id, title FROM gestor_tickets.system_threads
                WHERE account_id = :account_id
                ORDER BY updated_at DESC NULLS LAST
                LIMIT 25
            """),
            {"account_id": int(user["account_id"])},
        ).mappings().all()

        copy_items = ""
        for t in threads_rows:
            if t["id"] != thread_id:
                t_title = html_lib2.escape((t["title"] or "(Sin título)")[:40])
                copy_items += (
                    f'<form method="post" action="/threads/{thread_id}/copy-email/{email_message_id}">'
                    f'<input type="hidden" name="target_thread_id" value="{t["id"]}">'
                    f'<button class="inbox-email-menu-item" type="submit">'
                    f'Copiar a: {t_title}'
                    f'</button>'
                    f'</form>'
                )

        fork_confirm = ""
        action_menu_html = (
            f'<div class="inbox-email-action-menu" x-data="{{ open: false }}" @click.outside="open = false">'
            f'<button class="inbox-email-menu-btn" @click="open = !open" title="Acciones del correo">⋮</button>'
            f'<div class="inbox-email-menu-dropdown" x-show="open" x-cloak>'
            f'<form method="post" action="/threads/{thread_id}/fork-email/{email_message_id}">'
            f'<button class="inbox-email-menu-item" type="submit">Bifurcar en nuevo hilo</button>'
            f'</form>'
            f'{"<hr class=inbox-email-menu-divider>" if copy_items else ""}'
            f'{copy_items}'
            f'</div>'
            f'</div>'
        )

    html_out = f"""
<div class="inbox-viewer-meta">
    {action_menu_html}
    <div class="inbox-viewer-subject">{subject_safe}</div>
    <div class="inbox-viewer-row">
        <span class="inbox-dir-badge {dir_class}">{dir_label}</span>
        <span class="inbox-viewer-from">De: {from_safe}</span>
        <span class="inbox-viewer-date">{sent_at}</span>
    </div>
    {f'<div class="inbox-viewer-ai-row">{ai_tags_html}</div>' if ai_tags_html else ''}
</div>
<div class="inbox-viewer-body">
    {body_section}
</div>
"""
    return HTMLResponse(html_out)


@router.get("/api/emails/{email_message_id}/cid/{content_id:path}")
def serve_inline_attachment(
    request: Request,
    email_message_id: int,
    content_id: str,
    db: Session = Depends(get_db),
):
    """Proxy seguro para imágenes incrustadas (cid:) referenciadas en correos archivados."""
    user = require_session_user(request)
    if isinstance(user, RedirectResponse):
        return Response(status_code=403)

    row = db.execute(
        text("""
            SELECT ea.storage_path, ea.content_type, ea.filename
            FROM gestor_tickets.email_attachments ea
            JOIN gestor_tickets.email_messages em ON em.id = ea.email_message_id
            WHERE ea.email_message_id = :email_id
              AND ea.is_inline = true
              AND em.account_id = :account_id
              AND (ea.content_id = :cid OR ea.content_id = :cid_brackets)
            LIMIT 1
        """),
        {
            "email_id": email_message_id,
            "account_id": int(user["account_id"]),
            "cid": content_id,
            "cid_brackets": f"<{content_id}>",
        },
    ).mappings().first()

    if not row or not row["storage_path"]:
        return Response(status_code=404)

    path = row["storage_path"]
    if not os.path.isfile(path):
        return Response(status_code=404)

    content_type = row["content_type"] or mimetypes.guess_type(path)[0] or "application/octet-stream"
    return FileResponse(path, media_type=content_type)


@router.post("/threads/{thread_id}/fork-email/{email_message_id}", response_class=HTMLResponse)
def fork_email(
    request: Request,
    thread_id: int,
    email_message_id: int,
    db: Session = Depends(get_db),
):
    user = require_session_user(request)
    if isinstance(user, RedirectResponse):
        return user
    try:
        new_thread = fork_email_to_new_thread(
            db,
            account_id=int(user["account_id"]),
            source_thread_id=thread_id,
            email_message_id=email_message_id,
            user_id=int(user["user_id"]),
        )
        return RedirectResponse(url=f"/threads/{new_thread['id']}", status_code=303)
    except ValueError as exc:
        return RedirectResponse(url=f"/threads/{thread_id}?error={exc}", status_code=303)


@router.post("/threads/{thread_id}/copy-email/{email_message_id}", response_class=HTMLResponse)
def copy_email(
    request: Request,
    thread_id: int,
    email_message_id: int,
    target_thread_id: int = Form(...),
    db: Session = Depends(get_db),
):
    user = require_session_user(request)
    if isinstance(user, RedirectResponse):
        return user
    try:
        copy_email_to_thread(
            db,
            account_id=int(user["account_id"]),
            target_thread_id=target_thread_id,
            email_message_id=email_message_id,
            user_id=int(user["user_id"]),
        )
        return RedirectResponse(url=f"/threads/{target_thread_id}?message=copied", status_code=303)
    except ValueError as exc:
        return RedirectResponse(url=f"/threads/{thread_id}?error={exc}", status_code=303)


@router.post("/threads/{thread_id}/merge-into/{target_thread_id}", response_class=HTMLResponse)
def merge_thread(
    request: Request,
    thread_id: int,
    target_thread_id: int,
    db: Session = Depends(get_db),
):
    user = require_session_user(request)
    if isinstance(user, RedirectResponse):
        return user
    try:
        result = merge_thread_into(
            db,
            account_id=int(user["account_id"]),
            source_thread_id=thread_id,
            target_thread_id=target_thread_id,
            user_id=int(user["user_id"]),
        )
        return RedirectResponse(url=f"/threads/{result['id']}?message=merged", status_code=303)
    except ValueError as exc:
        return RedirectResponse(url=f"/threads/{thread_id}?error={exc}", status_code=303)


@router.get("/personal", response_class=HTMLResponse)
def personal_accounts_page(
    request: Request,
    personal_account_id: int | None = None,
    mailbox: str = "INBOX",
    message: str | None = None,
    error: str | None = None,
    db: Session = Depends(get_db),
):
    """Bandeja personal: gestión de cuentas IMAP privadas y transferencia."""
    user = require_session_user(request)
    if isinstance(user, RedirectResponse):
        return user
    user = _ensure_session_permissions(user, db)
    denied = _require_permission(user, "can_read_account_mail")
    if denied:
        return denied

    accounts = list_personal_accounts(db, user_id=int(user["user_id"]))
    preview = None
    preview_error = None
    selected_account = None

    if personal_account_id:
        selected_account = next((a for a in accounts if a["id"] == personal_account_id), None)
        if selected_account:
            try:
                preview = preview_personal_mailbox(
                    db,
                    personal_account_id=personal_account_id,
                    user_id=int(user["user_id"]),
                    mailbox=mailbox,
                    limit=30,
                )
            except Exception as exc:
                preview_error = str(exc)

    return templates.TemplateResponse(
        request=request,
        name="personal.html",
        context=_template_context(
            request,
            user=user,
            active_section="personal",
            accounts=accounts,
            selected_account=selected_account,
            personal_account_id=personal_account_id,
            mailbox=mailbox,
            preview=preview,
            preview_error=preview_error,
            message=message,
            error=error,
        ),
    )


@router.post("/personal/accounts", response_class=HTMLResponse)
def create_personal_account_route(
    request: Request,
    email: str = Form(...),
    display_name: str = Form(""),
    imap_host: str = Form(...),
    imap_username: str = Form(...),
    imap_password: str = Form(...),
    imap_port: int = Form(993),
    transfer_folder: str = Form("Transferidos"),
    db: Session = Depends(get_db),
):
    user = require_session_user(request)
    if isinstance(user, RedirectResponse):
        return user
    try:
        result = create_personal_account(
            db,
            account_id=int(user["account_id"]),
            user_id=int(user["user_id"]),
            email=email,
            display_name=display_name or None,
            imap_host=imap_host,
            imap_username=imap_username,
            imap_password=imap_password,
            imap_port=imap_port,
            transfer_folder=transfer_folder,
        )
        return RedirectResponse(
            url=f"/personal?personal_account_id={result['id']}&message=saved",
            status_code=303,
        )
    except Exception as exc:
        return RedirectResponse(url=f"/personal?error={exc}", status_code=303)


@router.get("/personal/detect-siblings", response_class=HTMLResponse)
def detect_thread_siblings_route(
    request: Request,
    personal_account_id: int = 0,
    mailbox: str = "INBOX",
    uid: str = "",
    db: Session = Depends(get_db),
):
    """HTMX partial: detecta correos hermanos en el hilo antes de transferir."""
    user = require_session_user(request)
    if isinstance(user, RedirectResponse):
        return HTMLResponse("")
    try:
        siblings = detect_thread_siblings(
            db,
            personal_account_id=personal_account_id,
            user_id=int(user["user_id"]),
            mailbox=mailbox,
            uid=uid,
        )
    except Exception:
        siblings = []

    if not siblings:
        return HTMLResponse("")

    items = "".join(
        f'<label class="checkbox-label">'
        f'<input type="checkbox" name="sibling_uid" value="{s["uid"]}" checked> '
        f'{s["subject"]} — {s["from_"]}</label>'
        for s in siblings
    )
    return HTMLResponse(
        f'<div class="assistant-hint" style="margin-top:10px;">'
        f'<strong>Se detectaron {len(siblings)} correo(s) relacionados en el mismo hilo.</strong> '
        f'Puedes transferirlos también:'
        f'<div style="margin-top:8px; display:grid; gap:4px;">{items}</div>'
        f'</div>'
    )


@router.post("/personal/transfer", response_class=HTMLResponse)
def transfer_email_route(
    request: Request,
    personal_account_id: int = Form(...),
    mailbox: str = Form(...),
    uid: str = Form(...),
    move_after: str = Form("1"),
    sibling_uid: list[str] = Form(default=[]),
    db: Session = Depends(get_db),
):
    user = require_session_user(request)
    if isinstance(user, RedirectResponse):
        return user
    target_account_id = int(user["account_id"])
    user_id = int(user["user_id"])
    move = move_after == "1"

    errors = []
    all_uids = [uid] + sibling_uid

    for transfer_uid in all_uids:
        try:
            transfer_personal_email(
                db,
                personal_account_id=personal_account_id,
                user_id=user_id,
                mailbox=mailbox,
                uid=transfer_uid,
                target_account_id=target_account_id,
                move_after_transfer=move,
            )
        except Exception as exc:
            errors.append(f"UID {transfer_uid}: {exc}")

    if errors:
        err_str = "; ".join(errors)
        return RedirectResponse(
            url=f"/personal?personal_account_id={personal_account_id}&mailbox={mailbox}&error={err_str}",
            status_code=303,
        )

    return RedirectResponse(
        url=f"/personal?personal_account_id={personal_account_id}&mailbox={mailbox}&message=transferred",
        status_code=303,
    )


@router.post("/settings/assistant-mode", response_class=HTMLResponse)
def toggle_assistant_mode(request: Request, db: Session = Depends(get_db)):
    user = require_session_user(request)
    if isinstance(user, RedirectResponse):
        return user

    current = bool(user.get("assistant_mode", True))
    new_value = not current

    db.execute(
        text("""
            UPDATE gestor_tickets.account_users
            SET assistant_mode = :v, updated_at = now()
            WHERE id = :user_id
        """),
        {"v": new_value, "user_id": int(user["user_id"])},
    )
    db.commit()

    session_data = dict(request.session["user"])
    session_data["assistant_mode"] = new_value
    request.session["user"] = session_data

    label = "Asistente ON" if new_value else "Asistente OFF"
    cls = "assistant-toggle is-on" if new_value else "assistant-toggle"
    return HTMLResponse(
        f'<button class="{cls}" hx-post="/settings/assistant-mode" '
        f'hx-target="this" hx-swap="outerHTML" title="Modo asistente didáctico">'
        f'{label}</button>'
    )


@router.get("/{section}", response_class=HTMLResponse)
def protected_section(request: Request, section: str):
    if section not in SECTION_DEFINITIONS:
        return RedirectResponse(url="/app", status_code=303)

    user = require_session_user(request)
    if isinstance(user, RedirectResponse):
        return user

    definition = SECTION_DEFINITIONS[section]

    return templates.TemplateResponse(
        request=request,
        name="section_page.html",
        context=_template_context(
            request,
            user=user,
            active_section=section,
            section_key=section,
            section=definition,
        ),
    )
