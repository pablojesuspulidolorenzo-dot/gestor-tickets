from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session

from app.core.db import get_db
from app.schemas.glpi_tickets import (
    CreateGlpiTicketFromThreadRequest,
    CreateGlpiTicketFromThreadResponse,
    GlpiTicketCacheSummary,
)
from app.services.glpi_ticket_service import create_glpi_ticket_from_thread

router = APIRouter(tags=["glpi-tickets"])


def _ticket_schema(item: dict) -> GlpiTicketCacheSummary:
    return GlpiTicketCacheSummary(
        id=item["id"],
        glpi_ticket_id=item["glpi_ticket_id"],
        title=item.get("title"),
        status=item.get("status"),
        priority=item.get("priority"),
        urgency=item.get("urgency"),
        impact=item.get("impact"),
    )


@router.post("/from-thread/{thread_id}", response_model=CreateGlpiTicketFromThreadResponse)
def create_from_thread(
    thread_id: int,
    payload: CreateGlpiTicketFromThreadRequest,
    account_id: int,
    user_id: int | None = None,
    db: Session = Depends(get_db),
):
    try:
        result = create_glpi_ticket_from_thread(
            db,
            account_id=account_id,
            thread_id=thread_id,
            user_id=user_id,
            glpi_password=payload.glpi_password.get_secret_value(),
            title_override=payload.title,
        )

        return CreateGlpiTicketFromThreadResponse(
            ok=result.ok,
            created=result.created,
            thread_id=result.thread_id,
            glpi_ticket_cache=_ticket_schema(result.glpi_ticket_cache),
            message=result.message,
        )

    except ValueError as exc:
        raise HTTPException(status_code=400, detail=str(exc)) from exc
