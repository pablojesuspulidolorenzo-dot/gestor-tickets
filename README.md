# gestor-tickets.es

Aplicacion web dockerizada para gestionar una cuenta de correo colaborativa, archivar mensajes `.eml`, agrupar correos en hilos operativos, relacionarlos con tickets GLPI, ejecutar ingesta IMAP segura y preparar configuracion IA OpenAI-compatible.

Este README esta escrito para que un desarrollador o un modelo LLM pueda entender la estructura completa del proyecto, sus contenedores, la aplicacion FastAPI, las paginas renderizadas, los servicios internos, el modelo de datos y las reglas criticas de seguridad.

## Estado Actual

- Ruta del proyecto en servidor: `/var/www/vhosts/gestor-tickets.es/docker/`
- Version actual de la app: `0.1.45`
- Stack: FastAPI, Jinja2, HTMX, PostgreSQL 17, GLPI, MariaDB, IMAP, Docker Compose
- Esquema PostgreSQL principal: `gestor_tickets`
- Archivo SQL de referencia: `gestor_tickets_v2_schema_postgresql17_sin_triggers.sql`
- El esquema se disena sin triggers de aplicacion; `updated_at` lo mantiene la aplicacion.
- La fase IA actual solo gestiona configuracion tecnica de endpoints/modelos. No analiza correos, hilos ni tickets.

## Reglas Criticas

- No instalar dependencias del proyecto fuera de Docker.
- No tocar `.env` salvo autorizacion expresa.
- No imprimir secretos, tokens, API keys, passwords ni valores cifrados.
- No modificar reglas IMAP readonly.
- No procesar correos reales con IA sin confirmacion explicita.
- Todo cambio funcional debe terminar con version/subversion y commit.
- El SQL con datos contiene datos reales y valores cifrados/hash; tratarlo como material sensible.

## Arquitectura Docker

El proyecto se levanta con `docker-compose.yml`.

### `app`

- Contenedor: `gestor-tickets-app`
- Build: `docker/app/Dockerfile`
- Working dir: `/app`
- Codigo montado: `./app:/app`
- Persistencia:
  - `../docker-data/app-uploads:/data/uploads`
  - `../docker-data/app-logs:/data/logs`
- Puerto host: `127.0.0.1:${APP_PORT:-18081}:8000`
- Redes: `frontend`, `backend`
- Depende de `postgres` healthy.

### `postgres`

- Contenedor: `gestor-tickets-postgres`
- Build: `docker/postgres/Dockerfile`
- DB por defecto: `gestor_tickets`
- Usuario por defecto: `gestor_tickets`
- Volumen: `postgres_data:/var/lib/postgresql/data`
- Puerto host: `127.0.0.1:${POSTGRES_HOST_PORT:-15432}:5432`
- Healthcheck: `pg_isready`
- Red: `backend`

### `pgadmin`

- Contenedor: `gestor-tickets-pgadmin`
- Imagen: `dpage/pgadmin4:latest`
- Volumen: `pgadmin_data:/var/lib/pgadmin`
- Puerto host: `127.0.0.1:${PGADMIN_PORT:-18083}:80`
- Redes: `frontend`, `backend`

### `glpi-db`

- Contenedor: `gestor-tickets-glpi-db`
- Imagen: `mariadb:11.4`
- Volumen: `glpi_db_data:/var/lib/mysql`
- Charset/collation: `utf8mb4`, `utf8mb4_unicode_ci`
- Red: `backend`

### `glpi`

- Contenedor: `gestor-tickets-glpi`
- Imagen: `glpi/glpi:latest`
- Volumen: `glpi_data:/var/glpi`
- Puerto host: `127.0.0.1:${GLPI_PORT:-18082}:80`
- Redes: `frontend`, `backend`

Redes: `gestor-tickets-frontend`, `gestor-tickets-backend`.
Volumenes: `postgres_data`, `pgadmin_data`, `glpi_db_data`, `glpi_data`.

## Dependencias Python

Archivo: `app/requirements.txt`.

Dependencias principales: `fastapi[standard]`, `uvicorn[standard]`, `jinja2`, `python-multipart`, `python-dotenv`, `pydantic-settings`, `psycopg[binary]`, `sqlalchemy`, `httpx`, `cryptography`, `markdown`, `bleach`, `beautifulsoup4`, `aiofiles`, `itsdangerous`, `email-validator`.

## Configuracion Central

Archivo: `app/core/config.py`.

La clase `Settings` carga variables desde `.env` dentro del contenedor. No documentar ni imprimir valores reales de secretos.

Grupos principales:

- Aplicacion: `APP_NAME`, `APP_ENV`, `APP_VERSION`, `APP_SUBVERSION`, `APP_TIMEZONE`, `SESSION_SECRET_KEY`, `SESSION_COOKIE_HTTPS_ONLY`.
- Cifrado: `APP_ENCRYPTION_SECRET`.
- PostgreSQL: `POSTGRES_HOST`, `POSTGRES_PORT`, `POSTGRES_DB`, `POSTGRES_USER`, `POSTGRES_PASSWORD`, `DB_SCHEMA`.
- GLPI: `GLPI_BASE_URL`, `GLPI_APP_TOKEN`, `GLPI_REQUIRED_PROFILE`, `GLPI_TIMEOUT_SECONDS`.
- IMAP: `DEFAULT_IMAP_PORT`, `DEFAULT_IMAP_SSL`, `MAIL_ARCHIVE_ROOT`.
- Scheduler: `MAIL_INGESTION_SCHEDULER_ENABLED`, `MAIL_INGESTION_SCHEDULER_INTERVAL_SECONDS`.
- IA/LLM: `LLM_BASE_URL`, `LLM_API_KEY`, `LLM_MODEL`, `LLM_TIMEOUT_SECONDS`.

## FastAPI

Archivo de entrada: `app/main.py`.

Responsabilidades:

- Crear `FastAPI(title=settings.APP_NAME, version=settings.full_version)`.
- Configurar `SessionMiddleware`.
- Montar estaticos en `/static`.
- Registrar `api_router` bajo `/api`.
- Registrar rutas web desde `app/api/routes/web_auth.py` sin prefijo.
- Arrancar y parar el scheduler de ingesta en `startup` y `shutdown`.

Rutas raiz:

- `GET /`: renderiza `index.html` con datos de app, entorno, PostgreSQL, schema, GLPI y version.
- `GET /health`: JSON simple con estado, app, entorno y version.
- `GET /htmx/ping`: fragmento HTML para probar HTMX.

## Router API

Archivo: `app/api/router.py`.

Rutas bajo `/api`:

- `/api/health`: health sin dependencia de sesion API.
- `/api/auth`: validaciones de autenticacion GLPI.
- `/api/accounts`: cuentas colaborativas y validacion IMAP, con sesion API.
- `/api/ai-settings`: endpoints/modelos IA, con sesion API.
- `/api/mailbox`: preview/detalle/archivo IMAP, con sesion API.
- `/api/threads`: hilos, con sesion API.
- `/api/glpi/tickets`: tickets GLPI, con sesion API.
- `/api/mail-ingestion`: jobs, ejecuciones y scheduler, con sesion API.

## Sesion Web y Permisos

Archivo: `app/api/routes/web_auth.py`.

La sesion web guarda usuario, cuenta activa, rol, modo de autenticacion y permisos:

- `can_manage_users`
- `can_manage_account_config`
- `can_read_account_mail`
- `can_reply_from_account`
- `can_create_glpi_ticket`
- `can_update_glpi_ticket`
- `can_link_tickets`
- `can_manage_ai`

Funciones clave:

- `get_session_user(request)`
- `require_session_user(request)`
- `_ensure_session_permissions(user, db)`
- `_require_permission(user, permission)`

Rutas de autenticacion:

- `GET /login`: renderiza `login.html`.
- `POST /login`: autentica con `authenticate_session_user`, crea sesion y redirige a `/app`.
- `POST /logout` y `GET /logout`: limpian sesion.

## Layout y Recursos Web

Plantilla base: `app/templates/base.html`.

- Carga `/static/css/app.css`.
- Carga HTMX local desde `/static/vendor/htmx/htmx.min.js` si `htmx_local`.
- Carga `/static/js/app.js`.
- Define bloques `title`, `head_extra`, `content`, `scripts`.

Navegacion habitual:

- Panel
- Bandeja
- Hilos
- Tickets GLPI
- Ingesta
- Cuentas
- Configuracion
- Configuracion IA

## Paginas Renderizadas

### `/app` - Panel

Plantilla: `app/templates/app_home.html`.

Muestra cuenta activa, usuario, rol, modo de acceso, version y datos de sesion. Requiere sesion iniciada.

### `/mailbox` - Bandeja

Plantilla: `app/templates/mailbox.html`.
Servicio: `preview_unified_collaborative_mailbox`.

Muestra vista unificada de `INBOX` e `INBOX.Sent`, mensajes recientes y notas de seguridad IMAP.

Permiso: `can_read_account_mail`.

### `/mailbox/message?mailbox=...&uid=...` - Detalle de correo

Plantilla: `app/templates/message_detail.html`.
Servicios: `fetch_message_detail_readonly`, `find_archived_message_for_occurrence`, `get_active_thread_for_email`.

Muestra un correo desde IMAP en modo seguro, estado de archivado e hilo asociado.

Acciones:

- `POST /mailbox/message/archive`: archiva `.eml`, requiere `can_link_tickets`.
- `POST /mailbox/message/create-thread`: crea hilo desde correo archivado, requiere `can_link_tickets`.

### `/threads` - Hilos

Plantilla: `app/templates/threads.html`.
Servicio: `list_system_threads`.

Lista hilos operativos. Requiere `can_read_account_mail`.

### `/threads/{thread_id}` - Detalle de hilo

Plantilla: `app/templates/thread_detail.html`.
Servicios: `get_thread_detail`, `list_glpi_tickets_for_thread`.

Muestra hilo, mensajes y tickets GLPI vinculados.

Accion:

- `POST /threads/{thread_id}/glpi/create-ticket`: crea ticket GLPI desde hilo. Requiere `can_create_glpi_ticket` y password GLPI en formulario.

### `/tickets` - Tickets GLPI

Plantilla: `app/templates/tickets.html`.
Servicio: `list_glpi_ticket_cache`.

Lista tickets GLPI cacheados localmente. Requiere `can_read_account_mail`.

### `/tickets/{ticket_cache_id}` - Detalle de ticket GLPI

Plantilla: `app/templates/ticket_detail.html`.
Servicio: `get_glpi_ticket_detail`.

Muestra cache local, hilos/correos relacionados y operaciones GLPI.

Acciones:

- `POST /tickets/{ticket_cache_id}/refresh`: refresca cache GLPI, requiere `can_update_glpi_ticket`.
- `POST /tickets/{ticket_cache_id}/followup`: anade seguimiento, requiere `can_update_glpi_ticket`.
- `POST /tickets/{ticket_cache_id}/attach-email/{email_message_id}`: adjunta `.eml`, requiere `can_update_glpi_ticket`.

### `/ingestion` - Ingesta IMAP

Plantilla: `app/templates/ingestion.html`.
Servicios: `list_mail_ingestion_jobs`, `get_mail_ingestion_scheduler_state`, `_get_ingestion_runs_for_account`.

Muestra scheduler, job de ingesta, ultimas ejecuciones y controles de configuracion. Requiere `can_manage_account_config`.

Acciones:

- `POST /ingestion/configure`: configura job.
- `POST /ingestion/reactivate`: reactiva job en error.
- `POST /ingestion/run-now`: ejecuta ingesta manual.

### `/ingestion/runs/{run_id}` - Detalle de run

Plantilla: `app/templates/ingestion_run_detail.html`.

Muestra estado, timestamps, contadores, errores y `details_json`. Expone seguridad: readonly, `BODY.PEEK`, no `STORE`, no `FLAGS`.

### `/settings/ai` - Configuracion IA

Plantilla: `app/templates/ai_settings.html`.
Servicios: `ai_settings_service.py`, `ai_model_discovery_service.py`.

Gestiona endpoints IA OpenAI-compatible, API keys cifradas, modelos detectados, validacion tecnica y logs de validacion. No analiza correos ni envia contenido real.

Permiso: `can_manage_ai`.

Proveedores/preajustes:

- Google Gemini OpenAI-compatible
- Groq
- OpenRouter
- Mistral
- Generico OpenAI-compatible

UI:

- Pestanas: Proveedor y conexion, Seleccion de modelo, Configuracion y validacion del modelo.
- Boton "Nuevo" navega a `/settings/ai?new=1` para forzar formulario vacio.
- Endpoint existente (con API key): pestanas 2 y 3 accesibles desde carga inicial.
- Pestana 2 se habilita tras validar API key (o al cargar endpoint existente).
- Pestana 3 se habilita tras seleccionar modelo.
- Boton "Guardar" deshabilitado hasta validar el modelo con exito (o al cargar endpoint ya configurado con modelo).
- "Validar modelo" y "Guardar endpoint" estan en la pestana 3.
- `is_active` se habilita y marca tras validacion correcta de modelo.
- `max_tokens` visible por defecto: `32000`.
- Selector `reasoning_effort` para Gemini: `none`, `low`, `medium`, `high`.
- Cambiar API key o modelo revierte el estado y requiere revalidar antes de guardar.

Acciones web:

- `POST /settings/ai/endpoints`
- `POST /settings/ai/endpoints/{endpoint_id}`
- `POST /settings/ai/endpoints/{endpoint_id}/discover-models`
- `POST /settings/ai/endpoints/{endpoint_id}/validate-model`
- `POST /settings/ai/endpoints/{endpoint_id}/set-default`
- `POST /settings/ai/endpoints/{endpoint_id}/disable`

### `/accounts` - Cuentas y colaboradores

Plantilla: `app/templates/accounts.html`.
Servicios: `collaborator_service.py`.

Gestiona colaboradores locales, permisos, roles y estado. Requiere `can_manage_users`.

Acciones:

- `POST /accounts/collaborators`
- `POST /accounts/collaborators/{collaborator_id}/update`
- `POST /accounts/collaborators/{collaborator_id}/status`

### `/{section}` - Pagina generica

Plantilla: `app/templates/section_page.html`.

Fallback para secciones definidas en `SECTION_DEFINITIONS`: `tickets`, `accounts`, `settings`. Si no existe, redirige a `/app`.

## APIs Internas Relevantes

### Health

- `GET /api/health`: health de app, PostgreSQL, version y GLPI.

### Auth

- `POST /api/auth/glpi/validate`: valida credenciales GLPI contra perfil requerido.

### Accounts

- `GET /api/accounts/collaborative`
- `POST /api/accounts/collaborative`
- Endpoints de validacion IMAP readonly.

### Mailbox

- `GET /api/mailbox/folders`
- `GET /api/mailbox/preview`
- `GET /api/mailbox/unified`
- `POST /api/mailbox/message/archive`
- `GET /api/mailbox/message`

### Threads

- `GET /api/threads/`
- `POST /api/threads/from-email/{email_message_id}`
- `GET /api/threads/{thread_id}`

### GLPI Tickets

- `GET /api/glpi/tickets/`
- `GET /api/glpi/tickets/cache/{ticket_cache_id}`
- `POST /api/glpi/tickets/cache/{ticket_cache_id}/refresh`
- `POST /api/glpi/tickets/cache/{ticket_cache_id}/followup`
- `POST /api/glpi/tickets/cache/{ticket_cache_id}/attach-email/{email_message_id}`
- `POST /api/glpi/tickets/from-thread/{thread_id}`

### Mail Ingestion

- `GET /api/mail-ingestion/jobs`
- `POST /api/mail-ingestion/jobs/configure`
- `POST /api/mail-ingestion/jobs/{job_id}/run-now`
- `POST /api/mail-ingestion/jobs/run-due`
- `GET /api/mail-ingestion/scheduler/status`

### AI Settings

- `GET /api/ai-settings/endpoints`
- `POST /api/ai-settings/endpoints`
- `GET /api/ai-settings/endpoints/{endpoint_id}`
- `POST /api/ai-settings/endpoints/{endpoint_id}`
- `POST /api/ai-settings/endpoints/{endpoint_id}/disable`
- `POST /api/ai-settings/endpoints/{endpoint_id}/enable`
- `POST /api/ai-settings/endpoints/{endpoint_id}/set-default`
- `POST /api/ai-settings/endpoints/{endpoint_id}/discover-models`
- `POST /api/ai-settings/endpoints/{endpoint_id}/validate-model`
- `POST /api/ai-settings/discover-models-preview`
- `POST /api/ai-settings/validate-model-preview`

## Servicios Internos

- `account_service.py`: cuenta colaborativa y configuracion.
- `collaborative_imap_service.py`: pruebas IMAP readonly.
- `mailbox_preview_service.py`: preview seguro con `BODY.PEEK[HEADER.FIELDS ...]`.
- `message_detail_service.py`: detalle seguro con `BODY.PEEK[]`.
- `email_archive_service.py`: archivado `.eml`, hashes, ocurrencias y deduplicacion.
- `thread_service.py`: hilos operativos y membresia de correos.
- `glpi_service.py`: cliente tecnico GLPI.
- `glpi_ticket_service.py`: tickets, cache, followups, adjuntos y operaciones GLPI.
- `mail_ingestion_service.py`: jobs, runs, clasificacion de errores e ingesta.
- `mail_ingestion_scheduler.py`: scheduler con advisory lock PostgreSQL.
- `session_auth_service.py`: autenticacion web GLPI/local.
- `collaborator_service.py`: colaboradores y permisos.
- `ai_settings_service.py`: persistencia IA y cifrado de API keys.
- `ai_model_discovery_service.py`: `/models`, `/chat/completions`, clasificacion de errores y limpieza de `<thought>...</thought>`.
- `audit_service.py`: auditoria.

## Reglas IMAP Obligatorias

No romper estas reglas:

- Nunca marcar correos como leidos.
- Nunca modificar el buzon IMAP.
- No usar `STORE`.
- No modificar `FLAGS`.
- No usar `BODY[]` normal.
- Usar `EXAMINE` o `select(..., readonly=True)`.
- Usar `UID SEARCH`.
- Leer mensajes con `BODY.PEEK`.
- Mostrar en UI/metadata: readonly, `BODY.PEEK`, no `STORE`, no flags.

Servicios donde se aplican:

- `mailbox_preview_service.py`
- `message_detail_service.py`
- `email_archive_service.py`
- `mail_ingestion_service.py`
- `collaborative_imap_service.py`

## Ingesta IMAP

La ingesta manual/programada:

- Usa jobs en `mail_ingestion_jobs`.
- Registra ejecuciones en `mail_ingestion_runs`.
- Guarda detalles en `details_json`.
- Archiva correos via `archive_message_from_imap_readonly`.
- Usa scheduler con advisory lock.

Politica `error_auth`:

- Primer fallo auth: incrementa `auth_failure_count`, mantiene job activo y reintenta aproximadamente en 2 minutos.
- Segundo fallo auth: marca job y cuenta como `error_auth`, desactiva `ingestion_enabled`.

## Integracion GLPI

La app permite:

- Validar usuarios contra GLPI.
- Exigir perfil GLPI requerido.
- Crear tickets desde hilos.
- Refrescar cache local.
- Anadir seguimientos.
- Adjuntar `.eml` archivados.
- Registrar operaciones en `glpi_api_operations`.

Las credenciales operativas se piden cuando hacen falta y no se guardan en claro.

## Configuracion IA

Solo configuracion tecnica. No analisis de contenido.

Se puede:

- Crear endpoints OpenAI-compatible.
- Guardar API keys cifradas.
- Detectar modelos desde `/models`.
- Seleccionar modelo con combo filtrable.
- Validar modelo con `/chat/completions`.
- Marcar default y activar/desactivar.
- Registrar validaciones sin API keys.

No se debe:

- Enviar correos reales a proveedores IA.
- Analizar hilos o tickets con IA.
- Guardar API keys en logs o historicos.
- Mostrar API keys completas.

Gemini:

- Usa `reasoning_effort`: `none`, `low`, `medium`, `high`.
- Si aparece `<thought>...</thought>`, se elimina antes de validar JSON util y se marca `thinking_detected`.

## Base de Datos

Esquema: `gestor_tickets`.

Tablas actuales:

- `account_users`
- `ai_call_history`
- `ai_endpoint_validation_logs`
- `ai_llm_endpoint_models`
- `ai_llm_endpoints`
- `ai_prompt_templates`
- `ai_prompt_versions`
- `app_settings`
- `audit_log`
- `collaborative_accounts`
- `email_ai_processing`
- `email_attachments`
- `email_message_occurrences`
- `email_messages`
- `email_recipients`
- `email_thread_members`
- `glpi_api_operations`
- `glpi_instances`
- `glpi_ticket_cache`
- `glpi_ticket_email_links`
- `glpi_ticket_relationships`
- `glpi_ticket_thread_links`
- `mail_ingestion_jobs`
- `mail_ingestion_runs`
- `personal_mail_accounts`
- `personal_message_transfer_log`
- `system_threads`
- `thread_ai_syntheses`
- `thread_merge_history`
- `thread_operations`

SQL completo:

- `gestor_tickets_v2_schema_postgresql17_sin_triggers.sql`
- PostgreSQL 17.
- Incluye estructura y datos.
- Incluye `pgcrypto` y `citext`.
- Sin triggers de aplicacion.
- Restauracion validada en base temporal.

## Archivos Importantes

- `docker-compose.yml`: servicios Docker.
- `app/main.py`: entrada FastAPI.
- `app/api/router.py`: router API principal.
- `app/api/routes/web_auth.py`: rutas web y formularios.
- `app/api/routes/*.py`: APIs internas.
- `app/templates/*.html`: vistas Jinja2.
- `app/static/css/app.css`: estilos.
- `app/static/js/app.js`: JS de HTMX/loading, Configuracion IA, tabs y validaciones.
- `app/core/config.py`: settings.
- `app/core/security.py`: cifrado/descifrado.
- `app/core/db.py`: engine/session SQLAlchemy.
- `app/core/versioning.py`: version visible.
- `app/services/*.py`: logica de negocio.
- `app/scripts/sql/*.sql`: migraciones incrementales.
- `app/scripts/*.py`: diagnostico/simulacion.

## Comandos de Verificacion

Entrar en ruta correcta:

```bash
cd /var/www/vhosts/gestor-tickets.es/docker/
```

Health:

```bash
curl -fsS http://127.0.0.1:18081/api/health
```

Compilacion Python:

```bash
docker compose exec -T app python -m compileall -q /app
```

Docker:

```bash
docker compose ps -a
```

Git:

```bash
git status --short
git log --oneline -5
```

Validar SQL en base temporal:

```bash
docker compose exec -T postgres psql -U gestor_tickets -d postgres -v ON_ERROR_STOP=1 -c "DROP DATABASE IF EXISTS gestor_tickets_dump_check;"
docker compose exec -T postgres psql -U gestor_tickets -d postgres -v ON_ERROR_STOP=1 -c "CREATE DATABASE gestor_tickets_dump_check;"
docker compose exec -T postgres psql -U gestor_tickets -d gestor_tickets_dump_check -v ON_ERROR_STOP=1 < gestor_tickets_v2_schema_postgresql17_sin_triggers.sql
docker compose exec -T postgres psql -U gestor_tickets -d gestor_tickets_dump_check -At -c "
select
  (select count(*) from information_schema.tables where table_schema='gestor_tickets' and table_type='BASE TABLE') || ' tables|' ||
  (select count(*) from gestor_tickets.mail_ingestion_runs) || ' runs|' ||
  (select count(*) from gestor_tickets.ai_llm_endpoints) || ' endpoints|' ||
  (select count(*) from pg_trigger t join pg_class c on c.oid=t.tgrelid join pg_namespace n on n.oid=c.relnamespace where n.nspname='gestor_tickets' and not t.tgisinternal) || ' triggers';
"
docker compose exec -T postgres psql -U gestor_tickets -d postgres -v ON_ERROR_STOP=1 -c "DROP DATABASE gestor_tickets_dump_check;"
```

## Flujo para Agentes LLM

1. Trabajar siempre en `/var/www/vhosts/gestor-tickets.es/docker/`.
2. Revisar `git status --short` antes de modificar.
3. No leer ni imprimir `.env`.
4. No instalar nada en host.
5. Usar Docker para pruebas de app y base de datos.
6. No tocar reglas IMAP readonly.
7. No incorporar analisis IA sin confirmacion explicita.
8. Hacer cambios pequenos y verificarlos.
9. Ejecutar `compileall`, `health` y `git diff --check`.
10. Subir version y hacer commit si el cambio es funcional.

## Estado Funcional

Implementado:

- Login web con sesiones.
- Cuenta colaborativa.
- Colaboradores locales y permisos.
- Preview IMAP readonly.
- Detalle de correo readonly.
- Archivado seguro `.eml`.
- Hilos operativos.
- Integracion GLPI basica completa.
- Tickets GLPI cacheados.
- Seguimientos GLPI.
- Adjuntar `.eml` a GLPI.
- Ingesta manual.
- Scheduler automatico con advisory lock PostgreSQL.
- Politica de errores de autenticacion IMAP.
- UI de ingesta y detalle de runs.
- Configuracion IA OpenAI-compatible.
- Deteccion de modelos IA.
- Validacion tecnica de modelos IA.
- Soporte `reasoning_effort` para Gemini.

No implementado todavia:

- Analisis IA de correos reales.
- Analisis IA de hilos o tickets.
- Envio de contenido real a proveedores IA.

## Notas de Seguridad

- Las API keys IA se guardan cifradas.
- Las passwords IMAP se guardan cifradas.
- Los tokens GLPI se guardan cifrados.
- Los colaboradores locales usan `password_hash`.
- La UI solo muestra mascaras de secretos.
- Los historicos IA no deben guardar API keys.
- Los logs no deben contener secretos.
- El dump SQL con datos debe tratarse como sensible.
