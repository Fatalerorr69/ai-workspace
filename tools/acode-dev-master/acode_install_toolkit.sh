#!/usr/bin/env bash
# ========================================================
# ACODE DEV TOOLKIT - KOMPLETNÍ INSTALAČNÍ SKRIPT
# Verze: 2.0.0
# ========================================================

set -e

# 🎨 Barvy pro lepší čitelnost
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'
BOLD='\033[1m'

# 📁 Základní cesty
BASE="$HOME/acode-dev-tools"
BIN="$HOME/.local/bin"
CACHE="$HOME/.cache/acode-dev"
LOG_FILE="$CACHE/install.log"
PROJECT_DIR="$HOME/muj_projekt"
PLUGIN_DIR="$HOME/.acode/plugins"

# 🔧 Funkce
log() {
    echo -e "${BLUE}[$(date '+%H:%M:%S')]${NC} $1" | tee -a "$LOG_FILE"
}

success() {
    echo -e "${GREEN}✓${NC} $1" | tee -a "$LOG_FILE"
}

warning() {
    echo -e "${YELLOW}⚠${NC} $1" | tee -a "$LOG_FILE"
}

error() {
    echo -e "${RED}✗${NC} $1" | tee -a "$LOG_FILE"
}

check_command() {
    if command -v "$1" >/dev/null 2>&1; then
        return 0
    else
        return 1
    fi
}

install_package() {
    local pkg="$1"
    if check_command "$pkg"; then
        log "Balíček $pkg je již nainstalován"
        return 0
    fi
    
    log "Instaluji balíček: $pkg"
    
    if check_command pkg; then
        pkg install -y "$pkg" && return 0
    elif check_command apt; then
        apt update && apt install -y "$pkg" && return 0
    elif check_command pacman; then
        pacman -Sy --noconfirm "$pkg" && return 0
    elif check_command yum; then
        yum install -y "$pkg" && return 0
    elif check_command dnf; then
        dnf install -y "$pkg" && return 0
    fi
    
    warning "Nepodařilo se nainstalovat: $pkg"
    return 1
}

# ========================================================
# 🚀 HLAVNÍ INSTALAČNÍ PROCES
# ========================================================

clear
echo -e "${BOLD}${BLUE}"
echo "╔══════════════════════════════════════════════════╗"
echo "║     ACODE DEV TOOLKIT - KOMPLETNÍ INSTALACE      ║"
echo "║                 Verze 2.0.0                      ║"
echo "╚══════════════════════════════════════════════════╝${NC}"
echo

# 📝 Vytvoření adresářů
log "Příprava adresářové struktury"
mkdir -p "$BASE"/{core,ai,gui,web,watcher,utils,templates,docs,plugins,reports,config}
mkdir -p "$BIN" "$CACHE" "$PROJECT_DIR" "$PLUGIN_DIR"
success "Adresáře vytvořeny"

# 🔍 Detekce prostředí
log "Detekce prostředí"
if check_command pkg; then
    ENV="Termux"
elif check_command apt; then
    ENV="Debian/Ubuntu"
elif check_command pacman; then
    ENV="Arch Linux"
else
    ENV="Neznámé"
fi
success "Detekováno: $ENV"

# 📦 Instalace základních balíčků
log "Instalace základních závislostí"
REQUIRED_PACKAGES="git curl wget unzip jq dialog"

for pkg in $REQUIRED_PACKAGES; do
    install_package "$pkg"
done

# 🤖 Instalace Ollama (AI modely)
log "Instalace AI nástrojů (Ollama)"
if ! check_command ollama; then
    curl -fsSL https://ollama.com/install.sh | sh
    success "Ollama nainstalován"
else
    success "Ollama je již nainstalován"
fi

# 📝 Core soubory
log "Generování core souborů"

cat > "$BASE/core/env.sh" << 'EOF'
#!/usr/bin/env bash
export ACODE_DEV_HOME="$HOME/acode-dev-tools"
export ACODE_CACHE="$HOME/.cache/acode-dev"
export ACODE_PROJECT="$HOME/muj_projekt"
export PATH="$HOME/.local/bin:$PATH"

alias acode-analyze="bash \$ACODE_DEV_HOME/analyze.sh"
alias acode-improve="bash \$ACODE_DEV_HOME/improve.sh"
alias acode-watch="bash \$ACODE_DEV_HOME/watch.sh"
alias acode-menu="bash \$ACODE_DEV_HOME/gui/menu.sh"
alias acode-update="bash \$ACODE_DEV_HOME/utils/update.sh"
alias acode-doctor="bash \$ACODE_DEV_HOME/core/doctor.sh"
EOF

cat > "$BASE/core/doctor.sh" << 'EOF'
#!/usr/bin/env bash
echo "=== ACODE DEV DOCTOR ==="
echo
echo "📦 Základní nástroje:"
for cmd in git curl dialog; do
    if command -v $cmd >/dev/null 2>&1; then
        echo "  ✓ $cmd"
    else
        echo "  ✗ $cmd (chybí)"
    fi
done
echo
echo "📁 Adresáře:"
for dir in "$HOME/acode-dev-tools" "$HOME/.cache/acode-dev" "$HOME/muj_projekt"; do
    if [ -d "$dir" ]; then
        echo "  ✓ $dir"
    else
        echo "  ✗ $dir (chybí)"
    fi
done
echo
echo "✅ Kontrola dokončena"
EOF
chmod +x "$BASE/core/doctor.sh"

# 🛠️ Hlavní skripty
log "Generování hlavních skriptů"

cat > "$BASE/analyze.sh" << 'EOF'
#!/usr/bin/env bash
source ~/acode-dev-tools/core/env.sh

PROJECT="${1:-$ACODE_PROJECT}"
[ ! -d "$PROJECT" ] && echo "Projekt $PROJECT neexistuje!" && exit 1

REPORT="$ACODE_DEV_HOME/reports/analysis_$(date +%Y%m%d_%H%M%S).md"
mkdir -p "$ACODE_DEV_HOME/reports"

echo "# Analýza projektu: $(basename "$PROJECT")" > "$REPORT"
echo "**Datum:** $(date)" >> "$REPORT"
echo >> "$REPORT"

echo "## 📊 Základní statistiky" >> "$REPORT"
echo "- **Velikost projektu:** $(du -sh "$PROJECT" | cut -f1)" >> "$REPORT"
echo "- **Počet souborů:** $(find "$PROJECT" -type f | wc -l)" >> "$REPORT"
echo "- **Počet adresářů:** $(find "$PROJECT" -type d | wc -l)" >> "$REPORT"
echo >> "$REPORT"

echo "## 🔍 Kontrola kódu" >> "$REPORT"
echo "### TODO/FIXME/BUG:" >> "$REPORT"
grep -rniE "TODO|FIXME|BUG|HACK|XXX" "$PROJECT" --include="*.js" --include="*.py" 2>/dev/null | head -10 | sed "s/^/- /" >> "$REPORT" || echo "Žádné poznámky" >> "$REPORT"
echo >> "$REPORT"

echo "## 🤖 AI analýza" >> "$REPORT"
echo "Pro detailní AI analýzu spusťte:" >> "$REPORT"
echo "\`\`\`bash" >> "$REPORT"
echo "bash $ACODE_DEV_HOME/ai/ai_analyze.sh $PROJECT" >> "$REPORT"
echo "\`\`\`" >> "$REPORT"

echo "✅ Analýza dokončena. Report: $REPORT"
EOF
chmod +x "$BASE/analyze.sh"

cat > "$BASE/improve.sh" << 'EOF'
#!/usr/bin/env bash
source ~/acode-dev-tools/core/env.sh

PROJECT="${1:-$ACODE_PROJECT}"
[ ! -d "$PROJECT" ] && echo "Projekt $PROJECT neexistuje!" && exit 1

echo "=== Optimalizace projektu: $(basename "$PROJECT") ==="
echo

# Kontrola duplicit
if command -v jscpd >/dev/null 2>&1; then
    echo "🔍 Kontrola duplicitního kódu..."
    jscpd "$PROJECT" --min-tokens 30 2>/dev/null || echo "Nenalezeny duplicity"
else
    echo "ℹ️ jscpd není nainstalován. Nainstalujte: npm i -g jscpd"
fi
echo

# AI návrhy
if command -v ollama >/dev/null 2>&1; then
    echo "🤖 Generuji AI návrhy pro vylepšení..."
    MAIN_FILE=$(find "$PROJECT" -name "main.js" -o -name "app.js" -o -name "index.js" | head -1)
    if [ -f "$MAIN_FILE" ]; then
        head -50 "$MAIN_FILE" | ollama run phi3:mini "Navrhni vylepšení pro tento kód:" || true
    fi
fi

echo "✅ Optimalizace dokončena"
EOF
chmod +x "$BASE/improve.sh"

cat > "$BASE/watch.sh" << 'EOF'
#!/usr/bin/env bash
source ~/acode-dev-tools/core/env.sh

PROJECT="${1:-$ACODE_PROJECT}"
[ ! -d "$PROJECT" ] && echo "Projekt $PROJECT neexistuje!" && exit 1

echo "👁️  Watch mode aktivován pro: $PROJECT"
echo "📝 Sleduji změny v souborech..."
echo "🛑 Pro zastavení stiskněte Ctrl+C"
echo

while true; do
    # Použijeme jednoduchý polling pro sledování změn
    OLD_HASH=$(find "$PROJECT" -type f -name "*.js" -exec md5sum {} \; 2>/dev/null | sort | md5sum)
    sleep 2
    NEW_HASH=$(find "$PROJECT" -type f -name "*.js" -exec md5sum {} \; 2>/dev/null | sort | md5sum)
    
    if [ "$OLD_HASH" != "$NEW_HASH" ]; then
        TIMESTAMP=$(date "+%H:%M:%S")
        echo "[$TIMESTAMP] Změna detekována, spouštím analýzu..."
        bash "$ACODE_DEV_HOME/analyze.sh" "$PROJECT" > /dev/null 2>&1 &
    fi
done
EOF
chmod +x "$BASE/watch.sh"

# 🎛️ GUI menu
log "Generování GUI rozhraní"

cat > "$BASE/gui/menu.sh" << 'EOF'
#!/usr/bin/env bash
source ~/acode-dev-tools/core/env.sh

while true; do
    CHOICE=$(dialog --clear --title "🎛️  Acode Dev Toolkit" \
        --menu "Vyberte akci:" 15 50 8 \
        1 "📊 Analýza projektu" \
        2 "🔧 Optimalizace projektu" \
        3 "👁️  Watch mode" \
        4 "🤖 AI analýza kódu" \
        5 "🔒 Kontrola zabezpečení" \
        6 "🩺 Diagnostika systému" \
        7 "🔄 Aktualizace toolkitu" \
        0 "🚪 Ukončit" \
        3>&1 1>&2 2>&3)
    
    case $CHOICE in
        1)
            bash "$ACODE_DEV_HOME/analyze.sh" "$ACODE_PROJECT"
            read -p "Stiskněte Enter pro pokračování..."
            ;;
        2)
            bash "$ACODE_DEV_HOME/improve.sh" "$ACODE_PROJECT"
            read -p "Stiskněte Enter pro pokračování..."
            ;;
        3)
            echo "Spouštím watch mode..."
            bash "$ACODE_DEV_HOME/watch.sh" "$ACODE_PROJECT"
            ;;
        4)
            bash "$ACODE_DEV_HOME/ai/ai_analyze.sh" "$ACODE_PROJECT"
            read -p "Stiskněte Enter pro pokračování..."
            ;;
        5)
            bash "$ACODE_DEV_HOME/ai/security_scan.sh" "$ACODE_PROJECT"
            read -p "Stiskněte Enter pro pokračování..."
            ;;
        6)
            bash "$ACODE_DEV_HOME/core/doctor.sh"
            read -p "Stiskněte Enter pro pokračování..."
            ;;
        7)
            bash "$ACODE_DEV_HOME/utils/update.sh"
            read -p "Stiskněte Enter pro pokračování..."
            ;;
        0)
            clear
            exit 0
            ;;
        *)
            echo "Neplatná volba"
            ;;
    esac
done
EOF
chmod +x "$BASE/gui/menu.sh"

# 🌐 Webové rozhraní
log "Generování webového rozhraní"

cat > "$BASE/web/server.sh" << 'EOF'
#!/usr/bin/env bash
PORT=${1:-8686}
echo "🌐 Acode Dev Toolkit - Webové rozhraní"
echo "📡 URL: http://localhost:$PORT"
echo "🛑 Pro zastavení stiskněte Ctrl+C"
echo

HTML_PAGE='<!DOCTYPE html>
<html>
<head>
    <title>Acode Dev Toolkit</title>
    <style>
        body {
            font-family: Arial, sans-serif;
            background: #0f172a;
            color: #e2e8f0;
            padding: 20px;
        }
        .container {
            max-width: 800px;
            margin: 0 auto;
        }
        h1 {
            color: #60a5fa;
        }
        .btn {
            display: inline-block;
            padding: 10px 20px;
            background: #3b82f6;
            color: white;
            text-decoration: none;
            border-radius: 5px;
            margin: 5px;
        }
        .btn:hover {
            background: #2563eb;
        }
    </style>
</head>
<body>
    <div class="container">
        <h1>🚀 Acode Dev Toolkit</h1>
        <p>Kompletní vývojové prostředí s AI asistencí</p>
        
        <h2>📊 Nástroje</h2>
        <a href="#" class="btn" onclick="runCmd('\''analyze'\'')">Analýza projektu</a>
        <a href="#" class="btn" onclick="runCmd('\''improve'\'')">Optimalizace</a>
        <a href="#" class="btn" onclick="runCmd('\''watch'\'')">Watch Mode</a>
        
        <h2>🤖 AI Funkce</h2>
        <a href="#" class="btn" onclick="runCmd('\''ai-analyze'\'')">AI Analýza</a>
        <a href="#" class="btn" onclick="runCmd('\''security-scan'\'')">Kontrola zabezpečení</a>
        
        <h2>🔧 Systém</h2>
        <a href="#" class="btn" onclick="runCmd('\''doctor'\'')">Diagnostika</a>
        <a href="#" class="btn" onclick="runCmd('\''update'\'')">Aktualizace</a>
        
        <div id="output" style="margin-top: 30px; padding: 15px; background: #1e293b; border-radius: 5px; min-height: 100px;">
            <pre id="output-text">Výstup se zobrazí zde...</pre>
        </div>
    </div>
    
    <script>
        function runCmd(cmd) {
            fetch('/' + cmd)
                .then(response => response.text())
                .then(data => {
                    document.getElementById('output-text').textContent = data;
                })
                .catch(error => {
                    document.getElementById('output-text').textContent = 'Chyba: ' + error;
                });
        }
    </script>
</body>
</html>'

while true; do
    echo -e "HTTP/1.1 200 OK\nContent-Type: text/html\n\n$HTML_PAGE" | nc -l -p $PORT -q 1 2>/dev/null || break
done
EOF
chmod +x "$BASE/web/server.sh"

# 🤖 AI moduly
log "Generování AI modulů"

cat > "$BASE/ai/ai_analyze.sh" << 'EOF'
#!/usr/bin/env bash
source ~/acode-dev-tools/core/env.sh

PROJECT="${1:-$ACODE_PROJECT}"
[ ! -d "$PROJECT" ] && echo "Projekt $PROJECT neexistuje!" && exit 1

if ! command -v ollama >/dev/null 2>&1; then
    echo "❌ Ollama není nainstalován"
    exit 1
fi

echo "🤖 AI analýza projektu: $(basename "$PROJECT")"
echo "⏳ Načítám AI model..."

# Najdi hlavní soubory
MAIN_FILES=$(find "$PROJECT" -type f -name "*.js" -o -name "*.py" | head -3)

for FILE in $MAIN_FILES; do
    echo ""
    echo "📄 Analýza souboru: $(basename "$FILE")"
    echo "════════════════════════════════════════"
    
    # Získej prvních 100 řádků kódu
    HEAD_CONTENT=$(head -100 "$FILE")
    
    # Analýza pomocí AI
    echo "$HEAD_CONTENT" | ollama run phi3:mini "Analyzuj tento kód a navrhni vylepšení. Buď stručný." || echo "AI analýza selhala"
    
    echo "════════════════════════════════════════"
done

echo ""
echo "✅ AI analýza dokončena"
EOF
chmod +x "$BASE/ai/ai_analyze.sh"

cat > "$BASE/ai/security_scan.sh" << 'EOF'
#!/usr/bin/env bash
source ~/acode-dev-tools/core/env.sh

PROJECT="${1:-$ACODE_PROJECT}"
[ ! -d "$PROJECT" ] && echo "Projekt $PROJECT neexistuje!" && exit 1

echo "🔒 Kontrola zabezpečení projektu: $(basename "$PROJECT")"
echo

echo "1. 🔍 Kontrola citlivých dat:"
SENSITIVE_PATTERNS=("password" "secret" "token" "api_key" "private_key")

for pattern in "${SENSITIVE_PATTERNS[@]}"; do
    grep -rni "$pattern" "$PROJECT" --include="*.js" --include="*.py" --include="*.json" --include="*.env" 2>/dev/null | head -3 | while read -r line; do
        echo "   ⚠️  Nalezeno: $line"
    done
done
echo

echo "2. ⚡ Kontrola nebezpečných funkcí:"
DANGEROUS_PATTERNS=("eval(" "setTimeout(" "exec(")

for pattern in "${DANGEROUS_PATTERNS[@]}"; do
    grep -rni "$pattern" "$PROJECT" --include="*.js" 2>/dev/null | head -3 | while read -r line; do
        echo "   ⚠️  Potenciálně nebezpečné: $line"
    done
done
echo

echo "✅ Kontrola zabezpečení dokončena"
EOF
chmod +x "$BASE/ai/security_scan.sh"

# 🛠️ Utility
log "Generování utilit"

cat > "$BASE/utils/stats.sh" << 'EOF'
#!/usr/bin/env bash
source ~/acode-dev-tools/core/env.sh

PROJECT="${1:-$ACODE_PROJECT}"
[ ! -d "$PROJECT" ] && echo "Projekt $PROJECT neexistuje!" && exit 1

echo "📈 Statistiky projektu: $(basename "$PROJECT")"
echo "════════════════════════════════════════"
echo

TOTAL_FILES=$(find "$PROJECT" -type f | wc -l)
TOTAL_DIRS=$(find "$PROJECT" -type d | wc -l)
TOTAL_SIZE=$(du -sh "$PROJECT" | cut -f1)

echo "📁 Základní informace:"
echo "   • Velikost projektu: $TOTAL_SIZE"
echo "   • Počet souborů: $TOTAL_FILES"
echo "   • Počet adresářů: $TOTAL_DIRS"
echo

echo "📊 Typy souborů:"
find "$PROJECT" -type f | sed 's/.*\.//' | sort | uniq -c | sort -rn | head -5 | while read count extension; do
    echo "   • $extension: $count souborů"
done
echo

echo "✅ Statistiky dokončeny"
EOF
chmod +x "$BASE/utils/stats.sh"

cat > "$BASE/utils/update.sh" << 'EOF'
#!/usr/bin/env bash
source ~/acode-dev-tools/core/env.sh

echo "🔄 Acode Dev Toolkit - Aktualizace"
echo "════════════════════════════════════════"
echo

echo "1. 🔧 Oprava oprávnění skriptů..."
chmod +x "$ACODE_DEV_HOME"/*.sh 2>/dev/null
chmod +x "$ACODE_DEV_HOME"/**/*.sh 2>/dev/null
echo

echo "2. 🤖 Kontrola aktualizací AI modelů..."
if command -v ollama >/dev/null 2>&1; then
    ollama pull phi3:mini 2>/dev/null || echo "Nelze aktualizovat AI modely"
fi
echo

echo "✅ Aktualizace dokončena!"
echo "📅 Poslední aktualizace: $(date)" > "$ACODE_DEV_HOME/LAST_UPDATE"
echo "════════════════════════════════════════"
EOF
chmod +x "$BASE/utils/update.sh"

# 📄 Templates
log "Generování šablon projektů"

# JavaScript šablona
mkdir -p "$BASE/templates/javascript/src"
cat > "$BASE/templates/javascript/src/main.js" << 'EOF'
// Acode Dev Toolkit - JavaScript šablona

console.log("🚀 Acode Dev Toolkit - JavaScript projekt");

class Calculator {
    constructor() {
        this.version = "1.0.0";
    }
    
    add(a, b) {
        return a + b;
    }
    
    subtract(a, b) {
        return a - b;
    }
    
    multiply(a, b) {
        return a * b;
    }
    
    divide(a, b) {
        if (b === 0) {
            throw new Error("Nelze dělit nulou");
        }
        return a / b;
    }
}

// Použití
const calc = new Calculator();
console.log(`Kalkulačka v${calc.version}`);

const x = 10;
const y = 5;

console.log(`${x} + ${y} = ${calc.add(x, y)}`);
console.log(`${x} - ${y} = ${calc.subtract(x, y)}`);
console.log(`${x} * ${y} = ${calc.multiply(x, y)}`);
console.log(`${x} / ${y} = ${calc.divide(x, y)}`);

// TODO: Přidat pokročilejší funkce
// FIXME: Zvážit přidání historie výpočtů

console.log("✅ Projekt je připraven k analýze!");
EOF

# Python šablona
mkdir -p "$BASE/templates/python/src"
cat > "$BASE/templates/python/src/main.py" << 'EOF'
#!/usr/bin/env python3
# Acode Dev Toolkit - Python šablona

import sys

class Application:
    """Hlavní třída aplikace"""
    
    def __init__(self):
        self.version = "1.0.0"
        print(f"Aplikace v{self.version} inicializována")
    
    def run(self):
        """Hlavní metoda pro spuštění aplikace"""
        print("Spouštím aplikaci...")
        
        try:
            self.execute_main_logic()
            print("Aplikace úspěšně dokončena")
        except Exception as e:
            print(f"Chyba při spuštění aplikace: {e}")
            sys.exit(1)
    
    def execute_main_logic(self):
        """Spustí hlavní logiku aplikace"""
        print("Spouštím hlavní logiku...")
        
        # Příklad výpočtu
        result = self.calculate_sum([1, 2, 3, 4, 5])
        print(f"Součet čísel: {result}")
    
    def calculate_sum(self, numbers):
        """Vypočítá součet čísel"""
        return sum(numbers)

def main():
    """Hlavní vstupní bod aplikace"""
    app = Application()
    app.run()

if __name__ == "__main__":
    main()
EOF

# 🎯 Finalizace
log "Finalizace instalace"

# Vytvoření aliasu
if [ -f "$HOME/.bashrc" ]; then
    if ! grep -q "alias ai=" "$HOME/.bashrc"; then
        echo "alias ai='bash ~/acode-dev-tools/gui/menu.sh'" >> "$HOME/.bashrc"
        success "Alias 'ai' přidán do .bashrc"
    fi
fi

if [ -f "$HOME/.zshrc" ]; then
    if ! grep -q "alias ai=" "$HOME/.zshrc"; then
        echo "alias ai='bash ~/acode-dev-tools/gui/menu.sh'" >> "$HOME/.zshrc"
        success "Alias 'ai' přidán do .zshrc"
    fi
fi

# Vytvoření ukázkového projektu
mkdir -p "$PROJECT_DIR/src"
cat > "$PROJECT_DIR/src/main.js" << 'EOF'
// Vítejte v Acode Dev Toolkit!
// Toto je váš první projekt

console.log("🚀 Acode Dev Toolkit - Ukázkový projekt");

function calculateCircleArea(radius) {
    return Math.PI * radius * radius;
}

function calculateRectangleArea(width, height) {
    return width * height;
}

// Testovací příklady
console.log("Plocha kruhu (r=5):", calculateCircleArea(5));
console.log("Plocha obdélníku (5x10):", calculateRectangleArea(5, 10));

// TODO: Přidat další geometrické funkce
// FIXME: Ošetřit záporné hodnoty

console.log("✅ Projekt je připraven k analýze!");
EOF

# 📊 Statistika instalace
TOTAL_FILES_CREATED=$(find "$BASE" -type f | wc -l)
TOTAL_DIRS_CREATED=$(find "$BASE" -type d | wc -l)

# 🎉 Dokončení
echo
echo -e "${GREEN}╔══════════════════════════════════════════════════╗${NC}"
echo -e "${GREEN}║      INSTALACE ÚSPĚŠNĚ DOKONČENA!               ║${NC}"
echo -e "${GREEN}╚══════════════════════════════════════════════════╝${NC}"
echo
echo -e "${BOLD}📊 Statistika instalace:${NC}"
echo -e "  • Vytvořeno souborů: $TOTAL_FILES_CREATED"
echo -e "  • Vytvořeno adresářů: $TOTAL_DIRS_CREATED"
echo
echo -e "${BOLD}🚀 Jak začít:${NC}"
echo -e "  1. Spusťte TUI rozhraní: ${GREEN}ai${NC}"
echo -e "  2. Nebo webové rozhraní: ${GREEN}bash ~/acode-dev-tools/web/server.sh${NC}"
echo -e "  3. Analyzujte projekt: ${GREEN}bash ~/acode-dev-tools/analyze.sh ~/muj_projekt${NC}"
echo
echo -e "${BOLD}🌐 Webové rozhraní:${NC}"
echo -e "  Po spuštění serveru otevřete: ${GREEN}http://localhost:8686${NC}"
echo
echo -e "${BOLD}🤖 AI funkce:${NC}"
echo -e "  Pro AI analýzu: ${GREEN}bash ~/acode-dev-tools/ai/ai_analyze.sh${NC}"
echo
echo -e "${YELLOW}⚠️  Pro aktivaci aliasů restartujte terminál nebo proveďte:${NC}"
echo -e "  ${GREEN}source ~/.bashrc${NC} (nebo ~/.zshrc)"
echo
echo -e "${BLUE}📅 Instalace dokončena: $(date)${NC}"
echo -e "${BLUE}📋 Log instalace: $LOG_FILE${NC}"
echo
echo -e "${GREEN}✅ Acode Dev Toolkit v2.0 je připraven k použití!${NC}"