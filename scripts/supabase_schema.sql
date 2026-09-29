-- ═══════════════════════════════════════════════════════════════════════════
-- CENS Caracterización — Schema para Supabase
-- Ejecutar en: Supabase → SQL Editor → New Query
-- ═══════════════════════════════════════════════════════════════════════════

-- ─── Tabla principal de encuestas de caracterización ─────────────────────────
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

-- ─── Tabla de inventario de mobiliario (futura) ───────────────────────────────
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

-- surveys: cualquier usuario autenticado puede insertar y actualizar la suya
create policy "insert_survey"
  on surveys for insert
  to authenticated
  with check (true);

create policy "upsert_survey"
  on surveys for update
  to authenticated
  using (true);

-- surveys: usuarios autenticados pueden leer todas (para exportar shapefile)
create policy "select_surveys"
  on surveys for select
  to authenticated
  using (true);

-- mobiliario: mismas reglas
create policy "insert_mobiliario"
  on inventario_mobiliario for insert
  to authenticated
  with check (true);

create policy "select_mobiliario"
  on inventario_mobiliario for select
  to authenticated
  using (true);

-- ─── Vista para exportación (sin imágenes base64) ────────────────────────────
create or replace view surveys_export as
select
  id,
  created_at,
  form_type,
  institution,
  dane_code,
  municipality,
  department,
  latitude,
  longitude,
  -- Eliminar campos de foto del JSON para exportación liviana
  data - 'photoFront'
       - 'photoClassroom1'
       - 'photoClassroom2'
       - 'photoKitchen'
       - 'photoDiningRoom'
       - 'photoBathroom' as data
from surveys
where latitude is not null
  and longitude is not null;

-- ─── Storage: fotos de encuestas ─────────────────────────────────────────────
-- Ruta: fotos-encuestas/<survey_id>/<campo>.jpg (la fila guarda {path}).
-- Bucket privado. La app sube sin sesión (anon), por eso INSERT incluye anon.
-- Solo usuarios autenticados pueden leer/descargar (URLs firmadas).
insert into storage.buckets (id, name, public, file_size_limit, allowed_mime_types)
values ('fotos-encuestas', 'fotos-encuestas', false, 5242880, array['image/jpeg'])
on conflict (id) do nothing;

create policy "fotos_insert"
  on storage.objects for insert
  to anon, authenticated
  with check (bucket_id = 'fotos-encuestas');

create policy "fotos_select"
  on storage.objects for select
  to authenticated
  using (bucket_id = 'fotos-encuestas');

-- ─── Endurecimiento RLS (2026-09-28) ─────────────────────────────────────────
-- La anon key va dentro del APK: anon solo puede INSERTAR encuestas.
-- Sin SELECT ni UPDATE para anon (antes podía leer y modificar todas).
-- Por eso la app usa insert (no upsert: ON CONFLICT exige SELECT) y trata
-- el error 23505 (id repetido en un reintento) como "ya guardada".
drop policy if exists "upsert_survey" on surveys;
drop policy if exists "select_surveys" on surveys;
create policy "select_surveys"
  on surveys for select
  to authenticated
  using (true);
