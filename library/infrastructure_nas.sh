#!/bin/bash

log_info "Instaluji NAS (Samba)"

apt install -y samba samba-common-bin

mkdir -p /srv/nas/{public,family,admin,robot-data}

chmod -R 770 /srv/nas
chown -R "$USER_CFG":"$USER_CFG" /srv/nas

cat <<EOF >>/etc/samba/smb.conf

[public]
path = /srv/nas/public
browseable = yes
read only = no
guest ok = yes

[family]
path = /srv/nas/family
browseable = yes
read only = no
valid users = $USER_CFG

[admin]
path = /srv/nas/admin
browseable = yes
read only = no
valid users = $USER_CFG

[robot-data]
path = /srv/nas/robot-data
browseable = yes
read only = no
valid users = $USER_CFG
EOF

systemctl restart smbd

log_ok "NAS (Samba) nakonfigurován"
