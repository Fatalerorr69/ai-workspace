#!/bin/bash
echo "[AI] Analýza instalace..."

if [ -d modules/android ]; then
  echo "✔ Doporučeno: android-tools"
fi
if [ -f logs/install.log ]; then
  echo "✔ Doporučeno: log-analyzer"
fi
