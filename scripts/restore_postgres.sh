#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
RUNTIME_DIR="${ROOT_DIR}/.runtime"
mkdir -p "${RUNTIME_DIR}"

if [[ -f "${ROOT_DIR}/.env" ]]; then
  set -a
  source "${ROOT_DIR}/.env"
  set +a
fi

: "${FGA_API_URL:=http://127.0.0.1:8080}"

if [[ -n "${OPENFGA_AUTHN_PRESHARED_KEYS:-}" ]]; then
  FGA_API_TOKEN="${OPENFGA_AUTHN_PRESHARED_KEYS%%,*}"
else
  FGA_API_TOKEN="${FGA_API_TOKEN:-}"
fi

if [[ $# -ne 1 ]]; then
  echo "Uso: $0 /percorso/backup.sql"
  exit 1
fi

sql="$1"
if [[ ! -f "${sql}" ]]; then
  echo "File non trovato: ${sql}"
  exit 1
fi

cd "${ROOT_DIR}"
docker compose stop openfga
cat "${sql}" | docker exec -i fga-postgres psql -U "${POSTGRES_USER}" -d "${POSTGRES_DB}"
docker compose start openfga
echo "OK"
