#!/bin/bash
set -e
ULTRA_ROOT="$HOME/ultra"
CACHE_DIR="$ULTRA_ROOT/cache"
KALI="http://http.kali.org/kali/pool/main"
SECLISTS="https://github.com/danielmiessler/SecLists.git"

mkdir -p "$ULTRA_ROOT"
mkdir -p "$CACHE_DIR"
mkdir -p "$ULTRA_ROOT/plugins/enabled"

log() { echo "[$(date '+%F %T')] $1" | tee -a "$ULTRA_ROOT/modules/web/ultra.log"; }

install_pkg() {
    sudo apt update && sudo apt install -y "$@"
}

download() {
    local url="$1"
    local dest="$2"
    if [ ! -f "$dest" ]; then
        wget -q --show-progress "$url" -O "$dest"
    fi
}

# ----------------------------
# CORE INSTALL
# ----------------------------
install_core_only() {
    log "[CORE] Instalace základu ULTRA"
    install_pkg git curl python3 python3-venv
}

# ----------------------------
# ANDROID MODULE
# ----------------------------
android_install() {
    log "[ANDROID] Instalace Android nástrojů"
    install_pkg adb fastboot
}

# ----------------------------
# AI MODULE
# ----------------------------
ai_install() {
    log "[AI] Instalace AI modulu"
    mkdir -p "$ULTRA_ROOT/modules/ai"
    python3 -m venv "$ULTRA_ROOT/modules/ai/venv"
    source "$ULTRA_ROOT/modules/ai/venv/bin/activate"
    pip install --upgrade pip
    pip install openai transformers torch psutil
    touch "$ULTRA_ROOT/modules/ai/ultra_ai.log"
}

ai_run() {
    log "[AI] Spouštím AI daemon"
    source "$ULTRA_ROOT/modules/ai/venv/bin/activate"
    nohup python3 "$ULTRA_ROOT/modules/ai/ai_core.py" > /dev/null 2>&1 &
}

# ----------------------------
# WEB DASHBOARD
# ----------------------------
web_install() {
    log "[WEB] Instalace web dashboardu"
    install_pkg python3 python3-venv
    mkdir -p "$ULTRA_ROOT/web"
    python3 -m venv "$ULTRA_ROOT/web/venv"
    source "$ULTRA_ROOT/web/venv/bin/activate"
    pip install flask psutil
    mkdir -p "$ULTRA_ROOT/web/backend" "$ULTRA_ROOT/web/frontend"
    cp -r "$ULTRA_ROOT/modules/web/backend/"* "$ULTRA_ROOT/web/backend/"
    cp -r "$ULTRA_ROOT/modules/web/frontend/"* "$ULTRA_ROOT/web/frontend/"
    bash "$ULTRA_ROOT/modules/web/service.sh"
    touch "$ULTRA_ROOT/modules/web/ultra.log"
    chmod 600 "$ULTRA_ROOT/modules/web/ultra.log"
}

# ----------------------------
# PENTEST / KALI
# ----------------------------
pentest_install() {
    log "[PENTEST] Instalace Pentest modulu"
    install_kali_chroot
    install_pentest_tools
    install_wordlists
}

install_kali_chroot() {
    log "[KALI] Instalace Kali rootfs"
    KALI_TAR="$CACHE_DIR/kali-rootfs.tar.xz"
    download "$KALI/pool/main/k/kali-rootfs/kali-rootfs_2024.1_amd64.tar.xz" "$KALI_TAR"
    mkdir -p "$ULTRA_ROOT/kali"
    tar -xf "$KALI_TAR" -C "$ULTRA_ROOT/kali"
}

install_pentest_tools() {
    log "[PENTEST] Instalace základních nástrojů"
    install_pkg nmap hydra sqlmap
}

install_wordlists() {
    log "[PENTEST] Instalace SecLists"
    git clone --depth=1 "$SECLISTS" "$ULTRA_ROOT/wordlists/SecLists"
}

# ----------------------------
# PLUGIN SYSTÉM
# ----------------------------
plugin_install() {
    URL="$1"
    NAME=$(basename "$URL" .git)
    log "[PLUGIN] Instalace $NAME"
    git clone "$URL" "$ULTRA_ROOT/plugins/enabled/$NAME"
    if [ -f "$ULTRA_ROOT/plugins/enabled/$NAME/install.sh" ]; then
        bash "$ULTRA_ROOT/plugins/enabled/$NAME/install.sh"
    fi
}

# ----------------------------
# INSTALL ALL
# ----------------------------
install_all() {
    log "[INSTALL] Plná instalace ULTRA"
    install_core_only
    android_install
    ai_install
    web_install
    pentest_install
    ai_run
    log "[INSTALL] ULTRA platforma připravena"
}

# ----------------------------
# Spuštění
# ----------------------------
install_all
