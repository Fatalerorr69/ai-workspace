#!/bin/bash
BACKUP=~/twister_backup_$(date +%F).img

echo "💾 Vytvářím zálohu OS..."
sudo dd if=/dev/mmcblk0 of=$BACKUP bs=4M status=progress

echo "📦 Hotovo: $BACKUP"
