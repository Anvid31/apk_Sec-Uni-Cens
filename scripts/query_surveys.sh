#!/usr/bin/env bash
# Consulta rápida de encuestas en la DB local.
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
docker compose -f "$ROOT/docker-compose.db.yml" exec -T postgres \
  psql -U caract_user -d caracterizacion_cens -c "
SELECT id, institution, municipality, dane_code, latitude, longitude, created_at
FROM surveys
ORDER BY created_at DESC
LIMIT 20;
"
