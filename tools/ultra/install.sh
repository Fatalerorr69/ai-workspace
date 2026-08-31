#!/bin/bash
# ULTRA v18 FINAL INSTALLER

ULTRA_ROOT=$(pwd)
LOG_FILE="$ULTRA_ROOT/logs/install.log"
mkdir -p "$ULTRA_ROOT/logs"

log() {
    echo "[$(date +%F\ %T)] $*" | tee -a "$LOG_FILE"
}

# --- STRUCTURE GUARD ---
structure_guard() {
    log "[STRUCTURE] Kontrola složek a souborů ULTRA..."
    for dir in core modules plugins web pwa registry logs snapshots gui; do
        if [ ! -d "$ULTRA_ROOT/$dir" ]; then
            mkdir -p "$ULTRA_ROOT/$dir"
            log "[STRUCTURE] Vytvořena chybějící složka: $dir"
        fi
    done

    for file in core/ai_engine.sh core/module_loader.sh core/plugin_recommender.sh core/structure_guard.sh core/env.sh; do
        if [ ! -f "$ULTRA_ROOT/$file" ]; then
            touch "$ULTRA_ROOT/$file"
            echo "# placeholder" > "$ULTRA_ROOT/$file"
            log "[STRUCTURE] Vytvořen chybějící core soubor: $(basename $file)"
        fi
    done
}

# --- MODULY ---
install_module() {
    MOD=$1
    log "[MODULE] Instalace modulu $MOD"
    if [ -f "$ULTRA_ROOT/modules/$MOD/${MOD}_install.sh" ]; then
        bash "$ULTRA_ROOT/modules/$MOD/${MOD}_install.sh"
    else
        log "[MODULE] $MOD placeholder instalace"
    fi
}

# --- VOLITELNÝ BACKEND ---
backend_step() {
    read -p "Spustit volitelný backend krok? (y/n): " ans
    if [[ "$ans" == "y" ]]; then
        log "[BACKEND] Spouštím AI doporučení pluginů..."
        if [ -f "$ULTRA_ROOT/core/plugin_recommender.sh" ]; then
            bash "$ULTRA_ROOT/core/plugin_recommender.sh"
        fi
    fi
}

# --- WEB GUI INSTALLER ---
launch_web_installer() {
    log "[WEB] Spouštím web GUI installer..."
    if [ -f "$ULTRA_ROOT/web/installer.py" ]; then
        python3 "$ULTRA_ROOT/web/installer.py" &
        log "[WEB] Web installer dostupný na http://localhost:8080"
    fi
}

# --- Hlavní ---
log "=== ULTRA v18 FINAL INSTALLER ==="

structure_guard

echo "Vyber profil instalace:"
echo "1) core"
echo "2) full"
echo "3) pentest"
read -p "#? " profile

case $profile in
    1)
        log "[PROFILE] Vybrán profil: core"
        install_module ai
        install_module android
        ;;
    2)
        log "[PROFILE] Vybrán profil: full"
        install_module ai
        install_module android
        install_module web
        install_module pentest
        install_module pwa
        ;;
    3)
        log "[PROFILE] Vybrán profil: pentest"
        install_module pentest
        ;;
    *)
        log "[PROFILE] Neznámý profil, ukončuji"
        exit 1
        ;;
esac

backend_step
launch_web_installer

log "✅ ULTRA v18 FINAL instalace dokončena!"
