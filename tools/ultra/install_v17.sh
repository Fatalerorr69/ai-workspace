#!/bin/bash
set -e
ULTRA_ROOT="$(cd "$(dirname "$0")" && pwd)"
LOG_FILE="$ULTRA_ROOT/logs/install.log"

# --- načtení core funkcí ---
source "$ULTRA_ROOT/core/env.sh"
source "$ULTRA_ROOT/core/logger.sh"
source "$ULTRA_ROOT/core/repair.sh"
source "$ULTRA_ROOT/core/auto_extract.sh"
source "$ULTRA_ROOT/core/generate_registry.sh"

repair_structure

# --- funkce pro profily ---
ultra_profile_full() {
    log "Instalace FULL profilu..."
    ultra_install_modules "full"
}

ultra_profile_core() {
    log "Instalace CORE profilu..."
    ultra_install_modules "core"
}

ultra_profile_pentest() {
    log "Instalace PENTEST profilu..."
    ultra_install_modules "pentest"
}

ultra_install_modules() {
    PROFILE="$1"
    MODULES=$(jq -r ".${PROFILE}[]" "$ULTRA_ROOT/registry/install_profiles.json")
    for mod in $MODULES; do
        MOD_DIR="$ULTRA_ROOT/modules/$mod"
        if [ -f "$MOD_DIR/install.sh" ]; then
            log "Instaluji modul $mod..."
            bash "$MOD_DIR/install.sh"
        else
            log "Upozornění: modul $mod nemá install.sh"
        fi
    done
}

# --- GUI / PWA instalátor ---
launch_gui() {
    log "Spouštím GUI instalátor (PWA)..."
    python3 -m http.server 9090 --directory "$ULTRA_ROOT/gui" &
    GUI_PID=$!
    echo "Otevři v prohlížeči http://localhost:9090/installer.html"
    echo "Stiskni Ctrl+C pro ukončení GUI"
    wait $GUI_PID
}

# --- auto-extract GitHub modulů ---
log "Spouštím auto-extract GitHub modulů..."
bash "$ULTRA_ROOT/core/auto_extract.sh"

# --- generování registrů ---
log "Generuji registry modulů..."
bash "$ULTRA_ROOT/core/generate_registry.sh"

# --- volba instalace ---
if [ "$1" == "--gui" ]; then
    launch_gui
    exit 0
fi

echo "================ ULTRA v16 FINAL ================"
echo "Vyber profil instalace:"
echo "1) Full install"
echo "2) Core only"
echo "3) Pentest + Android"
read -r choice

case $choice in
    1) ultra_profile_full ;;
    2) ultra_profile_core ;;
    3) ultra_profile_pentest ;;
    *) echo "Neplatná volba"; exit 1 ;;
esac

log "Instalace dokončena!"
