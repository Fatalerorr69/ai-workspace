#!/bin/bash
set -e

echo "=== MINIMAL ENTERPRISE NAS INSTALL ==="

if [ "$EUID" -ne 0 ]; then
  echo "Spusť jako root"
  exit 1
fi

# Aktualizace
apt update && apt -y upgrade

# Core balíky
apt install -y \
  zfsutils-linux \
  samba nfs-kernel-server \
  open-iscsi targetcli-fb \
  cockpit cockpit-storaged \
  python3 python3-pip \
  acl attr \
  fail2ban ufw \
  smartmontools \
  curl wget git

# Web stack
pip3 install flask gunicorn psutil

# Služby
systemctl enable cockpit
systemctl start cockpit
systemctl enable smbd nmbd nfs-server

# Firewall
ufw allow ssh
ufw allow 9090
ufw allow 8080
ufw allow samba
ufw allow nfs
ufw enable

echo "=== ZÁKLAD HOTOV ==="
