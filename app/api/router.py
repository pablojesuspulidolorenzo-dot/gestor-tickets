from fastapi import APIRouter

from app.api.routes import accounts, auth, health

api_router = APIRouter()

api_router.include_router(health.router, prefix="/health")
api_router.include_router(auth.router, prefix="/auth")
api_router.include_router(accounts.router, prefix="/accounts")
