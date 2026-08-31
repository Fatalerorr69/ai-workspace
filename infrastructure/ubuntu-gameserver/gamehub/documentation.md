# GameHub Ultimate Gaming Server
## Complete Documentation v3.0.0

---

## 📋 Table of Contents

1. [Quick Start](#quick-start)
2. [System Requirements](#system-requirements)
3. [Installation](#installation)
4. [Module Management](#module-management)
5. [Backup & Recovery](#backup-recovery)
6. [Game Streaming](#game-streaming)
7. [Monitoring & Health](#monitoring-health)
8. [Troubleshooting](#troubleshooting)
9. [API Reference](#api-reference)
10. [Advanced Configuration](#advanced-configuration)

---

## 🚀 Quick Start

### Installation (5 minutes)

```bash
# Download installer
wget https://raw.githubusercontent.com/gamehub/install/main/gamehub-installer.sh

# Make executable
chmod +x gamehub-installer.sh

# Run installation
sudo ./gamehub-installer.sh
```

### First Access

After installation, access your server:

- **Web Dashboard**: `http://YOUR_SERVER_IP`
- **Cockpit**: `https://YOUR_SERVER_IP:9090`
- **Netdata**: `http://YOUR_SERVER_IP:19999`
- **API**: `http://YOUR_SERVER_IP:3001`

### Quick Commands

```bash
# Check status
sudo systemctl status gamehub

# View logs
sudo journalctl -u gamehub -f

# Run health check
sudo /opt/gamehub/modules/manage-modules.sh health

# Auto-heal issues
sudo /opt/gamehub/modules/manage-modules.sh heal

# Backup now
sudo /usr/local/bin/gamehub-backup-daily.sh
```

---

## 💻 System Requirements

### Minimum Requirements

- **OS**: Ubuntu 22.04 or 24.04 LTS
- **CPU**: 4 cores @ 2.5GHz
- **RAM**: 8GB
- **Storage**: 100GB SSD
- **Network**: 100Mbps internet connection
- **GPU**: Optional (recommended for streaming)

### Recommended Requirements

- **OS**: Ubuntu 24.04 LTS
- **CPU**: 8+ cores @ 3.0GHz+
- **RAM**: 16GB+
- **Storage**: 256GB+ NVMe SSD
- **Network**: 1Gbps internet connection
- **GPU**: NVIDIA RTX series or AMD RX 6000+ series

### Optimal Configuration

- **CPU**: AMD Ryzen 9 / Intel i9
- **RAM**: 32GB+ DDR4/DDR5
- **Storage**: 512GB+ NVMe SSD + 2TB+ HDD for games
- **Network**: 10Gbps internal, 1Gbps+ WAN
- **GPU**: NVIDIA RTX 4070+ or AMD RX 7800 XT+

---

## 📦 Installation

### Standard Installation

```bash
# 1. Update system
sudo apt update && sudo apt upgrade -y

# 2. Clone repository
git clone https://github.com/gamehub/gamehub-server.git
cd gamehub-server

# 3. Run installer
sudo ./install.sh

# 4. Select modules when prompted
# Enter module numbers: 1 2 6 8 (for example)
```

### Automated Installation (Non-Interactive)

```bash
# Install all modules
sudo ./install.sh --all

# Install specific modules
sudo ./install.sh --modules "core,emulators,monitoring,dashboard"
```

### Ansible Installation

```bash
# Install Ansible
sudo apt install -y ansible

# Run playbook
ansible-playbook gamehub-playbook.yml

# Custom configuration
ansible-playbook gamehub-playbook.yml \
  --extra-vars "install_steam=true install_dev=false"
```

---

## 🔧 Module Management

### Available Modules

1. **Core** (Required)
   - GameHub API server
   - Database management
   - WebSocket server
   - User authentication

2. **Emulators**
   - RetroArch (multi-system)
   - PPSSPP (PSP)
   - Dolphin (GameCube/Wii)
   - PCSX2 (PS2)
   - DOSBox (DOS)
   - ScummVM (Adventure games)

3. **Steam + Proton**
   - Steam client
   - Proton compatibility layer
   - Proton-GE custom builds
   - Wine integration

4. **Development Tools**
   - GitHub CLI
   - VS Code Server
   - Docker & Docker Compose
   - Git with LFS
   - Multiple language runtimes

5. **Remote Access**
   - Cockpit web interface
   - X2Go remote desktop
   - TigerVNC server
   - SSH with key authentication

6. **Monitoring**
   - Netdata real-time monitoring
   - System resource tracking
   - Performance metrics
   - Alert system

7. **Backup & Recovery**
   - Timeshift snapshots
   - Cloud synchronization
   - Database backups
   - Game save backups

8. **Web Dashboard**
   - Real-time statistics
   - Server management
   - User interface
   - Mobile responsive

### Managing Modules

```bash
# List installed modules
/opt/gamehub/modules/manage-modules.sh list

# Enable a module
/opt/gamehub/modules/manage-modules.sh enable emulators

# Disable a module
/opt/gamehub/modules/manage-modules.sh disable steam

# Update all modules
/opt/gamehub/modules/manage-modules.sh update

# View module status
/opt/gamehub/modules/manage-modules.sh status
```

---

## 💾 Backup & Recovery

### Backup Strategy

GameHub implements a 3-tier backup strategy:

1. **Daily Backups** (Retained: 7 days)
   - Configurations
   - Game saves
   - Database dumps
   - Runs at: 2:00 AM daily

2. **Weekly Backups** (Retained: 4 weeks)
   - Full system snapshot
   - All installed software
   - User data
   - Runs at: 3:00 AM Sunday

3. **Monthly Archives** (Retained: 12 months)
   - Complete system archive
   - Compressed for long-term storage
   - Cloud backup
   - Runs at: 4:00 AM 1st of month

### Manual Backup

```bash
# Create immediate backup
sudo /usr/local/bin/gamehub-backup-daily.sh

# Full system backup
sudo /usr/local/bin/gamehub-backup-weekly.sh

# Configuration only
sudo tar -czf /backup/config-$(date +%Y%m%d).tar.gz /etc/gamehub /opt/gamehub/config
```

### Recovery

```bash
# Start recovery wizard
sudo /usr/local/bin/gamehub-restore.sh

# Or restore specific components:

# Restore configuration
sudo tar -xzf /backup/gamehub/daily/configs-YYYYMMDD.tar.gz -C /

# Restore database
gunzip < /backup/gamehub/daily/database-YYYYMMDD.sql.gz | mysql

# Restore saves
sudo tar -xzf /backup/gamehub/daily/saves-YYYYMMDD.tar.gz -C /
```

### Cloud Sync Configuration

```bash
# Configure Google Drive
rclone config create gdrive drive

# Test connection
rclone lsd gdrive:

# Manual sync
rclone sync /backup/gamehub gdrive:/gamehub-backups/
```

---

## 🎮 Game Streaming

### Supported Platforms

- **Sunshine** (Recommended - Open Source)
- **Moonlight** (NVIDIA GameStream Protocol)
- **Parsec** (Cloud gaming platform)
- **Steam Remote Play** (Valve's solution)

### Sunshine Setup (Recommended)

```bash
# Configure streaming
/opt/gamehub/setup-streaming.sh

# Select option: 1 (Sunshine)

# Access Sunshine web UI
https://YOUR_SERVER_IP:47990

# Default credentials: admin / admin
# Change immediately after first login!
```

### Streaming Clients

**PC/Mac:**
- Moonlight: https://moonlight-stream.org/
- Sunshine Client: Built-in web interface

**Android:**
- Moonlight (Play Store)
- Parsec (Play Store)

**iOS:**
- Moonlight (App Store)
- Parsec (App Store)

**Steam Deck:**
- Moonlight (Discover Store)
- Chiaki (PS Remote Play alternative)

### Streaming Optimization

```bash
# Apply network optimizations
sudo sysctl -w net.core.rmem_max=134217728
sudo sysctl -w net.core.wmem_max=134217728
sudo sysctl -w net.ipv4.tcp_congestion_control=bbr

# Set CPU governor to performance
sudo cpupower frequency-set -g performance

# NVIDIA GPU optimizations
sudo nvidia-smi -pm 1
sudo nvidia-smi -pl 300  # Set power limit to 300W
```

### Quality Settings

| Resolution | Bitrate | FPS | Latency |
|------------|---------|-----|---------|
| 1080p      | 10 Mbps | 60  | ~20ms   |
| 1440p      | 20 Mbps | 60  | ~25ms   |
| 4K         | 50 Mbps | 60  | ~30ms   |

---

## 📊 Monitoring & Health

### Health Check System

```bash
# Run comprehensive health check
sudo /opt/gamehub/modules/manage-modules.sh health

# Continuous monitoring mode (Ctrl+C to exit)
sudo /opt/gamehub/modules/manage-modules.sh watch

# Auto-healing routine
sudo /opt/gamehub/modules/manage-modules.sh heal
```

### Monitored Metrics

- **System Resources**
  - CPU usage and load average
  - Memory usage (RAM + Swap)
  - Disk space and I/O
  - Network traffic

- **Services**
  - GameHub API status
  - Database connectivity
  - Redis cache status
  - Web server status

- **Gaming Performance**
  - Active game servers
  - Player count
  - FPS metrics
  - Latency measurements

### Accessing Monitoring Tools

```bash
# Netdata (Real-time)
http://YOUR_SERVER_IP:19999

# Cockpit (System Management)
https://YOUR_SERVER_IP:9090

# GameHub Dashboard
http://YOUR_SERVER_IP
```

### Setting Up Alerts

```bash
# Edit alert configuration
sudo nano /etc/netdata/health.d/gamehub.conf

# Add custom alert
alarm: high_cpu_usage
   on: system.cpu
every: 10s
 warn: $this > 80
 crit: $this > 90
 info: CPU usage is critically high
   to: sysadmin

# Restart Netdata
sudo systemctl restart netdata
```

---

## 🔍 Troubleshooting

### Common Issues

#### Issue: GameHub service won't start

```bash
# Check service status
sudo systemctl status gamehub

# View recent logs
sudo journalctl -u gamehub -n 50 --no-pager

# Common fixes:
1. Check database connection
   sudo systemctl status mariadb
   
2. Check Redis
   sudo systemctl status redis-server
   
3. Check port conflicts
   sudo netstat -tuln | grep 3001
   
4. Restart service
   sudo systemctl restart gamehub
```

#### Issue: High memory usage

```bash
# Check memory hogs
sudo ps aux --sort=-%mem | head -n 10

# Clear system cache
sudo sync
sudo sysctl -w vm.drop_caches=3

# Restart GameHub
sudo systemctl restart gamehub
```

#### Issue: Slow network performance

```bash
# Test network speed
speedtest-cli

# Check for packet loss
ping -c 100 8.8.8.8 | tail -n 3

# Optimize network settings
sudo /opt/gamehub/optimize-network.sh

# Check firewall rules
sudo ufw status verbose
```

#### Issue: Emulator games not loading

```bash
# Check Flatpak apps
flatpak list

# Update RetroArch cores
flatpak run org.libretro.RetroArch --menu

# Check ROM permissions
sudo chown -R gamehub:gamehub /opt/gamehub/roms
sudo chmod -R 755 /opt/gamehub/roms

# Verify ROM location
ls -la /opt/gamehub/roms/
```

#### Issue: Streaming connection fails

```bash
# Check Sunshine status
sudo systemctl status sunshine

# Check firewall
sudo ufw status | grep -E "4798|4800"

# Test local connection
curl http://localhost:47989

# Check GPU encoding support
nvidia-smi  # For NVIDIA
vainfo      # For Intel/AMD
```

### Log Locations

```bash
# GameHub logs
/var/log/gamehub/gamehub.log
/var/log/gamehub/gamehub-error.log

# Installation log
/var/log/gamehub/installation.log

# Health check log
/var/log/gamehub/health-check.log

# Backup logs
/var/log/gamehub/backup-daily.log
/var/log/gamehub/backup-weekly.log

# View all logs
tail -f /var/log/gamehub/*.log
```

### Performance Tuning

```bash
# Database optimization
sudo mysql_upgrade --force
sudo mysqlcheck -o --all-databases

# Redis optimization
sudo nano /etc/redis/redis.conf
# Set: maxmemory 256mb
#      maxmemory-policy allkeys-lru

# System optimization
sudo nano /etc/sysctl.conf
# Add:
#   vm.swappiness=10
#   net.core.rmem_max=134217728
#   net.core.wmem_max=134217728

sudo sysctl -p
```

---

## 🔌 API Reference

### Base URL

```
http://YOUR_SERVER_IP:3001/api
```

### Authentication

```bash
# Get API key
curl -X POST http://localhost:3001/api/auth/login \
  -H "Content-Type: application/json" \
  -d '{"username":"admin","password":"your_password"}'

# Use API key in requests
curl -H "Authorization: Bearer YOUR_API_KEY" \
  http://localhost:3001/api/servers
```

### Endpoints

#### System

```bash
# Health check
GET /api/health

# System stats
GET /api/stats

# Module list
GET /api/modules
```

#### Servers

```bash
# List servers
GET /api/servers

# Create server
POST /api/servers
{
  "game": "minecraft",
  "name": "My Server",
  "port": 25565
}

# Start server
POST /api/servers/{id}/start

# Stop server
POST /api/servers/{id}/stop

# Server status
GET /api/servers/{id}/status
```

#### Monitoring

```bash
# Real-time metrics
WebSocket: ws://YOUR_SERVER_IP:8081

# Subscribe to server
{
  "type": "subscribe",
  "serverId": 1
}

# Send command
{
  "type": "command",
  "serverId": 1,
  "command": "list"
}
```

### WebSocket Events

```javascript
// Connect
const ws = new WebSocket('ws://localhost:8081');

// Listen for events
ws.onmessage = (event) => {
  const data = JSON.parse(event.data);
  
  switch(data.type) {
    case 'server_output':
      console.log('Server:', data.lines);
      break;
    case 'player_event':
      console.log('Player:', data.event, data.player);
      break;
    case 'monitoring_data':
      console.log('Stats:', data.system);
      break;
  }
};
```

---

## ⚙️ Advanced Configuration

### Custom Game Profiles

```bash
# Edit game profiles
sudo nano /opt/gamehub/config/games.json

# Add custom game
{
  "mygame": {
    "name": "My Custom Game",
    "slug": "mygame",
    "default_port": 7777,
    "executable": "./start-server.sh",
    "install_script": "#!/bin/bash\n..."
  }
}
```

### Database Tuning

```bash
# Edit MariaDB config
sudo nano /etc/mysql/mariadb.conf.d/50-server.cnf

# Recommended settings for gaming server:
[mysqld]
innodb_buffer_pool_size = 4G
innodb_log_file_size = 512M
max_connections = 200
query_cache_size = 64M
```

### NGINX Reverse Proxy

```bash
# Edit NGINX config
sudo nano /etc/nginx/sites-available/gamehub

server {
    listen 80;
    server_name gamehub.yourdomain.com;
    
    location / {
        proxy_pass http://localhost:3001;
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection 'upgrade';
        proxy_set_header Host $host;
        proxy_cache_bypass $http_upgrade;
    }
    
    location /ws {
        proxy_pass http://localhost:8081;
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection "Upgrade";
    }
}

# Enable and reload
sudo ln -s /etc/nginx/sites-available/gamehub /etc/nginx/sites-enabled/
sudo nginx -t
sudo systemctl reload nginx
```

### SSL/TLS Certificate (Let's Encrypt)

```bash
# Install Certbot
sudo apt install -y certbot python3-certbot-nginx

# Get certificate
sudo certbot --nginx -d gamehub.yourdomain.com

# Auto-renewal is configured automatically
```

---

## 📝 Additional Resources

### Official Links

- **Website**: https://gamehub.io
- **GitHub**: https://github.com/gamehub
- **Documentation**: https://docs.gamehub.io
- **Community**: https://discord.gg/gamehub

### Support

- **Discord**: Join our community server
- **GitHub Issues**: Report bugs and request features
- **Email**: support@gamehub.io

### Contributing

```bash
# Fork repository
git clone https://github.com/YOUR_USERNAME/gamehub-server.git

# Create feature branch
git checkout -b feature/amazing-feature

# Commit changes
git commit -m "Add amazing feature"

# Push and create PR
git push origin feature/amazing-feature
```

---

## 📄 License

GameHub is licensed under the MIT License. See LICENSE file for details.

---

## 🙏 Credits

- Built with ❤️ by the GameHub community
- Powered by: Node.js, MariaDB, Redis, Nginx
- Streaming: Sunshine, Moonlight
- Monitoring: Netdata, Cockpit

---

**Version**: 3.0.0  
**Last Updated**: December 2025  
**Status**: Production Ready ✅
