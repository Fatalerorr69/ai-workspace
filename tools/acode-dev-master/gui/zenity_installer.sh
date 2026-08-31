#!/usr/bin/env bash
set -euo pipefail
WORKDIR="${HOME}/.acode_dev_master"
while true; do
  CHOICE=$(zenity --list --title="Acode Installer" --column="Volba" --column="Popis" \
    "install_core" "Instalace základních modulů" \
    "install_ai" "AI moduly" \
    "install_android" "Android / Acode" \
    "install_wsl" "WSL / VM" \
    "install_lcd" "LCD / RPi5" \
    "manage_plugins" "Správa pluginů" \
    "create_zip" "Vytvořit ZIP" \
    "exit" "Ukončit" --height=400 --width=700)
  [ -z "$CHOICE" ] && exit 0
  case "$CHOICE" in
    install_core) bash "$WORKDIR/master_install_core.sh" ;;
    install_ai) bash "$WORKDIR/master_install_ai.sh" ;;
    install_android) bash "$WORKDIR/master_install_android.sh" ;;
    install_wsl) bash "$WORKDIR/master_install_wsl.sh" ;;
    install_lcd) bash "$WORKDIR/master_install_lcd.sh" ;;
    manage_plugins) bash "$WORKDIR/gui/plugin_manager.sh" ;;
    create_zip) bash "$WORKDIR/create_zip.sh" ;;
    exit) exit 0 ;;
  esac
done
