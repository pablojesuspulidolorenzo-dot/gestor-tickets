from fastapi import APIRouter, Depends, HTTPException, Request
from sqlalchemy.orm import Session

from app.core.db import get_db
from app.schemas.accounts import (
    CollaborativeAccountListItem,
    CollaborativeAccountResponse,
    CollaborativeAccountUpsertRequest,
)
from app.services.account_service import (
    list_collaborative_accounts,
    upsert_collaborative_account,
)

router = APIRouter(tags=["accounts"])


def _account_response(result) -> CollaborativeAccountResponse:
    account = result.account
    owner = result.owner_user

    return CollaborativeAccountResponse(
        id=account.id,
        email=account.email,
        display_name=account.display_name,
        status=account.status,
        glpi_login=account.glpi_login,
        glpi_user_id=account.glpi_user_id,
        glpi_profile_name=account.glpi_profile_name,
        imap_host=account.imap_host,
        imap_username=account.imap_username,
        ingestion_enabled=account.ingestion_enabled,
        archive_subdir=account.archive_subdir,
        owner_user_id=owner.id if owner else None,
        created_at=account.created_at,
        updated_at=account.updated_at,
        message=result.message,
    )


@router.post("/collaborative", response_model=CollaborativeAccountResponse)
async def upsert_account(
    payload: CollaborativeAccountUpsertRequest,
    request: Request,
    db: Session = Depends(get_db),
):
    try:
        result = await upsert_collaborative_account(
            db,
            account_email=str(payload.account_email),
            glpi_login=payload.glpi_login,
            glpi_password=payload.glpi_password,
            display_name=payload.display_name,
            imap_host=payload.imap_host,
            imap_username=payload.imap_username,
            imap_password=payload.imap_password,
            ingestion_enabled=payload.ingestion_enabled,
            actor_ip=request.client.host if request.client else None,
            actor_user_agent=request.headers.get("user-agent"),
        )
        return _account_response(result)
    except ValueError as exc:
        raise HTTPException(status_code=400, detail=str(exc)) from exc


@router.get("/collaborative", response_model=list[CollaborativeAccountListItem])
def list_accounts(db: Session = Depends(get_db)):
    accounts = list_collaborative_accounts(db)

    return [
        CollaborativeAccountListItem(
            id=item.id,
            email=item.email,
            display_name=item.display_name,
            status=item.status,
            glpi_login=item.glpi_login,
            glpi_user_id=item.glpi_user_id,
            glpi_profile_name=item.glpi_profile_name,
            ingestion_enabled=item.ingestion_enabled,
            archive_subdir=item.archive_subdir,
            created_at=item.created_at,
            updated_at=item.updated_at,
        )
        for item in accounts
    ]
