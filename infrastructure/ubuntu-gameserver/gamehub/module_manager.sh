#!/bin/bash
# ======================================================
# GameHub Module Manager & Auto-Healing System
# Version: 3.0.0
# Usage: ./manage-modules.sh [command] [options]
# ======================================================

set -e

# --- Configuration ---
INSTALL_DIR="/opt/gamehub"
CONFIG_DIR="/etc/gamehub"
LOG_DIR="/var/log/gamehub"
MODULE_CONFIG="$CONFIG_DIR/modules.json"
HEALTH_LOG="$LOG_DIR/health-check.log"

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m'

# --- Logging Functions ---
log() {
    echo -e "${BLUE}[$(date '+%Y-%m-%d %H:%M:%S')]${NC} $1" | tee -a "$HEALTH_LOG"
}

success() {
    echo -e "${GREEN}✓${NC} $1" | tee -a "$HEALTH_LOG"
}

error() {
    echo -e "${RED}✗${NC} $1" | tee -a "$HEALTH_LOG"
}

warning() {
    echo -e "${YELLOW}!${NC} $1" | tee -a "$HEALTH_LOG"
}

info() {
    echo -e "${CYAN}➜${NC} $1"
}

# --- Module Status Check ---
check_module_status() {
    local module=$1
    local enabled=$(jq -r ".modules.$module" "$MODULE_CONFIG" 2>/dev/null || echo "false")
    
    if [ "$enabled" = "true" ]; then
        echo -e "${GREEN}●${NC} $module: enabled"
        return 0
    else
        echo -e "${RED}○${NC} $module: disabled"
        return 1
    fi
}

# --- Service Health Check ---
check_service_health() {
    local service=$1
    
    if systemctl is-active --quiet "$service"; then
        success "$service is running"
        return 0
    else
        error "$service is not running"
        return 1
    fi
}

# --- Database Health Check ---
check_database_health() {
    log "Checking database health..."
    
    if systemctl is-active --quiet mariadb; then
        if mysql -e "SELECT 1" &>/dev/null; then
            success "Database is healthy"
            return 0
        else
            error "Database connection failed"
            return 1
        fi
    else
        error "MariaDB service is not running"
        return 1
    fi
}

# --- Redis Health Check ---
check_redis_health() {
    log "Checking Redis health..."
    
    if systemctl is-active --quiet redis-server; then
        if redis-cli ping &>/dev/null; then
            success "Redis is healthy"
            return 0
        else
            error "Redis connection failed"
            return 1
        fi
    else
        error "Redis service is not running"
        return 1
    fi
}

# --- Disk Space Check ---
check_disk_space() {
    log "Checking disk space..."
    
    local usage=$(df / | tail -1 | awk '{print $5}' | sed 's/%//')
    
    if [ "$usage" -lt 80 ]; then
        success "Disk usage: ${usage}% (healthy)"
        return 0
    elif [ "$usage" -lt 90 ]; then
        warning "Disk usage: ${usage}% (warning)"
        return 1
    else
        error "Disk usage: ${usage}% (critical)"
        return 2
    fi
}

# --- Memory Check ---
check_memory() {
    log "Checking memory usage..."
    
    local mem_usage=$(free | grep Mem | awk '{printf("%.0f", $3/$2 * 100.0)}')
    
    if [ "$mem_usage" -lt 80 ]; then
        success "Memory usage: ${mem_usage}% (healthy)"
        return 0
    elif [ "$mem_usage" -lt 90 ]; then
        warning "Memory usage: ${mem_usage}% (warning)"
        return 1
    else
        error "Memory usage: ${mem_usage}% (critical)"
        return 2
    fi
}

# --- CPU Check ---
check_cpu() {
    log "Checking CPU usage..."
    
    local cpu_usage=$(top -bn1 | grep "Cpu(s)" | sed "s/.*, *\([0-9.]*\)%* id.*/\1/" | awk '{print 100 - $1}')
    local cpu_int=${cpu_usage%.*}
    
    if [ "$cpu_int" -lt 80 ]; then
        success "CPU usage: ${cpu_int}% (healthy)"
        return 0
    elif [ "$cpu_int" -lt 90 ]; then
        warning "CPU usage: ${cpu_int}% (warning)"
        return 1
    else
        error "CPU usage: ${cpu_int}% (critical)"
        return 2
    fi
}

# --- Network Check ---
check_network() {
    log "Checking network connectivity..."
    
    if ping -c 1 8.8.8.8 &>/dev/null; then
        success "Network connectivity is healthy"
        return 0
    else
        error "Network connectivity failed"
        return 1
    fi
}

# --- Port Check ---
check_ports() {
    log "Checking service ports..."
    
    local ports=(
        "3001:GameHub API"
        "8081:WebSocket"
        "3306:MariaDB"
        "6379:Redis"
    )
    
    local all_ok=true
    
    for port_info in "${ports[@]}"; do
        IFS=':' read -r port name <<< "$port_info"
        
        if netstat -tuln | grep -q ":$port "; then
            success "$name (port $port) is listening"
        else
            error "$name (port $port) is not listening"
            all_ok=false
        fi
    done
    
    if [ "$all_ok" = true ]; then
        return 0
    else
        return 1
    fi
}

# --- Auto-Healing Functions ---
heal_service() {
    local service=$1
    
    log "Attempting to heal service: $service"
    
    # Try to restart the service
    if systemctl restart "$service"; then
        sleep 3
        if systemctl is-active --quiet "$service"; then
            success "Successfully healed $service"
            return 0
        fi
    fi
    
    error "Failed to heal $service"
    return 1
}

heal_database() {
    log "Attempting to heal database..."
    
    # Restart MariaDB
    if heal_service "mariadb"; then
        # Verify connection
        if mysql -e "SELECT 1" &>/dev/null; then
            success "Database healed successfully"
            return 0
        fi
    fi
    
    error "Failed to heal database"
    return 1
}

heal_redis() {
    log "Attempting to heal Redis..."
    
    if heal_service "redis-server"; then
        if redis-cli ping &>/dev/null; then
            success "Redis healed successfully"
            return 0
        fi
    fi
    
    error "Failed to heal Redis"
    return 1
}

heal_disk_space() {
    log "Attempting to free disk space..."
    
    # Clean old logs
    find "$LOG_DIR" -name "*.log" -mtime +30 -delete
    
    # Clean apt cache
    apt-get clean
    apt-get autoclean
    
    # Clean old backups
    find /backup -name "*.tar.gz" -mtime +7 -delete
    
    # Clean Docker
    docker system prune -af --volumes
    
    success "Disk cleanup completed"
    check_disk_space
}

heal_memory() {
    log "Attempting to free memory..."
    
    # Drop caches
    sync
    echo 3 > /proc/sys/vm/drop_caches
    
    # Restart heavy services if needed
    local mem_usage=$(free | grep Mem | awk '{printf("%.0f", $3/$2 * 100.0)}')
    
    if [ "$mem_usage" -gt 90 ]; then
        warning "Memory still critical, restarting services..."
        systemctl restart gamehub
    fi
    
    success "Memory optimization completed"
    check_memory
}

# --- Comprehensive Health Check ---
health_check() {
    log "Running comprehensive health check..."
    echo ""
    
    local failures=0
    
    # System resources
    check_disk_space || ((failures++))
    check_memory || ((failures++))
    check_cpu || ((failures++))
    check_network || ((failures++))
    
    # Services
    check_service_health "gamehub" || ((failures++))
    check_database_health || ((failures++))
    check_redis_health || ((failures++))
    check_ports || ((failures++))
    
    echo ""
    if [ $failures -eq 0 ]; then
        success "All health checks passed ✓"
        return 0
    else
        error "Health check failed with $failures issues"
        return 1
    fi
}

# --- Auto-Healing Routine ---
auto_heal() {
    log "Starting auto-healing routine..."
    echo ""
    
    # Check and heal services
    if ! check_service_health "gamehub"; then
        heal_service "gamehub"
    fi
    
    if ! check_database_health; then
        heal_database
    fi
    
    if ! check_redis_health; then
        heal_redis
    fi
    
    # Check and heal resources
    local disk_status
    check_disk_space
    disk_status=$?
    
    if [ $disk_status -ge 1 ]; then
        heal_disk_space
    fi
    
    local mem_status
    check_memory
    mem_status=$?
    
    if [ $mem_status -ge 1 ]; then
        heal_memory
    fi
    
    echo ""
    success "Auto-healing routine completed"
}

# --- Module Management ---
list_modules() {
    echo ""
    echo "╔══════════════════════════════════════════════════════════════╗"
    echo "║                     Module Status                            ║"
    echo "╚══════════════════════════════════════════════════════════════╝"
    echo ""
    
    check_module_status "core"
    check_module_status "emulators"
    check_module_status "steam"
    check_module_status "dev"
    check_module_status "remote"
    check_module_status "monitoring"
    check_module_status "backup"
    check_module_status "dashboard"
    
    echo ""
}

enable_module() {
    local module=$1
    
    log "Enabling module: $module"
    
    # Update config
    jq ".modules.$module = true" "$MODULE_CONFIG" > "$MODULE_CONFIG.tmp"
    mv "$MODULE_CONFIG.tmp" "$MODULE_CONFIG"
    
    # Run installation based on module
    case $module in
        "emulators")
            flatpak install -y flathub org.libretro.RetroArch
            ;;
        "steam")
            apt install -y steam-installer
            ;;
        "monitoring")
            systemctl enable --now cockpit.socket
            systemctl enable --now netdata
            ;;
        "backup")
            timeshift --create --comments "Module enabled" --yes
            ;;
    esac
    
    success "Module $module enabled"
}

disable_module() {
    local module=$1
    
    log "Disabling module: $module"
    
    # Update config
    jq ".modules.$module = false" "$MODULE_CONFIG" > "$MODULE_CONFIG.tmp"
    mv "$MODULE_CONFIG.tmp" "$MODULE_CONFIG"
    
    success "Module $module disabled"
}

# --- Update System ---
update_modules() {
    log "Updating all modules..."
    echo ""
    
    # System update
    apt update
    apt upgrade -y
    
    # Node packages
    cd "$INSTALL_DIR" && npm update
    
    # Flatpak updates
    flatpak update -y
    
    # Docker images
    docker images --format "{{.Repository}}:{{.Tag}}" | grep gamehub | xargs -r docker pull
    
    success "All modules updated"
}

# --- Status Report ---
status_report() {
    echo ""
    echo "╔══════════════════════════════════════════════════════════════╗"
    echo "║                  GameHub Status Report                       ║"
    echo "╚══════════════════════════════════════════════════════════════╝"
    echo ""
    
    # System info
    echo -e "${CYAN}System Information:${NC}"
    echo "  Hostname: $(hostname)"
    echo "  Uptime: $(uptime -p)"
    echo "  Load: $(uptime | awk -F'load average:' '{print $2}')"
    echo ""
    
    # Resource usage
    echo -e "${CYAN}Resource Usage:${NC}"
    echo "  CPU: $(top -bn1 | grep "Cpu(s)" | sed "s/.*, *\([0-9.]*\)%* id.*/\1/" | awk '{print 100 - $1}')%"
    echo "  Memory: $(free -h | awk '/^Mem:/ {printf "%s / %s (%.0f%%)", $3, $2, $3/$2*100}')"
    echo "  Disk: $(df -h / | tail -1 | awk '{printf "%s / %s (%s)", $3, $2, $5}')"
    echo ""
    
    # Services
    echo -e "${CYAN}Services:${NC}"
    systemctl is-active gamehub && echo -e "  ${GREEN}●${NC} GameHub" || echo -e "  ${RED}○${NC} GameHub"
    systemctl is-active mariadb && echo -e "  ${GREEN}●${NC} MariaDB" || echo -e "  ${RED}○${NC} MariaDB"
    systemctl is-active redis-server && echo -e "  ${GREEN}●${NC} Redis" || echo -e "  ${RED}○${NC} Redis"
    systemctl is-active nginx && echo -e "  ${GREEN}●${NC} Nginx" || echo -e "  ${RED}○${NC} Nginx"
    echo ""
    
    # Modules
    echo -e "${CYAN}Modules:${NC}"
    list_modules
}

# --- Backup Configuration ---
backup_config() {
    log "Backing up configuration..."
    
    local backup_file="/backup/gamehub-config-$(date +%Y%m%d-%H%M%S).tar.gz"
    
    tar -czf "$backup_file" \
        "$CONFIG_DIR" \
        "$INSTALL_DIR/package.json" \
        "$INSTALL_DIR/modules/" \
        2>/dev/null
    
    success "Configuration backed up to: $backup_file"
}

# --- Restore Configuration ---
restore_config() {
    local backup_file=$1
    
    if [ ! -f "$backup_file" ]; then
        error "Backup file not found: $backup_file"
        return 1
    fi
    
    log "Restoring configuration from: $backup_file"
    
    tar -xzf "$backup_file" -C / 2>/dev/null
    
    success "Configuration restored"
    systemctl restart gamehub
}

# --- Main Menu ---
show_menu() {
    echo ""
    echo "╔══════════════════════════════════════════════════════════════╗"
    echo "║            GameHub Module Manager & Auto-Healing             ║"
    echo "╚══════════════════════════════════════════════════════════════╝"
    echo ""
    echo "Commands:"
    echo "  health          - Run health check"
    echo "  heal            - Run auto-healing routine"
    echo "  status          - Show detailed status report"
    echo "  list            - List all modules"
    echo "  enable <module> - Enable a module"
    echo "  disable <module>- Disable a module"
    echo "  update          - Update all modules"
    echo "  backup          - Backup configuration"
    echo "  restore <file>  - Restore configuration"
    echo "  watch           - Continuous monitoring mode"
    echo ""
}

# --- Continuous Monitoring ---
watch_mode() {
    log "Starting continuous monitoring mode (Ctrl+C to exit)..."
    
    while true; do
        clear
        status_report
        
        # Auto-heal if needed
        if ! health_check >/dev/null 2>&1; then
            warning "Health issues detected, auto-healing..."
            auto_heal
        fi
        
        sleep 60
    done
}

# --- Main Function ---
main() {
    case "${1:-menu}" in
        health)
            health_check
            ;;
        heal)
            auto_heal
            ;;
        status)
            status_report
            ;;
        list)
            list_modules
            ;;
        enable)
            enable_module "$2"
            ;;
        disable)
            disable_module "$2"
            ;;
        update)
            update_modules
            ;;
        backup)
            backup_config
            ;;
        restore)
            restore_config "$2"
            ;;
        watch)
            watch_mode
            ;;
        menu|*)
            show_menu
            ;;
    esac
}

# Run
main "$@"
