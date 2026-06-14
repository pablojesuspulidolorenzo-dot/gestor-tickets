from fastapi import APIRouter, Depends, Form, Request
from fastapi.responses import HTMLResponse, RedirectResponse
from fastapi.templating import Jinja2Templates
from sqlalchemy.orm import Session

from app.core.config import settings
from app.core.db import get_db
from app.core.versioning import get_version_metadata
from app.services.email_archive_service import (
    archive_message_from_imap_readonly,
    find_archived_message_for_occurrence,
)
from app.services.mailbox_preview_service import SAFETY_NOTES, preview_unified_collaborative_mailbox
from app.services.message_detail_service import MESSAGE_DETAIL_SAFETY_NOTES, fetch_message_detail_readonly
from app.services.session_auth_service import authenticate_session_user
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

    try:
        thread, messages = get_thread_detail(
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
        ),
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
