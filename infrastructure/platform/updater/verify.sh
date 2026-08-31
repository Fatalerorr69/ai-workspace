#!/bin/bash

VERSION_FILE="/opt/platform/updater/version.json"

echo "Kontrola integrity systému..."

if [ ! -f "$VERSION_FILE" ]; then
    echo "Chybí version.json"
    exit 1
fi

jq . "$VERSION_FILE" >/dev/null || exit 1

echo "Verze:"
cat "$VERSION_FILE"
echo "Systém je konzistentní."
