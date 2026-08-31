#!/bin/bash
# ============================================================================
# STARCORE AUTO BUILDER – Final / Merge Edition (v3.2-final)
# Verze: 3.2-final
# Autor: STARCORE Enterprise Architect
# Popis: Sjednocovací skript, který čte výstupy z originální a lite verze,
#        porovnává generované skripty, odstraňuje duplicity a vytváří
#        finální knihovnu (master skript) v samostatném adresáři.
#        Běží v nekonečné smyčce a průběžně aktualizuje finální sadu.
# ============================================================================

set -uo pipefail

# --------------------------- KONFIGURACE -----------------------------------
BASE_DIR="/root/starcore"
VERSION="final"
OPTIMIZED_DIR="$BASE_DIR/bin/optimized-${VERSION}"
STATE_FILE="$OPTIMIZED_DIR/.builder_state"
LOG_DIR="$BASE_DIR/logs/auto-builder-${VERSION}"
RUN_DIR="$BASE_DIR/run-${VERSION}"
REPORTS_DIR="$BASE_DIR/reports/${VERSION}"
PREFLIGHT_LOG="$LOG_DIR/preflight-$(date +%Y%m%d-%H%M%S).log"

DASHBOARD_REFRESH=10
SLEEP_TIME=10   # delší pauza, protože slučování je méně náročné

# ZDROJOVÉ ADRESÁŘE – výstupy z předchozích verzí
SOURCE_ORIGINAL_OPTIMIZED="$BASE_DIR/bin/optimized"
SOURCE_LITE_OPTIMIZED="$BASE_DIR/bin/optimized-lite"

# Další zdroje lze přidat později – stačí upravit toto pole
SOURCE_DIRS=(
    "$SOURCE_ORIGINAL_OPTIMIZED"
    "$SOURCE_LITE_OPTIMIZED"
)

AUTO_INSTALL_MISSING="${AUTO_INSTALL_MISSING:-0}"

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
echo -e "${BOLD}${BLUE}║     STARCORE AUTO BUILDER FINAL – PREFLIGHT CHECK           ║${NC}"
echo -e "${BOLD}${BLUE}╚══════════════════════════════════════════════════════════════╝${NC}"

# ---- 1. Oprávnění ----
echo -e "\n${BOLD}[1/6] Oprávnění${NC}"
if [[ "$(id -u)" -eq 0 ]]; then
    pf_ok "Skript běží jako root"
else
    pf_warn "Skript neběží jako root – některé operace mohou vyžadovat sudo"
fi

# ---- 2. Adresářová struktura ----
echo -e "\n${BOLD}[2/6] Adresářová struktura${NC}"
for d in "$BASE_DIR" "$OPTIMIZED_DIR" "$LOG_DIR" "$RUN_DIR" "$REPORTS_DIR" \
         "$SOURCE_ORIGINAL_OPTIMIZED" "$SOURCE_LITE_OPTIMIZED"; do
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
echo -e "\n${BOLD}[3/6] Testovací zápis${NC}"
TESTFILE="$BASE_DIR/.write_test_$$"
if echo "test" > "$TESTFILE" 2>/dev/null; then
    rm -f "$TESTFILE"
    pf_ok "Zápis do $BASE_DIR funguje"
else
    pf_fail "Nelze zapisovat do $BASE_DIR – zkontroluj oprávnění/disk"
fi

# ---- 4. Místo na disku ----
echo -e "\n${BOLD}[4/6] Místo na disku${NC}"
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

# ---- 5. Povinné nástroje (stačí základ) ----
echo -e "\n${BOLD}[5/6] Povinné nástroje${NC}"
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

# ---- 6. Shrnutí ----
echo -e "\n${BOLD}[6/6] Shrnutí${NC}"
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

LOG_FILE="$LOG_DIR/builder-$(date +%Y%m%d-%H%M%S).log"
{
    echo "=== STARCORE Auto Builder Final - Preflight Summary ==="
    echo "Datum: $(date)"
    echo "Varování: $PREFLIGHT_ISSUES, Opraveno: $PREFLIGHT_FIXED, Fatální: $PREFLIGHT_FATAL"
} > "$PREFLIGHT_LOG"

exec > >(tee -a "$LOG_FILE") 2>&1

log() { echo -e "[$(date '+%Y-%m-%d %H:%M:%S')] $*"; }
log "${GREEN}Preflight log uložen do: $PREFLIGHT_LOG${NC}"

# ============================================================================
# FÁZE 1: INICIALIZACE STAVU
# ============================================================================
if [[ -f "$STATE_FILE" ]]; then
    # shellcheck disable=SC1090
    source "$STATE_FILE" 2>/dev/null || true
    CYCLE_COUNT=${cycles_completed:-0}
    log "${BLUE}📂 Obnoven stav: cyklů $CYCLE_COUNT${NC}"
else
    CYCLE_COUNT=0
    {
        echo "# STARCORE Auto Builder Final State"
        echo "cycles_completed=0"
    } > "$STATE_FILE"
fi

RUN_START_TS=$(date +%s)

# ============================================================================
# FÁZE 2: ZPRACOVÁNÍ SIGNÁLŮ
# ============================================================================
SHUTTING_DOWN=0
cleanup() {
    SHUTTING_DOWN=1
    tput cnorm 2>/dev/null || true
    echo
    log "${YELLOW}⏹️  Přijat signál ukončení. Ukládám stav a končím...${NC}"
    {
        echo "cycles_completed=$CYCLE_COUNT"
        echo "stopped_at=$(date +%s)"
    } > "$STATE_FILE"
    log "${GREEN}✅ Stav uložen do $STATE_FILE${NC}"
    log "${GREEN}📁 Finální knihovna: $OPTIMIZED_DIR${NC}"
    log "${GREEN}📄 Log: $LOG_FILE${NC}"
    exit 0
}
trap cleanup SIGINT SIGTERM

# ============================================================================
# FÁZE 3: DASHBOARD
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
    local cycle="${1:-0}" total_scripts="${2:-0}" unique_scripts="${3:-0}" duplicates="${4:-0}"
    local phase="${5:-}" phase_pct="${6:-0}"

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

    local sep_thick="════════════════════════════════════════════════════════════════"
    local sep_thin="────────────────────────────────────────────────────────────────"

    local out=""
    out+="${BOLD}${BLUE}╔${sep_thick}╗${NC}\n"
    out+="${BOLD}${BLUE}║${NC}  ${BOLD}STARCORE AUTO BUILDER FINAL – LIVE DASHBOARD${NC}\n"
    out+="${BOLD}${BLUE}╠${sep_thick}╣${NC}\n"
    out+="${BLUE}║${NC}  Aktuální fáze : ${BOLD}${MAGENTA}${phase}${NC}\n"
    out+="${BLUE}║${NC}  Průběh fáze   : $(draw_progress_bar "$phase_pct")\n"
    out+="${BLUE}╠${sep_thin}╣${NC}\n"

    local rows=(
        "Cyklus|#$cycle"
        "Celkem nalezeno skriptů|$total_scripts"
        "Unikátních po sloučení|$unique_scripts"
        "Duplicit (vyřešeno)|$duplicates"
        "Doba aktuálního cyklu|$(format_duration "$cycle_elapsed")"
        "Celkový čas běhu|$(format_duration "$total_runtime")"
        "Průměr na cyklus|$(format_duration "$avg_per_cycle")"
        "Volné místo na disku|$disk_avail"
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
# FÁZE 4: HLAVNÍ FUNKCE SLUČOVÁNÍ
# ============================================================================
merge_scripts() {
    local temp_dir="$RUN_DIR/merge_$$"
    mkdir -p "$temp_dir"
    local all_scripts_list="$temp_dir/all_scripts.txt"
    : > "$all_scripts_list"

    # 1) Shromáždit všechny .sh soubory ze zdrojových adresářů
    for src in "${SOURCE_DIRS[@]}"; do
        [[ -d "$src" ]] || continue
        find "$src" -maxdepth 1 -type f -name "*.sh" -exec basename {} \; 2>/dev/null >> "$all_scripts_list"
    done

    sort -u -o "$all_scripts_list" "$all_scripts_list"
    local total_scripts
    total_scripts=$(wc -l < "$all_scripts_list")

    # 2) Pro každý skript zjistit, zda existuje ve více zdrojích, a porovnat MD5
    local duplicate_count=0
    local unique_count=0
    local temp_unique="$temp_dir/unique.txt"
    : > "$temp_unique"
    local temp_duplicates="$temp_dir/duplicates.txt"
    : > "$temp_duplicates"

    while IFS= read -r script_name; do
        [[ -z "$script_name" ]] && continue
        local found_sources=()
        local md5_list=()
        local source_paths=()

        for src in "${SOURCE_DIRS[@]}"; do
            local full_path="$src/$script_name"
            if [[ -f "$full_path" ]]; then
                found_sources+=("$src")
                if [[ -f "$full_path" ]]; then
                    md5_list+=("$(md5sum "$full_path" 2>/dev/null | cut -d' ' -f1)")
                else
                    md5_list+=("")
                fi
                source_paths+=("$full_path")
            fi
        done

        if [[ ${#found_sources[@]} -eq 1 ]]; then
            # Pouze jeden výskyt – zkopírujeme do finálního adresáře
            cp "${source_paths[0]}" "$OPTIMIZED_DIR/" && ((unique_count++))
        else
            # Více výskytů – porovnej MD5
            local unique_md5=()
            for idx in "${!md5_list[@]}"; do
                if [[ -n "${md5_list[$idx]}" ]]; then
                    if [[ ! " ${unique_md5[@]} " =~ " ${md5_list[$idx]} " ]]; then
                        unique_md5+=("${md5_list[$idx]}")
                    fi
                fi
            done

            if [[ ${#unique_md5[@]} -eq 1 ]]; then
                # Všechny výskyty jsou stejné – zkopírujeme jeden
                cp "${source_paths[0]}" "$OPTIMIZED_DIR/$script_name" && ((unique_count++))
            else
                # Různé verze – zkopírujeme všechny s příponou podle zdroje
                for idx in "${!found_sources[@]}"; do
                    local src_name=$(basename "${found_sources[$idx]}")
                    local new_name="${script_name%.sh}_${src_name}.sh"
                    cp "${source_paths[$idx]}" "$OPTIMIZED_DIR/$new_name"
                done
                duplicate_count=$((duplicate_count + 1))
                echo "$script_name: ${#found_sources[@]} verzí (různé hashe)" >> "$temp_duplicates"
            fi
        fi
    done < "$all_scripts_list"

    # 3) Vygenerovat master spouštěcí skript
    cat > "$OPTIMIZED_DIR/starcore-master.sh" << 'EOF'
#!/bin/bash
# ============================================================
# STARCORE MASTER SCRIPT – Finální knihovna
# Vygenerováno automaticky sjednocovacím skriptem
# ============================================================
set -uo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo "=== STARCORE MASTER KNI HOVNA ==="
echo "Dostupné skripty:"
find "$SCRIPT_DIR" -maxdepth 1 -type f -name "*.sh" ! -name "starcore-master.sh" -exec basename {} \; | sort | nl
echo ""
echo "Pro spuštění zadej: $0 <název_skriptu> [parametry]"
echo "Příklad: $0 starcore-fix-all_v5.sh --help"
EOF
    chmod +x "$OPTIMIZED_DIR/starcore-master.sh"

    # 4) Uložit report
    {
        echo "=== STARCORE FINAL MERGE REPORT ==="
        echo "Datum: $(date)"
        echo "Celkem nalezeno skriptů: $total_scripts"
        echo "Unikátních po sloučení: $unique_count"
        echo "Duplicit (různé verze): $duplicate_count"
        echo ""
        if [[ -s "$temp_duplicates" ]]; then
            echo "Seznam duplicitních skriptů (různé verze):"
            cat "$temp_duplicates"
        else
            echo "Žádné duplicity s různými verzemi."
        fi
    } > "$REPORTS_DIR/merge-report-$(date +%Y%m%d-%H%M%S).txt"

    # Vyčistit dočasné soubory
    rm -rf "$temp_dir"

    # Vrátit hodnoty pro dashboard
    echo "$total_scripts $unique_count $duplicate_count"
}

# ============================================================================
# FÁZE 5: HLAVNÍ SMYČKA
# ============================================================================
log "${GREEN}${BOLD}🚀 Spouštím STARCORE Auto Builder Final v3.2${NC}"
log "${BLUE}🔁 Běží v nekonečné smyčce, zastavte Ctrl+C (stav se uloží automaticky)${NC}"
log "${BLUE}📁 Finální knihovna: $OPTIMIZED_DIR${NC}"
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
    log "${BLUE}========================================${NC}"
    log "${BLUE}🔁 CYKLUS #$CYCLE_COUNT (Final)${NC}"
    log "${BLUE}========================================${NC}"

    # Spustit sloučení
    log "${YELLOW}🔄 Provádím sloučení zdrojových skriptů...${NC}"
    mkdir -p "$OPTIMIZED_DIR"
    # Vyčistit finální adresář (ponechat master skript)
    find "$OPTIMIZED_DIR" -maxdepth 1 -type f -name "*.sh" ! -name "starcore-master.sh" -exec rm -f {} \;

    merge_output=$(merge_scripts)
    read -r total_scripts unique_count duplicate_count <<< "$merge_output"

    log "${GREEN}✅ Sloučení dokončeno: $total_scripts nalezeno, $unique_count unikátních, $duplicate_count duplicit (různé verze)${NC}"

    # Uložit stav
    {
        echo "cycles_completed=$CYCLE_COUNT"
        echo "last_merge_time=$(date)"
        echo "total_scripts=$total_scripts"
        echo "unique_scripts=$unique_count"
        echo "duplicates=$duplicate_count"
    } > "$STATE_FILE"

    maybe_render_dashboard 1 "$CYCLE_COUNT" "$total_scripts" "$unique_count" "$duplicate_count" \
        "Sloučení dokončeno, čekání..." 100

    log "${YELLOW}⏳ Čekám ${SLEEP_TIME}s před dalším cyklem...${NC}"
    sleep "$SLEEP_TIME"

    CYCLE_COUNT=$((CYCLE_COUNT + 1))
done
