#!/usr/bin/env bash
# Statická analýza projektu – výstup do TXT i JSON
set -euo pipefail

PROJECT="${1:-}"
if [ -z "$PROJECT" ] || [ ! -d "$PROJECT" ]; then
  echo "Chyba: zadej cestu k projektu jako první argument" >&2
  exit 1
fi

REPORT_DIR="${ACODE_REPORT_DIR:-$HOME/.acode_dev_master/reports}"
mkdir -p "$REPORT_DIR"
TS="$(date +%F_%H-%M-%S)"
TXT_REPORT="$REPORT_DIR/analysis_${TS}.txt"
JSON_REPORT="$REPORT_DIR/analysis_${TS}.json"

echo "== ANALÝZA PROJEKTU: $PROJECT ==" | tee "$TXT_REPORT"
du -sh "$PROJECT" | tee -a "$TXT_REPORT"
echo "Počet souborů:" | tee -a "$TXT_REPORT"
find "$PROJECT" -type f | wc -l | tee -a "$TXT_REPORT"
echo "TODO/FIXME/BUG/HACK:" | tee -a "$TXT_REPORT"
grep -RniE "TODO|FIXME|BUG|HACK" "$PROJECT" || true

cat > "$JSON_REPORT" <<EOF
{
  "project": "$PROJECT",
  "timestamp": "$TS",
  "size": "$(du -sh "$PROJECT" | cut -f1)",
  "file_count": $(find "$PROJECT" -type f | wc -l)
}
EOF

echo "Report uložen: $TXT_REPORT a $JSON_REPORT"
