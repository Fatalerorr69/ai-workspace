# Hluboká analýza: nymeakiosk-ultimate-system

## Základní informace
- **Cílová cesta:** $targetPath
- **Detekované technologie:** Python, Shell
- **Počet skriptů:** 93

## Popis z README
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


## Seznam skriptů
- `rpi5\nymeakiosk-ultimate-system\nymeakiosk-rpi5\RPI_nymea_skripty\guide\Příprava Raspberry Pi 5.sh` – Instalace základního OS
- `rpi5\nymeakiosk-ultimate-system\nymeakiosk-rpi5\RPI_nymea_skripty\guide\Spuštění inicializačního skriptu.sh` – Stažení a spuštění inicializačního skriptu
- `rpi5\nymeakiosk-ultimate-system\nymeakiosk-rpi5\RPI_nymea_skripty\guide\Stažení a příprava obrazu nymea-kiosk.sh` – Stažení nejnovějšího obrazu nymea:kiosk
- `rpi5\nymeakiosk-ultimate-system\nymeakiosk-rpi5\RPI_nymea_skripty\guide\Stažení_instalace_instalačního_skriptu.sh` – Stažení instalačního skriptu
- `rpi5\nymeakiosk-ultimate-system\nymeakiosk-rpi5\RPI_nymea_skripty\guide\Výchozí přihlašovací údaje.sh` – Přihlaste se a změňte heslo pro uživatele nymea
- `rpi5\nymeakiosk-ultimate-system\nymeakiosk-rpi5\RPI_nymea_skripty\instal skripty\Hlavní instalační skript.sh` – !/bin/bash
- `rpi5\nymeakiosk-ultimate-system\nymeakiosk-rpi5\RPI_nymea_skripty\instal skripty\Instalace systému.sh` – Spuštění instalačního skriptu
- `rpi5\nymeakiosk-ultimate-system\nymeakiosk-rpi5\RPI_nymea_skripty\instal skripty\Stažení vzdělávacího systému.sh` – Naklonování repozitáře
- `rpi5\nymeakiosk-ultimate-system\nymeakiosk-rpi5\RPI_nymea_skripty\Kompletní konfigurační skript\Kompletní konfigurační skript.sh` – !/bin/bash
- `rpi5\nymeakiosk-ultimate-system\nymeakiosk-rpi5\RPI_nymea_skripty\nastaveni\Aktualizace systému.sh` – Aktualizace seznamu balíčků
- `rpi5\nymeakiosk-ultimate-system\nymeakiosk-rpi5\RPI_nymea_skripty\nastaveni\Diagnostika problémů.sh` – Zobrazení logů nymea v reálném čase
- `rpi5\nymeakiosk-ultimate-system\nymeakiosk-rpi5\RPI_nymea_skripty\nastaveni\Instalace monitorovacích nástrojů.sh` – Instalace Netdata pro detailní monitoring
- `rpi5\nymeakiosk-ultimate-system\nymeakiosk-rpi5\RPI_nymea_skripty\nastaveni\Kalibrace dotykového displeje.sh` – Instalace kalibračních nástrojů
- `rpi5\nymeakiosk-ultimate-system\nymeakiosk-rpi5\RPI_nymea_skripty\nastaveni\Konfigurace časového pásma a lokalizace.sh` – Nastavení časového pásma pro ČR
- `rpi5\nymeakiosk-ultimate-system\nymeakiosk-rpi5\RPI_nymea_skripty\nastaveni\Konfigurace sítě a připojení.sh` – Spuštění síťového konfiguračního skriptu
- `rpi5\nymeakiosk-ultimate-system\nymeakiosk-rpi5\RPI_nymea_skripty\nastaveni\Konfigurace systému.sh` – Úprava konfigurace
- `rpi5\nymeakiosk-ultimate-system\nymeakiosk-rpi5\RPI_nymea_skripty\nastaveni\Monitorování výkonu.sh` – Instalace monitorovacích nástrojů
- `rpi5\nymeakiosk-ultimate-system\nymeakiosk-rpi5\RPI_nymea_skripty\nastaveni\Nastavení kiosk režimu.sh` – Úprava konfigurace kiosk režimu
- `rpi5\nymeakiosk-ultimate-system\nymeakiosk-rpi5\RPI_nymea_skripty\nastaveni\Nastavení monitorovacích nástrojů.sh` – Spuštění monitorovacího skriptu
- `rpi5\nymeakiosk-ultimate-system\nymeakiosk-rpi5\RPI_nymea_skripty\nastaveni\Nastavení notifikací.sh` – Instalace notifikačních pluginů
- `rpi5\nymeakiosk-ultimate-system\nymeakiosk-rpi5\RPI_nymea_skripty\nastaveni\Nastavení otáčení obrazovky.sh` – Úprava konfigurace pro otočení obrazovky
- `rpi5\nymeakiosk-ultimate-system\nymeakiosk-rpi5\RPI_nymea_skripty\nastaveni\Nastavení vzdáleného přístupu.sh` – Metoda 1: SSH tunel (bezpečné)
- `rpi5\nymeakiosk-ultimate-system\nymeakiosk-rpi5\RPI_nymea_skripty\nastaveni\Nastavení zálohování.sh` – Vytvoření zálohovacího skriptu
- `rpi5\nymeakiosk-ultimate-system\nymeakiosk-rpi5\RPI_nymea_skripty\nastaveni\Nastavení zálohování2.sh` – !/bin/bash
- `rpi5\nymeakiosk-ultimate-system\nymeakiosk-rpi5\RPI_nymea_skripty\nastaveni\Nastavení zálohování3.sh` – Nastavení práv a spuštění
- `rpi5\nymeakiosk-ultimate-system\nymeakiosk-rpi5\RPI_nymea_skripty\nastaveni\Optimalizace souborového systému.sh` – Přidání optimalizací do /etc/fstab
- `rpi5\nymeakiosk-ultimate-system\nymeakiosk-rpi5\RPI_nymea_skripty\nastaveni\Připojení k síti.sh` – Zobrazení dostupných WiFi sítí
- `rpi5\nymeakiosk-ultimate-system\nymeakiosk-rpi5\RPI_nymea_skripty\nastaveni\setup-network.sh` – !/bin/bash
- `rpi5\nymeakiosk-ultimate-system\nymeakiosk-rpi5\RPI_nymea_skripty\nastaveni\Skript pro automatické diagnostiku a opravy.sh` – Skript pro automatické diagnostiku a opravy
- `rpi5\nymeakiosk-ultimate-system\nymeakiosk-rpi5\RPI_nymea_skripty\nastaveni\Spuštění kontejnerů.sh` – Build a spuštění Docker kontejnerů
- `rpi5\nymeakiosk-ultimate-system\nymeakiosk-rpi5\RPI_nymea_skripty\nastaveni\Statická IP adresa.sh` – Editace síťového nastavení
- `rpi5\nymeakiosk-ultimate-system\nymeakiosk-rpi5\RPI_nymea_skripty\nastaveni\Testování funkcionality.sh` – Testování Zigbee sítě
- `rpi5\nymeakiosk-ultimate-system\nymeakiosk-rpi5\RPI_nymea_skripty\nastaveni\Testování základních funkcí.sh` – Kontrola stavu nymea služby
- `rpi5\nymeakiosk-ultimate-system\nymeakiosk-rpi5\RPI_nymea_skripty\nastaveni\Vzdálený přístup a zálohování.sh` – Nastavení SSH klíčů pro bezpečnější přístup
- `rpi5\nymeakiosk-ultimate-system\nymeakiosk-rpi5\RPI_nymea_skripty\nastaveni\Zabezpeceni systemu.sh` – Instalace základních bezpečnostních nástrojů
- `rpi5\nymeakiosk-ultimate-system\nymeakiosk-rpi5\RPI_nymea_skripty\nastaveni\Zakázání nepotřebných služeb2.sh` – Seznam a zastavení nepotřebných služeb
- `rpi5\nymeakiosk-ultimate-system\nymeakiosk-rpi5\RPI_nymea_skripty\puvodni instalacni soubory\rpi5-advanced-auto-setup.sh` – !/bin/bash
- `rpi5\nymeakiosk-ultimate-system\nymeakiosk-rpi5\RPI_nymea_skripty\puvodni instalacni soubory\rpi5-advanced-setup.sh` – !/bin/bash
- `rpi5\nymeakiosk-ultimate-system\nymeakiosk-rpi5\RPI_nymea_skripty\puvodni instalacni soubory\rpi5-setup_v2.sh` – !/bin/bash
- `rpi5\nymeakiosk-ultimate-system\nymeakiosk-rpi5\RPI_nymea_skripty\puvodni instalacni soubory\rpi5-setup.sh` – !/bin/bash
- `rpi5\nymeakiosk-ultimate-system\nymeakiosk-rpi5\RPI_nymea_skripty\puvodni instalacni soubory\rpi5-ultra-advanced-auto-setup.sh` – !/bin/bash
- `rpi5\nymeakiosk-ultimate-system\nymeakiosk-rpi5\RPI_nymea_skripty\sprava\Instalace a konfigurace nymea pluginů.sh` – Spuštění skriptu pro instalaci pluginů
- `rpi5\nymeakiosk-ultimate-system\nymeakiosk-rpi5\RPI_nymea_skripty\sprava\Instalace dalších pluginů.sh` – Zobrazení dostupných pluginů
- `rpi5\nymeakiosk-ultimate-system\nymeakiosk-rpi5\RPI_nymea_skripty\sprava\Integrace s Home Assistant.sh` – Instalace Home Assistant pomocí Docker
- `rpi5\nymeakiosk-ultimate-system\nymeakiosk-rpi5\RPI_nymea_skripty\sprava\Konfigurace MQTT brokeru (pokud potřebujete).sh` – Instalace Mosquitto MQTT brokeru
- `rpi5\nymeakiosk-ultimate-system\nymeakiosk-rpi5\RPI_nymea_skripty\sprava\Nastavení vlastních skriptů a automatizací.sh` – Vytvoření adresáře pro vlastní skripty
- `rpi5\nymeakiosk-ultimate-system\nymeakiosk-rpi5\RPI_nymea_skripty\sprava\Nastavení vzdáleného přístupu a zálohování.sh` – Spuštění skriptu pro vzdálený přístup
- `rpi5\nymeakiosk-ultimate-system\nymeakiosk-rpi5\RPI_nymea_skripty\sprava\Optimalizace SWAP a paměti.sh` – Úprava SWAP nastavení
- `rpi5\nymeakiosk-ultimate-system\nymeakiosk-rpi5\RPI_nymea_skripty\sprava\Optimalizace výkonu pro Raspberry Pi.sh` – Spuštění optimalizačního skriptu
- `rpi5\nymeakiosk-ultimate-system\nymeakiosk-rpi5\RPI_nymea_skripty\sprava\Pravidelné aktualizace.sh` – Nastavení automatických aktualizací
- `rpi5\nymeakiosk-ultimate-system\nymeakiosk-rpi5\RPI_nymea_skripty\sprava\Přidání studenta.sh` – Skript Přidání studenta.sh
- `rpi5\nymeakiosk-ultimate-system\nymeakiosk-rpi5\RPI_nymea_skripty\sprava\Přiřazení projektu.sh` – Skript Přiřazení projektu.sh
- `rpi5\nymeakiosk-ultimate-system\nymeakiosk-rpi5\RPI_nymea_skripty\sprava\Úprava vzhledu a chování kiosku.sh` – Editace konfigurace kiosku
- `rpi5\nymeakiosk-ultimate-system\nymeakiosk-rpi5\RPI_nymea_skripty\sprava\Vlastní dashboardy a rozhraní.sh` – Instalace Node-RED pro vlastní dashboardy
- `rpi5\nymeakiosk-ultimate-system\nymeakiosk-rpi5\RPI_nymea_skripty\sprava\Vytvoření dokumentace a shrnutí.sh` – Generování shrnutí nastavení
- `rpi5\nymeakiosk-ultimate-system\nymeakiosk-rpi5\RPI_nymea_skripty\sprava\Vytvoření komplexního údržbového skriptu.sh` – Stažení údržbového skriptu
- `rpi5\nymeakiosk-ultimate-system\nymeakiosk-rpi5\RPI_nymea_skripty\sprava\Vytvoření nového projektu.sh` – Skript Vytvoření nového projektu.sh
- `rpi5\nymeakiosk-ultimate-system\nymeakiosk-rpi5\RPI_nymea_skripty\sprava\Zakázání nepotřebných služeb.sh` – Kontrola aktivních služeb
- `rpi5\nymeakiosk-ultimate-system\nymeakiosk-rpi5\RPI_nymea_skripty\sprava\Základní zabezpečení systému.sh` – Spuštění bezpečnostního skriptu
- `rpi5\nymeakiosk-ultimate-system\nymeakiosk-rpi5\RPI_nymea_skripty\sprava\Zobrazení hodnocení.sh` – Skript Zobrazení hodnocení.sh
- `rpi5\nymeakiosk-ultimate-system\nymeakiosk-rpi5\RPI_nymea_skripty\example.py` – Ukázka vytvoření projektové šablony v Pythonu
- `rpi5\nymeakiosk-ultimate-system\nymeakiosk-rpi5\RPI_nymea_skripty\Chytrá meteorologická stanice.py` – Projekt: Chytrá meteorologická stanice
- `rpi5\nymeakiosk-ultimate-system\nymeakiosk-rpi5\RPI_nymea_skripty\Implementace projektového managementu.py` – Třída pro řízení studentských projektů
- `rpi5\nymeakiosk-ultimate-system\nymeakiosk-rpi5\RPI_nymea_skripty\Systematické vyhodnocování studentských prací.py` – Třída pro hodnocení studentských projektů
- `rpi5\nymeakiosk-ultimate-system\nymeakiosk-rpi5\RPI_nymea_skripty\Testovací soubor.py` – !/usr/bin/env python3
- `rpi5\nymeakiosk-ultimate-system\nymeakiosk-rpi5\scripts\configure-backup.sh` – !/bin/bash
- `rpi5\nymeakiosk-ultimate-system\nymeakiosk-rpi5\scripts\export-rules.sh` – !/bin/bash
- `rpi5\nymeakiosk-ultimate-system\nymeakiosk-rpi5\scripts\import-rules.sh` – !/bin/bash
- `rpi5\nymeakiosk-ultimate-system\nymeakiosk-rpi5\scripts\install-nodered.sh` – !/bin/bash
- `rpi5\nymeakiosk-ultimate-system\nymeakiosk-rpi5\scripts\install-plugins.sh` – !/bin/bash
- `rpi5\nymeakiosk-ultimate-system\nymeakiosk-rpi5\scripts\restore-backup.sh` – !/bin/bash
- `rpi5\nymeakiosk-ultimate-system\nymeakiosk-rpi5\scripts\setup-kiosk.sh` – !/bin/bash
- `rpi5\nymeakiosk-ultimate-system\nymeakiosk-rpi5\install-all.sh` – !/bin/bash
- `rpi5\nymeakiosk-ultimate-system\scripts\configure-backup.sh` – !/bin/bash
- `rpi5\nymeakiosk-ultimate-system\scripts\export-rules.sh` – !/bin/bash
- `rpi5\nymeakiosk-ultimate-system\scripts\import-rules.sh` – !/bin/bash
- `rpi5\nymeakiosk-ultimate-system\scripts\install-nodered.sh` – !/bin/bash
- `rpi5\nymeakiosk-ultimate-system\scripts\install-plugins.sh` – !/bin/bash
- `rpi5\nymeakiosk-ultimate-system\scripts\restore-backup.sh` – !/bin/bash
- `rpi5\nymeakiosk-ultimate-system\scripts\setup-kiosk.sh` – !/bin/bash
- `rpi5\nymeakiosk-ultimate-system\src\python\__init__.py` – Skript __init__.py
- `rpi5\nymeakiosk-ultimate-system\src\python\config_manager.py` – Skript config_manager.py
- `rpi5\nymeakiosk-ultimate-system\src\python\project_manager.py` – Skript project_manager.py
- `rpi5\nymeakiosk-ultimate-system\src\python\utils.py` – Skript utils.py
- `rpi5\nymeakiosk-ultimate-system\src\scripts\backup.sh` – !/bin/bash
- `rpi5\nymeakiosk-ultimate-system\src\scripts\install-all.sh` – !/bin/bash
- `rpi5\nymeakiosk-ultimate-system\src\scripts\setup-kiosk.sh` – !/bin/bash
- `rpi5\nymeakiosk-ultimate-system\tests\integration\__init__.py` – Skript __init__.py
- `rpi5\nymeakiosk-ultimate-system\tests\unit\__init__.py` – Skript __init__.py
- `rpi5\nymeakiosk-ultimate-system\tests\unit\test_config_manager.py` – Skript test_config_manager.py
- `rpi5\nymeakiosk-ultimate-system\tests\unit\test_project_manager.py` – Skript test_project_manager.py
- `rpi5\nymeakiosk-ultimate-system\tests\__init__.py` – Skript __init__.py
- `rpi5\nymeakiosk-ultimate-system\install-all.sh` – !/bin/bash


## Hodnocení a doporučení
<!-- Doplňte na základě výše uvedených informací -->
- 
