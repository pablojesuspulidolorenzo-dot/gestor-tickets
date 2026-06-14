from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session

from app.core.db import get_db
from app.schemas.glpi_tickets import (
    CreateGlpiTicketFromThreadRequest,
    CreateGlpiTicketFromThreadResponse,
    GlpiTicketCacheSummary,
    GlpiTicketDetailResponse,
    GlpiTicketLinkedEmail,
    GlpiTicketLinkedThread,
    GlpiTicketListItem,
    GlpiTicketListResponse,
    RefreshGlpiTicketRequest,
    RefreshGlpiTicketResponse,
)
from app.services.glpi_ticket_service import (
    create_glpi_ticket_from_thread,
    get_glpi_ticket_detail,
    list_glpi_ticket_cache,
    refresh_glpi_ticket_cache,
)

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


def _ticket_list_item(item: dict) -> GlpiTicketListItem:
    return GlpiTicketListItem(
        id=item["id"],
        account_id=item["account_id"],
        glpi_instance_id=item["glpi_instance_id"],
        glpi_ticket_id=item["glpi_ticket_id"],
        title=item.get("title"),
        status=item.get("status"),
        priority=item.get("priority"),
        urgency=item.get("urgency"),
        impact=item.get("impact"),
        thread_count=item["thread_count"],
        email_count=item["email_count"],
        last_sync_at=item.get("last_sync_at"),
        updated_at=item["updated_at"],
    )


@router.get("/", response_model=GlpiTicketListResponse)
def list_tickets(
    account_id: int,
    db: Session = Depends(get_db),
):
    tickets = list_glpi_ticket_cache(db, account_id=account_id)

    return GlpiTicketListResponse(
        ok=True,
        account_id=account_id,
        tickets=[_ticket_list_item(item) for item in tickets],
    )


@router.get("/cache/{ticket_cache_id}", response_model=GlpiTicketDetailResponse)
def ticket_detail(
    ticket_cache_id: int,
    account_id: int,
    db: Session = Depends(get_db),
):
    try:
        ticket, threads, emails = get_glpi_ticket_detail(
            db,
            account_id=account_id,
            ticket_cache_id=ticket_cache_id,
        )

        return GlpiTicketDetailResponse(
            ok=True,
            ticket=_ticket_list_item(ticket),
            threads=[
                GlpiTicketLinkedThread(
                    link_id=item["link_id"],
                    thread_id=item["thread_id"],
                    thread_title=item.get("thread_title"),
                    thread_status=item.get("thread_status"),
                    origin=item.get("origin"),
                    created_at=item["created_at"],
                )
                for item in threads
            ],
            emails=[
                GlpiTicketLinkedEmail(
                    link_id=item["link_id"],
                    email_message_id=item["email_message_id"],
                    subject=item.get("subject"),
                    from_email=item.get("from_email"),
                    sent_at=item.get("sent_at"),
                    origin=item.get("origin"),
                    created_at=item["created_at"],
                )
                for item in emails
            ],
        )

    except ValueError as exc:
        raise HTTPException(status_code=404, detail=str(exc)) from exc


@router.post("/cache/{ticket_cache_id}/refresh", response_model=RefreshGlpiTicketResponse)
def refresh_ticket(
    ticket_cache_id: int,
    payload: RefreshGlpiTicketRequest,
    account_id: int,
    user_id: int | None = None,
    db: Session = Depends(get_db),
):
    try:
        ticket = refresh_glpi_ticket_cache(
            db,
            account_id=account_id,
            ticket_cache_id=ticket_cache_id,
            user_id=user_id,
            glpi_password=payload.glpi_password.get_secret_value(),
        )

        return RefreshGlpiTicketResponse(
            ok=True,
            ticket=_ticket_list_item(ticket),
            message="Ticket GLPI refrescado correctamente desde la API.",
        )

    except ValueError as exc:
        raise HTTPException(status_code=400, detail=str(exc)) from exc


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
