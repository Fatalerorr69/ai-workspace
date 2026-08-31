#!/bin/bash
source "$ULTRA_ROOT/core/env.sh"
source "$ULTRA_ROOT/core/logger.sh"

log "[WEB] Instalace Web GUI + Marketplace Backend"

install_pkg() {
  for pkg in "$@"; do
    if ! dpkg -s "$pkg" &>/dev/null; then
      log "[WEB] Instalace $pkg"
      sudo apt-get install -y "$pkg"
    fi
  done
}

install_pkg python3 python3-venv python3-pip git curl jq

mkdir -p "$ULTRA_ROOT/web/venv"
python3 -m venv "$ULTRA_ROOT/web/venv"
source "$ULTRA_ROOT/web/venv/bin/activate"

pip install flask flask_cors requests psutil jinja2

ok "[WEB] Web GUI připraveno"
