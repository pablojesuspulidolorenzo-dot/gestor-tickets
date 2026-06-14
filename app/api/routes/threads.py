from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session

from app.core.db import get_db
from app.schemas.threads import (
    ThreadDetailResponse,
    ThreadFromEmailResponse,
    ThreadListResponse,
    ThreadMessageSummary,
    ThreadSummary,
)
from app.services.thread_service import (
    create_thread_from_email,
    get_thread_detail,
    list_system_threads,
)

router = APIRouter(tags=["threads"])


def _thread_schema(item: dict) -> ThreadSummary:
    return ThreadSummary(
        id=item["id"],
        system_thread_uid=item["system_thread_uid"],
        account_id=item["account_id"],
        title=item.get("title"),
        subject_normalized=item.get("subject_normalized"),
        status=item["status"],
        message_count=item["message_count"],
        last_message_at=item.get("last_message_at"),
        updated_at=item["updated_at"],
    )


def _message_schema(item: dict) -> ThreadMessageSummary:
    return ThreadMessageSummary(
        member_id=item["member_id"],
        email_message_id=item["email_message_id"],
        position_asc=item["position_asc"],
        subject=item.get("subject"),
        from_email=item.get("from_email"),
        from_name=item.get("from_name"),
        direction=item.get("direction"),
        sent_at=item.get("sent_at"),
        original_imap_folder=item.get("original_imap_folder"),
        original_imap_uid=item.get("original_imap_uid"),
        body_text_preview=item.get("body_text_preview"),
    )


@router.get("/", response_model=ThreadListResponse)
def list_threads(
    account_id: int,
    db: Session = Depends(get_db),
):
    threads = list_system_threads(db, account_id=account_id)

    return ThreadListResponse(
        ok=True,
        account_id=account_id,
        threads=[_thread_schema(item) for item in threads],
    )


@router.post("/from-email/{email_message_id}", response_model=ThreadFromEmailResponse)
def create_from_email(
    email_message_id: int,
    account_id: int,
    user_id: int | None = None,
    db: Session = Depends(get_db),
):
    try:
        thread, created = create_thread_from_email(
            db,
            account_id=account_id,
            email_message_id=email_message_id,
            created_by_user_id=user_id,
        )

        return ThreadFromEmailResponse(
            ok=True,
            created=created,
            email_message_id=email_message_id,
            thread=_thread_schema(thread),
            message=(
                "Hilo operativo creado correctamente."
                if created
                else "El correo ya pertenecía a un hilo activo."
            ),
        )

    except ValueError as exc:
        raise HTTPException(status_code=400, detail=str(exc)) from exc


@router.get("/{thread_id}", response_model=ThreadDetailResponse)
def thread_detail(
    thread_id: int,
    account_id: int,
    db: Session = Depends(get_db),
):
    try:
        thread, messages = get_thread_detail(
            db,
            account_id=account_id,
            thread_id=thread_id,
        )

        return ThreadDetailResponse(
            ok=True,
            thread=_thread_schema(thread),
            messages=[_message_schema(item) for item in messages],
        )

    except ValueError as exc:
        raise HTTPException(status_code=404, detail=str(exc)) from exc
