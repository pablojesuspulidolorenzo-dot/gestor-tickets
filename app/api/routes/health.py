from fastapi import APIRouter
from sqlalchemy import text

from app.core.config import settings
from app.core.db import engine
from app.core.versioning import get_version_metadata

router = APIRouter(tags=["health"])


def _check_postgres() -> dict:
    try:
        with engine.connect() as conn:
            result = conn.execute(
                text(
                    """
                    select
                        current_database() as database_name,
                        current_user as database_user,
                        current_schema() as current_schema
                    """
                )
            ).mappings().first()

        return {
            "status": "ok",
            "host": settings.POSTGRES_HOST,
            "port": settings.POSTGRES_PORT,
            "database": result["database_name"] if result else settings.POSTGRES_DB,
            "user": result["database_user"] if result else settings.POSTGRES_USER,
            "schema": settings.DB_SCHEMA,
        }
    except Exception as exc:
        return {
            "status": "error",
            "host": settings.POSTGRES_HOST,
            "port": settings.POSTGRES_PORT,
            "database": settings.POSTGRES_DB,
            "schema": settings.DB_SCHEMA,
            "error": str(exc),
        }


@router.get("")
def health() -> dict:
    postgres = _check_postgres()
    return {
        "status": "ok" if postgres["status"] == "ok" else "degraded",
        "app": {
            "name": settings.APP_NAME,
            "environment": settings.APP_ENV,
            "timezone": settings.APP_TIMEZONE,
            "version": get_version_metadata(),
        },
        "postgres": postgres,
        "glpi": {
            "base_url": settings.GLPI_BASE_URL,
            "required_profile": settings.GLPI_REQUIRED_PROFILE,
        },
    }
