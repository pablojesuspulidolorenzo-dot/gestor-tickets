"""
Servicio unificado para filtros de bandeja, estado de espera,
presencia colaborativa y modo operador.
Todas las migraciones son aditivas (ADD COLUMN/CREATE TABLE IF NOT EXISTS).
"""
from __future__ import annotations

import datetime as dt

from sqlalchemy import text
from sqlalchemy.orm import Session

FILTER_LABELS: dict[str, str] = {
    "pending": "Pendientes",
    "personal": "→ Personal",
    "account": "→ Cuenta",
    "active": "Activos",
    "all": "Todos",
    "waiting": "⏳ En espera",
}

VALID_FILTERS = set(FILTER_LABELS.keys())
PRESENCE_TTL = 120  # segundos


# ─── Migraciones seguras ──────────────────────────────────────────────────────

def ensure_migrations(db: Session) -> None:
    """Crea columnas y tablas necesarias. Completamente idempotente."""
    db.execute(text("""
        ALTER TABLE gestor_tickets.system_threads
          ADD COLUMN IF NOT EXISTS is_waiting   BOOLEAN     NOT NULL DEFAULT false,
          ADD COLUMN IF NOT EXISTS waiting_until TIMESTAMPTZ,
          ADD COLUMN IF NOT EXISTS waiting_reason TEXT;
    """))

    db.execute(text("""
        CREATE TABLE IF NOT EXISTS gestor_tickets.thread_viewer_presence (
          thread_id    BIGINT NOT NULL
            REFERENCES gestor_tickets.system_threads(id) ON DELETE CASCADE,
          user_id      BIGINT NOT NULL
            REFERENCES gestor_tickets.account_users(id)  ON DELETE CASCADE,
          account_id   BIGINT      NOT NULL,
          display_name TEXT        NOT NULL,
          last_ping_at TIMESTAMPTZ NOT NULL DEFAULT now(),
          CONSTRAINT pk_thread_viewer_presence PRIMARY KEY (thread_id, user_id)
        );
    """))
    db.execute(text("""
        CREATE INDEX IF NOT EXISTS ix_tvp_thread_ping
          ON gestor_tickets.thread_viewer_presence (thread_id, last_ping_at DESC);
    """))

    db.execute(text("""
        CREATE TABLE IF NOT EXISTS gestor_tickets.operator_queue_claims (
          id          BIGSERIAL   PRIMARY KEY,
          thread_id   BIGINT      NOT NULL
            REFERENCES gestor_tickets.system_threads(id) ON DELETE CASCADE,
          user_id     BIGINT      NOT NULL
            REFERENCES gestor_tickets.account_users(id)  ON DELETE CASCADE,
          account_id  BIGINT      NOT NULL,
          claimed_at  TIMESTAMPTZ NOT NULL DEFAULT now(),
          released_at TIMESTAMPTZ
        );
    """))
    db.execute(text("""
        CREATE UNIQUE INDEX IF NOT EXISTS uq_operator_active_thread
          ON gestor_tickets.operator_queue_claims (thread_id)
          WHERE released_at IS NULL;
    """))

    db.commit()


# ─── Filtros + listado de hilos ───────────────────────────────────────────────

def _filter_where(filter_key: str) -> str:
    base = "st.account_id = :account_id"
    active_not_waiting = (
        f"{base} AND st.status = 'active' "
        "AND (st.is_waiting = false OR st.is_waiting IS NULL)"
    )
    if filter_key == "pending":
        return active_not_waiting
    if filter_key == "personal":
        return (
            active_not_waiting
            + " AND le.destinatario_tipo = 'usuario_personal'"
        )
    if filter_key == "account":
        return (
            active_not_waiting
            + " AND le.destinatario_tipo = 'cuenta_colaborativa'"
        )
    if filter_key == "active":
        return f"{base} AND st.status = 'active'"
    if filter_key == "waiting":
        return f"{base} AND st.is_waiting = true"
    return base  # "all"


_BASE_CTES = """
    last_email AS (
        SELECT DISTINCT ON (etm.thread_id)
            etm.thread_id,
            em.direction::text              AS direction,
            eap.destinatario_tipo::text     AS destinatario_tipo,
            eap.urgencia_atencion::text     AS urgencia
        FROM gestor_tickets.email_thread_members etm
        JOIN  gestor_tickets.email_messages em
              ON em.id = etm.email_message_id
        LEFT JOIN gestor_tickets.email_ai_processing eap
              ON eap.email_message_id = em.id AND eap.status = 'processed'
        WHERE etm.status = 'active'
        ORDER BY etm.thread_id, em.sent_at DESC NULLS LAST, em.id DESC
    ),
    thread_msgs AS (
        SELECT etm2.thread_id,
               COUNT(*)::int        AS message_count,
               MAX(em2.sent_at)     AS last_message_at
        FROM gestor_tickets.email_thread_members etm2
        JOIN gestor_tickets.email_messages em2 ON em2.id = etm2.email_message_id
        WHERE etm2.status = 'active'
        GROUP BY etm2.thread_id
    )
"""


def list_threads_filtered(
    db: Session,
    *,
    account_id: int,
    user_id: int,
    filter_key: str = "pending",
    page: int = 1,
    page_size: int = 25,
) -> tuple[list[dict], int]:
    """
    Devuelve (threads, total_count) con filtrado SQL real y paginación.
    Incluye: is_waiting, waiting_until, last_direction, last_destinatario_tipo,
             others_viewing (otros colaboradores activos en el hilo),
             operator_claimed_by (user_id del técnico que tiene el claim).
    """
    if filter_key not in VALID_FILTERS:
        filter_key = "pending"

    where = _filter_where(filter_key)
    offset = (page - 1) * page_size

    presence_ttl = PRESENCE_TTL

    rows = db.execute(text(f"""
        WITH {_BASE_CTES},
        presence AS (
            SELECT thread_id,
                   COUNT(*) FILTER (WHERE user_id != :user_id)::int AS others
            FROM gestor_tickets.thread_viewer_presence
            WHERE account_id = :account_id
              AND last_ping_at > now() - interval '{presence_ttl} seconds'
            GROUP BY thread_id
        ),
        op_claim AS (
            SELECT thread_id, user_id AS claimed_by
            FROM gestor_tickets.operator_queue_claims
            WHERE account_id = :account_id AND released_at IS NULL
        )
        SELECT
            st.id,
            st.system_thread_uid::text  AS system_thread_uid,
            st.account_id,
            st.title,
            st.subject_normalized,
            st.status::text             AS status,
            st.is_waiting,
            st.waiting_until,
            st.waiting_reason,
            st.updated_at,
            st.created_at,
            COALESCE(tm.message_count, 0)   AS message_count,
            tm.last_message_at,
            le.direction                AS last_direction,
            le.destinatario_tipo        AS last_destinatario_tipo,
            le.urgencia                 AS last_urgencia,
            COALESCE(pr.others, 0)      AS others_viewing,
            oc.claimed_by               AS operator_claimed_by
        FROM gestor_tickets.system_threads st
        LEFT JOIN last_email  le ON le.thread_id = st.id
        LEFT JOIN thread_msgs tm ON tm.thread_id = st.id
        LEFT JOIN presence    pr ON pr.thread_id = st.id
        LEFT JOIN op_claim    oc ON oc.thread_id = st.id
        WHERE {where}
        ORDER BY COALESCE(tm.last_message_at, st.updated_at) DESC NULLS LAST, st.id DESC
        LIMIT :limit OFFSET :offset
    """), {"account_id": account_id, "user_id": user_id,
           "limit": page_size, "offset": offset}).mappings().all()

    total = db.execute(text(f"""
        WITH last_email AS (
            SELECT DISTINCT ON (etm.thread_id)
                etm.thread_id,
                eap.destinatario_tipo::text AS destinatario_tipo
            FROM gestor_tickets.email_thread_members etm
            JOIN  gestor_tickets.email_messages em ON em.id = etm.email_message_id
            LEFT JOIN gestor_tickets.email_ai_processing eap
                  ON eap.email_message_id = em.id AND eap.status = 'processed'
            WHERE etm.status = 'active'
            ORDER BY etm.thread_id, em.sent_at DESC NULLS LAST, em.id DESC
        )
        SELECT COUNT(*)
        FROM gestor_tickets.system_threads st
        LEFT JOIN last_email le ON le.thread_id = st.id
        WHERE {where}
    """), {"account_id": account_id, "user_id": user_id}).scalar_one()

    return [dict(r) for r in rows], int(total)


# ─── Estado de espera ─────────────────────────────────────────────────────────

def set_thread_waiting(
    db: Session,
    *,
    thread_id: int,
    account_id: int,
    waiting_until: dt.datetime | None = None,
    reason: str | None = None,
) -> None:
    db.execute(text("""
        UPDATE gestor_tickets.system_threads
           SET is_waiting     = true,
               waiting_until  = :until,
               waiting_reason = :reason,
               updated_at     = now()
         WHERE id = :thread_id AND account_id = :account_id
    """), {"thread_id": thread_id, "account_id": account_id,
           "until": waiting_until, "reason": reason or None})
    db.commit()


def unset_thread_waiting(db: Session, *, thread_id: int, account_id: int) -> None:
    db.execute(text("""
        UPDATE gestor_tickets.system_threads
           SET is_waiting     = false,
               waiting_until  = NULL,
               waiting_reason = NULL,
               updated_at     = now()
         WHERE id = :thread_id AND account_id = :account_id
    """), {"thread_id": thread_id, "account_id": account_id})
    db.commit()


def reactivate_expired_waiting(db: Session) -> int:
    """Reactiva hilos en espera cuyo waiting_until ya expiró. Llama el scheduler."""
    result = db.execute(text("""
        UPDATE gestor_tickets.system_threads
           SET is_waiting  = false,
               updated_at  = now()
         WHERE is_waiting  = true
           AND waiting_until IS NOT NULL
           AND waiting_until <= now()
        RETURNING id
    """))
    db.commit()
    return result.rowcount


# ─── Presencia colaborativa ───────────────────────────────────────────────────

_COLORS = [
    "#2563eb", "#16a34a", "#dc2626", "#d97706",
    "#7c3aed", "#0891b2", "#be123c", "#059669",
]


def _avatar_color(user_id: int) -> str:
    return _COLORS[int(user_id) % len(_COLORS)]


def _initials(name: str) -> str:
    parts = (name or "").strip().split()
    if len(parts) >= 2:
        return (parts[0][0] + parts[-1][0]).upper()
    return (name[:2] if name else "??").upper()


def ping_presence(
    db: Session,
    *,
    thread_id: int,
    user_id: int,
    account_id: int,
    display_name: str,
) -> None:
    """Registra que el usuario está viendo este hilo. Limpia su presencia en otros hilos."""
    db.execute(text("""
        DELETE FROM gestor_tickets.thread_viewer_presence
         WHERE user_id = :user_id AND account_id = :account_id
           AND thread_id != :thread_id
    """), {"user_id": user_id, "account_id": account_id, "thread_id": thread_id})

    db.execute(text("""
        INSERT INTO gestor_tickets.thread_viewer_presence
            (thread_id, user_id, account_id, display_name, last_ping_at)
        VALUES (:thread_id, :user_id, :account_id, :display_name, now())
        ON CONFLICT (thread_id, user_id)
        DO UPDATE SET last_ping_at  = now(),
                      display_name  = EXCLUDED.display_name
    """), {"thread_id": thread_id, "user_id": user_id,
           "account_id": account_id, "display_name": display_name})
    db.commit()


def get_presence_others(
    db: Session,
    *,
    thread_id: int,
    account_id: int,
    exclude_user_id: int,
) -> list[dict]:
    """Devuelve los demás colaboradores viendo este hilo (ping < 2 min)."""
    rows = db.execute(text(f"""
        SELECT user_id, display_name, last_ping_at
        FROM gestor_tickets.thread_viewer_presence
        WHERE thread_id   = :thread_id
          AND account_id  = :account_id
          AND user_id    != :exclude
          AND last_ping_at > now() - interval '{PRESENCE_TTL} seconds'
        ORDER BY last_ping_at DESC
    """), {"thread_id": thread_id, "account_id": account_id,
           "exclude": exclude_user_id}).mappings().all()

    return [
        {
            "user_id": r["user_id"],
            "display_name": r["display_name"],
            "initials": _initials(r["display_name"]),
            "color": _avatar_color(r["user_id"]),
        }
        for r in rows
    ]


# ─── Modo operador ────────────────────────────────────────────────────────────

def get_my_active_claim(db: Session, *, account_id: int, user_id: int) -> int | None:
    val = db.execute(text("""
        SELECT thread_id
        FROM gestor_tickets.operator_queue_claims
        WHERE user_id = :user_id AND account_id = :account_id
          AND released_at IS NULL
        ORDER BY claimed_at DESC LIMIT 1
    """), {"user_id": user_id, "account_id": account_id}).scalar_one_or_none()
    return int(val) if val is not None else None


def release_operator_claim(db: Session, *, account_id: int, user_id: int) -> None:
    db.execute(text("""
        UPDATE gestor_tickets.operator_queue_claims
           SET released_at = now()
         WHERE user_id     = :user_id
           AND account_id  = :account_id
           AND released_at IS NULL
    """), {"user_id": user_id, "account_id": account_id})
    db.commit()


def claim_next_thread(db: Session, *, account_id: int, user_id: int) -> int | None:
    """
    Libera el claim actual del usuario y reclama el siguiente hilo pendiente sin claim.
    Usa FOR UPDATE SKIP LOCKED para evitar colisiones concurrentes.
    Devuelve thread_id reclamado, o None si la cola está vacía.
    """
    release_operator_claim(db, account_id=account_id, user_id=user_id)

    for _ in range(5):
        result = db.execute(text("""
            WITH candidate AS (
                SELECT st.id AS thread_id
                FROM gestor_tickets.system_threads st
                WHERE st.account_id = :account_id
                  AND st.status     = 'active'
                  AND (st.is_waiting = false OR st.is_waiting IS NULL)
                  AND NOT EXISTS (
                      SELECT 1 FROM gestor_tickets.operator_queue_claims oqc
                      WHERE oqc.thread_id   = st.id
                        AND oqc.released_at IS NULL
                  )
                ORDER BY st.updated_at ASC NULLS LAST, st.id ASC
                LIMIT 1
                FOR UPDATE OF st SKIP LOCKED
            )
            INSERT INTO gestor_tickets.operator_queue_claims
                (thread_id, user_id, account_id)
            SELECT thread_id, :user_id, :account_id FROM candidate
            ON CONFLICT DO NOTHING
            RETURNING thread_id
        """), {"account_id": account_id, "user_id": user_id})

        claimed = result.scalar_one_or_none()
        if claimed is not None:
            db.commit()
            return int(claimed)
        db.rollback()

    return None


def pending_unclaimed_count(db: Session, *, account_id: int) -> int:
    """Hilos pendientes sin claim activo (para mostrar en modo operador)."""
    val = db.execute(text("""
        SELECT COUNT(*)
        FROM gestor_tickets.system_threads st
        WHERE st.account_id = :account_id
          AND st.status     = 'active'
          AND (st.is_waiting = false OR st.is_waiting IS NULL)
          AND NOT EXISTS (
              SELECT 1 FROM gestor_tickets.operator_queue_claims oqc
              WHERE oqc.thread_id   = st.id
                AND oqc.released_at IS NULL
          )
    """), {"account_id": account_id}).scalar_one()
    return int(val)
