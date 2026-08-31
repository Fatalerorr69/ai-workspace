#!/bin/bash
# =================================================================
# GENESIS AETERNA - SEKTOR 3: AGENT DEPLOYMENT (v8.0)
# =================================================================

G='\033[0;32m'; B='\033[0;34m'; Y='\033[1;33m'; NC='\033[0m'

echo -e "${B}--- INICIALIZACE MATRICE AGENTŮ ---${NC}"

# Funkce pro vytvoření Modelfile a nahrání do Ollama
create_agent() {
    local name=$1
    local system_prompt=$2
    echo -e "${Y}Nasazuji agenta: $name...${NC}"
    
    cat <<EOF > ~/genesis/tools/tmp_modelfile
FROM llama3:8b
PARAMETER temperature 0.7
SYSTEM """$system_prompt"""
EOF

    ollama create "$name" -f ~/genesis/tools/tmp_modelfile
    rm ~/genesis/tools/tmp_modelfile
}

# --- DEFINICE KLÍČOVÝCH AGENTŮ ---

# 1. ARCHITEKT (Hlavní systémový dozor)
create_agent "genesis-architekt" "Jsi jádro systému Genesis Aeterna. Tvým úkolem je dohlížet na integritu Raspberry Pi 5, NVMe SSD a všech běžících sektorů. Odpovídáš technicky, precizně a prioritizuješ stabilitu OS."

# 2. STÍN (Sektor 09: Cyber-Security)
create_agent "genesis-stin" "Jsi expert na kybernetickou bezpečnost a penetrační testování. Analyzuješ výstupy z Nmap a Security Auditů. Tvým cílem je chránit lokální síť a identifikovat zranitelnosti dříve, než budou zneužity."

# 3. ANALYTIK (Sektor 10: Log Analysis)
create_agent "genesis-analytik" "Jsi specialista na analýzu dat a systémových logů. Dokážeš identifikovat vzorce v chybových hlášeních a navrhovat optimalizace pro Python a Docker služby."

# 4. KODÉR (Sektor 05: Vývoj)
create_agent "genesis-koder" "Jsi expert na Python, Bash a automatizaci. Tvým úkolem je psát čistý, optimalizovaný kód pro nové moduly Genesis Aeterna. Vždy zohledňuješ omezené zdroje Raspberry Pi."

# --- HROMADNÉ NASAZENÍ ZBYTKU (Ukázka) ---
echo -e "${G}Agenti byli úspěšně integrováni do lokálního podvědomí.${NC}"

# Propojení s Open WebUI
echo -e "${Y}Restartuji AI GUI pro načtení nových identit...${NC}"
sudo docker restart genesis-ai-gui
