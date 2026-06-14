from fastapi import APIRouter, Depends, Form, Request
from fastapi.responses import HTMLResponse, RedirectResponse
from fastapi.templating import Jinja2Templates
from sqlalchemy.orm import Session

from app.core.config import settings
from app.core.db import get_db
from app.core.versioning import get_version_metadata
from app.services.session_auth_service import authenticate_session_user

router = APIRouter()
templates = Jinja2Templates(directory="/app/templates")


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
    user = get_session_user(request)
    if not user:
        return RedirectResponse(url="/login", status_code=303)

    return templates.TemplateResponse(
        request=request,
        name="app_home.html",
        context=_template_context(request, user=user),
    )
