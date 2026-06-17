import json

from fastapi import APIRouter, Depends, Form, Request
from fastapi.responses import HTMLResponse, RedirectResponse
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
    create_thread_from_email,
    get_active_thread_for_email,
    get_thread_detail,
    list_system_threads,
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
    context = {
        "request": request,
        "app_name": settings.APP_NAME,
        "app_env": settings.APP_ENV,
        "version": get_version_metadata(),
        "htmx_local": True,
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

    return templates.TemplateResponse(
        request=request,
        name="mailbox.html",
        context=_template_context(
            request,
            user=user,
            active_section="mailbox",
            preview=preview,
            safety_notes=SAFETY_NOTES,
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
        if archived:
            thread = get_active_thread_for_email(
                db,
                email_message_id=int(archived["email_message_id"]),
            )
        error = None
    except ValueError as exc:
        detail = None
        archived = None
        thread = None
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



@router.get("/tickets", response_class=HTMLResponse)
def tickets_page(
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

    tickets = list_glpi_ticket_cache(
        db,
        account_id=int(user["account_id"]),
    )

    return templates.TemplateResponse(
        request=request,
        name="tickets.html",
        context=_template_context(
            request,
            user=user,
            active_section="tickets",
            tickets=tickets,
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
def accounts_page(request: Request, db: Session = Depends(get_db)):
    user = require_session_user(request)
    if isinstance(user, RedirectResponse):
        return user

    user = _ensure_session_permissions(user, db)
    denied = _require_manage_users(user)
    if denied:
        return denied

    collaborators = list_account_users(db, account_id=int(user["account_id"]))
    return templates.TemplateResponse(
        request=request,
        name="accounts.html",
        context=_template_context(
            request,
            user=user,
            active_section="accounts",
            collaborators=collaborators,
            error=None,
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

    return RedirectResponse(url="/accounts", status_code=303)


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

    return RedirectResponse(url="/accounts", status_code=303)


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

    return RedirectResponse(url="/accounts", status_code=303)


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
