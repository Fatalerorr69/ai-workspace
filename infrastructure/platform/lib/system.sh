#!/bin/bash

function check_root() {
  if [ "$EUID" -ne 0 ]; then
    echo "Musíš spustit jako root (sudo)"
    exit 1
  fi
}

function check_dependencies() {
  apt update
  apt install -y jq curl git
}

function load_config() {
  HOSTNAME_CFG=$(jq -r '.hostname' "$CONFIG")
  TIMEZONE_CFG=$(jq -r '.timezone' "$CONFIG")
  USER_CFG=$(jq -r '.user' "$CONFIG")
}

function base_system() {
  log_info "Nastavuji hostname a timezone"
  hostnamectl set-hostname "$HOSTNAME_CFG"
  timedatectl set-timezone "$TIMEZONE_CFG"

  log_info "Provádím update systému"
  apt update && apt full-upgrade -y

  log_info "Instaluji základní balíky"
  apt install -y \
    curl wget git jq \
    python3 python3-pip \
    ufw fail2ban \
    htop net-tools \
    ca-certificates \
    gnupg lsb-release

  log_info "Vytvářím základní adresáře"
  mkdir -p /srv/{data,logs,backups,containers}

  log_ok "Základní systém připraven"
}
