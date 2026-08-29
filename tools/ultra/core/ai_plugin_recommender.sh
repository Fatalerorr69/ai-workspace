#!/bin/bash
source "$(dirname "$0")/env.sh"

echo "[AI_PLUGIN] Kontrola doporučených pluginů..."
RECOMMENDED=("android-tools" "pentest-pack" "web-optimizer")

for plugin in "${RECOMMENDED[@]}"; do
  if [ ! -d "$PLUGINS_DIR/enabled/$plugin" ]; then
    echo "[AI_PLUGIN] Doporučeno nainstalovat plugin: $plugin"
    git clone "https://github.com/Fatalerorr69/$plugin.git" "$PLUGINS_DIR/enabled/$plugin"
    if [ -f "$PLUGINS_DIR/enabled/$plugin/install.sh" ]; then
      bash "$PLUGINS_DIR/enabled/$plugin/install.sh"
    fi
  fi
done
