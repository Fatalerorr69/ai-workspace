#!/bin/bash
load_module() {
  local MODULE=$1
  echo "[MODULE] Spouštím modul $MODULE..."
  MODULE_FILE="$ULTRA_ROOT/modules/$MODULE/${MODULE}_install.sh"
  if [ -f "$MODULE_FILE" ]; then
    bash "$MODULE_FILE"
  else
    echo "[MODULE] Placeholder pro $MODULE"
    mkdir -p "$ULTRA_ROOT/modules/$MODULE"
    touch "$ULTRA_ROOT/modules/$MODULE/${MODULE}_install.sh"
  fi
}
