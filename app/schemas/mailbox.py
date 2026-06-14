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
    mailbox: str
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
    direction: str


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


class UnifiedMailboxPreviewResponse(BaseModel):
    ok: bool
    account_id: int
    account_email: str
    mailboxes: list[str]
    readonly_mode: bool
    total_messages_by_mailbox: dict[str, int | None]
    returned_messages: int
    messages: list[MailboxPreviewMessage]
    safety_notes: list[str]


class MailboxMessageDetailResponse(BaseModel):
    ok: bool
    account_id: int
    account_email: str
    mailbox: str
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
    text_body: str | None
    sanitized_html_body: str | None
    blocked_active_content: bool
    readonly_mode: bool
    safety_notes: list[str]


class ArchivedEmailResponse(BaseModel):
    ok: bool
    account_id: int
    account_email: str
    email_message_id: int
    occurrence_id: int
    mailbox: str
    uid: str
    message_id: str | None
    subject: str | None
    eml_storage_path: str
    eml_sha256: str
    size_bytes: int
    seen_before: bool
    seen_after: bool
    safety_notes: list[str]
    message: str
