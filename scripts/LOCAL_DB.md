# Base de datos local de pruebas

## Inicio rápido

```bash
./scripts/setup_local_db.sh
```

Esto levanta PostgreSQL + Adminer con Docker y crea las tablas.

## Credenciales

| Campo      | Valor                 |
|-----------|------------------------|
| Host      | ver abajo según dispositivo |
| Puerto    | 5432                   |
| Base      | caracterizacion_cens   |
| Usuario   | caract_user            |
| Contraseña| caract_dev_pass        |

## `PG_HOST` en `.env` según dónde corre la app

| Escenario | PG_HOST | Notas |
|-----------|---------|--------|
| **Teléfono USB (recomendado)** | `127.0.0.1` | Ejecuta `./scripts/connect_phone_db.sh` |
| Emulador Android | `10.0.2.2` | |
| `flutter run` en Linux/desktop | `127.0.0.1` | |
| Teléfono WiFi (misma red) | IP del PC (`ip -4 addr`) | Falla si la red tiene *aislamiento AP* |

### Error `Connection timed out` desde el teléfono

La WiFi institucional o invitados suele **bloquear** que el móvil hable con el PC.
Solución más fiable en desarrollo:

```bash
./scripts/connect_phone_db.sh   # USB + adb reverse
flutter run                     # reiniciar app (el .env va embebido en el APK)
```

Luego en la app: **Sincronizar ahora** en la pantalla de inicio (la encuesta ya está en cola local).

## Ver datos en el navegador (Adminer)

1. Abre http://localhost:8081
2. Sistema: **PostgreSQL**
3. Servidor: **postgres**
4. Usuario: **caract_user**
5. Contraseña: **caract_dev_pass**
6. Base de datos: **caracterizacion_cens**
7. Tabla **surveys** → columna **data** tiene el JSON completo

## Consulta por terminal

```bash
./scripts/query_surveys.sh
```

## Exportar Shapefile (desde la base de datos local)

Genera un ZIP con puntos WGS84 y **todos los atributos** del formulario
(columnas de tabla + JSON aplanado; sin fotos Base64).

```bash
./scripts/export_shapefile.sh
# o con ruta personalizada:
./scripts/export_shapefile.sh exports/mis_sedes.zip
```

El archivo queda en `exports/caracterizacion_sedes.zip`. Ábrelo en QGIS,
ArcGIS o similar.

Desde la **app móvil**, en la pantalla de inicio usa **Exportar Shapefile**
(conexión a la misma base de datos configurada en `.env`).

## Detener / reiniciar

```bash
docker compose -f docker-compose.db.yml down      # detener
docker compose -f docker-compose.db.yml up -d     # iniciar
```

Los datos persisten en el volumen Docker `cens_pgdata`.

## Volver a Supabase

```bash
cp .env.supabase.bak .env
```
