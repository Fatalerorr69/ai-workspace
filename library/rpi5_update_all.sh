#!/bin/bash
# Automatický updater repozitáře a pluginů

cd /opt/twisteros_supermanager
git pull origin main
echo "Repozitář aktualizován."

# Aktualizace skriptů a pluginů
bash scripts/setup_emulators.sh

echo "Všechny aktualizace dokončeny."
