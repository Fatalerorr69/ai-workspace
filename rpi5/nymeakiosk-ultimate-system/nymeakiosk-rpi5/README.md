# Nymea:Kiosk Ultimate System

All-in-one systém pro Raspberry Pi s plnou podporou nymea:core, nymea:app a kiosk režimu.

## Instalace

1. Naklonujte repozitář:
   ```bash
   git clone https://github.com/<tvůj-uživatel>/nymeakiosk-ultimate-system.git
   cd nymeakiosk-ultimate-system
   ```

2. Spusťte instalační skript:
   ```bash
   chmod +x install-all.sh
   sudo ./install-all.sh
   ```

3. Po instalaci přejděte na:
   - Web rozhraní: `http://<IP-RPi>:8080`
   - Grafana: `http://<IP-RPi>:3000`
   - Prometheus: `http://<IP-RPi>:9090`
