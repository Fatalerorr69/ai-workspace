#!/bin/bash
# Soubor: cleanup_and_docs.sh
# Popis: Odstranění instalačních zbytků a generování dokumentace
# Spuštění: sudo ./cleanup_and_docs.sh

export INSTALL_ROOT="$(dirname "$(readlink -f "$0")")"
source "$INSTALL_ROOT/lib/config.sh"
source "$INSTALL_ROOT/lib/functions.sh"

clear
print_banner
info "Spouštím Fázi 8: Čištění systému a Dokumentace"

# 80. Odstranění nepotřebných souborů
section_start "Systémová hygiena"
source "$INSTALL_ROOT/modules/80_cleanup.sh"
remove_temp_files
clean_package_cache
section_end "Systém je čistý"

# 81. Generování lokální dokumentace
section_start "Generování dokumentace"
source "$INSTALL_ROOT/modules/81_docs.sh"
generate_web_docs
create_admin_manual
section_end "Dokumentace připravena v /var/www/gamehub/docs"

print_success "Vše hotovo! Tvůj GameHub je v perfektní kondici."
