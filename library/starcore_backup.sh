#!/bin/bash
BACKUP_DIR="$HOME/STARCORE_backup_$(date +%Y%m%d_%H%M%S)"
mkdir -p "$BACKUP_DIR"
cp -r ~/STARCORE/data "$BACKUP_DIR/"
cp ~/STARCORE/services/services.json "$BACKUP_DIR/"
echo "✅ Záloha vytvořena v $BACKUP_DIR"
