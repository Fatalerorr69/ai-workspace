#!/bin/bash
# STARCORE - Kompletní diagnostický skript
# Verze: 1.0
# Datum: 2026-07-03

set -euo pipefail

# Barvy pro výstup
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
MAGENTA='\033[0;35m'
CYAN='\033[0;36m'
BOLD='\033[1m'
NC='\033[0m' # No Color

PROJECT_DIR="$HOME/STARCORE"
LOG_DIR="$PROJECT_DIR/data/logs"

cd "$PROJECT_DIR" || { echo -e "${RED}❌ STARCORE adresář nenalezencldar{NC}"; exit 1; }

echo -e "${BOLD}${CYAN}════════════════════════════════════════════════════════════${NC}"
echo -e "${BOLD}${CYAN}  STARCORE KOMPLETNÍ DIAGNOSTIKA${NC}"
echo -e "${BOLD}${CYAN}════════════════════════════════════════════════════════════${NC}"
echo ""

# ======================================================================
# 1. ZÁKLADNÍ SYSTÉM
# ======================================================================
echo -e "${BOLD}${BLUE}1. ZÁKLADNÍ SYSTÉM${NC}"
echo "----------------------------------------"

echo -e "${CYAN}Termux verze:${NC} $(termux-info 2>/dev/null | grep TERMUX_VERSION | cut -d= -f2 || echo 'Neznámá')"
echo -e "${CYAN}Android verze:${NC} $(getprop ro.build.version.release 2>/dev/null || echo 'Neznámá')"
echo -e "${CYAN}Architektura:${NC} $(uname -m)"
echo -e "${CYAN}Jádro:${NC} $(uname -r)"
echo -e "${CYAN}Uživatel:${NC} $(whoami)"
echo -e "${CYAN}Domovský adresář:${NC} $HOME"
echo -e "${CYAN}Aktuální adresář:${NC} $(pwd)"
echo ""

echo -e "${CYAN}RAM:${NC}"
free -h | grep -E "Mem|Swap"
echo ""

echo -e "${CYAN}Diskové využití (domovský adresář):${NC}"
df -h "$HOME" | tail -1
echo ""

echo -e "${CYAN}Počet jader CPU:${NC} $(nproc)"
echo ""

echo -e "${CYAN}IP adresa:${NC}"
ifconfig 2>/dev/null | grep -E "inet " | grep -v "127.0.0.1" | awk '{print $2}' | head -1 || echo "Neznámá"
echo ""

# ======================================================================
# 2. INSTALOVANÉ BALÍČKY
# ======================================================================
echo -e "${BOLD}${BLUE}2. INSTALOVANÉ BALÍČKY (KLÍČOVÉ)${NC}"
echo "----------------------------------------"

for pkg in python git tmux openssh rsync curl wget ollama tesseract fzf bat; do
    if pkg list-installed 2>/dev/null | grep -q "^$pkg"; then
        echo -e "  ${GREEN}✅ $pkg${NC}"
    else
        echo -e "  ${RED}❌ $pkg (není nainstalován)${NC}"
    fi
done
echo ""

# ======================================================================
# 3. ADRESÁŘOVÁ STRUKTURA STARCORE
# ======================================================================
echo -e "${BOLD}${BLUE}3. ADRESÁŘOVÁ STRUKTURA STARCORE${NC}"
echo "----------------------------------------"

DIRS=("core" "core/cli" "core/config" "core/database" "core/logging" "core/utils" "core/services" "core/hive" "data" "data/logs" "extensions" "dashboard" "ai" "scripts")
for d in "${DIRS[@]}"; do
    if [ -d "$d" ]; then
        echo -e "  ${GREEN}✅ $d${NC}"
    else
        echo -e "  ${RED}❌ $d (chybí)${NC}"
    fi
done
echo ""

# ======================================================================
# 4. BĚŽÍCÍ PROCESY
# ======================================================================
echo -e "${BOLD}${BLUE}4. BĚŽÍCÍ PROCESY${NC}"
echo "----------------------------------------"

echo -e "${CYAN}TMUX session:${NC}"
tmux list-sessions 2>/dev/null || echo "  Žádné tmux session"
echo ""

echo -e "${CYAN}STARCORE služby (tmux okna):${NC}"
tmux list-windows -t starcore 2>/dev/null | awk '{print "  " $0}' || echo "  Žádná okna"
echo ""

echo -e "${CYAN}Python procesy:${NC}"
ps aux | grep -E "python.*starcore|python.*dashboard|python.*test_service|uvicorn" | grep -v grep | awk '{print "  " $0}' || echo "  Žádné"
echo ""

echo -e "${CYAN}Ollama:${NC}"
if pgrep -f "ollama serve" >/dev/null; then
    echo -e "  ${GREEN}✅ Běží${NC}"
else
    echo -e "  ${RED}❌ Nespuštěn${NC}"
fi
echo ""

# ======================================================================
# 5. STARCORE KOMPONENTY
# ======================================================================
echo -e "${BOLD}${BLUE}5. STARCORE KOMPONENTY${NC}"
echo "----------------------------------------"

# 5a. CLI
echo -e "${CYAN}CLI:${NC}"
if ./starcore version &>/dev/null; then
    echo -e "  ${GREEN}✅ version${NC}"
else
    echo -e "  ${RED}❌ version selhalo${NC}"
fi

if ./starcore doctor &>/dev/null; then
    echo -e "  ${GREEN}✅ doctor${NC}"
else
    echo -e "  ${RED}❌ doctor selhalo${NC}"
fi
echo ""

# 5b. Služby
echo -e "${CYAN}Služby (Service Manager):${NC}"
./starcore status 2>/dev/null || echo "  Nelze získat status"
echo ""

# 5c. HIVE
echo -e "${CYAN}HIVE:${NC}"
./starcore hive-status 2>/dev/null || echo "  Nelze získat stav HIVE"
echo ""

# 5d. AI
echo -e "${CYAN}AI Runtime:${NC}"
./starcore ai-status 2>/dev/null || echo "  Nelze získat stav AI"
echo ""

# 5e. Dashboard
echo -e "${CYAN}Dashboard:${NC}"
if curl -s -o /dev/null -w "%{http_code}" http://localhost:8000/health 2>/dev/null | grep -q "200"; then
    echo -e "  ${GREEN}✅ Dashboard běží (health OK)${NC}"
else
    echo -e "  ${RED}❌ Dashboard nedostupný${NC}"
fi
echo ""

# ======================================================================
# 6. ROZŠÍŘENÍ
# ======================================================================
echo -e "${BOLD}${BLUE}6. ROZŠÍŘENÍ (EXTENSIONS)${NC}"
echo "----------------------------------------"

for ext in vision network sync backup ssh proxmox; do
    if python -c "import extensions.$ext" 2>/dev/null; then
        echo -e "  ${GREEN}✅ $ext${NC}"
    else
        echo -e "  ${RED}❌ $ext (import selhal)${NC}"
        # Zjistíme příčinu
        ERR=$(python -c "try: import extensions.$ext; except Exception as e: print(e)" 2>/dev/null)
        if [ -n "$ERR" ]; then
            echo -e "     ${YELLOW}Chyba: $ERR${NC}"
        fi
    fi
done
echo ""

# ======================================================================
# 7. LOGY (POSLEDNÍ CHYBY)
# ======================================================================
echo -e "${BOLD}${BLUE}7. LOGY (POSLEDNÍCH 10 ŘÁDKŮ)${NC}"
echo "----------------------------------------"

for log in "$LOG_DIR"/*.log; do
    if [ -f "$log" ]; then
        echo -e "${CYAN}--- $(basename "$log") ---${NC}"
        tail -5 "$log" | sed 's/^/  /'
        echo ""
    fi
done

# Kontrola chyb v logu
echo -e "${CYAN}Výskyt chyb (ERROR) v logu:${NC}"
grep -r "ERROR" "$LOG_DIR" 2>/dev/null | head -5 | sed 's/^/  /' || echo "  Žádné chyby"
echo ""

# ======================================================================
# 8. VYHODNOCENÍ A DOPORUČENÍ
# ======================================================================
echo -e "${BOLD}${MAGENTA}════════════════════════════════════════════════════════════${NC}"
echo -e "${BOLD}${MAGENTA}  VYHODNOCENÍ A DOPORUČENÉ OPRAVY${NC}"
echo -e "${BOLD}${MAGENTA}════════════════════════════════════════════════════════════${NC}"
echo ""

# Seznam problémů
PROBLEMS=0

# Kontrola služeb
if ! ./starcore status 2>/dev/null | grep -q "running"; then
    echo -e "${YELLOW}⚠️  Žádné služby neběží.${NC}"
    echo -e "   ${GREEN}Oprava:${NC} ./starcore start test && ./starcore start dashboard"
    ((PROBLEMS++))
fi

# Kontrola dashboardu
if ! curl -s -o /dev/null -w "%{http_code}" http://localhost:8000/health 2>/dev/null | grep -q "200"; then
    echo -e "${YELLOW}⚠️  Dashboard není dostupný.${NC}"
    echo -e "   ${GREEN}Oprava:${NC} ./starcore start dashboard"
    ((PROBLEMS++))
fi

# Kontrola HIVE Scheduler/Orchestrator
if ./starcore hive-status 2>/dev/null | grep -q "Scheduler.*🔴 Stopped"; then
    echo -e "${YELLOW}⚠️  HIVE Scheduler a Orchestrator jsou zastaveny.${NC}"
    echo -e "   ${GREEN}Není kritické, ale pro plnou funkčnost:${NC}"
    echo -e "   python -c \"from core.hive.engine import hive; hive.start()\""
    echo -e "   python -c \"from core.hive.orchestrator import orchestrator; orchestrator.start()\""
    ((PROBLEMS++))
fi

# Kontrola rozšíření
for ext in vision network sync backup ssh proxmox; do
    if ! python -c "import extensions.$ext" 2>/dev/null; then
        echo -e "${YELLOW}⚠️  Rozšíření '$ext' není dostupné.${NC}"
        echo -e "   ${GREEN}Oprava:${NC} Zkontrolujte obsah extensions/$ext/__init__.py"
        echo -e "   ${GREEN}Případně:${NC} python -c \"import sys; sys.path.insert(0,'.'); import extensions.$ext\""
        ((PROBLEMS++))
        break
    fi
done

# Kontrola Ollamy
if ! pgrep -f "ollama serve" >/dev/null; then
    echo -e "${YELLOW}⚠️  Ollama server neběží.${NC}"
    echo -e "   ${GREEN}Oprava:${NC} nohup ollama serve > /dev/null 2>&1 &"
    ((PROBLEMS++))
fi

# Kontrola volného místa
FREE=$(df -h "$HOME" | tail -1 | awk '{print $4}' | sed 's/G//')
if [ "${FREE%.*}" -lt 5 ]; then
    echo -e "${YELLOW}⚠️  Málo volného místa na disku (${FREE}G).${NC}"
    echo -e "   ${GREEN}Doporučení:${NC} Vyčistěte nepotřebné soubory (rm -rf ~/.cache/*)"
    ((PROBLEMS++))
fi

if [ $PROBLEMS -eq 0 ]; then
    echo -e "${GREEN}✅ Všechny kontroly prošly – žádné problémy nebyly nalezeny.${NC}"
else
    echo -e "${YELLOW}⚠️  Bylo nalezeno $PROBLEMS problémů. Viz výše uvedené opravy.${NC}"
fi

echo ""
echo -e "${BOLD}${CYAN}Doporučené komplexní opravy:${NC}"
echo "  1. Spustit všechny služby:"
echo "     ./starcore start test && ./starcore start dashboard"
echo ""
echo "  2. Restartovat HIVE:"
echo "     ./starcore hive-stop && ./starcore hive-start"
echo ""
echo "  3. Pokud rozšíření stále nefungují, přidejte do core/cli/app.py:"
echo "     import sys; from pathlib import Path; sys.path.insert(0, str(Path(__file__).parent.parent.parent))"
echo ""
echo "  4. Spustit Ollama (pro lokální modely):"
echo "     nohup ollama serve > /dev/null 2>&1 &"
echo ""
echo "  5. Nastavit automatické spouštění služeb po restartu Termuxu:"
echo "     cat > ~/.termux/boot/starcore.sh << 'EOL'"
echo "     #!/bin/bash"
echo "     cd ~/STARCORE && ./starcore start test && ./starcore start dashboard && ./starcore hive-start && ./starcore ai-start"
echo "     EOL"
echo "     chmod +x ~/.termux/boot/starcore.sh"
echo ""
echo -e "${BOLD}${CYAN}════════════════════════════════════════════════════════════${NC}"
echo -e "${BOLD}${CYAN}  Diagnostika dokončena.${NC}"
echo -e "${BOLD}${CYAN}════════════════════════════════════════════════════════════${NC}"
