from datetime import datetime

from pydantic import BaseModel, EmailStr, Field


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
