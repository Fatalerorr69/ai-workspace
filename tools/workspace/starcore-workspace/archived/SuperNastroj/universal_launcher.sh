#!/bin/bash
# ==================================================
# SUPER NÁSTROJ v5.0 - UNIVERZÁLNÍ LAUNCHER
# FatalErorr69 - Multiplatformní spouštěč
# ==================================================

VERSION="5.0"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" 2>/dev/null && pwd)"

# Barvy
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
WHITE='\033[1;37m'
NC='\033[0m'

# ==================================================
# DETEKCE PLATFORMY
# ==================================================

detect_platform() {
    echo -e "${CYAN}"
    echo "======================================================="
    echo "   🚀 SUPER NÁSTROJ v${VERSION} - UNIVERZÁLNÍ LAUNCHER"
    echo "======================================================="
    echo -e "${NC}"
    echo ""
    echo -e "${YELLOW}🔍 Detekuji platformu...${NC}"
    echo ""
    
    PLATFORM="UNKNOWN"
    ARCH=$(uname -m 2>/dev/null || echo "unknown")
    OS_TYPE=$(uname -s 2>/dev/null || echo "unknown")
    
    # Detekce Android/Termux
    if [ -d "/data/data/com.termux/files/usr" ] || [ "$PREFIX" = "/data/data/com.termux/files/usr" ]; then
        PLATFORM="ANDROID"
        SCRIPT="SuperNastroj_android.sh"
    # Detekce Linux
    elif [ "$OS_TYPE" = "Linux" ]; then
        PLATFORM="LINUX"
        SCRIPT="SuperNastroj_linux.sh"
    # Detekce macOS
    elif [ "$OS_TYPE" = "Darwin" ]; then
        PLATFORM="MACOS"
        SCRIPT="SuperNastroj_linux.sh"  # macOS může použít Linux verzi
    # Detekce WSL (Windows Subsystem for Linux)
    elif grep -qi microsoft /proc/version 2>/dev/null; then
        PLATFORM="WSL"
        SCRIPT="SuperNastroj_linux.sh"
    # Detekce BSD
    elif [ "$OS_TYPE" = "FreeBSD" ] || [ "$OS_TYPE" = "OpenBSD" ]; then
        PLATFORM="BSD"
        SCRIPT="SuperNastroj_linux.sh"
    fi
    
    # Zjištění distribuce Linux
    if [ "$PLATFORM" = "LINUX" ]; then
        if [ -f "/etc/os-release" ]; then
            DISTRO=$(grep "^ID=" /etc/os-release | cut -d= -f2 | tr -d '"')
            DISTRO_NAME=$(grep "^NAME=" /etc/os-release | cut -d= -f2 | tr -d '"')
        elif [ -f "/etc/lsb-release" ]; then
            DISTRO=$(grep "DISTRIB_ID" /etc/lsb-release | cut -d= -f2)
            DISTRO_NAME=$DISTRO
        else
            DISTRO="unknown"
            DISTRO_NAME="Unknown Linux"
        fi
    fi
    
    # Zjištění Android verze
    if [ "$PLATFORM" = "ANDROID" ]; then
        if command -v getprop &> /dev/null; then
            ANDROID_VERSION=$(getprop ro.build.version.release 2>/dev/null || echo "unknown")
            DEVICE_MODEL=$(getprop ro.product.model 2>/dev/null || echo "unknown")
        fi
    fi
}

# ==================================================
# ZOBRAZENÍ INFORMACÍ O PLATFORMĚ
# ==================================================

display_platform_info() {
    echo -e "${GREEN}✅ Platforma detekována:${NC}"
    echo ""
    echo "  Platform: $PLATFORM"
    echo "  OS Type:  $OS_TYPE"
    echo "  Arch:     $ARCH"
    
    case $PLATFORM in
        LINUX)
            echo "  Distro:   $DISTRO_NAME"
            ;;
        ANDROID)
            echo "  Android:  $ANDROID_VERSION"
            echo "  Device:   $DEVICE_MODEL"
            ;;
        WSL)
            echo "  Type:     Windows Subsystem for Linux"
            ;;
        MACOS)
            echo "  Version:  $(sw_vers -productVersion 2>/dev/null)"
            ;;
    esac
    
    echo ""
}

# ==================================================
# KONTROLA POŽADAVKŮ
# ==================================================

check_requirements() {
    echo -e "${YELLOW}🔧 Kontroluji požadavky...${NC}"
    echo ""
    
    local missing=()
    
    # Základní nástroje
    local required_tools=("bash")
    
    case $PLATFORM in
        LINUX|WSL|MACOS|BSD)
            required_tools+=("sudo" "chmod")
            ;;
        ANDROID)
            required_tools+=("pkg" "chmod")
            ;;
    esac
    
    for tool in "${required_tools[@]}"; do
        if ! command -v "$tool" &> /dev/null; then
            missing+=("$tool")
        fi
    done
    
    if [ ${#missing[@]} -gt 0 ]; then
        echo -e "${RED}❌ Chybějící nástroje: ${missing[*]}${NC}"
        echo ""
        return 1
    else
        echo -e "${GREEN}✅ Všechny požadavky splněny${NC}"
        echo ""
        return 0
    fi
}

# ==================================================
# KONTROLA SKRIPTŮ
# ==================================================

check_scripts() {
    echo -e "${YELLOW}📁 Kontroluji dostupnost skriptů...${NC}"
    echo ""
    
    cd "$SCRIPT_DIR" || {
        echo -e "${RED}❌ Nelze přejít do adresáře skriptu${NC}"
        exit 1
    }
    
    case $PLATFORM in
        ANDROID)
            SCRIPT="SuperNastroj_android.sh"
            ;;
        LINUX|WSL|MACOS|BSD)
            SCRIPT="SuperNastroj_linux.sh"
            ;;
        *)
            echo -e "${RED}❌ Nepodporovaná platforma: $PLATFORM${NC}"
            exit 1
            ;;
    esac
    
    if [ ! -f "$SCRIPT" ]; then
        echo -e "${RED}❌ Skript nenalezen: $SCRIPT${NC}"
        echo ""
        echo "📂 Obsah adresáře:"
        ls -la *.sh 2>/dev/null || ls -la
        echo ""
        echo "💡 Ujistěte se, že máte všechny soubory projektu"
        echo "   Stáhněte z: https://github.com/Fatalerorr69/SuperNastroj"
        return 1
    fi
    
    echo -e "${GREEN}✅ Skript nalezen: $SCRIPT${NC}"
    echo ""
    return 0
}

# ==================================================
# NASTAVENÍ OPRÁVNĚNÍ
# ==================================================

setup_permissions() {
    echo -e "${YELLOW}🔐 Nastavuji oprávnění...${NC}"
    
    chmod +x "$SCRIPT" 2>/dev/null
    
    if [ $? -eq 0 ]; then
        echo -e "${GREEN}✅ Oprávnění nastavena${NC}"
        echo ""
    else
        echo -e "${RED}❌ Nelze nastavit oprávnění${NC}"
        echo ""
        return 1
    fi
}

# ==================================================
# KONTROLA ROOT/SUDO
# ==================================================

check_root_requirements() {
    if [ "$PLATFORM" = "ANDROID" ]; then
        # Android nevyžaduje root
        return 0
    fi
    
    if [ "$EUID" -ne 0 ]; then
        echo -e "${YELLOW}⚠️  Upozornění: Některé funkce vyžadují sudo/root práva${NC}"
        echo ""
        return 1
    else
        echo -e "${GREEN}✅ Běží s root právy${NC}"
        echo ""
        return 0
    fi
}

# ==================================================
# SPUŠTĚNÍ PLATFORMY
# ==================================================

launch_platform() {
    echo -e "${CYAN}🚀 Spouštím SuperNástroj pro $PLATFORM...${NC}"
    echo ""
    sleep 1
    
    case $PLATFORM in
        ANDROID)
            exec bash "$SCRIPT"
            ;;
        LINUX|WSL|MACOS|BSD)
            if [ "$EUID" -ne 0 ]; then
                echo -e "${YELLOW}💡 Pro plnou funkcionalitu spusťte: sudo $0${NC}"
                sleep 2
            fi
            exec bash "$SCRIPT"
            ;;
        *)
            echo -e "${RED}❌ Nepodporovaná platforma${NC}"
            exit 1
            ;;
    esac
}

# ==================================================
# HLAVNÍ PROGRAM
# ==================================================

main() {
    clear
    
    # Detekce platformy
    detect_platform
    
    # Zobrazení informací
    display_platform_info
    
    # Kontrola požadavků
    if ! check_requirements; then
        echo ""
        read -p "Pokračovat přesto? [y/N]: " continue_anyway
        if [[ ! "$continue_anyway" =~ ^[Yy]$ ]]; then
            exit 1
        fi
    fi
    
    # Kontrola skriptů
    if ! check_scripts; then
        exit 1
    fi
    
    # Nastavení oprávnění
    if ! setup_permissions; then
        echo -e "${YELLOW}⚠️  Nelze nastavit oprávnění, pokračuji...${NC}"
    fi
    
    # Kontrola root (jen varování)
    check_root_requirements
    
    # Finální potvrzení
    echo ""
    echo -e "${WHITE}════════════════════════════════════════════════════════${NC}"
    echo -e "${GREEN}✨ Vše připraveno!${NC}"
    echo -e "${WHITE}════════════════════════════════════════════════════════${NC}"
    echo ""
    echo "  Platform:    $PLATFORM"
    echo "  Script:      $SCRIPT"
    echo "  Version:     $VERSION"
    echo ""
    read -p "Stiskněte Enter pro spuštění..." dummy
    
    # Spuštění
    launch_platform
}

# ==================================================
# ZPRACOVÁNÍ ARGUMENTŮ
# ==================================================

if [ "$1" = "--help" ] || [ "$1" = "-h" ]; then
    cat << EOF
SuperNastroj v${VERSION} - Univerzální Launcher

Použití:
  $0              Automatická detekce a spuštění
  $0 --help       Zobrazit tuto nápovědu
  $0 --version    Zobrazit verzi
  $0 --check      Pouze kontrola bez spuštění

Podporované platformy:
  • Linux (Debian, Ubuntu, Fedora, Arch, atd.)
  • Android/Termux
  • Windows Subsystem for Linux (WSL)
  • macOS
  • BSD (FreeBSD, OpenBSD)

Repositář: https://github.com/Fatalerorr69/SuperNastroj
Autor: FatalErorr69
EOF
    exit 0
fi

if [ "$1" = "--version" ] || [ "$1" = "-v" ]; then
    echo "SuperNastroj v${VERSION}"
    echo "Universal Launcher"
    exit 0
fi

if [ "$1" = "--check" ]; then
    detect_platform
    display_platform_info
    check_requirements
    check_scripts
    echo ""
    echo "✅ Kontrola dokončena"
    exit 0
fi

# Spuštění hlavního programu
main
