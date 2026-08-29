# Nymea:Kiosk Ultimate System - Instalační přívodce

## 📋 Obsah

1. [Požadavky](#požadavky)
2. [Příprava Raspberry Pi](#příprava-raspberry-pi)
3. [Instalace systému](#instalace-systému)
4. [Post-instalační konfigurace](#post-instalační-konfigurace)
5. [Ověření instalace](#ověření-instalace)
6. [Troubleshooting](#troubleshooting)

## Požadavky

### Hardware
- **Raspberry Pi 5** (4GB min, 8GB doporučeno)
- **Power Supply:** 5V/5A USB-C
- **Storage:** 32GB+ SD karta (Class 10+)
- **Network:** Ethernet nebo Wi-Fi

### Software
- **OS:** Raspberry Pi OS 64-bit (Bookworm)
- **Internet:** Aktivní připojení
- **Root:** sudo přístup vyžadován

## Příprava Raspberry Pi

### 1. Vytvoření SD karty

```bash
# Na počítači: Stáhněte Raspberry Pi Imager
# https://www.raspberrypi.com/software/

# Vyberte:
# - OS: Raspberry Pi OS 64-bit (Bookworm)
# - Storage: vaše SD karta
# - Advanced options:
#   - Set hostname: rpi-edu-001
#   - Enable SSH: true
#   - Set password
#   - Set locale & timezone
```

### 2. Boot do Raspberry Pi

```bash
# Vložte SD kartu, připojte síť, zapněte

# Po startu si připravte SSH připojení
ssh pi@rpi-edu-001.local
```

### 3. Inicializační setup

```bash
# Aktualizace OS
sudo apt-get update && sudo apt-get upgrade -y

# Instalace Git
sudo apt-get install -y git

# Volitelně: Rozšíření filesystému
sudo raspi-config nonint do_expand_rootfs
```

## Instalace systému

### Automatická instalace (doporučeno)

```bash
# 1. Klonování repozitáře
git clone https://github.com/Fatalerorr69/nymeakiosk-ultimate-system.git
cd nymeakiosk-ultimate-system

# 2. Spuštění instalátoru
chmod +x src/scripts/install-all.sh
sudo src/scripts/install-all.sh

# Instalátor bude:
# ✓ Aktualizovat systém
# ✓ Instalovat základní balíčky
# ✓ Instalovat Nymea
# ✓ Nastavit monitoring (Prometheus, Grafana)
# ✓ Nastavit zabezpečení (firewall, fail2ban)
# ✓ Nastavit zálohování
# ✓ Nastavit kiosk displej
# ✓ Instalovat pluginy

# Čas instalace: ~30-45 minut (závisí na internetu)
```

### Manuální instalace (pro pokročilé)

```bash
# 1. Aktualizace
sudo apt-get update && sudo apt-get upgrade -y

# 2. Základní balíčky
sudo apt-get install -y \
    build-essential \
    curl \
    fail2ban \
    git \
    htop \
    nano \
    openssh-server \
    python3 \
    python3-pip \
    unzip \
    wget

# 3. Nymea instalace
sudo apt-get install -y nymea nymea-app nymea-plugins

# 4. Monitoring (opt.)
sudo apt-get install -y prometheus grafana-server

# 5. Aktivace služeb
sudo systemctl enable nymead prometheus grafana-server
sudo systemctl start nymead prometheus grafana-server
```

## Post-instalační konfigurace

### 1. Grafana nastavení

```bash
# Přístup: http://YOUR_RPI_IP:3000
# Default login: admin / admin

# Po přihlášení:
# 1. Změňte heslo (admin → complex-password)
# 2. Přidejte Prometheus zdroj:
#    - URL: http://localhost:9090
#    - Save & Test
# 3. Importujte dashboardy
```

### 2. Nymea konfiguracija

```bash
# Přístup: http://YOUR_RPI_IP:8080
# Zde nakonfigurujete:
# - IoT zařízení
# - Automatizační pravidla
# - Uživatelské účty
```

### 3. Vlastní konfigurace

```bash
# Editujte hlavní config
sudo nano /app/config/main-config.yaml

# Důležité nastavení:
# - network.hostname
# - security.ssh_port
# - education.default_projects_path
# - kiosk.orientation (landscape/portrait)
```

### 4. Kiosk nastavení (pokud chcete)

```bash
# Pokud chcete full-screen displej
sudo src/scripts/setup-kiosk.sh \
    --orientation landscape \
    --autostart true \
    --url "http://localhost:8080"

# Reboot k aplikaci
sudo reboot
```

## Ověření instalace

### Kontrolní seznam

```bash
# 1. Nymea daemon
systemctl status nymead
# Output: active (running)

# 2. Prometheus
systemctl status prometheus
# Output: active (running)

# 3. Grafana
systemctl status grafana-server
# Output: active (running)

# 4. Porty
sudo netstat -tlnp | grep LISTEN
# 8080 - nymea
# 9090 - prometheus
# 3000 - grafana
```

### Web rozhraní testy

```bash
# Nymea
curl http://localhost:8080
# HTTP/1.1 200 OK

# Prometheus
curl http://localhost:9090/-/healthy
# Prometheus is Healthy

# Grafana
curl http://localhost:3000/api/health
# {"status":"ok"}
```

### Log kontrola

```bash
# Instalační log
tail -f /var/log/nymea-kiosk/install.log

# Nymea log
journalctl -u nymead -n 50 --no-paging

# Prometheus log
sudo journalctl -u prometheus -n 30 --no-paging
```

## Troubleshooting

### Nymea se nespouští

```bash
# Diagnostika
systemctl status nymead
journalctl -u nymead -n 100

# Restart
sudo systemctl restart nymead

# Zkuste:
sudo systemctl stop nymead
sudo /usr/bin/nymead -d
# Zkontrolujte chyby ve výstupu
```

### Web rozhraní není dostupné

```bash
# Kontrola portu
sudo netstat -tlnp | grep 8080

# Pokud nic, port není otevřen:
ps aux | grep nymea

# Restart
sudo systemctl restart nymead

# Firewall check
sudo ufw status
# Port 8080 by měl být povolen
```

### Grafana problém

```bash
# Kontrola
systemctl status grafana-server

# Logy
sudo journalctl -u grafana-server -n 50

# Restart
sudo systemctl restart grafana-server

# Reset hesla (pokud je zapomenuté):
sudo grafana-cli admin reset-admin-password newpassword
```

### Problém s SSH

```bash
# Kontrola
systemctl status ssh

# SSH na custom portu (výchozí 2222)
ssh -p 2222 pi@rpi-edu-001.local

# Firewall check
sudo ufw status
# Port 2222 by měl být povolen
```

### Problémy s diskovým místem

```bash
# Kontrola
df -h

# Vyčištění
sudo apt-get clean
sudo apt-get autoremove

# Zobrazení velkých souborů
du -sh /var/* 2>/dev/null | sort -h
```

## Další kroky po instalaci

1. **Změňte výchozí hesla**
   ```bash
   sudo passwd pi
   ```

2. **Nastavte SSH klíče** (namísto hesel)
   ```bash
   ssh-keygen
   ssh-copy-id -i ~/.ssh/id_rsa.pub pi@rpi-edu-001.local
   ```

3. **Nakonfigurujte NTP** (přesný čas)
   ```bash
   timedatectl set-ntp true
   timedatectl
   ```

4. **Nastavte SMTP** (pro notifikace)
   ```bash
   # Editujte /app/config/main-config.yaml
   # Přidejte SMTP nastavení
   ```

5. **Vytvořte prvního studenta/učitele**
   ```bash
   # Přes Nymea web rozhraní nebo:
   python3 -c "from src.python.project_manager import ProjectManager; ..."
   ```

## Podpora

- **Problémy:** [GitHub Issues](https://github.com/Fatalerorr69/nymeakiosk-ultimate-system/issues)
- **Diskuse:** [GitHub Discussions](https://github.com/Fatalerorr69/nymeakiosk-ultimate-system/discussions)
- **Dokumentace:** [docs/DOCUMENTATION.md](../DOCUMENTATION.md)

---

**Gratulujeme!** 🎉 Váš Nymea:Kiosk Ultimate System je nyní spuštěn a připraven k použití!

Navštivte: `http://YOUR_RPI_IP:8080` pro začátek
