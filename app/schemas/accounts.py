from datetime import datetime

from pydantic import BaseModel, EmailStr, Field, SecretStr


class CollaborativeAccountUpsertRequest(BaseModel):
    account_email: EmailStr = Field(
        ...,
        description="Buzón colaborativo real, por ejemplo sistemas-tic@gestor-tickets.es",
    )
    glpi_login: str = Field(
        ...,
        min_length=1,
        description="Login real del usuario GLPI, por ejemplo sistemas-tic",
    )
    glpi_password: str = Field(
        ...,
        min_length=1,
        description="Contraseña GLPI. Solo se usa para validar, no se guarda.",
    )
    display_name: str | None = Field(
        None,
        description="Nombre visible de la cuenta colaborativa.",
    )

    imap_host: str | None = None
    imap_username: str | None = None
    imap_password: str | None = None
    ingestion_enabled: bool = False


class CollaborativeAccountResponse(BaseModel):
    id: int
    email: str
    display_name: str | None
    status: str
    glpi_login: str
    glpi_user_id: int | None
    glpi_profile_name: str
    imap_host: str | None
    imap_username: str | None
    ingestion_enabled: bool
    archive_subdir: str
    owner_user_id: int | None = None
    created_at: datetime
    updated_at: datetime
    message: str


class CollaborativeAccountListItem(BaseModel):
    id: int
    email: str
    display_name: str | None
    status: str
    glpi_login: str
    glpi_user_id: int | None
    glpi_profile_name: str
    ingestion_enabled: bool
    archive_subdir: str
    created_at: datetime
    updated_at: datetime


class CollaborativeAccountImapConfigRequest(BaseModel):
    imap_host: str = Field(..., min_length=1)
    imap_port: int = Field(993, ge=1, le=65535)
    imap_use_ssl: bool = True
    imap_username: str = Field(..., min_length=1)
    imap_password: SecretStr = Field(..., min_length=1)
    mailbox: str = Field("INBOX", min_length=1)


class CollaborativeAccountImapTestResponse(BaseModel):
    ok: bool
    account_id: int
    account_email: str
    imap_host: str
    imap_port: int
    imap_use_ssl: bool
    imap_username: str
    mailbox: str
    message_count: int | None
    readonly_mode: bool
    safety_notes: list[str]
    message: str
