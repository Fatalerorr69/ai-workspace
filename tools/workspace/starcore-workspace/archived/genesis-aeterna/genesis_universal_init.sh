#!/bin/bash
# GENESIS UNIVERSAL INITIALIZER v7.0

echo "--- STARTING GENESIS CROSS-PLATFORM INITIALIZATION ---"

# 1. Detekce Prostředí
OS_TYPE=$(uname -s)
ARCH_TYPE=$(uname -m)
echo "Detected: $OS_TYPE ($ARCH_TYPE)"

# 2. Instalace Základních Nástrojů (Agnosticky)
if [[ "$OS_TYPE" == "Linux" ]]; then
    sudo apt-get update && sudo apt-get install -y docker.io python3-pip git curl
elif [[ "$OS_TYPE" == "Darwin" ]]; then
    brew install docker python git curl
fi

# 3. Vytvoření Standardizované Struktury (The Hive)
mkdir -p ~/genesis_swarm/{dna,vault,logs,config,gui}

# 4. Spuštění Logovacího Ducha (Containerized Agent ID-86)
# Tento kontejner je tvůj černý box, běží všude stejně.
docker run -d \
  --name genesis_logger \
  --restart always \
  -v ~/genesis_swarm/logs:/app/logs \
  python:3.11-slim \
  sh -c "echo 'Logger Active' > /app/logs/sys.log && tail -f /dev/null"

echo "✅ Environment Ready. Universal Hive initialized at ~/genesis_swarm.”

