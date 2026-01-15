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

if [[ ! -f "${RUNTIME_DIR}/store_id" ]]; then
  echo "ERRORE: store_id mancante. Esegui prima: ./scripts/create_store.sh"
  exit 1
fi

store_id="$(cat "${RUNTIME_DIR}/store_id")"
model_path="${ROOT_DIR}/examples/model.json"

resp="$(curl -sS -X POST "${FGA_API_URL}/stores/${store_id}/authorization-models" \
  -H "Authorization: Bearer ${FGA_API_TOKEN}" \
  -H "content-type: application/json" \
  -d @"${model_path}")"

echo "${resp}" | tee "${RUNTIME_DIR}/write_model.json" >/dev/null

model_id="$(echo "${resp}" | sed -n 's/.*"authorization_model_id"[[:space:]]*:[[:space:]]*"\([^"]*\)".*/\1/p' | head -n1)"
if [[ -z "${model_id}" ]]; then
  echo "Impossibile estrarre model_id. Vedi ${RUNTIME_DIR}/write_model.json"
  exit 1
fi

echo "${model_id}" > "${RUNTIME_DIR}/model_id"
echo "OK model_id=${model_id}"
