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

BACKUP_DIR="${ROOT_DIR}/backups"
mkdir -p "${BACKUP_DIR}"

ts="$(date +%F_%H%M%S)"
out="${BACKUP_DIR}/openfga_${ts}.sql"

docker exec -t fga-postgres pg_dump -U "${POSTGRES_USER}" "${POSTGRES_DB}" > "${out}"
ls -lh "${out}"
echo "OK"
