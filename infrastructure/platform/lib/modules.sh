#!/bin/bash

function run_modules() {
  log_info "Spouštím instalaci modulů dle config.json"

  for mod in docker pentest monitoring nas backup security k3s android; do
    enabled=$(jq -r ".modules.$mod" "$CONFIG")
    if [ "$enabled" == "true" ]; then
      log_info "Instaluji modul: $mod"
      bash "/opt/platform/modules/$mod.sh"
    else
      log_warn "Modul $mod přeskočen"
    fi
  done

  log_ok "Všechny moduly zpracovány"
}
