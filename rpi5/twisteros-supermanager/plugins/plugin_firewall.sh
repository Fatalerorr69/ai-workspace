#!/bin/bash
# Plugin: Správa firewallu
LOG=~/twisteros_supermanager/logs/plugin.log

start() {
    echo "🛡 Aktivace firewallu..." | tee -a "$LOG"
    sudo ufw enable
    sudo ufw allow 22/tcp
    sudo ufw allow 5900/tcp
}
stop() { echo "⏹ Firewall plugin ukončen" | tee -a "$LOG"; }
status() { sudo ufw status | tee -a "$LOG"; }

case $1 in
    start) start ;;
    stop) stop ;;
    status) status ;;
    *) echo "Použití: $0 {start|stop|status}" ;;
esac
