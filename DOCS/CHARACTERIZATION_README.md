# Documentación: Formulario de Caracterización de Sedes

Guía del formulario unificado de caracterización CENS (4 fases). Organizada según el marco **Diátaxis**.

---

## 1. Tutoriales

### Completar una caracterización de sede

**Paso 1: Inicio**

1. Abra la aplicación **CENS Caracterización**.
2. En la pantalla de inicio, seleccione **Formulario de Caracterización**.
3. Verifique el widget de sincronización en la parte superior (estado de red y pendientes).

**Paso 2: Fase 1 — Información general**

1. Complete municipio, zona, datos de la sede y del rector.
2. Capture la geolocalización (GPS) y las fotografías requeridas.
3. Registre datos de cobertura (matrícula, docentes, niveles educativos).
4. Presione **Continuar** para avanzar a la fase 2.

**Paso 3: Fase 2 — Dotación**

1. Indique servicios (gas, internet) y estado de los espacios (salones, comedor, baños, etc.).
2. Registre cantidades y estado del mobiliario por ítem.
3. Complete necesidades especiales (cocina, botiquín, emergencias).

**Paso 4: Fase 3 — Energía**

1. Indique si la sede tiene energía eléctrica y la fuente.
2. Registre electrodomésticos y equipos disponibles.

**Paso 5: Fase 4 — Agua y saneamiento (envío)**

1. Complete acceso al agua, saneamiento, higiene y riesgos.
2. Agregue observaciones finales si aplica.
3. Presione **Enviar formulario**.
4. El sistema envía a PostgreSQL o guarda en cola local si no hay conexión.

**Paso 6: Exportar datos (opcional)**

Desde la pantalla de inicio, use **Exportar Shapefile** para obtener un archivo geográfico con los registros de la base de datos.

---

## 2. Guías prácticas

### ¿Cómo registrar la ubicación exacta?

En la fase 1, use el botón de captura GPS. Verifique que latitud y longitud no estén en 0.0. Active el GPS y conceda permisos de ubicación al dispositivo.

### ¿Qué hacer sin internet?

1. Complete el formulario normalmente.
2. Al enviar en la fase 4, el sistema detectará la falta de red y guardará los datos en cola local.
3. Puede cerrar la aplicación. Al recuperar conectividad, `AutoSyncService` enviará automáticamente.
4. También puede usar **Sincronizar ahora** en la pantalla de inicio.

### ¿Cómo corregir un dato antes de enviar?

Use el botón **Anterior** en cualquier fase para volver y modificar campos. Los cambios se mantienen en memoria hasta el envío final.

### ¿Cómo configurar la base de datos?

Copie `.env.example` a `.env` y configure las variables `PG_*`. Para desarrollo local con Docker, siga [scripts/LOCAL_DB.md](../scripts/LOCAL_DB.md).

---

## 3. Referencia técnica

### Modelo de datos (`UnifiedSurveyState`)

Estado central gestionado con `ChangeNotifier` y `Provider`. Serializa a JSON con `formType: 'unified'`.

| Fase | Contenido principal |
|------|---------------------|
| 1 | Ubicación, institución, cobertura, fotos |
| 2 | Espacios, mobiliario, gas, internet |
| 3 | Energía eléctrica, electrodomésticos |
| 4 | Agua, saneamiento, higiene, riesgos |

### Servicios de envío

| Servicio | Rol |
|----------|-----|
| `UnifiedSubmissionService` | Orquesta el envío desde la fase 4 |
| `AutoSyncService` | Cola offline, conectividad, reintentos |
| `PostgresService` | Persistencia en PostgreSQL |

### Estados de sincronización

| Estado | Significado |
|--------|-------------|
| `pending` | En cola local, esperando red |
| `syncing` | En proceso de envío |
| `sent` | Confirmado en PostgreSQL |
| `error` | Falló el último intento (se reintenta) |

---

## 4. Explicación

### Arquitectura de persistencia

1. **Memoria (`UnifiedSurveyState`)** — Datos del formulario en curso.
2. **Cola local (`SharedPreferences`)** — Formularios pendientes de envío.
3. **PostgreSQL** — Fuente de verdad centralizada. Las imágenes se convierten a Base64 antes de insertar.

### Exportación Shapefile

`ShapefileExportService` consulta PostgreSQL, genera puntos WGS84 (EPSG:4326) y empaqueta `.shp`, `.shx`, `.dbf` y `.prj` en un ZIP compartible. Los atributos incluyen el JSON del formulario aplanado (sin fotos Base64).

---

Para detalles de implementación, consulte [APP_CLONE_REFERENCE.md](APP_CLONE_REFERENCE.md).
