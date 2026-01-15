#!/usr/bin/env bash
set -euo pipefail

cd "$(dirname "$0")/.."

if [[ ! -f .env ]]; then
  cp .env.example .env
  echo "Creato .env. Ora modifica password DB e preshared keys."
else
  echo ".env già presente."
fi

mkdir -p .runtime backups
echo "Bootstrap OK."
