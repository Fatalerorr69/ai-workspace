`#!/bin/bash`  
`# Sektor 09: Kybernetický dohled v reálném čase`  
`G='\033[0;32m'; R='\033[0;31m'; B='\033[0;34m'; NC='\033[0m'`  
`LOG_FILE="$HOME/genesis/logs/security_audit.log"`

`echo -e "${B}[S09] Aktivuji Security Sentinel...${NC}"`

`# Funkce pro záznam incidentu`  
`log_incident() {`  
    `local msg=$1`  
    `echo "[$(date '+%Y-%m-%d %H:%M:%S')] ALERT: $msg" >> "$LOG_FILE"`  
`}`

`# 1. Kontrola pokusů o SSH brute-force`  
`CHECK_SSH=$(tail -n 50 /var/log/auth.log 2>/dev/null | grep "Failed password" | wc -l)`  
`if [ "$CHECK_SSH" -gt 5 ]; then`  
    `echo -e "${R}Varování: Detekovány neúspěšné pokusy o přihlášení!${NC}"`  
    `log_incident "Možný Brute-force útok na SSH (Detekováno $CHECK_SSH pokusů)."`  
`fi`

`# 2. Skenování otevřených portů na lokální síti`  
`MY_IP=$(hostname -I | awk '{print $1}')`  
`echo -e "${G}Provádím rychlý sken sítě pro: $MY_IP/24${NC}"`  
`nmap -sn "$MY_IP/24" | grep "Nmap scan report" >> "$LOG_FILE"`

`# 3. Kontrola anonymity (pokud běží Tor v Sektoru 11)`  
`if systemctl is-active --quiet tor; then`  
    `echo -e "${G}Tor Proxy je aktivní.${NC}"`  
`else`  
    `log_incident "Sektor 11 (Tor) je offline, anonymita ohrožena."`  
`fi`

`echo -e "${B}Sledování dokončeno. Výsledek uložen v $LOG_FILE${NC}"`  
