#!/bin/bash
# Soubor: lib/config.sh

# Verze
GAMEHUB_VERSION="3.1.0"

# Cesty
INSTALL_DIR="/opt/gamehub"
CONFIG_DIR="/etc/gamehub"
DATA_DIR="/opt/gamehub/data"
BACKUP_DIR="/backup/gamehub"

# Uživatel
GH_USER="gamehub"

# Porty
PORT_API=3001
PORT_WEB=80
PORT_WS=8081
PORT_STREAM=47990

# Databáze (Hesla se vygenerují, pokud neexistují)
DB_NAME="gamehub_db"
DB_USER="gamehub_admin"
DB_PASS=$(openssl rand -base64 24)
JWT_SECRET=$(openssl rand -base64 32)
