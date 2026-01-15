#!/usr/bin/env bash
set -euo pipefail
curl -sS -i http://127.0.0.1:8080/healthz || true
