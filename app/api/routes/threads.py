from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session

from app.core.db import get_db
from app.schemas.threads import ThreadFromEmailResponse, ThreadListResponse, ThreadSummary
from app.services.thread_service import create_thread_from_email, list_system_threads

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
