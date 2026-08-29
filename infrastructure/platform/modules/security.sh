#!/bin/bash

log_info "Provádím bezpečnostní hardening"

apt install -y ufw fail2ban auditd lynis rkhunter

# SSH hardening
sed -i 's/^#\?PermitRootLogin .*/PermitRootLogin no/' /etc/ssh/sshd_config
sed -i 's/^#\?PasswordAuthentication .*/PasswordAuthentication no/' /etc/ssh/sshd_config

systemctl restart ssh

# Firewall
ufw default deny incoming
ufw default allow outgoing
ufw allow 22
ufw allow 8080
ufw allow 3000
ufw --force enable

# Fail2ban
systemctl enable fail2ban
systemctl start fail2ban

# Audit rules
auditctl -w /etc/passwd -p wa -k passwd_changes
auditctl -w /etc/shadow -p wa -k shadow_changes

log_ok "Security hardening dokončen"
