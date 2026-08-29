#!/bin/bash
# ======================================================
# GameHub Backup & Streaming Configuration
# Version: 3.0.0
# ======================================================

# --- BACKUP STRATEGY ---

setup_backup_system() {
    echo "╔══════════════════════════════════════════════════════════════╗"
    echo "║           GameHub Backup & Recovery System                   ║"
    echo "╚══════════════════════════════════════════════════════════════╝"
    echo ""
    
    # Create backup directory structure
    mkdir -p /backup/gamehub/{daily,weekly,monthly,configs,saves,databases}
    
    # Install backup tools
    apt install -y timeshift duplicity rclone restic borgbackup
    
    # Configure Timeshift for system snapshots
    cat > /etc/timeshift.json << 'EOF'
{
  "backup_device_uuid": "",
  "parent_device_uuid": "",
  "do_first_run": false,
  "btrfs_mode": false,
  "include_btrfs_home": false,
  "stop_cron_emails": true,
  "schedule_monthly": true,
  "schedule_weekly": true,
  "schedule_daily": true,
  "schedule_hourly": false,
  "schedule_boot": false,
  "count_monthly": 2,
  "count_weekly": 3,
  "count_daily": 5,
  "count_hourly": 6,
  "count_boot": 5,
  "snapshot_size": 0,
  "snapshot_count": 0
}
EOF

    # Create backup scripts
    create_backup_scripts
    
    # Setup cron jobs
    setup_backup_cron
    
    # Configure cloud sync
    setup_cloud_sync
}

create_backup_scripts() {
    # Daily backup script
    cat > /usr/local/bin/gamehub-backup-daily.sh << 'EOF'
#!/bin/bash
BACKUP_DIR="/backup/gamehub/daily"
DATE=$(date +%Y%m%d-%H%M%S)

# Backup configurations
tar -czf "$BACKUP_DIR/configs-$DATE.tar.gz" \
    /etc/gamehub \
    /opt/gamehub/config \
    /opt/gamehub/package.json

# Backup game saves
tar -czf "$BACKUP_DIR/saves-$DATE.tar.gz" \
    /opt/gamehub/saves \
    ~/.steam/userdata \
    ~/.config/RetroArch/saves

# Backup databases
mysqldump --all-databases | gzip > "$BACKUP_DIR/database-$DATE.sql.gz"

# Cleanup old backups (keep 7 days)
find "$BACKUP_DIR" -name "*.tar.gz" -mtime +7 -delete
find "$BACKUP_DIR" -name "*.sql.gz" -mtime +7 -delete

# Upload to cloud
rclone sync "$BACKUP_DIR" gdrive:/gamehub-backups/daily/

echo "Daily backup completed: $DATE"
EOF

    # Weekly full backup script
    cat > /usr/local/bin/gamehub-backup-weekly.sh << 'EOF'
#!/bin/bash
BACKUP_DIR="/backup/gamehub/weekly"
DATE=$(date +%Y%m%d)

# Full system backup with Restic
restic -r "$BACKUP_DIR" backup \
    /opt/gamehub \
    /etc/gamehub \
    /var/www/gamehub \
    /home/gamehub \
    --exclude "*.log" \
    --exclude "node_modules" \
    --tag weekly

# Upload to cloud
rclone sync "$BACKUP_DIR" gdrive:/gamehub-backups/weekly/

# Cleanup old snapshots (keep 4 weeks)
restic -r "$BACKUP_DIR" forget --keep-weekly 4 --prune

echo "Weekly backup completed: $DATE"
EOF

    # Monthly archive script
    cat > /usr/local/bin/gamehub-backup-monthly.sh << 'EOF'
#!/bin/bash
BACKUP_DIR="/backup/gamehub/monthly"
DATE=$(date +%Y%m)

# Create comprehensive archive
tar -czf "$BACKUP_DIR/gamehub-full-$DATE.tar.gz" \
    /opt/gamehub \
    /etc/gamehub \
    /var/www/gamehub \
    /backup/gamehub/databases

# Upload to cloud
rclone copy "$BACKUP_DIR/gamehub-full-$DATE.tar.gz" \
    gdrive:/gamehub-backups/monthly/

# Keep only 12 months
find "$BACKUP_DIR" -name "*.tar.gz" -mtime +365 -delete

echo "Monthly archive completed: $DATE"
EOF

    # Recovery script
    cat > /usr/local/bin/gamehub-restore.sh << 'EOF'
#!/bin/bash
# GameHub Recovery Script

show_menu() {
    echo "╔══════════════════════════════════════════════════════════════╗"
    echo "║              GameHub Recovery Menu                           ║"
    echo "╚══════════════════════════════════════════════════════════════╝"
    echo ""
    echo "1) Restore configuration"
    echo "2) Restore game saves"
    echo "3) Restore database"
    echo "4) Restore full system"
    echo "5) List available backups"
    echo "6) Exit"
    echo ""
    read -p "Select option: " choice
    
    case $choice in
        1) restore_config ;;
        2) restore_saves ;;
        3) restore_database ;;
        4) restore_full ;;
        5) list_backups ;;
        6) exit 0 ;;
        *) echo "Invalid option" ;;
    esac
}

restore_config() {
    echo "Available configuration backups:"
    ls -lh /backup/gamehub/daily/configs-*.tar.gz | tail -10
    echo ""
    read -p "Enter backup filename: " filename
    
    if [ -f "/backup/gamehub/daily/$filename" ]; then
        tar -xzf "/backup/gamehub/daily/$filename" -C /
        systemctl restart gamehub
        echo "Configuration restored successfully"
    else
        echo "Backup not found"
    fi
}

restore_saves() {
    echo "Available save backups:"
    ls -lh /backup/gamehub/daily/saves-*.tar.gz | tail -10
    echo ""
    read -p "Enter backup filename: " filename
    
    if [ -f "/backup/gamehub/daily/$filename" ]; then
        tar -xzf "/backup/gamehub/daily/$filename" -C /
        echo "Game saves restored successfully"
    else
        echo "Backup not found"
    fi
}

restore_database() {
    echo "Available database backups:"
    ls -lh /backup/gamehub/daily/database-*.sql.gz | tail -10
    echo ""
    read -p "Enter backup filename: " filename
    
    if [ -f "/backup/gamehub/daily/$filename" ]; then
        gunzip < "/backup/gamehub/daily/$filename" | mysql
        echo "Database restored successfully"
    else
        echo "Backup not found"
    fi
}

restore_full() {
    echo "Available full backups:"
    restic -r /backup/gamehub/weekly snapshots | tail -20
    echo ""
    read -p "Enter snapshot ID: " snapshot_id
    
    restic -r /backup/gamehub/weekly restore "$snapshot_id" --target /
    echo "Full system restored successfully"
    echo "Please reboot the system"
}

list_backups() {
    echo "╔══════════════════════════════════════════════════════════════╗"
    echo "║                    Available Backups                         ║"
    echo "╚══════════════════════════════════════════════════════════════╝"
    echo ""
    echo "Daily backups:"
    ls -lh /backup/gamehub/daily/ | tail -5
    echo ""
    echo "Weekly backups:"
    restic -r /backup/gamehub/weekly snapshots | tail -5
    echo ""
    echo "Monthly archives:"
    ls -lh /backup/gamehub/monthly/ | tail -5
}

show_menu
EOF

    chmod +x /usr/local/bin/gamehub-backup-*.sh
    chmod +x /usr/local/bin/gamehub-restore.sh
}

setup_backup_cron() {
    # Add cron jobs
    (crontab -l 2>/dev/null; cat << 'CRON'
# GameHub Backup Schedule
0 2 * * * /usr/local/bin/gamehub-backup-daily.sh >> /var/log/gamehub/backup-daily.log 2>&1
0 3 * * 0 /usr/local/bin/gamehub-backup-weekly.sh >> /var/log/gamehub/backup-weekly.log 2>&1
0 4 1 * * /usr/local/bin/gamehub-backup-monthly.sh >> /var/log/gamehub/backup-monthly.log 2>&1
CRON
) | crontab -
}

setup_cloud_sync() {
    echo ""
    echo "╔══════════════════════════════════════════════════════════════╗"
    echo "║              Cloud Sync Configuration                        ║"
    echo "╚══════════════════════════════════════════════════════════════╝"
    echo ""
    echo "Select cloud provider:"
    echo "1) Google Drive"
    echo "2) Dropbox"
    echo "3) OneDrive"
    echo "4) Nextcloud"
    echo "5) Skip cloud sync"
    echo ""
    read -p "Choice: " cloud_choice
    
    case $cloud_choice in
        1)
            rclone config create gdrive drive scope=drive
            ;;
        2)
            rclone config create dropbox dropbox
            ;;
        3)
            rclone config create onedrive onedrive
            ;;
        4)
            read -p "Nextcloud URL: " nextcloud_url
            read -p "Username: " nextcloud_user
            read -p "Password: " nextcloud_pass
            rclone config create nextcloud webdav \
                url="$nextcloud_url" \
                user="$nextcloud_user" \
                pass="$(rclone obscure $nextcloud_pass)"
            ;;
        5)
            echo "Skipping cloud sync configuration"
            return
            ;;
    esac
    
    echo "Cloud sync configured successfully"
}

# --- STREAMING CONFIGURATION ---

setup_streaming() {
    echo "╔══════════════════════════════════════════════════════════════╗"
    echo "║           GameHub Streaming Configuration                    ║"
    echo "╚══════════════════════════════════════════════════════════════╝"
    echo ""
    
    echo "Select streaming platform:"
    echo "1) Sunshine (Open Source - Recommended)"
    echo "2) Moonlight (NVIDIA GameStream Protocol)"
    echo "3) Parsec"
    echo "4) Steam Remote Play"
    echo "5) All of the above"
    echo ""
    read -p "Choice: " stream_choice
    
    case $stream_choice in
        1|5) install_sunshine ;;
    esac
    
    case $stream_choice in
        2|5) install_moonlight ;;
    esac
    
    case $stream_choice in
        3|5) install_parsec ;;
    esac
    
    case $stream_choice in
        4|5) configure_steam_remote ;;
    esac
    
    # Configure firewall for streaming
    configure_streaming_firewall
    
    # Setup game streaming optimizations
    optimize_for_streaming
}

install_sunshine() {
    echo "Installing Sunshine..."
    
    # Download latest Sunshine
    SUNSHINE_VERSION=$(curl -s https://api.github.com/repos/LizardByte/Sunshine/releases/latest | grep tag_name | cut -d '"' -f 4)
    wget "https://github.com/LizardByte/Sunshine/releases/download/${SUNSHINE_VERSION}/sunshine-ubuntu-22.04-amd64.deb" \
        -O /tmp/sunshine.deb
    
    apt install -y /tmp/sunshine.deb
    
    # Configure Sunshine
    mkdir -p ~/.config/sunshine
    cat > ~/.config/sunshine/sunshine.conf << 'EOF'
{
  "address_family": "both",
  "channels": 2,
  "pkey": "",
  "cert": "",
  "sunshine_name": "GameHub Server",
  "output_name": 0,
  "port": 47989,
  "upnp": "on",
  "fps": [10, 30, 60, 90, 120],
  "min_threads": 1,
  "hevc_mode": 0,
  "av1_mode": 0
}
EOF
    
    # Create systemd service
    cat > /etc/systemd/system/sunshine.service << 'EOF'
[Unit]
Description=Sunshine Streaming Server
StartLimitIntervalSec=500
StartLimitBurst=5

[Service]
ExecStart=/usr/bin/sunshine
Restart=on-failure
RestartSec=5s

[Install]
WantedBy=multi-user.target
EOF
    
    systemctl daemon-reload
    systemctl enable sunshine
    systemctl start sunshine
    
    echo "Sunshine installed successfully"
    echo "Access at: https://localhost:47990"
}

install_moonlight() {
    echo "Installing Moonlight tools..."
    
    # Install NVIDIA drivers if not present
    if ! command -v nvidia-smi &> /dev/null; then
        apt install -y nvidia-driver-525
    fi
    
    # Install Moonlight Internet Hosting Tool
    wget https://github.com/moonlight-stream/moonlight-common-c/releases/latest/download/moonlight-embedded.deb \
        -O /tmp/moonlight.deb
    apt install -y /tmp/moonlight.deb
    
    echo "Moonlight configured"
}

install_parsec() {
    echo "Installing Parsec..."
    
    wget https://builds.parsec.app/package/parsec-linux.deb -O /tmp/parsec.deb
    apt install -y /tmp/parsec.deb
    
    echo "Parsec installed"
    echo "Please configure via: parsecd app:login"
}

configure_steam_remote() {
    echo "Configuring Steam Remote Play..."
    
    # Enable Steam Remote Play
    mkdir -p ~/.steam/steam/remoteplay
    cat > ~/.steam/steam/remoteplay/streaming_client.txt << 'EOF'
"streaming_client"
{
    "EnableStreaming"       "1"
    "EnableRemotePlayTogetherHost"      "1"
    "H264"          "1"
    "HEVC"          "1"
    "EnableHardwareEncoding"        "1"
    "EnableTrafficPriority"         "1"
    "StreamingQuality"      "3"
}
EOF
    
    echo "Steam Remote Play configured"
}

configure_streaming_firewall() {
    echo "Configuring firewall for streaming..."
    
    # Sunshine ports
    ufw allow 47984:47990/tcp comment "Sunshine"
    ufw allow 47998:48000/udp comment "Sunshine"
    
    # Moonlight/GameStream ports
    ufw allow 47984:47990/tcp comment "Moonlight"
    ufw allow 48010/udp comment "Moonlight"
    
    # Parsec ports
    ufw allow 8000:8010/tcp comment "Parsec"
    
    # Steam Remote Play
    ufw allow 27031:27036/tcp comment "Steam Remote Play"
    ufw allow 27031:27036/udp comment "Steam Remote Play"
    
    echo "Firewall configured for streaming"
}

optimize_for_streaming() {
    echo "Applying streaming optimizations..."
    
    # Kernel parameters for low latency
    cat >> /etc/sysctl.conf << 'EOF'

# Streaming optimizations
net.core.rmem_max=134217728
net.core.wmem_max=134217728
net.ipv4.tcp_rmem=4096 87380 67108864
net.ipv4.tcp_wmem=4096 65536 67108864
net.core.netdev_max_backlog=30000
net.ipv4.tcp_no_metrics_save=1
net.ipv4.tcp_congestion_control=bbr
net.core.default_qdisc=fq
EOF
    
    sysctl -p
    
    # CPU governor for performance
    apt install -y cpufrequtils
    echo 'GOVERNOR="performance"' > /etc/default/cpufrequtils
    systemctl restart cpufrequtils
    
    # GPU optimizations
    if command -v nvidia-smi &> /dev/null; then
        nvidia-smi -pm 1
        nvidia-smi -pl 300
    fi
    
    echo "Streaming optimizations applied"
}

# --- SYNC CONFIGURATION ---

setup_save_sync() {
    echo "╔══════════════════════════════════════════════════════════════╗"
    echo "║              Game Save Synchronization                       ║"
    echo "╚══════════════════════════════════════════════════════════════╝"
    echo ""
    
    # Create sync script
    cat > /usr/local/bin/gamehub-sync-saves.sh << 'EOF'
#!/bin/bash
# Sync game saves across devices

SAVE_DIRS=(
    "$HOME/.steam/userdata"
    "$HOME/.config/RetroArch/saves"
    "$HOME/.local/share/Steam/userdata"
    "/opt/gamehub/saves"
)

# Sync to cloud
for dir in "${SAVE_DIRS[@]}"; do
    if [ -d "$dir" ]; then
        rclone sync "$dir" "gdrive:/gamehub-saves/$(basename $dir)/" \
            --transfers 4 \
            --checkers 8 \
            --fast-list \
            --exclude "*.log" \
            --exclude "*.tmp"
    fi
done

echo "Save sync completed: $(date)"
EOF
    
    chmod +x /usr/local/bin/gamehub-sync-saves.sh
    
    # Add to cron (every 15 minutes)
    (crontab -l 2>/dev/null; echo "*/15 * * * * /usr/local/bin/gamehub-sync-saves.sh >> /var/log/gamehub/sync.log 2>&1") | crontab -
    
    echo "Save sync configured"
}

# --- MAIN EXECUTION ---

main() {
    echo "╔══════════════════════════════════════════════════════════════╗"
    echo "║     GameHub Backup & Streaming Configuration Wizard          ║"
    echo "╚══════════════════════════════════════════════════════════════╝"
    echo ""
    
    PS3="Select configuration: "
    options=(
        "Setup Backup System"
        "Setup Game Streaming"
        "Setup Save Synchronization"
        "All of the above"
        "Exit"
    )
    
    select opt in "${options[@]}"; do
        case $REPLY in
            1)
                setup_backup_system
                break
                ;;
            2)
                setup_streaming
                break
                ;;
            3)
                setup_save_sync
                break
                ;;
            4)
                setup_backup_system
                setup_streaming
                setup_save_sync
                break
                ;;
            5)
                exit 0
                ;;
            *)
                echo "Invalid option"
                ;;
        esac
    done
    
    echo ""
    echo "╔══════════════════════════════════════════════════════════════╗"
    echo "║            Configuration completed successfully!             ║"
    echo "╚══════════════════════════════════════════════════════════════╝"
    echo ""
    echo "Backup commands:"
    echo "  • Daily backup:   /usr/local/bin/gamehub-backup-daily.sh"
    echo "  • Weekly backup:  /usr/local/bin/gamehub-backup-weekly.sh"
    echo "  • Monthly backup: /usr/local/bin/gamehub-backup-monthly.sh"
    echo "  • Restore:        /usr/local/bin/gamehub-restore.sh"
    echo ""
    echo "Streaming access:"
    echo "  • Sunshine:       https://localhost:47990"
    echo "  • Parsec:         parsecd app:connect"
    echo ""
    echo "Save sync runs automatically every 15 minutes"
    echo ""
}

# Run if executed directly
if [ "${BASH_SOURCE[0]}" = "${0}" ]; then
    main "$@"
fi
