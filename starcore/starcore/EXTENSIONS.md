# STARCORE Mobile – Catalog rozšíření

## 🔌 Oficiální rozšíření

### 1. STARCORE-Cloud
- Synchronizace s cloudovými úložišti (Google Drive, Dropbox)
- Zálohování konfigurací
- Příkaz: `starcore cloud sync`

### 2. STARCORE-Monitor
- Monitoring systémových zdrojů
- Upozornění na vybití baterie
- Příkaz: `starcore monitor`

### 3. STARCORE-DevOps
- Deployment skriptů
- CI/CD integrace
- Příkaz: `starcore deploy`

### 4. STARCORE-Voice
- Hlasové ovládání
- Text-to-speech
- Příkaz: `starcore voice`

### 5. STARCORE-Vision
- Počítačové vidění
- Rozpoznávání objektů
- Příkaz: `starcore vision`

### 6. STARCORE-Proxmox
- Správa Proxmox VE
- VM a kontejnery
- Příkaz: `starcore proxmox`

### 7. STARCORE-SSH
- Správa SSH připojení
- Tunneling
- Příkaz: `starcore ssh`

## 📦 Komunitní rozšíření (navrženo)

### 8. STARCORE-Docker
- Správa Docker kontejnerů
- Orchestrace

### 9. STARCORE-Kubernetes
- K8s management
- Helm charts

### 10. STARCORE-Network
- Síťové nástroje
- Ping, traceroute, speedtest

## 🛠 Jak vytvořit rozšíření

1. Vytvoř adresář: `mkdir -p extensions/<nazev>`
2. Vytvoř `__init__.py` s pluginem
3. Zaregistruj v CLI
4. Přidej testy

## 📝 Plánované

- Plugin manager
- Automatické aktualizace
- Marketplace
