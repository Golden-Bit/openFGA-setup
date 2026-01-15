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

if [[ -z "${FGA_API_TOKEN}" ]]; then
  echo "ERRORE: token non impostato. Compila OPENFGA_AUTHN_PRESHARED_KEYS in .env."
  exit 1
fi

resp="$(curl -sS -X POST "${FGA_API_URL}/stores" \
  -H "Authorization: Bearer ${FGA_API_TOKEN}" \
  -H "content-type: application/json" \
  -d '{"name":"openfga-demo-store"}')"

echo "${resp}" | tee "${RUNTIME_DIR}/create_store.json" >/dev/null

store_id="$(echo "${resp}" | sed -n 's/.*"id"[[:space:]]*:[[:space:]]*"\([^"]*\)".*/\1/p' | head -n1)"
if [[ -z "${store_id}" ]]; then
  echo "Impossibile estrarre store_id. Vedi ${RUNTIME_DIR}/create_store.json"
  exit 1
fi

echo "${store_id}" > "${RUNTIME_DIR}/store_id"
echo "OK store_id=${store_id}"
