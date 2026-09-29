-- ═══════════════════════════════════════════════════════════════════════════
-- CENS Caracterización — Migración inicial
-- ═══════════════════════════════════════════════════════════════════════════

-- ─── Tabla principal de encuestas ────────────────────────────────────────────
create table if not exists surveys (
  id           text primary key,
  form_type    text,
  institution  text,
  dane_code    text,
  municipality text,
  department   text,
  latitude     double precision,
  longitude    double precision,
  data         jsonb,
  user_id      uuid references auth.users(id) on delete set null,
  created_at   timestamptz default now()
);

create index if not exists surveys_municipality_idx on surveys(municipality);
create index if not exists surveys_dane_code_idx    on surveys(dane_code);
create index if not exists surveys_user_id_idx      on surveys(user_id);
create index if not exists surveys_coords_idx
  on surveys(latitude, longitude)
  where latitude is not null and longitude is not null;

-- ─── Tabla de inventario de mobiliario ───────────────────────────────────────
create table if not exists inventario_mobiliario (
  id           text primary key,
  form_type    text,
  institution  text,
  municipality text,
  department   text,
  data         jsonb,
  user_id      uuid references auth.users(id) on delete set null,
  created_at   timestamptz default now()
);

create index if not exists mobiliario_user_id_idx on inventario_mobiliario(user_id);

-- ─── Row Level Security ───────────────────────────────────────────────────────
alter table surveys               enable row level security;
alter table inventario_mobiliario enable row level security;

-- Cualquier usuario autenticado puede insertar y actualizar encuestas
create policy "insert_survey"  on surveys for insert to authenticated with check (true);
create policy "update_survey"  on surveys for update to authenticated using (true);
create policy "select_surveys" on surveys for select to authenticated using (true);

create policy "insert_mobiliario"  on inventario_mobiliario for insert to authenticated with check (true);
create policy "select_mobiliario"  on inventario_mobiliario for select to authenticated using (true);

-- ─── Vista de exportación (sin fotos Base64) ─────────────────────────────────
create or replace view surveys_export as
select
  id, created_at, form_type, institution, dane_code,
  municipality, department, latitude, longitude,
  data - 'photoFront' - 'photoClassroom1' - 'photoClassroom2'
       - 'photoKitchen' - 'photoDiningRoom' - 'photoBathroom' as data
from surveys
where latitude is not null and longitude is not null;
