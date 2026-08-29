#!/bin/bash
# =================================================================
# GENESIS AETERNA - SEKTOR 4: DATA VAULT & RAG (v8.0)
# =================================================================

G='\033[0;32m'; B='\033[0;34m'; Y='\033[1;33m'; NC='\033[0m'

echo -e "${B}--- AKTIVACE SEKTORU 04: DATA VAULT ---${NC}"

# --- [1] VYTVOŘENÍ STRUKTURY TREZORU ---
echo -e "${G}[1] Vytvářím složky pro znalostní bázi...${NC}"
mkdir -p ~/genesis/vault/documents
mkdir -p ~/genesis/vault/codes
mkdir -p ~/genesis/vault/logs

# --- [2] INSTALACE WEAVIATE / VECTOR DB (Volitelné, Open WebUI má interní) ---
# Open WebUI používá ChromaDB interně v kontejneru. 
# Nastavíme oprávnění, aby tam Genesis mohl posílat data.
sudo chmod -R 777 ~/genesis/vault

# --- [3] AUTOMATIZOVANÝ IMPORTNÍ SKRIPT ---
# Tento skript můžeš spustit, kdykoliv přidáš nové soubory do vaultu
cat > ~/genesis/tools/vault_refresh.sh <<EOF
#!/bin/bash
echo "Indexuji nové dokumenty v Sektoru 04..."
# Zde se v budoucnu přidá API volání pro re-indexaci Open WebUI
# Aktuálně Open WebUI sleduje namapovanou složku.
EOF
chmod +x ~/genesis/tools/vault_refresh.sh

# --- [4] ÚPRAVA DOCKERU PRO RAG ---
# Znovu spustíme Open WebUI s namapovaným VAULTEM pro přímý přístup k dokumentům
echo -e "${Y}[2] Propojuji VAULT s AI GUI...${NC}"
sudo docker stop genesis-ai-gui 2>/dev/null && sudo docker rm genesis-ai-gui 2>/dev/null

sudo docker run -d -p 3000:8080 \
  --add-host=host.docker.internal:host-gateway \
  -v open-webui:/app/backend/data \
  -v /home/$USER/genesis/vault:/app/backend/data/vault \
  --name genesis-ai-gui \
  --restart always \
  ghcr.io/open-webui/open-webui:main

echo -e "${G}VAULT integrován. Složka /home/$USER/genesis/vault je nyní přístupná pro AI.${NC}"
