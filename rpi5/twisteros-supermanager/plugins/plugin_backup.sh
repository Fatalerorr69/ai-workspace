#!/bin/bash
# Plugin: Automatické zálohování
LOG=~/twisteros_supermanager/logs/plugin.log
BACKUP_DIR=~/twisteros_supermanager/backup/$(date +%Y%m%d_%H%M%S)

status() { echo "Zálohy: $(ls -1 ~/twisteros_supermanager/backup)" | tee -a "$LOG"; }
start() { 
    echo "💾 Spouštím zálohování..." | tee -a "$LOG"
    mkdir -p "$BACKUP_DIR"
    cp -r ~/twisteros_supermanager/config "$BACKUP_DIR/"
    cp -r ~/twisteros_supermanager/scripts "$BACKUP_DIR/"
    echo "✅ Zálohování dokončeno: $BACKUP_DIR" | tee -a "$LOG"
}
stop() { echo "⏹ Backup plugin ukončen" | tee -a "$LOG"; }

case $1 in
    start) start ;;
    stop) stop ;;
    status) status ;;
    *) echo "Použití: $0 {start|stop|status}" ;;
esac
