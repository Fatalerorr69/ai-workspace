#!/data/data/com.termux/files/usr/bin/bash
# ==================================================
# SUPER NÁSTROJ v5.0 - Android/Termux Edition
# FatalErorr69 - Mobile Professional Edition
# ==================================================

VERSION="5.0"
PLATFORM="Android/Termux"

# Barvy pro Termux
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
MAGENTA='\033[0;35m'
CYAN='\033[0;36m'
WHITE='\033[1;37m'
NC='\033[0m' # No Color

# ==================================================
# INICIALIZACE
# ==================================================
clear
echo -e "${CYAN}"
echo "=================================================="
echo "   📱 SUPER NÁSTROJ v${VERSION} - ANDROID EDITION"
echo "=================================================="
echo -e "${NC}"

# Vytvoření složek
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
LOG_DIR="$HOME/SuperNastroj_Logs"
TOOLS_DIR="$HOME/SuperNastroj_Tools"
BACKUP_DIR="$HOME/SuperNastroj_Backups"
CONFIG_DIR="$HOME/.config/supernastroj"

mkdir -p "$LOG_DIR" "$TOOLS_DIR" "$BACKUP_DIR" "$CONFIG_DIR"

# Log soubory
SYSTEM_LOG="$LOG_DIR/system.log"
ERROR_LOG="$LOG_DIR/errors.log"
NETWORK_LOG="$LOG_DIR/network.log"

# ==================================================
# POMOCNÉ FUNKCE
# ==================================================

log_info() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] INFO: $1" | tee -a "$SYSTEM_LOG"
}

log_error() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] ERROR: $1" | tee -a "$ERROR_LOG"
}

log_success() {
    echo -e "${GREEN}✅ $1${NC}"
    log_info "SUCCESS: $1"
}

log_warning() {
    echo -e "${YELLOW}⚠️  $1${NC}"
    log_info "WARNING: $1"
}

check_command() {
    if command -v "$1" &> /dev/null; then
        return 0
    else
        return 1
    fi
}

install_package() {
    local pkg="$1"
    echo -e "${YELLOW}📥 Instaluji $pkg...${NC}"
    pkg install -y "$pkg" 2>&1 | tee -a "$SYSTEM_LOG"
    if [ $? -eq 0 ]; then
        log_success "$pkg úspěšně nainstalován"
        return 0
    else
        log_error "Instalace $pkg selhala"
        return 1
    fi
}

check_dependencies() {
    local missing=()
    local required=("python" "curl" "wget" "git" "nmap" "net-tools")
    
    echo -e "${CYAN}🔍 Kontroluji závislosti...${NC}"
    
    for pkg in "${required[@]}"; do
        if ! check_command "$pkg"; then
            missing+=("$pkg")
        fi
    done
    
    if [ ${#missing[@]} -gt 0 ]; then
        echo -e "${YELLOW}📦 Chybějící balíčky: ${missing[*]}${NC}"
        read -p "Chcete je nainstalovat? [y/N]: " install_choice
        if [[ "$install_choice" =~ ^[Yy]$ ]]; then
            pkg update
            for pkg in "${missing[@]}"; do
                install_package "$pkg"
            done
        fi
    else
        log_success "Všechny závislosti jsou nainstalovány"
    fi
}

pause_screen() {
    echo ""
    read -p "Stiskněte Enter pro pokračování..."
}

get_device_info() {
    if check_command getprop; then
        MODEL=$(getprop ro.product.model 2>/dev/null || echo "Neznámý")
        ANDROID_VERSION=$(getprop ro.build.version.release 2>/dev/null || echo "Neznámá")
        DEVICE=$(getprop ro.product.device 2>/dev/null || echo "Neznámé")
        API_LEVEL=$(getprop ro.build.version.sdk 2>/dev/null || echo "Neznámý")
    fi
}

# ==================================================
# HLAVNÍ MENU
# ==================================================
show_main_menu() {
    clear
    get_device_info
    echo -e "${CYAN}"
    echo "=================================================="
    echo "   📱 SUPER NÁSTROJ v${VERSION} - ANDROID EDITION"
    echo "=================================================="
    echo -e "${NC}"
    echo -e "${WHITE}Zařízení: ${MODEL:-Neznámý}${NC}"
    echo -e "${WHITE}Android: ${ANDROID_VERSION:-Neznámá}${NC}"
    echo ""
    echo -e "${GREEN}1)${NC}  🔍 Diagnostika zařízení"
    echo -e "${GREEN}2)${NC}  🌐 Síťové nástroje"
    echo -e "${GREEN}3)${NC}  🛡️  Bezpečnostní analýza"
    echo -e "${GREEN}4)${NC}  📱 Informace o systému"
    echo -e "${GREEN}5)${NC}  🔧 Utility a nástroje"
    echo -e "${GREEN}6)${NC}  📡 WiFi analýza"
    echo -e "${GREEN}7)${NC}  💾 Správa souborů a záloha"
    echo -e "${GREEN}8)${NC}  🚀 Výkon a baterie"
    echo -e "${GREEN}9)${NC}  📦 Správa balíčků Termux"
    echo -e "${GREEN}10)${NC} ⚙️  Nastavení a konfigurace"
    echo -e "${GREEN}11)${NC} 📊 Generovat report"
    echo -e "${GREEN}12)${NC} 🔄 Kontrola aktualizací"
    echo -e "${RED}13)${NC} ❌ Konec"
    echo ""
    read -p "Vyberte možnost [1-13]: " choice
}

# ==================================================
# 1. DIAGNOSTIKA ZAŘÍZENÍ
# ==================================================
android_diagnostics() {
    clear
    echo -e "${CYAN}"
    echo "=================================================="
    echo "          🔍 DIAGNOSTIKA ANDROID ZAŘÍZENÍ"
    echo "=================================================="
    echo -e "${NC}"
    
    # Základní informace
    echo -e "${YELLOW}📱 ZÁKLADNÍ INFORMACE:${NC}"
    if check_command getprop; then
        echo "Model: $(getprop ro.product.model 2>/dev/null || echo 'Neznámý')"
        echo "Výrobce: $(getprop ro.product.manufacturer 2>/dev/null || echo 'Neznámý')"
        echo "Verze Android: $(getprop ro.build.version.release 2>/dev/null || echo 'Neznámá')"
        echo "API Level: $(getprop ro.build.version.sdk 2>/dev/null || echo 'Neznámý')"
        echo "Zařízení: $(getprop ro.product.device 2>/dev/null || echo 'Neznámé')"
        echo "Build: $(getprop ro.build.id 2>/dev/null || echo 'Neznámý')"
    fi
    echo ""
    
    # Úložiště
    echo -e "${YELLOW}💾 ÚLOŽIŠTĚ:${NC}"
    df -h 2>/dev/null | grep -E "/(data|storage|sdcard)" || df -h | head -5
    echo ""
    
    # Paměť
    echo -e "${YELLOW}🧠 PAMĚŤ (RAM):${NC}"
    if [ -f "/proc/meminfo" ]; then
        total_mem=$(grep MemTotal /proc/meminfo | awk '{print $2}')
        free_mem=$(grep MemAvailable /proc/meminfo | awk '{print $2}')
        used_mem=$((total_mem - free_mem))
        echo "Celková: $((total_mem / 1024)) MB"
        echo "Použitá: $((used_mem / 1024)) MB"
        echo "Volná: $((free_mem / 1024)) MB"
        echo "Využití: $(awk "BEGIN {printf \"%.1f\", ($used_mem/$total_mem)*100}")%"
    fi
    echo ""
    
    # CPU
    echo -e "${YELLOW}⚡ PROCESOR:${NC}"
    if [ -f "/proc/cpuinfo" ]; then
        cores=$(grep -c ^processor /proc/cpuinfo)
        echo "Počet jader: $cores"
        cpu_model=$(grep "model name" /proc/cpuinfo | head -1 | cut -d: -f2 | xargs)
        [ -n "$cpu_model" ] && echo "Model: $cpu_model"
        
        # CPU frekvence
        if [ -d "/sys/devices/system/cpu/cpu0/cpufreq" ]; then
            cur_freq=$(cat /sys/devices/system/cpu/cpu0/cpufreq/scaling_cur_freq 2>/dev/null)
            max_freq=$(cat /sys/devices/system/cpu/cpu0/cpufreq/cpuinfo_max_freq 2>/dev/null)
            [ -n "$cur_freq" ] && echo "Aktuální frekvence: $((cur_freq / 1000)) MHz"
            [ -n "$max_freq" ] && echo "Maximální frekvence: $((max_freq / 1000)) MHz"
        fi
    fi
    echo ""
    
    # Baterie
    echo -e "${YELLOW}🔋 BATERIE:${NC}"
    if [ -d "/sys/class/power_supply/battery" ]; then
        battery_path="/sys/class/power_supply/battery"
        
        [ -f "$battery_path/capacity" ] && echo "Kapacita: $(cat $battery_path/capacity)%"
        [ -f "$battery_path/status" ] && echo "Stav: $(cat $battery_path/status)"
        [ -f "$battery_path/health" ] && echo "Zdraví: $(cat $battery_path/health)"
        
        if [ -f "$battery_path/current_now" ]; then
            current=$(cat $battery_path/current_now)
            echo "Proud: $((current / 1000)) mA"
        fi
        
        if [ -f "$battery_path/voltage_now" ]; then
            voltage=$(cat $battery_path/voltage_now)
            echo "Napětí: $((voltage / 1000)) mV"
        fi
        
        if [ -f "$battery_path/temp" ]; then
            temp=$(cat $battery_path/temp)
            echo "Teplota baterie: $((temp / 10))°C"
        fi
    else
        check_command termux-battery-status && termux-battery-status
    fi
    echo ""
    
    # Teplota CPU
    echo -e "${YELLOW}🌡️  TEPLOTA CPU:${NC}"
    if [ -f "/sys/class/thermal/thermal_zone0/temp" ]; then
        temp=$(cat /sys/class/thermal/thermal_zone0/temp 2>/dev/null)
        echo "CPU: $((temp / 1000))°C"
    fi
    
    # Uptime
    echo ""
    echo -e "${YELLOW}⏱️  UPTIME:${NC}"
    uptime -p 2>/dev/null || uptime
    
    log_info "Android diagnostics completed"
    pause_screen
}

# ==================================================
# 2. SÍŤOVÉ NÁSTROJE
# ==================================================
network_tools_menu() {
    while true; do
        clear
        echo -e "${CYAN}"
        echo "=================================================="
        echo "          🌐 SÍŤOVÉ NÁSTROJE - ANDROID"
        echo "=================================================="
        echo -e "${NC}"
        echo ""
        echo "1) Síťová diagnostika"
        echo "2) Skenování portů"
        echo "3) WiFi analýza"
        echo "4) Test rychlosti"
        echo "5) DNS testy"
        echo "6) Síťové informace"
        echo "7) Ping test"
        echo "8) Traceroute"
        echo "9) Otevřená spojení"
        echo "10) Zpět do hlavního menu"
        echo ""
        read -p "Vyberte možnost [1-10]: " net_choice
        
        case $net_choice in
            1) network_diagnostics ;;
            2) port_scanning ;;
            3) wifi_analysis ;;
            4) speed_test ;;
            5) dns_tests ;;
            6) network_info ;;
            7) compress_decompress ;;
            8) return ;;
            *) echo -e "${RED}❌ Neplatná volba!${NC}"; sleep 1 ;;
        esac
    done
}

show_current_directory() {
    clear
    echo -e "${CYAN}📁 AKTUÁLNÍ ADRESÁŘ${NC}"
    echo ""
    echo -e "${YELLOW}📍 Cesta:${NC}"
    pwd
    echo ""
    echo -e "${YELLOW}📊 OBSAH:${NC}"
    ls -lah
    echo ""
    echo -e "${YELLOW}💾 VOLNÉ MÍSTO:${NC}"
    df -h .
    pause_screen
}

browse_files() {
    clear
    echo -e "${CYAN}🗂️  PROCHÁZENÍ SOUBORŮ${NC}"
    echo ""
    read -p "Zadejte cestu (Enter pro aktuální adresář): " path
    [ -z "$path" ] && path="."
    
    if [ -d "$path" ]; then
        echo ""
        ls -lah "$path"
    else
        echo -e "${RED}❌ Adresář neexistuje${NC}"
    fi
    pause_screen
}

create_backup() {
    clear
    echo -e "${CYAN}💾 VYTVOŘENÍ ZÁLOHY${NC}"
    echo ""
    
    read -p "Cesta ke zálohování (Enter pro $HOME): " backup_source
    [ -z "$backup_source" ] && backup_source="$HOME"
    
    if [ ! -d "$backup_source" ]; then
        echo -e "${RED}❌ Zdrojový adresář neexistuje${NC}"
        pause_screen
        return
    fi
    
    backup_name="backup_$(date +%Y%m%d_%H%M%S).tar.gz"
    backup_path="$BACKUP_DIR/$backup_name"
    
    echo ""
    echo -e "${YELLOW}🔄 Vytvářím zálohu...${NC}"
    echo "Zdroj: $backup_source"
    echo "Cíl: $backup_path"
    echo ""
    
    tar -czf "$backup_path" -C "$(dirname "$backup_source")" "$(basename "$backup_source")" 2>&1
    
    if [ $? -eq 0 ]; then
        backup_size=$(du -h "$backup_path" | cut -f1)
        log_success "Záloha vytvořena: $backup_name ($backup_size)"
        echo ""
        echo -e "${GREEN}✅ Záloha uložena v: $backup_path${NC}"
    else
        log_error "Vytvoření zálohy selhalo"
        echo -e "${RED}❌ Chyba při vytváření zálohy${NC}"
    fi
    
    pause_screen
}

restore_backup() {
    clear
    echo -e "${CYAN}♻️  OBNOVA ZE ZÁLOHY${NC}"
    echo ""
    
    if [ ! -d "$BACKUP_DIR" ] || [ -z "$(ls -A "$BACKUP_DIR")" ]; then
        echo -e "${RED}❌ Žádné zálohy nenalezeny${NC}"
        pause_screen
        return
    fi
    
    echo -e "${YELLOW}📋 Dostupné zálohy:${NC}"
    ls -lh "$BACKUP_DIR"
    echo ""
    
    read -p "Název zálohy k obnově: " backup_file
    backup_full_path="$BACKUP_DIR/$backup_file"
    
    if [ ! -f "$backup_full_path" ]; then
        echo -e "${RED}❌ Záloha nenalezena${NC}"
        pause_screen
        return
    fi
    
    read -p "Cílový adresář pro obnovu (Enter pro $HOME/restored): " restore_path
    [ -z "$restore_path" ] && restore_path="$HOME/restored"
    
    mkdir -p "$restore_path"
    
    echo ""
    echo -e "${YELLOW}🔄 Obnovuji zálohu...${NC}"
    tar -xzf "$backup_full_path" -C "$restore_path" 2>&1
    
    if [ $? -eq 0 ]; then
        log_success "Záloha úspěšně obnovena"
        echo -e "${GREEN}✅ Záloha obnovena do: $restore_path${NC}"
    else
        log_error "Obnova zálohy selhala"
        echo -e "${RED}❌ Chyba při obnově zálohy${NC}"
    fi
    
    pause_screen
}

analyze_disk_usage() {
    clear
    echo -e "${CYAN}📊 ANALÝZA VYUŽITÍ DISKU${NC}"
    echo ""
    
    echo -e "${YELLOW}💾 CELKOVÉ VYUŽITÍ:${NC}"
    df -h
    echo ""
    
    read -p "Analyzovat konkrétní adresář? (Enter pro $HOME): " analyze_path
    [ -z "$analyze_path" ] && analyze_path="$HOME"
    
    echo ""
    echo -e "${YELLOW}📂 TOP 10 největších adresářů v $analyze_path:${NC}"
    du -h "$analyze_path" 2>/dev/null | sort -rh | head -10
    
    pause_screen
}

find_files() {
    clear
    echo -e "${CYAN}🔍 HLEDÁNÍ SOUBORŮ${NC}"
    echo ""
    
    read -p "Název souboru k hledání: " search_term
    if [ -z "$search_term" ]; then
        echo -e "${RED}❌ Zadejte název souboru${NC}"
        pause_screen
        return
    fi
    
    read -p "Cesta k prohledání (Enter pro $HOME): " search_path
    [ -z "$search_path" ] && search_path="$HOME"
    
    echo ""
    echo -e "${YELLOW}🔍 Hledám '$search_term' v $search_path...${NC}"
    find "$search_path" -name "*$search_term*" 2>/dev/null
    
    pause_screen
}

compress_decompress() {
    clear
    echo -e "${CYAN}📦 KOMPRESE/DEKOMPRESE${NC}"
    echo ""
    echo "1) Komprimovat soubor/složku (.tar.gz)"
    echo "2) Dekomprimovat archiv"
    echo "3) Zpět"
    echo ""
    read -p "Vyberte možnost: " compress_choice
    
    case $compress_choice in
        1)
            read -p "Cesta k souboru/složce: " source
            if [ ! -e "$source" ]; then
                echo -e "${RED}❌ Soubor neexistuje${NC}"
                pause_screen
                return
            fi
            output_name="$(basename "$source")_$(date +%Y%m%d_%H%M%S).tar.gz"
            tar -czf "$output_name" "$source"
            [ $? -eq 0 ] && log_success "Vytvořen archiv: $output_name"
            ;;
        2)
            read -p "Cesta k archivu: " archive
            if [ ! -f "$archive" ]; then
                echo -e "${RED}❌ Archiv neexistuje${NC}"
                pause_screen
                return
            fi
            read -p "Cílová složka (Enter pro aktuální): " dest
            [ -z "$dest" ] && dest="."
            tar -xzf "$archive" -C "$dest"
            [ $? -eq 0 ] && log_success "Archiv rozbalen"
            ;;
        3) return ;;
    esac
    pause_screen
}

# ==================================================
# 8. VÝKON A BATERIE
# ==================================================
performance_battery() {
    clear
    echo -e "${CYAN}"
    echo "=================================================="
    echo "          🚀 VÝKON A BATERIE"
    echo "=================================================="
    echo -e "${NC}"
    
    # CPU využití
    echo -e "${YELLOW}⚡ VYUŽITÍ CPU:${NC}"
    if check_command top; then
        top -bn1 | grep "CPU" | head -1 || top -n 1 | head -5
    fi
    echo ""
    
    # Paměť
    echo -e "${YELLOW}🧠 PAMĚŤ:${NC}"
    free -h 2>/dev/null || cat /proc/meminfo | grep -E "MemTotal|MemAvailable"
    echo ""
    
    # TOP procesy
    echo -e "${YELLOW}📊 TOP PROCESY (CPU):${NC}"
    ps aux 2>/dev/null | sort -rn -k 3 | head -6 || ps | head -10
    echo ""
    
    # Baterie detailně
    echo -e "${YELLOW}🔋 STAV BATERIE:${NC}"
    if [ -d "/sys/class/power_supply/battery" ]; then
        battery_path="/sys/class/power_supply/battery"
        
        [ -f "$battery_path/capacity" ] && echo "Kapacita: $(cat "$battery_path/capacity")%"
        [ -f "$battery_path/status" ] && echo "Stav nabíjení: $(cat "$battery_path/status")"
        [ -f "$battery_path/health" ] && echo "Zdraví: $(cat "$battery_path/health")"
        
        if [ -f "$battery_path/current_now" ]; then
            current=$(cat "$battery_path/current_now" 2>/dev/null)
            echo "Proud: $((current / 1000)) mA"
        fi
        
        if [ -f "$battery_path/voltage_now" ]; then
            voltage=$(cat "$battery_path/voltage_now" 2>/dev/null)
            echo "Napětí: $((voltage / 1000)) mV"
        fi
        
        if [ -f "$battery_path/temp" ]; then
            temp=$(cat "$battery_path/temp" 2>/dev/null)
            echo "Teplota: $((temp / 10))°C"
        fi
        
        if [ -f "$battery_path/technology" ]; then
            echo "Technologie: $(cat "$battery_path/technology")"
        fi
        
        # Výpočet odhadovaného času
        if [ -f "$battery_path/capacity" ] && [ -f "$battery_path/current_now" ]; then
            capacity=$(cat "$battery_path/capacity")
            current=$(cat "$battery_path/current_now")
            if [ "$current" -gt 0 ]; then
                echo "Odhadovaný čas vybití: ~$((capacity * 60 / (current / 1000))) minut"
            fi
        fi
    else
        if check_command termux-battery-status; then
            termux-battery-status
        else
            echo "ℹ️  Informace o baterii nejsou dostupné"
        fi
    fi
    echo ""
    
    # Teploty
    echo -e "${YELLOW}🌡️  TEPLOTY:${NC}"
    if [ -f "/sys/class/thermal/thermal_zone0/temp" ]; then
        temp=$(cat /sys/class/thermal/thermal_zone0/temp)
        echo "CPU: $((temp / 1000))°C"
    fi
    
    for zone in /sys/class/thermal/thermal_zone*/temp; do
        if [ -f "$zone" ]; then
            zone_name=$(basename $(dirname "$zone"))
            temp=$(cat "$zone")
            echo "$zone_name: $((temp / 1000))°C"
        fi
    done
    echo ""
    
    # Tipy pro úsporu baterie
    echo -e "${YELLOW}💡 TIPY PRO ŠETŘENÍ BATERIE:${NC}"
    echo "1. ✓ Snížit jas displeje"
    echo "2. ✓ Vypnout WiFi/Bluetooth když se nepoužívá"
    echo "3. ✓ Zavřít nepoužívané aplikace"
    echo "4. ✓ Použít tmavý režim"
    echo "5. ✓ Omezit běh na pozadí"
    echo "6. ✓ Zakázat automatické aktualizace"
    
    log_info "Performance and battery status displayed"
    pause_screen
}

# ==================================================
# 9. SPRÁVA BALÍČKŮ TERMUX
# ==================================================
package_management() {
    clear
    echo -e "${CYAN}"
    echo "=================================================="
    echo "          📦 SPRÁVA BALÍČKŮ TERMUX"
    echo "=================================================="
    echo -e "${NC}"
    
    echo -e "${YELLOW}📊 STATISTIKY BALÍČKŮ:${NC}"
    installed_count=$(pkg list-installed 2>/dev/null | wc -l)
    echo "Nainstalováno: $installed_count balíčků"
    echo ""
    
    echo -e "${YELLOW}🔄 DOSTUPNÉ AKTUALIZACE:${NC}"
    pkg list-upgradable 2>/dev/null | head -10
    upgradable_count=$(pkg list-upgradable 2>/dev/null | wc -l)
    [ "$upgradable_count" -gt 0 ] && echo "Dostupných aktualizací: $upgradable_count"
    echo ""
    
    echo -e "${YELLOW}📋 NEDÁVNO NAINSTALOVANÉ:${NC}"
    pkg list-installed 2>/dev/null | head -10
    echo ""
    
    echo -e "${YELLOW}💡 UŽITEČNÉ PŘÍKAZY:${NC}"
    echo "• pkg update          - aktualizovat seznamy"
    echo "• pkg upgrade         - aktualizovat vše"
    echo "• pkg install <pkg>   - instalovat balíček"
    echo "• pkg uninstall <pkg> - odinstalovat"
    echo "• pkg search <term>   - hledat balíček"
    echo "• pkg show <pkg>      - info o balíčku"
    echo "• pkg files <pkg>     - seznam souborů"
    echo "• pkg clean           - vyčistit cache"
    echo ""
    
    echo -e "${YELLOW}📦 DOSTUPNÉ REPOZITÁŘE:${NC}"
    echo "• Main repository (hlavní)"
    echo "• Root repository (root nástroje)"
    echo "• X11 repository (grafické aplikace)"
    echo ""
    echo "💡 Změna repozitářů: termux-change-repo"
    
    log_info "Package management displayed"
    pause_screen
}

# ==================================================
# 10. NASTAVENÍ A KONFIGURACE
# ==================================================
settings_configuration() {
    while true; do
        clear
        echo -e "${CYAN}"
        echo "=================================================="
        echo "          ⚙️  NASTAVENÍ A KONFIGURACE"
        echo "=================================================="
        echo -e "${NC}"
        echo ""
        echo "1) Zobrazit aktuální konfiguraci"
        echo "2) Nastavit úložiště (Storage)"
        echo "3) Změnit repozitář"
        echo "4) Konfigurace SSH"
        echo "5) Termux API setup"
        echo "6) Změnit vzhled (barvy)"
        echo "7) Nastavit font"
        echo "8) Exportovat konfiguraci"
        echo "9) Zpět do hlavního menu"
        echo ""
        read -p "Vyberte možnost [1-9]: " settings_choice
        
        case $settings_choice in
            1) show_configuration ;;
            2) setup_storage ;;
            3) change_repository ;;
            4) configure_ssh ;;
            5) setup_termux_api ;;
            6) change_colors ;;
            7) change_font ;;
            8) export_configuration ;;
            9) return ;;
            *) echo -e "${RED}❌ Neplatná volba!${NC}"; sleep 1 ;;
        esac
    done
}

show_configuration() {
    clear
    echo -e "${CYAN}⚙️  AKTUÁLNÍ KONFIGURACE${NC}"
    echo ""
    
    echo -e "${YELLOW}📱 SYSTÉM:${NC}"
    echo "Verze nástroje: $VERSION"
    echo "Platforma: $PLATFORM"
    echo "Shell: $SHELL"
    echo "HOME: $HOME"
    echo "PREFIX: $PREFIX"
    echo ""
    
    echo -e "${YELLOW}📂 SLOŽKY:${NC}"
    echo "Log dir: $LOG_DIR"
    echo "Tools dir: $TOOLS_DIR"
    echo "Backup dir: $BACKUP_DIR"
    echo "Config dir: $CONFIG_DIR"
    echo ""
    
    echo -e "${YELLOW}🔧 TERMUX:${NC}"
    echo "Termux verze: $(pkg show termux-tools 2>/dev/null | grep Version | cut -d: -f2 | xargs)"
    echo "Úložiště: $([ -r "/sdcard" ] && echo "Povoleno" || echo "Nepovoleno")"
    echo ""
    
    if [ -f "$CONFIG_DIR/config.ini" ]; then
        echo -e "${YELLOW}📄 CONFIG.INI:${NC}"
        cat "$CONFIG_DIR/config.ini"
    fi
    
    pause_screen
}

setup_storage() {
    clear
    echo -e "${CYAN}💾 NASTAVENÍ ÚLOŽIŠTĚ${NC}"
    echo ""
    
    if [ -r "/sdcard" ]; then
        log_success "Přístup k úložišti je již povolen"
    else
        echo -e "${YELLOW}📱 Nastavuji přístup k úložišti...${NC}"
        termux-setup-storage
        echo ""
        echo "💡 Povolte přístup k úložišti v dialogu Android"
        sleep 2
        
        if [ -r "/sdcard" ]; then
            log_success "Přístup k úložišti byl povolen"
        else
            log_warning "Přístup nebyl povolen nebo byl zamítnut"
        fi
    fi
    
    pause_screen
}

change_repository() {
    clear
    echo -e "${CYAN}📦 ZMĚNA REPOZITÁŘE${NC}"
    echo ""
    
    echo -e "${YELLOW}🌍 Dostupné mirrors:${NC}"
    echo "1. Hlavní (official)"
    echo "2. Mirror Grimler"
    echo "3. Mirror Kcubeterm"
    echo "4. Mirror A1batross"
    echo ""
    
    termux-change-repo
    
    pause_screen
}

configure_ssh() {
    clear
    echo -e "${CYAN}🔐 KONFIGURACE SSH${NC}"
    echo ""
    
    if ! check_command sshd; then
        echo -e "${YELLOW}📥 SSH server není nainstalován${NC}"
        read -p "Chcete nainstalovat openssh? [y/N]: " install_ssh
        if [[ "$install_ssh" =~ ^[Yy]$ ]]; then
            install_package openssh
        else
            pause_screen
            return
        fi
    fi
    
    echo -e "${YELLOW}🔧 SSH Konfigurace:${NC}"
    echo "1. Spustit SSH server: sshd"
    echo "2. Zastavit SSH server: pkill sshd"
    echo "3. SSH běží na portu: 8022"
    echo "4. Připojení: ssh -p 8022 <username>@<ip>"
    echo ""
    
    echo -e "${YELLOW}📝 Nastavení hesla:${NC}"
    echo "Spusťte: passwd"
    echo ""
    
    read -p "Chcete nastavit heslo nyní? [y/N]: " set_password
    [[ "$set_password" =~ ^[Yy]$ ]] && passwd
    
    pause_screen
}

setup_termux_api() {
    clear
    echo -e "${CYAN}📱 TERMUX API SETUP${NC}"
    echo ""
    
    if ! check_command termux-battery-status; then
        echo -e "${YELLOW}📥 Termux API není nainstalován${NC}"
        read -p "Chcete nainstalovat? [y/N]: " install_api
        if [[ "$install_api" =~ ^[Yy]$ ]]; then
            install_package termux-api
            echo ""
            echo "💡 Také nainstalujte Termux:API z F-Droid nebo Google Play"
        fi
    else
        log_success "Termux API je nainstalován"
    fi
    
    echo ""
    echo -e "${YELLOW}🔧 Dostupné API funkce:${NC}"
    echo "• termux-battery-status"
    echo "• termux-brightness"
    echo "• termux-camera-photo"
    echo "• termux-clipboard-get/set"
    echo "• termux-location"
    echo "• termux-notification"
    echo "• termux-sensor"
    echo "• termux-torch"
    echo "• termux-vibrate"
    echo "• termux-wifi-connectioninfo"
    
    pause_screen
}

change_colors() {
    clear
    echo -e "${CYAN}🎨 ZMĚNA BAREV${NC}"
    echo ""
    
    echo "💡 Barvy Termuxu můžete změnit pomocí:"
    echo "1. Dlouhý stisk na obrazovku Termuxu"
    echo "2. Vyberte 'Style' nebo 'More...'"
    echo "3. 'Choose color'"
    echo ""
    echo "📦 Nebo nainstalujte: pkg install termux-styling"
    
    pause_screen
}

change_font() {
    clear
    echo -e "${CYAN}🔤 ZMĚNA FONTU${NC}"
    echo ""
    
    echo "💡 Font Termuxu můžete změnit pomocí:"
    echo "1. Dlouhý stisk na obrazovku Termuxu"
    echo "2. Vyberte 'Style' nebo 'More...'"
    echo "3. 'Choose font'"
    echo ""
    echo "📦 Nebo nainstalujte: pkg install termux-styling"
    
    pause_screen
}

export_configuration() {
    clear
    echo -e "${CYAN}💾 EXPORT KONFIGURACE${NC}"
    echo ""
    
    export_file="$BACKUP_DIR/config_export_$(date +%Y%m%d_%H%M%S).txt"
    
    {
        echo "SuperNastroj Configuration Export"
        echo "Date: $(date)"
        echo "=================================="
        echo ""
        echo "VERSION: $VERSION"
        echo "PLATFORM: $PLATFORM"
        echo ""
        echo "PATHS:"
        echo "HOME: $HOME"
        echo "PREFIX: $PREFIX"
        echo "LOG_DIR: $LOG_DIR"
        echo "TOOLS_DIR: $TOOLS_DIR"
        echo "BACKUP_DIR: $BACKUP_DIR"
        echo ""
        echo "INSTALLED PACKAGES:"
        pkg list-installed 2>/dev/null
    } > "$export_file"
    
    log_success "Konfigurace exportována do: $export_file"
    pause_screen
}

# ==================================================
# 11. GENEROVAT REPORT
# ==================================================
generate_report() {
    clear
    echo -e "${CYAN}"
    echo "=================================================="
    echo "          📊 GENEROVÁNÍ REPORTU"
    echo "=================================================="
    echo -e "${NC}"
    
    report_file="$LOG_DIR/report_$(date +%Y%m%d_%H%M%S).txt"
    
    echo -e "${YELLOW}📝 Vytvářím kompletní report...${NC}"
    echo ""
    
    {
        echo "======================================================="
        echo "     SUPER NÁSTROJ - DIAGNOSTICKÝ REPORT"
        echo "======================================================="
        echo "Datum: $(date)"
        echo "Verze: $VERSION"
        echo "Platforma: $PLATFORM"
        echo ""
        echo "=== ZAŘÍZENÍ ==="
        get_device_info
        echo "Model: $MODEL"
        echo "Android: $ANDROID_VERSION"
        echo "Device: $DEVICE"
        echo "API Level: $API_LEVEL"
        echo ""
        echo "=== HARDWARE ==="
        echo "Architektura: $(uname -m)"
        echo "Jádro: $(uname -r)"
        if [ -f "/proc/cpuinfo" ]; then
            echo "CPU jader: $(grep -c ^processor /proc/cpuinfo)"
        fi
        echo ""
        echo "=== PAMĚŤ ==="
        if [ -f "/proc/meminfo" ]; then
            grep -E "MemTotal|MemAvailable" /proc/meminfo
        fi
        echo ""
        echo "=== ÚLOŽIŠTĚ ==="
        df -h 2>/dev/null | grep -E "/(data|storage)"
        echo ""
        echo "=== BATERIE ==="
        if [ -d "/sys/class/power_supply/battery" ]; then
            [ -f "/sys/class/power_supply/battery/capacity" ] && \
                echo "Kapacita: $(cat /sys/class/power_supply/battery/capacity)%"
            [ -f "/sys/class/power_supply/battery/status" ] && \
                echo "Stav: $(cat /sys/class/power_supply/battery/status)"
        fi
        echo ""
        echo "=== SÍŤ ==="
        ip addr show 2>/dev/null | grep "inet " || ifconfig | grep "inet "
        echo ""
        echo "=== NAINSTALOVANÉ BALÍČKY ==="
        pkg list-installed 2>/dev/null | wc -l | awk '{print "Celkem: " $1}'
        echo ""
        echo "=== TOP PROCESY ==="
        ps aux 2>/dev/null | sort -rn -k 3 | head -10 || ps | head -10
        echo ""
        echo "======================================================="
        echo "Report vygenerován: $(date)"
        echo "======================================================="
    } > "$report_file"
    
    log_success "Report vytvořen: $report_file"
    echo ""
    echo -e "${GREEN}✅ Report uložen v: $report_file${NC}"
    echo ""
    read -p "Zobrazit report? [y/N]: " show_report
    
    if [[ "$show_report" =~ ^[Yy]$ ]]; then
        less "$report_file" 2>/dev/null || cat "$report_file" | more
    fi
    
    pause_screen
}

# ==================================================
# 12. KONTROLA AKTUALIZACÍ
# ==================================================
check_updates() {
    clear
    echo -e "${CYAN}"
    echo "=================================================="
    echo "          🔄 KONTROLA AKTUALIZACÍ"
    echo "=================================================="
    echo -e "${NC}"
    
    echo -e "${YELLOW}🔍 Kontroluji dostupné aktualizace Termux...${NC}"
    echo ""
    pkg update
    echo ""
    
    echo -e "${YELLOW}📊 Dostupné aktualizace:${NC}"
    pkg list-upgradable
    echo ""
    
    upgradable=$(pkg list-upgradable 2>/dev/null | wc -l)
    
    if [ "$upgradable" -gt 0 ]; then
        echo -e "${YELLOW}⚠️  Nalezeno $upgradable aktualizací${NC}"
        read -p "Chcete nainstalovat aktualizace? [y/N]: " do_upgrade
        
        if [[ "$do_upgrade" =~ ^[Yy]$ ]]; then
            echo ""
            echo -e "${YELLOW}📥 Instaluji aktualizace...${NC}"
            pkg upgrade -y
            log_success "Aktualizace dokončeny"
        fi
    else
        log_success "Systém je aktuální"
    fi
    
    echo ""
    echo -e "${YELLOW}🚀 SuperNástroj verze:${NC} $VERSION"
    echo "💡 Zkontrolujte GitHub pro nové verze"
    echo "   github.com/Fatalerorr69/SuperNastroj"
    
    log_info "Update check completed"
    pause_screen
}

# ==================================================
# HLAVNÍ PROGRAM
# ==================================================

# Kontrola závislostí při startu
check_dependencies

# Logování startu
log_info "SuperNástroj Android edition v$VERSION started"

# Hlavní smyčka
while true; do
    show_main_menu
    
    case $choice in
        1) android_diagnostics ;;
        2) network_tools_menu ;;
        3) security_analysis ;;
        4) system_information ;;
        5) utilities_menu ;;
        6) wifi_analysis ;;
        7) file_management_menu ;;
        8) performance_battery ;;
        9) package_management ;;
        10) settings_configuration ;;
        11) generate_report ;;
        12) check_updates ;;
        13)
            clear
            echo ""
            echo -e "${CYAN}"
            echo "======================================================="
            echo "     Děkuji za použití SuperNástroje!"
            echo "     FatalErorr69 Android Edition v$VERSION"
            echo "======================================================="
            echo -e "${NC}"
            echo ""
            log_info "Application closed normally"
            exit 0
            ;;
        *)
            echo -e "${RED}❌ Neplatná volba!${NC}"
            sleep 1
            ;;
    esac
done ping_test ;;
            8) traceroute_test ;;
            9) show_connections ;;
            10) return ;;
            *) echo -e "${RED}❌ Neplatná volba!${NC}"; sleep 1 ;;
        esac
    done
}

network_diagnostics() {
    clear
    echo -e "${CYAN}🌐 SÍŤOVÁ DIAGNOSTIKA...${NC}"
    echo ""
    
    echo -e "${YELLOW}📶 Síťové rozhraní:${NC}"
    ip addr show 2>/dev/null || ifconfig 2>/dev/null
    echo ""
    
    echo -e "${YELLOW}🔄 Test připojení (Google DNS):${NC}"
    ping -c 4 8.8.8.8
    echo ""
    
    echo -e "${YELLOW}🔄 Test připojení (Cloudflare):${NC}"
    ping -c 4 1.1.1.1
    echo ""
    
    echo -e "${YELLOW}🛣️  Směrování:${NC}"
    ip route 2>/dev/null || route -n 2>/dev/null
    
    log_info "Network diagnostics completed"
    pause_screen
}

port_scanning() {
    clear
    echo -e "${CYAN}🔍 SKENOVÁNÍ PORTŮ${NC}"
    echo ""
    
    read -p "Zadejte IP adresu (Enter pro localhost): " ip_address
    [ -z "$ip_address" ] && ip_address="127.0.0.1"
    
    if check_command nmap; then
        echo ""
        echo -e "${YELLOW}Skenuji $ip_address...${NC}"
        nmap -Pn -p 1-1000 "$ip_address" 2>&1 | tee -a "$NETWORK_LOG"
    else
        echo -e "${RED}❌ Nmap není nainstalován${NC}"
        read -p "Chcete nainstalovat? [y/N]: " install_choice
        [[ "$install_choice" =~ ^[Yy]$ ]] && install_package nmap && port_scanning
    fi
    
    pause_screen
}

wifi_analysis() {
    clear
    echo -e "${CYAN}📶 WIFI ANALÝZA${NC}"
    echo ""
    
    if check_command termux-wifi-scaninfo; then
        echo -e "${YELLOW}🔍 Skenuji WiFi sítě...${NC}"
        termux-wifi-scaninfo 2>&1 | tee -a "$NETWORK_LOG"
    else
        echo -e "${YELLOW}ℹ️  Termux WiFi API není dostupné${NC}"
        echo "💡 Spusťte: termux-setup-storage"
        echo "💡 Povolte oprávnění pro WiFi v nastavení Androidu"
    fi
    
    echo ""
    echo -e "${YELLOW}📡 Aktuální WiFi připojení:${NC}"
    if check_command termux-wifi-connectioninfo; then
        termux-wifi-connectioninfo
    else
        ip addr show wlan0 2>/dev/null || echo "ℹ️  Informace o WiFi nejsou dostupné"
    fi
    
    pause_screen
}

speed_test() {
    clear
    echo -e "${CYAN}🚀 TEST RYCHLOSTI PŘIPOJENÍ${NC}"
    echo ""
    
    if check_command speedtest-cli; then
        echo -e "${YELLOW}📊 Měřím rychlost...${NC}"
        speedtest-cli --simple 2>&1 | tee -a "$NETWORK_LOG"
    elif check_command curl; then
        echo -e "${YELLOW}📥 Test download rychlosti...${NC}"
        curl -o /dev/null -s -w "Rychlost: %{speed_download} B/s\nČas: %{time_total}s\n" \
            http://speedtest.tele2.net/10MB.zip
    else
        echo -e "${RED}❌ speedtest-cli není nainstalován${NC}"
        read -p "Chcete nainstalovat? [y/N]: " install_choice
        [[ "$install_choice" =~ ^[Yy]$ ]] && install_package speedtest-cli && speed_test
    fi
    
    pause_screen
}

dns_tests() {
    clear
    echo -e "${CYAN}🔧 DNS TESTY${NC}"
    echo ""
    
    echo -e "${YELLOW}🌐 Test DNS Google (8.8.8.8):${NC}"
    nslookup google.com 8.8.8.8 2>/dev/null || host google.com
    echo ""
    
    echo -e "${YELLOW}🌐 Test DNS Cloudflare (1.1.1.1):${NC}"
    nslookup google.com 1.1.1.1 2>/dev/null
    echo ""
    
    if check_command dig; then
        echo -e "${YELLOW}⏱️  DNS Response Time:${NC}"
        dig google.com | grep "Query time"
    fi
    
    pause_screen
}

network_info() {
    clear
    echo -e "${CYAN}📡 SÍŤOVÉ INFORMACE${NC}"
    echo ""
    
    echo -e "${YELLOW}🌐 IP Adresy:${NC}"
    ip addr show 2>/dev/null | grep "inet " || ifconfig | grep "inet "
    echo ""
    
    echo -e "${YELLOW}📊 Síťová statistika:${NC}"
    netstat -s 2>/dev/null | head -20
    echo ""
    
    echo -e "${YELLOW}🔌 Aktivní rozhraní:${NC}"
    ip link show 2>/dev/null || ifconfig -a
    
    pause_screen
}

ping_test() {
    clear
    echo -e "${CYAN}🏓 PING TEST${NC}"
    echo ""
    
    read -p "Zadejte adresu (Enter pro 8.8.8.8): " target
    [ -z "$target" ] && target="8.8.8.8"
    
    read -p "Počet paketů (Enter pro 10): " count
    [ -z "$count" ] && count=10
    
    echo ""
    echo -e "${YELLOW}🔄 Pinguji $target ($count paketů)...${NC}"
    ping -c "$count" "$target" 2>&1 | tee -a "$NETWORK_LOG"
    
    pause_screen
}

traceroute_test() {
    clear
    echo -e "${CYAN}🗺️  TRACEROUTE${NC}"
    echo ""
    
    read -p "Zadejte adresu (Enter pro google.com): " target
    [ -z "$target" ] && target="google.com"
    
    echo ""
    if check_command traceroute; then
        echo -e "${YELLOW}🛣️  Trasování cesty k $target...${NC}"
        traceroute "$target" 2>&1 | tee -a "$NETWORK_LOG"
    else
        echo -e "${YELLOW}📍 Používám ping pro základní traceroute...${NC}"
        for i in {1..15}; do
            ping -c 1 -t $i "$target" 2>&1 | grep "time=" && sleep 0.5
        done
    fi
    
    pause_screen
}

show_connections() {
    clear
    echo -e "${CYAN}🔌 OTEVŘENÁ SPOJENÍ${NC}"
    echo ""
    
    echo -e "${YELLOW}📊 Aktivní TCP spojení:${NC}"
    netstat -tn 2>/dev/null | grep ESTABLISHED || ss -tn | grep ESTAB
    echo ""
    
    echo -e "${YELLOW}📊 Poslouchající porty:${NC}"
    netstat -tln 2>/dev/null | grep LISTEN || ss -tln | grep LISTEN
    echo ""
    
    echo -e "${YELLOW}📈 Počet spojení podle stavu:${NC}"
    netstat -tan 2>/dev/null | awk '{print $6}' | sort | uniq -c | sort -rn
    
    pause_screen
}

# ==================================================
# 3. BEZPEČNOSTNÍ ANALÝZA
# ==================================================
security_analysis() {
    clear
    echo -e "${CYAN}"
    echo "=================================================="
    echo "          🛡️  BEZPEČNOSTNÍ ANALÝZA"
    echo "=================================================="
    echo -e "${NC}"
    
    # Kontrola oprávnění
    echo -e "${YELLOW}🔐 KONTROLA OPRÁVNĚNÍ:${NC}"
    echo "Termux úložiště:"
    if [ -r "/sdcard" ]; then
        echo "✅ Přístup k úložišti povolen"
    else
        echo "❌ Přístup k úložišti není povolen"
        echo "   💡 Spusťte: termux-setup-storage"
    fi
    echo ""
    
    # Kontrola běžících procesů
    echo -e "${YELLOW}⚙️  TOP PROCESY (CPU):${NC}"
    ps aux --sort=-%cpu 2>/dev/null | head -6 || ps | head -10
    echo ""
    
    # Kontrola otevřených portů
    echo -e "${YELLOW}🚪 OTEVŘENÉ PORTY:${NC}"
    netstat -tuln 2>/dev/null | grep LISTEN | head -10 || \
    ss -tuln | grep LISTEN | head -10
    echo ""
    
    # Kontrola uživatelských práv
    echo -e "${YELLOW}👤 UŽIVATELSKÁ PRÁVA:${NC}"
    echo "Aktuální uživatel: $(whoami)"
    echo "UID: $UID"
    echo "GID: $(id -g)"
    echo "Skupiny: $(id -Gn)"
    echo ""
    
    # Termux API oprávnění
    echo -e "${YELLOW}📱 TERMUX API OPRÁVNĚNÍ:${NC}"
    local permissions=("storage" "camera" "location" "sms" "contacts")
    for perm in "${permissions[@]}"; do
        if check_command "termux-$perm-get" 2>/dev/null; then
            echo "✅ $perm - dostupné"
        else
            echo "❌ $perm - není dostupné"
        fi
    done
    echo ""
    
    # Bezpečnostní doporučení
    echo -e "${YELLOW}💡 BEZPEČNOSTNÍ DOPORUČENÍ:${NC}"
    echo "1. ✓ Pravidelně aktualizovat Termux (pkg update)"
    echo "2. ✓ Používat silná hesla pro SSH"
    echo "3. ✓ Omezit oprávnění aplikací"
    echo "4. ✓ Používat VPN v nezabezpečených sítích"
    echo "5. ✓ Pravidelně zálohovat data"
    echo "6. ✓ Neinstalovat aplikace z neznámých zdrojů"
    echo "7. ✓ Zkontrolovat nainstalované balíčky"
    echo ""
    
    # Kontrola balíčků
    echo -e "${YELLOW}📦 NAINSTALOVANÉ BALÍČKY:${NC}"
    pkg list-installed 2>/dev/null | wc -l | awk '{print "Celkem: " $1 " balíčků"}'
    
    log_info "Security analysis completed"
    pause_screen
}

# ==================================================
# 4. INFORMACE O SYSTÉMU
# ==================================================
system_information() {
    clear
    echo -e "${CYAN}"
    echo "=================================================="
    echo "          📱 INFORMACE O SYSTÉMU"
    echo "=================================================="
    echo -e "${NC}"
    
    # System Properties
    echo -e "${YELLOW}🏷️  SYSTEM PROPERTIES:${NC}"
    if check_command getprop; then
        echo "Model: $(getprop ro.product.model 2>/dev/null)"
        echo "Výrobce: $(getprop ro.product.manufacturer 2>/dev/null)"
        echo "Brand: $(getprop ro.product.brand 2>/dev/null)"
        echo "Device: $(getprop ro.product.device 2>/dev/null)"
        echo "Android verze: $(getprop ro.build.version.release 2>/dev/null)"
        echo "API Level: $(getprop ro.build.version.sdk 2>/dev/null)"
        echo "Build ID: $(getprop ro.build.id 2>/dev/null)"
        echo "Build Type: $(getprop ro.build.type 2>/dev/null)"
        echo "Security Patch: $(getprop ro.build.version.security_patch 2>/dev/null)"
    fi
    echo ""
    
    # Hardware
    echo -e "${YELLOW}⚙️  HARDWARE:${NC}"
    echo "Architektura: $(uname -m)"
    echo "Jádro: $(uname -r)"
    echo "Platform: $(uname -o)"
    echo ""
    
    # CPU detailně
    if [ -f "/proc/cpuinfo" ]; then
        echo -e "${YELLOW}🖥️  CPU DETAILY:${NC}"
        grep -E "processor|model name|cpu MHz|bogomips" /proc/cpuinfo | head -8
        echo ""
    fi
    
    # Storage
    echo -e "${YELLOW}💾 ÚLOŽIŠTĚ:${NC}"
    df -h 2>/dev/null | grep -E "/(data|storage)" || df -h | head -5
    echo ""
    
    # Environment
    echo -e "${YELLOW}🔧 PROSTŘEDÍ:${NC}"
    echo "Termux verze: $(pkg show termux-tools 2>/dev/null | grep Version | cut -d: -f2)"
    echo "Shell: $SHELL"
    echo "PATH: $PATH" | fold -w 60
    echo "HOME: $HOME"
    echo "PREFIX: $PREFIX"
    
    log_info "System information displayed"
    pause_screen
}

# ==================================================
# 5. UTILITY A NÁSTROJE
# ==================================================
utilities_menu() {
    clear
    echo -e "${CYAN}"
    echo "=================================================="
    echo "          🔧 UTILITY A NÁSTROJE"
    echo "=================================================="
    echo -e "${NC}"
    
    echo -e "${YELLOW}📊 SYSTÉMOVÉ UTILITY:${NC}"
    echo "• top - systémový monitor"
    echo "• htop - pokročilý monitor (pokud nainstalován)"
    echo "• free - stav paměti"
    echo "• df - využití disků"
    echo "• du - velikost složek"
    echo ""
    
    echo -e "${YELLOW}🛠️  DOSTUPNÉ NÁSTROJE:${NC}"
    local tools=("git" "python" "python3" "clang" "node" "php" "perl" "ruby" "java")
    for tool in "${tools[@]}"; do
        if check_command "$tool"; then
            version=$($tool --version 2>&1 | head -1)
            echo -e "✅ $tool - $version"
        else
            echo -e "❌ $tool - není nainstalován"
        fi
    done
    echo ""
    
    echo -e "${YELLOW}💡 UŽITEČNÉ PŘÍKAZY:${NC}"
    echo "• pkg update        - aktualizovat seznamy"
    echo "• pkg upgrade       - aktualizovat balíčky"
    echo "• pkg install <pkg> - nainstalovat balíček"
    echo "• pkg search <term> - hledat balíček"
    echo "• pkg show <pkg>    - info o balíčku"
    echo "• termux-setup-storage - nastavit úložiště"
    echo "• termux-change-repo   - změnit repozitář"
    
    log_info "Utilities menu displayed"
    pause_screen
}

# ==================================================
# 6. WIFI ANALÝZA (Rozšířená)
# ==================================================
# Již implementováno v network_tools_menu jako wifi_analysis

# ==================================================
# 7. SPRÁVA SOUBORŮ A ZÁLOHA
# ==================================================
file_management_menu() {
    while true; do
        clear
        echo -e "${CYAN}"
        echo "=================================================="
        echo "          💾 SPRÁVA SOUBORŮ A ZÁLOHA"
        echo "=================================================="
        echo -e "${NC}"
        echo ""
        echo "1) Zobrazit aktuální adresář"
        echo "2) Procházet soubory"
        echo "3) Vytvořit zálohu"
        echo "4) Obnovit ze zálohy"
        echo "5) Analyzovat využití disku"
        echo "6) Hledat soubory"
        echo "7) Komprimovat/Dekomprimovat"
        echo "8) Zpět do hlavního menu"
        echo ""
        read -p "Vyberte možnost [1-8]: " file_choice
        
        case $file_choice in
            1) show_current_directory ;;
            2) browse_files ;;
            3) create_backup ;;
            4) restore_backup ;;
            5) analyze_disk_usage ;;
            6) find_files ;;
            7)