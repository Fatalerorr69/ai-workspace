#!/bin/bash
# ======================================================
# GameHub Ultimate Gaming Server - Master Installer
# Version: 3.0.0
# Platform: Ubuntu 22.04/24.04 LTS
# ======================================================

set -e

# --- Colors ---
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
MAGENTA='\033[0;35m'
NC='\033[0m'
BOLD='\033[1m'

# --- Configuration ---
GAMEHUB_VERSION="3.0.0"
INSTALL_DIR="/opt/gamehub"
WEB_DIR="/var/www/gamehub"
LOG_DIR="/var/log/gamehub"
BACKUP_DIR="/backup/gamehub"
CONFIG_DIR="/etc/gamehub"
USER_NAME="gamehub"
DB_NAME="gamehub_db"
DB_USER="gamehub_admin"
DB_PASS=$(openssl rand -base64 32)

# Ports
API_PORT="3001"
WEB_PORT="80"
WS_PORT="8081"
COCKPIT_PORT="9090"
NETDATA_PORT="19999"

# --- Logging Functions ---
log() {
    echo -e "${BLUE}[$(date '+%Y-%m-%d %H:%M:%S')]${NC} $1" | tee -a "$LOG_DIR/installation.log"
}

success() {
    echo -e "${GREEN}✓${NC} $1" | tee -a "$LOG_DIR/installation.log"
}

error() {
    echo -e "${RED}✗${NC} $1" | tee -a "$LOG_DIR/installation.log"
    exit 1
}

warning() {
    echo -e "${YELLOW}!${NC} $1" | tee -a "$LOG_DIR/installation.log"
}

info() {
    echo -e "${CYAN}➜${NC} $1" | tee -a "$LOG_DIR/installation.log"
}

# --- Banner ---
print_banner() {
    clear
    echo -e "${MAGENTA}"
    cat << 'EOF'
  ╔══════════════════════════════════════════════════════════════╗
  ║                                                              ║
  ║   ██████╗  █████╗ ███╗   ███╗███████╗██╗  ██╗██╗   ██╗██████╗║
  ║  ██╔════╝ ██╔══██╗████╗ ████║██╔════╝██║  ██║██║   ██║██╔══██╗║
  ║  ██║  ███╗███████║██╔████╔██║█████╗  ███████║██║   ██║██████╔╝║
  ║  ██║   ██║██╔══██║██║╚██╔╝██║██╔══╝  ██╔══██║██║   ██║██╔══██╗║
  ║  ╚██████╔╝██║  ██║██║ ╚═╝ ██║███████╗██║  ██║╚██████╔╝██████╔╝║
  ║   ╚═════╝ ╚═╝  ╚═╝╚═╝     ╚═╝╚══════╝╚═╝  ╚═╝ ╚═════╝ ╚═════╝ ║
  ║                                                              ║
  ║            Ultimate Gaming Server Platform v3.0              ║
  ║        Modular • Automated • Cloud-Enabled • Monitored       ║
  ╚══════════════════════════════════════════════════════════════╝
EOF
    echo -e "${NC}"
    echo ""
}

# --- Environment Check ---
check_environment() {
    log "Checking environment requirements..."
    
    # Root check
    if [ "$EUID" -ne 0 ]; then
        error "This script must be run as root: sudo $0"
    fi
    
    # OS check
    if [ ! -f /etc/os-release ]; then
        error "Cannot determine OS distribution"
    fi
    
    . /etc/os-release
    if [ "$ID" != "ubuntu" ]; then
        warning "Recommended: Ubuntu 22.04/24.04 LTS. Current: $ID $VERSION_ID"
    fi
    
    # Memory check (min 4GB recommended)
    MEM_AVAIL=$(free -m | awk '/^Mem:/ {print $2}')
    if [ "$MEM_AVAIL" -lt 4096 ]; then
        warning "Low memory: ${MEM_AVAIL}MB. Recommended: 8GB+"
    fi
    
    # Disk check (min 50GB recommended)
    DISK_AVAIL=$(df / | tail -1 | awk '{print $4}')
    if [ "$DISK_AVAIL" -lt 52428800 ]; then
        warning "Low disk space: $((DISK_AVAIL/1024))MB. Recommended: 100GB+"
    fi
    
    # Internet connectivity
    if ! ping -c 1 8.8.8.8 &> /dev/null; then
        error "No internet connectivity detected"
    fi
    
    success "Environment check passed"
}

# --- Directory Structure ---
create_directories() {
    log "Creating directory structure..."
    
    local dirs=(
        "$INSTALL_DIR"
        "$INSTALL_DIR/servers"
        "$INSTALL_DIR/games"
        "$INSTALL_DIR/emulators"
        "$INSTALL_DIR/roms"
        "$INSTALL_DIR/saves"
        "$INSTALL_DIR/mods"
        "$INSTALL_DIR/scripts"
        "$INSTALL_DIR/modules"
        "$INSTALL_DIR/data"
        "$WEB_DIR"
        "$LOG_DIR"
        "$BACKUP_DIR"
        "$CONFIG_DIR"
        "$CONFIG_DIR/modules"
        "$CONFIG_DIR/games"
        "$CONFIG_DIR/nginx"
        "/home/$USER_NAME"
    )
    
    for dir in "${dirs[@]}"; do
        mkdir -p "$dir"
        chmod 755 "$dir"
    done
    
    # Create gamehub user
    if ! id "$USER_NAME" &>/dev/null; then
        useradd -m -s /bin/bash -d "/home/$USER_NAME" "$USER_NAME"
        usermod -aG sudo,docker "$USER_NAME"
        echo "$USER_NAME ALL=(ALL) NOPASSWD:ALL" > /etc/sudoers.d/gamehub
        chmod 440 /etc/sudoers.d/gamehub
        success "User $USER_NAME created"
    fi
    
    # Set ownership
    chown -R "$USER_NAME:$USER_NAME" "$INSTALL_DIR"
    chown -R "$USER_NAME:$USER_NAME" "$WEB_DIR"
    chown -R "$USER_NAME:$USER_NAME" "$CONFIG_DIR"
    
    success "Directory structure created"
}

# --- System Update ---
update_system() {
    log "Updating system packages..."
    
    apt update -y >> "$LOG_DIR/installation.log" 2>&1
    DEBIAN_FRONTEND=noninteractive apt upgrade -y >> "$LOG_DIR/installation.log" 2>&1
    
    # Essential tools
    apt install -y \
        software-properties-common \
        apt-transport-https \
        ca-certificates \
        curl wget git \
        build-essential \
        python3 python3-pip python3-venv \
        nodejs npm \
        docker.io docker-compose \
        nginx \
        mariadb-server \
        redis-server \
        ufw fail2ban \
        htop ncdu \
        jq yq \
        >> "$LOG_DIR/installation.log" 2>&1
    
    apt autoremove -y >> "$LOG_DIR/installation.log" 2>&1
    
    success "System updated"
}

# --- Module Selection ---
select_modules() {
    log "Module Selection..."
    
    echo -e "${CYAN}Select modules to install:${NC}"
    echo ""
    echo "  [1] Core Gaming Server (Required)"
    echo "  [2] Emulators (RetroArch, PPSSPP, Dolphin, etc.)"
    echo "  [3] Steam + Proton"
    echo "  [4] Development Tools (VSCode, Git, Docker)"
    echo "  [5] Remote Access (RDP, VNC, SSH)"
    echo "  [6] Monitoring & Analytics"
    echo "  [7] Backup & Cloud Sync"
    echo "  [8] Web Dashboard"
    echo "  [9] All Modules"
    echo ""
    
    read -p "Enter module numbers (space-separated, e.g., '1 2 6 8'): " MODULES
    
    # Parse selections
    INSTALL_CORE=false
    INSTALL_EMULATORS=false
    INSTALL_STEAM=false
    INSTALL_DEV=false
    INSTALL_REMOTE=false
    INSTALL_MONITORING=false
    INSTALL_BACKUP=false
    INSTALL_DASHBOARD=false
    
    for mod in $MODULES; do
        case $mod in
            1) INSTALL_CORE=true ;;
            2) INSTALL_EMULATORS=true ;;
            3) INSTALL_STEAM=true ;;
            4) INSTALL_DEV=true ;;
            5) INSTALL_REMOTE=true ;;
            6) INSTALL_MONITORING=true ;;
            7) INSTALL_BACKUP=true ;;
            8) INSTALL_DASHBOARD=true ;;
            9) 
                INSTALL_CORE=true
                INSTALL_EMULATORS=true
                INSTALL_STEAM=true
                INSTALL_DEV=true
                INSTALL_REMOTE=true
                INSTALL_MONITORING=true
                INSTALL_BACKUP=true
                INSTALL_DASHBOARD=true
                ;;
        esac
    done
    
    # Core is always required
    INSTALL_CORE=true
    
    # Save module config
    cat > "$CONFIG_DIR/modules.conf" << EOF
INSTALL_CORE=$INSTALL_CORE
INSTALL_EMULATORS=$INSTALL_EMULATORS
INSTALL_STEAM=$INSTALL_STEAM
INSTALL_DEV=$INSTALL_DEV
INSTALL_REMOTE=$INSTALL_REMOTE
INSTALL_MONITORING=$INSTALL_MONITORING
INSTALL_BACKUP=$INSTALL_BACKUP
INSTALL_DASHBOARD=$INSTALL_DASHBOARD
EOF
    
    success "Modules selected"
}

# --- Core Gaming Server ---
install_core() {
    if [ "$INSTALL_CORE" != "true" ]; then
        return
    fi
    
    log "Installing Core Gaming Server..."
    
    # Install Node.js LTS
    curl -fsSL https://deb.nodesource.com/setup_lts.x | bash -
    apt install -y nodejs
    
    # Install PM2
    npm install -g pm2
    
    # Create package.json
    cat > "$INSTALL_DIR/package.json" << 'EOF'
{
  "name": "gamehub-core",
  "version": "3.0.0",
  "description": "GameHub Ultimate Gaming Server",
  "main": "index.js",
  "scripts": {
    "start": "node index.js",
    "dev": "nodemon index.js"
  },
  "dependencies": {
    "express": "^4.18.2",
    "ws": "^8.14.2",
    "mysql2": "^3.6.1",
    "redis": "^4.6.8",
    "systeminformation": "^5.21.0",
    "uuid": "^9.0.1",
    "jsonwebtoken": "^9.0.2",
    "bcryptjs": "^2.4.3",
    "cors": "^2.8.5",
    "helmet": "^7.1.0",
    "compression": "^1.7.4",
    "dotenv": "^16.3.1",
    "winston": "^3.11.0"
  }
}
EOF
    
    cd "$INSTALL_DIR"
    npm install >> "$LOG_DIR/installation.log" 2>&1
    
    success "Core installed"
}

# --- Emulators Module ---
install_emulators() {
    if [ "$INSTALL_EMULATORS" != "true" ]; then
        return
    fi
    
    log "Installing gaming emulators..."
    
    # Add Flathub
    apt install -y flatpak
    flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo
    
    # RetroArch
    flatpak install -y flathub org.libretro.RetroArch
    
    # Individual emulators
    flatpak install -y flathub org.ppsspp.PPSSPP          # PSP
    flatpak install -y flathub org.DolphinEmu.dolphin-emu # GameCube/Wii
    flatpak install -y flathub net.pcsx2.PCSX2            # PS2
    
    # DOSBox
    apt install -y dosbox dosbox-x
    
    # ScummVM
    apt install -y scummvm
    
    success "Emulators installed"
}

# --- Steam Module ---
install_steam() {
    if [ "$INSTALL_STEAM" != "true" ]; then
        return
    fi
    
    log "Installing Steam and Proton..."
    
    dpkg --add-architecture i386
    apt update
    apt install -y steam-installer wine-stable winetricks
    
    # Proton-GE
    wget https://github.com/GloriousEggroll/proton-ge-custom/releases/latest/download/proton-ge-custom.tar.gz \
        -O /tmp/proton-ge.tar.gz
    mkdir -p /home/$USER_NAME/.steam/root/compatibilitytools.d
    tar -xf /tmp/proton-ge.tar.gz -C /home/$USER_NAME/.steam/root/compatibilitytools.d/
    chown -R $USER_NAME:$USER_NAME /home/$USER_NAME/.steam
    
    success "Steam installed"
}

# --- Development Tools ---
install_dev_tools() {
    if [ "$INSTALL_DEV" != "true" ]; then
        return
    fi
    
    log "Installing development tools..."
    
    # GitHub CLI
    curl -fsSL https://cli.github.com/packages/githubcli-archive-keyring.gpg | \
        dd of=/usr/share/keyrings/githubcli-archive-keyring.gpg
    echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" | \
        tee /etc/apt/sources.list.d/github-cli.list
    apt update
    apt install -y gh
    
    # Languages and tools
    apt install -y \
        golang-go \
        rustc cargo \
        default-jdk \
        cmake \
        ansible
    
    success "Development tools installed"
}

# --- Remote Access ---
install_remote_access() {
    if [ "$INSTALL_REMOTE" != "true" ]; then
        return
    fi
    
    log "Installing remote access tools..."
    
    # Cockpit
    apt install -y cockpit cockpit-machines cockpit-podman
    systemctl enable --now cockpit.socket
    
    # X2Go Server
    add-apt-repository -y ppa:x2go/stable
    apt update
    apt install -y x2goserver x2goserver-xsession
    
    # TigerVNC
    apt install -y tigervnc-standalone-server tigervnc-common
    
    success "Remote access tools installed"
}

# --- Monitoring Module ---
install_monitoring() {
    if [ "$INSTALL_MONITORING" != "true" ]; then
        return
    fi
    
    log "Installing monitoring tools..."
    
    # Netdata
    bash <(curl -Ss https://my-netdata.io/kickstart.sh) --dont-wait
    
    # Performance monitoring
    apt install -y \
        htop btop \
        iotop \
        nethogs \
        mangohud goverlay
    
    # GPU monitoring
    apt install -y nvtop
    
    success "Monitoring tools installed"
}

# --- Backup Module ---
install_backup() {
    if [ "$INSTALL_BACKUP" != "true" ]; then
        return
    fi
    
    log "Installing backup tools..."
    
    apt install -y \
        timeshift \
        duplicity \
        rclone \
        restic \
        borgbackup
    
    # Configure Timeshift
    timeshift --create --comments "Initial installation" --yes
    
    success "Backup tools installed"
}

# --- Database Setup ---
setup_database() {
    log "Setting up MariaDB database..."
    
    systemctl start mariadb
    systemctl enable mariadb
    
    # Secure installation
    mysql -e "DELETE FROM mysql.user WHERE User='';"
    mysql -e "DELETE FROM mysql.user WHERE User='root' AND Host NOT IN ('localhost', '127.0.0.1', '::1');"
    mysql -e "DROP DATABASE IF EXISTS test;"
    mysql -e "DELETE FROM mysql.db WHERE Db='test' OR Db='test\\_%';"
    
    # Create database and user
    mysql -e "CREATE DATABASE IF NOT EXISTS $DB_NAME CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;"
    mysql -e "CREATE USER IF NOT EXISTS '$DB_USER'@'localhost' IDENTIFIED BY '$DB_PASS';"
    mysql -e "GRANT ALL PRIVILEGES ON $DB_NAME.* TO '$DB_USER'@'localhost';"
    mysql -e "FLUSH PRIVILEGES;"
    
    # Save credentials
    cat > "$CONFIG_DIR/database.conf" << EOF
DB_HOST=localhost
DB_PORT=3306
DB_NAME=$DB_NAME
DB_USER=$DB_USER
DB_PASS=$DB_PASS
EOF
    chmod 600 "$CONFIG_DIR/database.conf"
    
    success "Database configured"
}

# --- Firewall Configuration ---
configure_firewall() {
    log "Configuring firewall..."
    
    ufw --force reset
    ufw default deny incoming
    ufw default allow outgoing
    
    # Essential ports
    ufw allow 22/tcp comment "SSH"
    ufw allow 80/tcp comment "HTTP"
    ufw allow 443/tcp comment "HTTPS"
    ufw allow $API_PORT/tcp comment "GameHub API"
    ufw allow $WS_PORT/tcp comment "WebSocket"
    ufw allow $COCKPIT_PORT/tcp comment "Cockpit"
    ufw allow $NETDATA_PORT/tcp comment "Netdata"
    
    # Gaming ports
    ufw allow 25565/tcp comment "Minecraft"
    ufw allow 27015/tcp comment "Steam/CS"
    ufw allow 7777/tcp comment "ARK/Terraria"
    
    echo "y" | ufw enable
    
    success "Firewall configured"
}

# --- Create Systemd Service ---
create_systemd_service() {
    log "Creating systemd service..."
    
    cat > /etc/systemd/system/gamehub.service << EOF
[Unit]
Description=GameHub Gaming Server
After=network.target mariadb.service redis.service

[Service]
Type=simple
User=$USER_NAME
WorkingDirectory=$INSTALL_DIR
ExecStart=/usr/bin/node $INSTALL_DIR/index.js
Restart=always
RestartSec=10
StandardOutput=append:$LOG_DIR/gamehub.log
StandardError=append:$LOG_DIR/gamehub-error.log

[Install]
WantedBy=multi-user.target
EOF
    
    systemctl daemon-reload
    systemctl enable gamehub.service
    
    success "Systemd service created"
}

# --- Final Configuration ---
finalize_installation() {
    log "Finalizing installation..."
    
    # Create module status file
    cat > "$INSTALL_DIR/module-status.json" << EOF
{
  "version": "$GAMEHUB_VERSION",
  "installed": "$(date -Iseconds)",
  "modules": {
    "core": $INSTALL_CORE,
    "emulators": $INSTALL_EMULATORS,
    "steam": $INSTALL_STEAM,
    "dev": $INSTALL_DEV,
    "remote": $INSTALL_REMOTE,
    "monitoring": $INSTALL_MONITORING,
    "backup": $INSTALL_BACKUP,
    "dashboard": $INSTALL_DASHBOARD
  }
}
EOF
    
    # Generate access info
    SERVER_IP=$(hostname -I | awk '{print $1}')
    
    cat > "$INSTALL_DIR/ACCESS_INFO.txt" << EOF
╔══════════════════════════════════════════════════════════════╗
║           GameHub Gaming Server - Access Information         ║
╚══════════════════════════════════════════════════════════════╝

Server IP: $SERVER_IP

Web Interfaces:
  • Cockpit:    https://$SERVER_IP:$COCKPIT_PORT
  • Netdata:    http://$SERVER_IP:$NETDATA_PORT
  • Dashboard:  http://$SERVER_IP:$WEB_PORT

API:
  • REST API:   http://$SERVER_IP:$API_PORT
  • WebSocket:  ws://$SERVER_IP:$WS_PORT

SSH Access:
  ssh $USER_NAME@$SERVER_IP

Database:
  Host: localhost
  Database: $DB_NAME
  User: $DB_USER
  Password: (stored in $CONFIG_DIR/database.conf)

Logs:
  • Installation: $LOG_DIR/installation.log
  • Runtime:      $LOG_DIR/gamehub.log

Commands:
  • Status:  sudo systemctl status gamehub
  • Start:   sudo systemctl start gamehub
  • Stop:    sudo systemctl stop gamehub
  • Restart: sudo systemctl restart gamehub
  • Logs:    sudo journalctl -u gamehub -f

Module Management:
  $INSTALL_DIR/modules/manage-modules.sh

Documentation:
  $INSTALL_DIR/docs/

╔══════════════════════════════════════════════════════════════╗
EOF
    
    cat "$INSTALL_DIR/ACCESS_INFO.txt"
    
    success "Installation complete!"
}

# --- Main Installation Flow ---
main() {
    print_banner
    
    # Create log directory first
    mkdir -p "$LOG_DIR"
    
    check_environment
    create_directories
    update_system
    select_modules
    
    install_core
    install_emulators
    install_steam
    install_dev_tools
    install_remote_access
    install_monitoring
    install_backup
    
    setup_database
    configure_firewall
    create_systemd_service
    finalize_installation
    
    echo ""
    echo -e "${GREEN}${BOLD}╔══════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${GREEN}${BOLD}║  Installation successful! GameHub is ready to use.           ║${NC}"
    echo -e "${GREEN}${BOLD}║  Access info saved to: $INSTALL_DIR/ACCESS_INFO.txt${NC}"
    echo -e "${GREEN}${BOLD}╚══════════════════════════════════════════════════════════════╝${NC}"
    echo ""
}

# Run installation
main "$@"
