from fastapi import FastAPI, Request
from fastapi.responses import HTMLResponse, JSONResponse
from fastapi.staticfiles import StaticFiles
from fastapi.templating import Jinja2Templates
import os

app = FastAPI(title="Gestor Tickets", version="0.1.0")

app.mount("/static", StaticFiles(directory="/app/static"), name="static")
templates = Jinja2Templates(directory="/app/templates")


@app.get("/", response_class=HTMLResponse)
def index(request: Request):
    return templates.TemplateResponse(
        request,
        "index.html",
        {
            "app_env": os.getenv("APP_ENV", "development"),
            "postgres_host": os.getenv("POSTGRES_HOST", "postgres"),
        },
    )


@app.get("/health")
def health():
    return JSONResponse({"status": "ok"})


@app.get("/htmx/ping", response_class=HTMLResponse)
def htmx_ping():
    return HTMLResponse("<div class='ok'>HTMX funciona correctamente ✅</div>")
