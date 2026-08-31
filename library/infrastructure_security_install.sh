#!/bin/bash

CONFIG="/opt/platform/security/security_config.json"
LOG="/opt/platform/security/security.log"

log() {
  echo "[SECURITY $(date '+%F %T')] $1" | tee -a "$LOG"
}

log "Instaluji bezpečnostní balíky..."

apt update
apt install -y ufw fail2ban auditd apparmor apparmor-utils unattended-upgrades lynis jq

bash /opt/platform/security/ssh_hardening.sh
bash /opt/platform/security/firewall.sh
bash /opt/platform/security/fail2ban.sh
bash /opt/platform/security/auto_updates.sh
bash /opt/platform/security/audit.sh
bash /opt/platform/security/apparmor.sh

log "Bezpečnostní instalace dokončena."
