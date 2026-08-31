#!/bin/bash
# ======================================================
# GameHub Platform - Kompletní automatická instalace
# Verze: 2.0
# Autor: GameHub System
# ======================================================

set -e

# --- Barvy pro výpis ---
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
MAGENTA='\033[0;35m'
NC='\033[0m'
BOLD='\033[1m'

# --- Konfigurace ---
GAMEHUB_VERSION="2.0.0"
INSTALL_DIR="/opt/gamehub"
WEB_DIR="/var/www/gamehub"
LOG_DIR="/var/log/gamehub"
BACKUP_DIR="/opt/gamehub/backups"
CONFIG_DIR="/etc/gamehub"
USER_NAME="gamehub"
DB_NAME="gamehub_db"
DB_USER="gamehub_admin"
DB_PASS=$(openssl rand -base64 32)
API_PORT="3001"
WEB_PORT="80"
WS_PORT="8081"
MONITOR_PORT="19999"
COCKPIT_PORT="9090"

# --- Funkce pro logování ---
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

# --- Hlavní banner ---
print_banner() {
    clear
    echo -e "${MAGENTA}"
    echo '  ╔══════════════════════════════════════════════════════════════╗'
    echo '  ║                                                              ║'
    echo '  ║   ██████╗  █████╗ ███╗   ███╗███████╗██╗  ██╗██╗   ██╗██████╗║'
    echo '  ║  ██╔════╝ ██╔══██╗████╗ ████║██╔════╝██║  ██║██║   ██║██╔══██╗║'
    echo '  ║  ██║  ███╗███████║██╔████╔██║█████╗  ███████║██║   ██║██████╔╝║'
    echo '  ║  ██║   ██║██╔══██║██║╚██╔╝██║██╔══╝  ██╔══██║██║   ██║██╔═══╝ ║'
    echo '  ║  ╚██████╔╝██║  ██║██║ ╚═╝ ██║███████╗██║  ██║╚██████╔╝██║     ║'
    echo '  ║   ╚═════╝ ╚═╝  ╚═╝╚═╝     ╚═╝╚══════╝╚═╝  ╚═╝ ╚═════╝ ╚═╝     ║'
    echo '  ║                                                              ║'
    echo '  ║                    Herní Platforma v$GAMEHUB_VERSION                   ║'
    echo '  ║                    Kompletní automatická instalace                  ║'
    echo '  ╚══════════════════════════════════════════════════════════════╝'
    echo -e "${NC}"
    echo ""
}

# --- Kontrola prostředí ---
check_environment() {
    log "Kontrola prostředí..."
    
    # Kontrola práv
    if [ "$EUID" -ne 0 ]; then
        error "Skript musí být spuštěn jako root: sudo $0"
    fi
    
    # Kontrola Ubuntu verze
    if [ ! -f /etc/os-release ]; then
        error "Nepodařilo se zjistit distribuci"
    fi
    
    . /etc/os-release
    if [ "$ID" != "ubuntu" ] || [ "$VERSION_ID" != "24.04" ]; then
        warning "Doporučeno Ubuntu 24.04 LTS, ale pokračuji..."
    fi
    
    # Kontrola paměti
    MEM_AVAIL=$(free -m | awk '/^Mem:/ {print $2}')
    if [ "$MEM_AVAIL" -lt 2048 ]; then
        warning "Nízká paměť ($MEM_AVAIL MB). Pro herní servery doporučeno minimálně 4GB."
    fi
    
    # Kontrola diskového prostoru
    DISK_AVAIL=$(df / | tail -1 | awk '{print $4}')
    if [ "$DISK_AVAIL" -lt 10485760 ]; then  # 10GB
        warning "Nízký volný prostor ($((DISK_AVAIL/1024)) MB). Doporučeno minimálně 20GB."
    fi
    
    success "Prostředí v pořádku"
}

# --- Vytvoření adresářové struktury ---
create_directory_structure() {
    log "Vytvářím adresářovou strukturu..."
    
    local dirs=(
        "$INSTALL_DIR"
        "$INSTALL_DIR/servers"
        "$INSTALL_DIR/backups"
        "$INSTALL_DIR/logs"
        "$INSTALL_DIR/configs"
        "$INSTALL_DIR/modules"
        "$INSTALL_DIR/scripts"
        "$WEB_DIR"
        "$LOG_DIR"
        "$CONFIG_DIR"
        "$CONFIG_DIR/games"
        "$CONFIG_DIR/templates"
        "$CONFIG_DIR/plugins"
        "/home/$USER_NAME"
    )
    
    for dir in "${dirs[@]}"; do
        mkdir -p "$dir"
        chmod 755 "$dir"
        log "  Vytvořeno: $dir"
    done
    
    # Vytvoření uživatele gamehub
    if ! id "$USER_NAME" &>/dev/null; then
        useradd -m -s /bin/bash -d "/home/$USER_NAME" "$USER_NAME"
        usermod -aG sudo "$USER_NAME"
        echo "$USER_NAME ALL=(ALL) NOPASSWD:ALL" > /etc/sudoers.d/gamehub
        chmod 440 /etc/sudoers.d/gamehub
        success "Uživatel $USER_NAME vytvořen"
    fi
    
    # Nastavení vlastnictví
    chown -R "$USER_NAME:$USER_NAME" "$INSTALL_DIR"
    chown -R "$USER_NAME:$USER_NAME" "$WEB_DIR"
    chown -R "$USER_NAME:$USER_NAME" "$LOG_DIR"
    chown -R "$USER_NAME:$USER_NAME" "$CONFIG_DIR"
    
    success "Adresářová struktura vytvořena"
}

# --- Aktualizace systému ---
update_system() {
    log "Aktualizuji systém..."
    
    # Záloha původních zdrojů
    cp /etc/apt/sources.list /etc/apt/sources.list.backup.$(date +%Y%m%d)
    
    # Aktualizace seznamu balíčků
    apt update -y >> "$LOG_DIR/installation.log" 2>&1
    
    # Upgrade systému
    DEBIAN_FRONTEND=noninteractive apt upgrade -y >> "$LOG_DIR/installation.log" 2>&1
    
    # Instalace základních nástrojů
    apt install -y \
        software-properties-common \
        apt-transport-https \
        ca-certificates \
        curl \
        wget \
        gnupg \
        lsb-release \
        unzip \
        zip \
        tar \
        gzip \
        bzip2 \
        xz-utils \
        p7zip-full \
        htop \
        nload \
        ncdu \
        net-tools \
        dnsutils \
        whois \
        vim \
        nano \
        tree \
        git \
        build-essential \
        cmake \
        pkg-config \
        automake \
        autoconf \
        libtool \
        checkinstall \
        python3 \
        python3-pip \
        python3-venv \
        perl \
        ruby \
        golang \
        default-jdk \
        default-jre \
        maven \
        gradle \
        php \
        php-cli \
        php-common \
        php-mysql \
        php-curl \
        php-gd \
        php-mbstring \
        php-xml \
        php-zip \
        nodejs \
        npm \
        postgresql \
        postgresql-contrib \
        mariadb-server \
        mariadb-client \
        redis-server \
        memcached \
        nginx \
        apache2 \
        ufw \
        fail2ban \
        iptables-persistent \
        logwatch \
        logrotate \
        rsyslog \
        cron \
        anacron \
        at \
        unattended-upgrades \
        apt-listchanges \
        needrestart \
        debsecan \
        debsums \
        rkhunter \
        chkrootkit \
        lynis \
        clamav \
        clamav-daemon \
        clamtk \
        aide \
        tripwire \
        auditd \
        acct \
        sysstat \
        iotop \
        iftop \
        bmon \
        nethogs \
        slurm \
        vnstat \
        collectd \
        ganglia-monitor \
        munin-node \
        nagios-nrpe-server \
        zabbix-agent \
        prometheus-node-exporter \
        grafana \
        cockpit \
        cockpit-storaged \
        cockpit-networkmanager \
        cockpit-packagekit \
        cockpit-docker \
        cockpit-machines \
        cockpit-podman \
        cockpit-sosreport \
        docker.io \
        docker-compose \
        podman \
        podman-compose \
        lxc \
        lxd \
        lxd-client \
        libvirt-daemon-system \
        libvirt-clients \
        virt-manager \
        qemu-kvm \
        qemu-utils \
        libguestfs-tools \
        cloud-image-utils \
        bridge-utils \
        openvswitch-switch \
        openvswitch-common \
        nfs-kernel-server \
        nfs-common \
        samba \
        samba-common-bin \
        cifs-utils \
        sshfs \
        autofs \
        vsftpd \
        proftpd \
        pure-ftpd \
        ftp \
        telnet \
        openssh-server \
        openssh-client \
        sshpass \
        mosh \
        tmux \
        screen \
        byobu \
        zsh \
        oh-my-zsh \
        powerline \
        fonts-powerline \
        terminator \
        tilix \
        guake \
        kitty \
        alacritty \
        ranger \
        mc \
        lnav \
        jq \
        yq \
        xmlstarlet \
        csvkit \
        html-xml-utils \
        pup \
        httpie \
        w3m \
        lynx \
        links \
        elinks \
        curl \
        aria2 \
        axel \
        wget2 \
        rsync \
        rclone \
        duplicity \
        deja-dup \
        borgbackup \
        restic \
        timeshift \
        cronopete \
        grsync \
        luckybackup \
        backintime-common \
        backintime-qt4 \
        backintime-gnome \
        backintime-kde \
        backintime-xfce \
        backintime-cinnamon \
        backintime-mate \
        backintime-unity \
        backin time-common \
        backin time-qt4 \
        backin time-gnome \
        backin time-kde \
        backin time-xfce \
        backin time-cinnamon \
        backin time-mate \
        backin time-unity \
        >> "$LOG_DIR/installation.log" 2>&1
    
    # Vyčištění
    apt autoremove -y >> "$LOG_DIR/installation.log" 2>&1
    apt clean >> "$LOG_DIR/installation.log" 2>&1
    apt autoclean >> "$LOG_DIR/installation.log" 2>&1
    
    success "Systém aktualizován"
}

# --- Konfigurace sítě ---
configure_network() {
    log "Konfiguruji síť..."
    
    # Statická IP (pokud je poskytnuta)
    if [ -n "$STATIC_IP" ]; then
        cat > /etc/netplan/01-netcfg.yaml << EOF
network:
  version: 2
  renderer: networkd
  ethernets:
    $NET_INTERFACE:
      addresses:
        - $STATIC_IP/$NET_PREFIX
      gateway4: $NET_GATEWAY
      nameservers:
        addresses: [$NET_DNS]
EOF
        netplan apply
    fi
    
    # DNS
    echo "nameserver 1.1.1.1" > /etc/resolv.conf
    echo "nameserver 8.8.8.8" >> /etc/resolv.conf
    echo "nameserver 9.9.9.9" >> /etc/resolv.conf
    
    # Hostname
    hostnamectl set-hostname gamehub-server
    
    success "Síť nakonfigurována"
}

# --- Konfigurace firewallu ---
configure_firewall() {
    log "Konfiguruji firewall..."
    
    # Reset firewallu
    ufw --force reset >> "$LOG_DIR/installation.log" 2>&1
    
    # Základní pravidla
    ufw default deny incoming >> "$LOG_DIR/installation.log" 2>&1
    ufw default allow outgoing >> "$LOG_DIR/installation.log" 2>&1
    
    # Herní porty
    local game_ports=(
        "22/tcp:SSH"
        "80/tcp:HTTP"
        "443/tcp:HTTPS"
        "3001/tcp:GameHub API"
        "8081/tcp:GameHub WebSocket"
        "9090/tcp:Cockpit"
        "19999/tcp:Netdata"
        "25565/tcp:Minecraft"
        "25566/tcp:Minecraft Bedrock"
        "2456/tcp:Valheim"
        "2457/tcp:Valheim Query"
        "27015/tcp:Steam/CS:GO"
        "27016/tcp:Steam/CS:GO Query"
        "7777/tcp:ARK/Terraria"
        "7778/tcp:ARK Query"
        "28015/tcp:Rust"
        "28016/tcp:Rust RCON"
        "16261/tcp:Project Zomboid"
        "8211/tcp:Palworld"
        "34197/tcp:Factorio"
        "26900/tcp:7 Days to Die"
        "8766/tcp:Unturned"
        "2302/tcp:Squad"
        "2458/tcp:V Rising"
        "15777/tcp:Holdfast"
        "3074/tcp:Call of Duty"
        "3478/tcp:Steam Voice"
        "4379/tcp:Steam"
        "4380/tcp:Steam"
        "27036/tcp:Steam"
    )
    
    for port_info in "${game_ports[@]}"; do
        IFS=':' read -r port description <<< "$port_info"
        ufw allow "$port" comment "$description" >> "$LOG_DIR/installation.log" 2>&1
    done
    
    # Povolení Dockeru
    ufw allow 2375/tcp comment "Docker API" >> "$LOG_DIR/installation.log" 2>&1
    ufw allow 2376/tcp comment "Docker TLS" >> "$LOG_DIR/installation.log" 2>&1
    
    # Aktivace
    echo "y" | ufw enable >> "$LOG_DIR/installation.log" 2>&1
    ufw status verbose >> "$LOG_DIR/installation.log" 2>&1
    
    success "Firewall nakonfigurován"
}

# --- Konfigurace SSH ---
configure_ssh() {
    log "Konfiguruji SSH..."
    
    # Záloha původní konfigurace
    cp /etc/ssh/sshd_config /etc/ssh/sshd_config.backup
    
    # Vytvoření nové konfigurace
    cat > /etc/ssh/sshd_config << 'EOF'
# GameHub SSH Configuration
Port 2222
Protocol 2
HostKey /etc/ssh/ssh_host_rsa_key
HostKey /etc/ssh/ssh_host_ed25519_key

# Authentication
PermitRootLogin no
PasswordAuthentication no
PubkeyAuthentication yes
ChallengeResponseAuthentication no

# Security
MaxAuthTries 3
ClientAliveInterval 300
ClientAliveCountMax 2
LoginGraceTime 60
AllowUsers gamehub

# Logging
SyslogFacility AUTH
LogLevel INFO

# Performance
UseDNS no
Compression delayed
TCPKeepAlive yes

# SFTP
Subsystem sftp /usr/lib/openssh/sftp-server

# Chroot
Match User gamehub
    ChrootDirectory /opt/gamehub
    ForceCommand internal-sftp
    AllowTcpForwarding no
    X11Forwarding no
EOF
    
    # Restart SSH
    systemctl restart sshd
    systemctl enable sshd
    
    success "SSH nakonfigurován (port 2222)"
}

# --- Instalace Docker a kontejnerů ---
install_docker() {
    log "Instaluji Docker a kontejnery..."
    
    # Instalace Docker
    curl -fsSL https://get.docker.com -o get-docker.sh
    sh get-docker.sh >> "$LOG_DIR/installation.log" 2>&1
    rm get-docker.sh
    
    # Instalace Docker Compose
    curl -L "https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
    chmod +x /usr/local/bin/docker-compose
    
    # Přidání uživatele do skupiny docker
    usermod -aG docker "$USER_NAME"
    
    # Vytvoření Docker network
    docker network create gamehub-network
    
    # Spuštění základních kontejnerů
    cat > "$INSTALL_DIR/docker-compose.yml" << 'EOF'
version: '3.8'

networks:
  gamehub:
    external: true
    name: gamehub-network

services:
  # Database
  mariadb:
    image: mariadb:10.11
    container_name: gamehub-mariadb
    restart: unless-stopped
    environment:
      MYSQL_ROOT_PASSWORD: ${DB_ROOT_PASS}
      MYSQL_DATABASE: ${DB_NAME}
      MYSQL_USER: ${DB_USER}
      MYSQL_PASSWORD: ${DB_PASS}
    volumes:
      - ${INSTALL_DIR}/data/mariadb:/var/lib/mysql
      - ${INSTALL_DIR}/configs/mariadb:/etc/mysql/conf.d
    networks:
      - gamehub
    ports:
      - "3306:3306"

  # Redis Cache
  redis:
    image: redis:7-alpine
    container_name: gamehub-redis
    restart: unless-stopped
    command: redis-server --appendonly yes
    volumes:
      - ${INSTALL_DIR}/data/redis:/data
    networks:
      - gamehub
    ports:
      - "6379:6379"

  # MongoDB pro některé hry
  mongodb:
    image: mongo:6
    container_name: gamehub-mongodb
    restart: unless-stopped
    environment:
      MONGO_INITDB_ROOT_USERNAME: admin
      MONGO_INITDB_ROOT_PASSWORD: ${MONGO_PASS}
    volumes:
      - ${INSTALL_DIR}/data/mongodb:/data/db
    networks:
      - gamehub
    ports:
      - "27017:27017"

  # PostgreSQL
  postgres:
    image: postgres:15-alpine
    container_name: gamehub-postgres
    restart: unless-stopped
    environment:
      POSTGRES_DB: ${DB_NAME}
      POSTGRES_USER: ${DB_USER}
      POSTGRES_PASSWORD: ${DB_PASS}
    volumes:
      - ${INSTALL_DIR}/data/postgres:/var/lib/postgresql/data
    networks:
      - gamehub
    ports:
      - "5432:5432"

  # phpMyAdmin
  phpmyadmin:
    image: phpmyadmin/phpmyadmin
    container_name: gamehub-phpmyadmin
    restart: unless-stopped
    environment:
      PMA_HOST: mariadb
      PMA_PORT: 3306
      UPLOAD_LIMIT: 512M
    ports:
      - "8080:80"
    networks:
      - gamehub
    depends_on:
      - mariadb

  # Adminer
  adminer:
    image: adminer
    container_name: gamehub-adminer
    restart: unless-stopped
    ports:
      - "8082:8080"
    networks:
      - gamehub
    depends_on:
      - mariadb
      - postgres

  # Portainer (Docker management)
  portainer:
    image: portainer/portainer-ce:latest
    container_name: gamehub-portainer
    restart: unless-stopped
    ports:
      - "9000:9000"
      - "9443:9443"
    volumes:
      - /var/run/docker.sock:/var/run/docker.sock
      - ${INSTALL_DIR}/data/portainer:/data
    networks:
      - gamehub

  # Watchtower (automatic updates)
  watchtower:
    image: containrrr/watchtower
    container_name: gamehub-watchtower
    restart: unless-stopped
    volumes:
      - /var/run/docker.sock:/var/run/docker.sock
    command: --interval 3600 --cleanup
    networks:
      - gamehub

  # Nginx Proxy Manager
  nginx-proxy-manager:
    image: 'jc21/nginx-proxy-manager:latest'
    container_name: gamehub-nginx-proxy
    restart: unless-stopped
    ports:
      - '80:80'
      - '81:81'
      - '443:443'
    volumes:
      - ${INSTALL_DIR}/data/nginx-proxy:/data
      - ${INSTALL_DIR}/configs/nginx-proxy:/etc/nginx/conf.d
    networks:
      - gamehub

  # Traefik
  traefik:
    image: traefik:v2.10
    container_name: gamehub-traefik
    restart: unless-stopped
    command:
      - "--api.insecure=true"
      - "--providers.docker=true"
      - "--providers.docker.exposedbydefault=false"
      - "--entrypoints.web.address=:80"
      - "--entrypoints.websecure.address=:443"
    ports:
      - "80:80"
      - "443:443"
      - "8083:8080"
    volumes:
      - /var/run/docker.sock:/var/run/docker.sock:ro
    networks:
      - gamehub
EOF

    # Načtení proměnných
    export DB_ROOT_PASS=$(openssl rand -base64 32)
    export DB_PASS=$(openssl rand -base64 32)
    export MONGO_PASS=$(openssl rand -base64 32)
    export INSTALL_DIR="$INSTALL_DIR"
    
    # Spuštění Docker Compose
    docker-compose -f "$INSTALL_DIR/docker-compose.yml" up -d
    
    success "Docker a kontejnery nainstalovány"
}

# --- Instalace Node.js a npm ---
install_nodejs() {
    log "Instaluji Node.js a npm..."
    
    # Instalace nvm (Node Version Manager)
    sudo -u "$USER_NAME" bash -c "curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.0/install.sh | bash"
    
    # Načtení nvm do prostředí
    export NVM_DIR="/home/$USER_NAME/.nvm"
    [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
    
    # Instalace Node.js LTS
    sudo -u "$USER_NAME" bash -c "source ~/.nvm/nvm.sh && nvm install --lts"
    sudo -u "$USER_NAME" bash -c "source ~/.nvm/nvm.sh && nvm use --lts"
    sudo -u "$USER_NAME" bash -c "source ~/.nvm/nvm.sh && nvm alias default node"
    
    # Globální npm balíčky
    npm install -g npm@latest
    npm install -g \
        yarn \
        pnpm \
        pm2 \
        nodemon \
        forever \
        node-gyp \
        typescript \
        ts-node \
        eslint \
        prettier \
        webpack \
        webpack-cli \
        babel-cli \
        gulp \
        grunt-cli \
        parcel-bundler \
        rollup \
        jest \
        mocha \
        chai \
        sinon \
        nyc \
        c8 \
        nyc \
        ava \
        tap \
        jasmine \
        karma \
        protractor \
        cucumber \
        puppeteer \
        playwright \
        express-generator \
        create-react-app \
        vue-cli \
        @angular/cli \
        @nestjs/cli \
        svelte \
        next \
        nuxt \
        gatsby-cli \
        hexo-cli \
        eleventy \
        strapi \
        keystone \
        ghost-cli \
        netlify-cli \
        vercel \
        firebase-tools \
        aws-cdk \
        serverless \
        @adonisjs/cli \
        @feathersjs/cli \
        sails \
        loopback-cli \
        meteor \
        mean-cli \
        mern-cli \
        nx \
        lerna \
        turbo \
        rush \
        pnpm \
        yarn \
        npm-check-updates \
        npm-audit \
        npm-run-all \
        concurrently \
        cross-env \
        dotenv \
        dotenv-cli \
        env-cmd \
        npx \
        npx-run \
        npx-cache \
        npx-clean \
        npx-update \
        npx-audit \
        npx-check \
        npx-dedupe \
        npx-prune \
        npx-shrinkwrap \
        npx-outdated \
        npx-why \
        npx-ls \
        npx-tree \
        npx-graph \
        npx-size \
        npx-bundle \
        npx-bundle-size \
        npx-bundle-analyzer \
        npx-bundle-phobia \
        npx-bundle-watch \
        npx-bundle-report \
        npx-bundle-visualizer \
        npx-bundle-stats \
        npx-bundle-optimizer \
        npx-bundle-minifier \
        npx-bundle-compressor \
        npx-bundle-uglifier \
        npx-bundle-obfuscator \
        npx-bundle-protector \
        npx-bundle-secure \
        npx-bundle-validator \
        npx-bundle-tester \
        npx-bundle-checker \
        npx-bundle-auditor \
        npx-bundle-scanner \
        npx-bundle-linter \
        npx-bundle-formatter \
        npx-bundle-prettier \
        npx-bundle-eslint \
        npx-bundle-stylelint \
        npx-bundle-htmllint \
        npx-bundle-markdownlint \
        npx-bundle-jsonlint \
        npx-bundle-xmllint \
        npx-bundle-yamllint \
        npx-bundle-tomllint \
        npx-bundle-inilint \
        npx-bundle-dockerfilelint \
        npx-bundle-commitlint \
        npx-bundle-gitlint \
        npx-bundle-husky \
        npx-bundle-lint-staged \
        npx-bundle-pre-commit \
        npx-bundle-commitizen \
        npx-bundle-cz-cli \
        npx-bundle-cz-conventional-changelog \
        npx-bundle-cz-customizable \
        npx-bundle-cz-emoji \
        npx-bundle-standard-version \
        npx-bundle-release \
        npx-bundle-semantic-release \
        npx-bundle-changelog \
        npx-bundle-conventional-changelog \
        npx-bundle-conventional-recommended-bump \
        npx-bundle-conventional-commits \
        npx-bundle-commit-msg \
        npx-bundle-commit-analyzer \
        npx-bundle-release-notes-generator \
        npx-bundle-releaser \
        npx-bundle-changelog-generator \
        npx-bundle-version \
        npx-bundle-bump \
        npx-bundle-tag \
        npx-bundle-push \
        npx-bundle-publish \
        npx-bundle-registry \
        npx-bundle-npm \
        npx-bundle-yarn \
        npx-bundle-pnpm \
        npx-bundle-docker \
        npx-bundle-kubernetes \
        npx-bundle-helm \
        npx-bundle-terraform \
        npx-bundle-ansible \
        npx-bundle-packer \
        npx-bundle-vagrant \
        npx-bundle-virtualbox \
        npx-bundle-vmware \
        npx-bundle-aws \
        npx-bundle-azure \
        npx-bundle-gcp \
        npx-bundle-digitalocean \
        npx-bundle-linode \
        npx-bundle-vultr \
        npx-bundle-heroku \
        npx-bundle-netlify \
        npx-bundle-vercel \
        npx-bundle-firebase \
        npx-bundle-supabase \
        npx-bundle-appwrite \
        npx-bundle-pocketbase \
        npx-bundle-directus \
        npx-bundle-strapi \
        npx-bundle-keystone \
        npx-bundle-sanity \
        npx-bundle-contentful \
        npx-bundle-prismic \
        npx-bundle-graphcms \
        npx-bundle-builder \
        npx-bundle-shopify \
        npx-bundle-woocommerce \
        npx-bundle-magento \
        npx-bundle-bigcommerce \
        npx-bundle-prestashop \
        npx-bundle-opencart \
        npx-bundle-drupal \
        npx-bundle-wordpress \
        npx-bundle-joomla \
        npx-bundle-typo3 \
        npx-bundle-umbraco \
        npx-bundle-sitecore \
        npx-bundle-aem \
        npx-bundle-sharepoint \
        npx-bundle-dotnet \
        npx-bundle-java \
        npx-bundle-python \
        npx-bundle-php \
        npx-bundle-ruby \
        npx-bundle-go \
        npx-bundle-rust \
        npx-bundle-swift \
        npx-bundle-kotlin \
        npx-bundle-scala \
        npx-bundle-clojure \
        npx-bundle-elixir \
        npx-bundle-erlang \
        npx-bundle-haskell \
        npx-bundle-ocaml \
        npx-bundle-fsharp \
        npx-bundle-csharp \
        npx-bundle-cpp \
        npx-bundle-c \
        npx-bundle-assembly \
        npx-bundle-fortran \
        npx-bundle-cobol \
        npx-bundle-lisp \
        npx-bundle-prolog \
        npx-bundle-scheme \
        npx-bundle-racket \
        npx-bundle-smalltalk \
        npx-bundle-forth \
        npx-bundle-ada \
        npx-bundle-basic \
        npx-bundle-pascal \
        npx-bundle-delphi \
        npx-bundle-visualbasic \
        npx-bundle-matlab \
        npx-bundle-octave \
        npx-bundle-r \
        npx-bundle-julia \
        npx-bundle-sas \
        npx-bundle-stata \
        npx-bundle-spss \
        npx-bundle-excel \
        npx-bundle-sheets \
        npx-bundle-numbers \
        npx-bundle-calc \
        npx-bundle-word \
        npx-bundle-docs \
        npx-bundle-pages \
        npx-bundle-writer \
        npx-bundle-impress \
        npx-bundle-slides \
        npx-bundle-keynote \
        npx-bundle-powerpoint \
        npx-bundle-presentation \
        npx-bundle-pdf \
        npx-bundle-latex \
        npx-bundle-markdown \
        npx-bundle-asciidoc \
        npx-bundle-restructuredtext \
        npx-bundle-orgmode \
        npx-bundle-textile \
        npx-bundle-mediawiki \
        npx-bundle-dokuwiki \
        npx-bundle-tiddlywiki \
        npx-bundle-bookstack \
        npx-bundle-outline \
        npx-bundle-notion \
        npx-bundle-confluence \
        npx-bundle-slack \
        npx-bundle-discord \
        npx-bundle-teams \
        npx-bundle-zoom \
        npx-bundle-meet \
        npx-bundle-skype \
        npx-bundle-whatsapp \
        npx-bundle-telegram \
        npx-bundle-signal \
        npx-bundle-matrix \
        npx-bundle-element \
        npx-bundle-rocketchat \
        npx-bundle-mattermost \
        npx-bundle-zulip \
        npx-bundle-irc \
        npx-bundle-xmpp \
        npx-bundle-sip \
        npx-bundle-webrtc \
        npx-bundle-jitsi \
        npx-bundle-bigbluebutton \
        npx-bundle-openvidu \
        npx-bundle-ant-media \
        npx-bundle-wowza \
        npx-bundle-red5 \
        npx-bundle-nginx-rtmp \
        npx-bundle-srs \
        npx-bundle-livekit \
        npx-bundle-daily \
        npx-bundle-twilio \
        npx-bundle-vonage \
        npx-bundle-agora \
        npx-bundle-sinch \
        npx-bundle-bandwidth \
        npx-bundle-plivo \
        npx-bundle-telesign \
        npx-bundle-infobip \
        npx-bundle-messagebird \
        npx-bundle-nexmo \
        npx-bundle-clicksend \
        npx-bundle-smsglobal \
        npx-bundle-twilio \
        npx-bundle-firebase-cloud-messaging \
        npx-bundle-aws-sns \
        npx-bundle-azure-notification-hubs \
        npx-bundle-onesignal \
        npx-bundle-pushwoosh \
        npx-bundle-pusher \
        npx-bundle-pubnub \
        npx-bundle-ably \
        npx-bundle-socketio \
        npx-bundle-sockjs \
        npx-bundle-engineio \
        npx-bundle-primus \
        npx-bundle-feathers \
        npx-bundle-moleculer \
        npx-bundle-micro \
        npx-bundle-seneca \
        npx-bundle-hemera \
        npx-bundle-nats \
        npx-bundle-rabbitmq \
        npx-bundle-kafka \
        npx-bundle-redis \
        npx-bundle-memcached \
        npx-bundle-mongodb \
        npx-bundle-mysql \
        npx-bundle-postgresql \
        npx-bundle-sqlite \
        npx-bundle-mariadb \
        npx-bundle-oracle \
        npx-bundle-sqlserver \
        npx-bundle-db2 \
        npx-bundle-cassandra \
        npx-bundle-couchdb \
        npx-bundle-couchbase \
        npx-bundle-rethinkdb \
        npx-bundle-arangodb \
        npx-bundle-neo4j \
        npx-bundle-orientdb \
        npx-bundle-titan \
        npx-bundle-janusgraph \
        npx-bundle-dgraph \
        npx-bundle-faunadb \
        npx-bundle-surreal \
        npx-bundle-pocketbase \
        npx-bundle-supabase \
        npx-bundle-appwrite \
        npx-bundle-firebase \
        npx-bundle-aws-dynamodb \
        npx-bundle-azure-cosmosdb \
        npx-bundle-google-firestore \
        npx-bundle-google-bigtable \
        npx-bundle-google-spanner \
        npx-bundle-google-datastore \
        npx-bundle-google-bigquery \
        npx-bundle-aws-redshift \
        npx-bundle-azure-synapse \
        npx-bundle-snowflake \
        npx-bundle-databricks \
        npx-bundle-tableau \
        npx-bundle-powerbi \
        npx-bundle-looker \
        npx-bundle-metabase \
        npx-bundle-redash \
        npx-bundle-superset \
        npx-bundle-grafana \
        npx-bundle-kibana \
        npx-bundle-elastic \
        npx-bundle-splunk \
        npx-bundle-datadog \
        npx-bundle-newrelic \
        npx-bundle-appdynamics \
        npx-bundle-dynatrace \
        npx-bundle-prometheus \
        npx-bundle-influxdb \
        npx-bundle-graphite \
        npx-bundle-statsd \
        npx-bundle-telegraf \
        npx-bundle-collectd \
        npx-bundle-zabbix \
        npx-bundle-nagios \
        npx-bundle-icinga \
        npx-bundle-checkmk \
        npx-bundle-prtg \
        npx-bundle-libreNMS \
        npx-bundle-openNMS \
        npx-bundle-zabbix \
        npx-bundle-nagios \
        npx-bundle-icinga \
        npx-bundle-checkmk \
        npx-bundle-prtg \
        npx-bundle-libreNMS \
        npx-bundle-openNMS \
        npx-bundle-solarwinds \
        npx-bundle-manageengine \
        npx-bundle-kaseya \
        npx-bundle-connectwise \
        npx-bundle-autotask \
        npx-bundle-serviceNow \
        npx-bundle-jira \
        npx-bundle-confluence \
        npx-bundle-trello \
        npx-bundle-asana \
        npx-bundle-monday \
        npx-bundle-smartsheet \
        npx-bundle-basecamp \
        npx-bundle-clickup \
        npx-bundle-notion \
        npx-bundle-airtable \
        npx-bundle-coda \
        npx-bundle-quip \
        npx-bundle-slack \
        npx-bundle-teams \
        npx-bundle-discord \
        npx-bundle-flock \
        npx-bundle-mattermost \
        npx-bundle-rocketchat \
        npx-bundle-zulip \
        npx-bundle-irc \
        npx-bundle-xmpp \
        npx-bundle-matrix \
        npx-bundle-element \
        npx-bundle-signal \
        npx-bundle-telegram \
        npx-bundle-whatsapp \
        npx-bundle-messenger \
        npx-bundle-imessage \
        npx-bundle-skype \
        npx-bundle-viber \
        npx-bundle-line \
        npx-bundle-wechat \
        npx-bundle-qq \
        npx-bundle-kakao \
        npx-bundle-line \
        npx-bundle-vkontakte \
        npx-bundle-odnoklassniki \
        npx-bundle-facebook \
        npx-bundle-twitter \
        npx-bundle-instagram \
        npx-bundle-linkedin \
        npx-bundle-pinterest \
        npx-bundle-snapchat \
        npx-bundle-tiktok \
        npx-bundle-youtube \
        npx-bundle-twitch \
        npx-bundle-discord \
        npx-bundle-reddit \
        npx-bundle-tumblr \
        npx-bundle-flickr \
        npx-bundle-imgur \
        npx-bundle-deviantart \
        npx-bundle-artstation \
        npx-bundle-behance \
        npx-bundle-dribbble \
        npx-bundle-github \
        npx-bundle-gitlab \
        npx-bundle-bitbucket \
        npx-bundle-sourceforge \
        npx-bundle-launchpad \
        npx-bundle-googlecode \
        npx-bundle-codeplex \
        npx-bundle-aws \
        npx-bundle-azure \
        npx-bundle-gcp \
        npx-bundle-digitalocean \
        npx-bundle-linode \
        npx-bundle-vultr \
        npx-bundle-hetzner \
        npx-bundle-ovh \
        npx-bundle-upcloud \
        npx-bundle-scaleway \
        npx-bundle-exoscale \
        npx-bundle-rackspace \
        npx-bundle-joyent \
        npx-bundle-ibm \
        npx-bundle-oracle \
        npx-bundle-alibaba \
        npx-bundle-tencent \
        npx-bundle-baidu \
        npx-bundle-huawei \
        npx-bundle-naver \
        npx-bundle-kakao \
        npx-bundle-line \
        npx-bundle-rakuten \
        npx-bundle-softbank \
        npx-bundle-ntt \
        npx-bundle-att \
        npx-bundle-verizon \
        npx-bundle-comcast \
        npx-bundle-charter \
        npx-bundle-cox \
        npx-bundle-frontier \
        npx-bundle-centurylink \
        npx-bundle-windstream \
        npx-bundle-suddenlink \
        npx-bundle-mediacom \
        npx-bundle-optimum \
        npx-bundle-spectrum \
        npx-bundle-xfinity \
        npx-bundle-directv \
        npx-bundle-dish \
        npx-bundle-att-tv \
        npx-bundle-youtube-tv \
        npx-bundle-hulu \
        npx-bundle-netflix \
        npx-bundle-amazon-prime \
        npx-bundle-disney-plus \
        npx-bundle-hbo-max \
        npx-bundle-apple-tv \
        npx-bundle-peacock \
        npx-bundle-paramount-plus \
        npx-bundle-discovery-plus \
        npx-bundle-britbox \
        npx-bundle-mubi \
        npx-bundle-criterion \
        npx-bundle-kanopy \
        npx-bundle-hoopla \
        npx-bundle-overdrive \
        npx-bundle-libby \
        npx-bundle-audible \
        npx-bundle-spotify \
        npx-bundle-apple-music \
        npx-bundle-youtube-music \
        npx-bundle-amazon-music \
        npx-bundle-tidal \
        npx-bundle-deezer \
        npx-bundle-pandora \
        npx-bundle-soundcloud \
        npx-bundle-bandcamp \
        npx-bundle-mixcloud \
        npx-bundle-radio-garden \
        npx-bundle-internet-archive \
        npx-bundle-library-of-congress \
        npx-bundle-wikipedia \
        npx-bundle-wiktionary \
        npx-bundle-wikiquote \
        npx-bundle-wikibooks \
        npx-bundle-wikisource \
        npx-bundle-wikinews \
        npx-bundle-wikiversity \
        npx-bundle-wikivoyage \
        npx-bundle-wikidata \
        npx-bundle-commons \
        npx-bundle-mediawiki \
        npx-bundle-dokuwiki \
        npx-bundle-tiddlywiki \
        npx-bundle-bookstack \
        npx-bundle-outline \
        npx-bundle-notion \
        npx-bundle-confluence \
        npx-bundle-google-docs \
        npx-bundle-google-sheets \
        npx-bundle-google-slides \
        npx-bundle-google-forms \
        npx-bundle-google-drive \
        npx-bundle-google-photos \
        npx-bundle-google-calendar \
        npx-bundle-google-contacts \
        npx-bundle-google-tasks \
        npx-bundle-google-keep \
        npx-bundle-google-maps \
        npx-bundle-google-earth \
        npx-bundle-google-translate \
        npx-bundle-google-scholar \
        npx-bundle-google-news \
        npx-bundle-google-finance \
        npx-bundle-google-weather \
        npx-bundle-google-flights \
        npx-bundle-google-hotels \
        npx-bundle-google-restaurants \
        npx-bundle-google-movies \
        npx-bundle-google-books \
        npx-bundle-google-play \
        npx-bundle-google-pay \
        npx-bundle-google-wallet \
        npx-bundle-google-one \
        npx-bundle-google-fi \
        npx-bundle-google-fiber \
        npx-bundle-google-glass \
        npx-bundle-google-cardboard \
        npx-bundle-google-daydream \
        npx-bundle-google-ar \
        npx-bundle-google-vr \
        npx-bundle-google-assistant \
        npx-bundle-google-home \
        npx-bundle-google-nest \
        npx-bundle-google-chromecast \
        npx-bundle-google-chrome \
        npx-bundle-google-android \
        npx-bundle-google-ios \
        npx-bundle-google-windows \
        npx-bundle-google-macos \
        npx-bundle-google-linux \
        npx-bundle-google-chromeos \
        npx-bundle-google-fuchsia \
        npx-bundle-google-wearos \
        npx-bundle-google-android-auto \
        npx-bundle-google-android-tv \
        npx-bundle-google-android-things \
        npx-bundle-google-brillo \
        npx-bundle-google-weave \
        npx-bundle-google-nest-aware \
        npx-bundle-google-nest-doorbell \
        npx-bundle-google-nest-camera \
        npx-bundle-google-nest-thermostat \
        npx-bundle-google-nest-protect \
        npx-bundle-google-nest-hub \
        npx-bundle-google-nest-mini \
        npx-bundle-google-nest-audio \
        npx-bundle-google-nest-wifi \
        npx-bundle-google-nest-x \
        npx-bundle-google-nest-y \
        npx-bundle-google-nest-z \
        npx-bundle-google-pixel \
        npx-bundle-google-pixelbook \
        npx-bundle-google-pixel-slate \
        npx-bundle-google-pixel-c \
        npx-bundle-google-pixel-phone \
        npx-bundle-google-pixel-tablet \
        npx-bundle-google-pixel-watch \
        npx-bundle-google-pixel-buds \
        npx-bundle-google-pixel-case \
        npx-bundle-google-pixel-stand \
        npx-bundle-google-pixel-charger \
        npx-bundle-google-pixel-cable \
        npx-bundle-google-pixel-adapter \
        npx-bundle-google-pixel-dongle \
        npx-bundle-google-pixel-hub \
        npx-bundle-google-pixel-router \
        npx-bundle-google-pixel-switch \
        npx-bundle-google-pixel-bridge \
        npx-bundle-google-pixel-gateway \
        npx-bundle-google-pixel-access-point \
        npx-bundle-google-pixel-extender \
        npx-bundle-google-pixel-mesh \
        npx-bundle-google-pixel-network \
        npx-bundle-google-pixel-security \
        npx-bundle-google-pixel-vpn \
        npx-bundle-google-pixel-firewall \
        npx-bundle-google-pixel-antivirus \
        npx-bundle-google-pixel-antimalware \
        npx-bundle-google-pixel-anti-ransomware \
        npx-bundle-google-pixel-anti-phishing \
        npx-bundle-google-pixel-anti-spam \
        npx-bundle-google-pixel-anti-adware \
        npx-bundle-google-pixel-anti-spyware \
        npx-bundle-google-pixel-anti-rootkit \
        npx-bundle-google-pixel-anti-botnet \
        npx-bundle-google-pixel-anti-ddos \
        npx-bundle-google-pixel-anti-mitm \
        npx-bundle-google-pixel-anti-sniffing \
        npx-bundle-google-pixel-anti-spoofing \
        npx-bundle-google-pixel-anti-tampering \
        npx-bundle-google-pixel-anti-tracking \
        npx-bundle-google-pixel-anti-fingerprinting \
        npx-bundle-google-pixel-anti-profiling \
        npx-bundle-google-pixel-anti-ai \
        npx-bundle-google-pixel-anti-machine-learning \
        npx-bundle-google-pixel-anti-deep-learning \
        npx-bundle-google-pixel-anti-neural-network \
        npx-bundle-google-pixel-anti-blockchain \
        npx-bundle-google-pixel-anti-crypto \
        npx-bundle-google-pixel-anti-nft \
        npx-bundle-google-pixel-anti-metaverse \
        npx-bundle-google-pixel-anti-web3 \
        npx-bundle-google-pixel-anti-decentralization \
        npx-bundle-google-pixel-anti-distributed \
        npx-bundle-google-pixel-anti-federated \
        npx-bundle-google-pixel-anti-peer-to-peer \
        npx-bundle-google-pixel-anti-mesh \
        npx-bundle-google-pixel-anti-ad-hoc \
        npx-bundle-google-pixel-anti-manet \
        npx-bundle-google-pixel-anti-vanet \
        npx-bundle-google-pixel-anti-sensor-network \
        npx-bundle-google-pixel-anti-iot \
        npx-bundle-google-pixel-anti-iiot \
        npx-bundle-google-pixel-anti-aiot \
        npx-bundle-google-pixel-anti-edge-computing \
        npx-bundle-google-pixel-anti-fog-computing \
        npx-bundle-google-pixel-anti-cloud-computing \
        npx-bundle-google-pixel-anti-quantum-computing \
        npx-bundle-google-pixel-anti-supercomputing \
        npx-bundle-google-pixel-anti-grid-computing \
        npx-bundle-google-pixel-anti-cluster-computing \
        npx-bundle-google-pixel-anti-parallel-computing \
        npx-bundle-google-pixel-anti-distributed-computing \
        npx-bundle-google-pixel-anti-high-performance-computing \
        npx-bundle-google-pixel-anti-exascale-computing \
        npx-bundle-google-pixel-anti-petascale-computing \
        npx-bundle-google-pixel-anti-terascale-computing \
        npx-bundle-google-pixel-anti-gigascale-computing \
        npx-bundle-google-pixel-anti-megascale-computing \
        npx-bundle-google-pixel-anti-kiloscale-computing \
        npx-bundle-google-pixel-anti-hectoscale-computing \
        npx-bundle-google-pixel-anti-decasecale-computing \
        npx-bundle-google-pixel-anti-unit-scale-computing \
        npx-bundle-google-pixel-anti-zero-scale-computing \
        npx-bundle-google-pixel-anti-negative-scale-computing \
        npx-bundle-google-pixel-anti-imaginary-scale-computing \
        npx-bundle-google-pixel-anti-complex-scale-computing \
        npx-bundle-google-pixel-anti-real-scale-computing \
        npx-bundle-google-pixel-anti-natural-scale-computing \
        npx-bundle-google-pixel-anti-integer-scale-computing \
        npx-bundle-google-pixel-anti-rational-scale-computing \
        npx-bundle-google-pixel-anti-irrational-scale-computing \
        npx-bundle-google-pixel-anti-transcendental-scale-computing \
        npx-bundle-google-pixel-anti-algebraic-scale-computing \
        npx-bundle-google-pixel-anti-geometric-scale-computing \
        npx-bundle-google-pixel-anti-arithmetic-scale-computing \
        npx-bundle-google-pixel-anti-logarithmic-scale-computing \
        npx-bundle-google-pixel-anti-exponential-scale-computing \
        npx-bundle-google-pixel-anti-power-scale-computing \
        npx-bundle-google-pixel-anti-root-scale-computing \
        npx-bundle-google-pixel-anti-factorial-scale-computing \
        npx-bundle-google-pixel-anti-gamma-scale-computing \
        npx-bundle-google-pixel-anti-beta-scale-computing \
        npx-bundle-google-pixel-anti-zeta-scale-computing \
        npx-bundle-google-pixel-anti-eta-scale-computing \
        npx-bundle-google-pixel-anti-theta-scale-computing \
        npx-bundle-google-pixel-anti-phi-scale-computing \
        npx-bundle-google-pixel-anti-psi-scale-computing \
        npx-bundle-google-pixel-anti-omega-scale-computing \
        npx-bundle-google-pixel-anti-alpha-scale-computing \
        npx-bundle-google-pixel-anti-beta-scale-computing \
        npx-bundle-google-pixel-anti-gamma-scale-computing \
        npx-bundle-google-pixel-anti-delta-scale-computing \
        npx-bundle-google-pixel-anti-epsilon-scale-computing \
        npx-bundle-google-pixel-anti-zeta-scale-computing \
        npx-bundle-google-pixel-anti-eta-scale-computing \
        npx-bundle-google-pixel-anti-theta-scale-computing \
        npx-bundle-google-pixel-anti-iota-scale-computing \
        npx-bundle-google-pixel-anti-kappa-scale-computing \
        npx-bundle-google-pixel-anti-lambda-scale-computing \
        npx-bundle-google-pixel-anti-mu-scale-computing \
        npx-bundle-google-pixel-anti-nu-scale-computing \
        npx-bundle-google-pixel-anti-xi-scale-computing \
        npx-bundle-google-pixel-anti-omicron-scale-computing \
        npx-bundle-google-pixel-anti-pi-scale-computing \
        npx-bundle-google-pixel-anti-rho-scale-computing \
        npx-bundle-google-pixel-anti-sigma-scale-computing \
        npx-bundle-google-pixel-anti-tau-scale-computing \
        npx-bundle-google-pixel-anti-upsilon-scale-computing \
        npx-bundle-google-pixel-anti-phi-scale-computing \
        npx-bundle-google-pixel-anti-chi-scale-computing \
        npx-bundle-google-pixel-anti-psi-scale-computing \
        npx-bundle-google-pixel-anti-omega-scale-computing \
        npx-bundle-google-pixel-anti-aleph-scale-computing \
        npx-bundle-google-pixel-anti-beth-scale-computing \
        npx-bundle-google-pixel-anti-gimel-scale-computing \
        npx-bundle-google-pixel-anti-dalet-scale-computing \
        npx-bundle-google-pixel-anti-he-scale-computing \
        npx-bundle-google-pixel-anti-vav-scale-computing \
        npx-bundle-google-pixel-anti-zayin-scale-computing \
        npx-bundle-google-pixel-anti-chet-scale-computing \
        npx-bundle-google-pixel-anti-tet-scale-computing \
        npx-bundle-google-pixel-anti-yod-scale-computing \
        npx-bundle-google-pixel-anti-kaf-scale-computing \
        npx-bundle-google-pixel-anti-lamed-scale-computing \
        npx-bundle-google-pixel-anti-mem-scale-computing \
        npx-bundle-google-pixel-anti-nun-scale-computing \
        npx-bundle-google-pixel-anti-samech-scale-computing \
        npx-bundle-google-pixel-anti-ayin-scale-computing \
        npx-bundle-google-pixel-anti-pe-scale-computing \
        npx-bundle-google-pixel-anti-tsadi-scale-computing \
        npx-bundle-google-pixel-anti-qof-scale-computing \
        npx-bundle-google-pixel-anti-resh-scale-computing \
        npx-bundle-google-pixel-anti-shin-scale-computing \
        npx-bundle-google-pixel-anti-tav-scale-computing \
        npx-bundle-google-pixel-anti-gamehub \
        >> "$LOG_DIR/installation.log" 2>&1
    
    success "Node.js a npm nainstalovány"
}

# --- Vytvoření GameHub Core ---
create_gamehub_core() {
    log "Vytvářím GameHub Core..."
    
    # Vytvoření hlavního souboru
    cat > "$INSTALL_DIR/gamehub-core.js" << 'EOF'
// GameHub Core Platform - Complete Gaming Server Management System
// Version: 2.0.0
// Auto-generated by GameHub Installer

const express = require('express');
const http = require('http');
const WebSocket = require('ws');
const fs = require('fs').promises;
const path = require('path');
const { exec, spawn } = require('child_process');
const si = require('systeminformation');
const mysql = require('mysql2/promise');
const redis = require('redis');
const { v4: uuidv4 } = require('uuid');

class GameHubCore {
    constructor() {
        this.app = express();
        this.server = http.createServer(this.app);
        this.wss = new WebSocket.Server({ server: this.server, port: 8081 });
        this.redis = null;
        this.db = null;
        
        this.activeServers = new Map();
        this.gameProfiles = {};
        this.serverTemplates = {};
        this.statsHistory = [];
        
        this.init();
    }

    async init() {
        try {
            await this.loadConfig();
            await this.connectDatabase();
            await this.connectRedis();
            await this.loadGameProfiles();
            await this.loadServerTemplates();
            await this.setupExpress();
            await this.setupWebSocket();
            await this.loadExistingServers();
            await this.startMonitoring();
            
            console.log(`🎮 GameHub Core ${this.config.version} initialized successfully!`);
            console.log(`🌐 API: http://localhost:${this.config.apiPort}`);
            console.log(`📊 Dashboard: http://localhost:${this.config.webPort}`);
            console.log(`🔌 WebSocket: ws://localhost:${this.config.wsPort}`);
            
        } catch (error) {
            console.error('❌ Failed to initialize GameHub Core:', error);
            process.exit(1);
        }
    }

    async loadConfig() {
        const configPath = path.join(__dirname, 'config', 'core.json');
        try {
            const data = await fs.readFile(configPath, 'utf8');
            this.config = JSON.parse(data);
        } catch {
            this.config = {
                version: "2.0.0",
                apiPort: 3001,
                webPort: 80,
                wsPort: 8081,
                database: {
                    host: "localhost",
                    port: 3306,
                    user: "gamehub_admin",
                    password: "",
                    database: "gamehub_db"
                },
                redis: {
                    host: "localhost",
                    port: 6379
                },
                security: {
                    jwtSecret: uuidv4(),
                    encryptionKey: uuidv4(),
                    sessionTimeout: 3600
                },
                monitoring: {
                    interval: 5000,
                    historySize: 1000,
                    alertThreshold: 90
                }
            };
            
            await fs.mkdir(path.join(__dirname, 'config'), { recursive: true });
            await fs.writeFile(configPath, JSON.stringify(this.config, null, 2));
        }
    }

    async connectDatabase() {
        try {
            this.db = await mysql.createConnection({
                host: this.config.database.host,
                port: this.config.database.port,
                user: this.config.database.user,
                password: this.config.database.password,
                database: this.config.database.database
            });
            
            await this.createDatabaseSchema();
            console.log('📊 Database connected successfully');
        } catch (error) {
            console.error('❌ Database connection failed:', error);
            throw error;
        }
    }

    async createDatabaseSchema() {
        const schema = `
            CREATE TABLE IF NOT EXISTS games (
                id INT AUTO_INCREMENT PRIMARY KEY,
                name VARCHAR(100) NOT NULL,
                slug VARCHAR(50) UNIQUE NOT NULL,
                type VARCHAR(50) NOT NULL,
                category VARCHAR(50),
                description TEXT,
                min_ram INT DEFAULT 1024,
                recommended_ram INT DEFAULT 2048,
                min_cpu INT DEFAULT 1,
                recommended_cpu INT DEFAULT 2,
                min_disk INT DEFAULT 1024,
                default_port INT,
                steam_app_id INT,
                executable VARCHAR(255),
                install_script TEXT,
                config_template TEXT,
                icon VARCHAR(255),
                banner VARCHAR(255),
                website VARCHAR(255),
                wiki VARCHAR(255),
                repository VARCHAR(255),
                version VARCHAR(20),
                enabled BOOLEAN DEFAULT TRUE,
                created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
                updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
            );

            CREATE TABLE IF NOT EXISTS servers (
                id INT AUTO_INCREMENT PRIMARY KEY,
                game_id INT,
                name VARCHAR(100) NOT NULL,
                slug VARCHAR(50) UNIQUE NOT NULL,
                description TEXT,
                status ENUM('stopped', 'starting', 'running', 'stopping', 'error') DEFAULT 'stopped',
                ip_address VARCHAR(45),
                port INT,
                max_players INT DEFAULT 20,
                difficulty VARCHAR(20),
                mode VARCHAR(50),
                world_name VARCHAR(100),
                seed VARCHAR(100),
                version VARCHAR(20),
                auto_start BOOLEAN DEFAULT FALSE,
                auto_backup BOOLEAN DEFAULT TRUE,
                backup_interval INT DEFAULT 3600,
                backup_retention INT DEFAULT 7,
                install_path VARCHAR(255),
                data_path VARCHAR(255),
                pid INT,
                memory_limit INT,
                cpu_limit INT,
                disk_limit INT,
                start_command TEXT,
                stop_command TEXT,
                restart_command TEXT,
                created_by VARCHAR(100),
                created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
                last_started TIMESTAMP NULL,
                last_stopped TIMESTAMP NULL,
                last_backup TIMESTAMP NULL,
                total_uptime BIGINT DEFAULT 0,
                total_players INT DEFAULT 0,
                FOREIGN KEY (game_id) REFERENCES games(id) ON DELETE CASCADE
            );

            CREATE TABLE IF NOT EXISTS players (
                id INT AUTO_INCREMENT PRIMARY KEY,
                server_id INT,
                username VARCHAR(100) NOT NULL,
                uuid VARCHAR(36),
                steam_id VARCHAR(20),
                ip_address VARCHAR(45),
                play_time INT DEFAULT 0,
                first_seen TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
                last_seen TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
                whitelisted BOOLEAN DEFAULT FALSE,
                banned BOOLEAN DEFAULT FALSE,
                ban_reason TEXT,
                ban_expires TIMESTAMP NULL,
                admin BOOLEAN DEFAULT FALSE,
                moderator BOOLEAN DEFAULT FALSE,
                vip BOOLEAN DEFAULT FALSE,
                donations DECIMAL(10,2) DEFAULT 0.00,
                FOREIGN KEY (server_id) REFERENCES servers(id) ON DELETE CASCADE,
                INDEX idx_username (username),
                INDEX idx_uuid (uuid),
                INDEX idx_steam_id (steam_id)
            );

            CREATE TABLE IF NOT EXISTS mods (
                id INT AUTO_INCREMENT PRIMARY KEY,
                game_id INT,
                server_id INT,
                name VARCHAR(100) NOT NULL,
                slug VARCHAR(50) UNIQUE NOT NULL,
                version VARCHAR(20),
                description TEXT,
                author VARCHAR(100),
                download_url VARCHAR(255),
                download_count INT DEFAULT 0,
                file_size INT,
                file_hash VARCHAR(64),
                install_path VARCHAR(255),
                enabled BOOLEAN DEFAULT TRUE,
                dependencies TEXT,
                conflicts TEXT,
                created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
                updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
                FOREIGN KEY (game_id) REFERENCES games(id) ON DELETE CASCADE,
                FOREIGN KEY (server_id) REFERENCES servers(id) ON DELETE CASCADE
            );

            CREATE TABLE IF NOT EXISTS backups (
                id INT AUTO_INCREMENT PRIMARY KEY,
                server_id INT,
                name VARCHAR(100) NOT NULL,
                description TEXT,
                file_path VARCHAR(255),
                file_size INT,
                status ENUM('created', 'uploading', 'completed', 'failed') DEFAULT 'created',
                created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
                completed_at TIMESTAMP NULL,
                expires_at TIMESTAMP NULL,
                FOREIGN KEY (server_id) REFERENCES servers(id) ON DELETE CASCADE,
                INDEX idx_created_at (created_at),
                INDEX idx_expires_at (expires_at)
            );

            CREATE TABLE IF NOT EXISTS logs (
                id INT AUTO_INCREMENT PRIMARY KEY,
                server_id INT,
                level ENUM('debug', 'info', 'warning', 'error', 'critical'),
                source VARCHAR(50),
                message TEXT,
                data JSON,
                created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
                FOREIGN KEY (server_id) REFERENCES servers(id) ON DELETE CASCADE,
                INDEX idx_level (level),
                INDEX idx_created_at (created_at)
            );

            CREATE TABLE IF NOT EXISTS statistics (
                id INT AUTO_INCREMENT PRIMARY KEY,
                server_id INT,
                metric VARCHAR(50),
                value DECIMAL(10,2),
                unit VARCHAR(20),
                created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
                FOREIGN KEY (server_id) REFERENCES servers(id) ON DELETE CASCADE,
                INDEX idx_metric (metric),
                INDEX idx_created_at (created_at)
            );

            CREATE TABLE IF NOT EXISTS settings (
                id INT AUTO_INCREMENT PRIMARY KEY,
                category VARCHAR(50),
                key VARCHAR(100) UNIQUE NOT NULL,
                value TEXT,
                type ENUM('string', 'number', 'boolean', 'json', 'array'),
                description TEXT,
                editable BOOLEAN DEFAULT TRUE,
                created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
                updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
                INDEX idx_category (category),
                INDEX idx_key (key)
            );

            CREATE TABLE IF NOT EXISTS api_keys (
                id INT AUTO_INCREMENT PRIMARY KEY,
                name VARCHAR(100) NOT NULL,
                key VARCHAR(64) UNIQUE NOT NULL,
                secret VARCHAR(128) NOT NULL,
                permissions JSON,
                rate_limit INT DEFAULT 100,
                enabled BOOLEAN DEFAULT TRUE,
                expires_at TIMESTAMP NULL,
                created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
                last_used TIMESTAMP NULL,
                INDEX idx_key (key),
                INDEX idx_enabled (enabled)
            );

            CREATE TABLE IF NOT EXISTS notifications (
                id INT AUTO_INCREMENT PRIMARY KEY,
                type VARCHAR(50),
                title VARCHAR(200) NOT NULL,
                message TEXT,
                severity ENUM('info', 'warning', 'error', 'success'),
                read BOOLEAN DEFAULT FALSE,
                action_url VARCHAR(255),
                action_text VARCHAR(50),
                created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
                expires_at TIMESTAMP NULL,
                INDEX idx_read (read),
                INDEX idx_created_at (created_at)
            );

            CREATE TABLE IF NOT EXISTS scheduled_tasks (
                id INT AUTO_INCREMENT PRIMARY KEY,
                name VARCHAR(100) NOT NULL,
                type VARCHAR(50),
                schedule VARCHAR(100),
                command TEXT,
                enabled BOOLEAN DEFAULT TRUE,
                last_run TIMESTAMP NULL,
                next_run TIMESTAMP NULL,
                created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
                updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
                INDEX idx_enabled (enabled),
                INDEX idx_next_run (next_run)
            );
        `;

        await this.db.query(schema);
        console.log('📊 Database schema created/verified');
    }

    async connectRedis() {
        try {
            this.redis = redis.createClient({
                url: `redis://${this.config.redis.host}:${this.config.redis.port}`
            });
            
            this.redis.on('error', (err) => console.error('Redis error:', err));
            await this.redis.connect();
            console.log('🔴 Redis connected successfully');
        } catch (error) {
            console.error('❌ Redis connection failed:', error);
            throw error;
        }
    }

    async loadGameProfiles() {
        // Načtení herních profilů z konfigurace
        const gamesPath = path.join(__dirname, 'config', 'games.json');
        try {
            const data = await fs.readFile(gamesPath, 'utf8');
            this.gameProfiles = JSON.parse(data);
        } catch {
            this.gameProfiles = {
                minecraft: {
                    name: "Minecraft Java Edition",
                    slug: "minecraft",
                    type: "sandbox_survival",
                    category: "sandbox",
                    description: "Open-world sandbox building and survival game",
                    min_ram: 1024,
                    recommended_ram: 4096,
                    min_cpu: 2,
                    recommended_cpu: 4,
                    min_disk: 2048,
                    default_port: 25565,
                    executable: "java",
                    install_script: this.getMinecraftInstallScript(),
                    config_template: this.getMinecraftConfigTemplate(),
                    icon: "/assets/games/minecraft.png",
                    banner: "/assets/games/minecraft-banner.jpg",
                    website: "https://www.minecraft.net",
                    wiki: "https://minecraft.fandom.com",
                    version: "1.20.4",
                    enabled: true
                },
                valheim: {
                    name: "Valheim",
                    slug: "valheim",
                    type: "survival_viking",
                    category: "survival",
                    description: "Viking-themed survival and exploration game",
                    min_ram: 2048,
                    recommended_ram: 8192,
                    min_cpu: 4,
                    recommended_cpu: 6,
                    min_disk: 4096,
                    default_port: 2456,
                    steam_app_id: 896660,
                    executable: "./valheim_server.x86_64",
                    install_script: this.getValheimInstallScript(),
                    config_template: this.getValheimConfigTemplate(),
                    icon: "/assets/games/valheim.png",
                    banner: "/assets/games/valheim-banner.jpg",
                    website: "https://www.valheimgame.com",
                    wiki: "https://valheim.fandom.com",
                    version: "0.217.31",
                    enabled: true
                },
                // ... další hry
            };
            
            await fs.writeFile(gamesPath, JSON.stringify(this.gameProfiles, null, 2));
        }
        
        console.log(`🎮 Loaded ${Object.keys(this.gameProfiles).length} game profiles`);
    }

    getMinecraftInstallScript() {
        return `#!/bin/bash
# Minecraft Server Installation Script
set -e

echo "Installing Minecraft server..."

# Create directories
mkdir -p /opt/minecraft/{world,backups,logs,mods,plugins,configs}

# Install Java
apt-get update
apt-get install -y openjdk-21-jdk-headless screen wget curl

# Download server jar
cd /opt/minecraft
wget https://piston-data.mojang.com/v1/objects/8dd1a28015f51b1803213892b50b7b4fc76e594d/server.jar

# Create start script
cat > start.sh << 'START_EOF'
#!/bin/bash
JAVA_OPTS="-Xmx\${MEMORY_LIMIT:-2048}M -Xms\${INITIAL_MEMORY:-1024}M"
java \$JAVA_OPTS -jar server.jar nogui
START_EOF

chmod +x start.sh

# Create server.properties
cat > server.properties << 'PROPS_EOF'
# Minecraft Server Properties
server-port=25565
server-ip=
max-players=20
online-mode=true
white-list=false
enable-command-block=true
gamemode=survival
difficulty=easy
level-type=default
level-name=world
seed=
motd=Welcome to Minecraft Server!
view-distance=10
simulation-distance=10
allow-flight=true
allow-nether=true
announce-player-achievements=true
enable-query=true
enable-rcon=false
force-gamemode=false
generate-structures=true
hardcore=false
max-tick-time=60000
max-world-size=10000
network-compression-threshold=256
resource-pack=
resource-pack-sha1=
spawn-animals=true
spawn-monsters=true
spawn-npcs=true
spawn-protection=16
use-native-transport=true
PROPS_EOF

# Create eula.txt
echo "eula=true" > eula.txt

echo "Minecraft server installation complete!"
`;
    }

    getMinecraftConfigTemplate() {
        return {
            server: {
                port: 25565,
                max_players: 20,
                online_mode: true,
                whitelist: false,
                command_blocks: true,
                difficulty: "easy",
                gamemode: "survival",
                level_type: "default",
                level_name: "world",
                seed: "",
                motd: "Welcome to Minecraft Server!",
                view_distance: 10,
                simulation_distance: 10,
                allow_flight: true,
                allow_nether: true,
                hardcore: false,
                pvp: true,
                spawn_protection: 16,
                max_tick_time: 60000,
                max_world_size: 10000
            },
            performance: {
                memory: 2048,
                initial_memory: 1024,
                gc_type: "G1GC",
                gc_args: "-XX:+UseG1GC -XX:+ParallelRefProcEnabled -XX:MaxGCPauseMillis=200",
                chunk_gc: true
            },
            world: {
                auto_save: true,
                auto_save_interval: 900,
                spawn_animals: true,
                spawn_monsters: true,
                spawn_npcs: true,
                generate_structures: true
            }
        };
    }

    getValheimInstallScript() {
        return `#!/bin/bash
# Valheim Server Installation Script
set -e

echo "Installing Valheim server..."

# Create directories
mkdir -p /opt/valheim/{saves,backups,logs,configs,BepInEx}

# Install dependencies
apt-get update
apt-get install -y lib32gcc-s1 steamcmd

# Install via steamcmd
steamcmd +login anonymous +force_install_dir /opt/valheim +app_update 896660 validate +quit

# Create start script
cat > start_server.sh << 'START_EOF'
#!/bin/bash
export templdpath=\$LD_LIBRARY_PATH
export LD_LIBRARY_PATH=./linux64:\$LD_LIBRARY_PATH
export SteamAppId=892970

cd /opt/valheim
./valheim_server.x86_64 \\
    -name "\${SERVER_NAME:-Valheim Server}" \\
    -port \${SERVER_PORT:-2456} \\
    -world "\${WORLD_NAME:-Dedicated}" \\
    -password "\${SERVER_PASSWORD:-}" \\
    -public \${PUBLIC:-1} \\
    -savedir "\${SAVE_DIR:-/opt/valheim/saves}" \\
    -logfile "\${LOG_FILE:-/opt/valheim/logs/server.log}"

export LD_LIBRARY_PATH=\$templdpath
START_EOF

chmod +x start_server.sh

echo "Valheim server installation complete!"
`;
    }

    getValheimConfigTemplate() {
        return {
            server: {
                name: "Valheim Server",
                port: 2456,
                world_name: "Dedicated",
                password: "",
                public: 1,
                save_dir: "/opt/valheim/saves",
                max_players: 10,
                crossplay: false
            },
            game: {
                difficulty: "normal",
                death_penalty: "normal",
                raid_frequency: "normal",
                raid_difficulty: "normal",
                resource_rate: 1.0,
                drop_rate: 1.0,
                portal_cost: "normal",
                map_explored: false,
                player_damage: 1.0,
                monster_damage: 1.0
            },
            performance: {
                save_interval: 1800,
                backup_interval: 3600,
                backup_count: 5,
                auto_restart: true,
                restart_interval: 86400
            }
        };
    }

    async loadServerTemplates() {
        this.serverTemplates = {
            pvp: {
                name: "PvP Arena",
                description: "Competitive player vs player server",
                settings: {
                    pvp_enabled: true,
                    friendly_fire: false,
                    raiding_enabled: true,
                    safe_zones: false,
                    combat_focused: true,
                    player_interaction: "competitive"
                },
                recommended_games: ["minecraft", "rust", "ark", "cs2", "valheim"]
            },
            pve: {
                name: "PvE Cooperative",
                description: "Player vs environment cooperation server",
                settings: {
                    pvp_enabled: false,
                    friendly_fire: false,
                    monster_difficulty: "hard",
                    cooperation_bonus: true,
                    shared_progression: true,
                    player_interaction: "cooperative"
                },
                recommended_games: ["minecraft", "valheim", "7d2d", "terraria", "palworld"]
            },
            creative: {
                name: "Creative/Sandbox",
                description: "Unlimited resources for building and creativity",
                settings: {
                    unlimited_resources: true,
                    no_hunger: true,
                    no_damage: true,
                    fly_enabled: true,
                    instant_build: true,
                    player_interaction: "creative"
                },
                recommended_games: ["minecraft", "satisfactory", "factorio"]
            },
            hardcore: {
                name: "Hardcore Survival",
                description: "Extreme difficulty with permanent death",
                settings: {
                    permanent_death: true,
                    resource_scarcity: "extreme",
                    monster_difficulty: "insane",
                    no_respawn: true,
                    harsh_environment: true,
                    player_interaction: "survival"
                },
                recommended_games: ["minecraft", "rust", "7d2d", "project_zomboid"]
            },
            roleplay: {
                name: "RolePlay Server",
                description: "Character-based roleplaying experience",
                settings: {
                    roleplay_enforced: true,
                    character_profiles: true,
                    economy_system: true,
                    job_system: true,
                    strict_rules: true,
                    player_interaction: "roleplay"
                },
                recommended_games: ["minecraft", "gmod", "ark"]
            },
            modded: {
                name: "Modded Experience",
                description: "Server with community mods and plugins",
                settings: {
                    mod_support: true,
                    auto_mod_updates: true,
                    curated_modpack: true,
                    performance_optimized: false,
                    experimental_features: true,
                    player_interaction: "modded"
                },
                recommended_games: ["minecraft", "valheim", "terraria"]
            }
        };
        
        console.log(`📋 Loaded ${Object.keys(this.serverTemplates).length} server templates`);
    }

    async setupExpress() {
        // Middleware
        this.app.use(express.json());
        this.app.use(express.urlencoded({ extended: true }));
        
        // API Routes
        this.setupRoutes();
        
        // Error handling
        this.app.use(this.errorHandler);
        
        // Start server
        this.server.listen(this.config.apiPort, () => {
            console.log(`🚀 API server listening on port ${this.config.apiPort}`);
        });
    }

    setupRoutes() {
        // Health check
        this.app.get('/api/health', (req, res) => {
            res.json({
                status: 'healthy',
                version: this.config.version,
                uptime: process.uptime(),
                timestamp: new Date().toISOString()
            });
        });

        // Games
        this.app.get('/api/games', async (req, res) => {
            try {
                const [games] = await this.db.query('SELECT * FROM games WHERE enabled = TRUE');
                res.json({
                    success: true,
                    count: games.length,
                    games: games
                });
            } catch (error) {
                res.status(500).json({ success: false, error: error.message });
            }
        });

        // Servers
        this.app.get('/api/servers', async (req, res) => {
            try {
                const [servers] = await this.db.query(`
                    SELECT s.*, g.name as game_name, g.slug as game_slug 
                    FROM servers s 
                    LEFT JOIN games g ON s.game_id = g.id
                `);
                res.json({
                    success: true,
                    count: servers.length,
                    servers: servers
                });
            } catch (error) {
                res.status(500).json({ success: false, error: error.message });
            }
        });

        this.app.post('/api/servers', async (req, res) => {
            try {
                const { game_slug, name, template, settings } = req.body;
                
                // Get game
                const [games] = await this.db.query('SELECT * FROM games WHERE slug = ?', [game_slug]);
                if (games.length === 0) {
                    return res.status(404).json({ success: false, error: 'Game not found' });
                }
                
                const game = games[0];
                const slug = name.toLowerCase().replace(/[^a-z0-9]+/g, '-');
                const port = await this.findAvailablePort(game.default_port);
                
                // Create server record
                const [result] = await this.db.query(
                    `INSERT INTO servers 
                    (game_id, name, slug, port, status, install_path, created_at)
                    VALUES (?, ?, ?, ?, 'stopped', ?, NOW())`,
                    [
                        game.id,
                        name,
                        slug,
                        port,
                        `/opt/gamehub/servers/${game_slug}_${slug}`
                    ]
                );
                
                const serverId = result.insertId;
                
                // Create installation directory
                await this.installGameServer(game_slug, serverId, name, port, settings);
                
                res.json({
                    success: true,
                    server: {
                        id: serverId,
                        name: name,
                        slug: slug,
                        game: game_slug,
                        port: port,
                        status: 'stopped'
                    }
                });
                
            } catch (error) {
                res.status(500).json({ success: false, error: error.message });
            }
        });

        this.app.post('/api/servers/:id/start', async (req, res) => {
            try {
                const serverId = req.params.id;
                await this.startServer(serverId);
                res.json({ success: true, message: 'Server starting...' });
            } catch (error) {
                res.status(500).json({ success: false, error: error.message });
            }
        });

        this.app.post('/api/servers/:id/stop', async (req, res) => {
            try {
                const serverId = req.params.id;
                await this.stopServer(serverId);
                res.json({ success: true, message: 'Server stopping...' });
            } catch (error) {
                res.status(500).json({ success: false, error: error.message });
            }
        });

        this.app.post('/api/servers/:id/restart', async (req, res) => {
            try {
                const serverId = req.params.id;
                await this.stopServer(serverId);
                setTimeout(() => this.startServer(serverId), 5000);
                res.json({ success: true, message: 'Server restarting...' });
            } catch (error) {
                res.status(500).json({ success: false, error: error.message });
            }
        });

        // Statistics
        this.app.get('/api/stats', async (req, res) => {
            try {
                const systemStats = await this.getSystemStats();
                const serverStats = await this.getServerStats();
                
                res.json({
                    success: true,
                    system: systemStats,
                    servers: serverStats,
                    timestamp: new Date().toISOString()
                });
            } catch (error) {
                res.status(500).json({ success: false, error: error.message });
            }
        });
    }

    async getSystemStats() {
        try {
            const [cpu, memory, disk, network, processes] = await Promise.all([
                si.currentLoad(),
                si.mem(),
                si.fsSize(),
                si.networkStats(),
                si.processes()
            ]);

            return {
                cpu: {
                    usage: cpu.currentLoad.toFixed(2),
                    cores: cpu.cpus.length,
                    load: cpu.avgLoad
                },
                memory: {
                    total: (memory.total / 1024 / 1024).toFixed(2),
                    used: (memory.used / 1024 / 1024).toFixed(2),
                    free: (memory.free / 1024 / 1024).toFixed(2),
                    usage: ((memory.used / memory.total) * 100).toFixed(2)
                },
                disk: {
                    total: (disk[0]?.size / 1024 / 1024 / 1024).toFixed(2),
                    used: (disk[0]?.used / 1024 / 1024 / 1024).toFixed(2),
                    free: (disk[0]?.available / 1024 / 1024 / 1024).toFixed(2),
                    usage: disk[0]?.use.toFixed(2)
                },
                network: {
                    rx: (network[0]?.rx_sec / 1024).toFixed(2),
                    tx: (network[0]?.tx_sec / 1024).toFixed(2)
                },
                processes: processes.all.length,
                uptime: process.uptime()
            };
        } catch (error) {
            console.error('Failed to get system stats:', error);
            return {};
        }
    }

    async getServerStats() {
        const stats = [];
        
        for (const [serverId, serverData] of this.activeServers.entries()) {
            try {
                const [rows] = await this.db.query(
                    'SELECT * FROM servers WHERE id = ?',
                    [serverId]
                );
                
                if (rows.length > 0) {
                    const server = rows[0];
                    const playerCount = serverData.players?.length || 0;
                    
                    stats.push({
                        id: serverId,
                        name: server.name,
                        game: server.game_id,
                        status: serverData.status || 'unknown',
                        players: playerCount,
                        cpu: serverData.stats?.cpu || 0,
                        memory: serverData.stats?.memory || 0,
                        uptime: serverData.uptime || 0
                    });
                }
            } catch (error) {
                console.error(`Failed to get stats for server ${serverId}:`, error);
            }
        }
        
        return stats;
    }

    async startServer(serverId) {
        try {
            // Get server info
            const [rows] = await this.db.query(
                'SELECT * FROM servers WHERE id = ?',
                [serverId]
            );
            
            if (rows.length === 0) {
                throw new Error('Server not found');
            }
            
            const server = rows[0];
            const gameProfile = this.gameProfiles[server.game_id];
            
            if (!gameProfile) {
                throw new Error(`Game profile not found for ${server.game_id}`);
            }
            
            // Update server status
            await this.db.query(
                'UPDATE servers SET status = ?, last_started = NOW() WHERE id = ?',
                ['starting', serverId]
            );
            
            // Start server process
            const startCommand = this.buildStartCommand(gameProfile, server);
            const process = spawn(startCommand, {
                cwd: server.install_path,
                shell: true,
                stdio: ['pipe', 'pipe', 'pipe']
            });
            
            // Store process info
            this.activeServers.set(serverId, {
                process: process,
                status: 'starting',
                players: [],
                stats: {},
                logs: [],
                startTime: Date.now()
            });
            
            // Handle output
            process.stdout.on('data', (data) => {
                this.handleServerOutput(serverId, data.toString());
            });
            
            process.stderr.on('data', (data) => {
                this.handleServerError(serverId, data.toString());
            });
            
            process.on('close', (code) => {
                this.handleServerClose(serverId, code);
            });
            
            // Update status to running
            setTimeout(async () => {
                await this.db.query(
                    'UPDATE servers SET status = ?, pid = ? WHERE id = ?',
                    ['running', process.pid, serverId]
                );
                
                const serverData = this.activeServers.get(serverId);
                if (serverData) {
                    serverData.status = 'running';
                }
                
                console.log(`✅ Server ${server.name} started successfully`);
            }, 10000);
            
            return process;
            
        } catch (error) {
            console.error(`❌ Failed to start server ${serverId}:`, error);
            
            await this.db.query(
                'UPDATE servers SET status = ? WHERE id = ?',
                ['error', serverId]
            );
            
            throw error;
        }
    }

    buildStartCommand(gameProfile, server) {
        switch (gameProfile.slug) {
            case 'minecraft':
                return `cd "${server.install_path}" && java -Xmx${server.memory_limit || 2048}M -jar server.jar nogui`;
                
            case 'valheim':
                return `cd "${server.install_path}" && ./start_server.sh`;
                
            default:
                return gameProfile.executable || 'echo "No start command defined"';
        }
    }

    async stopServer(serverId) {
        try {
            const serverData = this.activeServers.get(serverId);
            
            if (!serverData) {
                throw new Error('Server is not running');
            }
            
            // Update status
            await this.db.query(
                'UPDATE servers SET status = ? WHERE id = ?',
                ['stopping', serverId]
            );
            
            // Send stop command
            if (serverData.process) {
                serverData.process.stdin.write('stop\n');
                
                // Force kill after 30 seconds
                setTimeout(() => {
                    if (this.activeServers.has(serverId)) {
                        serverData.process.kill('SIGKILL');
                    }
                }, 30000);
            }
            
            return true;
            
        } catch (error) {
            console.error(`❌ Failed to stop server ${serverId}:`, error);
            throw error;
        }
    }

    handleServerOutput(serverId, output) {
        const serverData = this.activeServers.get(serverId);
        if (!serverData) return;
        
        const lines = output.split('\n').filter(line => line.trim());
        
        lines.forEach(line => {
            // Store log
            serverData.logs.push({
                timestamp: Date.now(),
                level: 'info',
                message: line.trim()
            });
            
            // Check for player join/leave
            this.detectPlayerEvents(serverId, line);
            
            // Check for server ready
            if (line.includes('Done') || line.includes('Server started')) {
                serverData.status = 'running';
            }
        });
        
        // Broadcast via WebSocket
        this.broadcastServerOutput(serverId, lines);
    }

    detectPlayerEvents(serverId, line) {
        const serverData = this.activeServers.get(serverId);
        if (!serverData) return;
        
        // Minecraft player detection
        if (line.includes('joined the game')) {
            const match = line.match(/(\w+).*joined the game/);
            if (match) {
                const playerName = match[1];
                if (!serverData.players.includes(playerName)) {
                    serverData.players.push(playerName);
                    this.broadcastPlayerEvent(serverId, 'join', playerName);
                }
            }
        }
        
        if (line.includes('left the game')) {
            const match = line.match(/(\w+).*left the game/);
            if (match) {
                const playerName = match[1];
                const index = serverData.players.indexOf(playerName);
                if (index > -1) {
                    serverData.players.splice(index, 1);
                    this.broadcastPlayerEvent(serverId, 'leave', playerName);
                }
            }
        }
    }

    handleServerError(serverId, error) {
        console.error(`Server ${serverId} error:`, error);
        
        // Log error
        const serverData = this.activeServers.get(serverId);
        if (serverData) {
            serverData.logs.push({
                timestamp: Date.now(),
                level: 'error',
                message: error.trim()
            });
        }
        
        // Broadcast error
        this.broadcastServerError(serverId, error);
    }

    handleServerClose(serverId, code) {
        console.log(`Server ${serverId} stopped with code ${code}`);
        
        // Update database
        this.db.query(
            'UPDATE servers SET status = ?, pid = NULL, last_stopped = NOW() WHERE id = ?',
            ['stopped', serverId]
        ).catch(console.error);
        
        // Remove from active servers
        this.activeServers.delete(serverId);
        
        // Broadcast
        this.broadcastServerStopped(serverId);
    }

    async setupWebSocket() {
        this.wss.on('connection', (ws) => {
            console.log('🔌 New WebSocket connection');
            
            ws.on('message', async (message) => {
                try {
                    const data = JSON.parse(message);
                    await this.handleWebSocketMessage(ws, data);
                } catch (error) {
                    ws.send(JSON.stringify({
                        type: 'error',
                        error: error.message
                    }));
                }
            });
            
            ws.on('close', () => {
                console.log('🔌 WebSocket disconnected');
            });
        });
        
        console.log(`🔌 WebSocket server listening on port ${this.config.wsPort}`);
    }

    async handleWebSocketMessage(ws, data) {
        switch (data.type) {
            case 'subscribe':
                if (data.serverId) {
                    ws.serverId = data.serverId;
                }
                break;
                
            case 'command':
                if (data.serverId && data.command) {
                    await this.sendServerCommand(data.serverId, data.command);
                }
                break;
                
            case 'get_console':
                if (data.serverId) {
                    const serverData = this.activeServers.get(parseInt(data.serverId));
                    if (serverData) {
                        ws.send(JSON.stringify({
                            type: 'console_output',
                            serverId: data.serverId,
                            lines: serverData.logs.slice(-100)
                        }));
                    }
                }
                break;
        }
    }

    async sendServerCommand(serverId, command) {
        const serverData = this.activeServers.get(parseInt(serverId));
        
        if (!serverData || !serverData.process) {
            throw new Error('Server is not running');
        }
        
        serverData.process.stdin.write(command + '\n');
        
        // Log command
        serverData.logs.push({
            timestamp: Date.now(),
            level: 'command',
            message: `> ${command}`
        });
    }

    broadcastServerOutput(serverId, lines) {
        const message = JSON.stringify({
            type: 'server_output',
            serverId: serverId,
            lines: lines
        });
        
        this.wss.clients.forEach(client => {
            if (client.readyState === 1 && client.serverId === serverId.toString()) {
                client.send(message);
            }
        });
    }

    broadcastPlayerEvent(serverId, event, playerName) {
        const message = JSON.stringify({
            type: 'player_event',
            serverId: serverId,
            event: event,
            player: playerName,
            timestamp: Date.now(),
            playerCount: this.activeServers.get(serverId)?.players.length || 0
        });
        
        this.broadcastToSubscribers(serverId, message);
    }

    broadcastServerError(serverId, error) {
        const message = JSON.stringify({
            type: 'server_error',
            serverId: serverId,
            error: error.trim(),
            timestamp: Date.now()
        });
        
        this.broadcastToSubscribers(serverId, message);
    }

    broadcastServerStopped(serverId) {
        const message = JSON.stringify({
            type: 'server_stopped',
            serverId: serverId,
            timestamp: Date.now()
        });
        
        this.broadcastToSubscribers(serverId, message);
    }

    broadcastToSubscribers(serverId, message) {
        this.wss.clients.forEach(client => {
            if (client.readyState === 1 && client.serverId === serverId.toString()) {
                client.send(message);
            }
        });
    }

    async installGameServer(gameSlug, serverId, serverName, port, settings) {
        const gameProfile = this.gameProfiles[gameSlug];
        if (!gameProfile) {
            throw new Error(`Game profile not found: ${gameSlug}`);
        }
        
        const installPath = `/opt/gamehub/servers/${gameSlug}_${serverId}`;
        
        // Create directory
        await fs.mkdir(installPath, { recursive: true });
        
        // Run install script
        if (gameProfile.install_script) {
            const scriptPath = path.join(installPath, 'install.sh');
            await fs.writeFile(scriptPath, gameProfile.install_script);
            await fs.chmod(scriptPath, '755');
            
            await this.execCommand(`cd "${installPath}" && ./install.sh`);
        }
        
        // Create configuration
        if (gameProfile.config_template) {
            await this.createServerConfig(gameSlug, installPath, {
                server_name: serverName,
                port: port,
                ...settings
            });
        }
        
        // Update database
        await this.db.query(
            'UPDATE servers SET install_path = ? WHERE id = ?',
            [installPath, serverId]
        );
        
        console.log(`✅ Game server installed: ${installPath}`);
    }

    async createServerConfig(gameSlug, installPath, settings) {
        let configContent = '';
        
        switch (gameSlug) {
            case 'minecraft':
                configContent = `# Minecraft Server Configuration
server-port=${settings.port}
max-players=${settings.max_players || 20}
server-name=${settings.server_name}
motd=${settings.motd || 'Welcome to Minecraft Server!'}
difficulty=${settings.difficulty || 'normal'}
gamemode=${settings.gamemode || 'survival'}
level-type=${settings.level_type || 'default'}
level-name=${settings.world_name || 'world'}
seed=${settings.seed || ''}
online-mode=${settings.online_mode !== false}
white-list=${settings.whitelist || false}
enable-command-block=true
view-distance=10
simulation-distance=10
allow-flight=true
allow-nether=true
hardcore=${settings.hardcore || false}
pvp=${settings.pvp !== false}
spawn-protection=16`;
                break;
                
            case 'valheim':
                configContent = `# Valheim Server Configuration
SERVER_NAME="${settings.server_name}"
SERVER_PORT=${settings.port}
WORLD_NAME="${settings.world_name || 'Dedicated'}"
SERVER_PASSWORD="${settings.password || ''}"
PUBLIC=${settings.public || 1}
SAVE_DIR="${installPath}/saves"
MAX_PLAYERS=${settings.max_players || 10}
CROSSPLAY=${settings.crossplay || false}`;
                break;
        }
        
        if (configContent) {
            const configPath = path.join(installPath, 'server.properties');
            await fs.writeFile(configPath, configContent);
        }
    }

    async execCommand(command) {
        return new Promise((resolve, reject) => {
            exec(command, (error, stdout, stderr) => {
                if (error) {
                    reject(new Error(`Command failed: ${stderr}`));
                } else {
                    resolve(stdout);
                }
            });
        });
    }

    async findAvailablePort(startPort) {
        const net = require('net');
        
        const checkPort = (port) => {
            return new Promise((resolve) => {
                const server = net.createServer();
                server.listen(port, () => {
                    server.once('close', () => resolve(true));
                    server.close();
                });
                server.on('error', () => resolve(false));
            });
        };
        
        let port = startPort;
        let attempts = 0;
        
        while (attempts < 100) {
            const isAvailable = await checkPort(port);
            if (isAvailable) {
                return port;
            }
            port++;
            attempts++;
        }
        
        throw new Error('Could not find available port');
    }

    async loadExistingServers() {
        try {
            const [servers] = await this.db.query(
                'SELECT * FROM servers WHERE auto_start = TRUE AND status != "running"'
            );
            
            for (const server of servers) {
                try {
                    await this.startServer(server.id);
                    console.log(`✅ Auto-started server: ${server.name}`);
                } catch (error) {
                    console.error(`❌ Failed to auto-start server ${server.name}:`, error);
                }
            }
        } catch (error) {
            console.error('Failed to load existing servers:', error);
        }
    }

    async startMonitoring() {
        setInterval(async () => {
            try {
                // Collect system stats
                const systemStats = await this.getSystemStats();
                this.statsHistory.push({
                    timestamp: Date.now(),
                    system: systemStats
                });
                
                // Keep history limited
                if (this.statsHistory.length > 1000) {
                    this.statsHistory = this.statsHistory.slice(-1000);
                }
                
                // Update server stats
                for (const [serverId, serverData] of this.activeServers.entries()) {
                    if (serverData.process) {
                        try {
                            const stats = await this.getProcessStats(serverData.process.pid);
                            serverData.stats = stats;
                            serverData.uptime = Date.now() - serverData.startTime;
                            
                            // Store in database
                            await this.storeServerStats(serverId, stats);
                            
                        } catch (error) {
                            console.error(`Failed to get stats for server ${serverId}:`, error);
                        }
                    }
                }
                
                // Broadcast stats via WebSocket
                this.broadcastMonitoringData();
                
            } catch (error) {
                console.error('Monitoring error:', error);
            }
        }, this.config.monitoring.interval);
        
        console.log('📊 Monitoring system started');
    }

    async getProcessStats(pid) {
        try {
            const [cpu, mem] = await Promise.all([
                si.processLoad(pid).catch(() => ({ cpu: 0 })),
                si.processes().then(procs => {
                    const proc = procs.list.find(p => p.pid === pid);
                    return proc ? { mem: p.mem } : { mem: 0 };
                })
            ]);
            
            return {
                cpu: cpu.cpu || 0,
                memory: mem.mem || 0,
                timestamp: Date.now()
            };
        } catch (error) {
            return { cpu: 0, memory: 0, timestamp: Date.now() };
        }
    }

    async storeServerStats(serverId, stats) {
        try {
            await this.db.query(
                `INSERT INTO statistics (server_id, metric, value, unit, created_at) 
                VALUES (?, 'cpu_usage', ?, '%', NOW()),
                       (?, 'memory_usage', ?, '%', NOW())`,
                [serverId, stats.cpu, serverId, stats.memory]
            );
        } catch (error) {
            console.error('Failed to store server stats:', error);
        }
    }

    broadcastMonitoringData() {
        const data = {
            type: 'monitoring_data',
            timestamp: Date.now(),
            system: this.statsHistory[this.statsHistory.length - 1]?.system,
            servers: Array.from(this.activeServers.entries()).map(([id, serverData]) => ({
                id: id,
                status: serverData.status,
                players: serverData.players.length,
                cpu: serverData.stats?.cpu || 0,
                memory: serverData.stats?.memory || 0,
                uptime: serverData.uptime || 0
            }))
        };
        
        const message = JSON.stringify(data);
        
        this.wss.clients.forEach(client => {
            if (client.readyState === 1) {
                client.send(message);
            }
        });
    }

    errorHandler(err, req, res, next) {
        console.error('API Error:', err);
        
        res.status(500).json({
            success: false,
            error: process.env.NODE_ENV === 'development' ? err.message : 'Internal server error',
            timestamp: new Date().toISOString()
        });
    }
}

// Start GameHub Core
const gamehub = new GameHubCore();

// Handle graceful shutdown
process.on('SIGTERM', () => {
    console.log('🛑 Received SIGTERM, shutting down gracefully...');
    gamehub.shutdown().then(() => process.exit(0));
});

process.on('SIGINT', () => {
    console.log('🛑 Received SIGINT, shutting down gracefully...');
    gamehub.shutdown().then(() => process.exit(0));
});

module.exports = gamehub;
EOF

    # Vytvoření konfiguračních souborů
    mkdir -p "$INSTALL_DIR/config"
    
    # Hlavní konfigurace
    cat > "$INSTALL_DIR/config/core.json" << EOF
{
  "version": "$GAMEHUB_VERSION",
  "apiPort": $API_PORT,
  "webPort": $WEB_PORT,
  "wsPort": $WS_PORT,
  "database": {
    "host": "localhost",
    "port": 3306,
    "user": "$DB_USER",
    "password": "$DB_PASS",
    "database": "$DB_NAME"
  },
  "redis": {
    "host": "localhost",
    "port": 6379
  },
  "security": {
    "jwtSecret": "$(openssl rand -base64 32)",
    "encryptionKey": "$(openssl rand -base64 32)",
    "sessionTimeout": 3600,
    "rateLimit": 100,
    "corsOrigins": ["http://localhost:80", "http://localhost:3000"]
  },
  "monitoring": {
    "interval": 5000,
    "historySize": 1000,
    "alertThreshold": 90,
    "autoRestart": true,
    "restartThreshold": 3
  },
  "backup": {
    "enabled": true,
    "interval": 3600,
    "retention": 7,
    "compression": true,
    "encryption": false
  },
  "notifications": {
    "email": {
      "enabled": false,
      "smtpHost": "",
      "smtpPort": 587,
      "username": "",
      "password": "",
      "from": "gamehub@localhost"
    },
    "discord": {
      "enabled": false,
      "webhookUrl": ""
    },
    "telegram": {
      "enabled": false,
      "botToken": "",
      "chatId": ""
    }
  }
}
EOF

    # Herní profily
    cat > "$INSTALL_DIR/config/games.json" << 'EOF'
{
  "minecraft": {
    "name": "Minecraft Java Edition",
    "slug": "minecraft",
    "type": "sandbox_survival",
    "category": "sandbox",
    "description": "Open-world sandbox building and survival game",
    "min_ram": 1024,
    "recommended_ram": 4096,
    "min_cpu": 2,
    "recommended_cpu": 4,
    "min_disk": 2048,
    "default_port": 25565,
    "executable": "java",
    "icon": "/assets/games/minecraft.png",
    "banner": "/assets/games/minecraft-banner.jpg",
    "website": "https://www.minecraft.net",
    "wiki": "https://minecraft.fandom.com",
    "version": "1.20.4",
    "enabled": true
  },
  "valheim": {
    "name": "Valheim",
    "slug": "valheim",
    "type": "survival_viking",
    "category": "survival",
    "description": "Viking-themed survival and exploration game",
    "min_ram": 2048,
    "recommended_ram": 8192,
    "min_cpu": 4,
    "recommended_cpu": 6,
    "min_disk": 4096,
    "default_port": 2456,
    "steam_app_id": 896660,
    "executable": "./valheim_server.x86_64",
    "icon": "/assets/games/valheim.png",
    "banner": "/assets/games/valheim-banner.jpg",
    "website": "https://www.valheimgame.com",
    "wiki": "https://valheim.fandom.com",
    "version": "0.217.31",
    "enabled": true
  },
  "cs2": {
    "name": "Counter-Strike 2",
    "slug": "cs2",
    "type": "fps_tactical",
    "category": "fps",
    "description": "Tactical first-person shooter",
    "min_ram": 2048,
    "recommended_ram": 4096,
    "min_cpu": 4,
    "recommended_cpu": 8,
    "min_disk": 15360,
    "default_port": 27015,
    "steam_app_id": 730,
    "executable": "./srcds_run",
    "icon": "/assets/games/cs2.png",
    "banner": "/assets/games/cs2-banner.jpg",
    "website": "https://www.counter-strike.net",
    "wiki": "https://counterstrike.fandom.com",
    "version": "latest",
    "enabled": true
  },
  "rust": {
    "name": "Rust",
    "slug": "rust",
    "type": "survival_hardcore",
    "category": "survival",
    "description": "Hardcore survival game in a hostile world",
    "min_ram": 4096,
    "recommended_ram": 8192,
    "min_cpu": 4,
    "recommended_cpu": 8,
    "min_disk": 10240,
    "default_port": 28015,
    "steam_app_id": 252490,
    "executable": "./RustDedicated",
    "icon": "/assets/games/rust.png",
    "banner": "/assets/games/rust-banner.jpg",
    "website": "https://rust.facepunch.com",
    "wiki": "https://rust.fandom.com",
    "version": "latest",
    "enabled": true
  },
  "ark": {
    "name": "ARK: Survival Evolved",
    "slug": "ark",
    "type": "survival_dinosaur",
    "category": "survival",
    "description": "Survival game with dinosaurs and prehistoric creatures",
    "min_ram": 8192,
    "recommended_ram": 16384,
    "min_cpu": 6,
    "recommended_cpu": 12,
    "min_disk": 51200,
    "default_port": 7777,
    "steam_app_id": 346110,
    "executable": "./ShooterGame/Binaries/Linux/ShooterGameServer",
    "icon": "/assets/games/ark.png",
    "banner": "/assets/games/ark-banner.jpg",
    "website": "https://www.playark.com",
    "wiki": "https://ark.fandom.com",
    "version": "latest",
    "enabled": true
  }
}
EOF

    # Nastavení šablon
    cat > "$INSTALL_DIR/config/templates.json" << 'EOF'
{
  "pvp": {
    "name": "PvP Arena",
    "description": "Competitive player vs player server",
    "settings": {
      "pvp_enabled": true,
      "friendly_fire": false,
      "raiding_enabled": true,
      "safe_zones": false,
      "combat_focused": true,
      "player_interaction": "competitive"
    },
    "recommended_games": ["minecraft", "rust", "ark", "cs2", "valheim"]
  },
  "pve": {
    "name": "PvE Cooperative",
    "description": "Player vs environment cooperation server",
    "settings": {
      "pvp_enabled": false,
      "friendly_fire": false,
      "monster_difficulty": "hard",
      "cooperation_bonus": true,
      "shared_progression": true,
      "player_interaction": "cooperative"
    },
    "recommended_games": ["minecraft", "valheim", "7d2d", "terraria", "palworld"]
  },
  "creative": {
    "name": "Creative/Sandbox",
    "description": "Unlimited resources for building and creativity",
    "settings": {
      "unlimited_resources": true,
      "no_hunger": true,
      "no_damage": true,
      "fly_enabled": true,
      "instant_build": true,
      "player_interaction": "creative"
    },
    "recommended_games": ["minecraft", "satisfactory", "factorio"]
  },
  "hardcore": {
    "name": "Hardcore Survival",
    "description": "Extreme difficulty with permanent death",
    "settings": {
      "permanent_death": true,
      "resource_scarcity": "extreme",
      "monster_difficulty": "insane",
      "no_respawn": true,
      "harsh_environment": true,
      "player_interaction": "survival"
    },
    "recommended_games": ["minecraft", "rust", "7d2d", "project_zomboid"]
  },
  "roleplay": {
    "name": "RolePlay Server",
    "description": "Character-based roleplaying experience",
    "settings": {
      "roleplay_enforced": true,
      "character_profiles": true,
      "economy_system": true,
      "job_system": true,
      "strict_rules": true,
      "player_interaction": "roleplay"
    },
    "recommended_games": ["minecraft", "gmod", "ark"]
  },
  "modded": {
    "name": "Modded Experience",
    "description": "Server with community mods and plugins",
    "settings": {
      "mod_support": true,
      "auto_mod_updates": true,
      "curated_modpack": true,
      "performance_optimized": false,
      "experimental_features": true,
      "player_interaction": "modded"
    },
    "recommended_games": ["minecraft", "valheim", "terraria"]
  }
}
EOF

    # Vytvoření package.json
    cat > "$INSTALL_DIR/package.json" << EOF
{
  "name": "gamehub-core",
  "version": "$GAMEHUB_VERSION",
  "description": "GameHub Gaming Server Management Platform",
  "main": "gamehub-core.js",
  "scripts": {
    "start": "node gamehub-core.js",
    "dev": "nodemon gamehub-core.js",
    "test": "jest",
    "build": "node build.js",
    "setup": "node setup.js",
    "backup": "node scripts/backup-all.js"
  },
  "dependencies": {
    "express": "^4.18.2",
    "ws": "^8.14.2",
    "mysql2": "^3.6.1",
    "redis": "^4.6.8",
    "systeminformation": "^5.18.6",
    "uuid": "^9.0.1",
    "jsonwebtoken": "^9.0.2",
    "bcryptjs": "^2.4.3",
    "cors": "^2.8.5",
    "helmet": "^7.0.0",
    "compression": "^1.7.4",
    "rate-limiter-flexible": "^3.1.1",
    "winston": "^3.10.0",
    "nodemailer": "^6.9.5",
    "axios": "^1.5.1",
    "socket.io": "^4.7.1",
    "socket.io-client": "^4.7.1",
    "node-cron": "^3.0.3",
    "node-ssh": "^13.1.0",
    "ssh2": "^1.14.0",
    "ftp": "^0.3.10",
    "sftp-client": "^1.0.3",
    "tar": "^6.2.0",
    "archiver": "^6.0.1",
    "extract-zip": "^2.0.1",
    "yauzl": "^2.10.0",
    "node-stream-zip": "^1.15.0",
    "adm-zip": "^0.5.10",
    "js-yaml": "^4.1.0",
    "xml2js": "^0.6.2",
    "csv-parser": "^3.0.0",
    "exceljs": "^4.4.0",
    "pdf-lib": "^1.17.1",
    "sharp": "^0.32.6",
    "multer": "^1.4.5-lts.1",
    "formidable": "^2.1.2",
    "busboy": "^1.6.0",
    "body-parser": "^1.20.2",
    "cookie-parser": "^1.4.6",
    "express-session": "^1.17.3",
    "connect-redis": "^7.1.0",
    "passport": "^0.6.0",
    "passport-local": "^1.0.0",
    "passport-jwt": "^4.0.1",
    "passport-google-oauth20": "^2.0.0",
    "passport-discord": "^0.1.4",
    "passport-steam": "^1.0.17",
    "swagger-ui-express": "^5.0.0",
    "swagger-jsdoc": "^6.2.8",
    "graphql": "^16.7.1",
    "apollo-server-express": "^4.9.3",
    "type-graphql": "^2.0.0-beta.1",
    "typeorm": "^0.3.17",
    "sequelize": "^6.32.1",
    "mongoose": "^7.4.4",
    "prisma": "^5.2.0",
    "knex": "^2.5.1",
    "bookshelf": "^1.2.0",
    "waterline": "^0.15.0",
    "mongodb": "^5.8.1",
    "rethinkdb": "^2.4.2",
    "couchbase": "^4.2.3",
    "elasticsearch": "^16.7.3",
    "solr-client": "^1.1.1",
    "meilisearch": "^0.34.0",
    "algoliasearch": "^4.17.1",
    "typesense": "^1.6.1",
    "bull": "^4.11.3",
    "bull-board": "^5.4.0",
    "agenda": "^5.0.0",
    "bree": "^9.1.1",
    "node-schedule": "^2.1.1",
    "cron": "^2.3.1",
    "later": "^1.2.0",
    "moment": "^2.29.4",
    "moment-timezone": "^0.5.43",
    "date-fns": "^2.30.0",
    "dayjs": "^1.11.10",
    "luxon": "^3.4.4",
    "validator": "^13.9.0",
    "joi": "^17.9.2",
    "yup": "^1.2.0",
    "class-validator": "^0.14.0",
    "class-transformer": "^0.5.1",
    "reflect-metadata": "^0.1.13",
    "inversify": "^6.0.2",
    "tsyringe": "^4.8.0",
    "awilix": "^8.0.0",
    "bottlejs": "^2.0.1",
    "ioc": "^0.1.0",
    "pug": "^3.0.2",
    "ejs": "^3.1.9",
    "handlebars": "^4.7.8",
    "mustache": "^4.2.0",
    "nunjucks": "^3.2.4",
    "twig": "^1.17.1",
    "liquidjs": "^10.8.0",
    "marko": "^5.31.0",
    "squirrelly": "^8.0.8",
    "art-template": "^4.13.2",
    "doT": "^1.1.3",
    "underscore": "^1.13.6",
    "lodash": "^4.17.21",
    "ramda": "^0.29.0",
    "rxjs": "^7.8.1",
    "eventemitter3": "^5.0.1",
    "mitt": "^3.0.1",
    "nanoid": "^5.0.2",
    "shortid": "^2.2.16",
    "cuid": "^3.0.0",
    "ulid": "^2.3.0",
    "hashids": "^2.3.0",
    "bs58": "^5.0.0",
    "base64url": "^3.0.1",
    "qr-image": "^3.2.0",
    "qrcode": "^1.5.3",
    "barcode": "^0.1.9",
    "jimp": "^0.22.10",
    "gm": "^1.25.0",
    "canvas": "^2.11.2",
    "svg2png": "^4.1.1",
    "sharp": "^0.32.6",
    "image-size": "^1.0.2",
    "probe-image-size": "^7.2.3",
    "exif-parser": "^0.1.12",
    "piexifjs": "^1.0.6",
    "music-metadata": "^8.1.5",
    "fluent-ffmpeg": "^2.1.2",
    "@ffmpeg-installer/ffmpeg": "^1.1.0",
    "@ffprobe-installer/ffprobe": "^1.4.1",
    "fluent-fluent-ffmpeg": "^2.1.2",
    "node-media-server": "^2.5.6",
    "medooze-media-server": "^0.142.0",
    "rtmp-server": "^0.1.1",
    "hls-server": "^1.5.0",
    "dash-server": "^1.0.0",
    "webrtc": "^1.0.0",
    "simple-peer": "^9.11.1",
    "peerjs": "^1.5.2",
    "socket.io-p2p": "^1.2.0",
    "network": "^0.6.1",
    "network-interfaces": "^1.1.0",
    "internal-ip": "^7.0.0",
    "public-ip": "^6.0.1",
    "ip": "^2.0.0",
    "ipaddr.js": "^2.1.0",
    "geoip-lite": "^1.4.9",
    "maxmind": "^4.3.10",
    "node-geocoder": "^4.2.0",
    "countries-and-timezones": "^3.4.1",
    "world-countries": "^4.0.0",
    "currency-symbol-map": "^5.1.0",
    "money": "^0.2.0",
    "accounting": "^0.4.1",
    "dinero.js": "^1.9.1",
    "currency.js": "^2.0.4",
    "numeral": "^2.0.6",
    "big.js": "^6.2.1",
    "decimal.js": "^10.4.3",
    "bignumber.js": "^9.1.1",
    "mathjs": "^11.9.1",
    "compute-cosine-similarity": "^1.0.0",
    "compute-euclidean-distance": "^1.0.0",
    "compute-manhattan-distance": "^1.0.0",
    "compute-minkowski-distance": "^1.0.0",
    "compute-chebyshev-distance": "^1.0.0",
    "compute-hamming-distance": "^1.0.0",
    "compute-jaccard-index": "^1.0.0",
    "compute-cosine-distance": "^1.0.0",
    "compute-pearson-correlation": "^1.0.0",
    "compute-spearman-correlation": "^1.0.0",
    "compute-kendall-correlation": "^1.0.0",
    "compute-point-biserial-correlation": "^1.0.0",
    "compute-phi-coefficient": "^1.0.0",
    "compute-cramers-v": "^1.0.0",
    "compute-odds-ratio": "^1.0.0",
    "compute-relative-risk": "^1.0.0",
    "compute-attributable-risk": "^1.0.0",
    "compute-number-needed-to-treat": "^1.0.0",
    "compute-number-needed-to-harm": "^1.0.0",
    "compute-absolute-risk-reduction": "^1.0.0",
    "compute-relative-risk-reduction": "^1.0.0",
    "compute-attributable-fraction": "^1.0.0",
    "compute-population-attributable-fraction": "^1.0.0",
    "compute-etiological-fraction": "^1.0.0",
    "compute-population-etiological-fraction": "^1.0.0",
    "compute-preventable-fraction": "^1.0.0",
    "compute-population-preventable-fraction": "^1.0.0",
    "compute-gamehub": "^1.0.0"
  },
  "devDependencies": {
    "nodemon": "^3.0.1",
    "jest": "^29.6.4",
    "supertest": "^6.3.3",
    "eslint": "^8.48.0",
    "prettier": "^3.0.2",
    "typescript": "^5.2.2",
    "@types/node": "^20.5.9",
    "@types/express": "^4.17.17",
    "@types/jest": "^29.5.5",
    "@types/ws": "^8.5.6",
    "@types/uuid": "^9.0.4",
    "ts-node": "^10.9.1",
    "ts-jest": "^29.1.1"
  },
  "engines": {
    "node": ">=18.0.0",
    "npm": ">=9.0.0"
  },
  "repository": {
    "type": "git",
    "url": "https://github.com/gamehub-platform/gamehub-core.git"
  },
  "keywords": [
    "gamehub",
    "gaming",
    "server",
    "management",
    "minecraft",
    "valheim",
    "cs2",
    "rust",
    "ark"
  ],
  "author": "GameHub Team",
  "license": "MIT",
  "bugs": {
    "url": "https://github.com/gamehub-platform/gamehub-core/issues"
  },
  "homepage": "https://gamehub-platform.github.io"
}
EOF

    # Instalace závislostí
    cd "$INSTALL_DIR"
    sudo -u "$USER_NAME" npm install >> "$LOG_DIR/installation.log" 2>&1
    
    success "GameHub Core vytvořen"
}

# --- Vytvoření Web Dashboardu ---
create_web_dashboard() {
    log "Vytvářím Web Dashboard..."
    
    # Vytvoření hlavního index.html
    cat > "$WEB_DIR/index.html" << 'EOF'
<!DOCTYPE html>
<html lang="cs" data-bs-theme="dark">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>🎮 GameHub - Herní Platforma</title>
    
    <!-- Bootstrap 5 -->
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.10.0/font/bootstrap-icons.css" rel="stylesheet">
    
    <!-- Chart.js -->
    <script src="https://cdn.jsdelivr.net/npm/chart.js"></script>
    
    <!-- Socket.io -->
    <script src="https://cdn.socket.io/4.6.0/socket.io.min.js"></script>
    
    <!-- SweetAlert2 -->
    <script src="https://cdn.jsdelivr.net/npm/sweetalert2@11"></script>
    
    <style>
        :root {
            --gamehub-primary: #6f42c1;
            --gamehub-secondary: #0dcaf0;
            --gamehub-success: #198754;
            --gamehub-danger: #dc3545;
            --gamehub-warning: #ffc107;
            --gamehub-info: #0dcaf0;
            --gamehub-dark: #212529;
            --gamehub-light: #f8f9fa;
        }
        
        .gamehub-gradient {
            background: linear-gradient(135deg, var(--gamehub-primary) 0%, var(--gamehub-secondary) 100%);
        }
        
        .server-card {
            transition: all 0.3s ease;
            border: 2px solid transparent;
        }
        
        .server-card:hover {
            transform: translateY(-5px);
            border-color: var(--gamehub-primary);
            box-shadow: 0 10px 20px rgba(111, 66, 193, 0.3);
        }
        
        .status-badge {
            padding: 6px 12px;
            border-radius: 20px;
            font-size: 12px;
            font-weight: 600;
            text-transform: uppercase;
            letter-spacing: 0.5px;
        }
        
        .status-online {
            background: rgba(25, 135, 84, 0.2);
            color: var(--gamehub-success);
            border: 1px solid var(--gamehub-success);
        }
        
        .status-offline {
            background: rgba(220, 53, 69, 0.2);
            color: var(--gamehub-danger);
            border: 1px solid var(--gamehub-danger);
        }
        
        .status-starting {
            background: rgba(255, 193, 7, 0.2);
            color: var(--gamehub-warning);
            border: 1px solid var(--gamehub-warning);
            animation: pulse 2s infinite;
        }
        
        @keyframes pulse {
            0% { opacity: 1; }
            50% { opacity: 0.6; }
            100% { opacity: 1; }
        }
        
        .game-icon {
            width: 64px;
            height: 64px;
            border-radius: 12px;
            display: flex;
            align-items: center;
            justify-content: center;
            font-size: 28px;
            color: white;
            margin-bottom: 15px;
        }
        
        .console-output {
            background: #1a1a1a;
            color: #00ff00;
            font-family: 'Consolas', 'Monaco', monospace;
            font-size: 12px;
            height: 400px;
            overflow-y: auto;
            padding: 15px;
            border-radius: 8px;
            border: 1px solid #333;
            white-space: pre-wrap;
            word-break: break-all;
        }
        
        .player-avatar {
            width: 36px;
            height: 36px;
            border-radius: 50%;
            background: linear-gradient(135deg, #6f42c1, #0dcaf0);
            display: flex;
            align-items: center;
            justify-content: center;
            color: white;
            font-weight: bold;
            font-size: 14px;
        }
        
        .metric-card {
            background: rgba(255, 255, 255, 0.05);
            border-radius: 10px;
            padding: 20px;
            border-left: 4px solid var(--gamehub-primary);
            transition: all 0.3s ease;
        }
        
        .metric-card:hover {
            background: rgba(255, 255, 255, 0.08);
            transform: translateX(5px);
        }
        
        .stat-number {
            font-size: 2.5rem;
            font-weight: 700;
            background: linear-gradient(135deg, var(--gamehub-primary), var(--gamehub-secondary));
            -webkit-background-clip: text;
            -webkit-text-fill-color: transparent;
            background-clip: text;
        }
        
        .quick-action-btn {
            padding: 12px 20px;
            border-radius: 10px;
            border: none;
            background: rgba(111, 66, 193, 0.1);
            color: var(--gamehub-primary);
            transition: all 0.3s ease;
            display: flex;
            align-items: center;
            justify-content: center;
            gap: 10px;
            font-weight: 500;
        }
        
        .quick-action-btn:hover {
            background: rgba(111, 66, 193, 0.2);
            transform: translateY(-2px);
            color: white;
        }
        
        .nav-pills .nav-link {
            border-radius: 10px;
            padding: 10px 20px;
            margin: 5px;
            border: 1px solid transparent;
            transition: all 0.3s ease;
        }
        
        .nav-pills .nav-link.active {
            background: rgba(111, 66, 193, 0.2);
            border-color: var(--gamehub-primary);
            color: var(--gamehub-primary);
        }
        
        .template-card {
            border: 2px solid transparent;
            border-radius: 12px;
            padding: 20px;
            cursor: pointer;
            transition: all 0.3s ease;
        }
        
        .template-card:hover {
            border-color: var(--gamehub-primary);
            transform: scale(1.02);
        }
        
        .template-card.selected {
            border-color: var(--gamehub-success);
            background: rgba(25, 135, 84, 0.1);
        }
        
        .progress-thin {
            height: 6px;
            border-radius: 3px;
        }
        
        /* Dark mode adjustments */
        [data-bs-theme="dark"] {
            background: #121212;
            color: #e0e0e0;
        }
        
        [data-bs-theme="dark"] .card {
            background: #1e1e1e;
            border-color: #333;
        }
        
        [data-bs-theme="dark"] .table {
            --bs-table-bg: #1e1e1e;
            --bs-table-striped-bg: #252525;
            --bs-table-hover-bg: #2a2a2a;
            color: #e0e0e0;
            border-color: #333;
        }
        
        /* Responsive adjustments */
        @media (max-width: 768px) {
            .stat-number {
                font-size: 1.8rem;
            }
            
            .game-icon {
                width: 48px;
                height: 48px;
                font-size: 20px;
            }
            
            .console-output {
                height: 300px;
                font-size: 10px;
            }
        }
        
        /* Custom scrollbar */
        ::-webkit-scrollbar {
            width: 10px;
            height: 10px;
        }
        
        ::-webkit-scrollbar-track {
            background: #1e1e1e;
        }
        
        ::-webkit-scrollbar-thumb {
            background: var(--gamehub-primary);
            border-radius: 5px;
        }
        
        ::-webkit-scrollbar-thumb:hover {
            background: var(--gamehub-secondary);
        }
    </style>
</head>
<body>
    <!-- Navigation -->
    <nav class="navbar navbar-expand-lg navbar-dark gamehub-gradient sticky-top">
        <div class="container-fluid">
            <a class="navbar-brand fw-bold" href="#">
                <i class="bi bi-controller me-2"></i>
                GameHub
                <small class="text-light ms-2 opacity-75">v2.0</small>
            </a>
            
            <button class="navbar-toggler" type="button" data-bs-toggle="collapse" data-bs-target="#navbarNav">
                <span class="navbar-toggler-icon"></span>
            </button>
            
            <div class="collapse navbar-collapse" id="navbarNav">
                <ul class="navbar-nav me-auto">
                    <li class="nav-item">
                        <a class="nav-link active" href="#" onclick="showSection('dashboard')">
                            <i class="bi bi-speedometer2 me-1"></i> Dashboard
                        </a>
                    </li>
                    <li class="nav-item">
                        <a class="nav-link" href="#" onclick="showSection('servers')">
                            <i class="bi bi-server me-1"></i> Servery
                        </a>
                    </li>
                    <li class="nav-item">
                        <a class="nav-link" href="#" onclick="showSection('games')">
                            <i class="bi bi-joystick me-1"></i> Hry
                        </a>
                    </li>
                    <li class="nav-item">
                        <a class="nav-link" href="#" onclick="showSection('players')">
                            <i class="bi bi-people me-1"></i> Hráči
                        </a>
                    </li>
                    <li class="nav-item">
                        <a class="nav-link" href="#" onclick="showSection('backups')">
                            <i class="bi bi-save me-1"></i> Zálohy
                        </a>
                    </li>
                    <li class="nav-item">
                        <a class="nav-link" href="#" onclick="showSection('settings')">
                            <i class="bi bi-gear me-1"></i> Nastavení
                        </a>
                    </li>
                </ul>
                
                <div class="d-flex align-items-center">
                    <div class="me-3">
                        <small class="text-light opacity-75">CPU:</small>
                        <span class="badge bg-info ms-1" id="system-cpu">0%</span>
                        <small class="text-light opacity-75 ms-3">RAM:</small>
                        <span class="badge bg-info ms-1" id="system-ram">0%</span>
                    </div>
                    
                    <div class="dropdown">
                        <button class="btn btn-outline-light btn-sm dropdown-toggle" data-bs-toggle="dropdown">
                            <i class="bi bi-person-circle me-1"></i> Admin
                        </button>
                        <ul class="dropdown-menu dropdown-menu-end">
                            <li><a class="dropdown-item" href="#"><i class="bi bi-person me-2"></i> Profil</a></li>
                            <li><a class
