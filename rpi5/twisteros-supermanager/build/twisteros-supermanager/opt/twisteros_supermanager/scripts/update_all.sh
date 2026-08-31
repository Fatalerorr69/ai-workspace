#!/bin/bash
echo "🔄 Aktualizuji Smart Suite..."

sudo apt update -y && sudo apt upgrade -y
sudo docker system prune -af

cd ~/homeassistant && sudo docker compose pull && sudo docker compose up -d
cd ~/smart-hub && sudo docker compose pull && sudo docker compose up -d

if [ -d ~/twister-dashboard ]; then
    git -C ~/twister-dashboard pull || true
fi

echo "🔥 Vše úspěšně aktualizováno!"
