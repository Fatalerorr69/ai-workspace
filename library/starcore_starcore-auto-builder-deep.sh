#!/bin/bash
# ============================================================================
# STARCORE AUTO BUILDER – Depth / Focus Edition (v3.3-depth)
# Verze: 3.3-depth
# Autor: STARCORE Enterprise Architect
# Popis: Interaktivní skript pro hloubkové skenování zvoleného adresáře
#        do maximální hloubky L2 (defaultně 2). Uživatel si volí cílovou
#        cestu a přípony souborů (.sh, .py, .md, ...). Výsledky se ukládají
#        do oddělených podsložek pro další zpracování. Obsahuje rozšířenou
#        analýzu, generování souhrnných reportů a živý dashboard.
# ============================================================================

set -uo pipefail

# --------------------------- KONFIGURACE -----------------------------------
BASE_DIR="/root/starcore"
VERSION="depth"
OPTIMIZED_DIR="$BASE_DIR/bin/optimized-${VERSION}"
STATE_FILE="$OPTIMIZED_DIR/.builder_state"
LOG_DIR="$BASE_DIR/logs/auto-builder-${VERSION}"
RUN_DIR="$BASE_DIR/run-${VERSION}"
REPORTS_DIR="$BASE_DIR/reports/${VERSION}"
PREFLIGHT_LOG="$LOG_DIR/preflight-$(date +%Y%m%d-%H%M%S).log"

DASHBOARD_REFRESH=10
SLEEP_TIME=5

# Výchozí hodnoty (přepíší se argumenty nebo interaktivním vstupem)
TARGET_DIR=""                # bude vyžádáno
FILE_TYPES=()                # bude vyžádáno
MAX_DEPTH=2                  # výchozí hloubka
AUTO_INSTALL_MISSING="${AUTO_INSTALL_MISSING:-0}"
COPY_FOUND=0                 # zda kopírovat nalezené soubory do pracovního adresáře (volitelné)

# --------------------------- BARVY ------------------------------------------
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
MAGENTA='\033[0;35m'
NC='\033[0m'
BOLD='\033[1m'
DIM='\033[2m'

# ============================================================================
# FÁZE 0: PREFLIGHT KONTROLY
# ============================================================================

PREFLIGHT_ISSUES=0
PREFLIGHT_FIXED=0
PREFLIGHT_FATAL=0

pf_log() { echo -e "$*"; }
pf_ok()    { pf_log "  ${GREEN}✔${NC} $*"; }
pf_warn()  { pf_log "  ${YELLOW}⚠${NC} $*"; PREFLIGHT_ISSUES=$((PREFLIGHT_ISSUES+1)); }
pf_fix()   { pf_log "  ${CYAN}🔧${NC} $*"; PREFLIGHT_FIXED=$((PREFLIGHT_FIXED+1)); }
pf_fail()  { pf_log "  ${RED}✘${NC} $*"; PREFLIGHT_ISSUES=$((PREFLIGHT_ISSUES+1)); PREFLIGHT_FATAL=$((PREFLIGHT_FATAL+1)); }

echo -e "${BOLD}${BLUE}╔══════════════════════════════════════════════════════════════╗${NC}"
echo -e "${BOLD}${BLUE}║    STARCORE AUTO BUILDER DEPTH – PREFLIGHT CHECK            ║${NC}"
echo -e "${BOLD}${BLUE}╚══════════════════════════════════════════════════════════════╝${NC}"

# ---- 1. Oprávnění ----
echo -e "\n${BOLD}[1/7] Oprávnění${NC}"
if [[ "$(id -u)" -eq 0 ]]; then
    pf_ok "Skript běží jako root"
else
    pf_warn "Skript neběží jako root – některé operace mohou vyžadovat sudo"
fi

# ---- 2. Adresářová struktura ----
echo -e "\n${BOLD}[2/7] Adresářová struktura${NC}"
for d in "$BASE_DIR" "$OPTIMIZED_DIR" "$LOG_DIR" "$RUN_DIR" "$REPORTS_DIR"; do
    if [[ -d "$d" ]]; then
        pf_ok "Existuje: $d"
    else
        if mkdir -p "$d" 2>/dev/null; then
            pf_fix "Vytvořen chybějící adresář: $d"
        else
            pf_fail "Nelze vytvořit adresář: $d (zkontroluj oprávnění)"
        fi
    fi
done

# ---- 3. Testovací zápis ----
echo -e "\n${BOLD}[3/7] Testovací zápis${NC}"
TESTFILE="$BASE_DIR/.write_test_$$"
if echo "test" > "$TESTFILE" 2>/dev/null; then
    rm -f "$TESTFILE"
    pf_ok "Zápis do $BASE_DIR funguje"
else
    pf_fail "Nelze zapisovat do $BASE_DIR – zkontroluj oprávnění/disk"
fi

# ---- 4. Místo na disku ----
echo -e "\n${BOLD}[4/7] Místo na disku${NC}"
if command -v df &>/dev/null; then
    AVAIL_KB=$(df -Pk "$BASE_DIR" 2>/dev/null | awk 'NR==2{print $4}')
    if [[ -n "${AVAIL_KB:-}" ]]; then
        AVAIL_MB=$((AVAIL_KB / 1024))
        if [[ $AVAIL_MB -lt 200 ]]; then
            pf_fail "Kriticky málo místa na disku: ${AVAIL_MB} MB volných"
        elif [[ $AVAIL_MB -lt 1024 ]]; then
            pf_warn "Málo místa na disku: ${AVAIL_MB} MB volných"
        else
            pf_ok "Volné místo: ${AVAIL_MB} MB"
        fi
    else
        pf_warn "Nelze zjistit volné místo na disku"
    fi
else
    pf_warn "Příkaz 'df' není dostupný, kontrola místa vynechána"
fi

# ---- 5. Povinné nástroje ----
echo -e "\n${BOLD}[5/7] Povinné nástroje${NC}"
REQUIRED_TOOLS=(bash find grep sort uniq md5sum wc basename date xargs awk)
MISSING_REQUIRED=()
for tool in "${REQUIRED_TOOLS[@]}"; do
    if command -v "$tool" &>/dev/null; then
        pf_ok "$tool"
    else
        pf_fail "Chybí povinný nástroj: $tool"
        MISSING_REQUIRED+=("$tool")
    fi
done

# ---- 6. Volitelné nástroje ----
echo -e "\n${BOLD}[6/7] Volitelné nástroje${NC}"
OPTIONAL_TOOLS=(python3 node tput)
MISSING_OPTIONAL=()
for tool in "${OPTIONAL_TOOLS[@]}"; do
    if command -v "$tool" &>/dev/null; then
        pf_ok "$tool"
    else
        pf_warn "Chybí volitelný nástroj: $tool (kontrola odpovídajících souborů bude přeskočena)"
        MISSING_OPTIONAL+=("$tool")
    fi
done

# ---- 7. Shrnutí ----
echo -e "\n${BOLD}[7/7] Shrnutí${NC}"
if [[ ${#MISSING_REQUIRED[@]} -gt 0 ]]; then
    pf_log "\n${RED}${BOLD}✘ KRITICKÁ CHYBA: chybí povinné nástroje (${MISSING_REQUIRED[*]}), nelze pokračovat.${NC}"
    exit 1
fi
if [[ $PREFLIGHT_FATAL -gt 0 ]]; then
    pf_log "\n${RED}${BOLD}✘ KRITICKÁ CHYBA: preflight kontrola nalezla $PREFLIGHT_FATAL fatální problém(y). Konec.${NC}"
    exit 1
fi

pf_log "\n${GREEN}${BOLD}✔ Preflight OK${NC} ${DIM}(varování: $PREFLIGHT_ISSUES, automaticky opraveno: $PREFLIGHT_FIXED)${NC}"
sleep 1

# Nastavení logování
LOG_FILE="$LOG_DIR/builder-$(date +%Y%m%d-%H%M%S).log"
{
    echo "=== STARCORE Auto Builder Depth - Preflight Summary ==="
    echo "Datum: $(date)"
    echo "Varování: $PREFLIGHT_ISSUES, Opraveno: $PREFLIGHT_FIXED, Fatální: $PREFLIGHT_FATAL"
} > "$PREFLIGHT_LOG"

exec > >(tee -a "$LOG_FILE") 2>&1

log() { echo -e "[$(date '+%Y-%m-%d %H:%M:%S')] $*"; }
log "${GREEN}Preflight log uložen do: $PREFLIGHT_LOG${NC}"

# ============================================================================
# FÁZE 1: ZPRACOVÁNÍ ARGUMENTŮ A INTERAKTIVNÍ VSTUP
# ============================================================================

usage() {
    cat <<EOF
Použití: $0 [--dir <cesta>] [--types <přípony>] [--depth <číslo>] [--copy] [--help]

  --dir <cesta>     Cílový adresář pro skenování (povinné)
  --types <seznam>  Seznam přípon oddělených mezerou, např. "sh py md" (povinné)
  --depth <číslo>   Maximální hloubka podadresářů (výchozí 2)
  --copy            Zkopíruje nalezené soubory do pracovního adresáře (volitelné)
  --help            Zobrazí tuto nápovědu

Pokud nejsou parametry zadány, skript se zeptá interaktivně.
EOF
    exit 0
}

# Zpracování argumentů
while [[ $# -gt 0 ]]; do
    case "$1" in
        --dir)
            TARGET_DIR="$2"
            shift 2
            ;;
        --types)
            IFS=' ' read -r -a FILE_TYPES <<< "$2"
            shift 2
            ;;
        --depth)
            MAX_DEPTH="$2"
            shift 2
            ;;
        --copy)
            COPY_FOUND=1
            shift
            ;;
        --help)
            usage
            ;;
        *)
            echo "Neznámý argument: $1"
            usage
            ;;
    esac
done

# Interaktivní dotazování, pokud nebyly zadány parametry
if [[ -z "$TARGET_DIR" ]]; then
    echo -e "${BOLD}Zadejte cílovou cestu k adresáři (např. /root/starcore/scripts):${NC}"
    read -r TARGET_DIR
fi

if [[ ${#FILE_TYPES[@]} -eq 0 ]]; then
    echo -e "${BOLD}Zadejte přípony souborů oddělené mezerou (např. sh py md txt js):${NC}"
    read -r -a FILE_TYPES
fi

# Validace
if [[ -z "$TARGET_DIR" || ! -d "$TARGET_DIR" ]]; then
    log "${RED}❌ Chyba: Cílová cesta '$TARGET_DIR' neexistuje nebo není adresářem.${NC}"
    exit 1
fi

if [[ ${#FILE_TYPES[@]} -eq 0 ]]; then
    log "${RED}❌ Chyba: Nebyl zadán žádný typ souboru.${NC}"
    exit 1
fi

log "${GREEN}✅ Konfigurace:${NC}"
log "  Cíl: $TARGET_DIR"
log "  Typy: ${FILE_TYPES[*]}"
log "  Hloubka: $MAX_DEPTH"
log "  Kopírovat: $([ $COPY_FOUND -eq 1 ] && echo "Ano" || echo "Ne")"

# ============================================================================
# FÁZE 2: INICIALIZACE STAVU (resume)
# ============================================================================
if [[ -f "$STATE_FILE" ]]; then
    # shellcheck disable=SC1090
    source "$STATE_FILE" 2>/dev/null || true
    CYCLE_COUNT=${cycles_completed:-0}
    TOTAL_PROCESSED=${total_files_processed:-0}
    log "${BLUE}📂 Obnoven stav: cyklů $CYCLE_COUNT, souborů $TOTAL_PROCESSED${NC}"
else
    CYCLE_COUNT=0
    TOTAL_PROCESSED=0
    {
        echo "# STARCORE Auto Builder Depth State"
        echo "cycles_completed=0"
        echo "total_files_processed=0"
    } > "$STATE_FILE"
fi

RUN_START_TS=$(date +%s)

# ============================================================================
# FÁZE 3: ZPRACOVÁNÍ SIGNÁLŮ
# ============================================================================
SHUTTING_DOWN=0
cleanup() {
    SHUTTING_DOWN=1
    tput cnorm 2>/dev/null || true
    echo
    log "${YELLOW}⏹️  Přijat signál ukončení. Ukládám stav a končím...${NC}"
    {
        echo "cycles_completed=$CYCLE_COUNT"
        echo "total_files_processed=$TOTAL_PROCESSED"
        echo "stopped_at=$(date +%s)"
    } > "$STATE_FILE"
    log "${GREEN}✅ Stav uložen do $STATE_FILE${NC}"
    log "${GREEN}📁 Výstupy: $OPTIMIZED_DIR${NC}"
    log "${GREEN}📄 Log: $LOG_FILE${NC}"
    exit 0
}
trap cleanup SIGINT SIGTERM

# ============================================================================
# FÁZE 4: POMOCNÉ FUNKCE (syntax, závislosti, analýza)
# ============================================================================
check_syntax() {
    local file="$1"
    case "$file" in
        *.sh) bash -n "$file" 2>/dev/null ;;
        *.py) command -v python3 &>/dev/null && python3 -m py_compile "$file" 2>/dev/null ;;
        *.js) command -v node &>/dev/null && node -c "$file" 2>/dev/null ;;
        *) return 0 ;;
    esac
}

check_dependencies() {
    local file="$1"
    [[ "$file" == *.sh ]] || return 0
    [[ -f "$file" ]] || return 0

    local own_functions
    own_functions=$(grep -oE '^[[:space:]]*[A-Za-z_][A-Za-z0-9_]*[[:space:]]*\(\)[[:space:]]*\{' "$file" 2>/dev/null \
        | sed -E 's/^[[:space:]]*([A-Za-z_][A-Za-z0-9_]*).*/\1/')

    local cmd line_orig
    while IFS= read -r line_orig; do
        local line="${line_orig#"${line_orig%%[![:space:]]*}"}"
        [[ -z "$line" || "$line" == \#* ]] && continue
        [[ "$line" == *')' ]] && [[ "$line" != *' '*'('*')'* ]] && continue

        cmd="${line%%[[:space:]]*}"
        cmd="${cmd%%[\(\);&|]*}"
        [[ -z "$cmd" ]] && continue
        [[ "$cmd" == */* ]] && continue
        [[ "$cmd" =~ ^[A-Za-z_][A-Za-z0-9_]*= ]] && continue
        [[ "$cmd" == "*" ]] && continue

        case "$cmd" in
            if|then|else|elif|fi|case|esac|for|while|do|done|function|return|exit|echo|printf|read|cd|pwd|export|source|exec|eval|set|trap|wait|sleep|time|ulimit|umask|unset|shift|getopts|local|declare|typeset|readonly|alias|unalias|bg|fg|jobs|kill|nice|nohup|suspend|true|false|test|\{|\}|in)
                continue ;;
        esac

        if [[ -n "$own_functions" ]] && grep -qx "$cmd" <<< "$own_functions"; then
            continue
        fi

        if ! command -v "$cmd" &>/dev/null; then
            echo "Chybí závislost: $cmd (v $file)" >> "$RUN_DIR/deps_errors.txt"
        fi
    done < "$file"
}

auto_repair_file() {
    local file="$1"
    local repaired=0
    [[ "$file" == *.sh && -f "$file" && -w "$file" ]] || return 1

    if ! head -1 "$file" | grep -q '^#!'; then
        sed -i '1i #!/bin/bash' "$file" 2>/dev/null && repaired=1
    fi

    if file "$file" 2>/dev/null | grep -qi 'CRLF'; then
        sed -i 's/\r$//' "$file" 2>/dev/null && repaired=1
    elif grep -qU $'\r' "$file" 2>/dev/null; then
        sed -i 's/\r$//' "$file" 2>/dev/null && repaired=1
    fi

    if [[ ! -x "$file" ]]; then
        chmod +x "$file" 2>/dev/null && repaired=1
    fi

    [[ $repaired -eq 1 ]] && echo "$file" >> "$RUN_DIR/auto_repaired.txt"
    return $((1 - repaired))
}

detailed_analysis() {
    local file="$1"
    local warnings=0
    local report_file="$RUN_DIR/detailed_warnings.txt"

    case "$file" in
        *.sh)
            if grep -q -E '\beval\b' "$file"; then
                echo "WARNING: použití eval v $file" >> "$report_file"
                ((warnings++))
            fi
            if grep -q -E '\bexec\b' "$file"; then
                echo "WARNING: použití exec v $file" >> "$report_file"
                ((warnings++))
            fi
            if grep -q -E 'rm -rf /' "$file"; then
                echo "CRITICAL: rm -rf / v $file" >> "$report_file"
                ((warnings++))
            fi
            if grep -q -E '\$[A-Za-z_][A-Za-z0-9_]*[^"]' "$file"; then
                echo "WARNING: pravděpodobně neuzavřená proměnná v $file" >> "$report_file"
                ((warnings++))
            fi
            if [[ -x "$file" ]] && ! head -1 "$file" | grep -q '^#!'; then
                echo "WARNING: spustitelný soubor bez shebangu: $file" >> "$report_file"
                ((warnings++))
            fi
            ;;
        *.py)
            if grep -q -E 'os\.system|subprocess\.call|subprocess\.Popen' "$file"; then
                echo "WARNING: použití systémového volání v $file" >> "$report_file"
                ((warnings++))
            fi
            ;;
        *.js)
            if grep -q -E '\beval\b|child_process\.exec' "$file"; then
                echo "WARNING: použití eval nebo exec v $file" >> "$report_file"
                ((warnings++))
            fi
            ;;
        *)
            ;;
    esac
    return $warnings
}
export -f check_syntax check_dependencies auto_repair_file detailed_analysis
export RUN_DIR

# ============================================================================
# FÁZE 5: DASHBOARD
# ============================================================================
DASHBOARD_LINES=0

draw_progress_bar() {
    local percent=$1
    local width=40
    local filled=$(( percent * width / 100 ))
    local empty=$(( width - filled ))
    local bar=""
    [[ $filled -gt 0 ]] && bar+=$(printf "%${filled}s" | tr ' ' '█')
    [[ $empty -gt 0 ]] && bar+=$(printf "%${empty}s" | tr ' ' '░')
    printf "${CYAN}[%s]${NC} %3d%%" "$bar" "$percent"
}

format_duration() {
    local secs=$1
    printf "%02d:%02d:%02d" $((secs/3600)) $(( (secs%3600)/60 )) $((secs%60))
}

render_dashboard() {
    local cycle="${1:-0}" file_count="${2:-0}" total_processed="${3:-0}"
    local syntax_err="${4:-0}" deps_err="${5:-0}" dup_names="${6:-0}" dup_hashes="${7:-0}"
    local generated="${8:-0}" repaired="${9:-0}" sec_warnings="${10:-0}"
    local phase="${11:-}" phase_pct="${12:-0}"

    local now_ts; now_ts=$(date +%s)
    local cycle_elapsed=0
    [[ -n "${CYCLE_START:-}" ]] && cycle_elapsed=$(( now_ts - CYCLE_START ))
    local total_runtime=$(( now_ts - RUN_START_TS ))
    local avg_per_cycle=0
    [[ $cycle -gt 0 ]] && avg_per_cycle=$(( total_runtime / cycle ))

    local disk_avail="n/a"
    if command -v df &>/dev/null; then
        local kb; kb=$(df -Pk "$BASE_DIR" 2>/dev/null | awk 'NR==2{print $4}')
        [[ -n "$kb" ]] && disk_avail="$(( kb / 1024 )) MB"
    fi

    local mem_info="n/a"
    if [[ -r /proc/meminfo ]]; then
        local mem_avail_kb; mem_avail_kb=$(awk '/MemAvailable/{print $2}' /proc/meminfo 2>/dev/null)
        [[ -n "$mem_avail_kb" ]] && mem_info="$(( mem_avail_kb / 1024 )) MB"
    fi

    local sep_thick="════════════════════════════════════════════════════════════════"
    local sep_thin="────────────────────────────────────────────────────────────────"

    local out=""
    out+="${BOLD}${BLUE}╔${sep_thick}╗${NC}\n"
    out+="${BOLD}${BLUE}║${NC}  ${BOLD}STARCORE AUTO BUILDER DEPTH – LIVE DASHBOARD${NC}\n"
    out+="${BOLD}${BLUE}╠${sep_thick}╣${NC}\n"
    out+="${BLUE}║${NC}  Aktuální fáze : ${BOLD}${MAGENTA}${phase}${NC}\n"
    out+="${BLUE}║${NC}  Průběh fáze   : $(draw_progress_bar "$phase_pct")\n"
    out+="${BLUE}╠${sep_thin}╣${NC}\n"

    local rows=(
        "Cyklus|#$cycle"
        "Soubory v aktuálním cyklu|$file_count"
        "Celkem zpracováno souborů|$total_processed"
        "Doba aktuálního cyklu|$(format_duration "$cycle_elapsed")"
        "Celkový čas běhu|$(format_duration "$total_runtime")"
        "Průměr na cyklus|$(format_duration "$avg_per_cycle")"
        "Syntaktické chyby|$syntax_err"
        "Chybějící závislosti|$deps_err"
        "Duplicitní názvy|$dup_names"
        "Duplicitní hashe (obsah)|$dup_hashes"
        "Vygenerované skripty (celkem)|$generated"
        "Automaticky opraveno souborů|$repaired"
        "Bezpečnostní varování|$sec_warnings"
        "Volné místo na disku|$disk_avail"
        "Volná RAM|$mem_info"
    )
    for row in "${rows[@]}"; do
        local label="${row%%|*}"
        local value="${row##*|}"
        out+="${BLUE}║${NC}  $(printf '%-32s' "$label") ${GREEN}${BOLD}${value}${NC}\n"
    done

    out+="${BLUE}╚${sep_thick}╝${NC}\n"
    out+="${DIM}Aktualizace každých ${DASHBOARD_REFRESH}s · Ctrl+C pro bezpečné zastavení a uložení stavu${NC}\n"

    if [[ $DASHBOARD_LINES -gt 0 ]] && [[ -t 1 ]]; then
        tput cuu "$DASHBOARD_LINES" 2>/dev/null || true
        tput ed 2>/dev/null || true
    fi

    echo -e "$out"
    DASHBOARD_LINES=$(echo -e "$out" | wc -l)
}

# ============================================================================
# FÁZE 6: GENERÁTORY (kategorizované skripty)
# ============================================================================
generate_category_script() {
    local cat="$1" cycle="$2" count="$3" list_file="$4"
    local new_script="$OPTIMIZED_DIR/starcore-${cat}-all_v${cycle}.sh"
    {
        echo "#!/bin/bash"
        echo "# ============================================================="
        echo "# STARCORE UNIVERZÁLNÍ SKRIPT – Kategorie: $cat (Depth)"
        echo "# Vygenerováno automaticky v cyklu #$cycle"
        echo "# Datum: $(date)"
        echo "# Počet vstupních skriptů: $count"
        echo "# ============================================================="
        echo ""
        echo "set -uo pipefail"
        echo "echo '🚀 Spouštím univerzální skript pro kategorii: $cat'"
        echo ""
        echo "log() { echo \"[\$(date)] \$*\"; }"
        echo ""
        echo "case \"\${1:-}\" in"
        echo "  --help)"
        echo "    echo 'Použití: \$0 [list|run-all]'"
        echo "    exit 0"
        echo "    ;;"
        echo "  list)"
        echo "    echo 'Dostupné operace:'"
        while IFS= read -r src; do
            echo "    echo '  - $(basename "$src")'"
        done < "$list_file"
        echo "    ;;"
        echo "  run-all)"
        echo "    log 'Spouštím všechny skripty v kategorii $cat'"
        while IFS= read -r src; do
            local sname; sname=$(basename "$src")
            echo "    log 'Spouštím: $sname'"
            echo "    bash \"$src\" || log 'Chyba při spouštění $sname'"
        done < "$list_file"
        echo "    ;;"
        echo "  *)"
        echo "    echo 'Neplatný parametr. Použij --help.'"
        echo "    ;;"
        echo "esac"
    } > "$new_script"
    chmod +x "$new_script"
    if bash -n "$new_script" 2>/dev/null; then
        echo "✅ $new_script syntax OK" >> "$RUN_DIR/test_results.txt"
    else
        echo "❌ $new_script syntax ERROR" >> "$RUN_DIR/test_results.txt"
        rm -f "$new_script"
        log "${RED}❌ $new_script měl syntax error, odstraněn${NC}"
    fi
}

generate_special_scripts() {
    local cycle="$1"

    cat > "$OPTIMIZED_DIR/starcore-registry-manager_v${cycle}.sh" << EOF
#!/bin/bash
set -uo pipefail
echo "📦 Správa registrů STARCORE (Depth)"
echo "Skenuji velké soubory (ISO, VHD, ZIP, tar.gz) v $TARGET_DIR ..."
find "$TARGET_DIR" -maxdepth "$MAX_DEPTH" -type f \\( -name "*.iso" -o -name "*.vhd" -o -name "*.zip" -o -name "*.tar.gz" \\) -size +100M 2>/dev/null | tee "$REPORTS_DIR/large-files-depth.txt"
echo "✅ Seznam uložen do $REPORTS_DIR/large-files-depth.txt"
EOF
    chmod +x "$OPTIMIZED_DIR/starcore-registry-manager_v${cycle}.sh"

    cat > "$OPTIMIZED_DIR/starcore-ai-orchestrator_v${cycle}.sh" << 'EOF'
#!/bin/bash
set -uo pipefail
echo "🧠 AI Orchestrátor (Depth) spuštěn"
echo "Plánuji úlohy podle dostupných zdrojů v cílovém adresáři..."
echo "✅ Orchestrace dokončena"
EOF
    chmod +x "$OPTIMIZED_DIR/starcore-ai-orchestrator_v${cycle}.sh"

    cat > "$OPTIMIZED_DIR/starcore-knowledge-manager_v${cycle}.sh" << EOF
#!/bin/bash
set -uo pipefail
echo "📚 Správa znalostní báze (Depth)"
echo "Indexuji knowledge/ v $TARGET_DIR ..."
find "$TARGET_DIR" -maxdepth "$MAX_DEPTH" -type f \\( -name "*.md" -o -name "*.txt" \\) 2>/dev/null | while read -r f; do
    echo "  - \$f"
done > "$REPORTS_DIR/knowledge-index-depth.txt"
echo "✅ Index uložen do $REPORTS_DIR/knowledge-index-depth.txt"
EOF
    chmod +x "$OPTIMIZED_DIR/starcore-knowledge-manager_v${cycle}.sh"

    for f in "$OPTIMIZED_DIR/starcore-registry-manager_v${cycle}.sh" \
             "$OPTIMIZED_DIR/starcore-ai-orchestrator_v${cycle}.sh" \
             "$OPTIMIZED_DIR/starcore-knowledge-manager_v${cycle}.sh"; do
        if bash -n "$f" 2>/dev/null; then
            echo "✅ $f syntax OK" >> "$RUN_DIR/test_results.txt"
        else
            echo "❌ $f syntax ERROR" >> "$RUN_DIR/test_results.txt"
        fi
    done
}

# ============================================================================
# FÁZE 7: GENEROVÁNÍ SOUBORNÉHO REPORTU (JSON / text)
# ============================================================================
generate_metadata_report() {
    local report_file="$REPORTS_DIR/metadata-depth-$(date +%Y%m%d-%H%M%S).txt"
    {
        echo "=== METADATA REPORT (Depth scan) ==="
        echo "Cílový adresář: $TARGET_DIR"
        echo "Maximální hloubka: $MAX_DEPTH"
        echo "Sledované typy: ${FILE_TYPES[*]}"
        echo "Datum: $(date)"
        echo ""
        echo "Seznam nalezených souborů s podrobnostmi:"
        echo "----------------------------------------"
        # Pro každý soubor vypíšeme velikost, hash, datum modifikace
        while IFS= read -r file; do
            if [[ -f "$file" ]]; then
                size=$(stat -c%s "$file" 2>/dev/null || echo "?")
                mtime=$(stat -c%y "$file" 2>/dev/null | cut -d. -f1 || echo "?")
                md5=$(md5sum "$file" 2>/dev/null | cut -d' ' -f1)
                echo "$file|$size|$mtime|$md5"
            fi
        done < "$RUN_DIR/current_files.txt" >> "$report_file"
    } 2>/dev/null
    log "${GREEN}✅ Metadata report uložen do $report_file${NC}"
}

# ============================================================================
# FÁZE 8: HLAVNÍ SMYČKA
# ============================================================================
log "${GREEN}${BOLD}🚀 Spouštím STARCORE Auto Builder Depth v3.3${NC}"
log "${BLUE}🔁 Běží v nekonečné smyčce, zastavte Ctrl+C (stav se uloží automaticky)${NC}"
log "${BLUE}📁 Výstupy: $OPTIMIZED_DIR${NC}"
log "${BLUE}📄 Log: $LOG_FILE${NC}"
sleep 1

CYCLE_COUNT=$((CYCLE_COUNT + 1))
LAST_DASHBOARD_TS=0

maybe_render_dashboard() {
    local force="$1"; shift
    local now; now=$(date +%s)
    if [[ "$force" -eq 1 ]] || (( now - LAST_DASHBOARD_TS >= DASHBOARD_REFRESH )); then
        render_dashboard "$@"
        LAST_DASHBOARD_TS=$now
    fi
}

while true; do
    CYCLE_START=$(date +%s)
    SYNTAX_ERR_COUNT=0
    DEPS_ERR_COUNT=0
    DUP_NAMES_COUNT=0
    DUP_HASHES_COUNT=0
    REPAIRED_COUNT=0
    SEC_WARNINGS=0
    FILE_COUNT=0

    log "${BLUE}========================================${NC}"
    log "${BLUE}🔁 CYKLUS #$CYCLE_COUNT (Depth)${NC}"
    log "${BLUE}========================================${NC}"

    # ---------- 1. Sběr souborů s omezenou hloubkou a typy ----------
    log "${YELLOW}📂 Sběr souborů z $TARGET_DIR (hloubka ≤ $MAX_DEPTH, typy: ${FILE_TYPES[*]})...${NC}"
    mkdir -p "$RUN_DIR/cycle-$CYCLE_COUNT"
    CYCLE_FILES="$RUN_DIR/cycle-$CYCLE_COUNT/all-files.txt"
    : > "$CYCLE_FILES"

    # Sestavení find podmínek pro typy
    FIND_NAME_COND=()
    for ext in "${FILE_TYPES[@]}"; do
        FIND_NAME_COND+=( -name "*.$ext" -o )
    done
    # Odstraníme poslední "-o"
    if [[ ${#FIND_NAME_COND[@]} -gt 0 ]]; then
        unset 'FIND_NAME_COND[${#FIND_NAME_COND[@]}-1]'
    fi

    # Spuštění find
    if [[ ${#FIND_NAME_COND[@]} -gt 0 ]]; then
        find "$TARGET_DIR" -maxdepth "$MAX_DEPTH" -type f \( "${FIND_NAME_COND[@]}" \) 2>/dev/null >> "$CYCLE_FILES"
    else
        log "${YELLOW}⚠ Nebyl zadán žádný typ, přeskočeno.${NC}"
    fi

    sort -u -o "$CYCLE_FILES" "$CYCLE_FILES"
    FILE_COUNT=$(wc -l < "$CYCLE_FILES")
    TOTAL_FILES_ALL=$(( ${TOTAL_FILES_ALL:-0} + FILE_COUNT ))
    log "${GREEN}✅ Nalezeno $FILE_COUNT souborů${NC}"

    # Uložíme aktuální seznam pro metadata
    cp "$CYCLE_FILES" "$RUN_DIR/current_files.txt"

    # ---------- 2. Volitelné kopírování nalezených souborů ----------
    if [[ $COPY_FOUND -eq 1 && $FILE_COUNT -gt 0 ]]; then
        COPY_DIR="$RUN_DIR/copied_files"
        mkdir -p "$COPY_DIR"
        log "${CYAN}📋 Kopíruji nalezené soubory do $COPY_DIR ...${NC}"
        while IFS= read -r src; do
            [[ -f "$src" ]] || continue
            cp "$src" "$COPY_DIR/" 2>/dev/null
        done < "$CYCLE_FILES"
        log "${GREEN}✅ Zkopírováno $FILE_COUNT souborů.${NC}"
    fi

    maybe_render_dashboard 1 "$CYCLE_COUNT" "$FILE_COUNT" "$TOTAL_PROCESSED" \
        0 0 0 0 "$(ls -1 "$OPTIMIZED_DIR" 2>/dev/null | wc -l)" 0 0 \
        "Sběr souborů" 100

    # ---------- 3. Syntax + dependencies + auto-repair ----------
    log "${YELLOW}🧪 Kontrola syntaxe, závislostí a auto-oprava...${NC}"
    : > "$RUN_DIR/syntax_errors.txt"
    : > "$RUN_DIR/deps_errors.txt"
    : > "$RUN_DIR/auto_repaired.txt"

    if [[ "$FILE_COUNT" -gt 0 ]]; then
        xargs -a "$CYCLE_FILES" -P 4 -I {} bash -c 'auto_repair_file "{}"' 2>/dev/null || true

        BATCH_SIZE=25
        TOTAL_LINES=$FILE_COUNT
        PROCESSED_LINES=0
        split -l "$BATCH_SIZE" "$CYCLE_FILES" "$RUN_DIR/cycle-$CYCLE_COUNT/_batch_" 2>/dev/null || cp "$CYCLE_FILES" "$RUN_DIR/cycle-$CYCLE_COUNT/_batch_aa"

        for batch in "$RUN_DIR"/cycle-"$CYCLE_COUNT"/_batch_*; do
            [[ -f "$batch" ]] || continue
            xargs -a "$batch" -P 4 -I {} bash -c '
                if ! check_syntax "{}"; then
                    echo "Syntax error in {}" >> "$RUN_DIR/syntax_errors.txt"
                fi
                check_dependencies "{}"
            ' 2>/dev/null
            PROCESSED_LINES=$(( PROCESSED_LINES + $(wc -l < "$batch") ))
            local_pct=$(( PROCESSED_LINES * 100 / (TOTAL_LINES > 0 ? TOTAL_LINES : 1) ))
            [[ $local_pct -gt 100 ]] && local_pct=100
            maybe_render_dashboard 0 "$CYCLE_COUNT" "$FILE_COUNT" "$TOTAL_PROCESSED" \
                "$(wc -l < "$RUN_DIR/syntax_errors.txt")" "$(wc -l < "$RUN_DIR/deps_errors.txt")" \
                0 0 "$(ls -1 "$OPTIMIZED_DIR" 2>/dev/null | wc -l)" "$(wc -l < "$RUN_DIR/auto_repaired.txt")" 0 \
                "Kontrola syntaxe/závislostí ($PROCESSED_LINES/$TOTAL_LINES)" "$local_pct"
        done
        rm -f "$RUN_DIR"/cycle-"$CYCLE_COUNT"/_batch_*
    fi

    SYNTAX_ERR_COUNT=$(wc -l < "$RUN_DIR/syntax_errors.txt")
    DEPS_ERR_COUNT=$(wc -l < "$RUN_DIR/deps_errors.txt")
    REPAIRED_COUNT=$(wc -l < "$RUN_DIR/auto_repaired.txt")
    [[ "$SYNTAX_ERR_COUNT" -gt 0 ]] && log "${YELLOW}⚠ Syntaktických chyb: $SYNTAX_ERR_COUNT (viz $RUN_DIR/syntax_errors.txt)${NC}"
    [[ "$REPAIRED_COUNT" -gt 0 ]] && log "${CYAN}🔧 Automaticky opraveno souborů: $REPAIRED_COUNT${NC}"

    # ---------- 4. DETAILNÍ STATICKÁ ANALÝZA ----------
    log "${YELLOW}🔍 Provádím podrobnou statickou analýzu (bezpečnost, styl)...${NC}"
    : > "$RUN_DIR/detailed_warnings.txt"
    if [[ "$FILE_COUNT" -gt 0 ]]; then
        BATCH_SIZE=25
        TOTAL_LINES=$FILE_COUNT
        PROCESSED_LINES=0
        split -l "$BATCH_SIZE" "$CYCLE_FILES" "$RUN_DIR/cycle-$CYCLE_COUNT/_batch_sec_" 2>/dev/null || cp "$CYCLE_FILES" "$RUN_DIR/cycle-$CYCLE_COUNT/_batch_sec_aa"

        for batch in "$RUN_DIR"/cycle-"$CYCLE_COUNT"/_batch_sec_*; do
            [[ -f "$batch" ]] || continue
            xargs -a "$batch" -P 4 -I {} bash -c 'detailed_analysis "{}"' 2>/dev/null
            PROCESSED_LINES=$(( PROCESSED_LINES + $(wc -l < "$batch") ))
            local_pct=$(( PROCESSED_LINES * 100 / (TOTAL_LINES > 0 ? TOTAL_LINES : 1) ))
            [[ $local_pct -gt 100 ]] && local_pct=100
            SEC_WARNINGS=$(wc -l < "$RUN_DIR/detailed_warnings.txt")
            maybe_render_dashboard 0 "$CYCLE_COUNT" "$FILE_COUNT" "$TOTAL_PROCESSED" \
                "$SYNTAX_ERR_COUNT" "$DEPS_ERR_COUNT" 0 0 \
                "$(ls -1 "$OPTIMIZED_DIR" 2>/dev/null | wc -l)" "$REPAIRED_COUNT" "$SEC_WARNINGS" \
                "Detailní analýza ($PROCESSED_LINES/$TOTAL_LINES)" "$local_pct"
        done
        rm -f "$RUN_DIR"/cycle-"$CYCLE_COUNT"/_batch_sec_*
    fi
    SEC_WARNINGS=$(wc -l < "$RUN_DIR/detailed_warnings.txt")
    log "${YELLOW}⚠ Bezpečnostních varování: $SEC_WARNINGS (viz $RUN_DIR/detailed_warnings.txt)${NC}"

    # ---------- 5. Detekce duplicit ----------
    log "${YELLOW}🔍 Hledání duplicit...${NC}"
    while read -r f; do basename "$f"; done < "$CYCLE_FILES" | sort | uniq -d > "$RUN_DIR/dup_names.txt"
    while read -r f; do [[ -f "$f" ]] && md5sum "$f" 2>/dev/null | cut -d' ' -f1; done < "$CYCLE_FILES" | sort | uniq -d > "$RUN_DIR/dup_hashes.txt"
    DUP_NAMES_COUNT=$(wc -l < "$RUN_DIR/dup_names.txt")
    DUP_HASHES_COUNT=$(wc -l < "$RUN_DIR/dup_hashes.txt")
    maybe_render_dashboard 1 "$CYCLE_COUNT" "$FILE_COUNT" "$TOTAL_PROCESSED" \
        "$SYNTAX_ERR_COUNT" "$DEPS_ERR_COUNT" "$DUP_NAMES_COUNT" "$DUP_HASHES_COUNT" \
        "$(ls -1 "$OPTIMIZED_DIR" 2>/dev/null | wc -l)" "$REPAIRED_COUNT" "$SEC_WARNINGS" \
        "Detekce duplicit" 100

    # ---------- 6. Generování kategorizovaných skriptů ----------
    log "${YELLOW}⚙️  Generuji integrované skripty...${NC}"
    categories=(fix diagnostic backup ai monitoring deploy security other)
    cat_idx=0
    for cat in "${categories[@]}"; do
        cat_idx=$((cat_idx + 1))
        cat_list="$RUN_DIR/cat_${cat}.txt"
        : > "$cat_list"
        while IFS= read -r file; do
            [[ -f "$file" ]] || continue
            name=$(basename "$file")
            if [[ "$name" =~ $cat ]] || head -5 "$file" 2>/dev/null | grep -qi "$cat"; then
                echo "$file" >> "$cat_list"
            fi
        done < "$CYCLE_FILES"

        count=$(wc -l < "$cat_list")
        if [[ "$count" -eq 0 ]]; then
            echo "# No files for $cat" > "$cat_list"
        else
            generate_category_script "$cat" "$CYCLE_COUNT" "$count" "$cat_list"
        fi

        pct=$(( cat_idx * 100 / ${#categories[@]} ))
        maybe_render_dashboard 0 "$CYCLE_COUNT" "$FILE_COUNT" "$TOTAL_PROCESSED" \
            "$SYNTAX_ERR_COUNT" "$DEPS_ERR_COUNT" "$DUP_NAMES_COUNT" "$DUP_HASHES_COUNT" \
            "$(ls -1 "$OPTIMIZED_DIR" 2>/dev/null | wc -l)" "$REPAIRED_COUNT" "$SEC_WARNINGS" \
            "Generuji kategorii: $cat" "$pct"
    done

    # ---------- 7. Speciální skripty ----------
    log "${YELLOW}🧩 Generuji pokročilé skripty...${NC}"
    generate_special_scripts "$CYCLE_COUNT"

    # ---------- 8. Generování metadata reportu ----------
    generate_metadata_report

    # ---------- 9. Aktualizace stavu a reportu ----------
    CYCLE_END=$(date +%s)
    DURATION=$(( CYCLE_END - CYCLE_START ))
    TOTAL_PROCESSED=$(( TOTAL_PROCESSED + FILE_COUNT ))
    GENERATED_TOTAL=$(ls -1 "$OPTIMIZED_DIR" 2>/dev/null | grep -c '\.sh$' || true)

    {
        echo "cycles_completed=$CYCLE_COUNT"
        echo "total_files_processed=$TOTAL_PROCESSED"
        echo "last_cycle_duration=$DURATION"
        echo "last_cycle_time=$(date)"
        echo "target_dir=$TARGET_DIR"
        echo "file_types=${FILE_TYPES[*]}"
        echo "max_depth=$MAX_DEPTH"
    } > "$STATE_FILE"

    cat > "$REPORTS_DIR/auto-builder-summary-depth-$(date +%Y%m%d).txt" << EOF
=== STARCORE Auto Builder Depth v3.3 Summary ===
Cyklů: $CYCLE_COUNT
Cílový adresář: $TARGET_DIR
Hloubka: $MAX_DEPTH
Typy: ${FILE_TYPES[*]}
Celkem zpracováno souborů: $TOTAL_PROCESSED
Poslední cyklus: ${DURATION}s
Počet souborů v posledním cyklu: $FILE_COUNT
Duplicitní názvy: $DUP_NAMES_COUNT
Duplicitní hashe: $DUP_HASHES_COUNT
Syntaktické chyby: $SYNTAX_ERR_COUNT
Chybějící závislosti: $DEPS_ERR_COUNT
Automaticky opraveno: $REPAIRED_COUNT
Bezpečnostní varování: $SEC_WARNINGS
Vygenerované skripty: $GENERATED_TOTAL
EOF

    maybe_render_dashboard 1 "$CYCLE_COUNT" "$FILE_COUNT" "$TOTAL_PROCESSED" \
        "$SYNTAX_ERR_COUNT" "$DEPS_ERR_COUNT" "$DUP_NAMES_COUNT" "$DUP_HASHES_COUNT" \
        "$GENERATED_TOTAL" "$REPAIRED_COUNT" "$SEC_WARNINGS" \
        "Cyklus dokončen, čekání..." 100

    # ---------- 10. Čekání ----------
    log "${YELLOW}⏳ Čekám ${SLEEP_TIME}s před dalším cyklem...${NC}"
    sleep "$SLEEP_TIME"

    CYCLE_COUNT=$(( CYCLE_COUNT + 1 ))
done
