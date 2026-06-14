from fastapi import APIRouter, Depends, HTTPException, Query
from sqlalchemy.orm import Session

from app.core.db import get_db
from app.schemas.mailbox import (
    ImapFolderInfo,
    MailboxFoldersResponse,
    MailboxMessageDetailResponse,
    MailboxPreviewMessage,
    MailboxPreviewResponse,
    UnifiedMailboxPreviewResponse,
)
from app.services.mailbox_preview_service import (
    FOLDER_SAFETY_NOTES,
    SAFETY_NOTES,
    list_collaborative_imap_folders,
    preview_collaborative_mailbox,
    preview_unified_collaborative_mailbox,
)
from app.services.message_detail_service import (
    MESSAGE_DETAIL_SAFETY_NOTES,
    fetch_message_detail_readonly,
)

router = APIRouter(tags=["mailbox"])


def _message_schema(item) -> MailboxPreviewMessage:
    return MailboxPreviewMessage(
        mailbox=item.mailbox,
        uid=item.uid,
        message_id=item.message_id,
        subject=item.subject,
        from_=item.from_,
        to=item.to,
        cc=item.cc,
        date=item.date,
        flags=item.flags,
        seen=item.seen,
        answered=item.answered,
        has_references=item.has_references,
        direction=item.direction,
    )


@router.get("/folders", response_model=MailboxFoldersResponse)
def list_folders(
    account_id: int,
    db: Session = Depends(get_db),
):
    try:
        result = list_collaborative_imap_folders(db, account_id=account_id)

        return MailboxFoldersResponse(
            ok=result.ok,
            account_id=result.account.id,
            account_email=result.account.email,
            folders=[
                ImapFolderInfo(
                    name=item.name,
                    delimiter=item.delimiter,
                    flags=item.flags,
                    is_inbox=item.is_inbox,
                    is_sent_candidate=item.is_sent_candidate,
                )
                for item in result.folders
            ],
            detected_inbox=result.detected_inbox,
            sent_candidates=result.sent_candidates,
            safety_notes=FOLDER_SAFETY_NOTES,
        )

    except ValueError as exc:
        raise HTTPException(status_code=400, detail=str(exc)) from exc


@router.get("/preview", response_model=MailboxPreviewResponse)
def preview_mailbox(
    account_id: int,
    mailbox: str = "INBOX",
    limit: int = 20,
    db: Session = Depends(get_db),
):
    try:
        preview = preview_collaborative_mailbox(
            db,
            account_id=account_id,
            mailbox=mailbox,
            limit=limit,
        )

        return MailboxPreviewResponse(
            ok=preview.ok,
            account_id=preview.account.id,
            account_email=preview.account.email,
            mailbox=preview.mailbox,
            readonly_mode=True,
            total_messages=preview.total_messages,
            returned_messages=len(preview.messages),
            messages=[_message_schema(item) for item in preview.messages],
            safety_notes=SAFETY_NOTES,
        )

    except ValueError as exc:
        raise HTTPException(status_code=400, detail=str(exc)) from exc


@router.get("/unified", response_model=UnifiedMailboxPreviewResponse)
def preview_unified_mailbox(
    account_id: int,
    mailboxes: list[str] = Query(default=["INBOX", "INBOX.Sent"]),
    limit_per_mailbox: int = 20,
    total_limit: int = 50,
    db: Session = Depends(get_db),
):
    try:
        preview = preview_unified_collaborative_mailbox(
            db,
            account_id=account_id,
            mailboxes=mailboxes,
            limit_per_mailbox=limit_per_mailbox,
            total_limit=total_limit,
        )

        return UnifiedMailboxPreviewResponse(
            ok=preview.ok,
            account_id=preview.account.id,
            account_email=preview.account.email,
            mailboxes=preview.mailboxes,
            readonly_mode=True,
            total_messages_by_mailbox=preview.total_messages_by_mailbox,
            returned_messages=len(preview.messages),
            messages=[_message_schema(item) for item in preview.messages],
            safety_notes=SAFETY_NOTES,
        )

    except ValueError as exc:
        raise HTTPException(status_code=400, detail=str(exc)) from exc


@router.get("/message", response_model=MailboxMessageDetailResponse)
def message_detail(
    account_id: int,
    mailbox: str,
    uid: str,
    db: Session = Depends(get_db),
):
    try:
        detail = fetch_message_detail_readonly(
            db,
            account_id=account_id,
            mailbox=mailbox,
            uid=uid,
        )

        return MailboxMessageDetailResponse(
            ok=detail.ok,
            account_id=detail.account.id,
            account_email=detail.account.email,
            mailbox=detail.mailbox,
            uid=detail.uid,
            message_id=detail.message_id,
            subject=detail.subject,
            from_=detail.from_,
            to=detail.to,
            cc=detail.cc,
            date=detail.date,
            flags=detail.flags,
            seen=detail.seen,
            answered=detail.answered,
            text_body=detail.text_body,
            sanitized_html_body=detail.sanitized_html_body,
            blocked_active_content=detail.blocked_active_content,
            readonly_mode=True,
            safety_notes=MESSAGE_DETAIL_SAFETY_NOTES,
        )

    except ValueError as exc:
        raise HTTPException(status_code=400, detail=str(exc)) from exc
