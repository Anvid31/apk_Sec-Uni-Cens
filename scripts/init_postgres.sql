-- Esquema PostgreSQL para CaracT Móvil / CENS Caracterización
-- Ejecutar una sola vez en el servidor antes de usar la app.
--
-- Requiere PostgreSQL 12+ (soporte JSONB).
-- Conexión configurada en .env: PG_HOST, PG_PORT, PG_DB, PG_USER, PG_PASSWORD

-- ─── Caracterización de sedes ────────────────────────────────────────────────

CREATE TABLE IF NOT EXISTS surveys (
  id            TEXT PRIMARY KEY,
  created_at    TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  form_type     TEXT NOT NULL DEFAULT 'caracterizacion',
  institution   TEXT,
  dane_code     TEXT,
  municipality  TEXT,
  department    TEXT,
  latitude      DOUBLE PRECISION,
  longitude     DOUBLE PRECISION,
  data          JSONB NOT NULL
);

COMMENT ON TABLE surveys IS
  'Encuestas de caracterización de sedes educativas CENS. '
  'El JSONB data almacena el formulario completo (unificado o legacy).';

COMMENT ON COLUMN surveys.form_type IS
  'Tipo de formulario: caracterizacion (incluye formulario unificado de 4 fases).';

COMMENT ON COLUMN surveys.latitude IS
  'Latitud WGS84 para exportación GIS / Shapefile.';

COMMENT ON COLUMN surveys.longitude IS
  'Longitud WGS84 para exportación GIS / Shapefile.';

-- Índices para consultas frecuentes y exportación Shapefile
CREATE INDEX IF NOT EXISTS idx_surveys_coords
  ON surveys (latitude, longitude)
  WHERE latitude IS NOT NULL AND longitude IS NOT NULL;

CREATE INDEX IF NOT EXISTS idx_surveys_municipality
  ON surveys (municipality);

CREATE INDEX IF NOT EXISTS idx_surveys_dane_code
  ON surveys (dane_code);

CREATE INDEX IF NOT EXISTS idx_surveys_created_at
  ON surveys (created_at DESC);

-- ─── Inventario de mobiliario (módulo legacy / futuro) ───────────────────────

CREATE TABLE IF NOT EXISTS inventario_mobiliario (
  id            TEXT PRIMARY KEY,
  created_at    TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  form_type     TEXT NOT NULL DEFAULT 'mobiliario',
  institution   TEXT,
  municipality  TEXT,
  department    TEXT,
  data          JSONB NOT NULL
);

CREATE INDEX IF NOT EXISTS idx_inventario_municipality
  ON inventario_mobiliario (municipality);

-- ─── Verificación rápida ─────────────────────────────────────────────────────
-- SELECT COUNT(*) FROM surveys;
-- SELECT id, institution, latitude, longitude, created_at FROM surveys ORDER BY created_at DESC LIMIT 5;
