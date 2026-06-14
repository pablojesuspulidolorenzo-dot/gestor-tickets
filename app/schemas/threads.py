from datetime import datetime

from pydantic import BaseModel


class ThreadSummary(BaseModel):
    id: int
    system_thread_uid: str
    account_id: int
    title: str | None
    subject_normalized: str | None
    status: str
    message_count: int
    last_message_at: datetime | None
    updated_at: datetime


class ThreadListResponse(BaseModel):
    ok: bool
    account_id: int
    threads: list[ThreadSummary]


class ThreadFromEmailResponse(BaseModel):
    ok: bool
    created: bool
    email_message_id: int
    thread: ThreadSummary
    message: str
