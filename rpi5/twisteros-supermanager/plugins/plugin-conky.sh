#!/bin/bash
PLUGIN_NAME="plugin_conky.sh"
LOG_FILE="$HOME/twisteros_supermanager/logs/plugin.log"
STATUS_JSON="$HOME/twisteros_supermanager/twister-dashboard/data/plugin_status.json"

echo "$(date '+%Y-%m-%d %H:%M:%S') 🖥 Spouštím Conky monitor..." | tee -a "$LOG_FILE"

mkdir -p ~/.config/autostart
cat << 'EOF' > ~/.config/autostart/conky.desktop
[Desktop Entry]
Type=Application
Exec=conky
Hidden=false
NoDisplay=false
X-GNOME-Autostart-enabled=true
Name=Conky Monitor
EOF

conky &

# Aktualizace statusu
jq --arg p "$PLUGIN_NAME" --arg s "✅ aktivní" '.[$p]=$s' "$STATUS_JSON" > "${STATUS_JSON}.tmp" && mv "${STATUS_JSON}.tmp" "$STATUS_JSON"

echo "✅ Conky spuštěn." | tee -a "$LOG_FILE"
