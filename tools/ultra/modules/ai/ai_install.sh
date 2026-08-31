#!/bin/bash
set -Eeuo pipefail
echo "[AI] Inicializace AI engine"
python3 -m venv venv || true
source venv/bin/activate
pip install transformers torch psutil --quiet
