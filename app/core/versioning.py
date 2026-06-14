from pathlib import Path

from app.core.config import settings


def _read_version_file() -> str | None:
    candidates = [
        Path("/app/version.txt"),
        Path("app/version.txt"),
        Path("version.txt"),
    ]

    for path in candidates:
        if path.exists():
            value = path.read_text(encoding="utf-8").strip()
            if value:
                return value

    return None


def get_version_metadata() -> dict[str, str | int]:
    full = _read_version_file() or settings.full_version

    parts = full.split(".")
    subversion = 0

    if len(parts) >= 3 and parts[-1].isdigit():
        subversion = int(parts[-1])

    return {
        "version": full,
        "subversion": subversion,
        "full": full,
    }
