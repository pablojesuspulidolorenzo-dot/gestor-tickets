# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Contexto del proyecto

TFG (Trabajo de Fin de Grado) de Informática. Gestor de tickets orientado a cuentas de correo compartidas: relaciona hilos de correo con tickets GLPI, permite crear/modificar tickets vía API GLPI, y facilita el trabajo colaborativo. La fase actual en curso es la configuración e integración de endpoints LLM IA (cupo gratuito) para procesar correos y obtener resúmenes y datos estructurados.

## Directorio de trabajo

Siempre trabajar desde `/var/www/vhosts/gestor-tickets.es/docker/`.

## Comandos clave

```bash
# Estado del stack
docker compose ps -a

# Health de la app
curl -fsS http://127.0.0.1:18081/api/health

# Compilar Python (detecta errores de sintaxis sin reiniciar)
docker compose exec -T app python -m compileall -q /app

# Ver logs en tiempo real
docker compose logs -f app

# Reiniciar solo la app (el código se monta en vivo)
docker compose restart app

# Logs recientes
git log --oneline -5
git status --short
```

El código en `./app/` se monta directamente en el contenedor como `/app`, por lo que los cambios de código no requieren rebuild. Solo se necesita reiniciar el contenedor si cambian dependencias o configuración de arranque.

## Verificación tras cambios funcionales

1. `docker compose exec -T app python -m compileall -q /app` — sin errores
2. `curl -fsS http://127.0.0.1:18081/api/health` — `"status":"ok"`
3. `git diff --check` — sin whitespace errors
4. Actualizar `app/version.txt` incrementando el tercer número (subversión)
5. Actualizar `README.md` para reflejar el cambio
6. Commit con mensaje descriptivo
7. `git push` — subir a GitHub

## Arquitectura

Stack: **FastAPI + Jinja2 + HTMX + PostgreSQL 17 + GLPI + Docker Compose**.

No es una SPA. Las páginas las renderiza Jinja2 en el servidor; HTMX añade interactividad parcial sin framework JS frontend.

### Capas

```
app/main.py              — FastAPI entry point, middleware, scheduler lifecycle
app/api/router.py        — monta todos los routers bajo /api
app/api/routes/          — endpoints: web_auth.py (formularios web) + APIs REST
app/services/            — lógica de negocio (una responsabilidad por archivo)
app/models/db_models.py  — modelos SQLAlchemy (schema gestor_tickets)
app/schemas/             — Pydantic schemas de entrada/salida
app/templates/           — Jinja2, base.html como plantilla padre
app/core/                — config, db, security, versioning, timezone, markdown
```

### Flujo de autenticación

Hay dos modos: autenticación GLPI (credenciales validadas en tiempo real contra GLPI) y colaboradores locales (tabla `account_users`, contraseñas hasheadas). Ambos crean una sesión web gestionada por `SessionMiddleware` (itsdangerous). La sesión almacena usuario, cuenta activa, rol y 8 permisos booleanos (`can_*`). Ver `app/api/routes/web_auth.py`.

### Cifrado de secretos en base de datos

Las API keys IA, passwords IMAP y tokens GLPI se guardan cifradas usando `app/core/security.py` y la clave `APP_ENCRYPTION_SECRET` del `.env`. La UI solo muestra máscaras. Nunca imprimir valores descifrados en logs ni en respuestas.

### Versioning

La versión visible proviene de `app/version.txt` (ej. `0.1.44`). El tercer segmento es la subversión. Todo cambio funcional requiere incrementarlo antes del commit.

### Scheduler de ingesta

Arranca en el evento `startup` de FastAPI (`mail_ingestion_scheduler.py`). Usa advisory lock de PostgreSQL para evitar ejecuciones concurrentes. Se puede disparar manualmente desde `/ingestion`.

## Reglas IMAP — nunca romper

El acceso IMAP es estrictamente **readonly**:

- Usar `EXAMINE` o `select(..., readonly=True)`, nunca `SELECT` en modo escritura.
- Leer mensajes con `BODY.PEEK`, nunca `BODY[]`.
- Nunca usar `STORE`, nunca modificar `FLAGS`.
- Usar `UID SEARCH`, no sequence numbers.
- Esto aplica a: `mailbox_preview_service.py`, `message_detail_service.py`, `email_archive_service.py`, `mail_ingestion_service.py`, `collaborative_imap_service.py`.

## Reglas generales

- No instalar dependencias en el host; solo dentro de Docker.
- No leer ni imprimir el contenido de `.env`.
- No procesar correos reales con IA sin confirmación explícita del usuario.
- El archivo SQL `gestor_tickets_v2_schema_postgresql17_sin_triggers.sql` contiene datos reales y cifrados; tratarlo como material sensible.
- El schema PostgreSQL es `gestor_tickets` (no `public`).
- No hay triggers de aplicación en el schema; `updated_at` lo actualiza la aplicación.
