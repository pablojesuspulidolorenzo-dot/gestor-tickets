from fastapi import APIRouter, Depends, Form, Request
from fastapi.responses import HTMLResponse, RedirectResponse
from fastapi.templating import Jinja2Templates
from sqlalchemy.orm import Session

from app.core.config import settings
from app.core.db import get_db
from app.core.versioning import get_version_metadata
from app.services.mailbox_preview_service import SAFETY_NOTES, preview_unified_collaborative_mailbox
from app.services.session_auth_service import authenticate_session_user

router = APIRouter()
templates = Jinja2Templates(directory="/app/templates")


SECTION_DEFINITIONS = {
    "threads": {
        "title": "Hilos",
        "icon": "🧵",
        "description": "Aquí se mostrarán los hilos operativos del sistema.",
        "next_steps": [
            "Agrupar mensajes por referencias, asunto y reglas internas.",
            "Permitir mover correos entre hilos.",
            "Permitir fusionar hilos y mantener auditoría.",
        ],
    },
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
