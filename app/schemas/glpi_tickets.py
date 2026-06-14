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


class CreateGlpiTicketFromThreadResponse(BaseModel):
    ok: bool
    created: bool
    thread_id: int
    glpi_ticket_cache: GlpiTicketCacheSummary
    message: str
