#!/bin/bash
LOG="$ULTRA_ROOT/logs/install.log"

while true; do
  if [ -f "$LOG" ]; then
    bash core/ai_repair.sh "$LOG"
  fi
  sleep 30
done
