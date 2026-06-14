from datetime import datetime, timezone
from zoneinfo import ZoneInfo, ZoneInfoNotFoundError

from app.core.config import settings


def get_app_timezone() -> ZoneInfo:
    try:
        return ZoneInfo(settings.APP_TIMEZONE)
    except ZoneInfoNotFoundError:
        return ZoneInfo("UTC")


def utc_now_naive() -> datetime:
    return datetime.now(timezone.utc).replace(tzinfo=None)


def to_app_timezone(value: datetime | None) -> datetime | None:
    if value is None:
        return None

    source = value
    if source.tzinfo is None:
        source = source.replace(tzinfo=timezone.utc)

    return source.astimezone(get_app_timezone())


def format_app_datetime(value: datetime | None, default: str = "N/D") -> str:
    local_value = to_app_timezone(value)
    if local_value is None:
        return default
    return local_value.strftime("%d/%m/%Y %H:%M")


def datetime_local_input_value(value: datetime | None) -> str:
    local_value = to_app_timezone(value)
    if local_value is None:
        return ""
    return local_value.strftime("%Y-%m-%dT%H:%M")


def parse_app_datetime_input(value: str | None) -> datetime | None:
    clean = (value or "").strip()
    if not clean:
        return None

    local_value = datetime.fromisoformat(clean)
    if local_value.tzinfo is None:
        local_value = local_value.replace(tzinfo=get_app_timezone())

    return local_value.astimezone(timezone.utc).replace(tzinfo=None)
