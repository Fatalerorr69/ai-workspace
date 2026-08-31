#!/bin/bash
PLUGIN_NAME="plugin_home_assistant.sh"
LOG_FILE="$HOME/twisteros_supermanager/logs/plugin.log"
STATUS_JSON="$HOME/twisteros_supermanager/twister-dashboard/data/plugin_status.json"

echo "$(date '+%Y-%m-%d %H:%M:%S') 🏠 Spouštím Home Assistant a Node-RED..." | tee -a "$LOG_FILE"

cd ~/homeassistant && sudo docker compose up -d
cd ~/smart-hub && sudo docker compose up -d

jq --arg p "$PLUGIN_NAME" --arg s "✅ aktivní" '.[$p]=$s' "$STATUS_JSON" > "${STATUS_JSON}.tmp" && mv "${STATUS_JSON}.tmp" "$STATUS_JSON"

echo "✅ Home Assistant a Node-RED spuštěny." | tee -a "$LOG_FILE"
