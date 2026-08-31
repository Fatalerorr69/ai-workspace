#!/bin/bash

LOGFILE="/var/log/platform-install.log"

log_info() {
  echo "[INFO] $(date '+%F %T') - $1"
}

log_warn() {
  echo "[WARN] $(date '+%F %T') - $1"
}

log_error() {
  echo "[ERROR] $(date '+%F %T') - $1"
}

log_ok() {
  echo "[OK] $(date '+%F %T') - $1"
}
