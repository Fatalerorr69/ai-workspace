#!/bin/bash
# =====================================================================
# SuperNastroj Updater - Bezpečná aktualizace TUI a pluginů s logováním
# =====================================================================

BASE_DIR="$HOME/SuperNastroj"
LOG_DIR="$BASE_DIR/SuperNastroj_Logs"
REPO_URL="https://github.com/Fatalerorr69/SuperNastroj.git"
BRANCH="main"

mkdir -p "$LOG_DIR"
LOG_FILE="$LOG_DIR/updater.log"

log() {
    echo "[$(date +'%Y-%m-%d %H:%M:%S')] $1" | tee -a "$LOG_FILE"
}

log "[*] Spouštím updater..."

# Aktualizace repozitáře
if [ -d "$BASE_DIR/.git" ]; then
    log "[*] Aktualizuji existující repozitář..."
    cd "$BASE_DIR" || { log "[!] Nelze přejít do $BASE_DIR"; exit 1; }
    git reset --hard >> "$LOG_FILE" 2>&1
    git pull origin $BRANCH >> "$LOG_FILE" 2>&1
else
    log "[*] Klonování repozitáře poprvé..."
    git clone -b $BRANCH $REPO_URL "$BASE_DIR" >> "$LOG_FILE" 2>&1
fi

# Kontrola TUI
TUI="$BASE_DIR/supernastroj_v5_tui.sh"
if [ ! -f "$TUI" ]; then
    log "[!] Chyba: TUI soubor neexistuje!"
    exit 1
fi
chmod +x "$TUI"

# Pluginy
PLUGIN_DIR="$BASE_DIR/plugins"
if [ -d "$PLUGIN_DIR" ]; then
    chmod +x "$PLUGIN_DIR/"*.sh 2>/dev/null
    PLUGINS=()
    for f in "$PLUGIN_DIR/"*.sh; do
        [ -f "$f" ] && PLUGINS+=("$f")
    done
    if [ ${#PLUGINS[@]} -eq 0 ]; then
        log "[!] Žádné platné pluginy nebyly nalezeny."
    else
        log "[*] Pluginy připraveny ke spuštění: ${#PLUGINS[@]}"
    fi
else
    log "[!] Pluginy nebyly nalezeny."
fi

# Volba spuštění pluginů
read -rp "[*] Chceš spustit všechny pluginy nebo vybrat konkrétní? (vše/vybrat) " choice
case "$choice" in
    vše)
        log "[*] Spouštím všechny pluginy..."
        for plugin in "${PLUGINS[@]}"; do
            log "[*] Spouštím $plugin"
            "$plugin" >> "$LOG_FILE" 2>&1
            [ $? -eq 0 ] && log "[+] $plugin dokončen úspěšně." || log "[!] Chyba při spuštění $plugin."
        done
        ;;
    vybrat)
        log "[*] Dostupné pluginy:"
        select p in "${PLUGINS[@]}"; do
            if [ -f "$p" ]; then
                log "[*] Spouštím vybraný plugin $p"
                "$p" >> "$LOG_FILE" 2>&1
                [ $? -eq 0 ] && log "[+] Plugin dokončen úspěšně." || log "[!] Chyba při spuštění pluginu."
            fi
            break
        done
        ;;
    *)
        log "[!] Neplatná volba, pluginy nebudou spuštěny."
        ;;
esac

# Spuštění TUI
log "[*] Spouštím TUI..."
"$TUI" >> "$LOG_FILE" 2>&1
if [ $? -eq 0 ]; then
    log "[+] TUI spuštěna úspěšně."
else
    log "[!] Chyba při spuštění TUI."
fi
