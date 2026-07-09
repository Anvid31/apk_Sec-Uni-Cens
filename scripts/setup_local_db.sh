#!/usr/bin/env bash
# Levanta PostgreSQL local (Docker) y aplica el esquema inicial.
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT"

COMPOSE_FILE="docker-compose.db.yml"

echo "▶ Iniciando contenedores PostgreSQL + Adminer..."
docker compose -f "$COMPOSE_FILE" up -d

echo "▶ Esperando a que PostgreSQL esté listo..."
for i in $(seq 1 30); do
  if docker compose -f "$COMPOSE_FILE" exec -T postgres \
    pg_isready -U caract_user -d caracterizacion_cens &>/dev/null; then
    break
  fi
  sleep 1
done

echo "▶ Aplicando esquema (scripts/init_postgres.sql)..."
docker compose -f "$COMPOSE_FILE" exec -T postgres \
  psql -U caract_user -d caracterizacion_cens \
  < "$ROOT/scripts/init_postgres.sql"

LAN_IP="$(hostname -I 2>/dev/null | awk '{print $1}')"

echo ""
echo "✅ Base de datos local lista"
echo ""
echo "  PostgreSQL:  localhost:5432"
echo "  Base:        caracterizacion_cens"
echo "  Usuario:     caract_user"
echo "  Contraseña:  caract_dev_pass"
echo ""
echo "  Adminer (ver tablas en el navegador): http://localhost:8081"
echo "    Sistema:   PostgreSQL"
echo "    Servidor:  postgres"
echo "    Usuario:   caract_user"
echo "    Contraseña: caract_dev_pass"
echo "    Base:      caracterizacion_cens"
echo ""
echo "  Para la app Flutter (.env PG_HOST):"
echo "    • Emulador Android:     10.0.2.2"
echo "    • Teléfono en la misma red WiFi: ${LAN_IP:-<IP-de-tu-PC>}"
echo "    • Flutter en Linux/desktop:      127.0.0.1"
echo ""
if [[ ! -f "$ROOT/.env" ]]; then
  echo "  Ejecuta también: ./scripts/create_local_env.sh"
fi
