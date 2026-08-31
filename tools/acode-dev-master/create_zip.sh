#!/usr/bin/env bash
set -euo pipefail
OUT="Acode_Dev_Master.zip"
BASE_DIR="$(dirname "$0")"
cd "$BASE_DIR"
if [ -f "$OUT" ]; then
  rm -f "$OUT"
fi
zip -r "$OUT" . -x "*.bak.*" || { echo "Chyba při zipování"; exit 1; }
echo "Archiv vytvořen: $OUT"
