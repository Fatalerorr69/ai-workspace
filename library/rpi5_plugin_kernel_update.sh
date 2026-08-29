#!/bin/bash
# Plugin: Aktualizace jádra
LOG=~/twisteros_supermanager/logs/plugin.log

status() { uname -r | tee -a "$LOG"; }
start() { 
    echo "⬆️ Aktualizuji jádro a balíčky..." | tee -a "$LOG"
    sudo apt update && sudo apt upgrade -y | tee -a "$LOG"
}
stop() { echo "⏹ Kernel update plugin ukončen" | tee -a "$LOG"; }

case $1 in
    start) start ;;
    stop) stop ;;
    status) status ;;
    *) echo "Použití: $0 {start|stop|status}" ;;
esac
