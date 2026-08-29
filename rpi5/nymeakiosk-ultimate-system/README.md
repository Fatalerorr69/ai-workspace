# Nymea:Kiosk Ultimate System 🚀

[![Python Tests](https://github.com/Fatalerorr69/nymeakiosk-ultimate-system/workflows/Python%20Unit%20Tests/badge.svg)](https://github.com/Fatalerorr69/nymeakiosk-ultimate-system/actions)
[![Shell Script Linting](https://github.com/Fatalerorr69/nymeakiosk-ultimate-system/workflows/Shell%20Script%20Linting/badge.svg)](https://github.com/Fatalerorr69/nymeakiosk-ultimate-system/actions)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)

> Kompletní vzdělávací IoT platforma pro Raspberry Pi 5

**Nymea:Kiosk Ultimate System** je all-in-one řešení pro vzdělávací IoT projekty v českých školách. Kombinuje výkonný backend nymea:core s moderním webovým rozhraním, pokročilým projekto-vým managementem a plným monitoringem.

## ✨ Hlavní vlastnosti

- 🎓 **Vzdělávací fokus** - Projekt management pro studenty a učitele
- 🔧 **nymea:core** - Výkonný IoT backend s podporou stovek zařízení
- 📊 **Monitoring** - Prometheus + Grafana pro real-time metriky
- 🔒 **Zabezpečení** - UFW firewall, Fail2Ban, SSH na custom portu
- 💾 **Zálohy** - Automatizované denní zálohování s retenční politikou
- 🖥️ **Kiosk Mode** - Full-screen displej pro monitorování
- 🐳 **Docker** - Multi-container orchestration s Postgres DB
- 🇨🇿 **Čeština** - Kompletní lokalizace v českém jazyce

## 📦 Součásti

| Komponenta | Popis | Port |
|-----------|-------|------|
| **nymea:core** | IoT device backend | - |
| **nymea:app** | Web rozhraní | 8080 |
| **Grafana** | Dashboardy a metriky | 3000 |
| **Prometheus** | Time-series databáze | 9090 |
| **Postgres** | Projekt & student DB | 5432 |
| **Node-RED** (opt) | Automatizační engine | 1880 |

## 🚀 Rychlý start

### Minimální požadavky

- **Hardware:** Raspberry Pi 5 (8GB RAM doporučeno)
- **OS:** Raspberry Pi OS 64-bit
- **Storage:** 32GB SD karta (Class 10+)
- **Síť:** Připojení k internetu

### Instalace (3 kroky)

```bash
# 1️⃣ Klonování
git clone https://github.com/Fatalerorr69/nymeakiosk-ultimate-system.git
cd nymeakiosk-ultimate-system

# 2️⃣ Spuštění instalátoru
chmod +x src/scripts/install-all.sh
sudo src/scripts/install-all.sh

# 3️⃣ Přístup k systému
# Web UI: http://YOUR_RPI_IP:8080
# Grafana: http://YOUR_RPI_IP:3000
# Prometheus: http://YOUR_RPI_IP:9090
```

## 📖 Dokumentace

- **[Úplná dokumentace](docs/DOCUMENTATION.md)** - Kompletní API reference
- **[Quickstart](docs/QUICKSTART.md)** - Rychlý úvod
- **[Troubleshooting](docs/TROUBLESHOOTING.md)** - Řešení problémů
- **[Copilot Instructions](.github/copilot-instructions.md)** - Pro AI coding agents

## 🏗️ Architektura

```
Raspberry Pi 5
├── nymea:core (IoT Backend)
│   └── Device Management & Automation
├── Web Stack (port 8080)
│   └── nymea:app + Project Manager UI
├── Data Storage
│   ├── Postgres DB (projects, students)
│   └── YAML Configs
├── Monitoring (Prometheus + Grafana)
│   └── Real-time Metrics
└── Kiosk Display
    └── Full-screen Chromium Dashboard
```

## 💻 Příklady použití

### Vytvoření projektu

```python
from src.python.project_manager import ProjectManager

pm = ProjectManager()

project = pm.create_project(
    name="Weather Station IoT",
    description="Měření a analýza dat",
    objectives=["Sběr dat", "Vizualizace", "ML analýza"],
    timeline="4 týdny"
)

pm.add_task(
    project_name="Weather Station IoT",
    task_name="Připojit senzor",
    assignee="Jan Novák",
    deadline="2025-12-15",
    priority="high"
)
```

### Konfigurace systému

```python
from src.python.config_manager import ConfigManager

cm = ConfigManager()
cm.load_config('main-config.yaml')

# Čtení
hostname = cm.get('network.hostname')

# Zápis
cm.set('security.ssh_port', 2222)
cm.save_config('main-config.yaml')
```

## 🧪 Testování

```bash
# Unit testy
python -m pytest tests/unit/ -v

# Kontrola shell scriptů
shellcheck src/scripts/*.sh

# Kontrola kódování
python -m py_compile src/python/*.py
```

## 🔧 Příkazy pro správu

```bash
# Kontrola statusu služeb
sudo systemctl status nymead

# Restart Nymea
sudo systemctl restart nymead

# Zálohování
sudo /usr/local/bin/backup-nymea.sh

# Čtení logů
tail -f /var/log/nymea-kiosk/install.log

# Kontrola firewallu
sudo ufw status
```

## 📋 Pokročilá konfigurace

### Vlastní Kiosk URL

```bash
sudo src/scripts/setup-kiosk.sh \
    --url http://custom-dashboard.local \
    --orientation portrait \
    --autostart true
```

### Backup policy

```bash
# Backup s retencí 30 dní
sudo src/scripts/backup.sh backup

# Restore z konkrétního bodu
sudo src/scripts/backup.sh restore /home/nymea/backups/nymea-backup-20251111_020000.tar.gz
```

### Plugin instalace

```bash
# Instalace konkrétního pluginu
sudo apt-get install nymea-plugin-{plugin-name}
sudo systemctl restart nymead
```

## 📊 Monitoring Dashboard

Defaultní Grafana dashboard je dostupný na: `http://<RPi-IP>:3000`

**Přihlašovací údaje:**
- Username: `admin`
- Password: `admin` (změňte po prvním přihlášení!)

## 🐛 Troubleshooting

### Nymea se nespouští?
```bash
journalctl -u nymead -n 50
systemctl restart nymead
```

### Web rozhraní není dostupné?
```bash
sudo netstat -tlnp | grep 8080
curl http://localhost:8080
```

### Problémy s zálohováním?
```bash
ls -la /home/nymea/backups/
sudo /usr/local/bin/backup-nymea.sh --verbose
```

Více viz [TROUBLESHOOTING.md](docs/TROUBLESHOOTING.md)

## 🤝 Přispívání

Jsme rádi za příspěvky! Prosím:

1. Fork project
2. Vytvořte feature branch (`git checkout -b feature/amazing-feature`)
3. Commitujte změny (`git commit -m 'Add amazing feature'`)
4. Push na branch (`git push origin feature/amazing-feature`)
5. Otevřete Pull Request

## 📝 Licencování

Tento projekt je pod licencí **MIT** - viz [LICENSE](LICENSE) soubor pro detaily.

## 👥 Autoři

- **Fatalerorr69** - Tvůrce a maintainer

## 🙏 Poděkování

Děkujeme:
- [nymea](https://nymea.io/) komunitě za skvělou IoT platformu
- Všem přispěvatelům a testérům
- Českému vzdělávacímu sektoru za inspiraci

## 📞 Support & Kontakt

- **Issues:** [GitHub Issues](https://github.com/Fatalerorr69/nymeakiosk-ultimate-system/issues)
- **Discussions:** [GitHub Discussions](https://github.com/Fatalerorr69/nymeakiosk-ultimate-system/discussions)

---

<div align="center">

**[⬆ zpět nahoru](#nymea-kiosk-ultimate-system-)**

Made with ❤️ for Czech education

</div>
