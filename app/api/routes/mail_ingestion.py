from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session

from app.core.db import get_db
from app.schemas.mail_ingestion import (
    ConfigureMailIngestionJobRequest,
    ConfigureMailIngestionJobResponse,
    MailIngestionJobListResponse,
    MailIngestionJobSummary,
    MailIngestionRunResponse,
    MailIngestionRunSummary,
)
from app.services.mail_ingestion_service import (
    configure_mail_ingestion_job,
    list_mail_ingestion_jobs,
    run_due_mail_ingestion_jobs,
    run_mail_ingestion_job,
)

router = APIRouter(tags=["mail-ingestion"])


def _job_schema(item: dict) -> MailIngestionJobSummary:
    return MailIngestionJobSummary(**item)


def _run_schema(item: dict) -> MailIngestionRunSummary:
    return MailIngestionRunSummary(**item)


@router.get("/jobs", response_model=MailIngestionJobListResponse)
def list_jobs(
    account_id: int | None = None,
    db: Session = Depends(get_db),
):
    jobs = list_mail_ingestion_jobs(db, account_id=account_id)
    return MailIngestionJobListResponse(
        ok=True,
        jobs=[_job_schema(item) for item in jobs],
    )


@router.post("/jobs/configure", response_model=ConfigureMailIngestionJobResponse)
def configure_job(
    payload: ConfigureMailIngestionJobRequest,
    user_id: int | None = None,
    db: Session = Depends(get_db),
):
    try:
        job = configure_mail_ingestion_job(
            db,
            account_id=payload.account_id,
            user_id=user_id,
            status=payload.status,
            scan_inbox=payload.scan_inbox,
            scan_sent=payload.scan_sent,
            inbox_folder_name=payload.inbox_folder_name,
            sent_folder_name=payload.sent_folder_name,
            interval_minutes=payload.interval_minutes,
            max_messages_per_folder=payload.max_messages_per_folder,
        )
        return ConfigureMailIngestionJobResponse(
            ok=True,
            job=_job_schema(job),
            message="Job de ingesta configurado correctamente.",
        )
    except ValueError as exc:
        raise HTTPException(status_code=400, detail=str(exc)) from exc


@router.post("/jobs/{job_id}/run-now", response_model=MailIngestionRunResponse)
def run_job_now(
    job_id: int,
    user_id: int | None = None,
    db: Session = Depends(get_db),
):
    try:
        job, run = run_mail_ingestion_job(
            db,
            job_id=job_id,
            user_id=user_id,
        )
        return MailIngestionRunResponse(
            ok=True,
            job=_job_schema(job),
            run=_run_schema(run),
            message="Ingesta ejecutada correctamente.",
        )
    except ValueError as exc:
        raise HTTPException(status_code=400, detail=str(exc)) from exc


@router.post("/jobs/run-due")
def run_due_jobs(
    db: Session = Depends(get_db),
):
    results = run_due_mail_ingestion_jobs(db)
    return {
        "ok": True,
        "runs": [
            {
                "job": _job_schema(job).model_dump(),
                "run": _run_schema(run).model_dump(),
            }
            for job, run in results
        ],
    }
