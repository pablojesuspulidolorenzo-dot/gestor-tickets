from fastapi import APIRouter, Depends, HTTPException, Request
from sqlalchemy.orm import Session

from app.core.db import get_db
from app.schemas.accounts import (
    CollaborativeAccountImapConfigRequest,
    CollaborativeAccountImapTestResponse,
    CollaborativeAccountListItem,
    CollaborativeAccountResponse,
    CollaborativeAccountUpsertRequest,
)
from app.services.account_service import (
    list_collaborative_accounts,
    upsert_collaborative_account,
)
from app.services.collaborative_imap_service import (
    configure_collaborative_account_imap,
    test_stored_collaborative_account_imap,
)

router = APIRouter(tags=["accounts"])


SAFETY_NOTES = [
    "La prueba usa EXAMINE/readonly=True.",
    "No se ejecuta FETCH.",
    "No se ejecuta STORE.",
    "No se modifican FLAGS.",
    "No se marca ningún correo como leído.",
]


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


def _imap_response(account, result, mailbox: str) -> CollaborativeAccountImapTestResponse:
    return CollaborativeAccountImapTestResponse(
        ok=result.ok,
        account_id=account.id,
        account_email=account.email,
        imap_host=account.imap_host,
        imap_port=account.imap_port,
        imap_use_ssl=account.imap_use_ssl,
        imap_username=account.imap_username,
        mailbox=mailbox,
        message_count=result.message_count,
        readonly_mode=True,
        safety_notes=SAFETY_NOTES,
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


@router.post(
    "/collaborative/{account_id}/imap/configure",
    response_model=CollaborativeAccountImapTestResponse,
)
def configure_imap(
    account_id: int,
    payload: CollaborativeAccountImapConfigRequest,
    request: Request,
    db: Session = Depends(get_db),
):
    try:
        account, result = configure_collaborative_account_imap(
            db,
            account_id=account_id,
            imap_host=payload.imap_host,
            imap_port=payload.imap_port,
            imap_use_ssl=payload.imap_use_ssl,
            imap_username=payload.imap_username,
            imap_password=payload.imap_password.get_secret_value(),
            mailbox=payload.mailbox,
            actor_login_identifier=None,
            ip_address=request.client.host if request.client else None,
            user_agent=request.headers.get("user-agent"),
        )
        return _imap_response(account, result, payload.mailbox)

    except ValueError as exc:
        raise HTTPException(status_code=400, detail=str(exc)) from exc


@router.post(
    "/collaborative/{account_id}/imap/test",
    response_model=CollaborativeAccountImapTestResponse,
)
def test_imap(
    account_id: int,
    mailbox: str = "INBOX",
    db: Session = Depends(get_db),
):
    try:
        account, result = test_stored_collaborative_account_imap(
            db,
            account_id=account_id,
            mailbox=mailbox,
        )
        return _imap_response(account, result, mailbox)

    except ValueError as exc:
        raise HTTPException(status_code=400, detail=str(exc)) from exc
