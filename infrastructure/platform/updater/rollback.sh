#!/bin/bash

BACKUP_DIR="/opt/platform/backups"

echo "Dostupné zálohy:"
select file in $BACKUP_DIR/*.tar.gz; do
    if [ -n "$file" ]; then
        echo "Obnovuji ze zálohy $file"
        tar -xzf "$file" -C /
        echo "Hotovo."
        break
    fi
done
