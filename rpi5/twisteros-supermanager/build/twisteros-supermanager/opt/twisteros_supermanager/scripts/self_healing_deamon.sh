#!/bin/bash
# self_heal_daemon.sh – kontrola & automatická oprava
# Umístění: ~/twister-smart-suite/scripts/self_heal_daemon.sh

set -euo pipefail
IFS=$'\n\t'

LOG="$HOME/twister-smart-suite/logs/self_heal.log"
mkdir -p "$(dirname "$LOG")"

echo "$(date '+%Y-%m-%d %H:%M:%S') START self_heal" | tee -a "$LOG"

# Funkce pro restart docker compose projektu pokud kontejner chybí
repair_docker_project() {
  local dir="$1"
  local name="$2"
  if [ -d "$dir" ]; then
    if ! sudo docker ps --format '{{.Names}}' | grep -qw "$name"; then
      echo "$(date '+%Y-%m-%d %H:%M:%S') Restart $name v $dir" | tee -a "$LOG"
      (cd "$dir" && sudo docker compose up -d) &>>"$LOG" || echo "Chyba při startu $name" | tee -a "$LOG"
    else
      echo "$(date '+%Y-%m-%d %H:%M:%S') $name běží" | tee -a "$LOG"
    fi
  else
    echo "$(date '+%Y-%m-%d %H:%M:%S') $dir neexistuje" | tee -a "$LOG"
  fi
}

# Docker kontejnery
repair_docker_project "$HOME/homeassistant" "home-assistant"
repair_docker_project "$HOME/smart-hub" "nodered"
repair_docker_project "$HOME/smart-hub" "mqtt"

# VNC
if ! systemctl is-active --quiet vncserver-x11-serviced.service; then
  echo "$(date '+%Y-%m-%d %H:%M:%S') Restart VNC" | tee -a "$LOG"
  sudo systemctl restart vncserver-x11-serviced.service || echo "Nelze restartovat VNC" | tee -a "$LOG"
fi

# Conky
if ! pgrep -x conky >/dev/null 2>&1; then
  echo "$(date '+%Y-%m-%d %H:%M:%S') Spouštím Conky" | tee -a "$LOG"
  (conky &) || echo "Chyba při spuštění conky" | tee -a "$LOG"
fi

# Web dashboard (Node)
if ! ss -tln | grep -q ':8080'; then
  if [ -d "$HOME/twisteros_supermanager/twister-dashboard" ]; then
    echo "$(date '+%Y-%m-%d %H:%M:%S') Start web dashboard" | tee -a "$LOG"
    nohup node "$HOME/twisteros_supermanager/twister-dashboard/app.js" >/dev/null 2>&1 &
  else
    echo "$(date '+%Y-%m-%d %H:%M:%S') Dashboard adresář nenalezen" | tee -a "$LOG"
  fi
fi

# SSH
if ! systemctl is-active --quiet ssh; then
  echo "$(date '+%Y-%m-%d %H:%M:%S') Start SSH" | tee -a "$LOG"
  sudo systemctl start ssh || echo "SSH nelze spustit" | tee -a "$LOG"
fi

echo "$(date '+%Y-%m-%d %H:%M:%S') END self_heal" | tee -a "$LOG"
