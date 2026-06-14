from __future__ import annotations

from datetime import datetime, timedelta, timezone

from sqlalchemy import text

from app.core.db import SessionLocal
from app.services.mail_ingestion_service import _apply_auth_failure_policy


AUTH_EXCEPTION = Exception("AUTHENTICATIONFAILED invalid credentials")


def _one(db, query: str, params: dict | None = None) -> dict:
    row = db.execute(text(query), params or {}).mappings().first()
    if not row:
        raise RuntimeError("No se encontró el registro requerido para el diagnóstico.")
    return dict(row)


def _job(db, job_id: int) -> dict:
    return _one(
        db,
        """
        SELECT
            id,
            account_id,
            status::text AS status,
            next_run_at,
            auth_failure_count,
            last_error_message
        FROM gestor_tickets.mail_ingestion_jobs
        WHERE id = :job_id
        """,
        {"job_id": job_id},
    )


def _account(db, account_id: int) -> dict:
    return _one(
        db,
        """
        SELECT
            id,
            status::text AS status,
            ingestion_enabled
        FROM gestor_tickets.collaborative_accounts
        WHERE id = :account_id
        """,
        {"account_id": account_id},
    )


def _active_job(db) -> dict:
    return _one(
        db,
        """
        SELECT
            id,
            account_id,
            status::text AS status,
            next_run_at,
            auth_failure_count,
            last_error_message
        FROM gestor_tickets.mail_ingestion_jobs
        ORDER BY id
        LIMIT 1
        """,
    )


def _restore(db, *, job_id: int, account_id: int, next_run_at=None) -> None:
    db.execute(
        text("""
            UPDATE gestor_tickets.mail_ingestion_jobs
            SET status = 'active',
                auth_failure_count = 0,
                last_error_message = NULL,
                next_run_at = COALESCE(:next_run_at, now()),
                updated_at = now()
            WHERE id = :job_id
        """),
        {"job_id": job_id, "next_run_at": next_run_at},
    )
    db.execute(
        text("""
            UPDATE gestor_tickets.collaborative_accounts
            SET status = 'active',
                ingestion_enabled = true,
                updated_at = now()
            WHERE id = :account_id
        """),
        {"account_id": account_id},
    )
    db.commit()


def _assert_first_failure(job: dict) -> None:
    if job["status"] != "active":
        raise AssertionError(f"Primer fallo: status esperado active, obtenido {job['status']}")
    if int(job["auth_failure_count"] or 0) != 1:
        raise AssertionError(f"Primer fallo: auth_failure_count esperado 1, obtenido {job['auth_failure_count']}")
    next_run_at = job["next_run_at"]
    if next_run_at is None:
        raise AssertionError("Primer fallo: next_run_at no puede ser NULL.")
    now = datetime.now(timezone.utc)
    delta = next_run_at.astimezone(timezone.utc) - now
    if not timedelta(seconds=30) <= delta <= timedelta(minutes=3):
        raise AssertionError(f"Primer fallo: next_run_at fuera de ventana esperada: {next_run_at}")


def _assert_second_failure(job: dict, account: dict) -> None:
    if job["status"] != "error_auth":
        raise AssertionError(f"Segundo fallo: status esperado error_auth, obtenido {job['status']}")
    if int(job["auth_failure_count"] or 0) != 2:
        raise AssertionError(f"Segundo fallo: auth_failure_count esperado 2, obtenido {job['auth_failure_count']}")
    if job["next_run_at"] is not None:
        raise AssertionError("Segundo fallo: next_run_at debe ser NULL.")
    if account["status"] != "error_auth":
        raise AssertionError(f"Segundo fallo: cuenta esperada error_auth, obtenida {account['status']}")
    if bool(account["ingestion_enabled"]):
        raise AssertionError("Segundo fallo: ingestion_enabled debe ser false.")


def main() -> None:
    db = SessionLocal()
    job_id = None
    account_id = None
    original_next_run_at = None

    try:
        initial_job = _active_job(db)
        job_id = int(initial_job["id"])
        account_id = int(initial_job["account_id"])
        original_next_run_at = initial_job["next_run_at"]

        _restore(db, job_id=job_id, account_id=account_id, next_run_at=original_next_run_at)

        _apply_auth_failure_policy(db, job=_job(db, job_id), exc=AUTH_EXCEPTION)
        first_job = _job(db, job_id)
        _assert_first_failure(first_job)
        print("FIRST_FAILURE_OK", first_job["status"], first_job["auth_failure_count"], first_job["next_run_at"])

        _apply_auth_failure_policy(db, job=first_job, exc=AUTH_EXCEPTION)
        second_job = _job(db, job_id)
        second_account = _account(db, account_id)
        _assert_second_failure(second_job, second_account)
        print("SECOND_FAILURE_OK", second_job["status"], second_job["auth_failure_count"], second_account["status"])

    finally:
        if job_id is not None and account_id is not None:
            _restore(db, job_id=job_id, account_id=account_id, next_run_at=original_next_run_at)
            final_job = _job(db, job_id)
            final_account = _account(db, account_id)
            print(
                "RESTORED_OK",
                final_job["status"],
                final_job["auth_failure_count"],
                final_job["last_error_message"],
                final_account["status"],
                final_account["ingestion_enabled"],
            )
        db.close()


if __name__ == "__main__":
    main()
