from typing import Any

from sqlalchemy.orm import Session

from app.models import AuditLog


def create_audit_log(
    db: Session,
    *,
    action: str,
    entity_type: str,
    entity_id: str | int | None = None,
    account_id: int | None = None,
    actor_user_id: int | None = None,
    actor_login_identifier: str | None = None,
    before: dict[str, Any] | None = None,
    after: dict[str, Any] | None = None,
    ip_address: str | None = None,
    user_agent: str | None = None,
    commit: bool = False,
) -> AuditLog:
    """
    Registra una acción relevante del sistema.

    No usa triggers. La aplicación decide explícitamente cuándo auditar.
    """
    item = AuditLog(
        account_id=account_id,
        actor_user_id=actor_user_id,
        actor_login_identifier=actor_login_identifier,
        action=action,
        entity_type=entity_type,
        entity_id=str(entity_id) if entity_id is not None else None,
        before_json=before,
        after_json=after,
        ip_address=ip_address,
        user_agent=user_agent,
    )

    db.add(item)
    db.flush()

    if commit:
        db.commit()
        db.refresh(item)

    return item
