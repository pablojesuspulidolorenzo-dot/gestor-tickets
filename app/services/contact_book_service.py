from __future__ import annotations

from sqlalchemy import text
from sqlalchemy.orm import Session


def upsert_contact(
    db: Session,
    *,
    account_id: int,
    email: str,
    name: str | None = None,
    phone: str | None = None,
    company: str | None = None,
    source: str = "ai_detected",
) -> dict:
    """
    Inserta o actualiza un contacto. Solo sobreescribe campos no vacíos y
    nunca degrada datos introducidos manualmente (source='manual').
    """
    row = db.execute(
        text("""
            INSERT INTO gestor_tickets.contact_book
                (account_id, email, name, phone, company, source, last_seen_at)
            VALUES (:account_id, :email, :name, :phone, :company, :source, now())
            ON CONFLICT (account_id, email) DO UPDATE SET
                name = CASE
                    WHEN :name IS NOT NULL AND :name <> ''
                         AND (gestor_tickets.contact_book.name IS NULL
                              OR gestor_tickets.contact_book.source <> 'manual')
                    THEN :name
                    ELSE gestor_tickets.contact_book.name
                END,
                phone = CASE
                    WHEN :phone IS NOT NULL AND :phone <> ''
                         AND (gestor_tickets.contact_book.phone IS NULL
                              OR gestor_tickets.contact_book.source <> 'manual')
                    THEN :phone
                    ELSE gestor_tickets.contact_book.phone
                END,
                company = CASE
                    WHEN :company IS NOT NULL AND :company <> ''
                         AND (gestor_tickets.contact_book.company IS NULL
                              OR gestor_tickets.contact_book.source <> 'manual')
                    THEN :company
                    ELSE gestor_tickets.contact_book.company
                END,
                last_seen_at = now(),
                updated_at   = now()
            RETURNING id, account_id, email::text, name, phone, company,
                      source, last_seen_at, created_at, updated_at
        """),
        {
            "account_id": account_id,
            "email": email,
            "name": (name or "").strip() or None,
            "phone": (phone or "").strip() or None,
            "company": (company or "").strip() or None,
            "source": source,
        },
    ).mappings().first()
    db.commit()
    return dict(row) if row else {}


def list_contacts(
    db: Session,
    *,
    account_id: int,
    search: str | None = None,
    limit: int = 200,
) -> list[dict]:
    if search:
        rows = db.execute(
            text("""
                SELECT id, account_id, email::text, name, phone, company,
                       source, last_seen_at, created_at, updated_at
                FROM gestor_tickets.contact_book
                WHERE account_id = :account_id
                  AND (email ILIKE :q OR name ILIKE :q OR company ILIKE :q
                       OR phone ILIKE :q)
                ORDER BY last_seen_at DESC NULLS LAST, id DESC
                LIMIT :limit
            """),
            {"account_id": account_id, "q": f"%{search}%", "limit": limit},
        ).mappings().all()
    else:
        rows = db.execute(
            text("""
                SELECT id, account_id, email::text, name, phone, company,
                       source, last_seen_at, created_at, updated_at
                FROM gestor_tickets.contact_book
                WHERE account_id = :account_id
                ORDER BY last_seen_at DESC NULLS LAST, id DESC
                LIMIT :limit
            """),
            {"account_id": account_id, "limit": limit},
        ).mappings().all()
    return [dict(r) for r in rows]


def get_contact_by_email(
    db: Session,
    *,
    account_id: int,
    email: str,
) -> dict | None:
    row = db.execute(
        text("""
            SELECT id, account_id, email::text, name, phone, company,
                   source, last_seen_at, created_at, updated_at
            FROM gestor_tickets.contact_book
            WHERE account_id = :account_id AND email = :email
        """),
        {"account_id": account_id, "email": email},
    ).mappings().first()
    return dict(row) if row else None


def delete_contact(db: Session, *, contact_id: int, account_id: int) -> bool:
    result = db.execute(
        text("""
            DELETE FROM gestor_tickets.contact_book
            WHERE id = :id AND account_id = :account_id
        """),
        {"id": contact_id, "account_id": account_id},
    )
    db.commit()
    return bool(result.rowcount)
