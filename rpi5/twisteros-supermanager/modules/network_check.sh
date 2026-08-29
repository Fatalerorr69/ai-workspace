#!/bin/bash
MODULE_NAME="network_check.sh"
LOG_FILE="$HOME/twisteros_supermanager/logs/plugin.log"
PING_TARGET="8.8.8.8"

echo "$(date '+%Y-%m-%d %H:%M:%S') 🌐 Spouštím modul kontroly sítě..." | tee -a "$LOG_FILE"

ping -c 3 $PING_TARGET >/dev/null 2>&1 && STATUS="✅ online" || STATUS="❌ offline"

echo "$(date '+%Y-%m-%d %H:%M:%S') Stav sítě: $STATUS" | tee -a "$LOG_FILE"
