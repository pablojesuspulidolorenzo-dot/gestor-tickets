from __future__ import annotations

from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session

from app.core.db import get_db
from app.schemas.ai_settings import (
    AiEndpointCreate,
    AiEndpointDetailResponse,
    AiEndpointListResponse,
    AiEndpointResponse,
    AiEndpointUpdate,
    AiEndpointPreviewRequest,
    AiValidateModelPreviewRequest,
    AiModelListResponse,
    AiOperationResponse,
    AiValidateModelRequest,
    AiValidationResponse,
)
from app.services.ai_model_discovery_service import discover_models, discover_models_preview, validate_model, validate_model_preview
from app.services.ai_settings_service import (
    create_endpoint,
    get_endpoint,
    list_endpoints,
    list_models,
    list_validation_logs,
    set_default_endpoint,
    set_endpoint_active,
    update_endpoint,
)

router = APIRouter(tags=["ai-settings"])


@router.get("/endpoints", response_model=AiEndpointListResponse)
def api_list_endpoints(db: Session = Depends(get_db)):
    return AiEndpointListResponse(endpoints=[AiEndpointResponse(**item) for item in list_endpoints(db)])


@router.post("/endpoints", response_model=AiOperationResponse)
def api_create_endpoint(payload: AiEndpointCreate, db: Session = Depends(get_db)):
    try:
        endpoint = create_endpoint(db, payload.model_dump())
        return AiOperationResponse(ok=True, message="Endpoint IA creado.", endpoint=AiEndpointResponse(**endpoint))
    except ValueError as exc:
        raise HTTPException(status_code=400, detail=str(exc)) from exc


@router.get("/endpoints/{endpoint_id}", response_model=AiEndpointDetailResponse)
def api_get_endpoint(endpoint_id: int, db: Session = Depends(get_db)):
    try:
        endpoint = get_endpoint(db, endpoint_id)
        models = list_models(db, endpoint_id)
        logs = list_validation_logs(db, endpoint_id)
        return AiEndpointDetailResponse(
            endpoint=AiEndpointResponse(**endpoint),
            models=models,
            validation_logs=logs,
        )
    except ValueError as exc:
        raise HTTPException(status_code=404, detail=str(exc)) from exc


@router.post("/endpoints/{endpoint_id}", response_model=AiOperationResponse)
def api_update_endpoint(endpoint_id: int, payload: AiEndpointUpdate, db: Session = Depends(get_db)):
    try:
        endpoint = update_endpoint(db, endpoint_id, payload.model_dump())
        return AiOperationResponse(ok=True, message="Endpoint IA actualizado.", endpoint=AiEndpointResponse(**endpoint))
    except ValueError as exc:
        raise HTTPException(status_code=400, detail=str(exc)) from exc


@router.post("/endpoints/{endpoint_id}/disable", response_model=AiOperationResponse)
def api_disable_endpoint(endpoint_id: int, db: Session = Depends(get_db)):
    try:
        endpoint = set_endpoint_active(db, endpoint_id, False)
        return AiOperationResponse(ok=True, message="Endpoint IA desactivado.", endpoint=AiEndpointResponse(**endpoint))
    except ValueError as exc:
        raise HTTPException(status_code=404, detail=str(exc)) from exc


@router.post("/endpoints/{endpoint_id}/enable", response_model=AiOperationResponse)
def api_enable_endpoint(endpoint_id: int, db: Session = Depends(get_db)):
    try:
        endpoint = set_endpoint_active(db, endpoint_id, True)
        return AiOperationResponse(ok=True, message="Endpoint IA activado.", endpoint=AiEndpointResponse(**endpoint))
    except ValueError as exc:
        raise HTTPException(status_code=404, detail=str(exc)) from exc


@router.post("/endpoints/{endpoint_id}/set-default", response_model=AiOperationResponse)
def api_set_default_endpoint(endpoint_id: int, db: Session = Depends(get_db)):
    try:
        endpoint = set_default_endpoint(db, endpoint_id)
        return AiOperationResponse(ok=True, message="Endpoint IA predeterminado actualizado.", endpoint=AiEndpointResponse(**endpoint))
    except ValueError as exc:
        raise HTTPException(status_code=404, detail=str(exc)) from exc


@router.post("/endpoints/{endpoint_id}/discover-models", response_model=AiModelListResponse)
def api_discover_models(endpoint_id: int, db: Session = Depends(get_db)):
    try:
        models = discover_models(db, endpoint_id)
        return AiModelListResponse(endpoint_id=endpoint_id, models=models)
    except ValueError as exc:
        raise HTTPException(status_code=400, detail=str(exc)) from exc


@router.post("/endpoints/{endpoint_id}/validate-model", response_model=AiValidationResponse)
def api_validate_model(endpoint_id: int, payload: AiValidateModelRequest, db: Session = Depends(get_db)):
    try:
        return AiValidationResponse(**validate_model(db, endpoint_id, payload.model_id))
    except ValueError as exc:
        raise HTTPException(status_code=400, detail=str(exc)) from exc


@router.post("/discover-models-preview", response_model=AiModelListResponse)
def api_discover_models_preview(payload: AiEndpointPreviewRequest):
    try:
        models = discover_models_preview(payload.model_dump())
        return AiModelListResponse(endpoint_id=0, models=models)
    except ValueError as exc:
        raise HTTPException(status_code=400, detail=str(exc)) from exc


@router.post("/validate-model-preview", response_model=AiValidationResponse)
def api_validate_model_preview(payload: AiValidateModelPreviewRequest):
    try:
        return AiValidationResponse(**validate_model_preview(payload.model_dump(), payload.model_id))
    except ValueError as exc:
        raise HTTPException(status_code=400, detail=str(exc)) from exc
