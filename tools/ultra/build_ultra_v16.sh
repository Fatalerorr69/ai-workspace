#!/bin/bash
set -e

# --- konfigurace ---
REPO_URL="https://github.com/Fatalerorr69/ultra.git"
WORKDIR="$(pwd)/ultra_build"
FINAL_DIR="$(pwd)/ultra-v16-final"

# --- příprava pracovního adresáře ---
rm -rf "$WORKDIR" "$FINAL_DIR"
mkdir -p "$WORKDIR" "$FINAL_DIR"

echo "🔹 Klonování repozitáře ULTRA..."
git clone --depth=1 "$REPO_URL" "$WORKDIR/ultra"

# --- kopírování hlavní struktury ---
echo "🔹 Kopírování hlavních složek..."
for dir in install.sh ultra VERSION README.md LICENSE core modules plugins gui web; do
  cp -r "$WORKDIR/ultra/$dir" "$FINAL_DIR/"
done

# --- vytvoření cache, logs, registry ---
mkdir -p "$FINAL_DIR/cache/github" "$FINAL_DIR/logs" "$FINAL_DIR/registry"

# --- auto-extract GitHub modulů ---
echo "🔹 Spouštím auto-extract GitHub modulů..."
bash "$FINAL_DIR/core/auto_extract.sh"

# --- generování modulů a registrů ---
echo "🔹 Generování modules.json a registrů..."
bash "$FINAL_DIR/core/generate_registry.sh"

cp registry/modules.json registry/extracted_modules.json registry/install_profiles.json "$FINAL_DIR/registry/"

# --- vytvoření distribuce ---
echo "🔹 Vytvářím tar.gz a zip balíky..."
tar -czvf ultra-v16-final.tar.gz -C "$FINAL_DIR" .
zip -r ultra-v16-final.zip "$FINAL_DIR"

echo "✅ ULTRA v16 FINAL balík připraven!"
echo "📦 Výstup: ultra-v16-final.tar.gz a ultra-v16-final.zip"
