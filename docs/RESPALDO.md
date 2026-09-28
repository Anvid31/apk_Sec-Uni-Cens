# Respaldo semanal de Supabase

El plan gratuito de Supabase no incluye copias de seguridad descargables.
El workflow `.github/workflows/backup-supabase.yml` hace una cada domingo
(02:00 hora Colombia) y la guarda **cifrada** en Google Drive.

| Qué | Cómo | Retención |
|---|---|---|
| Base de datos (`public`: encuestas, mobiliario) | `pg_dump -Fc` completo | 26 semanas (`db/AAAA-MM-DD/`) |
| Usuarios (`auth.users`, `auth.identities`) | `pg_dump --data-only` | 26 semanas |
| Fotos (bucket `fotos-encuestas`) | Solo las nuevas cada semana | Permanente (nunca se borran del respaldo) |

También avisa en el resumen del workflow cuando la base pasa de 400 MB o las
fotos de 800 MB (límites del plan gratuito: 500 MB y 1 GB).

---

## Configuración (una sola vez)

### 1. rclone con Google Drive + cifrado

En tu computador:

```bash
sudo -v ; curl -fsSL https://rclone.org/install.sh | sudo bash
rclone config
```

1. **Client ID propio de Google** (el compartido de rclone se retira en 2026 y
   ya no autentica). En https://console.cloud.google.com, con la cuenta
   donde irá el respaldo:
   - Proyecto nuevo → *APIs & Services → Library* → activar **Google Drive API**.
   - *Google Auth Platform → Branding*: nombre de app, correos, audiencia **External**.
   - *Data Access*: agregar el scope `…/auth/drive.file`.
   - *Audience* → **Publish app** ("In production"). En modo *Testing* el
     token caduca a los 7 días y el respaldo semanal fallaría.
     `drive.file` no requiere verificación de Google.
   - *Clients → Create client* → tipo **Desktop app** → copiar ID y secret.
2. **Remote de Drive**:
   ```bash
   rclone config create gdrive drive \
     client_id=TU_CLIENT_ID client_secret=TU_CLIENT_SECRET scope=drive.file
   ```
   En el navegador, ante "Google hasn't verified this app": *Advanced → Go to …*
   (es tu propia app) y autorizar.
3. **Remote cifrado** (el workflow usa el nombre **`backup`**). Cifra el
   contenido pero deja los nombres legibles para que Drive se vea ordenado
   (`db/AAAA-MM-DD/public.dump.bin`, `fotos/<id>/photoFront.jpg.bin`).
   En fish:
   ```fish
   set P1 (openssl rand -base64 32); set P2 (openssl rand -base64 32)
   echo "Contraseña 1: $P1"; echo "Contraseña 2: $P2"
   rclone config create backup crypt remote=gdrive:cens-respaldos \
     filename_encryption=off directory_name_encryption=false \
     password="$P1" password2="$P2"
   ```
   Los nombres solo muestran fechas, ids numéricos de encuesta y el campo de
   la foto; el contenido de cada archivo sí queda cifrado.
4. **Guarda las dos contraseñas en un gestor de contraseñas.**
   Sin ellas el respaldo es ilegible — Google ni nadie puede recuperarlo.

Prueba: `rclone mkdir backup:` y `rclone lsd gdrive:` (debe aparecer `cens-respaldos`).

En Drive los archivos terminan en `.bin`: solo se leen con `rclone … backup:`.

### 2. Secrets en GitHub

Repo → Settings → Secrets and variables → Actions → *New repository secret*:

| Secret | Valor |
|---|---|
| `SUPABASE_DB_URL` | Supabase → **Connect** → *Session pooler* (IPv4; GitHub no soporta la conexión directa IPv6). Formato `postgresql://postgres.exfoosctabmtbzbqyupc:CONTRASEÑA@aws-…pooler.supabase.com:5432/postgres` |
| `SUPABASE_URL` | `https://exfoosctabmtbzbqyupc.supabase.co` |
| `SUPABASE_SERVICE_ROLE_KEY` | Supabase → Settings → API Keys → *service_role* / *secret* (el bucket es privado) |
| `RCLONE_CONFIG` | Contenido completo de `rclone config file` (normalmente `~/.config/rclone/rclone.conf`) |

La service role key salta todas las políticas RLS: **solo** va en secrets,
nunca en la app ni en el repo.

### 3. Primera ejecución

Actions → *Respaldo Supabase* → **Run workflow**. Revisa que termine en verde y
que el resumen muestre el uso de espacio. `rclone ls backup:` debe listar
`db/AAAA-MM-DD/public.dump`, `db/…/auth_users.sql` y `fotos/<id>/…jpg`.

GitHub envía un correo si una ejecución programada falla.

---

## Ver el respaldo (y comprobar que sirve)

En la web de Drive los archivos aparecen como `.bin`: están cifrados a
propósito. Se ven con rclone y tus contraseñas (comandos para fish):

```fish
rclone tree backup:                                   # contenido, ya descifrado
rclone copy backup:fotos ~/respaldo-cens/fotos        # fotos .jpg normales
xdg-open ~/respaldo-cens/fotos

rclone copy backup:db ~/respaldo-cens/db              # comprobar la base
docker run --rm -v ~/respaldo-cens/db:/db postgres:17 \
  pg_restore --list /db/AAAA-MM-DD/public.dump | grep "TABLE DATA"

mkdir -p ~/respaldo-vivo; rclone mount backup: ~/respaldo-vivo --read-only   # navegar
```

Hazlo al menos una vez al configurar y cada pocos meses: si abre, el
respaldo y las contraseñas funcionan. Borra `~/respaldo-cens` al terminar
(tiene datos personales sin cifrar).

## Restaurar

```bash
# Traer un respaldo (descifra automáticamente)
rclone copy backup:db/2026-10-04 ./restaurar/db
rclone copy backup:fotos ./restaurar/fotos

# 1. Base de datos en un proyecto Supabase (nuevo o el mismo)
pg_restore --no-owner --no-privileges -d "$SUPABASE_DB_URL" --clean --if-exists \
  restaurar/db/public.dump
psql "$SUPABASE_DB_URL" -f restaurar/db/auth_users.sql   # solo si el proyecto es nuevo

# 2. Fotos: crear el bucket con scripts/supabase_schema.sql y subirlas
#    manteniendo la ruta <survey_id>/<campo>.jpg
```

`--clean` borra las tablas antes de recrearlas: en el proyecto de producción
úsalo solo si de verdad quieres volver al estado del respaldo.

## Notas

- Usa el cliente `pg_dump` 17 (el servidor es Postgres 17.6).
- Las fotos se comparan por nombre: una foto borrada en Supabase **se conserva**
  en el respaldo; eso es intencional.
- La conexión semanal a la base puede ayudar a que el proyecto gratuito no se
  pause por 7 días de inactividad, pero Supabase no lo garantiza: si el
  proyecto se pausa, el workflow falla y llega el correo de aviso.
