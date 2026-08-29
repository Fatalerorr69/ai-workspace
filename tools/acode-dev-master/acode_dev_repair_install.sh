#!/usr/bin/env bash
set -e

BASE="$HOME/acode-dev-tools"
BIN="$HOME/.local/bin"
LOG="$HOME/.cache/acode-dev/repair.log"

mkdir -p "$BIN" "$(dirname "$LOG")"

log() { echo "[REPAIR] $1" | tee -a "$LOG"; }

#################################
# DETEKCE PROSTŘEDÍ
#################################
if command -v pkg >/dev/null; then
  ENV=termux
elif command -v apt >/dev/null; then
  ENV=apt
else
  ENV=minimal
fi

log "Prostředí: $ENV"

#################################
# INSTALACE CURL (BOOTSTRAP)
#################################
if ! command -v curl >/dev/null; then
  log "Instaluji curl (bootstrap)"
  if [ "$ENV" = termux ]; then
    pkg install -y curl
  elif [ "$ENV" = apt ]; then
    apt update && apt install -y curl
  else
    wget https://busybox.net/downloads/binaries/1.36.1-i686-linux-musl/busybox \
      -O "$BIN/busybox" || true
    chmod +x "$BIN/busybox"
    ln -sf "$BIN/busybox" "$BIN/curl"
  fi
fi

#################################
# GIT
#################################
if ! command -v git >/dev/null; then
  log "Instaluji git"
  if [ "$ENV" = termux ]; then
    pkg install -y git
  elif [ "$ENV" = apt ]; then
    apt install -y git
  else
    log "⚠️ git nelze instalovat – minimální prostředí"
  fi
fi

#################################
# DIALOG
#################################
if ! command -v dialog >/dev/null; then
  log "Instaluji dialog"
  if [ "$ENV" = termux ]; then
    pkg install -y dialog
  elif [ "$ENV" = apt ]; then
    apt install -y dialog
  else
    log "⚠️ dialog nedostupný – TUI poběží v fallback režimu"
  fi
fi

#################################
# NODEJS + NPM
#################################
if ! command -v node >/dev/null; then
  log "Instaluji Node.js (binární)"
  curl -fsSL https://nodejs.org/dist/v20.11.1/node-v20.11.1-linux-x64.tar.xz \
    | tar -xJ -C "$BIN" --strip-components=1 || true
fi

#################################
# INOTIFY
#################################
if ! command -v inotifywait >/dev/null; then
  log "Instaluji inotify-tools"
  if [ "$ENV" = termux ]; then
    pkg install -y inotify-tools
  elif [ "$ENV" = apt ]; then
    apt install -y inotify-tools
  else
    log "⚠️ watch mód nebude dostupný"
  fi
fi

#################################
# OPRAVA PRÁV
#################################
chmod +x "$BASE"/**/*.sh 2>/dev/null || true

#################################
# DIAGNOSTIKA
#################################
log "=== KONTROLA ==="
for b in git curl dialog node npm; do
  command -v $b >/dev/null && log "✓ $b OK" || log "✗ $b CHYBÍ"
done

log "Oprava dokončena"
log "Znovu spusť: ai"