# DISASTER RECOVERY

## Obnova systému

1. Flash nový OS
2. Připoj zálohový disk
3. Spusť restore skript

```
bash /opt/platform/docs/restore.sh

Obnova konfigurace

/opt/platform

/etc/docker

/etc/systemd/system

Kontrola

systemctl status

docker ps

ověř web panel


---

# 📄 `docs/export.sh`

```bash
#!/bin/bash

EXPORT_DIR="/srv/backups/platform-export"
DATE=$(date +%F_%H-%M)
ARCHIVE="$EXPORT_DIR/platform_$DATE.zip"

mkdir -p "$EXPORT_DIR"

zip -r "$ARCHIVE" \
/opt/platform \
/etc/systemd/system \
/etc/docker \
/etc/ssh \
/etc/fail2ban \
/etc/ufw \
/opt/platform/docs

echo "Export hotov: $ARCHIVE"
