# Copilot Instructions: Nymea:Kiosk Ultimate System

## Project Overview

**Nymea:Kiosk Ultimate System** is an all-in-one educational IoT platform for Raspberry Pi 5 that combines:
- **nymea:core**: IoT device management backend
- **nymea:app**: Web/mobile frontend interface
- **Kiosk mode**: Full-screen educational/monitoring display
- **Monitoring stack**: Prometheus + Grafana for metrics and dashboards
- **Education framework**: Project management and student workflow support

The system targets Czech educational settings with educational IoT projects (weather stations, robotics, programming).

## Architecture Pattern

### Multi-Component Deployment
The system is **NOT** a single monolith. Key components:

1. **Service Layer** (`install-all.sh`): Master orchestration script
   - Coordinates installation of all subsystems in order
   - Uses logging to `/var/log/nymea-kiosk-install.log`
   - Implements error handling with `set -e` and fallback with `|| true`

2. **Configuration Paradigm**: YAML-first approach
   - System config: `Hlavní konfigurační soubor.yaml` (main config)
   - Docker services: Multi-container setup with Postgres DB + Prometheus + Education app
   - Kiosk settings: Display orientation, autostart behavior

3. **Modular Scripts** (`scripts/` directory): Each script handles ONE concern
   - `install-plugins.sh`: Nymea plugin installation
   - `setup-kiosk.sh`: Display configuration (landscape/portrait, autostart)
   - `configure-backup.sh`: Backup scheduling (daily retention=30 days)
   - `export-rules.sh` / `import-rules.sh`: Rule portability
   - `install-nodered.sh`: Optional Node-RED integration

### Data Flow
```
Raspberry Pi 5
├─ nymea:core (daemon) → manages IoT devices via /etc/nymea/
├─ nymea:app (web UI on :8080) → user interface
├─ Prometheus (:9090) → metrics collection
├─ Grafana (:3000) → dashboards
├─ Postgres (:5432) → education project storage
└─ Kiosk display (:8080 fullscreen) → monitoring view
```

## Key Development Workflows

### Installation & Deployment
```bash
chmod +x install-all.sh
sudo ./install-all.sh
```
Idempotent pattern: Script logs all actions, handles missing files gracefully with `|| true`. Suitable for retry scenarios.

### Adding New Plugins
Edit `scripts/install-plugins.sh` following this pattern:
```bash
sudo apt-get install -y nymea-plugin-<name>
sudo systemctl restart nymead
```

### Backup/Restore Operations
- **Backup**: `scripts/configure-backup.sh --frequency=daily --retention=30`
- **Restore**: `scripts/restore-backup.sh`
- Uses cron scheduling with daily 02:00 execution

### Configuration Changes
1. Edit YAML config file (`Hlavní konfigurační soubor.yaml`)
2. Validate syntax
3. Reload services: `sudo systemctl restart nymead`

## Project-Specific Conventions

### Naming & Language
- **Czech language everywhere**: Variables, comments, documentation use Czech
- **Path conventions**: 
  - Projects: `/home/education-system/projects`
  - Configs: `/app/config`
  - Backups: `/home/nymea/backups/`

### Error Handling Pattern
Standard approach across all scripts:
```bash
set -e  # Fail on first error
LOG_FILE="/var/log/nymea-kiosk-install.log"
log() { echo "$(date '+%Y-%m-%d %H:%M:%S') - $1" | tee -a "$LOG_FILE"; }
```

### Logging Expectation
All operations should produce timestamped logs in `/var/log/nymea-kiosk-install.log`. Use the `log()` function for consistency.

## Integration Points

### nymea Plugin System
Plugins extend nymea:core functionality. Adding a sensor type requires:
1. Install plugin: `sudo apt-get install -y nymea-plugin-<type>`
2. Configure in nymea config
3. Restart daemon: `sudo systemctl restart nymead`

### Docker Compose Stack
The system uses Docker for:
- **education-app** (8080): Main application container
- **education-db** (Postgres): Project/student data persistence
- **monitoring** (Prometheus 9091): Metrics collection

Services communicate via `education-network` bridge (172.20.0.0/16).

### Home Assistant Integration
Optional integration via MQTT broker (see `sprava/` management scripts). Not enabled by default.

## Critical Files

| File | Purpose | Modification Pattern |
|------|---------|----------------------|
| `install-all.sh` | Master deployment orchestrator | Add new subsystem installations here |
| `Hlavní konfigurační soubor.yaml` | System-wide configuration | Modify to change network, security, project defaults |
| `Docker konfigurace.yaml` | Service topology | Edit to add/remove containers or change ports |
| `scripts/install-plugins.sh` | Plugin management | Add new plugin installations |
| `Implementace projektového managementu.py` | Student project tracking | Extend ProjectManager class for new workflows |

## Common Tasks

### Enable Automatic Updates
```bash
# Uncomment/add in main config YAML:
security:
  automatic_updates: true
```

### Add New Student
Use `sprava/Přidání studenta.sh` script

### Configure Remote Access
- SSH port: 2222 (from config)
- Enable VNC via `raspi-config`
- Firewall rules in setup script

### Memory Optimization
See `sprava/Optimalizace SWAP a paměti.sh` for swap configuration on Pi 5.

## Testing & Validation

### Service Health Check
```bash
systemctl status nymead              # Core service
systemctl status prometheus          # Metrics
systemctl status grafana-server      # Dashboards
sudo ufw status                       # Firewall
```

### Configuration Validation
- Check `/var/log/nymea-kiosk-install.log` for installation errors
- Verify all services started: `sudo systemctl list-units --type=service --all`
- Access web interfaces (check IP from script output)

---

**Last Updated:** November 2025 | **System Version:** 3.5 | **Target Platform:** Raspberry Pi 5 (64-bit)
