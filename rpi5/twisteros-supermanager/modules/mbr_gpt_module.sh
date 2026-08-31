#!/bin/bash
MODULE_NAME="mbr_gpt_module.sh"
LOG_FILE="$HOME/twisteros_supermanager/logs/plugin.log"

echo "$(date '+%Y-%m-%d %H:%M:%S') 💾 Spouštím MBR/GPT modul..." | tee -a "$LOG_FILE"

sudo parted -l >/dev/null 2>&1 && STATUS="✅ MBR/GPT ok" || STATUS="❌ Chyba MBR/GPT"

echo "$(date '+%Y-%m-%d %H:%M:%S') $STATUS" | tee -a "$LOG_FILE"
