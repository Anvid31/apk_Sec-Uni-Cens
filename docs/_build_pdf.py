#!/usr/bin/env python3
import base64, pathlib, subprocess

BASE    = pathlib.Path(__file__).parent
SCREENS = BASE / "screens"
OUT_PDF = BASE / "MANUAL_USUARIO.pdf"

def img(name):
    data = base64.b64encode((SCREENS / name).read_bytes()).decode()
    return f"data:image/png;base64,{data}"

I = {
    "home":      img("01_pantalla_principal.png"),
    "fase1a":    img("02_fase1_info_general.png"),
    "fase1b":    img("03_fase1_ubicacion_fotos.png"),
    "fase2":     img("04_fase2_dotacion.png"),
    "fase3":     img("05_fase3_energia.png"),
    "fase4":     img("06_fase4_agua.png"),
    "fase5":     img("07_fase5_riesgo.png"),
    "enviado":   img("08_envio_exitoso.png"),
    "offline":   img("08b_guardado_offline.png"),
    "historial": img("09_historial.png"),
}

CSS = """
*, *::before, *::after { box-sizing: border-box; margin: 0; padding: 0; }
body { font-family: "Segoe UI", Arial, sans-serif; font-size: 10.5pt; line-height: 1.65; color: #1a1c19; }
@page { size: A4; margin: 18mm 16mm 20mm 16mm; }

.cover { page-break-after: always; display: flex; flex-direction: column;
  align-items: center; justify-content: center; min-height: 250mm; text-align: center; }
.cover-bar { width: 100%; height: 10px;
  background: linear-gradient(90deg,#1b5e20,#4caf50,#1b5e20);
  margin-bottom: 40px; -webkit-print-color-adjust: exact; print-color-adjust: exact; }
.cover-icon { font-size: 72px; margin-bottom: 20px; }
.cover-title { font-size: 28pt; font-weight: 800; color: #1b5e20; margin-bottom: 8px; }
.cover-sub { font-size: 14pt; color: #2e7d32; margin-bottom: 32px; }
.cover-meta { font-size: 10pt; color: #555; line-height: 1.9;
  background: #f1f8e9; border-radius: 8px; padding: 16px 28px;
  -webkit-print-color-adjust: exact; print-color-adjust: exact; }
.cover-footer { margin-top: 48px; font-size: 9pt; color: #999; }

h1 { font-size: 17pt; color: #1b5e20; margin: 0 0 6px 0; padding-bottom: 6px;
  border-bottom: 3px solid #4caf50; page-break-before: always; page-break-after: avoid;
  -webkit-print-color-adjust: exact; print-color-adjust: exact; }
h1:first-of-type { page-break-before: avoid; }
h2 { font-size: 12.5pt; color: #1b5e20; margin: 22px 0 8px 0; padding: 6px 12px;
  background: #e8f5e9; border-left: 5px solid #2e7d32; border-radius: 0 4px 4px 0;
  page-break-after: avoid; -webkit-print-color-adjust: exact; print-color-adjust: exact; }
h3 { font-size: 11pt; color: #2e7d32; margin: 16px 0 5px 0;
  padding-bottom: 3px; border-bottom: 1px solid #c8e6c9; page-break-after: avoid; }
h4 { font-size: 10.5pt; color: #388e3c; margin: 12px 0 4px 0; page-break-after: avoid; }

p  { margin: 4px 0 9px 0; }
ul, ol { margin: 4px 0 9px 0; padding-left: 22px; }
li { margin-bottom: 3px; }

table { width: 100%; border-collapse: collapse; margin: 10px 0 14px 0;
  font-size: 9.5pt; page-break-inside: avoid; }
thead tr { background: #2e7d32; color: #fff;
  -webkit-print-color-adjust: exact; print-color-adjust: exact; }
thead th { padding: 6px 9px; text-align: left; font-weight: 600; }
tbody tr:nth-child(even) { background: #f1f8e9;
  -webkit-print-color-adjust: exact; print-color-adjust: exact; }
tbody td { padding: 5px 9px; border-bottom: 1px solid #dcedc8; vertical-align: top; }

blockquote { background: #fff8e1; border-left: 5px solid #f9a825;
  padding: 7px 12px; margin: 8px 0; border-radius: 0 4px 4px 0; font-size: 9.5pt;
  -webkit-print-color-adjust: exact; print-color-adjust: exact; }
blockquote p { margin: 0; }
.alert-red { background: #ffebee; border-left: 5px solid #c62828;
  padding: 7px 12px; margin: 8px 0; border-radius: 0 4px 4px 0; font-size: 9.5pt;
  -webkit-print-color-adjust: exact; print-color-adjust: exact; }

code { background: #f5f5f5; padding: 1px 4px; border-radius: 3px;
  font-family: "Courier New", monospace; font-size: 9pt; color: #c62828; }
strong { color: #1b5e20; font-weight: 700; }

.screens-row { display: flex; gap: 14px; justify-content: center;
  align-items: flex-start; margin: 16px 0; page-break-inside: avoid; }
.screen-wrap { display: flex; flex-direction: column; align-items: center; gap: 5px; }
.screen-img { width: 155px; border-radius: 18px;
  box-shadow: 0 4px 14px rgba(0,0,0,.22); border: 1px solid #e0e0e0; }
.screen-cap { font-size: 8pt; color: #555; text-align: center;
  max-width: 155px; font-style: italic; }
hr { border: none; border-top: 1.5px solid #c8e6c9; margin: 20px 0; }
"""

HTML = f"""<!DOCTYPE html>
<html lang="es">
<head><meta charset="UTF-8"><title>Manual CENS</title>
<style>{CSS}</style></head>
<body>

<div class="cover">
  <div class="cover-bar"></div>
  <div class="cover-icon">📋</div>
  <div class="cover-title">CENS Caracterización</div>
  <div class="cover-sub">Manual de Usuario</div>
  <div class="cover-meta">
    <strong>Sistema:</strong> Android (APK)<br>
    <strong>Proyecto:</strong> Caracterización de Sedes Educativas — Norte de Santander<br>
    <strong>Versión del documento:</strong> Septiembre 2026<br>
    <strong>Público:</strong> Encuestadores y coordinadores de campo
  </div>
  <div class="cover-footer">Documento de uso interno del proyecto CENS</div>
</div>

<!-- 1 -->
<h1>1. Descripción general</h1>
<p><strong>CENS Caracterización</strong> es una aplicación móvil Android que permite registrar información detallada sobre sedes educativas del departamento de Norte de Santander. Al abrirse, va directamente a la pantalla principal. El formulario tiene <strong>cinco fases</strong>:</p>
<table>
  <thead><tr><th>Fase</th><th>Tema</th><th>Contenido principal</th></tr></thead>
  <tbody>
    <tr><td>1</td><td>Información General</td><td>Datos de la sede, entrevistado, GPS, fotos</td></tr>
    <tr><td>2</td><td>Dotación</td><td>Servicios, infraestructura, mobiliario</td></tr>
    <tr><td>3</td><td>Energía</td><td>Fuente eléctrica, electrodomésticos</td></tr>
    <tr><td>4</td><td>Agua y Saneamiento</td><td>Fuentes de agua, sanitarios, higiene</td></tr>
    <tr><td>5</td><td>Riesgo</td><td>Continuidad escolar, amenazas, trayectos</td></tr>
  </tbody>
</table>
<p>La app funciona <strong>sin conexión</strong> en campo: guarda los formularios localmente y los sincroniza automáticamente al detectar red.</p>

<!-- 2 -->
<h1>2. Requisitos del dispositivo</h1>
<table>
  <thead><tr><th>Elemento</th><th>Mínimo recomendado</th></tr></thead>
  <tbody>
    <tr><td>Sistema operativo</td><td>Android 8.0 (API 26) o superior</td></tr>
    <tr><td>Memoria RAM</td><td>2 GB</td></tr>
    <tr><td>Almacenamiento libre</td><td>100 MB</td></tr>
    <tr><td>Cámara</td><td>Trasera con autofoco</td></tr>
    <tr><td>GPS</td><td>Integrado</td></tr>
    <tr><td>Conexión a internet</td><td>Opcional en campo; necesaria para sincronizar</td></tr>
  </tbody>
</table>

<!-- 3 -->
<h1>3. Permisos requeridos</h1>
<h3>3.1 Ubicación (GPS)</h3>
<ul>
  <li><strong>Para qué:</strong> capturar automáticamente latitud y longitud en la Fase 1.</li>
  <li><strong>Cuándo se solicita:</strong> al pulsar el botón 🎯 en el campo de coordenadas.</li>
  <li><strong>Si se niega:</strong> las coordenadas se ingresan manualmente.</li>
  <li><strong>Habilitarlo:</strong> Configuración → Aplicaciones → CENS Caracterización → Permisos → Ubicación → "Solo al usar la aplicación".</li>
</ul>
<h3>3.2 Cámara</h3>
<ul>
  <li><strong>Para qué:</strong> tomar o seleccionar fotos de la sede en la Fase 1.</li>
  <li><strong>Cuándo se solicita:</strong> al tocar cualquier campo de fotografía.</li>
  <li><strong>Si se niega:</strong> no se pueden adjuntar fotos.</li>
  <li><strong>Habilitarlo:</strong> Configuración → Aplicaciones → CENS Caracterización → Permisos → Cámara → Permitir.</li>
</ul>
<blockquote><p><strong>Tip:</strong> Active el GPS antes de iniciar el formulario para mayor precisión al capturar coordenadas.</p></blockquote>

<!-- 4 -->
<h1>4. Instalación de la APK</h1>
<p>La aplicación se distribuye directamente por el equipo CENS (no está en Google Play):</p>
<ol>
  <li>Descargue el archivo <code>.apk</code> en el dispositivo (correo, WhatsApp o enlace del administrador).</li>
  <li>Abra el archivo desde el administrador de archivos.</li>
  <li>Si Android muestra "Instalar de fuentes desconocidas", siga las instrucciones de pantalla y regrese a instalar.</li>
  <li>Toque <strong>Instalar</strong> y espere.</li>
  <li>Toque <strong>Abrir</strong> — la app inicia directamente en la pantalla principal.</li>
</ol>

<!-- 5 -->
<h1>5. Pantalla principal</h1>
<p>Al abrir la aplicación aparece directamente la pantalla principal, sin ningún paso previo.</p>

<div class="screens-row">
  <div class="screen-wrap">
    <img class="screen-img" src="{I['home']}" alt="Pantalla principal">
    <div class="screen-cap">Pantalla principal con indicador de sincronización</div>
  </div>
</div>

<table>
  <thead><tr><th>Elemento</th><th>Descripción</th></tr></thead>
  <tbody>
    <tr><td><strong>Tarjeta "Estado de Sincronización"</strong></td><td>Muestra conectividad (Online/Offline), encuestas pendientes y última sincronización. Si hay pendientes con red disponible, aparece "Sincronizar ahora".</td></tr>
    <tr><td><strong>Formulario de Caracterización</strong></td><td>Abre el formulario de 5 fases.</td></tr>
    <tr><td><strong>Historial</strong></td><td>Consulta encuestas enviadas y pendientes.</td></tr>
  </tbody>
</table>

<!-- 6 -->
<h1>6. Formulario de Caracterización</h1>
<p>Consta de <strong>5 fases</strong> en orden secuencial. En la parte superior se muestra la barra de progreso. El botón <strong>Anterior</strong> permite regresar sin perder datos. Los campos con <strong>*</strong> son obligatorios.</p>

<h2>Fase 1 — Información General</h2>
<div class="screens-row">
  <div class="screen-wrap">
    <img class="screen-img" src="{I['fase1a']}" alt="Fase 1a">
    <div class="screen-cap">Municipio, zona, institución y código DANE</div>
  </div>
  <div class="screen-wrap">
    <img class="screen-img" src="{I['fase1b']}" alt="Fase 1b">
    <div class="screen-cap">GPS, tipo de acceso, cobertura y fotos</div>
  </div>
</div>

<h4>Información automática</h4>
<p>La <strong>fecha</strong> y el <strong>departamento</strong> (Norte de Santander) se registran automáticamente y no son editables.</p>

<h4>Datos del Entrevistado</h4>
<p>Nombre, cargo y contacto de la persona entrevistada (todos opcionales).</p>

<h4>Sede Educativa (campos obligatorios)</h4>
<p>Seleccione en cascada: <strong>Municipio → Zona → Institución → Sede</strong>. El <strong>Código DANE</strong> se completa automáticamente. En zona Rural aparecen los campos de Corregimiento y Vereda.</p>

<h4>Ubicación y Acceso</h4>
<ul>
  <li><strong>GPS:</strong> toque 🎯 para captura automática, o ingrese latitud/longitud manualmente.</li>
  <li><strong>Tipo de acceso:</strong> selección múltiple (Vehicular, Fluvial, Camino Herradura).</li>
  <li><strong>Observaciones:</strong> ruta de llegada con referencias locales.</li>
  <li><strong>Proyectos recientes:</strong> obras ejecutadas en los últimos 2 años y entidad responsable.</li>
</ul>

<h4>Cobertura</h4>
<p>Niveles educativos presentes (selección múltiple): Preescolar, Básica Primaria, Básica Secundaria, Media.</p>

<h4>Registro Fotográfico</h4>
<p>Tome o seleccione fotos para: frente, Aula 1, Aula 2, Cocina (si aplica), Comedor y Baño principal. Toque el campo para elegir entre cámara o galería.</p>

<h2>Fase 2 — Dotación</h2>
<div class="screens-row">
  <div class="screen-wrap">
    <img class="screen-img" src="{I['fase2']}" alt="Fase 2">
    <div class="screen-cap">Inventario con clasificación Bueno / Regular / Malo</div>
  </div>
</div>

<h4>Servicios Públicos</h4>
<p>Sí/No para gas (fuente si Sí) e internet (nombre del proveedor si Sí).</p>

<h4>Infraestructura — Espacios</h4>
<p>Para cada espacio (salones, comedor, cocina, salón de reuniones, habitaciones): Sí/No y, si Sí, cantidad y estado. Puede agregar "Otros espacios" (biblioteca, laboratorio…).</p>

<h4>Ítems de Mobiliario</h4>
<table>
  <thead><tr><th>Color</th><th>Estado</th><th>Criterio</th></tr></thead>
  <tbody>
    <tr><td style="color:#2e7d32"><strong>Verde</strong></td><td>Bueno</td><td>Sin daños, en óptimas condiciones</td></tr>
    <tr><td style="color:#e65100"><strong>Naranja</strong></td><td>Regular</td><td>Desgaste menor, pero funcional</td></tr>
    <tr><td style="color:#c62828"><strong>Rojo</strong></td><td>Malo</td><td>Deteriorado, roto o inservible</td></tr>
  </tbody>
</table>
<p>El campo <strong>Necesidades</strong> (Regular + Malo) se calcula automáticamente.</p>

<h4>Dotación Especial</h4>
<p>Equipamiento de cocina/comedor (con estado) y mobiliario para atención de emergencias.</p>

<h2>Fase 3 — Energía</h2>
<div class="screens-row">
  <div class="screen-wrap">
    <img class="screen-img" src="{I['fase3']}" alt="Fase 3">
    <div class="screen-cap">Fuente eléctrica y electrodomésticos disponibles</div>
  </div>
</div>

<p>Indique si hay energía eléctrica y seleccione la fuente: Red CENS, vivienda cercana, conexión irregular, planta eléctrica, energías renovables o red artesana. Si es <strong>Red CENS</strong>: número de cliente y calidad del servicio. Para cada electrodoméstico indique si existe y la cantidad.</p>

<h2>Fase 4 — Agua y Saneamiento</h2>
<div class="screens-row">
  <div class="screen-wrap">
    <img class="screen-img" src="{I['fase4']}" alt="Fase 4">
    <div class="screen-cap">Fuente de agua, calidad y condiciones sanitarias</div>
  </div>
</div>

<p><strong>Agua:</strong> fuente principal y alternativa, frecuencia de disponibilidad, calidad percibida, y —si hay almacenamiento— material y capacidad del tanque.</p>
<p><strong>Saneamiento:</strong> total de sanitarios por tipo de usuario, tipo de dispositivo, gestión de residuos y prácticas de higiene.</p>

<h2>Fase 5 — Riesgo</h2>
<div class="screens-row">
  <div class="screen-wrap">
    <img class="screen-img" src="{I['fase5']}" alt="Fase 5">
    <div class="screen-cap">Preguntas sensibles: continuidad y amenazas</div>
  </div>
</div>

<div class="alert-red">
  <strong>⚠ Protocolo sensible:</strong> Lea cada pregunta en voz alta y marque <em>solo</em> lo que la persona indique. No solicite ni registre nombres propios, lugares ni detalles de incidentes. Si prefiere no responder, seleccione esa opción.
</div>

<ul>
  <li><strong>Continuidad:</strong> ¿suspendió clases en los últimos 12 meses? Si sí: días y causa(s).</li>
  <li><strong>Amenazas:</strong> selección múltiple de situaciones que podrían afectar la sede; luego las 3 más prioritarias.</li>
  <li><strong>Trayectos:</strong> cómo llegan los estudiantes, duración, condiciones de riesgo en el recorrido.</li>
  <li><strong>Ruta de aviso:</strong> a quién avisa ante emergencias, por qué medio y si obtuvo respuesta.</li>
  <li><strong>Actualización:</strong> cargo del responsable de los PGIR y frecuencia de actualización.</li>
</ul>

<!-- 7 -->
<h1>7. Envío del formulario</h1>
<p>Al completar la Fase 5, toque <strong>Enviar formulario</strong>. Aparecerá uno de estos dos diálogos:</p>

<div class="screens-row">
  <div class="screen-wrap">
    <img class="screen-img" src="{I['enviado']}" alt="Enviado">
    <div class="screen-cap">Con conexión: datos guardados en la base de datos</div>
  </div>
  <div class="screen-wrap">
    <img class="screen-img" src="{I['offline']}" alt="Offline">
    <div class="screen-cap">Sin conexión: guardado local, se sincronizará solo</div>
  </div>
</div>

<table>
  <thead><tr><th>Icono</th><th>Mensaje</th><th>Significado</th></tr></thead>
  <tbody>
    <tr><td>☁️✅ Verde</td><td>"Formulario enviado"</td><td>Confirmado en la base de datos</td></tr>
    <tr><td>⬆️ Naranja</td><td>"Formulario guardado"</td><td>Sin red: guardado local, se enviará automáticamente al conectarse</td></tr>
  </tbody>
</table>
<p>Toque <strong>Aceptar</strong>. El formulario se reinicia para una nueva encuesta.</p>

<!-- 8 -->
<h1>8. Historial de encuestas</h1>
<p>Toque <strong>Historial</strong> desde la pantalla principal para ver todos los registros.</p>

<div class="screens-row">
  <div class="screen-wrap">
    <img class="screen-img" src="{I['historial']}" alt="Historial">
    <div class="screen-cap">Encuestas pendientes (naranja/rojo) y enviadas (verde)</div>
  </div>
</div>

<table>
  <thead><tr><th>Estado</th><th>Color</th><th>Descripción</th></tr></thead>
  <tbody>
    <tr><td>Enviada</td><td style="color:#2e7d32"><strong>Verde</strong></td><td>Sincronizada correctamente con la base de datos</td></tr>
    <tr><td>Pendiente</td><td style="color:#e65100"><strong>Naranja</strong></td><td>Guardada en el dispositivo, esperando conexión</td></tr>
    <tr><td>Error</td><td style="color:#c62828"><strong>Rojo</strong></td><td>Falló la sincronización; se reintentará automáticamente</td></tr>
  </tbody>
</table>
<p>Use el botón 🔄 (esquina superior derecha) para recargar, o deslice hacia abajo para refrescar.</p>

<!-- 9 -->
<h1>9. Sincronización automática (modo sin conexión)</h1>
<ol>
  <li><strong>Al enviar sin red:</strong> se guarda localmente con estado <em>Pendiente</em>.</li>
  <li><strong>Al detectar conexión:</strong> intenta sincronizar automáticamente.</li>
  <li><strong>Verificación periódica:</strong> cada 5 minutos revisa encuestas pendientes.</li>
  <li><strong>Sin pérdida de datos:</strong> los datos no se eliminan hasta confirmar recepción en la base de datos.</li>
</ol>
<blockquote><p><strong>Al terminar la jornada:</strong> conéctese a Wi-Fi y verifique en el Historial que todas las encuestas aparezcan como "Enviadas".</p></blockquote>

<!-- 10 -->
<h1>10. Actualizaciones de la aplicación</h1>
<p>Al abrir la aplicación se verifica si hay versión más reciente. Si hay actualización, aparece un aviso con botón <strong>Actualizar</strong> (descarga la nueva APK) o <strong>Más tarde</strong> (continúa con la versión actual).</p>

<!-- 11 -->
<h1>11. Recomendaciones de uso en campo</h1>

<h3>Antes de salir</h3>
<ul>
  <li>Cargue el dispositivo al 100% o lleve powerbank.</li>
  <li>Active el GPS y verifique permisos de ubicación y cámara.</li>
  <li>Conéctese a internet al menos una vez para descargar el catálogo de instituciones actualizado.</li>
</ul>

<h3>Durante la visita</h3>
<ul>
  <li>Complete las fases en orden; siguen el flujo natural de la visita.</li>
  <li>Capture las coordenadas en el <strong>exterior</strong> de la sede (evite techos metálicos o de concreto).</li>
  <li>Tome fotos con buena iluminación; son parte del registro oficial.</li>
  <li>En la <strong>Fase 5</strong>: lea en voz alta y marque solo lo que la persona indique. No presione al entrevistado.</li>
  <li>No cierre la app a la mitad; use <strong>Anterior</strong> si necesita pausar.</li>
</ul>

<h3>Al terminar la jornada</h3>
<ul>
  <li>Conéctese a Wi-Fi y espere a que las encuestas pendientes se sincronicen.</li>
  <li>Verifique en el Historial que todas aparezcan como "Enviadas".</li>
  <li>Informe al coordinador si alguna persiste en estado "Error".</li>
</ul>

<!-- 12 -->
<h1>12. Preguntas frecuentes</h1>

<h4>¿Qué pasa si cierro la app a la mitad del formulario?</h4>
<p>Los datos se guardan como borrador cuando la app pasa a segundo plano. Al volver a abrirla, el borrador se restaura. Si el sistema la cierra forzosamente, los datos no guardados como borrador se perderán.</p>

<h4>¿Puedo editar un formulario ya enviado?</h4>
<p>No. Una vez enviado queda registrado. Para corregir información, contacte al administrador.</p>

<h4>¿La app funciona sin internet?</h4>
<p>Sí. Puede completar y enviar el formulario sin conexión. Los datos se sincronizan automáticamente cuando hay red.</p>

<h4>¿Cuántas encuestas puedo tener pendientes?</h4>
<p>No hay límite fijo. Se recomienda no acumular más de 10 para evitar sobrecargar el almacenamiento.</p>

<h4>El catálogo no muestra mi institución.</h4>
<p>Asegúrese de haber tenido internet al menos una vez antes de ir a campo. Si persiste, contacte al administrador.</p>

<h4>El GPS no captura las coordenadas.</h4>
<p>Verifique que el GPS esté activado, que la app tenga permiso de ubicación y que esté en un lugar con cielo despejado. Si no las obtiene automáticamente, ingréselas manualmente.</p>

<!-- 13 -->
<h1>13. Contacto y soporte</h1>
<table>
  <tbody>
    <tr><td><strong>Correo</strong></td><td>mendozadiazjuandavid@gmail.com</td></tr>
    <tr><td><strong>Proyecto</strong></td><td>CENS Caracterización de Sedes Educativas — Norte de Santander</td></tr>
  </tbody>
</table>

<hr>
<p style="font-size:8.5pt;color:#888;text-align:center;margin-top:16px">
  Documento de uso interno del proyecto CENS · Versión septiembre 2026
</p>
</body></html>"""

tmp = BASE / "_tmp.html"
tmp.write_text(HTML, encoding="utf-8")
subprocess.run(["google-chrome-stable","--headless","--disable-gpu","--no-sandbox",
    f"--print-to-pdf={OUT_PDF}","--print-to-pdf-no-header","--no-pdf-header-footer",
    f"file://{tmp}"], capture_output=True, timeout=60)
tmp.unlink()
kb = OUT_PDF.stat().st_size // 1024
print(f"✅ {OUT_PDF.name}  ({kb} KB)")
