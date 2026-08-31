#!/bin/bash
set -e

BASE_DIR="/opt/platform"
CONFIG="$BASE_DIR/config.json"
LOG="/var/log/platform-install.log"

mkdir -p /var/log
touch "$LOG"

exec > >(tee -a "$LOG") 2>&1

source "$BASE_DIR/lib/logger.sh"
source "$BASE_DIR/lib/ui.sh"
source "$BASE_DIR/lib/system.sh"
source "$BASE_DIR/lib/modules.sh"
source "$BASE_DIR/lib/backup.sh"

check_root
check_dependencies
load_config

show_banner
main_menu
