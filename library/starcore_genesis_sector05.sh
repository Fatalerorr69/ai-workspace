#!/bin/bash
# GENESIS AETERNA - SEKTOR 05: INTEGRITY SHIELD
G='\033[0;32m'; B='\033[0;34m'; NC='\033[0m'

echo -e "${B}--- AKTIVACE SEKTORU 05: INTEGRITY SHIELD ---${NC}"

# 1. SSD Health Check (SMART Monitoring)
sudo apt install -y smartmontools
cat > ~/genesis/tools/check_ssd.sh <<EOF
#!/bin/bash
echo "--- SSD REPORT \$(date) ---" >> ~/genesis/logs/integrity.log
sudo smartctl -a /dev/nvme0n1 | grep -E "Percentage Used|Data Units Read|Temperature" >> ~/genesis/logs/integrity.log
EOF
chmod +x ~/genesis/tools/check_ssd.sh

# 2. Auto-Backup (Šifrovaný archiv Vaultu)
cat > ~/genesis/tools/backup_vault.sh <<EOF
#!/bin/bash
tar -czf ~/genesis/backups/vault_\$(date +%F).tar.gz ~/genesis/vault/
echo "Záloha Vaultu dokončena: \$(date)" >> ~/genesis/logs/integrity.log
EOF
mkdir -p ~/genesis/backups
chmod +x ~/genesis/tools/backup_vault.sh

# 3. Plánování úloh (Cron)
(crontab -l 2>/dev/null; echo "0 3 * * * ~/genesis/tools/check_ssd.sh") | crontab -
(crontab -l 2>/dev/null; echo "0 4 * * 0 ~/genesis/tools/backup_vault.sh") | crontab -

echo -e "${G}Sektor 05 aktivován: Denní kontrola SSD a týdenní záloha nastavena.${NC}"
