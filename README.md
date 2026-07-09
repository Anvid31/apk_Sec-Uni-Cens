# CENS Caracterización — Aplicación Móvil

Aplicación Flutter para la caracterización de sedes educativas CENS (Centros Educativos de Nivel Superior) en el departamento de Norte de Santander.

## Características

- **Formulario unificado en 4 fases**: información general, dotación, energía y agua/saneamiento.
- **Captura fotográfica y geolocalización** de la sede.
- **Sincronización automática** con PostgreSQL (offline-first).
- **Exportación Shapefile** desde la base de datos para uso en SIG (QGIS, ArcGIS).
- **Actualizaciones automáticas** vía GitHub Releases.

## Requisitos

- Flutter SDK `^3.7.2`
- Android 7.0+ (API 24) como plataforma principal
- PostgreSQL accesible desde el dispositivo (ver [scripts/LOCAL_DB.md](scripts/LOCAL_DB.md))

## Instalación

```bash
git clone <url-del-repositorio>
cd apk_Sec-Uni-Cens
cp .env.example .env   # configurar PG_* y GITHUB_*
flutter pub get
flutter run
```

## Configuración

Copie `.env.example` a `.env` y configure:

| Variable | Descripción |
|----------|-------------|
| `PG_HOST` | Host de PostgreSQL |
| `PG_PORT` | Puerto (5432 por defecto) |
| `PG_DB` | Nombre de la base de datos |
| `PG_USER` / `PG_PASSWORD` | Credenciales |
| `GITHUB_OWNER` / `GITHUB_REPO` | Para verificación de actualizaciones |

Para desarrollo local con Docker, consulte [scripts/LOCAL_DB.md](scripts/LOCAL_DB.md).

> **Seguridad:** nunca suba `.env` ni credenciales a control de versiones.

## Uso de la aplicación

1. En la pantalla de inicio, seleccione **Formulario de Caracterización**.
2. Complete las 4 fases del formulario:
   - **Fase 1** — Información general, cobertura y registro fotográfico
   - **Fase 2** — Dotación (mobiliario, espacios, servicios)
   - **Fase 3** — Energía y electrodomésticos
   - **Fase 4** — Agua, saneamiento e higiene (envío final)
3. Al finalizar la fase 4, el formulario se envía a PostgreSQL o queda en cola local si no hay red.
4. Use **Sincronizar ahora** en la pantalla de inicio para forzar el envío de pendientes.
5. Use **Exportar Shapefile** para generar un ZIP con puntos WGS84 y atributos del formulario.

## Sincronización automática

El `AutoSyncService` gestiona una cola persistente en `SharedPreferences`:

```
Usuario envía formulario
  → UnifiedSubmissionService.submit()
  → AutoSyncService.scheduleImmediateSync()
      → Con red: PostgresService.saveSurvey()
      → Sin red: cola local + reintento al recuperar conectividad
```

Estados de la cola: `pending`, `syncing`, `synced`, `error`.

## Estructura del proyecto

```
lib/
├── config/           # Tema y estilos
├── models/
│   └── unified_survey_state.dart
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
│   └── unified/
│       ├── phase1_info_general_page.dart
│       ├── phase2_dotacion_page.dart
│       ├── phase3_energia_page.dart
│       └── phase4_agua_page.dart
└── widgets/
    ├── auto_sync_status_widget.dart
    ├── form/          # Campos reutilizables
    └── layout/        # Contenedor del formulario
```

## Tecnologías

| Categoría | Paquete |
|-----------|---------|
| UI / Estado | Flutter, Provider |
| Base de datos remota | `postgres` |
| Almacenamiento local | Hive, SharedPreferences |
| Conectividad | `connectivity_plus` |
| GPS | `geolocator` |
| Fotos | `image_picker` |
| Shapefile | `archive` (ZIP con .shp/.dbf/.prj) |
| Configuración | `flutter_dotenv` |

## Documentación adicional

- [DOCS/CHARACTERIZATION_README.md](DOCS/CHARACTERIZATION_README.md) — Guía de uso del formulario
- [DOCS/APP_CLONE_REFERENCE.md](DOCS/APP_CLONE_REFERENCE.md) — Referencia técnica de arquitectura
- [scripts/LOCAL_DB.md](scripts/LOCAL_DB.md) — Base de datos local de desarrollo

## Licencia

Proyecto privado para uso interno de la institución educativa.
