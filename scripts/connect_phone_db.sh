#!/usr/bin/env bash
# Conecta el teléfono (USB) a PostgreSQL local vía adb reverse.
# En el teléfono, 127.0.0.1:5432 → PC localhost:5432
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
ADB="${ANDROID_HOME:-$HOME/Android/Sdk}/platform-tools/adb"

if [[ ! -x "$ADB" ]]; then
  echo "❌ No se encontró adb en $ADB"
  exit 1
fi

DEVICES="$("$ADB" devices | grep -w device | wc -l)"
if [[ "$DEVICES" -eq 0 ]]; then
  echo "❌ Conecta el teléfono por USB con depuración activada."
  exit 1
fi

"$ADB" reverse tcp:5432 tcp:5432
echo "✅ Puerto reenviado: teléfono 127.0.0.1:5432 → PC localhost:5432"
"$ADB" reverse --list

# Asegurar PG_HOST correcto en .env
ENV_FILE="$ROOT/.env"
if grep -q '^PG_HOST=' "$ENV_FILE" 2>/dev/null; then
  sed -i 's/^PG_HOST=.*/PG_HOST=127.0.0.1/' "$ENV_FILE"
else
  echo 'PG_HOST=127.0.0.1' >> "$ENV_FILE"
fi
echo "✅ .env actualizado: PG_HOST=127.0.0.1"
echo ""
echo "⚠️  Reinicia la app (obligatorio tras cambiar .env):"
echo "    ./scripts/connect_phone_db.sh && flutter run"
