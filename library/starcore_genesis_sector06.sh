#!/bin/bash
# GENESIS AETERNA - SEKTOR 06: GHOST-SENTINEL
G='\033[0;32m'; B='\033[0;34m'; NC='\033[0m'

echo -e "${B}--- AKTIVACE SEKTORU 06: GHOST-SENTINEL ---${NC}"

# 1. Instalace Logwatch a Fail2Ban pro ochranu SSH
sudo apt install -y fail2ban logwatch

# 2. Vytvoření AI-Security Sonda
# Tento skript extrahuje podezřelé aktivity a připraví je pro Sektor 10 (AI Analýzu)
cat > ~/genesis/tools/security_sonda.sh <<EOF
#!/bin/bash
echo "--- SECURITY AUDIT LOG \$(date) ---" > ~/genesis/logs/security_sonda.log
grep "Failed password" /var/log/auth.log | tail -n 10 >> ~/genesis/logs/security_sonda.log
echo "Aktivní spojení:" >> ~/genesis/logs/security_sonda.log
netstat -ant | grep ESTABLISHED >> ~/genesis/logs/security_sonda.log
EOF
chmod +x ~/genesis/tools/security_sonda.sh

# 3. Plánování sondy (každou hodinu)
(crontab -l 2>/dev/null; echo "0 * * * * ~/genesis/tools/security_sonda.sh") | crontab -

echo -e "${G}Sektor 06 ONLINE: Systém nyní monitoruje neúspěšné pokusy o přihlášení.${NC}"
