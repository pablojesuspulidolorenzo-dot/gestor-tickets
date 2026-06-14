# Endurecimiento de producción

## Scheduler de ingesta

Variables soportadas:

- `MAIL_INGESTION_SCHEDULER_ENABLED`: activa o desactiva el scheduler.
- `MAIL_INGESTION_SCHEDULER_INTERVAL_SECONDS`: intervalo entre ciclos. La aplicación limita el valor efectivo entre 5 y 3600 segundos.

El scheduler usa advisory lock PostgreSQL `27027024` para evitar ejecuciones simultáneas entre procesos.

## Arranque de aplicación

El `Dockerfile` actual usa `uvicorn --reload` para desarrollo. Antes de producción real debe cambiarse a un arranque sin reload o a un comando gestionado por el orquestador, manteniendo la aplicación dentro de Docker.

## Endpoints internos

Los endpoints bajo `/api/accounts`, `/api/mailbox`, `/api/threads`, `/api/glpi/tickets` y `/api/mail-ingestion` requieren sesión web activa. `/api/health` queda público para monitorización local y `/api/auth` queda disponible para validación de login.

## Logs

Los errores del scheduler se registran con tipo y mensaje truncado. El traceback completo solo se imprime en `APP_ENV=development`.

No se deben escribir contraseñas, tokens, claves API ni contenido de `.env` en logs, commits o documentación.

## Backups

PostgreSQL:

```bash
docker compose exec -T postgres sh -lc 'pg_dump -U "$POSTGRES_USER" -d "$POSTGRES_DB" --schema=gestor_tickets --format=custom' > backup_gestor_tickets.dump
```

Archivo de correos `.eml`:

```bash
tar -C ../docker-data -czf mail_archive_backup.tgz mail_archive
```

Antes de restaurar en otro entorno, confirmar rutas de volúmenes y permisos del usuario de la aplicación.

## Retención

No borrar `.eml` archivados ni purgar historial de `mail_ingestion_runs`, `glpi_api_operations` o `personal_message_transfer_log` sin confirmación explícita.

La ingesta y transferencia deben mantener readonly, `BODY.PEEK`, sin `STORE` y sin modificar `FLAGS`.
