#!/usr/bin/env bash
set -euo pipefail

### ================================
### ULTRA v18 FINAL INSTALLER
### Root + Rootless + Python + Mongo
### ================================

APP_NAME="ULTRA"
APP_VERSION="18.0-FINAL"
INSTALL_DIR="$HOME/ultra"
ULTRA_HOME="$HOME/.ultra"
LOG_DIR="$INSTALL_DIR/logs"
LOG_FILE="$LOG_DIR/install_$(date +%F_%H-%M-%S).log"

MONGO_LOCAL_DIR="$ULTRA_HOME/mongodb"
MONGO_DATA_DIR="$ULTRA_HOME/mongo-data"
MONGO_CONF="$ULTRA_HOME/mongod.conf"
MONGO_PORT=27017

PYTHON_MIN="3.10"

### ---------- LOGGING ----------
mkdir -p "$LOG_DIR"
log() {
  echo "[$(date '+%F %T')] $1" | tee -a "$LOG_FILE"
}

error_exit() {
  log "❌ ERROR: $1"
  exit 1
}

### ---------- CHECK ROOT ----------
IS_ROOT=false
if [[ $EUID -eq 0 ]]; then
  IS_ROOT=true
fi

### ---------- REQUIREMENTS ----------
command -v bash >/dev/null || error_exit "bash není dostupný"
command -v curl >/dev/null || error_exit "curl není dostupný"
command -v tar  >/dev/null || error_exit "tar není dostupný"

### ---------- PYTHON ----------
log "[PYTHON] Kontrola Pythonu…"
if ! command -v python3 >/dev/null; then
  error_exit "Python3 není nainstalován"
fi

PY_VER=$(python3 -c 'import sys; print(".".join(map(str, sys.version_info[:2])))')
log "✅ Python $PY_VER nalezen"

### ---------- PIP ----------
if ! command -v pip3 >/dev/null; then
  error_exit "pip3 není nainstalován"
fi

### ---------- VENV ----------
log "[PYTHON] Inicializace virtuálního prostředí"
mkdir -p "$ULTRA_HOME"
python3 -m venv "$ULTRA_HOME/venv"
source "$ULTRA_HOME/venv/bin/activate"
pip install --upgrade pip setuptools wheel

### ---------- PYTHON DEPENDENCIES ----------
log "[PYTHON] Instalace Python balíčků"
pip install flask fastapi uvicorn pymongo rich requests

### ---------- MONGODB ----------
log "[MONGODB] Kontrola MongoDB"

if command -v mongod >/dev/null; then
  log "✅ MongoDB je dostupná systémově"
else
  log "[MONGODB] MongoDB nenalezena – spouštím ROOTLESS instalaci"

  mkdir -p "$MONGO_LOCAL_DIR" "$MONGO_DATA_DIR"

  ARCH=$(uname -m)
  case "$ARCH" in
    x86_64) MONGO_ARCH="x86_64" ;;
    aarch64) MONGO_ARCH="arm64" ;;
    *) error_exit "Nepodporovaná architektura: $ARCH" ;;
  esac

  MONGO_TGZ="mongodb-linux-$MONGO_ARCH-ubuntu2204-7.0.4.tgz"

  log "[MONGODB] Stahuji MongoDB $MONGO_TGZ"
  curl -fsSL "https://fastdl.mongodb.org/linux/$MONGO_TGZ" | tar xz -C "$ULTRA_HOME"

  mv "$ULTRA_HOME"/mongodb-linux-* "$MONGO_LOCAL_DIR"

  cat > "$MONGO_CONF" <<EOF
storage:
  dbPath: $MONGO_DATA_DIR
net:
  bindIp: 127.0.0.1
  port: $MONGO_PORT
processManagement:
  fork: true
systemLog:
  destination: file
  path: $ULTRA_HOME/mongod.log
EOF

  log "[MONGODB] Spouštím rootless MongoDB"
  "$MONGO_LOCAL_DIR/bin/mongod" --config "$MONGO_CONF"
fi

### ---------- VERIFY MONGO ----------
sleep 2
if ! nc -z 127.0.0.1 $MONGO_PORT; then
  error_exit "MongoDB neběží"
fi
log "✅ MongoDB běží na portu $MONGO_PORT"

### ---------- ULTRA CORE ----------
log "[ULTRA] Inicializace adresářů"
mkdir -p "$INSTALL_DIR"/{core,modules,web,plugins,registry,gui}

### ---------- ENV ----------
cat > "$ULTRA_HOME/.env" <<EOF
ULTRA_HOME=$ULTRA_HOME
ULTRA_INSTALL=$INSTALL_DIR
MONGO_URI=mongodb://127.0.0.1:$MONGO_PORT
PYTHON_ENV=$ULTRA_HOME/venv
EOF

### ---------- FINISH ----------
log "====================================="
log "✅ ULTRA v18 FINAL byl úspěšně nainstalován"
log "📁 Instalace: $INSTALL_DIR"
log "🐍 Python VENV: $ULTRA_HOME/venv"
log "🗄 MongoDB: mongodb://127.0.0.1:$MONGO_PORT"
log "📄 Log: $LOG_FILE"
log "====================================="

echo
echo "➡ Aktivace prostředí:"
echo "   source $ULTRA_HOME/venv/bin/activate"
echo
echo "➡ Spuštění ULTRA:"
echo "   python core/main.py"
echo
