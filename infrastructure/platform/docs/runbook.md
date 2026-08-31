# PLATFORM RUNBOOK

## Denní provoz
- Kontrola dashboardu
- Kontrola backup logů
- Kontrola teploty systému

## Týdenní údržba
- apt update && apt upgrade
- docker compose pull
- restart kritických služeb

## Měsíční údržba
- audit uživatelů
- test obnovy dat
- kontrola logů

## Kritické služby
- docker
- platform-web
- k8s-panel
- security
- backup

## Příkazy
systemctl status platform-*
docker ps
kubectl get nodes
