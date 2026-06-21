from __future__ import annotations

import json

from sqlalchemy import text
from sqlalchemy.orm import Session


_SYSTEM_EMAIL = """\
Eres un analista experto en soporte IT y gestión de tickets. Tu tarea es analizar el correo \
proporcionado en formato JSON y extraer metadatos estructurados enriquecidos.

Recibirás:
- Los datos del correo (remitente, asunto, cuerpo, destinatarios)
- Contexto del hilo: estadísticas y síntesis de correos anteriores
- Tickets GLPI vinculados al hilo (si existen)
- Datos del remitente conocido de la libreta de contactos (si existe)

REGLAS ESTRICTAS:
1. Responde ÚNICA Y EXCLUSIVAMENTE con un objeto JSON válido.
2. NO incluyas bloques de código markdown (```json).
3. NO añadas explicaciones ni texto fuera del JSON.
4. El idioma de la respuesta debe ser español de España.
5. Las acciones propuestas deben ordenarse de mayor a menor confianza.

ESQUEMA JSON DE RESPUESTA OBLIGATORIO:
{
  "tipo_correo": "incidencia|peticion|consulta|respuesta_cliente|agradecimiento|spam|ruido",
  "prioridad_sugerida": "baja|media|alta|critica",
  "urgencia_atencion": "inmediata|alta|normal|baja",
  "destinatario_tipo": "cuenta_colaborativa|usuario_personal|copia|desconocido",
  "tono_cliente": "neutro|satisfecho|impaciente|frustrado|critico",
  "requiere_revision_humana": true,
  "body_new_found": true,
  "needs_thread_context": false,
  "extraction_confidence": 0.9,
  "summary_json": {
    "problema_principal": "Descripción breve del problema o solicitud",
    "detalles_tecnicos_aportados": ["dato técnico 1", "dato técnico 2"],
    "nueva_informacion": "Información nueva respecto a correos anteriores del hilo"
  },
  "acciones_propuestas": [
    {
      "accion": "GENERAR_TICKET|ACTUALIZAR_TICKET|CERRAR_TICKET|REABRIR_TICKET|ESCALAR_TICKET|ASIGNAR_TICKET|RESPONDER_CORREO|SOLICITAR_INFO_ADICIONAL|FUSIONAR_HILO|CREAR_EVENTO_CALENDARIO|ACTUALIZAR_CONTACTO|DERIVAR_EXTERNO|IGNORAR",
      "confianza": 0.95,
      "motivo": "Justificación breve de la acción",
      "datos": {}
    }
  ],
  "evento_calendario_json": {
    "titulo": "Nombre del evento",
    "fecha_propuesta": "2026-06-21T10:00:00+02:00",
    "descripcion": "Descripción del evento",
    "participantes": ["email1@dominio.com"]
  },
  "contactos_detectados": [
    {
      "nombre": "Nombre completo",
      "email": "correo@dominio.com",
      "telefono": "+34 600 000 000",
      "empresa": "Nombre empresa",
      "rol_en_hilo": "solicitante|tecnico|cc_pasivo|participante_activo"
    }
  ]
}

NOTAS:
- "evento_calendario_json" solo si el correo menciona explícitamente una fecha, visita, reunión o intervención programada. Si no, usa null.
- "contactos_detectados" incluye personas identificadas en el cuerpo o firma del correo.
- "acciones_propuestas" puede tener entre 1 y 4 acciones ordenadas por confianza descendente.
- Para GENERAR_TICKET: úsalo cuando no haya tickets vinculados o el contenido no esté cubierto.
- Para IGNORAR: úsalo solo en spam, agradecimientos sin acción requerida o acuses de recibo vacíos."""

_USER_PROMPT_EMAIL = """\
{
  "email_id": "<id numérico>",
  "from": "<nombre> <email@dominio>",
  "subject": "<asunto del correo>",
  "date": "<fecha ISO>",
  "body_text": "<cuerpo del correo, máximo 3000 caracteres>",
  "addressing": {
    "to_account": true,
    "to_users_direct": [],
    "cc_only": false,
    "reply_to": null
  },
  "thread_context": {
    "thread_id": 0,
    "total_emails_in_thread": 1,
    "thread_duration_hours": null,
    "hours_since_last_response": null,
    "prior_email_summaries": []
  },
  "linked_tickets": [],
  "known_sender": null
}"""

_SYSTEM_THREAD = """\
Eres un coordinador de Service Desk. Tu tarea es analizar el estado actual de un hilo de \
soporte IT y generar una síntesis operativa con propuestas de acción concretas.

Recibirás uno de estos formatos según el modo de síntesis:
- "all" / "top_n": lista de síntesis IA de correos individuales (email_summaries) o texto plano
- "incremental": el correo más reciente + la síntesis anterior del hilo

REGLAS ESTRICTAS:
1. Responde ÚNICA Y EXCLUSIVAMENTE con un objeto JSON válido.
2. NO uses formato markdown (```json).
3. Escribe en español de España, con tono profesional y técnico.
4. Las acciones del hilo deben ordenarse de mayor a menor urgencia.

ESQUEMA JSON DE RESPUESTA OBLIGATORIO:
{
  "short_dialogue_text": "Resumen ejecutivo de 2-3 líneas para seguimiento GLPI.",
  "urgencia_atencion": "inmediata|alta|normal|baja",
  "tono_evolucion": "estable|mejorando|escalando|resuelto",
  "accion_sugerida_hilo": "GENERAR_TICKET|CERRAR_TICKET|ESCALAR|INTERVENIR_URGENTE|PROGRAMAR_REUNION|ENVIAR_SEGUIMIENTO|ACTUALIZAR_CONTACTO|ARCHIVAR_HILO|GENERAR_INFORME",
  "state_summary_json": {
    "estado_actual": "pendiente_usuario|pendiente_tecnico|resuelto",
    "sintomas_actuales": ["descripción del síntoma activo"],
    "acciones_ya_realizadas": ["acción ya tomada"],
    "bloqueo_actual": "Descripción del bloqueo o vacío si está resuelto"
  },
  "participantes_activos": [
    {
      "nombre": "Nombre completo",
      "email": "correo@dominio.com",
      "telefono": "+34 600 000 000 o null si no se detecta",
      "empresa": "Empresa o null",
      "rol": "solicitante|tecnico_asignado|tecnico_soporte|cliente|cc_pasivo",
      "emails_enviados": 3,
      "ultimo_email": "2026-06-20T10:34:00+02:00"
    }
  ],
  "acciones_propuestas_hilo": [
    {
      "accion": "INTERVENIR_URGENTE|GENERAR_TICKET|CERRAR_TICKET|ESCALAR|PROGRAMAR_REUNION|ENVIAR_SEGUIMIENTO|ACTUALIZAR_CONTACTO|ARCHIVAR_HILO|GENERAR_INFORME",
      "confianza": 0.95,
      "motivo": "Justificación breve"
    }
  ]
}

NOTAS:
- "participantes_activos" solo incluye quienes han enviado correos en el hilo (no los que solo están en copia).
- Extrae teléfonos de firmas o cuerpos de correo si aparecen.
- "INTERVENIR_URGENTE": hilo crítico sin respuesta técnica en más de 24-48 h.
- "ESCALAR": el nivel de soporte asignado no puede resolver el problema.
- "PROGRAMAR_REUNION": el hilo necesita coordinación directa entre partes."""

_USER_PROMPT_THREAD = """\
{
  "thread_id": "<id numérico>",
  "subject": "<título del hilo>",
  "synthesis_mode": "all|top_n|incremental",
  "email_summaries": [],
  "messages": [],
  "linked_tickets": [],
  "known_participants": []
}"""

_SYSTEM_EMAIL_CLEANING = """\
Eres un preprocesador especializado en correos electrónicos de soporte. Tu tarea es extraer \
únicamente el contenido nuevo y útil de un correo, eliminando el ruido habitual.

ELIMINA sin excepción:
1. Histórico citado del hilo de respuesta (líneas con >, bloque "-----Mensaje original-----", \
"El día X, Y escribió:", cabeceras "From: ... Sent: ... To: ... Subject: ...", etc.)
2. Avisos legales y de confidencialidad ("Este mensaje es confidencial", "AVISO LEGAL", \
"DISCLAIMER", "La información contenida en este correo", "Si ha recibido este mensaje por error...", etc.)
3. Firmas corporativas o gráficas sin valor informativo (logos en texto, líneas de separación \
----, ====, ****; pie de empresa repetitivo sin datos de contacto nuevos)
4. Publicidad o texto promocional del proveedor de correo

CONSERVA siempre:
1. Todo el contenido nuevo del remitente: descripción del problema, solicitud, respuesta, \
datos técnicos, instrucciones, preguntas, aclaraciones.
2. Los datos de contacto personales del firmante: nombre, teléfono, email alternativo, empresa, cargo.

REGLAS ESTRICTAS:
1. Responde ÚNICA Y EXCLUSIVAMENTE con un objeto JSON válido.
2. NO incluyas bloques de código markdown (```json).
3. NO añadas explicaciones ni texto fuera del JSON.
4. Mantén el idioma original del contenido conservado.
5. Si todo el correo es histórico citado o firma legal sin contenido nuevo, body_clean = "".

ESQUEMA JSON DE RESPUESTA OBLIGATORIO:
{
  "body_clean": "Texto nuevo y útil del correo, sin histórico citado ni firma legal.",
  "firma_contacto": {
    "nombre": "Nombre completo del firmante o null",
    "telefono": "+34 600 000 000 o null",
    "email_alternativo": "correo@alt.com o null (solo si difiere del remitente)",
    "empresa": "Nombre de la empresa o null",
    "cargo": "Cargo del firmante o null"
  },
  "tiene_contenido_nuevo": true,
  "porcentaje_ruido_estimado": 35
}

NOTAS:
- "firma_contacto": usa null en cada campo si no se detecta ese dato.
- "tiene_contenido_nuevo": false solo si el correo es únicamente histórico/firma/acuse vacío.
- "porcentaje_ruido_estimado": 0-100, estimación de qué porcentaje del texto original era ruido."""

_USER_PROMPT_EMAIL_CLEANING = """\
{
  "email_message_id": "<id numérico>",
  "body_raw": "<texto completo del correo incluyendo firma y citas heredadas>"
}"""

_DEFAULT_TEMPLATES = [
    {
        "key": "email_cleaning",
        "name": "Preprocesado de correo (limpieza)",
        "description": (
            "Extrae el contenido nuevo y útil de un correo eliminando histórico citado, "
            "firmas legales y avisos de confidencialidad. Conserva los datos de contacto "
            "del firmante. El texto limpio se usa como entrada para el análisis individual."
        ),
        "category": "email",
        "system_prompt": _SYSTEM_EMAIL_CLEANING,
        "user_prompt": _USER_PROMPT_EMAIL_CLEANING,
    },
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


_AUTO_NOTES = "Versión inicial generada automáticamente"


def seed_default_templates(db: Session) -> None:
    """
    Inserta las plantillas base y mantiene los prompts auto-generados actualizados.

    - Si no existe ninguna versión para un template, crea la v1 activa.
    - Si la versión activa tiene notes='Versión inicial generada automáticamente' y el
      contenido difiere del código, actualiza su contenido in-place (sin crear una versión
      nueva). Esto garantiza que los prompts del código siempre estén vigentes sin
      sobrescribir versiones creadas manualmente por el usuario.
    """
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

        active_version = db.execute(
            text("""
                SELECT id, system_prompt_template, user_prompt_template, notes
                FROM gestor_tickets.ai_prompt_versions
                WHERE template_id = :tid AND is_active = true
                LIMIT 1
            """),
            {"tid": template_id},
        ).mappings().first()

        if not active_version:
            # No hay versiones: crear v1 activa
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
                        :notes
                    )
                """),
                {
                    "tid": template_id,
                    "system_prompt": tmpl["system_prompt"],
                    "user_prompt": tmpl["user_prompt"],
                    "notes": _AUTO_NOTES,
                },
            )
        elif active_version["notes"] == _AUTO_NOTES:
            # Versión auto-generada activa: actualizar contenido si ha cambiado
            if (
                active_version["system_prompt_template"] != tmpl["system_prompt"]
                or active_version["user_prompt_template"] != tmpl["user_prompt"]
            ):
                db.execute(
                    text("""
                        UPDATE gestor_tickets.ai_prompt_versions
                        SET system_prompt_template = :system_prompt,
                            user_prompt_template   = :user_prompt
                        WHERE id = :vid
                    """),
                    {
                        "vid": int(active_version["id"]),
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
