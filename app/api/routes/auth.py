from fastapi import APIRouter

from app.schemas.auth import (
    GlpiLoginValidationRequest,
    GlpiLoginValidationResponse,
    GlpiProfileResponse,
)
from app.services.glpi_service import glpi_service

router = APIRouter(tags=["auth"])


@router.post("/glpi/validate", response_model=GlpiLoginValidationResponse)
async def validate_glpi_login(payload: GlpiLoginValidationRequest):
    """
    Valida una cuenta principal contra GLPI.

    No guarda la contraseña. Solo comprueba credenciales y perfil requerido.
    """
    result = await glpi_service.validate_account_manager_login(
        login=payload.login,
        password=payload.password,
    )

    return GlpiLoginValidationResponse(
        ok=result.ok,
        login=result.login,
        required_profile=result.required_profile,
        has_required_profile=result.has_required_profile,
        profiles=[GlpiProfileResponse(id=p.id, name=p.name) for p in result.profiles],
        glpi_user_id=result.glpi_user_id,
        glpi_user_name=result.glpi_user_name,
        message=result.message,
    )
