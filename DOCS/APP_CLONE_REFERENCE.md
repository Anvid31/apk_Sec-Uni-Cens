# CENS Caracterización — Referencia Técnica

> Flutter · Dart `^3.7.2` · Android principal

---

## Tabla de contenidos

1. [Stack y dependencias](#1-stack-y-dependencias)
2. [Arquitectura de estado](#2-arquitectura-de-estado)
3. [Navegación del formulario](#3-navegación-del-formulario)
4. [Sincronización y PostgreSQL](#4-sincronización-y-postgresql)
5. [Exportación Shapefile](#5-exportación-shapefile)
6. [Variables de entorno](#6-variables-de-entorno)
7. [Estructura de archivos](#7-estructura-de-archivos)

---

## 1. Stack y dependencias

| Categoría | Paquete | Uso |
|-----------|---------|-----|
| Estado | `provider` | `ChangeNotifier` + `MultiProvider` |
| BD remota | `postgres` | Inserción y consulta en PostgreSQL |
| Cola offline | `shared_preferences` | Encuestas pendientes de envío |
| Almacenamiento | `hive` + `hive_flutter` | Inicialización de almacenamiento local |
| Conectividad | `connectivity_plus` | Monitoreo de red |
| GPS | `geolocator` | Geolocalización |
| Fotos | `image_picker` | Captura de imágenes |
| Shapefile | `archive` | Empaquetado ZIP (.shp/.dbf/.prj) |
| Compartir | `share_plus` | Compartir Shapefile exportado |
| Notificaciones | `flutter_local_notifications` | Estado de sincronización |
| Actualizaciones | `dio`, `open_file`, `package_info_plus` | GitHub Releases |
| Config | `flutter_dotenv` | Variables desde `.env` |

---

## 2. Arquitectura de estado

### Provider único

```dart
// main.dart
runApp(MultiProvider(
  providers: [
    ChangeNotifierProvider(create: (_) => UnifiedSurveyState()),
  ],
  child: const MyApp(),
));
```

### `UnifiedSurveyState`

Modelo monolítico con las 4 fases del formulario. Expone:

- Campos de cada fase como propiedades tipadas.
- `toJson()` con `formType: 'unified'`.
- `reset()` para limpiar tras envío.
- `submissionStatus`, `submissionId`, `submissionDate` para seguimiento.

Sub-modelos internos:

- `MobiliarioItem` — cantidad, texto, observaciones por código de ítem.
- `ElectrodomesticoItem` — tiene (`si`/`numero`/`no`), cantidad.

---

## 3. Navegación del formulario

### Flujo lineal (4 pasos)

```
SelectionPage
  → Phase1InfoGeneralPage  (step 1/4)
  → Phase2DotacionPage     (step 2/4)
  → Phase3EnergiaPage      (step 3/4)
  → Phase4AguaPage         (step 4/4, envío)
```

### `FormNavigator`

Utilidad de transiciones animadas entre páginas:

- `pushForm()` — avanzar con animación.
- `popForm()` — retroceder con haptic feedback.
- Tipos: `slide`, `slideScale`, `fadeSlide`, `layered`.

### `EnhancedFormContainer`

Layout estándar de cada fase:

- Barra de progreso (4 pasos).
- Botones Anterior / Continuar.
- Soporte para FAB y estado de carga.

### Widgets de formulario activos

| Widget | Uso |
|--------|-----|
| `CustomTextField` | Campos de texto |
| `CustomDropdownField` | Selectores |
| `PhotoCaptureField` | Captura fotográfica |
| `AutoSyncStatusWidget` | Estado de sincronización |

---

## 4. Sincronización y PostgreSQL

### Flujo de envío

```
Phase4AguaPage
  └── UnifiedSubmissionService.submit(state)
        ├── state.toJson()
        └── AutoSyncService.scheduleImmediateSync(payload)
              ├── Guarda en SharedPreferences (cola)
              ├── Si hay red → PostgresService.saveSurvey()
              └── Si no hay red → reintento al recuperar conectividad
```

### `AutoSyncService`

| Mecanismo | Descripción |
|-----------|-------------|
| Envío inmediato | Al presionar enviar en fase 4 |
| `onConnectivityChanged` | Reintento al detectar red |
| Timer periódico | Verificación cada 5 minutos |
| `forceSyncNow()` | Sincronización manual desde UI |

Anti-deduplicación por firma de campos clave (institución, DANE, fecha).

### `PostgresService`

- Conexión lazy con variables `PG_*` del `.env`.
- `saveSurvey()` — inserta JSON en tabla `surveys`, convierte imágenes a Base64.
- `querySurveysForExport()` — consulta registros con coordenadas para Shapefile.

Esquema: ver `scripts/init_postgres.sql`.

### Procesamiento de imágenes

`ImageHelper` convierte rutas locales de fotos a Base64 antes de insertar en PostgreSQL.

---

## 5. Exportación Shapefile

`ShapefileExportService.exportFromDatabase()`:

1. Consulta `PostgresService.querySurveysForExport()`.
2. Aplana atributos con `SurveyShapefileFlatten.flattenRow()`.
3. Genera `.shp`, `.shx`, `.dbf`, `.prj` (WGS84).
4. Empaqueta en ZIP y comparte vía `share_plus`.

Invocable desde `SelectionPage` → botón **Exportar Shapefile**.

También disponible por script: `scripts/export_shapefile.sh`.

---

## 6. Variables de entorno

```env
PG_HOST=...
PG_PORT=5432
PG_DB=caracterizacion_cens
PG_USER=...
PG_PASSWORD=...

GITHUB_OWNER=...
GITHUB_REPO=...
```

El archivo `.env` se embebe en el APK como asset. Tras cambiar `.env`, reconstruir la app.

---

## 7. Estructura de archivos

```
lib/
├── main.dart
├── config/theme.dart
├── models/unified_survey_state.dart
├── services/
│   ├── auto_sync_service.dart
│   ├── postgres_service.dart
│   ├── unified_submission_service.dart
│   ├── shapefile_export_service.dart
│   ├── storage_service.dart
│   ├── location_service.dart
│   ├── notification_service.dart
│   └── update_service.dart
├── utils/
│   ├── form_navigator.dart
│   ├── location_data.dart
│   ├── image_helper.dart
│   └── survey_shapefile_flatten.dart
├── views/
│   ├── selection_page.dart
│   └── unified/phase{1..4}_*.dart
└── widgets/
    ├── auto_sync_status_widget.dart
    ├── update_dialog.dart
    ├── form/
    │   ├── custom_text_field.dart
    │   ├── custom_dropdown_field.dart
    │   ├── photo_capture_field.dart
    │   └── enhanced_form_navigation.dart
    └── layout/enhanced_form_container.dart
```

### Inicialización en `main()`

```dart
await dotenv.load(fileName: ".env");
await StorageService.init();        // Hive
await AutoSyncService.initialize(); // Cola + conectividad
await NotificationService.initialize();
```

Orientación forzada: `portraitUp`.

---

## Servicios eliminados (legacy)

Los siguientes componentes ya no forman parte del proyecto:

- MongoDB (`mongo_dart`, `MongoService`)
- Correo SMTP (`mailer`, `EmailService`)
- Exportación CSV/ZIP de formularios (`csv`, `ZipExportService`, `CsvExportService`)
- Formularios multipágina legacy (`SurveyState`, módulo de mobiliario independiente)

La persistencia remota es exclusivamente **PostgreSQL**.
