from __future__ import annotations

import asyncio
from datetime import datetime
from typing import Any

from sqlalchemy import text

from app.core.config import settings
from app.core.db import SessionLocal
from app.services.mail_ingestion_service import run_due_mail_ingestion_jobs


ADVISORY_LOCK_ID = 27027024

_scheduler_task: asyncio.Task | None = None
_stop_event: asyncio.Event | None = None

_state: dict[str, Any] = {
    "enabled": False,
    "running": False,
    "last_cycle_started_at": None,
    "last_cycle_finished_at": None,
    "last_success_at": None,
    "last_error_at": None,
    "last_error_message": None,
    "last_due_jobs_executed": 0,
    "last_runs": [],
}


def _interval_seconds() -> int:
    return max(5, min(int(settings.MAIL_INGESTION_SCHEDULER_INTERVAL_SECONDS), 3600))


def _scheduler_enabled() -> bool:
    return bool(settings.MAIL_INGESTION_SCHEDULER_ENABLED)


def _safe_error_message(exc: Exception) -> str:
    message = str(exc).replace("\n", " ").strip()
    if len(message) > 300:
        message = message[:297] + "..."
    return f"{type(exc).__name__}: {message}"


def get_mail_ingestion_scheduler_state() -> dict[str, Any]:
    task_running = _scheduler_task is not None and not _scheduler_task.done()

    return {
        **_state,
        "enabled": _scheduler_enabled(),
        "interval_seconds": _interval_seconds(),
        "task_running": task_running,
        "advisory_lock_id": ADVISORY_LOCK_ID,
    }


def _run_due_jobs_with_lock_sync() -> list[dict[str, Any]]:
    db = SessionLocal()
    locked = False

    try:
        locked = bool(
            db.execute(
                text("select pg_try_advisory_lock(:lock_id)"),
                {"lock_id": ADVISORY_LOCK_ID},
            ).scalar()
        )

        if not locked:
            return []

        results = run_due_mail_ingestion_jobs(db)

        return [
            {
                "job_id": int(job["id"]),
                "account_id": int(job["account_id"]),
                "run_id": int(run["id"]),
                "run_status": run["status"],
                "imported_count": int(run["imported_count"]),
                "duplicate_count": int(run["duplicate_count"]),
                "error_count": int(run["error_count"]),
            }
            for job, run in results
        ]

    finally:
        if locked:
            try:
                db.execute(
                    text("select pg_advisory_unlock(:lock_id)"),
                    {"lock_id": ADVISORY_LOCK_ID},
                )
                db.commit()
            except Exception:
                db.rollback()

        db.close()


async def _scheduler_loop() -> None:
    global _state

    assert _stop_event is not None

    while not _stop_event.is_set():
        if not _scheduler_enabled():
            _state["enabled"] = False
            _state["running"] = False

            try:
                await asyncio.wait_for(_stop_event.wait(), timeout=_interval_seconds())
            except asyncio.TimeoutError:
                pass

            continue

        _state["enabled"] = True
        _state["running"] = True
        _state["last_cycle_started_at"] = datetime.now().isoformat(timespec="seconds")

        try:
            runs = await asyncio.to_thread(_run_due_jobs_with_lock_sync)

            _state["last_due_jobs_executed"] = len(runs)
            _state["last_runs"] = runs
            _state["last_success_at"] = datetime.now().isoformat(timespec="seconds")
            _state["last_error_message"] = None

        except Exception as exc:
            _state["last_error_at"] = datetime.now().isoformat(timespec="seconds")
            _state["last_error_message"] = _safe_error_message(exc)
            print("[mail-ingestion-scheduler] ERROR:", _state["last_error_message"], flush=True)
            if settings.APP_ENV.lower() == "development":
                import traceback

                traceback.print_exc()

        finally:
            _state["running"] = False
            _state["last_cycle_finished_at"] = datetime.now().isoformat(timespec="seconds")

        try:
            await asyncio.wait_for(_stop_event.wait(), timeout=_interval_seconds())
        except asyncio.TimeoutError:
            pass


def start_mail_ingestion_scheduler() -> None:
    global _scheduler_task, _stop_event

    if _scheduler_task is not None and not _scheduler_task.done():
        return

    _stop_event = asyncio.Event()
    _scheduler_task = asyncio.create_task(_scheduler_loop())


async def stop_mail_ingestion_scheduler() -> None:
    global _scheduler_task, _stop_event

    if _stop_event is not None:
        _stop_event.set()

    if _scheduler_task is not None:
        try:
            await asyncio.wait_for(_scheduler_task, timeout=15)
        except asyncio.TimeoutError:
            _scheduler_task.cancel()

    _scheduler_task = None
    _stop_event = None
