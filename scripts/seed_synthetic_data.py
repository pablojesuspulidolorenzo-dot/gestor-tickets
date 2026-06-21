#!/usr/bin/env python3
"""
Genera 50 hilos sintéticos de soporte TI con EML reales, síntesis IA y tickets GLPI.
Ejecutar dentro del contenedor: python /scripts/seed_synthetic_data.py
"""
import hashlib, json, os, re, uuid
from datetime import datetime, timedelta, timezone
from pathlib import Path

import psycopg

# ── Conexión ─────────────────────────────────────────────────────────────────
# DATABASE_URL format: postgresql+psycopg://user:pass@host/db
_raw_url = os.environ["DATABASE_URL"]
# Strip SQLAlchemy driver prefix
_dsn = re.sub(r"^postgresql\+psycopg://", "postgresql://", _raw_url)
conn = psycopg.connect(_dsn)
conn.autocommit = False
cur = conn.cursor()

ACCOUNT_ID = 3
ACCOUNT_EMAIL = "sistemas-tic@gestor-tickets.es"
EML_BASE = Path(f"/data/mail_archive/sistemas-tic__at__gestor-tickets.es/synthetic")
EML_BASE.mkdir(parents=True, exist_ok=True)

TZ = timezone(timedelta(hours=1))   # Europe/Madrid (invierno UTC+1)

def dt(y, m, d, h=9, mi=0):
    return datetime(y, m, d, h, mi, 0, tzinfo=TZ)

# ── Participantes ficticios ───────────────────────────────────────────────────
USERS = {
    "maria": ("María García Ruiz",       "m.garcia@empresa-cliente.es"),
    "carlos": ("Carlos Martínez López",  "c.martinez@empresa-cliente.es"),
    "laura": ("Laura Sánchez Pérez",     "l.sanchez@empresa-cliente.es"),
    "antonio": ("Antonio Jiménez Vega",  "a.jimenez@empresa-cliente.es"),
    "elena": ("Elena Torres Romero",     "e.torres@despacho-abogados.es"),
    "pablo": ("Pablo Ruiz Morales",      "p.ruiz@constructora-norte.es"),
    "ana": ("Ana Fernández Gil",         "a.fernandez@ayuntamiento.local"),
    "david": ("David López Serrano",     "d.lopez@clinica-salud.es"),
    "sofia": ("Sofía Castro Navarro",    "s.castro@grupo-logistica.es"),
    "miguel": ("Miguel Ángel Blanco",    "m.blanco@distribuidora.es"),
    "rosa": ("Rosa María Vidal",         "r.vidal@academia-formacion.es"),
    "juan": ("Juan Carlos Ortega",       "j.ortega@industria-metal.es"),
    "cristina": ("Cristina Molina Reyes","c.molina@asesoría-fiscal.es"),
    "roberto": ("Roberto Herrero Sanz",  "r.herrero@hotel-playa.es"),
    "nuria": ("Nuria Pons Castelló",     "n.pons@farmacia-central.es"),
}

FIRMA_SOPORTE = """\n\n--\nSistemas TIC · Soporte Técnico\nTel: 900 123 456 | sistemas-tic@gestor-tickets.es\nHorario: L-V 8:00-18:00h\n\nEste mensaje y sus adjuntos son confidenciales y están dirigidos exclusivamente al destinatario indicado. Si usted no es el destinatario previsto, notifíquenos inmediatamente y destruya el mensaje. Queda prohibida su difusión, copia o distribución sin autorización expresa."""

def firma_usuario(nombre, empresa, dept=""):
    s = f"\n\n--\n{nombre}"
    if dept: s += f"\n{dept}"
    s += f"\n{empresa}\n\nEste correo y cualquier archivo adjunto son confidenciales. Si lo ha recibido por error, por favor notifíquelo al remitente y elimine todos los ejemplares."
    return s

# ── Generador de EML ─────────────────────────────────────────────────────────
def make_eml(msg_id, from_name, from_email, to_email, subject, body_html,
             body_text, sent_at, reply_to_id=None, attachments=None):
    """Genera un EML MIME multipart/alternative (o mixed si hay adjuntos)."""
    date_str = sent_at.strftime("%a, %d %b %Y %H:%M:%S %z")
    boundary = f"=_Part_{uuid.uuid4().hex[:16]}"
    alt_boundary = f"=_Alt_{uuid.uuid4().hex[:16]}"

    headers = [
        f"Message-ID: <{msg_id}>",
        f"Date: {date_str}",
        f"From: {from_name} <{from_email}>",
        f"To: {to_email}",
        f"Subject: {subject}",
        "MIME-Version: 1.0",
        "X-Mailer: Synthetic-TI-Mailer/1.0",
    ]
    if reply_to_id:
        headers.append(f"In-Reply-To: <{reply_to_id}>")
        headers.append(f"References: <{reply_to_id}>")

    if attachments:
        headers.append(f'Content-Type: multipart/mixed; boundary="{boundary}"')
        body_parts = "\r\n".join(headers) + "\r\n\r\n"
        body_parts += f"--{boundary}\r\n"
        body_parts += f'Content-Type: multipart/alternative; boundary="{alt_boundary}"\r\n\r\n'
    else:
        headers.append(f'Content-Type: multipart/alternative; boundary="{alt_boundary}"')
        body_parts = "\r\n".join(headers) + "\r\n\r\n"

    # Text part
    body_parts += f"--{alt_boundary}\r\nContent-Type: text/plain; charset=utf-8\r\nContent-Transfer-Encoding: quoted-printable\r\n\r\n"
    body_parts += body_text + "\r\n"
    # HTML part
    body_parts += f"--{alt_boundary}\r\nContent-Type: text/html; charset=utf-8\r\nContent-Transfer-Encoding: quoted-printable\r\n\r\n"
    body_parts += body_html + "\r\n"
    body_parts += f"--{alt_boundary}--\r\n"

    if attachments:
        for att_name, att_content_type, att_b64 in attachments:
            body_parts += f"--{boundary}\r\n"
            body_parts += f'Content-Type: {att_content_type}; name="{att_name}"\r\n'
            body_parts += f'Content-Disposition: attachment; filename="{att_name}"\r\n'
            body_parts += "Content-Transfer-Encoding: base64\r\n\r\n"
            body_parts += att_b64 + "\r\n"
        body_parts += f"--{boundary}--\r\n"

    return body_parts

def html_wrap(body_inner):
    return f"""<!DOCTYPE html><html><head><meta charset="utf-8"></head><body style="font-family:Arial,sans-serif;font-size:14px;color:#222;line-height:1.5">{body_inner}</body></html>"""

def p(text):
    return f"<p>{text}</p>"

# Adjunto simulado (base64 de un PDF mínimo de 1 byte)
FAKE_PDF_B64 = "JVBERi0xLjAKMSAwIG9iajw8L1R5cGUvQ2F0YWxvZy9QYWdlcyAyIDAgUj4+ZW5kb2JqCjIgMCBvYmo8PC9UeXBlL1BhZ2VzL0tpZHNbMyAwIFJdL0NvdW50IDE+PmVuZG9iagozIDAgb2JqPDwvVHlwZS9QYWdlL01lZGlhQm94WzAgMCAzIDNdPj5lbmRvYmoKeHJlZgowIDQKMDAwMDAwMDAwMCA2NTUzNSBmIAowMDAwMDAwMDA5IDAwMDAwIG4gCjAwMDAwMDAwNTggMDAwMDAgbiAKMDAwMDAwMDExNSAwMDAwMCBuIAp0cmFpbGVyPDwvU2l6ZSA0L1Jvb3QgMSAwIFI+PgpzdGFydHhyZWYKMTkwCiUlRU9G"
FAKE_XLSX_B64 = "UEsDBBQABgAIAAAAIQDfpNJsWgEAACAFAAATAAgCW0NvbnRlbnRfVHlwZXNdLnhtbCCiBAIooAACAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAUEsBAhQAFAAGAAgAAAAhAN+k0mxaAQAAIAUAABMAAAAAAAAAAAAAAAAAAAAAW0NvbnRlbnRfVHlwZXNdLnhtbFBLBQYAAAAAAQABAEEAAAB7AQAAAAA="

# ── Inserción en BD ───────────────────────────────────────────────────────────
def insert_message(account_id, eml_path, eml_filename, sha256, msg_id_header,
                   subject, from_email, from_name, sent_at, direction,
                   has_attachments, body_preview, size_bytes):
    cur.execute("""
        INSERT INTO gestor_tickets.email_messages
            (account_id, message_id_header, eml_sha256, eml_storage_path,
             eml_filename, size_bytes, source, subject, subject_normalized,
             from_email, from_name, sent_at, received_at, direction,
             has_attachments, body_text_preview, archived_at)
        VALUES (%s,%s,%s,%s,%s,%s,'collaborative_ingestion',%s,%s,%s,%s,%s,%s,%s,%s,%s,%s)
        ON CONFLICT (account_id, eml_sha256) DO NOTHING
        RETURNING id
    """, (account_id, msg_id_header, sha256, str(eml_path), eml_filename,
          size_bytes, subject, subject.lower().strip(), from_email, from_name,
          sent_at, sent_at, direction, has_attachments, body_preview[:300], sent_at))
    row = cur.fetchone()
    if row:
        return row[0]
    cur.execute("SELECT id FROM gestor_tickets.email_messages WHERE account_id=%s AND eml_sha256=%s",
                (account_id, sha256))
    return cur.fetchone()[0]

def insert_thread(account_id, title, subject_norm, status, created_at,
                  is_waiting=False, waiting_until=None, waiting_reason=None):
    cur.execute("""
        INSERT INTO gestor_tickets.system_threads
            (account_id, title, subject_normalized, status, created_at, updated_at,
             is_waiting, waiting_until, waiting_reason)
        VALUES (%s,%s,%s,%s,%s,%s,%s,%s,%s)
        RETURNING id
    """, (account_id, title, subject_norm, status, created_at, created_at,
          is_waiting, waiting_until, waiting_reason))
    return cur.fetchone()[0]

SYNTH_GLPI_INSTANCE_ID = 3   # instancia GLPI principal
SYNTH_PROMPT_VERSION_ID = 1  # versión de prompt ficticia

def link_message_to_thread(thread_id, email_msg_id, added_at):
    cur.execute("""
        INSERT INTO gestor_tickets.email_thread_members
            (thread_id, email_message_id, status, added_at, added_reason)
        VALUES (%s,%s,'active',%s,'synthetic_seed')
        ON CONFLICT (thread_id, email_message_id) WHERE status = 'active' DO NOTHING
    """, (thread_id, email_msg_id, added_at))

def insert_ai_email(email_msg_id, summary, tipo, accion, prioridad, urgencia,
                    destinatario_tipo, tono, processed_at):
    cur.execute("""
        INSERT INTO gestor_tickets.email_ai_processing
            (email_message_id, prompt_version_id, status, summary_json, tipo_correo,
             accion_sugerida, prioridad_sugerida, urgencia_atencion, destinatario_tipo,
             tono_cliente, processed_at, extraction_confidence)
        VALUES (%s,%s,'processed',%s,%s,%s,%s,%s,%s,%s,%s,0.92)
        ON CONFLICT (email_message_id, prompt_version_id) DO NOTHING
    """, (email_msg_id, SYNTH_PROMPT_VERSION_ID,
          json.dumps(summary, ensure_ascii=False),
          tipo, accion, prioridad, urgencia, destinatario_tipo, tono, processed_at))

def insert_synthesis(thread_id, latest_msg_id, state_summary, short_text,
                     acciones, participantes, urgencia, tono, synthesized_at):
    cur.execute("""
        INSERT INTO gestor_tickets.thread_ai_syntheses
            (thread_id, latest_email_message_id, prompt_version_id, status,
             state_summary_json, short_dialogue_text, acciones_propuestas_json,
             participantes_json, urgencia_atencion, tono_evolucion, synthesized_at)
        VALUES (%s,%s,%s,'processed',%s,%s,%s,%s,%s,%s,%s)
        ON CONFLICT (thread_id, latest_email_message_id, prompt_version_id) DO NOTHING
    """, (thread_id, latest_msg_id, SYNTH_PROMPT_VERSION_ID,
          json.dumps(state_summary, ensure_ascii=False),
          short_text,
          json.dumps(acciones, ensure_ascii=False),
          json.dumps(participantes, ensure_ascii=False),
          urgencia, tono, synthesized_at))

def insert_glpi_ticket(account_id, glpi_id, title, status, priority, thread_id):
    cur.execute("""
        INSERT INTO gestor_tickets.glpi_ticket_cache
            (account_id, glpi_instance_id, glpi_ticket_id, title, status, priority,
             urgency, impact, requester_json, assignee_json, raw_json, last_sync_at)
        VALUES (%s,%s,%s,%s,%s,%s,'3','3','[]'::jsonb,'[]'::jsonb,'{}'::jsonb, now())
        ON CONFLICT (glpi_instance_id, glpi_ticket_id) DO NOTHING
        RETURNING id
    """, (account_id, SYNTH_GLPI_INSTANCE_ID, glpi_id, title, str(status), str(priority)))
    row = cur.fetchone()
    if not row:
        cur.execute("""SELECT id FROM gestor_tickets.glpi_ticket_cache
                       WHERE glpi_instance_id=%s AND glpi_ticket_id=%s""",
                    (SYNTH_GLPI_INSTANCE_ID, glpi_id))
        row = cur.fetchone()
    cache_id = row[0]
    cur.execute("""
        INSERT INTO gestor_tickets.glpi_ticket_thread_links
            (account_id, glpi_ticket_cache_id, thread_id, origin, status)
        VALUES (%s,%s,%s,'manual','active')
        ON CONFLICT (glpi_ticket_cache_id, thread_id) WHERE status = 'active' DO NOTHING
    """, (account_id, cache_id, thread_id))
    return cache_id

# ── Función principal de creación de hilo ─────────────────────────────────────
def create_thread(idx, title, messages, thread_status="active",
                  is_waiting=False, waiting_until=None, waiting_reason=None,
                  synthesis=None, glpi=None):
    """
    messages: lista de dicts con claves:
      from_key (key de USERS o 'soporte'), subject, body_text, body_html_extra,
      sent_at, direction, has_attachments, attachments (lista de tuplas)
    """
    first_msg = messages[0]
    created_at = first_msg["sent_at"]
    thread_id = insert_thread(
        ACCOUNT_ID, title, title.lower(),
        thread_status, created_at, is_waiting, waiting_until, waiting_reason,
    )

    last_msg_id = None
    prev_msg_id_header = None
    for i, msg in enumerate(messages):
        if msg["from_key"] == "soporte":
            from_name = "Sistemas TIC"
            from_email = ACCOUNT_EMAIL
            # Busca el primer participante externo para el To:
            _ext = next((m["from_key"] for m in messages if m["from_key"] != "soporte"), None)
            to_email = USERS[_ext][1] if _ext else "cliente@empresa.es"
            direction = "outbound"
        else:
            from_name, from_email = USERS[msg["from_key"]]
            to_email = ACCOUNT_EMAIL
            direction = "inbound"

        msg_uuid = f"synthetic-{idx:03d}-{i:02d}-{uuid.uuid4().hex[:8]}@gestor-tickets.es"
        subj = msg["subject"] if i == 0 else (
            ("Re: " if direction == "inbound" else "Re: ") + messages[0]["subject"]
        )
        body_text = msg["body_text"]
        body_html = html_wrap(msg.get("body_html_extra", p(body_text.replace("\n", "<br>"))))

        eml_content = make_eml(
            msg_id=msg_uuid,
            from_name=from_name, from_email=from_email, to_email=to_email,
            subject=subj, body_html=body_html, body_text=body_text,
            sent_at=msg["sent_at"], reply_to_id=prev_msg_id_header,
            attachments=msg.get("attachments"),
        )
        eml_bytes = eml_content.encode("utf-8")
        sha256 = hashlib.sha256(eml_bytes).hexdigest()
        filename = f"syn{idx:03d}_{i:02d}_{sha256[:12]}.eml"
        eml_path = EML_BASE / filename
        eml_path.write_bytes(eml_bytes)

        em_id = insert_message(
            ACCOUNT_ID, eml_path, filename, sha256, msg_uuid,
            subj, from_email, from_name, msg["sent_at"], direction,
            bool(msg.get("attachments")), body_text, len(eml_bytes),
        )
        link_message_to_thread(thread_id, em_id, msg["sent_at"])
        insert_ai_email(
            em_id,
            summary={
                "nueva_informacion": body_text[:200],
                "problema_principal": title,
                "detalles_tecnicos_aportados": msg.get("detalles", [title]),
            },
            tipo=msg.get("tipo", "consulta_soporte"),
            accion=msg.get("accion", "REVISAR"),
            prioridad=msg.get("prioridad", "3"),
            urgencia=msg.get("urgencia", "media"),
            destinatario_tipo="cuenta_colaborativa",
            tono=msg.get("tono", "neutral"),
            processed_at=msg["sent_at"] + timedelta(minutes=2),
        )
        prev_msg_id_header = msg_uuid
        last_msg_id = em_id

    # Síntesis del hilo
    if synthesis and last_msg_id:
        insert_synthesis(
            thread_id, last_msg_id,
            synthesis["state_summary"],
            synthesis["short_text"],
            synthesis["acciones"],
            synthesis["participantes"],
            synthesis.get("urgencia", "media"),
            synthesis.get("tono", "neutral"),
            messages[-1]["sent_at"] + timedelta(minutes=5),
        )

    # Ticket GLPI
    if glpi:
        insert_glpi_ticket(
            ACCOUNT_ID, glpi["id"], glpi["title"],
            glpi["status"], glpi["priority"], thread_id,
        )

    return thread_id

# ═══════════════════════════════════════════════════════════════════════════════
#  DATOS SINTÉTICOS — 50 HILOS
# ═══════════════════════════════════════════════════════════════════════════════

def participante(key, emails_sent):
    n, e = USERS[key]
    return {"rol": "solicitante", "nombre": n, "email": e,
            "empresa": e.split("@")[1], "telefono": None,
            "ultimo_email": None, "emails_enviados": emails_sent}

def tecnico(emails_sent=2):
    return {"rol": "tecnico_soporte", "nombre": "Sistemas TIC",
            "email": ACCOUNT_EMAIL, "empresa": "Sistemas TIC",
            "telefono": None, "ultimo_email": None, "emails_enviados": emails_sent}

def accion(tipo, motivo, conf=0.90):
    return {"accion": tipo, "motivo": motivo, "confianza": conf}

def estado(est, bloqueo=None, sintomas=None, realizadas=None):
    r = {"estado_actual": est}
    if bloqueo: r["bloqueo_actual"] = bloqueo
    if sintomas: r["sintomas_actuales"] = sintomas
    if realizadas: r["acciones_ya_realizadas"] = realizadas
    return r

# ─── HILO 1: Impresora no imprime ────────────────────────────────────────────
create_thread(1,
    "Impresora HP LaserJet no imprime — 2ª planta",
    messages=[
        {"from_key":"maria","sent_at":dt(2026,4,7,9,10),"subject":"Impresora HP LaserJet no imprime — 2ª planta",
         "body_text":f"Buenos días,\n\nLa impresora HP LaserJet Pro MFP M428fdw de la 2ª planta lleva desde ayer por la tarde sin imprimir. Aparece el mensaje 'Sin papel' aunque la bandeja está llena. Hemos probado a reiniciarla sin éxito.\n\nNecesitamos utilizarla urgentemente para imprimir contratos.\n\nGracias{firma_usuario('María García Ruiz','Empresa Cliente S.L.','Administración')}",
         "detalles":["Impresora HP LaserJet Pro MFP M428fdw","Error 'Sin papel' con bandeja llena","Reinicio sin efecto"],
         "urgencia":"alta","tipo":"incidencia_hardware","accion":"ESCALAR","prioridad":"4","tono":"urgente",
         "attachments":[("foto_impresora.jpg","image/jpeg",FAKE_PDF_B64)]},
        {"from_key":"soporte","sent_at":dt(2026,4,7,10,5),
         "subject":"Re: Impresora HP LaserJet no imprime — 2ª planta",
         "body_text":f"Buenos días María,\n\nHemos registrado la incidencia. Vamos a acceder remotamente para revisar los drivers. Mientras tanto, ¿podría verificar que el rodillo de la bandeja no tiene papel atascado en la parte trasera?\n\nLe mantendremos informada.{FIRMA_SOPORTE}",
         "urgencia":"alta","tipo":"respuesta_tecnica","accion":"REVISAR","prioridad":"4","tono":"profesional"},
        {"from_key":"maria","sent_at":dt(2026,4,7,11,30),
         "subject":"Re: Impresora HP LaserJet no imprime — 2ª planta",
         "body_text":f"He revisado la parte trasera y hay un pequeño atasco de papel. Al retirarlo ha vuelto a funcionar correctamente. Muchas gracias por la atención tan rápida.\n\nUn saludo{firma_usuario('María García Ruiz','Empresa Cliente S.L.','Administración')}",
         "urgencia":"baja","tipo":"confirmacion_resolucion","accion":"CERRAR","prioridad":"1","tono":"satisfecho"},
    ],
    thread_status="archived",
    synthesis={
        "state_summary": estado("resuelto", realizadas=["Diagnóstico remoto","Usuario retiró atasco trasero"]),
        "short_text": "Atasco de papel oculto en bandeja posterior. Resuelto por usuario.",
        "acciones": [accion("CERRAR_TICKET","Incidencia resuelta por el usuario al retirar atasco oculto en bandeja trasera.",0.97)],
        "participantes": [participante("maria",2), tecnico(1)],
        "urgencia":"alta","tono":"satisfecho",
    },
    glpi={"id":1041,"title":"Impresora HP LaserJet 2ª planta — atasco oculto","status":"5","priority":"4"},
)

# ─── HILO 2: VPN sin conexión ─────────────────────────────────────────────────
create_thread(2,
    "VPN corporativa no conecta desde casa — teletrabajo",
    messages=[
        {"from_key":"carlos","sent_at":dt(2026,4,8,8,45),
         "subject":"VPN corporativa no conecta desde casa",
         "body_text":f"Buenos días,\n\nDesde el lunes no puedo conectarme a la VPN corporativa desde casa. El cliente FortiClient me da el error 'SSL VPN timeout'. Esto me impide acceder a los sistemas de gestión internos para trabajar en remoto.\n\nMi equipo: Windows 11 Pro, FortiClient 7.0.7.\n{firma_usuario('Carlos Martínez López','Empresa Cliente S.L.','Comercial')}",
         "detalles":["FortiClient 7.0.7","Error SSL VPN timeout","Windows 11 Pro"],
         "urgencia":"alta","tipo":"incidencia_red","accion":"DIAGNOSTICAR","prioridad":"4","tono":"urgente"},
        {"from_key":"soporte","sent_at":dt(2026,4,8,9,20),
         "subject":"Re: VPN corporativa no conecta desde casa",
         "body_text":f"Buenos días Carlos,\n\nVamos a revisar varios puntos:\n\n1. ¿Ha cambiado su contraseña de dominio recientemente? Las credenciales VPN se sincronizan con el AD.\n2. ¿Su router doméstico tiene el puerto 443 TCP disponible? Algunos ISP filtran el tráfico SSL.\n3. Pruebe a desinstalar y reinstalar FortiClient 7.2.4 (versión actualizada).\n\nAdjuntamos la guía de instalación.{FIRMA_SOPORTE}",
         "urgencia":"alta","tipo":"diagnostico","accion":"INFORMAR","prioridad":"4","tono":"profesional",
         "attachments":[("guia_forti_client_7.2.4.pdf","application/pdf",FAKE_PDF_B64)]},
        {"from_key":"carlos","sent_at":dt(2026,4,8,11,0),
         "subject":"Re: VPN corporativa no conecta desde casa",
         "body_text":f"Hola,\n\nActualicé FortiClient a la 7.2.4 y ahora conecta perfectamente. Debía ser un problema de compatibilidad con la versión antigua. Muchas gracias.\n{firma_usuario('Carlos Martínez López','Empresa Cliente S.L.','Comercial')}",
         "urgencia":"baja","tipo":"confirmacion","accion":"CERRAR","prioridad":"1","tono":"satisfecho"},
    ],
    thread_status="archived",
    synthesis={
        "state_summary": estado("resuelto", realizadas=["Actualización FortiClient 7.0.7→7.2.4"]),
        "short_text": "VPN sin conexión por incompatibilidad de versión FortiClient. Actualización resolvió el problema.",
        "acciones": [accion("CERRAR_TICKET","Resuelto tras actualizar FortiClient a 7.2.4.",0.98)],
        "participantes": [participante("carlos",2), tecnico(1)],
        "urgencia":"alta","tono":"satisfecho",
    },
    glpi={"id":1042,"title":"VPN teletrabajo — error SSL timeout FortiClient","status":"5","priority":"4"},
)

# ─── HILO 3: Correo corporativo no llega ─────────────────────────────────────
create_thread(3,
    "Correos de clientes no llegan al buzón compartido",
    messages=[
        {"from_key":"laura","sent_at":dt(2026,4,9,10,0),
         "subject":"Correos de clientes no llegan al buzón compartido",
         "body_text":f"Buenos días,\n\nNos hemos dado cuenta de que desde el viernes pasado los correos enviados por clientes externos a info@empresa-cliente.es no están llegando al buzón compartido de Outlook. Hemos verificado con varios clientes que los correos se envían correctamente desde su parte.\n\nTenemos miedo de haber perdido comunicaciones importantes.\n{firma_usuario('Laura Sánchez Pérez','Empresa Cliente S.L.','Atención al Cliente')}",
         "detalles":["Buzón info@empresa-cliente.es","Correos externos no recibidos desde viernes","Confirmado por remitentes"],
         "urgencia":"critica","tipo":"incidencia_correo","accion":"ESCALAR","prioridad":"5","tono":"preocupado"},
        {"from_key":"soporte","sent_at":dt(2026,4,9,10,30),
         "subject":"Re: Correos de clientes no llegan al buzón compartido",
         "body_text":f"Buenos días Laura,\n\nEs una incidencia de alta prioridad. Hemos iniciado la investigación:\n\n- Revisamos los registros MX del dominio empresa-cliente.es\n- Comprobamos la cola de correo en el servidor Exchange\n- Verificamos las reglas de anti-spam y listas negras\n\nLe daremos respuesta en menos de 1 hora con el diagnóstico completo.{FIRMA_SOPORTE}",
         "urgencia":"critica","tipo":"escalado","accion":"INVESTIGAR","prioridad":"5","tono":"urgente"},
        {"from_key":"soporte","sent_at":dt(2026,4,9,11,15),
         "subject":"Re: Correos de clientes no llegan al buzón compartido — DIAGNÓSTICO",
         "body_text":f"Laura,\n\nHemos identificado el problema: la dirección IP del servidor de correo (87.23.45.67) ha sido incluida en la lista negra de Spamhaus el pasado jueves. Esto ha provocado que los correos externos entrantes sean rechazados silenciosamente.\n\nHemos iniciado el proceso de eliminación de la lista negra (delist). El proceso puede tardar entre 2-24 horas en propagarse. Paralelamente, hemos configurado una ruta alternativa para recibir correos durante el proceso.\n\nLe confirmaremos cuando esté resuelto completamente.{FIRMA_SOPORTE}",
         "urgencia":"critica","tipo":"diagnostico","accion":"ESCALAR","prioridad":"5","tono":"informativo",
         "attachments":[("informe_blacklist.pdf","application/pdf",FAKE_PDF_B64)]},
        {"from_key":"laura","sent_at":dt(2026,4,9,13,0),
         "subject":"Re: Correos de clientes no llegan al buzón compartido — DIAGNÓSTICO",
         "body_text":f"Muchas gracias por la rápida respuesta y el diagnóstico tan detallado. ¿Hay algo que debamos hacer desde nuestra parte mientras se resuelve? ¿Los clientes deben reenviar los correos que enviaron durante ese período?\n{firma_usuario('Laura Sánchez Pérez','Empresa Cliente S.L.','Atención al Cliente')}",
         "urgencia":"alta","tipo":"consulta","accion":"INFORMAR","prioridad":"4","tono":"neutral"},
        {"from_key":"soporte","sent_at":dt(2026,4,9,15,0),
         "subject":"Re: Correos de clientes no llegan al buzón compartido — RESUELTO",
         "body_text":f"Laura,\n\nEl servidor ha sido eliminado de la lista negra de Spamhaus y los correos externos ya están llegando con normalidad. Hemos verificado la recepción con varios dominios de prueba.\n\nRecomendamos solicitar a sus clientes más críticos que reenvíen cualquier correo enviado entre el jueves y hoy. También hemos implementado un sistema de monitorización para detectar futuros incidentes de este tipo.\n\nQuedo a su disposición para cualquier consulta.{FIRMA_SOPORTE}",
         "urgencia":"baja","tipo":"resolucion","accion":"CERRAR","prioridad":"2","tono":"satisfecho"},
    ],
    thread_status="archived",
    synthesis={
        "state_summary": estado("resuelto",
            sintomas=["Correos externos rechazados","IP en lista negra Spamhaus"],
            realizadas=["Delist Spamhaus","Ruta alternativa configurada","Monitorización implementada"]),
        "short_text": "IP servidor en blacklist Spamhaus. Resuelto mediante delist y ruta alternativa.",
        "acciones": [accion("CERRAR_TICKET","IP eliminada de Spamhaus. Correo normalizado.",0.99)],
        "participantes": [participante("laura",2), tecnico(3)],
        "urgencia":"critica","tono":"satisfecho",
    },
    glpi={"id":1043,"title":"Buzón info@ — IP en blacklist Spamhaus","status":"5","priority":"5"},
)

# ─── HILO 4: Actualización Windows forzada — equipo lento ────────────────────
create_thread(4,
    "Equipo muy lento tras actualización Windows 11 22H2",
    messages=[
        {"from_key":"antonio","sent_at":dt(2026,4,10,9,0),
         "subject":"Equipo muy lento tras actualización Windows 11 22H2",
         "body_text":f"Hola,\n\nAyer Windows instaló la actualización 22H2 de forma automática y ahora el equipo tarda 10 minutos en arrancar y las aplicaciones van muy despacio. El Administrador de tareas muestra el disco al 100% constantemente.\n\nEquipo: Dell Latitude 5520, 8 GB RAM, SSD 256 GB.\n{firma_usuario('Antonio Jiménez Vega','Empresa Cliente S.L.','Contabilidad')}",
         "detalles":["Windows 11 22H2","Disco al 100%","Dell Latitude 5520 8GB RAM SSD 256GB"],
         "urgencia":"alta","tipo":"incidencia_software","accion":"DIAGNOSTICAR","prioridad":"4","tono":"molesto"},
        {"from_key":"soporte","sent_at":dt(2026,4,10,9,45),
         "subject":"Re: Equipo muy lento tras actualización Windows 11 22H2",
         "body_text":f"Buenos días Antonio,\n\nEl disco al 100% tras la actualización 22H2 es un problema conocido causado por el servicio SysMain (antes Superfetch) que reconstruye su caché. Normalmente se resuelve en 24-48 h de forma automática.\n\nSin embargo, también puede estar relacionado con la indexación de Windows Search. Vamos a programar una sesión de soporte remoto para hoy a las 16:00 h. ¿Le viene bien?\n{FIRMA_SOPORTE}",
         "urgencia":"alta","tipo":"diagnostico","accion":"PROGRAMAR_SESION","prioridad":"4","tono":"profesional"},
        {"from_key":"antonio","sent_at":dt(2026,4,10,10,5),
         "subject":"Re: Equipo muy lento tras actualización Windows 11 22H2",
         "body_text":f"Sí, a las 16:00 perfecto. El equipo sigue igual de lento.\n{firma_usuario('Antonio Jiménez Vega','Empresa Cliente S.L.','Contabilidad')}",
         "urgencia":"alta","tipo":"confirmacion","accion":"ESPERAR","prioridad":"4","tono":"neutral"},
        {"from_key":"soporte","sent_at":dt(2026,4,10,16,30),
         "subject":"Re: Equipo muy lento tras actualización Windows 11 22H2",
         "body_text":f"Antonio,\n\nTras la sesión remota hemos:\n1. Desactivado SysMain y ajustado los parámetros de Windows Search\n2. Ejecutado DISM y SFC para reparar la imagen del SO\n3. Verificado que no hay malware\n\nEl equipo ahora arranca en 45 segundos y el disco se mantiene por debajo del 40%. ¿Confirma que funciona correctamente?\n{FIRMA_SOPORTE}",
         "urgencia":"baja","tipo":"resolucion","accion":"CONFIRMAR","prioridad":"2","tono":"profesional"},
        {"from_key":"antonio","sent_at":dt(2026,4,10,17,0),
         "subject":"Re: Equipo muy lento tras actualización Windows 11 22H2",
         "body_text":f"Sí, confirmo que ahora va perfectamente. Muchas gracias.\n{firma_usuario('Antonio Jiménez Vega','Empresa Cliente S.L.','Contabilidad')}",
         "urgencia":"baja","tipo":"confirmacion","accion":"CERRAR","prioridad":"1","tono":"satisfecho"},
    ],
    thread_status="archived",
    synthesis={
        "state_summary": estado("resuelto",
            sintomas=["Disco al 100%","Arranque 10 min"],
            realizadas=["Desactivar SysMain","DISM/SFC reparación","Sesión remota diagnóstico"]),
        "short_text": "Disco al 100% post-actualización 22H2 por SysMain. Resuelto en sesión remota.",
        "acciones": [accion("CERRAR_TICKET","Rendimiento restaurado. Equipo validado por usuario.",0.97)],
        "participantes": [participante("antonio",3), tecnico(2)],
        "urgencia":"alta","tono":"satisfecho",
    },
)

# ─── HILO 5: Solicitud instalación software ───────────────────────────────────
create_thread(5,
    "Solicitud instalación Adobe Acrobat Pro — dpto. Legal",
    messages=[
        {"from_key":"elena","sent_at":dt(2026,4,11,10,30),
         "subject":"Solicitud instalación Adobe Acrobat Pro — dpto. Legal",
         "body_text":f"Hola,\n\nNecesito que instalen Adobe Acrobat Pro DC en mi equipo (PC-LEGAL-07). Lo necesito para firmar digitalmente contratos y editar PDF con funcionalidades avanzadas. Actualmente solo tengo el lector gratuito.\n\nQuedo a la espera de confirmación.\n{firma_usuario('Elena Torres Romero','Despacho de Abogados Torres & Asociados','Dept. Legal')}",
         "detalles":["Adobe Acrobat Pro DC","PC-LEGAL-07","Firma digital de PDFs"],
         "urgencia":"media","tipo":"solicitud_software","accion":"AUTORIZAR","prioridad":"3","tono":"formal"},
        {"from_key":"soporte","sent_at":dt(2026,4,11,11,15),
         "subject":"Re: Solicitud instalación Adobe Acrobat Pro — dpto. Legal",
         "body_text":f"Buenos días Elena,\n\nHemos recibido su solicitud. Para proceder necesitamos:\n\n1. Autorización del responsable del departamento (nombre del autorizante)\n2. Número de licencia o confirmación de compra\n\nSi dispone de la licencia corporativa del despacho, indíquenos el código para verificar en el portal de Adobe.\n{FIRMA_SOPORTE}",
         "urgencia":"media","tipo":"solicitud_informacion","accion":"ESPERAR","prioridad":"3","tono":"profesional"},
        {"from_key":"elena","sent_at":dt(2026,4,11,12,0),
         "subject":"Re: Solicitud instalación Adobe Acrobat Pro — dpto. Legal",
         "body_text":f"La autorización la da el socio director, D. Ramón Torres (rtorres@despacho-abogados.es). Adjunto el correo de confirmación de la licencia corporativa que compramos el año pasado.\n{firma_usuario('Elena Torres Romero','Despacho de Abogados Torres & Asociados','Dept. Legal')}",
         "urgencia":"media","tipo":"respuesta","accion":"INSTALAR","prioridad":"3","tono":"formal",
         "attachments":[("confirmacion_licencia_adobe.pdf","application/pdf",FAKE_PDF_B64)]},
        {"from_key":"soporte","sent_at":dt(2026,4,11,15,0),
         "subject":"Re: Solicitud instalación Adobe Acrobat Pro — dpto. Legal",
         "body_text":f"Elena,\n\nHemos instalado Adobe Acrobat Pro DC en PC-LEGAL-07 y configurado los certificados de firma digital. Puede acceder al software desde el menú de inicio.\n\nRecuerde que para la firma digital deberá tener instalado también el certificado de firma electrónica (DNIe o FNMT). ¿Necesita asistencia con la configuración del certificado?\n{FIRMA_SOPORTE}",
         "urgencia":"baja","tipo":"resolucion","accion":"CONFIRMAR","prioridad":"2","tono":"profesional"},
        {"from_key":"elena","sent_at":dt(2026,4,11,15,30),
         "subject":"Re: Solicitud instalación Adobe Acrobat Pro — dpto. Legal",
         "body_text":f"Perfecto, funciona correctamente. El certificado FNMT ya lo tenemos instalado de antes. Muchas gracias por la rapidez.\n{firma_usuario('Elena Torres Romero','Despacho de Abogados Torres & Asociados','Dept. Legal')}",
         "urgencia":"baja","tipo":"confirmacion","accion":"CERRAR","prioridad":"1","tono":"satisfecho"},
    ],
    thread_status="archived",
    synthesis={
        "state_summary": estado("resuelto", realizadas=["Verificación licencia","Instalación Acrobat Pro DC","Configuración firma digital"]),
        "short_text": "Acrobat Pro instalado con licencia corporativa verificada. Firma digital operativa.",
        "acciones": [accion("CERRAR_TICKET","Software instalado y validado.",0.98)],
        "participantes": [participante("elena",3), tecnico(2)],
        "urgencia":"media","tono":"satisfecho",
    },
)

# ─── HILO 6: Servidor caído en horario pico ───────────────────────────────────
create_thread(6,
    "Servidor de ficheros SRV-DATOS01 inaccesible — CRÍTICO",
    messages=[
        {"from_key":"pablo","sent_at":dt(2026,4,14,8,5),
         "subject":"Servidor de ficheros SRV-DATOS01 inaccesible — CRÍTICO",
         "body_text":f"URGENTE:\n\nEl servidor SRV-DATOS01 no está accesible desde las 7:50 h. Todos los empleados de oficina (30 personas) no pueden acceder a los documentos de trabajo. Estamos paralizados.\n\nError al intentar acceder: 'No se puede encontrar la ruta de red \\\\SRV-DATOS01'\n{firma_usuario('Pablo Ruiz Morales','Constructora Norte S.A.','Director de Operaciones')}",
         "detalles":["SRV-DATOS01 inaccesible","30 usuarios afectados","Error ruta de red no encontrada"],
         "urgencia":"critica","tipo":"incidencia_servidor","accion":"ESCALAR","prioridad":"5","tono":"muy_urgente"},
        {"from_key":"soporte","sent_at":dt(2026,4,14,8,15),
         "subject":"Re: Servidor de ficheros SRV-DATOS01 inaccesible — CRÍTICO",
         "body_text":f"Pablo, estamos en ello ahora mismo. Hemos detectado que el servicio Server en SRV-DATOS01 se ha detenido. Reiniciando el servicio... Mantenemos comunicación constante.\n{FIRMA_SOPORTE}",
         "urgencia":"critica","tipo":"escalado","accion":"RESOLVER","prioridad":"5","tono":"urgente"},
        {"from_key":"soporte","sent_at":dt(2026,4,14,8,40),
         "subject":"Re: Servidor de ficheros SRV-DATOS01 inaccesible — CRÍTICO — ACTUALIZACIÓN",
         "body_text":f"Pablo,\n\nEl servidor SRV-DATOS01 está de nuevo operativo desde las 8:35 h. El problema fue una actualización de seguridad de Windows Server (KB5034441) que requirió reinicio y dejó el servicio de uso compartido de archivos detenido.\n\nHemos verificado la integridad de los datos: sin pérdida de información. También hemos configurado una alerta para que este servicio se reinicie automáticamente si vuelve a detenerse.\n\n¿Puede confirmar que todos los usuarios tienen acceso nuevamente?\n{FIRMA_SOPORTE}",
         "urgencia":"critica","tipo":"resolucion","accion":"CONFIRMAR","prioridad":"5","tono":"profesional"},
        {"from_key":"pablo","sent_at":dt(2026,4,14,8,50),
         "subject":"Re: Servidor de ficheros SRV-DATOS01 inaccesible — CRÍTICO — RESUELTO",
         "body_text":f"Confirmado. Todos los usuarios pueden acceder con normalidad. Tiempo de resolución: 45 minutos desde el reporte. Buen trabajo.\n{firma_usuario('Pablo Ruiz Morales','Constructora Norte S.A.','Director de Operaciones')}",
         "urgencia":"baja","tipo":"confirmacion","accion":"CERRAR","prioridad":"1","tono":"satisfecho"},
    ],
    thread_status="archived",
    synthesis={
        "state_summary": estado("resuelto",
            sintomas=["30 usuarios sin acceso a ficheros","Servicio Server detenido por KB5034441"],
            realizadas=["Reinicio servicio Server","Verificación integridad datos","Alerta auto-restart configurada"]),
        "short_text": "SRV-DATOS01 caído 45 min por actualización KB5034441. Resuelto sin pérdida de datos.",
        "acciones": [accion("CERRAR_TICKET","Servidor restaurado y monitorizado.",0.99)],
        "participantes": [participante("pablo",2), tecnico(3)],
        "urgencia":"critica","tono":"satisfecho",
    },
    glpi={"id":1044,"title":"SRV-DATOS01 caída — actualización KB5034441","status":"5","priority":"5"},
)

# ─── HILO 7: Reset contraseña ─────────────────────────────────────────────────
create_thread(7,
    "Restablecimiento contraseña — cuenta bloqueada",
    messages=[
        {"from_key":"ana","sent_at":dt(2026,4,15,9,30),
         "subject":"No puedo acceder a mi cuenta — bloqueada",
         "body_text":f"Buenos días,\n\nHe intentado iniciar sesión varias veces y ahora aparece 'Cuenta bloqueada'. Creo que olvidé la contraseña y los intentos fallidos la bloquearon. Necesito acceso urgente para trabajar.\n\nUsuario: agilf@ayuntamiento.local\n{firma_usuario('Ana Fernández Gil','Ayuntamiento','Urbanismo')}",
         "detalles":["Cuenta agilf@ayuntamiento.local bloqueada","Múltiples intentos fallidos"],
         "urgencia":"alta","tipo":"acceso_cuenta","accion":"RESOLVER","prioridad":"4","tono":"urgente"},
        {"from_key":"soporte","sent_at":dt(2026,4,15,9,40),
         "subject":"Re: No puedo acceder a mi cuenta — bloqueada",
         "body_text":f"Buenos días Ana,\n\nHemos desbloqueado su cuenta y restablecido la contraseña temporal. La nueva contraseña es: TempAyto2026# (cámbiela en el primer inicio de sesión).\n\nRecuerde que la política de contraseñas exige mínimo 10 caracteres, mayúsculas, minúsculas, número y símbolo.\n{FIRMA_SOPORTE}",
         "urgencia":"alta","tipo":"resolucion","accion":"CONFIRMAR","prioridad":"4","tono":"profesional"},
        {"from_key":"ana","sent_at":dt(2026,4,15,9,50),
         "subject":"Re: No puedo acceder a mi cuenta — bloqueada",
         "body_text":f"Perfecto, ya he podido entrar y he cambiado la contraseña. Muchas gracias.\n{firma_usuario('Ana Fernández Gil','Ayuntamiento','Urbanismo')}",
         "urgencia":"baja","tipo":"confirmacion","accion":"CERRAR","prioridad":"1","tono":"satisfecho"},
    ],
    thread_status="archived",
    synthesis={
        "state_summary": estado("resuelto", realizadas=["Desbloqueo cuenta AD","Reset contraseña temporal"]),
        "short_text": "Cuenta bloqueada por intentos fallidos. Restablecida y verificada.",
        "acciones": [accion("CERRAR_TICKET","Acceso restaurado.",0.99)],
        "participantes": [participante("ana",2), tecnico(1)],
        "urgencia":"alta","tono":"satisfecho",
    },
)

# ─── HILO 8: Disco duro casi lleno en servidor ────────────────────────────────
create_thread(8,
    "Alerta: disco C: al 95% en SRV-APP01",
    messages=[
        {"from_key":"soporte","sent_at":dt(2026,4,16,7,0),
         "subject":"Alerta: disco C: al 95% en SRV-APP01",
         "body_text":f"Buenos días,\n\nNuestro sistema de monitorización ha detectado que el disco C: del servidor SRV-APP01 está al 95% de capacidad (476 GB de 500 GB). Esto puede causar fallos en los servicios si llega al 100%.\n\nVamos a proceder a limpiar los logs y archivos temporales.\n{FIRMA_SOPORTE}",
         "urgencia":"alta","tipo":"alerta_proactiva","accion":"RESOLVER","prioridad":"4","tono":"profesional"},
        {"from_key":"david","sent_at":dt(2026,4,16,8,30),
         "subject":"Re: Alerta: disco C: al 95% en SRV-APP01",
         "body_text":f"Gracias por el aviso. ¿Hay algo que debamos hacer desde nuestra parte? ¿Necesitamos ampliar el espacio?\n{firma_usuario('David López Serrano','Clínica Salud Integral','Administración de Sistemas')}",
         "urgencia":"alta","tipo":"consulta","accion":"ASESORAR","prioridad":"4","tono":"neutral"},
        {"from_key":"soporte","sent_at":dt(2026,4,16,10,0),
         "subject":"Re: Alerta: disco C: al 95% en SRV-APP01",
         "body_text":f"David,\n\nHemos liberado 47 GB eliminando logs antiguos y archivos temporales del sistema. El disco está ahora al 67% (335 GB / 500 GB).\n\nA medio plazo, dado el crecimiento de los últimos 6 meses, recomendamos ampliar el disco a 1 TB antes de que finalice el año. Adjuntamos el informe de análisis de crecimiento.\n{FIRMA_SOPORTE}",
         "urgencia":"media","tipo":"resolucion_parcial","accion":"ASESORAR","prioridad":"3","tono":"profesional",
         "attachments":[("informe_crecimiento_disco_SRV-APP01.xlsx","application/vnd.openxmlformats-officedocument.spreadsheetml.sheet",FAKE_XLSX_B64)]},
        {"from_key":"david","sent_at":dt(2026,4,16,11,0),
         "subject":"Re: Alerta: disco C: al 95% en SRV-APP01",
         "body_text":f"Perfecto. Vamos a solicitar presupuesto para la ampliación. ¿Pueden enviarnos una propuesta económica?\n{firma_usuario('David López Serrano','Clínica Salud Integral','Administración de Sistemas')}",
         "urgencia":"baja","tipo":"solicitud","accion":"PRESUPUESTAR","prioridad":"2","tono":"neutral"},
    ],
    thread_status="active",
    synthesis={
        "state_summary": estado("pendiente_cliente",
            bloqueo="Pendiente decisión cliente sobre ampliación de disco",
            sintomas=["Disco C: al 95%"],
            realizadas=["Limpieza 47 GB logs y temporales","Informe crecimiento enviado"]),
        "short_text": "Disco al 95% resuelto temporalmente. Pendiente presupuesto ampliación a 1TB.",
        "acciones": [
            accion("ENVIAR_PRESUPUESTO","El cliente solicita propuesta económica para ampliar disco a 1TB.",0.95),
            accion("PROGRAMAR_REVISION","Revisar crecimiento en 30 días para ajustar la propuesta.",0.80),
        ],
        "participantes": [tecnico(2), participante("david",2)],
        "urgencia":"alta","tono":"neutral",
    },
    glpi={"id":1045,"title":"SRV-APP01 — disco C: al 95%, limpieza y análisis","status":"2","priority":"4"},
)

# ─── HILO 9: Phishing — incidente de seguridad ────────────────────────────────
create_thread(9,
    "URGENTE: empleada abrió enlace sospechoso de phishing",
    messages=[
        {"from_key":"sofia","sent_at":dt(2026,4,17,14,20),
         "subject":"URGENTE: empleada abrió enlace phishing",
         "body_text":f"URGENTE:\n\nUna empleada de almacén ha hecho clic en un enlace de un correo de phishing que simulaba ser un aviso de DHL. Introdujo sus credenciales de red antes de darse cuenta. El equipo afectado es ALM-PC-03.\n\n¿Qué debemos hacer ahora mismo?\n{firma_usuario('Sofía Castro Navarro','Grupo Logística del Norte S.L.','RRHH')}",
         "detalles":["Phishing simulando DHL","Credenciales de red comprometidas","Equipo ALM-PC-03"],
         "urgencia":"critica","tipo":"incidente_seguridad","accion":"ESCALAR","prioridad":"5","tono":"muy_urgente"},
        {"from_key":"soporte","sent_at":dt(2026,4,17,14,35),
         "subject":"Re: URGENTE: empleada abrió enlace phishing",
         "body_text":f"Sofía, actuamos ahora mismo. PASOS INMEDIATOS:\n\n1. Desconecte el equipo ALM-PC-03 de la red AHORA (cable o WiFi)\n2. Cambiamos la contraseña de la empleada desde aquí (ya lo estamos haciendo)\n3. Revisamos el acceso al AD para detectar actividad sospechosa\n4. Iniciamos análisis forense del equipo\n\nLlamar al +34 900 123 456 si tiene alguna duda urgente.{FIRMA_SOPORTE}",
         "urgencia":"critica","tipo":"respuesta_incidente","accion":"RESOLVER","prioridad":"5","tono":"muy_urgente"},
        {"from_key":"sofia","sent_at":dt(2026,4,17,14,50),
         "subject":"Re: URGENTE: empleada abrió enlace phishing",
         "body_text":f"Equipo desconectado. ¿Necesitamos notificar a alguien más? ¿A la AEPD por la brecha de seguridad?\n{firma_usuario('Sofía Castro Navarro','Grupo Logística del Norte S.L.','RRHH')}",
         "urgencia":"critica","tipo":"consulta","accion":"ASESORAR","prioridad":"5","tono":"preocupado"},
        {"from_key":"soporte","sent_at":dt(2026,4,17,15,30),
         "subject":"Re: URGENTE: empleada abrió enlace phishing — INFORME PRELIMINAR",
         "body_text":f"Sofía,\n\nInforme de situación:\n\n✅ Contraseña de la empleada cambiada y todas las sesiones activas cerradas\n✅ Análisis del AD: no se detecta movimiento lateral ni compromiso de otras cuentas\n✅ Equipo ALM-PC-03 en análisis forense — sin cifrador activo detectado\n\nSobre la AEPD: dado que parece que las credenciales no fueron usadas para acceder a datos de clientes, no hay obligación inmediata de notificación. Recomendamos consultar con su DPO para confirmar. Adjuntamos modelo de evaluación de brecha.\n\nEl equipo puede volver a conectarse mañana tras completar el análisis.\n{FIRMA_SOPORTE}",
         "urgencia":"alta","tipo":"informe","accion":"ASESORAR","prioridad":"5","tono":"profesional",
         "attachments":[("evaluacion_brecha_seguridad.pdf","application/pdf",FAKE_PDF_B64)]},
        {"from_key":"sofia","sent_at":dt(2026,4,18,9,0),
         "subject":"Re: URGENTE: empleada abrió enlace phishing — SEGUIMIENTO",
         "body_text":f"Buenos días,\n\n¿Cómo va el análisis forense? ¿Podemos volver a usar el equipo?\n{firma_usuario('Sofía Castro Navarro','Grupo Logística del Norte S.L.','RRHH')}",
         "urgencia":"alta","tipo":"seguimiento","accion":"INFORMAR","prioridad":"5","tono":"preocupado"},
        {"from_key":"soporte","sent_at":dt(2026,4,18,11,0),
         "subject":"Re: URGENTE: empleada abrió enlace phishing — CERRADO",
         "body_text":f"Sofía,\n\nEl análisis forense ha concluido:\n- Sin malware ni ransomware detectado\n- Sin acceso a datos de clientes desde la cuenta comprometida\n- Sin movimiento lateral en la red\n\nEl equipo ALM-PC-03 está limpio y puede volver a usarse. Hemos actualizado el antivirus y habilitado la autenticación de doble factor para todas las cuentas.\n\nRecomendamos realizar una sesión de concienciación sobre phishing con todos los empleados. Podemos impartirla remotamente. ¿Le interesa?\n{FIRMA_SOPORTE}",
         "urgencia":"media","tipo":"resolucion","accion":"ASESORAR","prioridad":"3","tono":"profesional"},
        {"from_key":"sofia","sent_at":dt(2026,4,18,11,30),
         "subject":"Re: URGENTE: empleada abrió enlace phishing — CERRADO",
         "body_text":f"Qué alivio. Sí, nos interesa la sesión de concienciación. ¿La pueden hacer el próximo martes?\n{firma_usuario('Sofía Castro Navarro','Grupo Logística del Norte S.L.','RRHH')}",
         "urgencia":"baja","tipo":"consulta","accion":"PROGRAMAR","prioridad":"2","tono":"satisfecho"},
    ],
    thread_status="active",
    synthesis={
        "state_summary": estado("pendiente_accion",
            bloqueo="Pendiente programar sesión de concienciación sobre phishing",
            sintomas=["Empleada introdujo credenciales en web phishing","Equipo ALM-PC-03 comprometido potencialmente"],
            realizadas=["Cambio contraseña","Análisis forense limpio","2FA habilitado","Análisis AD sin compromiso"]),
        "short_text": "Incidente phishing DHL resuelto. Sin brecha de datos. Pendiente sesión formativa.",
        "acciones": [
            accion("PROGRAMAR_REUNION","Sesión concienciación phishing solicitada para próximo martes.",0.98),
            accion("ENVIAR_SEGUIMIENTO","Confirmar fecha sesión formativa.",0.90),
        ],
        "participantes": [participante("sofia",3), tecnico(4)],
        "urgencia":"critica","tono":"satisfecho",
    },
    glpi={"id":1046,"title":"Incidente phishing ALM-PC-03 — análisis forense y remediacíón","status":"2","priority":"5"},
)

# ─── HILO 10: WiFi lento en sala reuniones ───────────────────────────────────
create_thread(10,
    "WiFi muy lento en sala de reuniones principal",
    messages=[
        {"from_key":"miguel","sent_at":dt(2026,4,21,10,0),
         "subject":"WiFi muy lento en sala de reuniones principal",
         "body_text":f"Buenos días,\n\nEn la sala de reuniones principal el WiFi va muy lento, especialmente cuando hay más de 5 personas conectadas. Esto es un problema cuando hacemos videoconferencias con clientes.\n\nVelocidad medida: 2 Mbps. El contrato es de 300 Mbps.\n{firma_usuario('Miguel Ángel Blanco','Distribuidora Regional S.L.','Gerencia')}",
         "detalles":["Sala reuniones WiFi 2 Mbps medidos","300 Mbps contratados","Problema con >5 usuarios"],
         "urgencia":"alta","tipo":"incidencia_red","accion":"DIAGNOSTICAR","prioridad":"4","tono":"molesto"},
        {"from_key":"soporte","sent_at":dt(2026,4,21,11,0),
         "subject":"Re: WiFi muy lento en sala de reuniones principal",
         "body_text":f"Buenos días Miguel,\n\nHemos accedido al controlador WiFi y detectamos que el AP de la sala de reuniones (AP-SALA-01) lleva 47 días encendido sin reinicio y tiene saturación en el canal 6 (2,4 GHz). Vamos a cambiarlo al canal 11 en 5 GHz y programar reinicios automáticos semanales.\n\nSolución en 15 minutos. Habrá una breve interrupción del WiFi en esa zona.\n{FIRMA_SOPORTE}",
         "urgencia":"alta","tipo":"diagnostico_resolucion","accion":"RESOLVER","prioridad":"4","tono":"profesional"},
        {"from_key":"miguel","sent_at":dt(2026,4,21,11,30),
         "subject":"Re: WiFi muy lento en sala de reuniones principal",
         "body_text":f"Ahora mismo tenemos 180 Mbps en la sala. Perfecto. Gracias.\n{firma_usuario('Miguel Ángel Blanco','Distribuidora Regional S.L.','Gerencia')}",
         "urgencia":"baja","tipo":"confirmacion","accion":"CERRAR","prioridad":"1","tono":"satisfecho"},
    ],
    thread_status="archived",
    synthesis={
        "state_summary": estado("resuelto",
            sintomas=["AP saturado canal 2.4GHz","47 días sin reinicio"],
            realizadas=["Cambio canal 5GHz","Reinicio AP","Auto-reinicio semanal configurado"]),
        "short_text": "AP sala reuniones saturado en 2.4GHz. Migrado a 5GHz. Velocidad restaurada a 180 Mbps.",
        "acciones": [accion("CERRAR_TICKET","WiFi normalizado.",0.99)],
        "participantes": [participante("miguel",2), tecnico(1)],
        "urgencia":"alta","tono":"satisfecho",
    },
)

# ─── HILO 11: Solicitud nuevo usuario ────────────────────────────────────────
create_thread(11,
    "Alta de nuevo usuario — incorporación 1 mayo",
    messages=[
        {"from_key":"rosa","sent_at":dt(2026,4,22,9,0),
         "subject":"Alta de nuevo usuario — incorporación 1 mayo",
         "body_text":f"Hola,\n\nVamos a incorporar un nuevo docente el 1 de mayo:\n\n- Nombre: Jorge Pérez Valls\n- Puesto: Profesor de Matemáticas\n- Necesita: cuenta de correo institucional, acceso al aula virtual Moodle, impresora sala profesores y acceso a sala de ordenadores.\n\nGracias\n{firma_usuario('Rosa María Vidal','Academia de Formación Integral','Dirección')}",
         "detalles":["Nuevo usuario Jorge Pérez Valls","Incorporación 01/05","Moodle + correo + impresora"],
         "urgencia":"media","tipo":"solicitud_alta","accion":"PLANIFICAR","prioridad":"3","tono":"formal"},
        {"from_key":"soporte","sent_at":dt(2026,4,22,10,0),
         "subject":"Re: Alta de nuevo usuario — incorporación 1 mayo",
         "body_text":f"Buenos días Rosa,\n\nHemos registrado la solicitud de alta. Para completarla necesitamos:\n\n1. DNI del nuevo empleado (para generar usuario)\n2. ¿Nombre de usuario preferido? (ej. jperez, j.perez.valls)\n3. ¿Necesita equipo nuevo o reutilizará uno existente?\n\nTenemos hasta el 28 de abril para tenerlo todo listo.\n{FIRMA_SOPORTE}",
         "urgencia":"media","tipo":"solicitud_informacion","accion":"ESPERAR","prioridad":"3","tono":"profesional"},
        {"from_key":"rosa","sent_at":dt(2026,4,22,11,30),
         "subject":"Re: Alta de nuevo usuario — incorporación 1 mayo",
         "body_text":f"DNI: 45678912X. Usuario: jperez.valls. Usará el ordenador del aula 3B que quedó libre.\n{firma_usuario('Rosa María Vidal','Academia de Formación Integral','Dirección')}",
         "urgencia":"media","tipo":"respuesta","accion":"EJECUTAR","prioridad":"3","tono":"formal"},
        {"from_key":"soporte","sent_at":dt(2026,4,28,16,0),
         "subject":"Re: Alta de nuevo usuario — incorporación 1 mayo",
         "body_text":f"Rosa,\n\nTodo preparado para el 1 de mayo:\n\n✅ Cuenta de correo: jperez.valls@academia-formacion.es\n✅ Contraseña inicial: AcademiaInicio2026! (cambiar en primer acceso)\n✅ Acceso Moodle: rol Profesor, asignado a Matemáticas 1º y 2º\n✅ Impresora sala profesores configurada\n✅ Equipo aula 3B actualizado y con el perfil de usuario listo\n\nAdaptador USB-C incluido en el cajón del escritorio. ¡Bienvenido Jorge!\n{FIRMA_SOPORTE}",
         "urgencia":"baja","tipo":"resolucion","accion":"CERRAR","prioridad":"2","tono":"amigable"},
    ],
    thread_status="archived",
    synthesis={
        "state_summary": estado("resuelto",
            realizadas=["Cuenta correo creada","Moodle configurado","Equipo 3B preparado","Impresora asignada"]),
        "short_text": "Alta usuario Jorge Pérez Valls completada para incorporación 01/05.",
        "acciones": [accion("CERRAR_TICKET","Onboarding completo.",0.99)],
        "participantes": [participante("rosa",2), tecnico(2)],
        "urgencia":"media","tono":"amigable",
    },
)

# ─── HILO 12: Backup fallido ──────────────────────────────────────────────────
create_thread(12,
    "Backup nocturno fallido — últimas 3 noches",
    messages=[
        {"from_key":"soporte","sent_at":dt(2026,4,23,7,30),
         "subject":"Backup nocturno fallido — últimas 3 noches",
         "body_text":f"Buenos días,\n\nNuestro sistema de monitorización ha detectado que el backup nocturno del servidor principal ha fallado las últimas 3 noches (20, 21 y 22 de abril). El error es:\n\nVSS Error: 0x8004230F - VSS_E_UNEXPECTED_PROVIDER_ERROR\n\nVamos a investigar la causa y restaurar el proceso de backup.\n{FIRMA_SOPORTE}",
         "urgencia":"alta","tipo":"alerta_backup","accion":"DIAGNOSTICAR","prioridad":"4","tono":"urgente"},
        {"from_key":"juan","sent_at":dt(2026,4,23,9,0),
         "subject":"Re: Backup nocturno fallido — últimas 3 noches",
         "body_text":f"Buenos días,\n\nNo sabíamos que había un problema. ¿Tenemos los datos del 19 de abril al menos? ¿Hay riesgo de pérdida de datos?\n{firma_usuario('Juan Carlos Ortega','Industria Metal Levante S.A.','Dirección')}",
         "detalles":["VSS Error 0x8004230F","3 backups fallidos consecutivos"],
         "urgencia":"alta","tipo":"consulta","accion":"INFORMAR","prioridad":"4","tono":"preocupado"},
        {"from_key":"soporte","sent_at":dt(2026,4,23,10,30),
         "subject":"Re: Backup nocturno fallido — últimas 3 noches",
         "body_text":f"Juan Carlos,\n\nEl último backup exitoso es del 19 de abril a las 02:14 h — los datos de ese día están seguros.\n\nHemos identificado la causa: la instalación de un antivirus nuevo el 19 de abril interfiere con el proveedor VSS de Windows Server Backup. Solución: excluir el proceso de backup de la detección en tiempo real del antivirus.\n\nAplicando la corrección ahora. Esta noche verificaremos que el backup se completa correctamente.\n{FIRMA_SOPORTE}",
         "urgencia":"alta","tipo":"diagnostico_resolucion","accion":"RESOLVER","prioridad":"4","tono":"profesional"},
        {"from_key":"soporte","sent_at":dt(2026,4,24,7,15),
         "subject":"Re: Backup nocturno fallido — RESUELTO",
         "body_text":f"Juan Carlos,\n\nEl backup de esta noche se ha completado exitosamente a las 03:42 h (48 GB, duración 1h 28min). El problema estaba confirmado en la interferencia del antivirus con VSS.\n\nHemos configurado una alerta diaria por email si el backup falla. Quede tranquilo.\n{FIRMA_SOPORTE}",
         "urgencia":"baja","tipo":"resolucion","accion":"CONFIRMAR","prioridad":"2","tono":"profesional"},
        {"from_key":"juan","sent_at":dt(2026,4,24,8,0),
         "subject":"Re: Backup nocturno fallido — RESUELTO",
         "body_text":f"Muchas gracias. Me alegra saber que solo perdimos 3 noches sin backup y no hay datos perdidos. Bien hecho.\n{firma_usuario('Juan Carlos Ortega','Industria Metal Levante S.A.','Dirección')}",
         "urgencia":"baja","tipo":"confirmacion","accion":"CERRAR","prioridad":"1","tono":"satisfecho"},
    ],
    thread_status="archived",
    synthesis={
        "state_summary": estado("resuelto",
            sintomas=["VSS Error 0x8004230F 3 noches","Antivirus nuevo interfería con VSS"],
            realizadas=["Exclusión proceso backup en antivirus","Backup nocturno verificado OK","Alerta diaria configurada"]),
        "short_text": "Backup fallido 3 noches por conflicto antivirus-VSS. Resuelto con exclusión. Sin pérdida de datos.",
        "acciones": [accion("CERRAR_TICKET","Backup restaurado. Monitorización activa.",0.99)],
        "participantes": [tecnico(3), participante("juan",2)],
        "urgencia":"alta","tono":"satisfecho",
    },
    glpi={"id":1047,"title":"Backup nocturno — error VSS antivirus interferencia","status":"5","priority":"4"},
)

# ─── HILO 13: Outlook no sincroniza ──────────────────────────────────────────
create_thread(13,
    "Outlook no sincroniza el calendario con móvil",
    messages=[
        {"from_key":"cristina","sent_at":dt(2026,4,25,9,15),
         "subject":"Outlook no sincroniza calendario con móvil",
         "body_text":f"Hola,\n\nDesde hace una semana los eventos del calendario de Outlook (Exchange) no se sincronizan en mi iPhone. Otros compañeros no tienen este problema. La cuenta de correo sí llega bien al móvil.\n\nVersiones: Outlook 2021, iOS 17.4.\n{firma_usuario('Cristina Molina Reyes','Asesoría Fiscal & Legal','Socia')}",
         "detalles":["Calendario Exchange no sincroniza en iPhone","Correo OK, solo calendario falla","iOS 17.4 Outlook 2021"],
         "urgencia":"media","tipo":"incidencia_software","accion":"DIAGNOSTICAR","prioridad":"3","tono":"neutral"},
        {"from_key":"soporte","sent_at":dt(2026,4,25,10,0),
         "subject":"Re: Outlook no sincroniza calendario con móvil",
         "body_text":f"Buenos días Cristina,\n\nVamos a revisar la configuración del perfil Exchange en su iPhone. Por favor, siga estos pasos:\n\n1. Ajustes → Correo → su cuenta Exchange → Calendar: asegúrese de que está activado\n2. ¿Qué versión de iOS tiene exactamente? (Ajustes → General → Información)\n3. Intente eliminar y volver a añadir la cuenta Exchange en el iPhone\n\nSi no se resuelve, solicitaremos acceso remoto vía TeamViewer.\n{FIRMA_SOPORTE}",
         "urgencia":"media","tipo":"solicitud_informacion","accion":"DIAGNOSTICAR","prioridad":"3","tono":"profesional"},
        {"from_key":"cristina","sent_at":dt(2026,4,25,11,0),
         "subject":"Re: Outlook no sincroniza calendario con móvil",
         "body_text":f"iOS 17.4.1. He eliminado y vuelto a añadir la cuenta y ahora sí sincroniza. Parece que con eso se ha resuelto.\n{firma_usuario('Cristina Molina Reyes','Asesoría Fiscal & Legal','Socia')}",
         "urgencia":"baja","tipo":"confirmacion","accion":"CERRAR","prioridad":"1","tono":"satisfecho"},
    ],
    thread_status="archived",
    synthesis={
        "state_summary": estado("resuelto", realizadas=["Eliminar y re-añadir cuenta Exchange en iPhone"]),
        "short_text": "Calendario Exchange no sincronizaba en iPhone. Resuelto eliminando y re-añadiendo la cuenta.",
        "acciones": [accion("CERRAR_TICKET","Sincronización restaurada.",0.99)],
        "participantes": [participante("cristina",2), tecnico(1)],
        "urgencia":"media","tono":"satisfecho",
    },
)

# ─── HILO 14: Nuevo PC no arranca ─────────────────────────────────────────────
create_thread(14,
    "PC nuevo no arranca — pantalla azul BSOD",
    messages=[
        {"from_key":"roberto","sent_at":dt(2026,5,2,9,0),
         "subject":"PC nuevo HP Pavilion no arranca — pantalla azul",
         "body_text":f"Buenos días,\n\nAcabamos de recibir un PC nuevo (HP Pavilion 15-eh2xxx) y al intentar configurarlo aparece una pantalla azul con el error DRIVER_IRQL_NOT_LESS_OR_EQUAL. Hemos reiniciado varias veces y siempre aparece el mismo error.\n{firma_usuario('Roberto Herrero Sanz','Hotel Playa del Sol','Recepción')}",
         "detalles":["HP Pavilion 15-eh2xxx nuevo","BSOD DRIVER_IRQL_NOT_LESS_OR_EQUAL"],
         "urgencia":"alta","tipo":"incidencia_hardware","accion":"DIAGNOSTICAR","prioridad":"4","tono":"preocupado"},
        {"from_key":"soporte","sent_at":dt(2026,5,2,10,0),
         "subject":"Re: PC nuevo HP Pavilion no arranca — pantalla azul",
         "body_text":f"Buenos días Roberto,\n\nEl error DRIVER_IRQL_NOT_LESS_OR_EQUAL suele indicar un driver defectuoso. Dado que es un PC nuevo, posiblemente sea el driver de la tarjeta WiFi o de la tarjeta gráfica integrada.\n\nVamos a solicitar acceso remoto para analizar el minidump del BSOD. ¿Puede intentar arrancar en Modo Seguro? (F8 durante el arranque → Reparación → Opciones avanzadas → Inicio seguro)\n{FIRMA_SOPORTE}",
         "urgencia":"alta","tipo":"diagnostico","accion":"RESOLVER","prioridad":"4","tono":"profesional"},
        {"from_key":"roberto","sent_at":dt(2026,5,2,10,30),
         "subject":"Re: PC nuevo HP Pavilion no arranca — pantalla azul",
         "body_text":f"En modo seguro arranca correctamente. ¿Qué hago ahora?\n{firma_usuario('Roberto Herrero Sanz','Hotel Playa del Sol','Recepción')}",
         "urgencia":"alta","tipo":"respuesta","accion":"RESOLVER","prioridad":"4","tono":"neutral"},
        {"from_key":"soporte","sent_at":dt(2026,5,2,11,30),
         "subject":"Re: PC nuevo HP Pavilion no arranca — pantalla azul",
         "body_text":f"Perfecto. En modo seguro hemos podido conectarnos remotamente y hemos:\n\n1. Analizado el minidump: el driver culpable es rtx64w10.sys (Realtek WiFi)\n2. Descargado e instalado el driver actualizado desde la web de HP (v6.1.2.0)\n3. Reiniciado en modo normal\n\nEl equipo arranca correctamente ahora. Por favor confirme.\n{FIRMA_SOPORTE}",
         "urgencia":"alta","tipo":"resolucion","accion":"CONFIRMAR","prioridad":"4","tono":"profesional"},
        {"from_key":"roberto","sent_at":dt(2026,5,2,11,45),
         "subject":"Re: PC nuevo HP Pavilion no arranca — SOLUCIONADO",
         "body_text":f"Confirmo que arranca correctamente. Muchas gracias.\n{firma_usuario('Roberto Herrero Sanz','Hotel Playa del Sol','Recepción')}",
         "urgencia":"baja","tipo":"confirmacion","accion":"CERRAR","prioridad":"1","tono":"satisfecho"},
    ],
    thread_status="archived",
    synthesis={
        "state_summary": estado("resuelto",
            sintomas=["BSOD DRIVER_IRQL","Driver Realtek WiFi rtx64w10.sys defectuoso"],
            realizadas=["Análisis minidump","Actualización driver Realtek WiFi v6.1.2.0"]),
        "short_text": "BSOD en PC nuevo por driver Realtek WiFi. Actualización resolvió el problema.",
        "acciones": [accion("CERRAR_TICKET","PC operativo con driver actualizado.",0.98)],
        "participantes": [participante("roberto",3), tecnico(2)],
        "urgencia":"alta","tono":"satisfecho",
    },
)

# ─── HILO 15: Licencias Office caducadas ─────────────────────────────────────
create_thread(15,
    "Licencias Microsoft 365 caducadas — bloqueadas",
    messages=[
        {"from_key":"nuria","sent_at":dt(2026,5,5,8,30),
         "subject":"Office dice que la licencia ha expirado",
         "body_text":f"Buenos días,\n\nAl abrir Word y Excel aparece el mensaje 'La suscripción ha caducado. Para seguir usando Microsoft 365 renueve su suscripción.' Solo puedo ver los documentos en modo lectura. Afecta a los 5 ordenadores de la farmacia.\n{firma_usuario('Nuria Pons Castelló','Farmacia Central Pons','Titulada')}",
         "detalles":["Microsoft 365 caducado en 5 equipos","Solo lectura disponible","Farmacia afectada"],
         "urgencia":"alta","tipo":"incidencia_licencias","accion":"RESOLVER","prioridad":"4","tono":"urgente"},
        {"from_key":"soporte","sent_at":dt(2026,5,5,9,0),
         "subject":"Re: Office dice que la licencia ha expirado",
         "body_text":f"Buenos días Nuria,\n\nHemos revisado el portal Microsoft 365 y su suscripción Business Standard expiró el 3 de mayo. La factura de renovación fue enviada el 10 de abril al email de facturación pero no llegó a abonarse.\n\nPuede renovar inmediatamente en el portal de su cuenta (admin.microsoft.com) con tarjeta. Una vez abonada, las licencias se reactivarán automáticamente en 15-30 minutos. ¿Desea que le ayudemos con el proceso?\n{FIRMA_SOPORTE}",
         "urgencia":"alta","tipo":"informacion","accion":"INFORMAR","prioridad":"4","tono":"profesional"},
        {"from_key":"nuria","sent_at":dt(2026,5,5,9,30),
         "subject":"Re: Office dice que la licencia ha expirado",
         "body_text":f"Sí, necesito ayuda. La persona que gestiona las facturas está de vacaciones y no tengo acceso al portal de administración.\n{firma_usuario('Nuria Pons Castelló','Farmacia Central Pons','Titulada')}",
         "urgencia":"alta","tipo":"solicitud_apoyo","accion":"ASISTIR","prioridad":"4","tono":"neutral"},
        {"from_key":"soporte","sent_at":dt(2026,5,5,10,30),
         "subject":"Re: Office dice que la licencia ha expirado",
         "body_text":f"Nuria,\n\nHemos accedido al portal de administración con las credenciales de la cuenta admin. La renovación anual (5 licencias × 12 meses) asciende a 874,20 € + IVA.\n\n¿Podría proporcionar una tarjeta de pago para proceder con la renovación? También puede hacer una transferencia bancaria, aunque tardaría 1-2 días en activarse.\n{FIRMA_SOPORTE}",
         "urgencia":"alta","tipo":"solicitud","accion":"ESPERAR","prioridad":"4","tono":"profesional"},
        {"from_key":"nuria","sent_at":dt(2026,5,5,11,0),
         "subject":"Re: Office dice que la licencia ha expirado",
         "body_text":f"Voy a llamar a mi responsable para que autorice el pago con tarjeta. Le escribo en breve.\n{firma_usuario('Nuria Pons Castelló','Farmacia Central Pons','Titulada')}",
         "urgencia":"alta","tipo":"respuesta","accion":"ESPERAR","prioridad":"4","tono":"neutral"},
    ],
    thread_status="active",
    is_waiting=True,
    waiting_until=dt(2026,5,6,12,0),
    waiting_reason="Esperando autorización de pago con tarjeta del responsable de la farmacia",
    synthesis={
        "state_summary": estado("pendiente_cliente",
            bloqueo="Pendiente autorización de pago para renovar licencias Microsoft 365",
            sintomas=["5 licencias M365 caducadas","Solo modo lectura en todos los equipos"],
            realizadas=["Identificada factura no abonada","Importe renovación calculado 874.20€+IVA"]),
        "short_text": "M365 caducado. Esperando autorización de pago del responsable. 874€+IVA renovación anual.",
        "acciones": [
            accion("ENVIAR_SEGUIMIENTO","Confirmar si el responsable autorizó el pago.",0.95),
            accion("INFORMAR","Considerar transferencia bancaria como alternativa.",0.75),
        ],
        "participantes": [participante("nuria",3), tecnico(2)],
        "urgencia":"alta","tono":"neutral",
    },
)

# ─── HILOS 16-50: Generación de los restantes 35 hilos ────────────────────────
# Para mantener coherencia, los genero con un helper compacto

def simple_thread(idx, user_key, subject, issue, solution, sent_base,
                  n_msgs=3, status="active", has_synth=True, glpi_data=None,
                  urgencia="media", is_waiting=False, waiting_reason=None, waiting_days=3):
    """Crea un hilo simple con n_msgs mensajes."""
    waiting_until = (sent_base + timedelta(days=waiting_days)) if is_waiting else None
    user_name, user_email = USERS[user_key]
    msgs = []
    # Msg 1: usuario reporta
    msgs.append({
        "from_key": user_key,
        "sent_at": sent_base,
        "subject": subject,
        "body_text": f"Buenos días,\n\n{issue}\n{firma_usuario(user_name, user_email.split('@')[1])}",
        "detalles": [issue[:100]],
        "urgencia": urgencia,
        "tipo": "incidencia",
        "accion": "DIAGNOSTICAR",
        "prioridad": "4" if urgencia in ("alta","critica") else "3",
        "tono": "neutral",
    })
    if n_msgs >= 2:
        # Msg 2: soporte responde
        msgs.append({
            "from_key": "soporte",
            "sent_at": sent_base + timedelta(hours=1),
            "subject": subject,
            "body_text": f"Buenos días,\n\nHemos recibido su incidencia y vamos a investigar la causa del problema. En breve le daremos respuesta con el diagnóstico y la solución.{FIRMA_SOPORTE}",
            "urgencia": urgencia,
            "tipo": "diagnostico",
            "accion": "RESOLVER",
            "prioridad": "3",
            "tono": "profesional",
        })
    if n_msgs >= 3:
        # Msg 3: resolución
        msgs.append({
            "from_key": "soporte",
            "sent_at": sent_base + timedelta(hours=3),
            "subject": subject,
            "body_text": f"Buenas tardes,\n\n{solution}\n\n¿Puede confirmarnos que el problema está resuelto?{FIRMA_SOPORTE}",
            "urgencia": "baja",
            "tipo": "resolucion",
            "accion": "CONFIRMAR",
            "prioridad": "2",
            "tono": "profesional",
            "attachments": [("informe_soporte.pdf","application/pdf",FAKE_PDF_B64)] if idx % 5 == 0 else None,
        })
    if n_msgs >= 4:
        msgs.append({
            "from_key": user_key,
            "sent_at": sent_base + timedelta(hours=4),
            "subject": subject,
            "body_text": f"Confirmado, funciona correctamente. Muchas gracias por la rápida atención.{firma_usuario(user_name, user_email.split('@')[1])}",
            "urgencia": "baja",
            "tipo": "confirmacion",
            "accion": "CERRAR",
            "prioridad": "1",
            "tono": "satisfecho",
        })
    synth = None
    if has_synth:
        final_status = "resuelto" if status == "archived" else ("pendiente_cliente" if is_waiting else "en_proceso")
        synth = {
            "state_summary": estado(final_status,
                bloqueo=waiting_reason if is_waiting else None,
                realizadas=[solution[:100]]),
            "short_text": f"{subject}: {solution[:120]}",
            "acciones": [accion("CERRAR_TICKET" if status=="closed" else "ENVIAR_SEGUIMIENTO",
                                f"Pendiente de cierre: {subject[:80]}", 0.90)],
            "participantes": [participante(user_key, n_msgs//2), tecnico()],
            "urgencia": urgencia,
            "tono": "satisfecho" if status == "archived" else "neutral",
        }
    create_thread(idx, subject, msgs,
                  thread_status=status,
                  is_waiting=is_waiting,
                  waiting_until=waiting_until,
                  waiting_reason=waiting_reason,
                  synthesis=synth,
                  glpi=glpi_data)

# Generamos 35 hilos más con variedad temática
THREAD_DEFS = [
    # idx, user_key, subject, issue, solution, date, n_msgs, status, synth, glpi, urgencia, waiting, reason, wdays
    (16,"carlos","Error acceso aplicación de nóminas","No puedo acceder a la aplicación de nóminas A3 desde ayer. Error de conexión al servidor.","Hemos actualizado el cliente A3 Nóminas a la versión 11.2.1. El error era de incompatibilidad con el nuevo servidor SQL.",dt(2026,5,6,9,0),4,"archived",True,None,"alta",False,None,0),
    (17,"laura","Pantalla de PC con rayas verticales","La pantalla del PC de recepción tiene rayas verticales desde esta mañana. Molesta para trabajar.","La pantalla tiene el panel dañado. La hemos reemplazado por una nueva de 24 pulgadas igual modelo.",dt(2026,5,7,8,30),3,"archived",True,{"id":1048,"title":"Sustitución pantalla recepción","status":"5","priority":"3"},"media",False,None,0),
    (18,"antonio","Carpeta compartida no aparece en el explorador","La carpeta compartida \\\\SRV-DATOS01\\\\Proyectos2026 no aparece en el explorador de Windows de mi equipo.","Hemos reasignado los permisos de acceso a su usuario en el servidor. La carpeta ahora es visible y accesible.",dt(2026,5,8,10,0),3,"archived",True,None,"media",False,None,0),
    (19,"elena","Solicitud certificado SSL página web","Nuestro certificado SSL de la web del despacho caduca el 15 de mayo. Necesitamos renovarlo.","Hemos renovado el certificado SSL Let's Encrypt (3 años) y configurado la renovación automática. La web muestra candado verde.",dt(2026,5,9,9,0),4,"archived",True,{"id":1049,"title":"Renovación SSL despacho-abogados.es","status":"5","priority":"3"},"media",False,None,0),
    (20,"pablo","Impresora A3 sin tóner — urgente obra","La impresora A3 de la oficina técnica se ha quedado sin tóner y necesitamos imprimir los planos de la obra urgentemente.","El tóner compatible CF237A ha sido entregado e instalado. Impresora operativa.",dt(2026,5,12,11,0),3,"archived",True,None,"alta",False,None,0),
    (21,"ana","Portal del empleado no carga — error 500","El portal del empleado del ayuntamiento devuelve Error 500 Internal Server Error desde esta mañana. Varios usuarios afectados.","El servicio de aplicaciones IIS se detuvo por un error en la actualización del módulo ASP.NET. Revertido y reiniciado correctamente.",dt(2026,5,13,8,0),4,"archived",True,{"id":1050,"title":"Error 500 portal empleado ayuntamiento","status":"5","priority":"4"},"alta",False,None,0),
    (22,"david","Scanner no reconocido por sistema","El escáner Canon DR-S130 de consultas no aparece en el sistema. Necesitamos digitalizar historiales.","Driver Canon DR-Series reinstalado. El escáner aparece correctamente en el panel de dispositivos y funciona.",dt(2026,5,14,9,0),3,"archived",True,None,"media",False,None,0),
    (23,"sofia","Migración datos NAS antiguo a nuevo","Necesitamos migrar 2 TB de datos del NAS antiguo (Synology DS218) al nuevo (Synology DS923+).","Migración completada en horario nocturno (8 horas). 1.87 TB transferidos sin errores. Integridad verificada con checksums.",dt(2026,5,15,10,0),5,"archived",True,{"id":1051,"title":"Migración NAS DS218→DS923+ 2TB","status":"5","priority":"3"},"media",False,None,0),
    (24,"miguel","Actualización firmware routers sucursales","Necesitamos actualizar el firmware de los 4 routers MikroTik de las sucursales por una vulnerabilidad crítica.","Firmware RouterOS 7.14.3 instalado en los 4 routers durante ventana de mantenimiento. CVE-2024-XXXX mitigada.",dt(2026,5,16,10,0),4,"archived",True,{"id":1052,"title":"Actualización firmware routers — CVE crítica","status":"5","priority":"5"},"critica",False,None,0),
    (25,"rosa","Error sincronización Moodle con Google Classroom","La sincronización automática entre Moodle y Google Classroom falla desde la actualización de Moodle 4.3.","El plugin de integración OAuth2 necesitaba regenerar los tokens. Renovados y sincronización funcionando.",dt(2026,5,19,9,0),3,"archived",True,None,"media",False,None,0),
    (26,"juan","Cortafuegos bloqueando ERP — nueva versión","Tras instalar la nueva versión del ERP (SAP B1 10.0 PL05) el cortafuegos bloquea las conexiones al servidor de BD.","Añadidas reglas de firewall para el nuevo rango de puertos 40000-40099 que usa SAP B1 10.0 PL05.",dt(2026,5,20,8,0),4,"archived",True,{"id":1053,"title":"Firewall bloqueando SAP B1 10.0 PL05","status":"5","priority":"4"},"alta",False,None,0),
    (27,"cristina","Solicitud ampliación buzón correo — 50 GB","El buzón de correo de la socia tiene 48 GB y ya no puede recibir correos nuevos.","Ampliado el buzón de Exchange a 100 GB. Los correos que rebotaban los últimos días han sido reenviados por los remitentes.",dt(2026,5,21,9,0),3,"archived",True,None,"alta",False,None,0),
    (28,"roberto","Sistema TPV no conecta con central","Los terminales TPV del hotel no pueden conectar con el sistema central de reservas desde el cambio de IP del ISP.","Actualizada la IP del servidor central en la configuración del middleware del TPV. Todos los terminales conectan.",dt(2026,5,22,7,30),4,"archived",True,{"id":1054,"title":"TPV hotel — fallo conectividad IP cambio ISP","status":"5","priority":"5"},"critica",False,None,0),
    (29,"nuria","Receta electrónica — aplicación no responde","La aplicación de receta electrónica de la Conselleria de Salut se cuelga al intentar imprimir recetas.","El problema estaba en la caché de Java Web Start. Limpieza de caché y reinstalación del plugin resolvieron el cuelgue.",dt(2026,5,23,9,0),3,"archived",True,None,"alta",False,None,0),
    (30,"maria","Solicitud segundo monitor — teletrabajo","Para el trabajo en remoto necesito un segundo monitor. ¿Pueden facilitarme uno y el soporte para instalarlo?","Enviado monitor LG 24MP60G-B con soporte VESA y cable HDMI al domicilio. Configuración dual screen mediante Teams.",dt(2026,5,26,10,0),3,"archived",True,None,"baja",False,None,0),
    (31,"carlos","Equipo sin acceso a internet — solo red local","Mi equipo tiene acceso a los recursos internos pero no puede navegar por internet desde ayer.","La puerta de enlace por defecto estaba incorrectamente configurada a .255 en lugar de .1 tras actualización DHCP. Corregida.",dt(2026,5,27,9,0),4,"archived",True,None,"media",False,None,0),
    (32,"laura","Solicitud configuración Teams Rooms — sala conferencias","Vamos a habilitar la sala de conferencias como Microsoft Teams Room. Necesitamos la configuración del sistema.","Teams Rooms configurado en Surface Hub 2S. Sala añadida al directorio de salas del tenant M365.",dt(2026,5,28,10,0),5,"archived",True,{"id":1055,"title":"Configuración Microsoft Teams Rooms sala A","status":"5","priority":"3"},"media",False,None,0),
    (33,"antonio","Ransomware detectado — archivos .encrypted","ALERTA: Varios archivos de mi equipo tienen extensión .encrypted y un txt con instrucciones de rescate.",
     "Equipo aislado, ransomware LockBit 3.0 contenido. Restauración desde backup del día anterior. Sin pago de rescate. Análisis forense completo.",
     dt(2026,6,2,8,10),7,"archived",True,{"id":1056,"title":"INCIDENTE: Ransomware LockBit 3.0 contenido","status":"5","priority":"5"},"critica",False,None,0),
    (34,"elena","Enlace fibra óptica cortado — sin conectividad","Desde las 6:00 h no tenemos conectividad a internet. El ONT muestra luz roja.","Avería en línea de fibra reportada a Vodafone. Técnico enviado. Fibra reparada a las 14:30h. Tiempo de resolución: 8h30min.",dt(2026,6,3,6,30),5,"archived",True,{"id":1057,"title":"Corte fibra óptica despacho — Vodafone avería","status":"5","priority":"5"},"critica",False,None,0),
    (35,"pablo","Solicitud inventario equipos informáticos","Necesitamos un inventario actualizado de todos los equipos informáticos para el seguro.","Inventario completo generado con GLPI: 47 equipos, 12 impresoras, 8 switches, 4 servidores. Excel adjunto.",dt(2026,6,4,10,0),3,"archived",True,None,"baja",False,None,0),
    (36,"ana","Web municipal caída por actualización WordPress","La web del ayuntamiento ha quedado en blanco tras actualizar un plugin de WordPress.","Plugin Elementor v3.21 incompatible con PHP 8.2. Revertido a v3.20.5. Web restaurada.",dt(2026,6,5,9,0),4,"archived",True,{"id":1058,"title":"Web ayuntamiento — plugin Elementor incompatible","status":"5","priority":"4"},"alta",False,None,0),
    (37,"david","Cámara IP consultas sin imagen","La cámara de seguridad IP de la sala de espera de consultas no muestra imagen desde el lunes.","Cámara reiniciada remotamente y firmware actualizado. Imagen restaurada. Contraseña por defecto cambiada.",dt(2026,6,6,9,0),3,"archived",True,None,"media",False,None,0),
    (38,"sofia","Configuración VPN para nuevo almacén","Abrimos un segundo almacén y necesitamos configurar la VPN site-to-site con la sede central.","VPN IPSec site-to-site configurada entre HQ y almacén 2. Latencia <10ms. Todos los servicios accesibles.",dt(2026,6,9,10,0),5,"archived",True,{"id":1059,"title":"VPN site-to-site almacén 2","status":"5","priority":"3"},"media",False,None,0),
    (39,"miguel","Solicitud formación Microsoft 365 para equipo","Queremos una formación práctica de Teams, SharePoint y OneDrive para 8 personas.","Formación programada: 4 sesiones de 2h online los martes de julio. Material incluido.",dt(2026,6,10,10,0),4,"active",True,None,"baja",False,None,0),
    (40,"rosa","Error exportar notas a PDF — Moodle","Al exportar las notas del trimestre a PDF desde Moodle, el archivo sale en blanco.","Error en la librería mPDF de Moodle 4.3. Hotfix aplicado desde el repositorio oficial.",dt(2026,6,11,9,0),3,"archived",True,None,"media",False,None,0),
    (41,"juan","Impresora etiquetas Zebra sin comunicación","La impresora Zebra ZD420 para etiquetas de producción no comunica con el sistema de gestión.","Puerto COM3 había cambiado a COM7 tras actualización de Windows. Reconfigurada en ZebraDesigner.",dt(2026,6,12,8,0),3,"archived",True,None,"alta",False,None,0),
    (42,"cristina","Actualización política contraseñas — dudas","Hemos recibido aviso de que la política de contraseñas cambia el 1 de julio. ¿Cómo afecta a los usuarios?","Enviada guía de nueva política: 12 car. mínimo, sin historial de 24 contraseñas, 2FA obligatorio para accesos externos.",dt(2026,6,13,10,0),3,"active",True,None,"baja",False,None,0),
    (43,"roberto","Sistema domótica hotel no responde — HVAC","El sistema de control de temperatura (HVAC) de las habitaciones 301-320 no responde desde el controlador central.","Gateway KNX reiniciado. Canales HVAC 301-320 reprogramados. Temperatura estable en 22°C.",dt(2026,6,16,7,0),4,"archived",True,{"id":1060,"title":"HVAC habitaciones 301-320 — fallo gateway KNX","status":"5","priority":"4"},"alta",False,None,0),
    (44,"nuria","Necesitamos instalar sistema TPV farmacia","Vamos a cambiar el software de gestión de farmacia a Farmatic 2026. Necesitan instalar el servidor y los clientes en 3 puestos.","Servidor Farmatic 2026 instalado y configurado. 3 puestos de trabajo con cliente conectado. Migración de datos desde Farmasist completada.",dt(2026,6,17,9,0),6,"active",True,{"id":1061,"title":"Instalación Farmatic 2026 — farmacia 3 puestos","status":"2","priority":"3"},"media",False,None,0),
    (45,"maria","PC de contabilidad muy lento — SSD dañado","El PC de contabilidad va extremadamente lento. CrystalDiskInfo muestra estado del SSD en CAUTION.","SSD Samsung 870 EVO reemplazado por 1TB. Clonado el disco antes de la sustitución. Sin pérdida de datos.",dt(2026,6,18,9,0),4,"archived",True,{"id":1062,"title":"Sustitución SSD contabilidad — estado CAUTION","status":"5","priority":"4"},"alta",False,None,0),
    (46,"carlos","Propuesta renovación parque informático 2026","Solicitamos una auditoría del parque informático y presupuesto para renovar los equipos con más de 5 años de antigüedad.",
     "Auditoría en progreso. 12 equipos identificados para renovar. Presupuesto aproximado 18.400€. Propuesta formal en preparación.",
     dt(2026,6,19,10,0),3,"active",True,None,"baja",
     True,"Esperando aprobación presupuestaria por gerencia",30),
    (47,"laura","Error en certificado raíz CA interna — todos los navegadores","Todos los usuarios ven el error 'Conexión no segura' al acceder a aplicaciones internas.","Certificado raíz CA renovado y desplegado via GPO en todos los equipos del dominio. Error desaparecido.",dt(2026,6,20,8,0),4,"archived",True,{"id":1063,"title":"CA interna — certificado raíz caducado GPO","status":"5","priority":"5"},"critica",False,None,0),
    (48,"antonio","Solicitud soporte presencial — configuración sala formación","El aula de formación necesita que se configure el sistema de proyección dual y los portátiles para el curso del 30 de junio.","Sala configurada: proyector dual 4K, 15 portátiles con imagen corporativa, WiFi dedicado SSID Formacion2026.",dt(2026,6,21,10,0),3,"active",True,None,"media",True,"Esperando confirmación número de asistentes para calibrar WiFi",5),
    (49,"elena","Migración servidor Exchange a Microsoft 365","Iniciamos la migración del servidor Exchange 2016 on-premise a Microsoft 365 Business Premium (25 usuarios).","En progreso: fase 1 completada (coexistencia DNS). Fase 2 (migración buzones) programada del 28 jun al 5 jul.",dt(2026,6,21,9,0),5,"active",True,{"id":1064,"title":"Migración Exchange 2016 → M365 Business Premium 25u","status":"2","priority":"4"},"alta",False,None,0),
    (50,"pablo","Incidencia calor extremo CPD — temperatura crítica","ALERTA: La sonda de temperatura del CPD marca 38°C. El aire acondicionado ha fallado.","Aire acondicionado Liebert reparado (filtro obstruido). Temperatura estable en 21°C. Sin daño en equipos. Mantenimiento preventivo programado.",dt(2026,6,21,11,0),4,"active",True,{"id":1065,"title":"CPD — AC Liebert fallo temperatura 38°C","status":"2","priority":"5"},"critica",False,None,0),
]

for row in THREAD_DEFS:
    idx, user_key, subject, issue, solution, sent_base, n_msgs, status, has_synth, glpi_data, urgencia, is_waiting, waiting_reason, wdays = row
    simple_thread(idx, user_key, subject, issue, solution, sent_base,
                  n_msgs=n_msgs, status=status, has_synth=has_synth,
                  glpi_data=glpi_data, urgencia=urgencia,
                  is_waiting=is_waiting, waiting_reason=waiting_reason,
                  waiting_days=wdays)

conn.commit()
cur.close()
conn.close()


print(f"✅ 50 hilos sintéticos generados correctamente en cuenta ID={ACCOUNT_ID}")
print(f"   EML almacenados en: {EML_BASE}")
