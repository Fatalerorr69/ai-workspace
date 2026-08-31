#!/bin/bash
# Soubor: hybrid_cloud.sh
# Popis: Kombinace Streamingu a Multihostingu (A + B)
# Spuštění: sudo ./hybrid_cloud.sh

export INSTALL_ROOT="$(dirname "$(readlink -f "$0")")"
source "$INSTALL_ROOT/lib/config.sh"
source "$INSTALL_ROOT/lib/functions.sh"

clear
echo -e "${CYAN}╔══════════════════════════════════════════════╗${NC}"
echo -e "${CYAN}║    GAMEHUB: HYBRID CLOUD & MULTIHOSTING      ║${NC}"
echo -e "${CYAN}╚══════════════════════════════════════════════╝${NC}"

# 40. Pterodactyl Wings (Jádro pro hostování her)
section_start "Instalace Pterodactyl Wings (Docker Node)"
source "$INSTALL_ROOT/modules/40_wings.sh"
install_wings
section_end "Wings uzel je připraven"

# 41. Virtual Display & GPU Acceleration (Pro streaming)
section_start "GPU Passthrough & Virtual Display"
source "$INSTALL_ROOT/modules/41_streaming_pro.sh"
setup_virtual_display
optimize_gpu_drivers
section_end "Grafika optimalizována pro streaming"

# 42. Herní Knihovna & Steam integration
section_start "Integrace herní knihovny"
source "$INSTALL_ROOT/modules/42_library.sh"
setup_shared_library
section_end "Knihovna připravena"

print_success "Hybridní systém A+B byl úspěšně nakonfigurován!"
