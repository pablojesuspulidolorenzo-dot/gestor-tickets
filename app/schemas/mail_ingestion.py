from datetime import datetime
from typing import Any

from pydantic import BaseModel, Field


class ConfigureMailIngestionJobRequest(BaseModel):
    account_id: int
    status: str = "active"
    scan_inbox: bool = True
    scan_sent: bool = True
    inbox_folder_name: str = "INBOX"
    sent_folder_name: str = "INBOX.Sent"
    interval_minutes: int = Field(default=5, ge=1, le=1440)
    max_messages_per_folder: int = Field(default=200, ge=1)
    lookback_days: int = Field(default=7, ge=1, le=365)


class MailIngestionJobSummary(BaseModel):
    id: int
    account_id: int
    status: str
    scan_inbox: bool
    scan_sent: bool
    inbox_folder_name: str
    sent_folder_name: str
    interval_minutes: int
    max_messages_per_folder: int
    lookback_days: int = 7
    last_started_at: datetime | None
    last_success_at: datetime | None
    last_error_at: datetime | None
    next_run_at: datetime | None
    auth_failure_count: int
    last_error_message: str | None
    created_by_user_id: int | None
    updated_by_user_id: int | None
    created_at: datetime
    updated_at: datetime


class MailIngestionRunSummary(BaseModel):
    id: int
    job_id: int
    account_id: int
    status: str
    started_at: datetime
    finished_at: datetime | None
    scanned_inbox_count: int
    scanned_sent_count: int
    imported_count: int
    duplicate_count: int
    error_count: int
    error_message: str | None
    details_json: dict[str, Any]


class ConfigureMailIngestionJobResponse(BaseModel):
    ok: bool
    job: MailIngestionJobSummary
    message: str


class MailIngestionRunResponse(BaseModel):
    ok: bool
    job: MailIngestionJobSummary
    run: MailIngestionRunSummary
    message: str


class MailIngestionJobListResponse(BaseModel):
    ok: bool
    jobs: list[MailIngestionJobSummary]
