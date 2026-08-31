#!/bin/bash

log_info "Instaluji backup nástroje (restic + cron)"

apt install -y restic cron

BACKUP_DIR=$(jq -r '.backup_path' "$CONFIG")

mkdir -p "$BACKUP_DIR/restic-repo"

export RESTIC_REPOSITORY="$BACKUP_DIR/restic-repo"
export RESTIC_PASSWORD="platformbackup"

restic init || true

cat <<EOF >/etc/cron.daily/platform-backup
#!/bin/bash
export RESTIC_REPOSITORY="$BACKUP_DIR/restic-repo"
export RESTIC_PASSWORD="platformbackup"
restic backup /etc /home /srv
EOF

chmod +x /etc/cron.daily/platform-backup

log_ok "Backup systém nakonfigurován (denní zálohy)"
