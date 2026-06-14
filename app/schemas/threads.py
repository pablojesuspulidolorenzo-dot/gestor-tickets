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


class ThreadMessageSummary(BaseModel):
    member_id: int
    email_message_id: int
    position_asc: int
    subject: str | None
    from_email: str | None
    from_name: str | None
    direction: str | None
    sent_at: datetime | None
    original_imap_folder: str | None
    original_imap_uid: str | None
    body_text_preview: str | None


class ThreadListResponse(BaseModel):
    ok: bool
    account_id: int
    threads: list[ThreadSummary]


class ThreadDetailResponse(BaseModel):
    ok: bool
    thread: ThreadSummary
    messages: list[ThreadMessageSummary]


class ThreadFromEmailResponse(BaseModel):
    ok: bool
    created: bool
    email_message_id: int
    thread: ThreadSummary
    message: str
