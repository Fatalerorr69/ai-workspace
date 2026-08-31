#!/bin/bash
# Správa pluginů TwisterOS SuperManager

PLUGIN_DIR="/opt/twisteros_supermanager/plugins"

function list_plugins() {
    echo "Dostupné pluginy:"
    ls "$PLUGIN_DIR"
}

function run_plugin() {
    echo "Zadej název pluginu ke spuštění:"
    read plugin
    if [ -x "$PLUGIN_DIR/$plugin" ]; then
        bash "$PLUGIN_DIR/$plugin"
    else
        echo "Plugin '$plugin' neexistuje nebo není spustitelný."
    fi
    read -p "Stiskni Enter pro návrat do menu..."
}

while true; do
    echo "=== Plugin Manager ==="
    echo "1) Vypsat pluginy"
    echo "2) Spustit plugin"
    echo "3) Návrat"
    read -p "Volba: " choice
    case $choice in
        1) list_plugins ;;
        2) run_plugin ;;
        3) break ;;
        *) echo "Neplatná volba." ;;
    esac
done
