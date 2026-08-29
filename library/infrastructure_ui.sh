#!/bin/bash

function show_banner() {
clear
echo "======================================"
echo "   RPi Platform Installer v7.0-STABLE"
echo "======================================"
echo ""
}

function main_menu() {
PS3="Vyber akci: "
options=(
"Plná automatická instalace"
"Vlastní výběr modulů"
"Pouze základní systém"
"Ukončit"
)

select opt in "${options[@]}"
do
  case $REPLY in
    1) auto_install ;;
    2) custom_install ;;
    3) base_only ;;
    4) exit 0 ;;
    *) echo "Neplatná volba" ;;
  esac
done
}

function auto_install() {
  log_info "Spouštím plnou automatickou instalaci"
  base_system
  run_modules
  initial_backup
  log_ok "Instalace dokončena – reboot"
  reboot
}

function custom_install() {
  log_info "Interaktivní výběr modulů"
  for mod in docker pentest monitoring nas backup security k3s android; do
    read -p "Instalovat modul $mod? (y/n): " choice
    if [[ "$choice" == "y" ]]; then
      bash "/opt/platform/modules/$mod.sh"
    fi
  done
  initial_backup
  reboot
}

function base_only() {
  log_info "Instaluji pouze základní systém"
  base_system
  reboot
}
