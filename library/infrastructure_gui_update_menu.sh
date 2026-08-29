#!/bin/bash

while true; do
    clear
    echo "===== PLATFORM OTA UPDATE MENU ====="
    echo "1) Zkontrolovat verzi"
    echo "2) Spustit aktualizaci"
    echo "3) Rollback"
    echo "4) Ověřit integritu"
    echo "5) Exit"
    read -p "Vyber: " choice

    case $choice in
        1) cat /opt/platform/updater/version.json; read ;;
        2) bash /opt/platform/updater/updater.sh; read ;;
        3) bash /opt/platform/updater/rollback.sh; read ;;
        4) bash /opt/platform/updater/verify.sh; read ;;
        5) exit 0 ;;
        *) echo "Neplatná volba"; sleep 2 ;;
    esac
done
