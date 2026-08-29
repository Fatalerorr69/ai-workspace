#!/bin/bash
set -e

echo "=== NAS INSTALL START ==="

apt update && apt -y upgrade

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

pip3 install flask gunicorn psutil

systemctl enable cockpit
systemctl start cockpit
systemctl enable smbd nmbd nfs-server

ufw allow ssh
ufw allow 9090
ufw allow 8443
ufw allow samba
ufw allow nfs
ufw enable

echo "=== NAS BASE READY ==="
