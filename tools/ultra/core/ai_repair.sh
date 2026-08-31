#!/bin/bash
LOG="$1"
echo "[AI-REPAIR] Analýza logu $LOG"

if grep -q "command not found" "$LOG"; then
  echo "[AI-REPAIR] Detekována chybějící funkce – opravuji PATH"
  export PATH=$PATH:/usr/local/bin
fi

if grep -q "No such file or directory" "$LOG"; then
  echo "[AI-REPAIR] Chybějící soubory – spouštím structure_guard"
  bash core/structure_guard.sh
fi

if grep -q "Permission denied" "$LOG"; then
  echo "[AI-REPAIR] Opravuji práva"
  chmod -R 755 .
fi

echo "[AI-REPAIR] Opravy aplikovány"
