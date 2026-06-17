from __future__ import annotations

import json

from sqlalchemy import text
from sqlalchemy.orm import Session


_SYSTEM_EMAIL = """\
Eres un asistente técnico experto en clasificar y resumir correos electrónicos de soporte IT.
Tu tarea es analizar el correo proporcionado en formato JSON y extraer metadatos estructurados.

REGLAS ESTRICTAS:
1. Responde ÚNICA Y EXCLUSIVAMENTE con un objeto JSON válido.
2. NO incluyas bloques de código markdown (como ```json).
3. NO añadas explicaciones, saludos ni texto fuera del JSON.
4. El idioma de la respuesta debe ser español.

ESQUEMA JSON DE RESPUESTA OBLIGATORIO:
{
  "tipo_correo": "incidencia|peticion|consulta|respuesta_cliente|agradecimiento|spam|ruido",
  "prioridad_sugerida": "baja|media|alta|critica",
  "accion_sugerida": "Texto corto (ej. 'Revisar logs', 'Cerrar ticket')",
  "requiere_revision_humana": true,
  "body_new_found": true,
  "needs_thread_context": false,
  "extraction_confidence": 0.9,
  "summary_json": {
    "problema_principal": "Descripción breve",
    "detalles_tecnicos_aportados": ["error 504"]
  }
}"""

_USER_PROMPT_EMAIL = """\
{
  "email_id": "<id numérico>",
  "from": "<nombre> <email@dominio>",
  "subject": "<asunto del correo>",
  "date": "<fecha ISO>",
  "body_text": "<cuerpo del correo, máximo 3000 caracteres>"
}"""

_SYSTEM_THREAD = """\
Eres un coordinador de Service Desk. Tu tarea es analizar un hilo cronológico de correos \
(de más antiguo a más reciente) y generar una síntesis del estado actual de la incidencia.

REGLAS ESTRICTAS:
1. Responde ÚNICA Y EXCLUSIVAMENTE con un objeto JSON válido.
2. NO uses formato markdown (```json).
3. Escribe en español de España, con un tono profesional y técnico.

ESQUEMA JSON DE RESPUESTA OBLIGATORIO:
{
  "short_dialogue_text": "Resumen de 2-3 líneas para seguimiento GLPI.",
  "state_summary_json": {
    "estado_actual": "pendiente_usuario|pendiente_tecnico|resuelto",
    "sintomas_actuales": ["falla tras reiniciar"],
    "acciones_ya_realizadas": ["actualizar Windows"],
    "bloqueo_actual": "Esperando log del cliente"
  }
}"""

_USER_PROMPT_THREAD = """\
{
  "thread_id": "<id numérico>",
  "subject": "<título del hilo>",
  "messages": [
    {
      "date": "<fecha ISO>",
      "from": "<nombre> <email@dominio>",
      "text": "<cuerpo del correo, máximo 1500 caracteres>"
    }
  ]
}"""

_DEFAULT_TEMPLATES = [
    {
        "key": "email_analysis",
        "name": "Análisis de correo individual",
        "description": (
            "Clasifica y resume un correo de soporte IT extrayendo tipo, prioridad, "
            "acción sugerida y resumen estructurado."
        ),
        "category": "email",
        "system_prompt": _SYSTEM_EMAIL,
        "user_prompt": _USER_PROMPT_EMAIL,
    },
    {
        "key": "thread_synthesis",
        "name": "Síntesis de hilo operativo",
        "description": (
            "Sintetiza cronológicamente un hilo de correos y genera el estado actual, "
            "síntomas, acciones realizadas y bloqueo."
        ),
        "category": "thread",
        "system_prompt": _SYSTEM_THREAD,
        "user_prompt": _USER_PROMPT_THREAD,
    },
]


def seed_default_templates(db: Session) -> None:
    """Inserta las plantillas base con v1 activa si no existen."""
    for tmpl in _DEFAULT_TEMPLATES:
        existing = db.execute(
            text("SELECT id FROM gestor_tickets.ai_prompt_templates WHERE key = :key"),
            {"key": tmpl["key"]},
        ).mappings().first()

        if existing:
            template_id = int(existing["id"])
        else:
            template_id = int(db.execute(
                text("""
                    INSERT INTO gestor_tickets.ai_prompt_templates
                        (key, name, description, category, variables_schema_json, active)
                    VALUES (:key, :name, :description, :category, '{}', true)
                    RETURNING id
                """),
                {
                    "key": tmpl["key"],
                    "name": tmpl["name"],
                    "description": tmpl["description"],
                    "category": tmpl["category"],
                },
            ).scalar_one())

        has_versions = db.execute(
            text("SELECT 1 FROM gestor_tickets.ai_prompt_versions WHERE template_id = :tid LIMIT 1"),
            {"tid": template_id},
        ).first()

        if not has_versions:
            db.execute(
                text("""
                    INSERT INTO gestor_tickets.ai_prompt_versions (
                        template_id, version_number, system_prompt_template,
                        user_prompt_template, response_schema_json,
                        example_input_json, expected_output_example_json,
                        default_llm_params_json, enable_thinking, timeout_seconds,
                        is_active, notes
                    ) VALUES (
                        :tid, 1, :system_prompt, :user_prompt,
                        '{}', '{}', '{}', '{}',
                        false, 120, true,
                        'Versión inicial generada automáticamente'
                    )
                """),
                {
                    "tid": template_id,
                    "system_prompt": tmpl["system_prompt"],
                    "user_prompt": tmpl["user_prompt"],
                },
            )

    db.commit()


def list_templates(db: Session) -> list[dict]:
    rows = db.execute(
        text("""
            SELECT
                t.id, t.key, t.name, t.description, t.category, t.active,
                t.created_at, t.updated_at,
                av.id AS active_version_id,
                av.version_number AS active_version_number,
                (
                    SELECT COUNT(*)
                    FROM gestor_tickets.ai_prompt_versions
                    WHERE template_id = t.id
                ) AS version_count
            FROM gestor_tickets.ai_prompt_templates t
            LEFT JOIN gestor_tickets.ai_prompt_versions av
                ON av.template_id = t.id AND av.is_active = true
            ORDER BY t.id ASC
        """)
    ).mappings().all()
    result = []
    for row in rows:
        item = dict(row)
        for k in ("created_at", "updated_at"):
            if item.get(k):
                item[k] = str(item[k])
        result.append(item)
    return result


def get_template_with_versions(db: Session, template_id: int) -> tuple[dict | None, list[dict]]:
    tmpl_row = db.execute(
        text("""
            SELECT id, key, name, description, category, active, created_at, updated_at
            FROM gestor_tickets.ai_prompt_templates
            WHERE id = :id
        """),
        {"id": template_id},
    ).mappings().first()

    if not tmpl_row:
        return None, []

    tmpl = dict(tmpl_row)
    for k in ("created_at", "updated_at"):
        if tmpl.get(k):
            tmpl[k] = str(tmpl[k])

    version_rows = db.execute(
        text("""
            SELECT id, template_id, version_number, system_prompt_template,
                   user_prompt_template, enable_thinking, timeout_seconds,
                   is_active, created_by_user_id, created_at, notes
            FROM gestor_tickets.ai_prompt_versions
            WHERE template_id = :tid
            ORDER BY version_number DESC
        """),
        {"tid": template_id},
    ).mappings().all()

    versions = []
    for row in version_rows:
        v = dict(row)
        if v.get("created_at"):
            v["created_at"] = str(v["created_at"])
        versions.append(v)

    return tmpl, versions


def get_active_version(db: Session, template_key: str) -> dict | None:
    row = db.execute(
        text("""
            SELECT pv.id, pv.template_id, pv.version_number,
                   pv.system_prompt_template, pv.user_prompt_template,
                   pv.enable_thinking, pv.timeout_seconds, pv.is_active, pv.notes
            FROM gestor_tickets.ai_prompt_versions pv
            JOIN gestor_tickets.ai_prompt_templates pt ON pt.id = pv.template_id
            WHERE pt.key = :key AND pv.is_active = true
        """),
        {"key": template_key},
    ).mappings().first()
    return dict(row) if row else None


def create_version(
    db: Session,
    template_id: int,
    *,
    system_prompt: str,
    user_prompt_template: str,
    notes: str | None = None,
    user_id: int | None = None,
) -> dict:
    max_ver = db.execute(
        text("""
            SELECT COALESCE(MAX(version_number), 0)
            FROM gestor_tickets.ai_prompt_versions
            WHERE template_id = :tid
        """),
        {"tid": template_id},
    ).scalar_one()

    new_ver = int(max_ver) + 1

    row_id = db.execute(
        text("""
            INSERT INTO gestor_tickets.ai_prompt_versions (
                template_id, version_number, system_prompt_template,
                user_prompt_template, response_schema_json,
                example_input_json, expected_output_example_json,
                default_llm_params_json, enable_thinking, timeout_seconds,
                is_active, created_by_user_id, notes
            ) VALUES (
                :tid, :ver, :system_prompt, :user_prompt,
                '{}', '{}', '{}', '{}',
                false, 120, false, :user_id, :notes
            )
            RETURNING id
        """),
        {
            "tid": template_id,
            "ver": new_ver,
            "system_prompt": system_prompt.strip(),
            "user_prompt": (user_prompt_template or "").strip(),
            "user_id": user_id,
            "notes": (notes or "").strip() or None,
        },
    ).scalar_one()
    db.commit()

    row = db.execute(
        text("""
            SELECT id, template_id, version_number, system_prompt_template,
                   user_prompt_template, is_active, created_at, notes
            FROM gestor_tickets.ai_prompt_versions WHERE id = :id
        """),
        {"id": row_id},
    ).mappings().first()
    result = dict(row)
    if result.get("created_at"):
        result["created_at"] = str(result["created_at"])
    return result


def activate_version(db: Session, version_id: int, template_id: int) -> None:
    db.execute(
        text("""
            UPDATE gestor_tickets.ai_prompt_versions
            SET is_active = false
            WHERE template_id = :tid AND is_active = true
        """),
        {"tid": template_id},
    )
    db.execute(
        text("""
            UPDATE gestor_tickets.ai_prompt_versions
            SET is_active = true
            WHERE id = :vid
        """),
        {"vid": version_id},
    )
    db.commit()
