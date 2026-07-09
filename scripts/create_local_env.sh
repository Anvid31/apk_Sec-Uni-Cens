#!/usr/bin/env bash
# Crea .env apuntando a la base de datos local de pruebas.
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
ENV_FILE="$ROOT/.env"
LAN_IP="$(hostname -I 2>/dev/null | awk '{print $1}')"

if [[ -f "$ENV_FILE" ]]; then
  echo "⚠️  Ya existe .env — no se sobrescribe."
  echo "   Ajusta PG_HOST manualmente si hace falta."
  exit 0
fi

# Por defecto: IP LAN (teléfono físico en la misma red).
# Cambia a 10.0.2.2 si usas solo emulador Android.
PG_HOST="${PG_HOST:-$LAN_IP}"

cat > "$ENV_FILE" <<EOF
# Generado por scripts/create_local_env.sh — entorno LOCAL de pruebas
# No subir a git (.gitignore)

PG_HOST=$PG_HOST
PG_PORT=5432
PG_DB=caracterizacion_cens
PG_USER=caract_user
PG_PASSWORD=caract_dev_pass

# Correo (opcional en pruebas locales)
DESTINATION_EMAIL=prueba@local.dev
SENDER_EMAIL=prueba@local.dev
SENDER_PASSWORD=no_usado_en_local
SMTP_HOST=smtp.gmail.com
SMTP_PORT=587
SENDER_NAME=CaracT Móvil Local

# Actualizaciones GitHub (opcional)
GITHUB_OWNER=
GITHUB_REPO=
EOF

echo "✅ Creado $ENV_FILE"
echo "   PG_HOST=$PG_HOST"
echo ""
echo "   Si usas emulador Android, edita .env y pon: PG_HOST=10.0.2.2"
