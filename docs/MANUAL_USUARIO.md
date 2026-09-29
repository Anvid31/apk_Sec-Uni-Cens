# Manual de Usuario — CENS Caracterización

**Sistema operativo:** Android  
**Público objetivo:** Encuestadores y coordinadores de campo del proyecto de caracterización de sedes educativas CENS – Norte de Santander

---

## Tabla de contenido

1. [Descripción general](#1-descripción-general)
2. [Requisitos del dispositivo](#2-requisitos-del-dispositivo)
3. [Permisos requeridos](#3-permisos-requeridos)
4. [Instalación](#4-instalación)
5. [Pantalla principal](#5-pantalla-principal)
6. [Formulario de Caracterización](#6-formulario-de-caracterización)
   - [Fase 1 – Información General](#fase-1--información-general)
   - [Fase 2 – Dotación](#fase-2--dotación)
   - [Fase 3 – Energía](#fase-3--energía)
   - [Fase 4 – Agua y Saneamiento](#fase-4--agua-y-saneamiento)
   - [Fase 5 – Riesgo](#fase-5--riesgo)
7. [Envío del formulario](#7-envío-del-formulario)
8. [Historial de encuestas](#8-historial-de-encuestas)
9. [Sincronización automática (modo sin conexión)](#9-sincronización-automática-modo-sin-conexión)
10. [Actualizaciones de la aplicación](#10-actualizaciones-de-la-aplicación)
11. [Recomendaciones de uso en campo](#11-recomendaciones-de-uso-en-campo)
12. [Preguntas frecuentes](#12-preguntas-frecuentes)
13. [Contacto y soporte](#13-contacto-y-soporte)

---

## 1. Descripción general

**CENS Caracterización** es una aplicación móvil que permite a los encuestadores de campo recopilar información detallada sobre las sedes educativas del departamento de Norte de Santander. Al abrirse, va directamente a la pantalla principal. El formulario abarca cinco áreas temáticas:

| Fase | Tema                     |
|------|--------------------------|
| 1    | Información General      |
| 2    | Dotación                 |
| 3    | Energía                  |
| 4    | Agua y Saneamiento       |
| 5    | Riesgo                   |

La aplicación guarda los datos en el dispositivo cuando no hay conexión a internet y los sincroniza automáticamente con la base de datos en cuanto se restablece la red.

---

## 2. Requisitos del dispositivo

| Elemento              | Mínimo recomendado                       |
|-----------------------|------------------------------------------|
| Sistema operativo     | Android 8.0 (API 26) o superior          |
| Memoria RAM           | 2 GB                                     |
| Almacenamiento libre  | 100 MB                                   |
| Cámara                | Trasera con autofoco (para fotos)        |
| GPS                   | Integrado (para coordenadas)             |
| Conexión a internet   | Opcional en campo; necesaria para sincronizar |

---

## 3. Permisos requeridos

La aplicación solicita dos permisos al momento de usarlos por primera vez.

### 3.1 Ubicación (GPS)

- **Para qué se usa:** capturar automáticamente las coordenadas (latitud y longitud) de la sede en la Fase 1.
- **Cuándo se solicita:** al pulsar el botón de ubicación 🎯 en el campo de coordenadas.
- **Si se niega:** las coordenadas deben ingresarse manualmente.
- **Cómo habilitarlo:** Configuración → Aplicaciones → CENS Caracterización → Permisos → Ubicación → "Solo al usar la aplicación".

### 3.2 Cámara

- **Para qué se usa:** tomar o seleccionar fotos de la sede en la Fase 1.
- **Cuándo se solicita:** al tocar cualquier campo de fotografía.
- **Si se niega:** no podrán adjuntarse imágenes al formulario.
- **Cómo habilitarlo:** Configuración → Aplicaciones → CENS Caracterización → Permisos → Cámara → Permitir.

> **Recomendación:** Active el GPS del dispositivo antes de iniciar el formulario para asegurar mayor precisión.

---

## 4. Instalación

La APK se distribuye directamente por el equipo CENS (no está en Google Play).

1. Descargue el archivo `.apk` en el dispositivo (correo, WhatsApp o enlace del administrador).
2. Abra el archivo descargado desde el administrador de archivos.
3. Si Android muestra *"Instalar de fuentes desconocidas"*, siga la ruta indicada y luego regrese a instalar.
4. Toque **Instalar** y espere a que finalice.
5. Toque **Abrir** — la aplicación inicia directamente en la pantalla principal.

> Cuando el administrador libere una versión nueva, la aplicación mostrará un aviso automático al abrirla. Consulte el [apartado 10](#10-actualizaciones-de-la-aplicación).

---

## 5. Pantalla principal

Al abrir la aplicación aparece directamente la pantalla principal, sin ningún paso previo. Desde aquí se accede a las dos funciones principales:

- **Formulario de Caracterización** — inicia el proceso de encuesta de 5 fases.
- **Historial** — consulta los formularios enviados y los pendientes de sincronización.

### Indicador de sincronización

En la parte superior de las opciones se muestra la tarjeta de **Estado de Sincronización**, que indica:
- Si hay conexión activa (Online / Offline).
- Cuántas encuestas están pendientes de envío.
- Fecha y hora de la última sincronización exitosa.
- Si hay encuestas pendientes y hay red disponible, aparece el botón **Sincronizar ahora**.

---

## 6. Formulario de Caracterización

El formulario está dividido en **5 fases** que se completan en orden. En la parte superior de cada pantalla se muestra una barra de progreso indicando el paso actual (ej: "Paso 2 de 5"). Puede navegar hacia atrás con el botón **Anterior** sin perder los datos ya ingresados.

> Los campos marcados con asterisco (`*`) son **obligatorios**. No podrá avanzar al siguiente paso si alguno está vacío.

---

### Fase 1 – Información General

Recopila los datos de identificación de la sede.

#### Sección: Información General (automática)
- **Fecha:** se registra automáticamente (no editable).
- **Departamento:** fijo como "Norte de Santander" (no editable).

#### Sección: Datos del Entrevistado
| Campo                     | Tipo        | Obligatorio |
|---------------------------|-------------|-------------|
| Nombre del entrevistado   | Texto libre | No          |
| Cargo del entrevistado    | Texto libre | No          |
| Contacto del entrevistado | Teléfono    | No          |

#### Sección: Sede Educativa
Seleccione en cascada: primero el **Municipio** y la **Zona** (Urbano / Rural); luego se habilita el listado de **Instituciones Educativas** y, al elegirla, el de **Sedes**. El **Código DANE** se completa automáticamente al seleccionar la sede.

| Campo                           | Tipo                         | Obligatorio |
|---------------------------------|------------------------------|-------------|
| Municipio                       | Desplegable                  | Sí          |
| Zona                            | Desplegable (Urbano / Rural) | Sí          |
| Corregimiento                   | Texto libre (solo Zona Rural)| No          |
| Vereda                          | Texto libre (solo Zona Rural)| No          |
| Institución Educativa Principal | Desplegable                  | Sí          |
| Nombre de la sede               | Desplegable                  | Sí          |
| Código DANE                     | Solo lectura (automático)    | Sí          |
| Nombre del rector               | Texto libre                  | No          |
| Número telefónico del rector    | Teléfono                     | No          |
| Email del rector                | Email                        | No          |

#### Sección: Ubicación y Acceso
- **Coordenadas GPS:** toque el ícono 🎯 para capturarlas automáticamente, o ingréselas manualmente.
- **Tipo de acceso:** selección múltiple (Vehicular, Fluvial, Camino Herradura).
- **Observaciones de acceso:** describa la ruta de llegada con referencias locales.
- **Proyectos recientes:** proyectos ejecutados en los últimos 2 años y entidad responsable.

#### Sección: Cobertura
- **Niveles educativos:** selección múltiple (Preescolar, Básica Primaria, Básica Secundaria, Media).

#### Sección: Registro Fotográfico
Tome o seleccione fotos para cada espacio. Se requiere el permiso de cámara.

| Foto                              |
|-----------------------------------|
| Frente de la sede educativa       |
| Aula 1                            |
| Aula 2                            |
| Cocina (si aplica)                |
| Comedor                           |
| Baño principal                    |

> Toque el campo de foto para elegir entre tomar una nueva imagen con la cámara o seleccionar una de la galería.

Al completar esta fase, toque **Continuar** para avanzar.

---

### Fase 2 – Dotación

Registra los servicios públicos, la infraestructura y el inventario de mobiliario.

#### Servicios Públicos
- ¿Tiene gas? → Si Sí: seleccione la fuente (Gas Domiciliario / Bombonas).
- ¿Cuenta con Internet? → Si Sí: ingrese el nombre de la empresa prestadora.

#### Infraestructura — Espacios
Para cada espacio (Salones, Comedor, Cocina, Salón de reuniones, Habitaciones), responda **Sí / No**. Si la respuesta es **Sí**, ingrese la cantidad y el estado general.

También puede registrar **Otros espacios** (biblioteca, laboratorio, etc.) tocando "Agregar espacio".

#### Ítems de Mobiliario
Por cada ítem (pupitres, sillas, escritorios, etc.) ingrese la cantidad en cada estado:
- **Bueno** (verde) — sin daños visibles, en óptimas condiciones.
- **Regular** (naranja) — desgaste o daño menor, pero funcional.
- **Malo** (rojo) — deteriorado, roto o inservible.

El campo **Necesidades** se calcula automáticamente (Regular + Malo), indicando cuántos ítems requieren reemplazo o reparación.

#### Dotación Especial
- **Cocina y Comedor:** indique si existe, su estado y los enseres presentes.
- **Emergencias:** indique si hay mobiliario para atención de emergencias y registre el inventario.

---

### Fase 3 – Energía

Registra la fuente de energía eléctrica y los electrodomésticos disponibles.

#### Fuente de energía
Seleccione una de las opciones:
- Red CENS (requiere número de cliente, calidad del servicio y motivo si no es Buena)
- A través de una vivienda cercana
- Conectado de Manera Irregular
- Planta Eléctrica (ACPM/Gasolina)
- Energías Renovables (Paneles solares, hídrico, biomasa)
- Red Artesana (construida por la comunidad)

#### Electrodomésticos
Para cada electrodoméstico listado indique si existe y la cantidad. Puede agregar equipos adicionales en "Otros electrodomésticos".

---

### Fase 4 – Agua y Saneamiento

Registra el acceso al agua y las condiciones sanitarias de la sede.

#### Agua
- Fuente principal (acueducto, pozo, río, carrotanque, aguas lluvias, etc.)
- Fuente alternativa en caso de desabastecimiento
- Frecuencia de disponibilidad
- Calidad percibida (Buena / Regular / Mala)
- Si hay almacenamiento: material y capacidad del tanque

#### Saneamiento e Instalaciones sanitarias
- Número de hidrantes / puntos de lavado de manos
- Total de sanitarios (niñas, niños, funcionales, discapacidad, primera infancia)
- Tipo de dispositivo sanitario y condiciones
- Gestión de residuos sólidos y prácticas de higiene

---

### Fase 5 – Riesgo

> **Fase sensible.** Lea cada pregunta en voz alta y marque solo lo que la persona entrevistada indique. **No solicite ni registre nombres propios, lugares específicos ni detalles de incidentes.**

#### Continuidad del Servicio Educativo
- ¿La sede suspendió clases en los últimos 12 meses? (Sí / No / No sabe)
  - Si Sí: número de días y causa(s) de la suspensión.

#### Amenazas Reconocidas por la Sede
- Selección múltiple de situaciones que podrían afectar la sede (inundación, deslizamiento, sismo, deterioro estructural, violencia armada, etc.).
- De las seleccionadas, indique las **3 más importantes** (máximo 3).

#### Trayectos y Transporte Escolar
- ¿Cómo llegan los estudiantes? (a pie, ruta escolar, transporte familiar, fluvial, bicicleta/animal)
- Duración promedio del trayecto más largo.
- Condiciones que hacen riesgoso el trayecto (físicas y del entorno).
- ¿En el último año algún trayecto se suspendió o modificó?

#### Efectividad de la Ruta de Aviso
- Ante una emergencia, ¿a quién avisa primero?
- ¿Por qué medio avisa?
- La última vez que avisó, ¿obtuvo respuesta?

#### Actualización de la Información
- Cargo del responsable de mantener actualizados los PGIR.
- Frecuencia de actualización.

---

## 7. Envío del formulario

Al completar la Fase 5, toque el botón **Enviar formulario**.

| Icono          | Mensaje                  | Significado                                                                        |
|----------------|--------------------------|------------------------------------------------------------------------------------|
| ☁️✅ Verde      | "Formulario enviado"     | Los datos se guardaron exitosamente en la base de datos.                           |
| ⬆️ Naranja     | "Formulario guardado"    | Sin conexión. Quedan en el dispositivo y se enviarán solos cuando haya red. |

Toque **Aceptar** para regresar a la pantalla principal. El formulario se reinicia automáticamente para una nueva encuesta.

---

## 8. Historial de encuestas

Desde la pantalla principal, toque **Historial** para ver todas las encuestas.

| Estado    | Color   | Descripción                                         |
|-----------|---------|-----------------------------------------------------|
| Enviada   | Verde   | Sincronizada correctamente con la base de datos.    |
| Pendiente | Naranja | Guardada en el dispositivo, a la espera de red.     |
| Error     | Rojo    | Falló el intento de sincronización. Se reintentará. |

Use el botón 🔄 (esquina superior derecha) para recargar, o deslice hacia abajo para refrescar.

---

## 9. Sincronización automática (modo sin conexión)

La aplicación funciona **completamente sin internet** durante la encuesta:

1. **Al enviar sin red:** se guarda localmente con estado *Pendiente*.
2. **Al detectar conexión:** intenta enviar automáticamente las encuestas pendientes.
3. **Verificación periódica:** cada 5 minutos revisa si hay pendientes para enviar.
4. **Sin pérdida de datos:** los datos no se eliminan del dispositivo hasta confirmar recepción en la base de datos.

> **Al terminar la jornada:** conéctese a Wi-Fi o datos móviles y verifique en el Historial que todas las encuestas aparezcan como "Enviadas".

---

## 10. Actualizaciones de la aplicación

Al abrir la aplicación se verifica automáticamente si existe una versión más reciente. Si hay actualización disponible, aparece un aviso con:

- Número de versión nueva
- Botón **Actualizar** → descarga la nueva APK
- Botón **Más tarde** → continúa con la versión actual

Se recomienda instalar las actualizaciones disponibles para recibir correcciones y mejoras.

---

## 11. Recomendaciones de uso en campo

### Antes de salir a campo
- Cargue el dispositivo al 100% o lleve batería portátil (powerbank).
- Active el GPS y verifique que la aplicación tenga permisos de ubicación y cámara.
- Conéctese a internet al menos una vez para descargar el catálogo de instituciones actualizado.
- Verifique que la pantalla principal carga correctamente.

### Durante la visita
- Complete las fases en orden; el formulario sigue el flujo natural de la visita.
- Capture las coordenadas GPS en el **exterior** de la sede (evite techos de metal o concreto).
- Tome fotos con buena iluminación; son parte del registro oficial.
- En la **Fase 5 (Riesgo):** lea las preguntas en voz alta y marque solo lo que la persona indique. No presione al entrevistado.
- No cierre la aplicación a la mitad de un formulario; use siempre el botón **Anterior** si necesita pausar.

### Preguntas sensibles (Fase 5)
- No registre nombres de personas, organizaciones ni ubicaciones específicas de incidentes.
- Si el entrevistado prefiere no responder, seleccione esa opción y continúe sin insistir.
- La información de riesgo es confidencial y de uso exclusivo del equipo técnico.

### Al terminar la jornada
- Conéctese a Wi-Fi o datos y espere a que las encuestas pendientes se sincronicen.
- Verifique en el Historial que todas aparezcan en estado "Enviada".
- Informe al coordinador si alguna encuesta persiste en estado "Error".

---

## 12. Preguntas frecuentes

**¿Qué pasa si cierro la aplicación a la mitad de un formulario?**  
Los datos se guardan como borrador automáticamente cuando la app pasa a segundo plano. Al volver a abrirla, el borrador se restaura. Si el sistema cierra la app forzosamente, los datos no guardados como borrador se perderán.

**¿Puedo editar un formulario ya enviado?**  
No. Una vez enviado queda registrado. Para corregir información, contacte al administrador.

**¿La app funciona sin internet?**  
Sí. Puede completar y enviar el formulario sin conexión. Los datos se guardan localmente y se sincronizan cuando hay red disponible.

**¿Cuántas encuestas puedo tener pendientes a la vez?**  
No hay límite fijo. Se recomienda no acumular más de 10 encuestas pendientes para evitar sobrecargar el almacenamiento del dispositivo.

**El catálogo no muestra mi municipio o institución.**  
El catálogo se carga desde el servidor al iniciar la app. Asegúrese de haber tenido internet al menos una vez antes de ir a campo. Si el problema persiste, contacte al administrador.

**El GPS no captura las coordenadas.**  
Verifique que: (1) el GPS esté activado, (2) la app tenga permiso de ubicación, (3) esté en un lugar con cielo despejado. Si no las obtiene automáticamente, ingréselas manualmente.

---

## 13. Contacto y soporte

Para reporte de errores o dudas técnicas:

- **Correo:** mendozadiazjuandavid@gmail.com
- **Proyecto:** CENS Caracterización de Sedes Educativas — Norte de Santander

---

*Documento de uso interno del proyecto CENS. Versión septiembre 2026.*
