#!/bin/bash

while true; do
clear
echo "===== SECURITY & HARDENING MENU ====="
echo "1) Stav firewallu"
echo "2) Stav fail2ban"
echo "3) Spustit audit systému"
echo "4) Kontrola integrity"
echo "5) Restart bezpečnostních služeb"
echo "6) Exit"

read -p "Vyber: " opt

case $opt in
1) ufw status; read ;;
2) systemctl status fail2ban; read ;;
3) lynis audit system; read ;;
4) bash /opt/platform/security/integrity_check.sh; read ;;
5) systemctl restart ufw fail2ban auditd; read ;;
6) exit ;;
*) echo "Neplatná volba"; sleep 2 ;;
esac
done
