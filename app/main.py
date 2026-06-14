from app.services.mail_ingestion_scheduler import start_mail_ingestion_scheduler, stop_mail_ingestion_scheduler
from fastapi import FastAPI, Request
from fastapi.responses import HTMLResponse, JSONResponse
from fastapi.staticfiles import StaticFiles
from fastapi.templating import Jinja2Templates
from starlette.middleware.sessions import SessionMiddleware

from app.api.router import api_router
from app.api.routes.web_auth import router as web_auth_router
from app.core.config import settings
from app.core.versioning import get_version_metadata

app = FastAPI(
    title=settings.APP_NAME,
    version=settings.full_version,
)

app.add_middleware(
    SessionMiddleware,
    secret_key=settings.SESSION_SECRET_KEY,
    same_site="lax",
    https_only=settings.SESSION_COOKIE_HTTPS_ONLY or settings.APP_ENV.lower() == "production",
)

app.mount("/static", StaticFiles(directory="/app/static"), name="static")
templates = Jinja2Templates(directory="/app/templates")

app.include_router(api_router, prefix="/api")
app.include_router(web_auth_router)


@app.get("/", response_class=HTMLResponse)
def index(request: Request):
    return templates.TemplateResponse(
        request=request,
        name="index.html",
        context={
            "app_name": settings.APP_NAME,
            "app_env": settings.APP_ENV,
            "postgres_host": settings.POSTGRES_HOST,
            "db_schema": settings.DB_SCHEMA,
            "glpi_base_url": settings.GLPI_BASE_URL,
            "version": get_version_metadata(),
            "htmx_local": True,
        },
    )


@app.get("/health")
def root_health():
    return JSONResponse(
        {
            "status": "ok",
            "app": settings.APP_NAME,
            "environment": settings.APP_ENV,
            "version": get_version_metadata(),
        }
    )


@app.get("/htmx/ping", response_class=HTMLResponse)
def htmx_ping():
    return HTMLResponse(
        "<div style='background:#ecfdf5;border:1px solid #a7f3d0;color:#065f46;"
        "padding:12px 16px;border-radius:8px;font-weight:600;'>"
        "HTMX funciona correctamente ✅"
        "</div>"
    )


@app.on_event("startup")
async def _start_mail_ingestion_scheduler() -> None:
    start_mail_ingestion_scheduler()


@app.on_event("shutdown")
async def _stop_mail_ingestion_scheduler() -> None:
    await stop_mail_ingestion_scheduler()
