from fastapi import APIRouter, Depends

from app.api.routes import accounts, ai_settings, auth, glpi_tickets, health, mail_ingestion, mailbox, threads
from app.api.dependencies import require_api_session

api_router = APIRouter()

api_router.include_router(health.router, prefix="/health")
api_router.include_router(auth.router, prefix="/auth")
internal_api_dependencies = [Depends(require_api_session)]

api_router.include_router(accounts.router, prefix="/accounts", dependencies=internal_api_dependencies)
api_router.include_router(ai_settings.router, prefix="/ai-settings", dependencies=internal_api_dependencies)
api_router.include_router(mailbox.router, prefix="/mailbox", dependencies=internal_api_dependencies)
api_router.include_router(threads.router, prefix="/threads", dependencies=internal_api_dependencies)
api_router.include_router(glpi_tickets.router, prefix="/glpi/tickets", dependencies=internal_api_dependencies)
api_router.include_router(mail_ingestion.router, prefix="/mail-ingestion", dependencies=internal_api_dependencies)
