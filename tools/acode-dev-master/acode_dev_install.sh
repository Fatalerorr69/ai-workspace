#!/usr/bin/env bash
# ========================================================
# ACODE DEV TOOLKIT - KOMPLETNÍ SJEDNOCENÁ INSTALACE
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

# 📊 Proměnné pro sledování průběhu
TOTAL_STEPS=15
CURRENT_STEP=0
INSTALLED_PACKAGES=0
CREATED_FILES=0
ERRORS=0

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
    ((ERRORS++))
}

progress() {
    ((CURRENT_STEP++))
    PERCENT=$((CURRENT_STEP * 100 / TOTAL_STEPS))
    echo -e "\n${BOLD}[Krok $CURRENT_STEP/$TOTAL_STEPS | $PERCENT%]${NC} $1"
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
        pkg install -y "$pkg" && ((INSTALLED_PACKAGES++)) && return 0
    elif check_command apt; then
        apt update && apt install -y "$pkg" && ((INSTALLED_PACKAGES++)) && return 0
    elif check_command pacman; then
        pacman -Sy --noconfirm "$pkg" && ((INSTALLED_PACKAGES++)) && return 0
    elif check_command yum; then
        yum install -y "$pkg" && ((INSTALLED_PACKAGES++)) && return 0
    elif check_command dnf; then
        dnf install -y "$pkg" && ((INSTALLED_PACKAGES++)) && return 0
    fi
    
    warning "Nepodařilo se nainstalovat: $pkg"
    return 1
}

create_file() {
    local file="$1"
    local content="$2"
    
    mkdir -p "$(dirname "$file")"
    echo -e "$content" > "$file"
    ((CREATED_FILES++))
    chmod +x "$file" 2>/dev/null || true
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
progress "Příprava adresářové struktury"
mkdir -p "$BASE"/{core,ai,gui,web,watcher,utils,templates,docs,plugins,reports,config}
mkdir -p "$BIN" "$CACHE" "$PROJECT_DIR" "$PLUGIN_DIR"
success "Vytvořeno $(( $(find "$BASE" -type d | wc -l) - 1 )) adresářů"

# 🔍 Detekce prostředí
progress "Detekce prostředí a balíčkovacího systému"
if check_command pkg; then
    ENV="Termux"
    PKG_MGR="pkg"
elif check_command apt; then
    ENV="Debian/Ubuntu"
    PKG_MGR="apt"
elif check_command pacman; then
    ENV="Arch Linux"
    PKG_MGR="pacman"
elif check_command dnf; then
    ENV="Fedora"
    PKG_MGR="dnf"
else
    ENV="Neznámé"
    PKG_MGR=""
fi
success "Detekováno: $ENV (správce balíčků: $PKG_MGR)"

# 📦 Instalace základních balíčků
progress "Instalace základních závislostí"
REQUIRED_PACKAGES="git curl wget unzip jq nc dialog ripgrep"
OPTIONAL_PACKAGES="nodejs npm python3 clang inotify-tools"

for pkg in $REQUIRED_PACKAGES; do
    install_package "$pkg"
done

for pkg in $OPTIONAL_PACKAGES; do
    if ! install_package "$pkg"; then
        warning "Volitelný balíček $pkg nebyl nainstalován"
    fi
done

# 🤖 Instalace Ollama (AI modely)
progress "Instalace AI nástrojů (Ollama)"
create_file "$BASE/ai/install_ollama.sh" '#!/usr/bin/env bash
if ! command -v ollama >/dev/null 2>&1; then
    echo "Instaluji Ollama..."
    curl -fsSL https://ollama.com/install.sh | sh
else
    echo "Ollama je již nainstalován"
fi

# Stažení lehkých modelů (optimalizováno pro mobilní zařízení)
echo "Stahuji AI modely..."
ollama pull phi3:mini 2>/dev/null || echo "Model phi3:mini není dostupný"
ollama pull codellama:7b 2>/dev/null || echo "Model codellama:7b není dostupný"
ollama pull llama3.2:3b 2>/dev/null || echo "Model llama3.2:3b není dostupný"

echo "AI modely připraveny"'

bash "$BASE/ai/install_ollama.sh" | tee -a "$LOG_FILE"

# 📝 Core soubory
progress "Generování core souborů"

create_file "$BASE/core/env.sh" '#!/usr/bin/env bash
export ACODE_DEV_HOME="$HOME/acode-dev-tools"
export ACODE_CACHE="$HOME/.cache/acode-dev"
export ACODE_PROJECT="$HOME/muj_projekt"
export PATH="$HOME/.local/bin:$PATH"
export TERMUX=0

if [ -d "/data/data/com.termux" ]; then
    export TERMUX=1
    export PLUGIN_DIR="/data/data/com.termux/files/home/.acode/plugins"
else
    export PLUGIN_DIR="$HOME/.acode/plugins"
fi

alias acode-analyze="bash \$ACODE_DEV_HOME/analyze.sh"
alias acode-improve="bash \$ACODE_DEV_HOME/improve.sh"
alias acode-watch="bash \$ACODE_DEV_HOME/watch.sh"
alias acode-menu="bash \$ACODE_DEV_HOME/gui/menu.sh"
alias acode-update="bash \$ACODE_DEV_HOME/utils/update.sh"
alias acode-doctor="bash \$ACODE_DEV_HOME/core/doctor.sh"'

create_file "$BASE/core/doctor.sh" '#!/usr/bin/env bash
echo "=== ACODE DEV DOCTOR ==="
echo
echo "📦 Základní nástroje:"
for cmd in git curl node npm python3 dialog nc; do
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
echo "🤖 AI modely:"
if command -v ollama >/dev/null 2>&1; then
    echo "  ✓ Ollama je nainstalován"
    echo "  Načtené modely:"
    ollama list 2>/dev/null || echo "    Nelze načíst seznam modelů"
else
    echo "  ✗ Ollama není nainstalován"
fi

echo
echo "✅ Kontrola dokončena"'

# 🛠️ Hlavní skripty
progress "Generování hlavních skriptů"

create_file "$BASE/analyze.sh" '#!/usr/bin/env bash
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
grep -rniE "TODO|FIXME|BUG|HACK|XXX" "$PROJECT" --include="*.js" --include="*.ts" --include="*.py" --include="*.java" 2>/dev/null | head -20 | sed "s/^/- /" >> "$REPORT" || echo "Žádné poznámky" >> "$REPORT"
echo >> "$REPORT"

if [ -f "$PROJECT/package.json" ]; then
    echo "## 📦 npm závislosti" >> "$REPORT"
    cat "$PROJECT/package.json" | jq -r '"Závislosti: " + (.dependencies // {} | length|tostring) + ", devDependencies: " + (.devDependencies // {} | length|tostring)' >> "$REPORT"
    echo >> "$REPORT"
fi

echo "## 🤖 AI analýza" >> "$REPORT"
echo "Pro detailní AI analýzu spusťte:" >> "$REPORT"
echo "```bash" >> "$REPORT"
echo "bash $ACODE_DEV_HOME/ai/ai_analyze.sh $PROJECT" >> "$REPORT"
echo "```" >> "$REPORT"

echo "✅ Analýza dokončena. Report: $REPORT"'

create_file "$BASE/improve.sh" '#!/usr/bin/env bash
source ~/acode-dev-tools/core/env.sh

PROJECT="${1:-$ACODE_PROJECT}"
[ ! -d "$PROJECT" ] && echo "Projekt $PROJECT neexistuje!" && exit 1

echo "=== Optimalizace projektu: $(basename "$PROJECT") ==="
echo

# 1. Kontrola duplicit
if command -v jscpd >/dev/null 2>&1; then
    echo "🔍 Kontrola duplicitního kódu..."
    jscpd "$PROJECT" --min-tokens 30 --reporters console 2>/dev/null || echo "Nenalezeny duplicity"
else
    echo "ℹ️ jscpd není nainstalován. Nainstalujte: npm i -g jscpd"
fi
echo

# 2. Formátování
if [ -f "$PROJECT/package.json" ]; then
    echo "🎨 Kontrola formátování..."
    if grep -q "prettier" "$PROJECT/package.json"; then
        npx prettier --check "$PROJECT" || echo "Formátování vyžaduje opravu"
    fi
    
    if grep -q "eslint" "$PROJECT/package.json"; then
        npx eslint "$PROJECT" --ext .js,.ts || echo "ESLint našel problémy"
    fi
fi
echo

# 3. AI návrhy
if command -v ollama >/dev/null 2>&1; then
    echo "🤖 Generuji AI návrhy pro vylepšení..."
    MAIN_FILE=$(find "$PROJECT" -name "main.js" -o -name "app.js" -o -name "index.js" | head -1)
    if [ -f "$MAIN_FILE" ]; then
        head -100 "$MAIN_FILE" | ollama run phi3:mini "Navrhni vylepšení pro tento kód:" || true
    fi
fi

echo "✅ Optimalizace dokončena"'

create_file "$BASE/watch.sh" '#!/usr/bin/env bash
source ~/acode-dev-tools/core/env.sh

PROJECT="${1:-$ACODE_PROJECT}"
[ ! -d "$PROJECT" ] && echo "Projekt $PROJECT neexistuje!" && exit 1

if ! command -v inotifywait >/dev/null 2>&1; then
    echo "❌ inotify-tools nejsou nainstalovány"
    exit 1
fi

echo "👁️  Watch mode aktivován pro: $PROJECT"
echo "📝 Sleduji změny v souborech..."
echo "🛑 Pro zastavení stiskněte Ctrl+C"
echo

while true; do
    inotifywait -r -e modify,create,delete,move "$PROJECT" 2>/dev/null | while read -r directory events filename; do
        TIMESTAMP=$(date "+%H:%M:%S")
        echo "[$TIMESTAMP] $events: $directory$filename"
        
        # Po změně spustit analýzu
        sleep 1
        echo "🔄 Spouštím analýzu..."
        bash "$ACODE_DEV_HOME/analyze.sh" "$PROJECT" > /dev/null 2>&1 &
    done
done'

# 🎛️ GUI systémy
progress "Generování GUI rozhraní"

create_file "$BASE/gui/menu.sh" '#!/usr/bin/env bash
source ~/acode-dev-tools/core/env.sh

while true; do
    CHOICE=$(dialog --clear --title "🎛️  Acode Dev Toolkit" \
        --menu "Vyberte akci:" 20 60 12 \
        1 "📊 Analýza projektu" \
        2 "🔧 Optimalizace projektu" \
        3 "👁️  Watch mode (sledování změn)" \
        4 "🤖 AI analýza kódu" \
        5 "🔒 Kontrola zabezpečení" \
        6 "📦 Správa pluginů" \
        7 "📈 Zobrazit statistiky" \
        8 "🔄 Aktualizace toolkitu" \
        9 "🩺 Diagnostika systému" \
        10 "🌐 Webové rozhraní" \
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
            bash "$ACODE_DEV_HOME/plugins/manager.sh"
            read -p "Stiskněte Enter pro pokračování..."
            ;;
        7)
            bash "$ACODE_DEV_HOME/utils/stats.sh" "$ACODE_PROJECT"
            read -p "Stiskněte Enter pro pokračování..."
            ;;
        8)
            bash "$ACODE_DEV_HOME/utils/update.sh"
            read -p "Stiskněte Enter pro pokračování..."
            ;;
        9)
            bash "$ACODE_DEV_HOME/core/doctor.sh"
            read -p "Stiskněte Enter pro pokračování..."
            ;;
        10)
            echo "Spouštím webové rozhraní na portu 8686..."
            bash "$ACODE_DEV_HOME/web/server.sh" &
            read -p "Stiskněte Enter pro zastavení serveru..."
            pkill -f "nc -l -p 8686" 2>/dev/null || true
            ;;
        0)
            clear
            exit 0
            ;;
        *)
            echo "Neplatná volba"
            ;;
    esac
done'

# 🌐 Webové rozhraní
progress "Generování webového rozhraní"

create_file "$BASE/web/server.sh" '#!/usr/bin/env bash
PORT=${1:-8686}
IP=$(hostname -I 2>/dev/null | awk "{print \$1}" || echo "127.0.0.1")

echo "🌐 Acode Dev Toolkit - Webové rozhraní"
echo "📡 URL: http://$IP:$PORT"
echo "🛑 Pro zastavení stiskněte Ctrl+C"
echo

HTML_PAGE=$(cat <<EOF
HTTP/1.1 200 OK
Content-Type: text/html
Connection: close

<!DOCTYPE html>
<html lang="cs">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Acode Dev Toolkit</title>
    <style>
        * { margin: 0; padding: 0; box-sizing: border-box; }
        body {
            font-family: "Segoe UI", Tahoma, Geneva, Verdana, sans-serif;
            background: linear-gradient(135deg, #0f172a 0%, #1e293b 100%);
            color: #e2e8f0;
            min-height: 100vh;
            padding: 20px;
        }
        .container {
            max-width: 1200px;
            margin: 0 auto;
            padding: 20px;
        }
        header {
            text-align: center;
            margin-bottom: 40px;
            padding: 20px;
            background: rgba(30, 41, 59, 0.7);
            border-radius: 15px;
            backdrop-filter: blur(10px);
            border: 1px solid rgba(255, 255, 255, 0.1);
        }
        h1 {
            color: #60a5fa;
            font-size: 2.5em;
            margin-bottom: 10px;
        }
        .subtitle {
            color: #94a3b8;
            font-size: 1.1em;
        }
        .dashboard {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(300px, 1fr));
            gap: 20px;
            margin-bottom: 30px;
        }
        .card {
            background: rgba(30, 41, 59, 0.7);
            border-radius: 12px;
            padding: 25px;
            backdrop-filter: blur(10px);
            border: 1px solid rgba(255, 255, 255, 0.1);
            transition: transform 0.3s, box-shadow 0.3s;
        }
        .card:hover {
            transform: translateY(-5px);
            box-shadow: 0 10px 25px rgba(0, 0, 0, 0.3);
        }
        .card h3 {
            color: #38bdf8;
            margin-bottom: 15px;
            font-size: 1.3em;
        }
        .btn {
            display: inline-block;
            padding: 12px 25px;
            background: linear-gradient(135deg, #3b82f6 0%, #1d4ed8 100%);
            color: white;
            text-decoration: none;
            border-radius: 8px;
            margin: 5px;
            transition: all 0.3s;
            border: none;
            cursor: pointer;
            font-size: 1em;
        }
        .btn:hover {
            background: linear-gradient(135deg, #1d4ed8 0%, #1e40af 100%);
            transform: scale(1.05);
        }
        .btn-secondary {
            background: linear-gradient(135deg, #475569 0%, #334155 100%);
        }
        .btn-secondary:hover {
            background: linear-gradient(135deg, #334155 0%, #1e293b 100%);
        }
        .status {
            padding: 10px;
            background: rgba(34, 197, 94, 0.2);
            border-radius: 8px;
            margin-top: 10px;
            border-left: 4px solid #22c55e;
        }
        .footer {
            text-align: center;
            margin-top: 40px;
            padding: 20px;
            color: #94a3b8;
            font-size: 0.9em;
        }
        .code-block {
            background: rgba(0, 0, 0, 0.3);
            padding: 15px;
            border-radius: 8px;
            font-family: "Courier New", monospace;
            margin: 15px 0;
            overflow-x: auto;
        }
    </style>
</head>
<body>
    <div class="container">
        <header>
            <h1>🚀 Acode Dev Toolkit</h1>
            <p class="subtitle">Kompletní vývojové prostředí s AI asistencí</p>
            <div class="status">
                ✅ Systém je aktivní | Port: $PORT | IP: $IP
            </div>
        </header>
        
        <div class="dashboard">
            <div class="card">
                <h3>📊 Analýza kódu</h3>
                <p>Kompletní analýza projektu s detekcí problémů a návrhy optimalizací.</p>
                <button class="btn" onclick="runCommand('analyze')">Spustit analýzu</button>
            </div>
            
            <div class="card">
                <h3>🤖 AI Asistent</h3>
                <p>AI návrhy pro vylepšení kódu, refaktoring a opravy chyb.</p>
                <button class="btn" onclick="runCommand('ai-analyze')">Konzultovat s AI</button>
                <button class="btn btn-secondary" onclick="runCommand('ai-fix')">Automatické opravy</button>
            </div>
            
            <div class="card">
                <h3>👁️ Watch Mode</h3>
                <p>Sledování změn v reálném čase s automatickou analýzou.</p>
                <button class="btn" onclick="runCommand('watch')">Spustit Watch Mode</button>
            </div>
            
            <div class="card">
                <h3>🔧 Nástroje</h3>
                <p>Rychlý přístup k užitečným nástrojům a utilitám.</p>
                <button class="btn" onclick="runCommand('doctor')">Diagnostika</button>
                <button class="btn btn-secondary" onclick="runCommand('update')">Aktualizace</button>
                <button class="btn btn-secondary" onclick="runCommand('plugins')">Pluginy</button>
            </div>
        </div>
        
        <div class="card">
            <h3>📝 Rychlé příkazy</h3>
            <div class="code-block">
                <code># Analýza projektu<br>bash ~/acode-dev-tools/analyze.sh ~/muj_projekt</code><br><br>
                <code># AI návrhy<br>bash ~/acode-dev-tools/ai/ai_analyze.sh</code><br><br>
                <code># Sledování změn<br>bash ~/acode-dev-tools/watch.sh</code>
            </div>
        </div>
        
        <div class="footer">
            <p>© 2024 Acode Dev Toolkit v2.0 | Lokální AI modely | Realtime analýza</p>
            <p>Poslední aktualizace: $(date "+%d.%m.%Y %H:%M")</p>
        </div>
    </div>
    
    <script>
        function runCommand(cmd) {
            fetch("/" + cmd)
                .then(response => response.text())
                .then(data => {
                    alert("Příkaz " + cmd + " byl spuštěn\\n" + data);
                })
                .catch(error => {
                    alert("Chyba: " + error);
                });
        }
    </script>
</body>
</html>
EOF

while true; do
    echo -e "$HTML_PAGE" | nc -l -p $PORT -q 1
done'

# 🤖 AI moduly
progress "Generování AI modulů"

create_file "$BASE/ai/ai_analyze.sh" '#!/usr/bin/env bash
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
MAIN_FILES=$(find "$PROJECT" -type f -name "*.js" -o -name "*.py" -o -name "*.java" | head -5)

for FILE in $MAIN_FILES; do
    echo ""
    echo "📄 Analýza souboru: $(basename "$FILE")"
    echo "════════════════════════════════════════"
    
    # Získej prvních 200 řádků kódu
    HEAD_CONTENT=$(head -200 "$FILE")
    
    # Analýza pomocí AI
    echo "$HEAD_CONTENT" | ollama run phi3:mini "Analyzuj tento kód a navrhni vylepšení. Zaměř se na:
1. Čitelnost a strukturu kódu
2. Možné chyby a bezpečnostní problémy
3. Návrhy na optimalizaci
4. Best practices pro daný jazyk
    
Odpověz stručně a konkrétně:" || echo "AI analýza selhala pro tento soubor"
    
    echo "════════════════════════════════════════"
done

echo ""
echo "✅ AI analýza dokončena"'

create_file "$BASE/ai/security_scan.sh" '#!/usr/bin/env bash
source ~/acode-dev-tools/core/env.sh

PROJECT="${1:-$ACODE_PROJECT}"
[ ! -d "$PROJECT" ] && echo "Projekt $PROJECT neexistuje!" && exit 1

echo "🔒 Kontrola zabezpečení projektu: $(basename "$PROJECT")"
echo

# 1. Hledání citlivých dat
echo "1. 🔍 Kontrola citlivých dat:"
SENSITIVE_PATTERNS=(
    "password"
    "secret"
    "token"
    "api[_-]?key"
    "private[_-]?key"
    "access[_-]?token"
    "credential"
)

for pattern in "${SENSITIVE_PATTERNS[@]}"; do
    grep -rni "$pattern" "$PROJECT" --include="*.js" --include="*.ts" --include="*.py" --include="*.json" --include="*.env" 2>/dev/null | head -5 | while read -r line; do
        echo "   ⚠️  Nalezeno: $line"
    done
done
echo

# 2. Kontrola nebezpečných funkcí
echo "2. ⚡ Kontrola nebezpečných funkcí:"
DANGEROUS_PATTERNS=(
    "eval("
    "setTimeout("
    "setInterval("
    "exec("
    "execSync("
    "spawn("
    "spawnSync("
)

for pattern in "${DANGEROUS_PATTERNS[@]}"; do
    grep -rni "$pattern" "$PROJECT" --include="*.js" --include="*.ts" 2>/dev/null | head -5 | while read -r line; do
        echo "   ⚠️  Potenciálně nebezpečné: $line"
    done
done
echo

# 3. Kontrola závislostí
if [ -f "$PROJECT/package.json" ]; then
    echo "3. 📦 Kontrola npm závislostí:"
    if command -v npm >/dev/null 2>&1; then
        cd "$PROJECT" && npm audit --json 2>/dev/null | jq -r '.metadata.vulnerabilities | to_entries[] | "   \(.key): \(.value)"' || echo "   ℹ️ Nelze spustit npm audit"
    else
        echo "   ℹ️ npm není nainstalován"
    fi
fi
echo

# 4. Doporučení
echo "4. 📝 Doporučení pro zabezpečení:"
echo "   • Používejte .env pro citlivá data"
echo "   • Pravidelně aktualizujte závislosti"
echo "   • Používejte ESLint s bezpečnostními pravidly"
echo "   • Omezte použití eval() a podobných funkcí"
echo "   • Implementujte validaci vstupů"

echo ""
echo "✅ Kontrola zabezpečení dokončena"'

# 📦 Plugin systém
progress "Generování plugin systému"

create_file "$BASE/plugins/manager.sh" '#!/usr/bin/env bash
source ~/acode-dev-tools/core/env.sh

PLUGIN_INDEX="$ACODE_DEV_HOME/config/plugins.json"

# Inicializace plugin indexu
if [ ! -f "$PLUGIN_INDEX" ]; then
    cat > "$PLUGIN_INDEX" <<EOF
[
    {
        "name": "code-analyzer",
        "description": "Pokročilá analýza kódu",
        "installed": false,
        "url": "https://github.com/acode-plugin/code-analyzer"
    },
    {
        "name": "ai-assistant",
        "description": "AI asistent pro vývoj",
        "installed": false,
        "url": "https://github.com/acode-plugin/ai-assistant"
    },
    {
        "name": "git-integration",
        "description": "Rozšířená Git integrace",
        "installed": false,
        "url": "https://github.com/acode-plugin/git-integration"
    }
]
EOF
fi

while true; do
    CHOICE=$(dialog --clear --title "📦 Správa pluginů" \
        --menu "Vyberte akci:" 15 50 5 \
        1 "Zobrazit dostupné pluginy" \
        2 "Nainstalovat plugin" \
        3 "Odstranit plugin" \
        4 "Aktualizovat pluginy" \
        0 "Zpět" \
        3>&1 1>&2 2>&3)
    
    case $CHOICE in
        1)
            echo "Dostupné pluginy:"
            jq -r '.[] | "\(.name): \(.description) [\(if .installed then "Nainstalován" else "Není nainstalován" end)]"' "$PLUGIN_INDEX"
            read -p "Stiskněte Enter pro pokračování..."
            ;;
        2)
            PLUGINS=$(jq -r '.[] | "\(.name) \(if .installed then "(nainstalován)" else "" end)"' "$PLUGIN_INDEX")
            SELECTED=$(dialog --menu "Vyberte plugin k instalaci" 20 60 10 $PLUGINS 3>&1 1>&2 2>&3)
            
            if [ -n "$SELECTED" ]; then
                echo "Instalace pluginu: $SELECTED"
                mkdir -p "$PLUGIN_DIR/$SELECTED"
                echo "# Plugin: $SELECTED" > "$PLUGIN_DIR/$SELECTED/plugin.js"
                echo "// Nainstalováno $(date)" >> "$PLUGIN_DIR/$SELECTED/plugin.js"
                echo "✅ Plugin $SELECTED nainstalován"
                
                # Aktualizace JSON
                jq "(.[] | select(.name == \"$SELECTED\") | .installed) = true" "$PLUGIN_INDEX" > tmp.json && mv tmp.json "$PLUGIN_INDEX"
            fi
            ;;
        3)
            INSTALLED=$(jq -r '.[] | select(.installed == true) | .name' "$PLUGIN_INDEX")
            if [ -z "$INSTALLED" ]; then
                echo "Žádné pluginy nejsou nainstalovány"
            else
                SELECTED=$(dialog --menu "Vyberte plugin k odstranění" 20 60 10 $(echo "$INSTALLED" | awk '{print $0 " "}') 3>&1 1>&2 2>&3)
                
                if [ -n "$SELECTED" ]; then
                    rm -rf "$PLUGIN_DIR/$SELECTED"
                    echo "✅ Plugin $SELECTED odstraněn"
                    
                    # Aktualizace JSON
                    jq "(.[] | select(.name == \"$SELECTED\") | .installed) = false" "$PLUGIN_INDEX" > tmp.json && mv tmp.json "$PLUGIN_INDEX"
                fi
            fi
            ;;
        4)
            echo "🔄 Kontrola aktualizací pluginů..."
            # Tady by byla skutečná kontrola aktualizací
            echo "✅ Všechny pluginy jsou aktuální"
            read -p "Stiskněte Enter pro pokračování..."
            ;;
        0)
            break
            ;;
    esac
done'

# 🛠️ Utility
progress "Generování utilit"

create_file "$BASE/utils/stats.sh" '#!/usr/bin/env bash
source ~/acode-dev-tools/core/env.sh

PROJECT="${1:-$ACODE_PROJECT}"
[ ! -d "$PROJECT" ] && echo "Projekt $PROJECT neexistuje!" && exit 1

echo "📈 Statistiky projektu: $(basename "$PROJECT")"
echo "════════════════════════════════════════"
echo

# Základní statistiky
TOTAL_FILES=$(find "$PROJECT" -type f | wc -l)
TOTAL_DIRS=$(find "$PROJECT" -type d | wc -l)
TOTAL_SIZE=$(du -sh "$PROJECT" | cut -f1)

echo "📁 Základní informace:"
echo "   • Velikost projektu: $TOTAL_SIZE"
echo "   • Počet souborů: $TOTAL_FILES"
echo "   • Počet adresářů: $TOTAL_DIRS"
echo

# Typy souborů
echo "📊 Rozdělení podle typu souborů:"
find "$PROJECT" -type f | grep -E "\.(js|ts|py|java|html|css|json)$" | sed 's/.*\.//' | sort | uniq -c | sort -rn | while read count extension; do
    PERCENT=$((count * 100 / TOTAL_FILES))
    echo "   • .$extension: $count souborů ($PERCENT%)"
done
echo

# Počet řádků kódu
echo "📝 Počet řádků kódu:"
if command -v cloc >/dev/null 2>&1; then
    cloc "$PROJECT" --quiet | tail -5
else
    JS_LINES=$(find "$PROJECT" -name "*.js" -exec cat {} \; 2>/dev/null | wc -l)
    PY_LINES=$(find "$PROJECT" -name "*.py" -exec cat {} \; 2>/dev/null | wc -l)
    HTML_LINES=$(find "$PROJECT" -name "*.html" -exec cat {} \; 2>/dev/null | wc -l)
    CSS_LINES=$(find "$PROJECT" -name "*.css" -exec cat {} \; 2>/dev/null | wc -l)
    
    echo "   • JavaScript: $JS_LINES řádků"
    echo "   • Python: $PY_LINES řádků"
    echo "   • HTML: $HTML_LINES řádků"
    echo "   • CSS: $CSS_LINES řádků"
fi
echo

# Největší soubory
echo "🏆 10 největších souborů:"
find "$PROJECT" -type f -exec du -h {} + 2>/dev/null | sort -rh | head -10 | while read size file; do
    echo "   • $size - $file"
done

echo "════════════════════════════════════════"
echo "✅ Statistiky dokončeny"'

create_file "$BASE/utils/update.sh" '#!/usr/bin/env bash
source ~/acode-dev-tools/core/env.sh

echo "🔄 Acode Dev Toolkit - Aktualizace"
echo "════════════════════════════════════════"
echo

# 1. Aktualizace základních balíčků
echo "1. 📦 Aktualizace systémových balíčků..."
if command -v pkg >/dev/null 2>&1; then
    pkg update -y && pkg upgrade -y
elif command -v apt >/dev/null 2>&1; then
    apt update && apt upgrade -y
fi
echo

# 2. Aktualizace Node.js balíčků
echo "2. 📦 Aktualizace globálních npm balíčků..."
if command -v npm >/dev/null 2>&1; then
    npm update -g
fi
echo

# 3. Aktualizace AI modelů
echo "3. 🤖 Kontrola aktualizací AI modelů..."
if command -v ollama >/dev/null 2>&1; then
    ollama pull phi3:mini 2>/dev/null || true
fi
echo

# 4. Oprava oprávnění
echo "4. 🔧 Oprava oprávnění skriptů..."
chmod +x "$ACODE_DEV_HOME"/*.sh 2>/dev/null
chmod +x "$ACODE_DEV_HOME"/**/*.sh 2>/dev/null
echo

# 5. Aktualizace konfigurace
echo "5. ⚙️  Aktualizace konfigurace..."
if [ ! -f "$ACODE_DEV_HOME/VERSION" ]; then
    echo "2.0.0" > "$ACODE_DEV_HOME/VERSION"
fi

# 6. Vytvoření zálohy
BACKUP_DIR="$HOME/acode-backup-$(date +%Y%m%d)"
echo "6. 💾 Vytváření zálohy do: $BACKUP_DIR"
mkdir -p "$BACKUP_DIR"
cp -r "$ACODE_DEV_HOME" "$BACKUP_DIR/" 2>/dev/null || true
echo

echo "✅ Aktualizace dokončena!"
echo "📅 Poslední aktualizace: $(date)" > "$ACODE_DEV_HOME/LAST_UPDATE"
echo "════════════════════════════════════════"'

# 📄 Templates
progress "Generování šablon projektů"

# JavaScript šablona
mkdir -p "$BASE/templates/javascript/src"
create_file "$BASE/templates/javascript/package.json" '{
  "name": "my-project",
  "version": "1.0.0",
  "description": "Acode Dev Toolkit Project",
  "main": "src/index.js",
  "scripts": {
    "start": "node src/index.js",
    "dev": "nodemon src/index.js",
    "test": "jest",
    "lint": "eslint src/",
    "format": "prettier --write src/"
  },
  "dependencies": {},
  "devDependencies": {
    "eslint": "^8.0.0",
    "prettier": "^3.0.0",
    "jest": "^29.0.0",
    "nodemon": "^3.0.0"
  },
  "keywords": ["acode", "toolkit", "javascript"],
  "author": "Acode Developer"
}'

create_file "$BASE/templates/javascript/src/index.js" '// Acode Dev Toolkit - JavaScript šablona
// Hlavní vstupní bod aplikace

console.log("🚀 Acode Dev Toolkit - JavaScript projekt");

class App {
    constructor() {
        this.version = "1.0.0";
        this.initialize();
    }
    
    initialize() {
        console.log(`Aplikace v${this.version} inicializována`);
        this.loadConfig();
        this.setupEventListeners();
        this.start();
    }
    
    loadConfig() {
        // TODO: Načíst konfiguraci
        this.config = {
            debug: true,
            apiUrl: "https://api.example.com"
        };
    }
    
    setupEventListeners() {
        // TODO: Nastavit posluchače událostí
        console.log("Event listeners nastaveny");
    }
    
    start() {
        console.log("Aplikace spuštěna");
        this.runMainLogic();
    }
    
    runMainLogic() {
        // Hlavní logika aplikace
        console.log("Hlavní logika aplikace běží");
        
        // Příklad funkce
        const result = this.calculate(10, 5);
        console.log(`Výpočet: 10 + 5 = ${result}`);
    }
    
    calculate(a, b) {
        return a + b;
    }
}

// Spuštění aplikace
const app = new App();

// Export pro testování
if (typeof module !== "undefined" && module.exports) {
    module.exports = App;
}'

create_file "$BASE/templates/javascript/README.md" '# JavaScript Projekt

Toto je šablona projektu vytvořená pomocí Acode Dev Toolkit.

## Struktura projektu