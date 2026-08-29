#!/bin/bash
set -e

ROOT="$(cd "$(dirname "$0")" && pwd)"
OUT="$ROOT/ultra-v16-final"
ARCHIVE="$ROOT/ultra-v16-final.tar.gz"

echo "🔧 BUILD: ULTRA v16 FINAL"

rm -rf "$OUT"
mkdir -p "$OUT"

echo "📦 Kopírování souborů..."
cp -r \
  install.sh \
  ULTRA_MANIFEST.json \
  core modules plugins web gui registry \
  "$OUT/"

mkdir -p "$OUT/logs" "$OUT/cache"

echo "🧹 Čištění..."
find "$OUT" -name "__pycache__" -exec rm -rf {} +
find "$OUT" -name "*.log" -delete

echo "📄 README"
cat > "$OUT/README.md" <<EOF
ULTRA v16 FINAL

Instalace:
  sudo bash install.sh

Obsah:
- Modulární instalátor
- AI doporučování modulů + pluginů
- Web GUI + API
- Plugin marketplace
- PWA kompatibilní GUI

EOF

echo "📦 Vytvářím archiv..."
tar -czf "$ARCHIVE" -C "$ROOT" ultra-v16-final

echo "✅ HOTOVO: $ARCHIVE"
