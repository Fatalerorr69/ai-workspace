#!/bin/bash

DEST="/srv/backups/docs"
DATE=$(date +%F)

mkdir -p "$DEST"
cp -r /opt/platform/docs "$DEST/docs_$DATE"

echo "Dokumentace zazálohována."
