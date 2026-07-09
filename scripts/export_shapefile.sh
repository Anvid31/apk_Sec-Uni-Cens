#!/usr/bin/env bash
# Exporta surveys de PostgreSQL a Shapefile (ZIP con .shp/.dbf/.prj).
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
VENV="$ROOT/.venv-export"
OUT="${1:-$ROOT/exports/caracterizacion_sedes.zip}"

if [[ ! -d "$VENV" ]]; then
  echo "Creando entorno virtual en .venv-export ..."
  python3 -m venv "$VENV"
  "$VENV/bin/pip" install -q psycopg2-binary pyshp
fi

# Cargar .env si existe
if [[ -f "$ROOT/.env" ]]; then
  set -a
  # shellcheck disable=SC1091
  source <(grep -E '^PG_' "$ROOT/.env" | sed 's/\r$//')
  set +a
fi

mkdir -p "$(dirname "$OUT")"
"$VENV/bin/python3" "$ROOT/scripts/export_shapefile.py" --output "$OUT"
