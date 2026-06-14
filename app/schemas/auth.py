from pydantic import BaseModel, Field


class GlpiLoginValidationRequest(BaseModel):
    login: str = Field(..., min_length=1)
    password: str = Field(..., min_length=1)


class GlpiProfileResponse(BaseModel):
    id: int | None
    name: str


class GlpiLoginValidationResponse(BaseModel):
    ok: bool
    login: str
    required_profile: str
    has_required_profile: bool
    profiles: list[GlpiProfileResponse]
    glpi_user_id: int | None = None
    glpi_user_name: str | None = None
    message: str
