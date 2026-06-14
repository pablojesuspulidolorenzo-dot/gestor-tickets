import os
from pathlib import Path

from app.core.config import settings


def get_app_version() -> str:
    version_file = os.getenv("APP_VERSION_FILE", "/app/version.txt")
    path = Path(version_file)

    if path.exists():
        try:
            value = path.read_text(encoding="utf-8").strip()
            if value:
                return value
        except Exception:
            pass

    return settings.full_version


def get_version_metadata() -> dict:
    return {
        "version": settings.APP_VERSION,
        "subversion": settings.APP_SUBVERSION,
        "full": get_app_version(),
    }
