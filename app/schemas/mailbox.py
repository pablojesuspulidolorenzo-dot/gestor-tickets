from pydantic import BaseModel


class ImapFolderInfo(BaseModel):
    name: str
    delimiter: str | None
    flags: list[str]
    is_inbox: bool
    is_sent_candidate: bool


class MailboxFoldersResponse(BaseModel):
    ok: bool
    account_id: int
    account_email: str
    folders: list[ImapFolderInfo]
    detected_inbox: str | None
    sent_candidates: list[str]
    safety_notes: list[str]


class MailboxPreviewMessage(BaseModel):
    uid: str
    message_id: str | None
    subject: str
    from_: str
    to: str | None
    cc: str | None
    date: str | None
    flags: list[str]
    seen: bool
    answered: bool
    has_references: bool


class MailboxPreviewResponse(BaseModel):
    ok: bool
    account_id: int
    account_email: str
    mailbox: str
    readonly_mode: bool
    total_messages: int | None
    returned_messages: int
    messages: list[MailboxPreviewMessage]
    safety_notes: list[str]
