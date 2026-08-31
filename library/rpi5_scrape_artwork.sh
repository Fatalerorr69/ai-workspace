#!/bin/bash
echo "🎭 Stahuji artwork..."

ROMDIR=~/Games/ROMs
ARTDIR=~/Games/Artwork
mkdir -p "$ARTDIR"

for FILE in "$ROMDIR"/*.zip; do
    NAME=$(basename "$FILE" .zip)
    wget -q "https://thumbnails.libretro.com/$NAME.png" -O "$ARTDIR/$NAME.png" || true
done

echo "🎨 Artwork hotov!"
