# Nymea:Kiosk Ultimate System - Úplná dokumentace

## 📋 Obsah

- [Přehled](#přehled)
- [Instalace](#instalace)
- [Architektura](#architektura)
- [Konfigurace](#konfigurace)
- [Správa projektů](#správa-projektů)
- [Monitoring](#monitoring)
- [Troubleshooting](#troubleshooting)
- [API Reference](#api-reference)

## Přehled

**Nymea:Kiosk Ultimate System** je kompletní vzdělávací IoT platforma pro Raspberry Pi 5 s integrací:

- **nymea:core**: Backend pro správu IoT zařízení
- **nymea:app**: Webové rozhraní pro konfiguraci
- **Monitoring**: Prometheus + Grafana pro metriky
- **Projekty**: Systém pro správu studentských projektů
- **Kiosk mode**: Full-screen displej pro monitorování

### Hlavní vlastnosti

✅ Český jazyk v celém systému  
✅ Automatizovaná instalace a konfigurace  
✅ Robustní error handling a logging  
✅ Pokročilý projekt management  
✅ Plné zabezpečení (UFW, Fail2Ban)  
✅ Automatizované zálohování  
✅ Docker orchestrace  

## Instalace

### Minimální požadavky

- Raspberry Pi 5 (64-bit OS)
- 8 GB RAM doporučeno
- 32 GB SD karta (Class 10+)
- Připojení k internetu

### Krátký návod

```bash
# 1. Klonování repozitáře
git clone https://github.com/Fatalerorr69/nymeakiosk-ultimate-system.git
cd nymeakiosk-ultimate-system

# 2. Spuštění instalátoru
chmod +x src/scripts/install-all.sh
sudo src/scripts/install-all.sh

# 3. Po instalaci
# Web rozhraní: http://<RPi-IP>:8080
# Grafana: http://<RPi-IP>:3000
# Prometheus: http://<RPi-IP>:9090
```

### Pokročilá instalace

```bash
# Pouze Nymea
sudo ./src/scripts/install-all.sh --skip-monitoring

# S vlastní URL pro kiosk
sudo ./src/scripts/setup-kiosk.sh --url http://custom.url --orientation portrait

# Nastavení backup
sudo ./src/scripts/backup.sh backup
```

## Architektura

### Struktura projektu

```
nymeakiosk-ultimate-system/
├── src/
│   ├── python/              # Python moduly
│   │   ├── __init__.py
│   │   ├── project_manager.py    # Správa projektů
│   │   ├── config_manager.py     # Správa konfigurací
│   │   └── utils.py              # Utility funkce
│   ├── scripts/             # Shell scripty
│   │   ├── install-all.sh        # Hlavní instalátor
│   │   ├── setup-kiosk.sh        # Kiosk nastavení
│   │   └── backup.sh             # Zálohování
│   └── config/              # Konfigurační soubory
├── tests/                   # Unit a integrační testy
│   ├── unit/
│   └── integration/
├── docs/                    # Dokumentace
│   ├── guides/
│   ├── api/
│   └── architecture/
└── README.md
```

### Service architektura

```
┌─────────────────────────────────────────┐
│         Nymea:Kiosk Ultimate System     │
├─────────────────────────────────────────┤
│  Kiosk Display (Chromium)               │
│  ↓                                       │
│  nymea:app (Web UI - port 8080)        │
│  ↓                                       │
│  nymea:core (daemon)                   │
│  ├─ Postgres DB (port 5432)            │
│  ├─ MQTT Broker (opt.)                 │
│  └─ Node-RED (opt., port 1880)         │
│                                         │
│  Monitoring Stack                       │
│  ├─ Prometheus (port 9090)             │
│  └─ Grafana (port 3000)                │
└─────────────────────────────────────────┘
```

## Konfigurace

### Hlavní konfigurační soubor

Lokace: `/app/config/main-config.yaml`

```yaml
# Konfigurace vzdělávacího systému
system:
  name: "Raspberry Pi Education System"
  version: "3.5.0"
  language: "cs"
  timezone: "Europe/Prague"

network:
  hostname: "rpi-edu-001"
  static_ip: "192.168.1.100"
  gateway: "192.168.1.1"
  dns_servers: ["8.8.8.8", "1.1.1.1"]

security:
  ssh_port: 2222
  firewall_enabled: true
  automatic_updates: true
  backup_schedule: "0 2 * * *"  # Denně v 2:00

education:
  default_projects_path: "/home/education-system/projects"
  teacher_username: "teacher"
  student_username_prefix: "student"

projects:
  categories:
    - name: "programming"
      enabled: true
    - name: "robotics"
      enabled: true
    - name: "iot"
      enabled: true

monitoring:
  enabled: true
  metrics_port: 9090
  alerting_enabled: true
```

### Konfigurace přes Python

```python
from src.python.config_manager import ConfigManager

# Načtení konfigurace
cm = ConfigManager('/app/config')
config = cm.load_config('main-config.yaml')

# Čtení hodnot
hostname = cm.get('network.hostname')
projects_path = cm.get('education.default_projects_path')

# Nastavení hodnot
cm.set('network.hostname', 'new-hostname')
cm.save_config('main-config.yaml')
```

## Správa projektů

### Vytvoření projektu

```python
from src.python.project_manager import ProjectManager

pm = ProjectManager()

project = pm.create_project(
    name="Weather Station",
    description="Měření teplotních dat",
    objectives=[
        "Sběr dat",
        "Vizualizace",
        "Analýza"
    ],
    timeline="4 týdny",
    created_by="teacher"
)
```

### Přidělování úkolů

```python
task = pm.add_task(
    project_name="Weather Station",
    task_name="Připojit senzor",
    assignee="Jan Novák",
    deadline="2025-12-15",
    priority="high"
)
```

### Sledování pokroku

```python
# Aktualizace stavu úkolu
pm.update_task_status(task_id=1, new_status="in_progress")

# Získání pokroku
progress = pm.track_progress("Weather Station")
print(f"Pokrok: {progress}%")

# Generování reportu
report = pm.generate_report("Weather Station")
```

### Statistiky projektu

```python
stats = pm.get_project_stats("Weather Station")
print(f"Celkem úkolů: {stats['total_tasks']}")
print(f"Hotových: {stats['completed']}")
print(f"Kritických: {stats['by_priority']['critical']}")
```

## Monitoring

### Přístup do Grafany

1. Otevřete: `http://<RPi-IP>:3000`
2. Přihlaste se: `admin` / `admin`
3. Změňte heslo pro první přihlášení
4. Přidejte Prometheus zdroj dat: `http://localhost:9090`

### Vytvoření custom dashboardu

Použijte Grafana UI pro vytváření custom dashboardů nebo importujte JSON:

```json
{
  "dashboard": {
    "title": "Nymea System Status",
    "panels": [
      {
        "title": "System CPU",
        "targets": [
          {
            "expr": "node_cpu_seconds_total"
          }
        ]
      }
    ]
  }
}
```

### Metriky

Dostupné metriky (Prometheus):

- `nymea_devices_count` - Počet zařízení
- `nymea_rules_count` - Počet pravidel
- `system_cpu_percent` - CPU utilizace
- `system_memory_percent` - RAM utilizace
- `system_disk_percent` - Disk utilizace

## Troubleshooting

### Nymea daemon se nespouští

```bash
# Kontrola statusu
systemctl status nymead

# Čtení logů
journalctl -u nymead -n 50

# Restart
sudo systemctl restart nymead
```

### Problém s weitem rozhraním

```bash
# Kontrola port 8080
sudo netstat -tlnp | grep 8080

# Restart nymea-app
sudo systemctl restart nymea-app

# Čtení logů aplikace
tail -f /var/log/nymea-kiosk/install.log
```

### Problémy s kiosk displejem

```bash
# Test start-kiosk skriptu
/usr/local/bin/start-kiosk.sh

# Kontrola X serveru
ps aux | grep Xvfb

# Restart displeje
sudo systemctl restart nymea-kiosk
```

### Záloha se neprovádí

```bash
# Manuální spuštění
sudo /usr/local/bin/backup-nymea.sh

# Kontrola cron jobů
sudo crontab -l

# Kontrola práv
ls -la /home/nymea/backups/
```

## API Reference

### ProjectManager API

#### `create_project(name, description, objectives, timeline, created_by)`

Vytvoří nový projekt.

**Parametry:**
- `name` (str): Název projektu
- `description` (str): Popis
- `objectives` (list): Seznam cílů
- `timeline` (str): Časový plán
- `created_by` (str, opt): Tvůrce (default: "teacher")

**Vrací:** Dict s daty projektu

```python
project = pm.create_project(
    name="AI Project",
    description="Projekt na AI",
    objectives=["Learn ML", "Build model"],
    timeline="6 weeks"
)
```

#### `add_task(project_name, task_name, assignee, deadline, description, priority)`

Přidá úkol do projektu.

**Parametry:**
- `project_name` (str): Název projektu
- `task_name` (str): Název úkolu
- `assignee` (str): Osoba na starosti
- `deadline` (str): ISO format (YYYY-MM-DD)
- `description` (str, opt): Popis
- `priority` (str, opt): low|normal|high|critical

**Vrací:** Dict s daty úkolu

#### `update_task_status(task_id, new_status, notes)`

Aktualizuje stav úkolu.

**Parametry:**
- `task_id` (int): ID úkolu
- `new_status` (str): assigned|in_progress|completed|blocked
- `notes` (str, opt): Poznámky

**Vrací:** bool (úspěch)

#### `track_progress(project_name)`

Zjistí pokrok projektu v procentech.

**Vrací:** float (0-100)

#### `generate_report(project_name)`

Vytvoří detailní report o projektu.

**Vrací:** Dict s reportem

#### `get_project_stats(project_name)`

Vrátí statistiky projektu.

**Vrací:** Dict se statistikami

### ConfigManager API

#### `load_config(filename)`

Načte YAML konfiguraci.

**Vrací:** Dict nebo None

#### `get(key, default)`

Reads config value with dot notation support.

**Vrací:** Any (value or default)

#### `set(key, value)`

Nastaví konfigurační hodnotu.

**Vrací:** bool

#### `save_config(filename)`

Uloží konfiguraci do YAML souboru.

**Vrací:** bool

---

**Poslední aktualizace:** Listopadu 2025  
**Verze:** 3.5.0  
**Platforma:** Raspberry Pi 5 (64-bit)
