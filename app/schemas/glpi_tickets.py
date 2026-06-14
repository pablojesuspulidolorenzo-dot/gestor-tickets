from datetime import datetime

from pydantic import BaseModel, SecretStr


class CreateGlpiTicketFromThreadRequest(BaseModel):
    glpi_password: SecretStr
    title: str | None = None


class GlpiTicketCacheSummary(BaseModel):
    id: int
    glpi_ticket_id: int
    title: str | None
    status: str | None
    priority: str | None
    urgency: str | None
    impact: str | None


class GlpiTicketListItem(GlpiTicketCacheSummary):
    account_id: int
    glpi_instance_id: int
    thread_count: int
    email_count: int
    last_sync_at: datetime | None
    updated_at: datetime


class GlpiTicketLinkedThread(BaseModel):
    link_id: int
    thread_id: int
    thread_title: str | None
    thread_status: str | None
    origin: str | None
    created_at: datetime


class GlpiTicketLinkedEmail(BaseModel):
    link_id: int
    email_message_id: int
    subject: str | None
    from_email: str | None
    sent_at: datetime | None
    origin: str | None
    created_at: datetime


class GlpiTicketDetailResponse(BaseModel):
    ok: bool
    ticket: GlpiTicketListItem
    threads: list[GlpiTicketLinkedThread]
    emails: list[GlpiTicketLinkedEmail]


class GlpiTicketListResponse(BaseModel):
    ok: bool
    account_id: int
    tickets: list[GlpiTicketListItem]


class CreateGlpiTicketFromThreadResponse(BaseModel):
    ok: bool
    created: bool
    thread_id: int
    glpi_ticket_cache: GlpiTicketCacheSummary
    message: str
