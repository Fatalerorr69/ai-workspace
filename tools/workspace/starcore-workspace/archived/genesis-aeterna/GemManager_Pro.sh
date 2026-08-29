#!/bin/bash
# GemManager Pro for Linux (Bash)
# Verze: 5.0
# Vyžaduje: bash 4+, coreutils, find, grep, sed, awk, curl, jq, git, qpdf, zip

set -euo pipefail
export LC_ALL=en_US.UTF-8
export LANG=en_US.UTF-8

# ----- KONFIGURACE -----
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$SCRIPT_DIR"
CONFIG_FILE="$SCRIPT_DIR/gem_manager_config.json"
GLOBAL_CONFIG="$ROOT_DIR/_global_config.json"
EXCLUDED_FOLDERS=("VSTUPNÍ GEM (ORCHESTRÁTOR)" "_knowledge_base" "_backup" "_redundant" "_global_config" "_exports" "_audits")
LOG_FILE="$SCRIPT_DIR/gem_manager.log"
RELEVANCE_THRESHOLD=0.3
PARALLEL_JOBS=3

# ----- BAREVNÝ VÝSTUP -----
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
MAGENTA='\033[0;35m'
GRAY='\033[0;90m'
NC='\033[0m'

# ----- LOGOVÁNÍ -----
log() {
    local msg="[$(date '+%Y-%m-%d %H:%M:%S')] $1"
    echo -e "$msg" | tee -a "$LOG_FILE"
}

log_color() {
    local color="$1"; shift
    echo -e "${color}[$(date '+%Y-%m-%d %H:%M:%S')] $*${NC}" | tee -a "$LOG_FILE"
}

# ----- KONTROLA A INSTALACE ZÁVISLOSTÍ (automatická) -----
check_and_install() {
    local cmd="$1"
    local pkg_name="$2"
    local alt_install="$3"
    if command -v "$cmd" &>/dev/null; then
        log_color "$GREEN" "✓ $cmd je nainstalován."
        return 0
    fi
    log_color "$YELLOW" "⚠ $cmd není nainstalován. Pokus o instalaci..."
    if command -v apt &>/dev/null; then
        sudo apt update && sudo apt install -y "$pkg_name"
    elif command -v yum &>/dev/null; then
        sudo yum install -y "$pkg_name"
    elif command -v pacman &>/dev/null; then
        sudo pacman -S --noconfirm "$pkg_name"
    else
        log_color "$RED" "Neznámý package manager. Zkuste ručně: $alt_install"
        return 1
    fi
    if command -v "$cmd" &>/dev/null; then
        log_color "$GREEN" "✓ $cmd úspěšně nainstalován."
        return 0
    else
        log_color "$RED" "Instalace selhala. Nainstalujte prosím ručně: $alt_install"
        return 1
    fi
}

ensure_dependencies() {
    log_color "$CYAN" "Kontrola závislostí..."
    check_and_install "qpdf" "qpdf" "https://github.com/qpdf/qpdf/releases" || true
    check_and_install "git" "git" "https://git-scm.com/download/linux" || true
    check_and_install "zip" "zip" "sudo apt install zip" || true
    check_and_install "curl" "curl" "sudo apt install curl" || true
    check_and_install "jq" "jq" "sudo apt install jq" || true
}

# ----- KONFIGURACE JSON (pomocí jq) -----
init_global_config() {
    if [[ ! -f "$GLOBAL_CONFIG" ]]; then
        log_color "$YELLOW" "Vytvářím výchozí globální konfiguraci..."
        cat > "$GLOBAL_CONFIG" <<EOF
{
  "relevanceThreshold": 0.3,
  "stopWords": ["a","an","and","the","of","to","in","for","on","with","by","is","at","are","that","this","these","those","be","as","from","or","but","not","so","such","was","were","has","have","had","do","does","did","will","would","could","should","may","might","must","pro"],
  "lowRelevanceExtensions": [".jpg",".jpeg",".png",".gif",".bmp",".tiff",".ico",".mp4",".avi",".mov",".mkv",".mp3",".wav",".flac",".exe",".msi",".dll",".so",".dmg",".iso",".zip",".rar",".7z",".tar",".gz",".bz2",".xz",".cab",".deb",".rpm"],
  "keywordBoost": { "fileName": 0.4, "content": 0.3, "extension": 0.2 },
  "gitEnabled": false,
  "gitRemoteUrl": "",
  "parallelJobs": 3,
  "backupRetentionDays": 30
}
EOF
    fi
    RELEVANCE_THRESHOLD=$(jq -r '.relevanceThreshold' "$GLOBAL_CONFIG")
    PARALLEL_JOBS=$(jq -r '.parallelJobs' "$GLOBAL_CONFIG")
}

load_config() {
    if [[ -f "$CONFIG_FILE" ]]; then
        ROOT_DIR=$(jq -r '.rootPath' "$CONFIG_FILE")
    else
        ROOT_DIR="$SCRIPT_DIR"
        save_config
    fi
    init_global_config
}

save_config() {
    jq -n --arg root "$ROOT_DIR" '{rootPath: $root}' > "$CONFIG_FILE"
}

set_root_path() {
    echo -e "${CYAN}Aktuální kořenová cesta: $ROOT_DIR${NC}"
    read -p "Zadejte novou cestu (Enter pro ponechání): " new_path
    if [[ -n "$new_path" ]]; then
        new_path=$(realpath -m "$new_path")
        if [[ -d "$new_path" ]]; then
            ROOT_DIR="$new_path"
            save_config
            init_global_config
            log_color "$GREEN" "Kořenová cesta změněna na $ROOT_DIR"
        else
            log_color "$RED" "Cesta neexistuje!"
        fi
    fi
}

# ----- PRÁCE SE SLOŽKAMI -----
get_gem_folders() {
    find "$ROOT_DIR" -maxdepth 1 -type d | tail -n +2 | while read -r d; do
        name=$(basename "$d")
        skip=0
        for excl in "${EXCLUDED_FOLDERS[@]}"; do
            if [[ "$name" == "$excl" || "$name" == _* ]]; then skip=1; break; fi
        done
        if [[ $skip -eq 0 ]]; then echo "$d"; fi
    done
}

select_gem_folder() {
    mapfile -t folders < <(get_gem_folders)
    if [[ ${#folders[@]} -eq 0 ]]; then
        log_color "$RED" "Žádné GEM složky."
        return 1
    fi
    echo -e "${CYAN}Dostupné GEM složky:${NC}"
    for i in "${!folders[@]}"; do
        echo "[$((i+1))] $(basename "${folders[$i]}")"
    done
    read -p "Vyberte číslo (0 pro zrušení): " choice
    if [[ "$choice" =~ ^[0-9]+$ ]] && (( choice >= 1 && choice <= ${#folders[@]} )); then
        echo "${folders[$((choice-1))]}"
        return 0
    fi
    return 1
}

show_overview() {
    echo -e "${MAGENTA}=== PŘEHLED GEM SLOŽEK ===${NC}"
    while IFS= read -r folder; do
        name=$(basename "$folder")
        count=$(find "$folder" -type f ! -path "*_knowledge_base*" | wc -l)
        size=$(du -sm "$folder" 2>/dev/null | cut -f1)
        echo -e "${CYAN}$name : $count souborů, ${size:-0} MB${NC}"
    done < <(get_gem_folders)
}

# ----- ZÁLOHOVÁNÍ -----
backup_gem_folder() {
    local folder="$1"
    local backup_dir="$ROOT_DIR/_backups"
    mkdir -p "$backup_dir"
    local timestamp=$(date +%Y%m%d_%H%M%S)
    local name=$(basename "$folder")
    local backup_file="$backup_dir/${name}_$timestamp.tar.gz"
    log_color "$CYAN" "Zálohuji $folder -> $backup_file"
    tar -czf "$backup_file" -C "$(dirname "$folder")" "$name"
    log_color "$GREEN" "Záloha vytvořena."
    local retention=$(jq -r '.backupRetentionDays' "$GLOBAL_CONFIG")
    find "$backup_dir" -name "${name}_*.tar.gz" -type f -mtime +$retention -delete 2>/dev/null || true
}

# ----- GENEROVÁNÍ README -----
generate_readme() {
    local folder="$1"
    local readme="$folder/README.md"
    local name=$(basename "$folder")
    local kb_path="$folder/_knowledge_base"
    local txt_size="0 MB"
    local pdf_count=0
    local last_update="nikdy"
    if [[ -d "$kb_path" ]]; then
        txt_size=$(du -sh "$kb_path" 2>/dev/null | cut -f1)
        pdf_count=$(find "$kb_path" -name "*.pdf" | wc -l)
        last_update=$(find "$kb_path" -type f -printf '%T@ %p\n' 2>/dev/null | sort -n | tail -1 | cut -d' ' -f2- | xargs stat -c '%y' 2>/dev/null | cut -d' ' -f1)
        [[ -z "$last_update" ]] && last_update="nikdy"
    fi
    cat > "$readme" <<EOF
# GEM Robot: $name

## Popis
Tento robot je součástí systému GEM Knowledge Manager.

## Statistiky znalostní báze
- Velikost textových souborů: $txt_size
- Počet PDF dokumentů: $pdf_count
- Poslední aktualizace: $last_update

## Automaticky generováno
GemManager Pro dne $(date '+%Y-%m-%d %H:%M:%S')
EOF
    log_color "$GREEN" "README.md vygenerován pro $name"
}

# ----- SMART UPDATE (INKREMENTÁLNÍ ZPRACOVÁNÍ) -----
process_gem_folder() {
    local src="$1"
    local dest="$src/_knowledge_base"
    backup_gem_folder "$src"
    mkdir -p "$dest"/{Globalni_Konfigurace,TXT,PDF,YAML,Skripty,Logs}
    
    local added=0 skipped=0 copied=0 errors=0
    
    log_color "$CYAN" "Zpracovávám: $(basename "$src")"
    
    local txt_out="$dest/TXT/kompletni_soubor_TXT.txt"
    local yaml_out="$dest/YAML/kompletni_soubor_YAML.txt"
    local script_out="$dest/Skripty/kompletni_soubor_Skripty.txt"
    
    # Načtení existujících názvů do asociativních polí (bash 4+)
    declare -A txt_hash yaml_hash script_hash
    if [[ -f "$txt_out" ]]; then
        while IFS= read -r line; do
            [[ "$line" =~ START\ SOUBORU:\ (.*)\ --- ]] && txt_hash["${BASH_REMATCH[1]}"]=1
        done < "$txt_out"
    fi
    if [[ -f "$yaml_out" ]]; then
        while IFS= read -r line; do
            [[ "$line" =~ START\ SOUBORU:\ (.*)\ --- ]] && yaml_hash["${BASH_REMATCH[1]}"]=1
        done < "$yaml_out"
    fi
    if [[ -f "$script_out" ]]; then
        while IFS= read -r line; do
            [[ "$line" =~ START\ SOUBORU:\ (.*)\ --- ]] && script_hash["${BASH_REMATCH[1]}"]=1
        done < "$script_out"
    fi
    
    total=$(find "$src" -type f \( -name "*.txt" -o -name "*.md" -o -name "*.yaml" -o -name "*.yml" -o -name "*.pdf" -o -name "*.ps1" -o -name "*.sh" -o -name "*.bat" \) ! -path "$dest/*" | wc -l)
    current=0
    
    find "$src" -type f \( -name "*.txt" -o -name "*.md" -o -name "*.yaml" -o -name "*.yml" -o -name "*.pdf" -o -name "*.ps1" -o -name "*.sh" -o -name "*.bat" \) ! -path "$dest/*" -print0 | while IFS= read -r -d '' file; do
        ((current++))
        percent=$((current * 100 / total))
        echo -ne "\r${CYAN}Zpracování: $percent% (${current}/${total}) - $(basename "$file")${NC}    "
        
        fname=$(basename "$file")
        ext="${fname##*.}"
        ext=$(echo "$ext" | tr '[:upper:]' '[:lower:]')
        
        case "$ext" in
            txt|md|log|json|csv) sub="TXT"; outfile="$txt_out"; hash_ref="txt_hash" ;;
            yaml|yml) sub="YAML"; outfile="$yaml_out"; hash_ref="yaml_hash" ;;
            ps1|sh|bat) sub="Skripty"; outfile="$script_out"; hash_ref="script_hash" ;;
            pdf) sub="PDF" ;;
            *) continue ;;
        esac
        
        if [[ "$sub" == "PDF" ]]; then
            target="$dest/PDF/$fname"
            if [[ ! -f "$target" ]]; then
                cp "$file" "$target" && ((copied++))
                log_color "$CYAN" "+ [PDF KOPÍROVÁNO] $fname"
            else
                ((skipped++))
            fi
        else
            # Kontrola duplicity pomocí asociativního pole
            if [[ -n "${!hash_ref["$fname"]+_}" ]]; then
                ((skipped++))
            else
                echo -e "\n--- START SOUBORU: $fname ---" >> "$outfile"
                cat "$file" >> "$outfile"
                echo -e "\n--- KONEC SOUBORU ---" >> "$outfile"
                ((added++))
                log_color "$GREEN" "+ [TEXT PŘIDÁN] $fname"
                # Nelze snadno přidat do asociativního pole z pipe, ale výsledek je uložen
            fi
        fi
    done
    echo "" # nový řádek
    log_color "$MAGENTA" "REPORT pro $(basename "$src"): Přidáno: $added, PDF: $copied, Přeskočeno: $skipped, Chyby: $errors"
    generate_readme "$src"
    
    # Git commit (pokud je povolen)
    if [[ "$(jq -r '.gitEnabled' "$GLOBAL_CONFIG")" == "true" ]]; then
        if command -v git &>/dev/null; then
            pushd "$dest" >/dev/null
            if [[ ! -d .git ]]; then
                git init
                git add .
                git commit -m "Initial knowledge base"
                local remote=$(jq -r '.gitRemoteUrl' "$GLOBAL_CONFIG")
                [[ -n "$remote" && "$remote" != "null" ]] && git remote add origin "$remote"
            else
                git add .
                git commit -m "Auto-update $(date '+%Y-%m-%d %H:%M:%S')" || true
                [[ -n "$remote" && "$remote" != "null" ]] && git push || true
            fi
            popd >/dev/null
        fi
    fi
}

# ----- PARALELNÍ ZPRACOVÁNÍ (pomocí xargs) -----
process_all_gem_folders_parallel() {
    mapfile -t folders < <(get_gem_folders)
    if [[ ${#folders[@]} -eq 0 ]]; then
        log_color "$RED" "Žádné složky."
        return
    fi
    log_color "$CYAN" "Spouštím paralelní zpracování (max $PARALLEL_JOBS najednou)..."
    export -f process_gem_folder backup_gem_folder generate_readme log_color log
    printf "%s\n" "${folders[@]}" | xargs -P "$PARALLEL_JOBS" -I {} bash -c 'process_gem_folder "{}"'
    log_color "$GREEN" "Všechny složky zpracovány paralelně."
}

# ----- SLOUČENÍ PDF -----
merge_pdf() {
    local folder="$1"
    if ! command -v qpdf &>/dev/null; then
        log_color "$RED" "qpdf není nainstalován, slučování přeskočeno."
        return
    fi
    local pdfs=($(find "$folder" -maxdepth 1 -name "*.pdf" -type f))
    if [[ ${#pdfs[@]} -eq 0 ]]; then
        log_color "$YELLOW" "Žádná PDF."
        return
    fi
    local output="$folder/kompletni_sloucene_PDF.pdf"
    pushd "$folder" >/dev/null
    qpdf --empty --pages *.pdf -- "$output" 2>/dev/null
    if [[ $? -eq 0 ]]; then
        log_color "$GREEN" "PDF sloučena do $output"
    else
        log_color "$RED" "Chyba při slučování."
    fi
    popd >/dev/null
}

# ----- SMART ANALÝZA (NEPATŘÍCÍ SOUBORY) -----
smart_analyze_and_clean() {
    local folder="$1"
    echo -e "${MAGENTA}=== SMART ANALÝZA PRO: $(basename "$folder") ===${NC}"
    
    # Získání popisných souborů
    local desc_files=$(find "$folder" -maxdepth 1 -name "*.txt" -type f)
    local robot_name=$(basename "$folder")
    local combined="$robot_name"
    while IFS= read -r f; do
        combined+=" $(cat "$f" 2>/dev/null)"
    done <<< "$desc_files"
    
    # Extrakce klíčových slov
    local stopwords=$(jq -r '.stopWords | join("|")' "$GLOBAL_CONFIG")
    local keywords=$(echo "$combined" | tr '[:upper:]' '[:lower:]' | grep -oE '\b[a-z]{4,}\b' | grep -vE "^($stopwords)$" | sort | uniq -c | sort -nr | head -30 | awk '{print $2}')
    log_color "$GRAY" "Klíčová slova: $(echo "$keywords" | tr '\n' ', ')"
    
    # Procházení souborů
    local low_ext=$(jq -r '.lowRelevanceExtensions | join("|")' "$GLOBAL_CONFIG")
    local irrelevant=()
    while IFS= read -r file; do
        [[ "$file" == *"_knowledge_base"* || "$file" == *"_redundant"* ]] && continue
        local score=0
        local ext="${file##*.}"
        ext=".${ext,,}"
        if [[ "$ext" =~ ^($low_ext)$ ]]; then
            score=-0.5
        elif [[ "$ext" == ".pdf" ]]; then
            score=$(jq -r '.keywordBoost.extension' "$GLOBAL_CONFIG")
        elif [[ "$ext" =~ ^.(txt|md|ps1|sh|yaml|yml)$ ]]; then
            score=$(jq -r '.keywordBoost.extension' "$GLOBAL_CONFIG")
        fi
        local fname=$(basename "$file" | tr '[:upper:]' '[:lower:]')
        while read -r kw; do
            if [[ "$fname" == *"$kw"* ]]; then
                score=$(echo "$score + $(jq -r '.keywordBoost.fileName' "$GLOBAL_CONFIG")" | bc)
                break
            fi
        done <<< "$keywords"
        # Obsah pro textové soubory
        if [[ "$ext" =~ ^.(txt|md|ps1|sh|yaml|yml|json|csv|log)$ ]]; then
            local sample=$(head -c 2000 "$file" 2>/dev/null | tr '[:upper:]' '[:lower:]')
            while read -r kw; do
                if [[ "$sample" == *"$kw"* ]]; then
                    score=$(echo "$score + $(jq -r '.keywordBoost.content' "$GLOBAL_CONFIG")" | bc)
                    break
                fi
            done <<< "$keywords"
        fi
        if (( $(echo "$score < $RELEVANCE_THRESHOLD" | bc -l) )); then
            irrelevant+=("$file")
            log_color "$YELLOW" "Označen jako nepatřící: $file (skóre: $score)"
        fi
    done < <(find "$folder" -type f ! -path "*_knowledge_base*" ! -path "*_redundant*")
    
    echo -e "${YELLOW}Počet nepatřících souborů: ${#irrelevant[@]}${NC}"
    if [[ ${#irrelevant[@]} -gt 0 ]]; then
        for f in "${irrelevant[@]}"; do echo "   $f"; done
        read -p "[1] Přesunout do _redundant  [2] Smazat  [3] Ignorovat: " action
        if [[ "$action" == "1" ]]; then
            local redir="$folder/_redundant"
            for f in "${irrelevant[@]}"; do
                local rel="${f#$folder/}"
                local dest="$redir/$rel"
                mkdir -p "$(dirname "$dest")"
                mv "$f" "$dest"
            done
            log_color "$GREEN" "Přesunuto ${#irrelevant[@]} souborů."
        elif [[ "$action" == "2" ]]; then
            for f in "${irrelevant[@]}"; do rm -f "$f"; done
            log_color "$RED" "Smazáno ${#irrelevant[@]} souborů."
        fi
    else
        echo -e "${GREEN}Žádné nepatřící soubory.${NC}"
    fi
}

# ----- PŘIDÁNÍ NOVÉHO ROBOTA -----
add_new_gem_robot() {
    echo -e "${MAGENTA}=== PŘIDÁNÍ NOVÉHO ROBOTA ===${NC}"
    read -p "Cesta ke složce (může být mimo kořen): " source_path
    source_path=$(realpath -m "$source_path")
    if [[ ! -d "$source_path" ]]; then
        log_color "$RED" "Cesta neexistuje!"
        return
    fi
    local default_name=$(basename "$source_path")
    read -p "Název robota (Enter pro '$default_name'): " new_name
    [[ -z "$new_name" ]] && new_name="$default_name"
    local target="$ROOT_DIR/$new_name"
    if [[ -d "$target" ]]; then
        log_color "$RED" "Robot již existuje."
        return
    fi
    read -p "[1] Přesunout  [2] Zkopírovat (1/2): " move_copy
    if [[ "$move_copy" == "1" ]]; then
        mv "$source_path" "$target"
    else
        cp -r "$source_path" "$target"
    fi
    log_color "$GREEN" "Robot přidán do $target"
    smart_analyze_and_clean "$target"
    read -p "Vytvořit knowledge base? (ano/ne): " create_kb
    if [[ "$create_kb" == "ano" ]]; then
        process_gem_folder "$target"
    fi
}

# ----- EXPORT BALÍČKU PRO LLM / ASISTENTA -----
export_package() {
    local folder="$1"
    local name=$(basename "$folder")
    local export_dir="$ROOT_DIR/_exports"
    mkdir -p "$export_dir"
    local timestamp=$(date +%Y%m%d_%H%M%S)
    local package_name="${name}_package_$timestamp"
    local package_dir="$export_dir/$package_name"
    mkdir -p "$package_dir"
    if [[ -d "$folder/_knowledge_base" ]]; then
        cp -r "$folder/_knowledge_base" "$package_dir/knowledge_base"
    fi
    [[ -f "$folder/README.md" ]] && cp "$folder/README.md" "$package_dir/"
    cat > "$package_dir/manifest.json" <<EOF
{
  "robotName": "$name",
  "exportDate": "$(date '+%Y-%m-%d %H:%M:%S')",
  "sourcePath": "$folder",
  "fileCount": $(find "$folder" -type f ! -path "*_knowledge_base*" | wc -l),
  "kbSizeMB": $(du -sm "$folder/_knowledge_base" 2>/dev/null | cut -f1 || echo 0),
  "description": "Export balíčku pro přenos do LLM nebo vlastního AI asistenta."
}
EOF
    local zip_file="$export_dir/${package_name}.zip"
    (cd "$export_dir" && zip -r "$zip_file" "$package_name" >/dev/null)
    rm -rf "$package_dir"
    log_color "$GREEN" "Balíček vytvořen: $zip_file"
}

# ----- EXPORT REPORTU HTML/CSV -----
export_report() {
    local export_dir="$ROOT_DIR/_exports"
    mkdir -p "$export_dir"
    local csv_file="$export_dir/gem_report.csv"
    local html_file="$export_dir/gem_report.html"
    echo "Robot,Počet souborů,Velikost (MB),Poslední změna" > "$csv_file"
    local html_header='<!DOCTYPE html><html><head><meta charset="UTF-8"><title>GEM Report</title><style>body{font-family:Arial;}table{border-collapse:collapse;}th,td{border:1px solid #ddd;padding:8px;}th{background-color:#4CAF50;color:white;}</style></head><body><h1>Přehled GEM robotů</h1><table><tr><th>Robot</th><th>Počet souborů</th><th>Velikost (MB)</th><th>Poslední změna</th></tr>'
    local html_rows=""
    while IFS= read -r folder; do
        name=$(basename "$folder")
        count=$(find "$folder" -type f ! -path "*_knowledge_base*" | wc -l)
        size=$(du -sm "$folder" 2>/dev/null | cut -f1)
        last=$(find "$folder" -type f -printf '%T@ %p\n' 2>/dev/null | sort -n | tail -1 | cut -d' ' -f2- | xargs stat -c '%y' 2>/dev/null | cut -d' ' -f1)
        [[ -z "$last" ]] && last="nikdy"
        echo "\"$name\",$count,$size,$last" >> "$csv_file"
        html_rows+="<tr><td>$name</td><td>$count</td><td>$size</td><td>$last</td></tr>"
    done < <(get_gem_folders)
    cat > "$html_file" <<EOF
$html_header
$html_rows
</table><p>Vygenerováno: $(date)</p></body></html>
EOF
    log_color "$GREEN" "Reporty uloženy do $export_dir"
    if command -v xdg-open &>/dev/null; then
        xdg-open "$html_file" 2>/dev/null &
    fi
}

# ----- HLOUBKOVÝ AUDIT (MD REPORT) -----
deep_audit_folder() {
    local folder="$1"
    local audit_dir="$ROOT_DIR/_audits"
    mkdir -p "$audit_dir"
    local timestamp=$(date +%Y%m%d_%H%M%S)
    local folder_name=$(basename "$folder" | sed 's/[^a-zA-Z0-9_-]/_/g')
    local output_file="$audit_dir/Audit_${folder_name}_$timestamp.md"
    
    log_color "$CYAN" "Provádím hloubkový audit složky: $folder"
    echo -e "${YELLOW}Tato operace může trvat několik minut (duplicity, analýza textu)...${NC}"
    
    # Základní info
    local total_size=$(du -sb "$folder" | cut -f1)
    local file_count=$(find "$folder" -type f ! -path "*_knowledge_base*" | wc -l)
    local folder_count=$(find "$folder" -type d | wc -l)
    local latest_change=$(find "$folder" -type f -printf '%T@\n' 2>/dev/null | sort -n | tail -1 | xargs -I{} date -d @{} '+%Y-%m-%d %H:%M:%S' 2>/dev/null || echo "N/A")
    
    # Typy souborů
    local ext_stats=$(find "$folder" -type f ! -path "*_knowledge_base*" -printf "%f\n" | sed 's/.*\.//' | sort | uniq -c | sort -nr | head -20 | awk '{print "| ."$2" | "$1" | - |"}')
    
    # Největší soubory
    local largest=$(find "$folder" -type f ! -path "*_knowledge_base*" -exec du -b {} \; | sort -nr | head -20 | awk '{printf "| %s | %.2f MB | %s | %s |\n", $2, $1/1048576, "?", $2}')
    
    # Nepotřebné soubory (junk)
    local junk_patterns="*.tmp,*.temp,*.bak,*.old,*.log,*.cache,*.pyc,Thumbs.db,desktop.ini,.DS_Store"
    local junk_files=$(find "$folder" -type f \( -name "*.tmp" -o -name "*.temp" -o -name "*.bak" -o -name "*.old" -o -name "*.log" -o -name "*.cache" -o -name "*.pyc" -o -name "Thumbs.db" -o -name "desktop.ini" -o -name ".DS_Store" \) ! -path "*_knowledge_base*" | head -20 | sed 's|.*/||' | paste -sd ',' -)
    
    # Duplicity (MD5)
    echo -e "${YELLOW}Hledám duplicity...${NC}"
    declare -A hash_map
    local duplicates=0
    local dup_list=""
    while IFS= read -r file; do
        hash=$(md5sum "$file" | cut -d' ' -f1)
        if [[ -n "${hash_map[$hash]}" ]]; then
            ((duplicates++))
            dup_list+="- Duplicitní: $file a ${hash_map[$hash]}\n"
        else
            hash_map[$hash]="$file"
        fi
    done < <(find "$folder" -type f ! -path "*_knowledge_base*")
    
    # Textová statistika (prvních 200 souborů)
    local total_lines=0 total_words=0 total_chars=0 text_files=0
    while IFS= read -r file; do
        if [[ "$file" =~ \.(txt|md|ps1|sh|yaml|yml|json|csv|log)$ ]]; then
            lines=$(wc -l < "$file" 2>/dev/null || echo 0)
            words=$(wc -w < "$file" 2>/dev/null || echo 0)
            chars=$(wc -c < "$file" 2>/dev/null || echo 0)
            total_lines=$((total_lines + lines))
            total_words=$((total_words + words))
            total_chars=$((total_chars + chars))
            ((text_files++))
        fi
        ((text_files >= 200)) && break
    done < <(find "$folder" -type f ! -path "*_knowledge_base*")
    
    # Generování MD
    cat > "$output_file" <<EOF
# Hloubkový audit složky: $(basename "$folder")

**Datum auditu:** $(date '+%Y-%m-%d %H:%M:%S')  
**Cesta:** `$folder`  

---

## 1. Základní informace

| Metrika | Hodnota |
|---------|---------|
| Celková velikost | $(echo "$total_size" | awk '{printf "%.2f MB", $1/1048576}') |
| Počet souborů | $file_count |
| Počet složek | $folder_count |
| Poslední změna | $latest_change |

---

## 2. Typy souborů (top 20)

| Přípona | Počet | Velikost (MB) |
|---------|-------|----------------|
$ext_stats

---

## 3. Největší soubory (top 20)

| Název | Velikost (MB) | Poslední změna | Cesta |
|-------|---------------|----------------|-------|
$largest

---

## 4. Nepotřebné soubory (vzory: $junk_patterns)

$(if [[ -n "$junk_files" ]]; then echo "| Název | Cesta |\n|-------|-------|\n| $(echo "$junk_files" | sed 's/,/ | - |\n| /g') | - |"; else echo "Žádné nepotřebné soubory."; fi)

---

## 5. Duplicitní soubory

Bylo nalezeno **$duplicates** duplicitních párů.

$(if [[ $duplicates -gt 0 ]]; then echo -e "$dup_list"; else echo "Žádné duplicity."; fi)

---

## 6. Statistika textových souborů (prvních 200)

| Metrika | Hodnota |
|---------|---------|
| Počet analyzovaných souborů | $text_files |
| Celkový počet řádků | $total_lines |
| Celkový počet slov | $total_words |
| Celkový počet znaků | $total_chars |

---

*Tento audit byl vygenerován nástrojem GemManager Pro.*
EOF
    
    log_color "$GREEN" "Audit uložen do: $output_file"
    read -p "Chcete soubor nyní otevřít? (ano/ne): " open
    if [[ "$open" == "ano" ]]; then
        if command -v less &>/dev/null; then
            less "$output_file"
        else
            cat "$output_file"
        fi
    fi
}

# ----- KOMPLEXNÍ ANALÝZA + KLASIFIKACE -----
deep_analyze_and_classify() {
    local folder="$1"
    local audit_dir="$ROOT_DIR/_audits"
    mkdir -p "$audit_dir"
    local timestamp=$(date +%Y%m%d_%H%M%S)
    local folder_name=$(basename "$folder" | sed 's/[^a-zA-Z0-9_-]/_/g')
    local output_file="$audit_dir/Analyza_${folder_name}_$timestamp.md"
    
    log_color "$CYAN" "Provádím komplexní analýzu a klasifikaci složky: $folder"
    
    # Základní informace (stejné jako audit)
    local total_size=$(du -sb "$folder" | cut -f1)
    local file_count=$(find "$folder" -type f ! -path "*_knowledge_base*" | wc -l)
    local folder_count=$(find "$folder" -type d | wc -l)
    local latest_change=$(find "$folder" -type f -printf '%T@\n' 2>/dev/null | sort -n | tail -1 | xargs -I{} date -d @{} '+%Y-%m-%d %H:%M:%S' 2>/dev/null || echo "N/A")
    
    # Klíčové soubory
    local has_readme=$(find "$folder" -maxdepth 1 -iname "readme.md" -o -iname "readme.txt" | head -1)
    local has_license=$(find "$folder" -maxdepth 1 -iname "license*" | head -1)
    local has_git=$(test -d "$folder/.git" && echo "yes" || echo "no")
    local has_dockerfile=$(find "$folder" -maxdepth 1 -iname "dockerfile" | head -1)
    local has_requirements=$(find "$folder" -maxdepth 1 -iname "requirements.txt" | head -1)
    local has_package_json=$(find "$folder" -maxdepth 1 -name "package.json" | head -1)
    local has_makefile=$(find "$folder" -maxdepth 1 -iname "makefile" | head -1)
    
    # Programovací jazyky
    local langs=""
    if find "$folder" -name "*.py" | grep -q .; then langs+="Python "; fi
    if find "$folder" -name "*.js" -o -name "*.ts" | grep -q .; then langs+="JavaScript/TypeScript "; fi
    if find "$folder" -name "*.cs" | grep -q .; then langs+="C# "; fi
    if find "$folder" -name "*.java" | grep -q .; then langs+="Java "; fi
    if find "$folder" -name "*.go" | grep -q .; then langs+="Go "; fi
    if find "$folder" -name "*.rs" | grep -q .; then langs+="Rust "; fi
    if find "$folder" -name "*.php" | grep -q .; then langs+="PHP "; fi
    if [[ -z "$langs" ]]; then langs="žádné rozpoznané"; fi
    
    # Klasifikace projektu
    local project_type="Neurčeno"
    local confidence="Nízká"
    if [[ -n "$has_package_json" ]]; then
        project_type="Node.js / JavaScript projekt"
        confidence="Vysoká"
    elif [[ -n "$has_requirements" ]]; then
        project_type="Python projekt"
        confidence="Vysoká"
    elif [[ -n "$has_makefile" ]]; then
        project_type="C/C++ projekt (Makefile)"
        confidence="Střední"
    elif [[ -n "$has_dockerfile" ]]; then
        project_type="Docker kontejnerová aplikace"
        confidence="Střední"
    elif [[ "$file_count" -gt 0 && "$file_count" -lt 50 ]] && find "$folder" -name "*.md" | grep -q .; then
        project_type="Dokumentační repozitář / Knowledge base"
        confidence="Vysoká"
    elif [[ "$file_count" -eq 0 ]]; then
        project_type="Prázdná složka"
        confidence="Vysoká"
    elif [[ -n "$langs" && "$langs" != "žádné rozpoznané" ]]; then
        project_type="Projekt v jazycích: $langs"
        confidence="Střední"
    fi
    
    # Aktivita
    local days_since_change="N/A"
    if [[ "$latest_change" != "N/A" ]]; then
        local latest_epoch=$(date -d "$latest_change" +%s)
        local now_epoch=$(date +%s)
        days_since_change=$(( (now_epoch - latest_epoch) / 86400 ))
    fi
    local status="OK"
    if [[ $days_since_change -gt 180 ]]; then
        status="Zastaralý"
    elif [[ $days_since_change -gt 30 ]]; then
        status="Neaktivní"
    fi
    
    # Doporučení
    local recommendations=""
    [[ -z "$has_readme" ]] && recommendations+="- Chybí README.md – doporučeno pro dokumentaci.\n"
    [[ -z "$has_license" ]] && recommendations+="- Chybí LICENSE – pokud chcete projekt sdílet, přidejte licenci.\n"
    [[ "$has_git" == "no" ]] && recommendations+="- Není inicializován Git – spusťte 'git init'.\n"
    [[ $days_since_change -gt 30 ]] && recommendations+="- Projekt nebyl aktualizován více než 30 dní – zvažte oživení.\n"
    
    # Nepatřící soubory (zjednodušená smart analýza)
    local irrelevant_count=0
    # Zde by byla plná smart analýza, ale pro stručnost uvádíme jen počet
    # (lze volat smart_analyze_and_clean s parametrem pro tichý režim)
    
    # Generování MD
    cat > "$output_file" <<EOF
# Analýza a klasifikace složky: $(basename "$folder")

**Datum analýzy:** $(date '+%Y-%m-%d %H:%M:%S')  
**Cesta:** `$folder`  

---

## 📊 Základní informace

| Metrika | Hodnota |
|---------|---------|
| Celková velikost | $(echo "$total_size" | awk '{printf "%.2f MB", $1/1048576}') |
| Počet souborů | $file_count |
| Počet složek | $folder_count |
| Poslední změna | $latest_change |

---

## 🧠 Klasifikace projektu

| Vlastnost | Hodnota |
|-----------|---------|
| **Typ projektu** | $project_type |
| **Jistota klasifikace** | $confidence |
| **Programovací jazyky** | $langs |

---

## 📁 Klíčové soubory (přítomnost)

| Soubor | Stav |
|--------|------|
| README | $( [[ -n "$has_readme" ]] && echo "✅ Ano" || echo "❌ Chybí" ) |
| LICENSE | $( [[ -n "$has_license" ]] && echo "✅ Ano" || echo "❌ Chybí" ) |
| .git | $( [[ "$has_git" == "yes" ]] && echo "✅ Ano" || echo "❌ Ne" ) |
| Dockerfile | $( [[ -n "$has_dockerfile" ]] && echo "✅ Ano" || echo "❌ Ne" ) |
| requirements.txt / package.json | $( [[ -n "$has_requirements" || -n "$has_package_json" ]] && echo "✅ Ano" || echo "❌ Ne" ) |

---

## 🚦 Stav projektu a aktivita

| Ukazatel | Hodnota |
|----------|---------|
| **Celkový stav** | $status |
| **Dny od poslední změny** | $days_since_change |

---

## 💡 Doporučené akce

$(if [[ -n "$recommendations" ]]; then echo -e "$recommendations"; else echo "Projekt je v dobrém stavu, není třeba nic měnit."; fi)

---

## 🔗 Související akce

- Spusťte `Smart analýzu` pro odstranění nepatřících souborů.
- Vytvořte knowledge base pomocí `Smart Update`.
- Exportujte balíček pro LLM/asistenta.

---

*Tato analýza byla vygenerována nástrojem GemManager Pro.*
EOF
    
    log_color "$GREEN" "Analýza uložena do: $output_file"
    read -p "Chcete soubor nyní otevřít? (ano/ne): " open
    if [[ "$open" == "ano" ]]; then
        if command -v less &>/dev/null; then
            less "$output_file"
        else
            cat "$output_file"
        fi
    fi
}

# ----- PLÁNOVANÁ ÚLOHA (CRON) -----
schedule_cron() {
    local script_path=$(realpath "$0")
    local cron_line="0 2 * * * $script_path --auto-update >> $LOG_FILE 2>&1"
    (crontab -l 2>/dev/null | grep -vF "$script_path"; echo "$cron_line") | crontab -
    log_color "$GREEN" "Plánovaná úloha přidána do cronu (denně v 2:00)."
}

auto_update() {
    log_color "$CYAN" "Automatická aktualizace spuštěna..."
    while IFS= read -r folder; do
        process_gem_folder "$folder"
    done < <(get_gem_folders)
    log_color "$GREEN" "Automatická aktualizace dokončena."
}

# ----- HLAVNÍ MENU -----
main() {
    if [[ "$1" == "--auto-update" ]]; then
        auto_update
        exit 0
    fi
    
    load_config
    ensure_dependencies
    
    while true; do
        echo -e "\n${CYAN}=======================================================${NC}"
        echo -e "${CYAN} 🧠 GEM KNOWLEDGE MANAGER: PRO EDITION (Linux)${NC}"
        echo -e "${CYAN}=======================================================${NC}"
        echo " [1] Smart Update (inkrementální záloha) – jedna složka"
        echo " [2] Sloučit PDF v jedné složce (qpdf)"
        echo " [3] ZPRACOVAT VŠECHNY GEM SLOŽKY (paralelně)"
        echo " [4] Vybrat konkrétní GEM složku k zpracování"
        echo " [5] Zobrazit přehled všech GEM složek"
        echo " [6] Export přehledu do HTML/CSV"
        echo " [7] SMART ANALÝZA (automatické určení nepatřících souborů)"
        echo " [8] PŘIDAT NOVÉHO ROBOTA (z libovolné složky)"
        echo " [9] EXPORTOVAT BALÍČEK PRO PŘENOS (LLM / vlastní AI)"
        echo " [10] Správa záloh (ruční záloha vybraného robota)"
        echo " [11] Nastavit plánovanou úlohu (cron, denně v 2:00)"
        echo " [12] Změnit kořenovou cestu"
        echo " [13] HLOUBKOVÝ AUDIT SLOŽKY (detailní MD report)"
        echo " [14] KOMPLEXNÍ ANALÝZA + KLASIFIKACE (včetně doporučení)"
        echo " [Q] Ukončit aplikaci"
        echo -e "-------------------------------------------------------"
        read -p "Vyberte akci: " choice
        
        case "$choice" in
            1) folder=$(select_gem_folder) && [[ -n "$folder" ]] && process_gem_folder "$folder" ;;
            2) folder=$(select_gem_folder) && [[ -n "$folder" ]] && merge_pdf "$folder" ;;
            3) process_all_gem_folders_parallel ;;
            4) folder=$(select_gem_folder) && [[ -n "$folder" ]] && process_gem_folder "$folder" ;;
            5) show_overview ;;
            6) export_report ;;
            7) folder=$(select_gem_folder) && [[ -n "$folder" ]] && smart_analyze_and_clean "$folder" ;;
            8) add_new_gem_robot ;;
            9) folder=$(select_gem_folder) && [[ -n "$folder" ]] && export_package "$folder" ;;
            10) folder=$(select_gem_folder) && [[ -n "$folder" ]] && backup_gem_folder "$folder" ;;
            11) schedule_cron ;;
            12) set_root_path ;;
            13) folder=$(select_gem_folder) && [[ -n "$folder" ]] && deep_audit_folder "$folder" ;;
            14) folder=$(select_gem_folder) && [[ -n "$folder" ]] && deep_analyze_and_classify "$folder" ;;
            q|Q) log_color "$CYAN" "Ukončuji..."; exit 0 ;;
            *) log_color "$RED" "Neplatná volba." ;;
        esac
    done
}

main "$@"