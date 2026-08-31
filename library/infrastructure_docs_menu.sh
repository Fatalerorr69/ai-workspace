#!/bin/bash

while true; do
clear
echo "===== PLATFORM DOCUMENTATION MENU ====="
echo "1) Zobraz runbook"
echo "2) Zobraz recovery plán"
echo "3) Export konfigurace (ZIP)"
echo "4) Backup dokumentace"
echo "5) Generuj HTML dokumentaci"
echo "6) Exit"

read -p "Vyber: " opt

case $opt in
1) less /opt/platform/docs/runbook.md ;;
2) less /opt/platform/docs/recovery.md ;;
3) bash /opt/platform/docs/export.sh; read ;;
4) bash /opt/platform/docs/backup_docs.sh; read ;;
5) bash /opt/platform/docs/generate_docs.sh; read ;;
6) exit ;;
*) echo "Neplatná volba"; sleep 2 ;;
esac
done
