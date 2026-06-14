from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session

from app.core.db import get_db
from app.schemas.mailbox import (
    ImapFolderInfo,
    MailboxFoldersResponse,
    MailboxPreviewMessage,
    MailboxPreviewResponse,
)
from app.services.mailbox_preview_service import (
    FOLDER_SAFETY_NOTES,
    SAFETY_NOTES,
    list_collaborative_imap_folders,
    preview_collaborative_mailbox,
)

router = APIRouter(tags=["mailbox"])


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
            messages=[
                MailboxPreviewMessage(
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
                )
                for item in preview.messages
            ],
            safety_notes=SAFETY_NOTES,
        )

    except ValueError as exc:
        raise HTTPException(status_code=400, detail=str(exc)) from exc
