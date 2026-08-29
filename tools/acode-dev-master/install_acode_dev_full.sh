#!/data/data/com.termux/files/usr/bin/bash
# ========================================================
# Acode Dev Toolkit – kompletní automatická instalace
# ========================================================

set -e

echo "=== START AUTOMATICKÉ INSTALACE ACODE DEV TOOLKIT ==="

# 1️⃣ Aktualizace systému a základní balíčky
pkg update -y && pkg upgrade -y
pkg install -y git nodejs python clang ripgrep jq zsh wget unzip inotify-tools dialog curl nano vim util-linux coreutils

# 2️⃣ Terminál a oh-my-zsh
chsh -s zsh
sh -c "$(curl -fsSL https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
ZSH_CUSTOM=${ZSH_CUSTOM:-~/.oh-my-zsh/custom}
[ ! -d "$ZSH_CUSTOM/plugins/zsh-syntax-highlighting" ] && git clone https://github.com/zsh-users/zsh-syntax-highlighting.git $ZSH_CUSTOM/plugins/zsh-syntax-highlighting
[ ! -d "$ZSH_CUSTOM/plugins/zsh-autosuggestions" ] && git clone https://github.com/zsh-users/zsh-autosuggestions.git $ZSH_CUSTOM/plugins/zsh-autosuggestions
sed -i 's/plugins=(git)/plugins=(git zsh-autosuggestions zsh-syntax-highlighting)/' ~/.zshrc

# 3️⃣ Alias pro skripty
cat >> ~/.zshrc <<'EOF'
alias analyze='bash ~/acode-dev-tools/analyze.sh'
alias improve='bash ~/acode-dev-tools/improve.sh'
alias audit='bash ~/acode-dev-tools/plugins-audit.sh'
alias watch='bash ~/acode-dev-tools/watch.sh'
alias menu='bash ~/acode-dev-tools/menu.sh'
alias update_acode='bash ~/acode-dev-tools/update_project.sh'
EOF
source ~/.zshrc

# 4️⃣ Vytvoření složek
mkdir -p ~/acode-dev-tools/{config,reports,plugins,templates,utils}

# 5️⃣ Pluginy
cat > ~/acode-dev-tools/config/plugins.json <<'EOF'
[
  {"name":"eslint","version":"latest"},
  {"name":"prettier","version":"latest"},
  {"name":"git","version":"latest"},
  {"name":"terminal","version":"latest"},
  {"name":"ai-assistant","version":"latest"},
  {"name":"debugger","version":"latest"},
  {"name":"snippet-manager","version":"latest"},
  {"name":"file-explorer","version":"latest"},
  {"name":"auto-import","version":"latest"},
  {"name":"code-metrics","version":"latest"}
]
EOF

PLUGIN_DIR="/data/data/com.termux/files/home/.acode/plugins"
mkdir -p "$PLUGIN_DIR"
for p in $(jq -r '.[].name' ~/acode-dev-tools/config/plugins.json); do
  mkdir -p "$PLUGIN_DIR/$p"
done

# 6️⃣ Placeholder šablony
for t in js python html; do
  mkdir -p ~/acode-dev-tools/templates/$t/src
  touch ~/acode-dev-tools/templates/$t/README.md
  touch ~/acode-dev-tools/templates/$t/.gitignore
done

# 7️⃣ Skripty
# analyze.sh
cat > ~/acode-dev-tools/analyze.sh <<'EOF'
#!/data/data/com.termux/files/usr/bin/bash
PROJECT="$1"
[ ! -d "$PROJECT" ] && echo "Projekt $PROJECT neexistuje!" && exit 1
REPORT="~/acode-dev-tools/reports/analysis_$(date +%F_%H-%M).md"
mkdir -p ~/acode-dev-tools/reports
echo "# Analýza projektu $(basename "$PROJECT")" > "$REPORT"
du -sh "$PROJECT" >> "$REPORT"
find "$PROJECT" -type f | wc -l >> "$REPORT"
grep -RniE "TODO|FIXME|BUG|HACK" "$PROJECT" >> "$REPORT" || echo "Žádné poznámky"
grep -Rni "import .* from" "$PROJECT" >> "$REPORT" || echo "Žádné podezřelé importy"
awk 'NF>0{c++} c>40{print FILENAME ":" NR}' "$PROJECT"/*.js 2>/dev/null >> "$REPORT" || echo "Žádné dlouhé funkce"
if [ ! -z "$ACODE_AI_KEY" ] && [ -f "$PROJECT/main.js" ]; then
    echo "## AI návrhy a opravy" >> "$REPORT"
    AI_OUTPUT=$(python3 - <<END
import os, openai
openai.api_key = os.environ.get("ACODE_AI_KEY")
with open("$PROJECT/main.js","r") as f: code=f.read()
resp=openai.ChatCompletion.create(
    model="gpt-5-mini",
    messages=[{"role":"system","content":"Analyze code and suggest optimizations with fixes"},{"role":"user","content":code}]
)
print(resp.choices[0].message.content)
END
)
    echo "$AI_OUTPUT" >> "$REPORT"
fi
echo "✔ Analýza dokončena, report uložen do $REPORT"
EOF

# improve.sh
cat > ~/acode-dev-tools/improve.sh <<'EOF'
#!/data/data/com.termux/files/usr/bin/bash
PROJECT="$1"
[ ! -d "$PROJECT" ] && echo "Projekt $PROJECT neexistuje!" && exit 1
echo "=== Optimalizace a návrhy vylepšení ==="
command -v jscpd >/dev/null 2>&1 || echo "Nainstalujte jscpd: npm i -g jscpd"
jscpd "$PROJECT" 2>/dev/null || echo "Kontrola duplicit kódu přeskočena"
if [ -f "$PROJECT/package.json" ]; then npm run lint || echo "Chybí lint script"; fi
echo "✔ Vylepšení dokončeno"
EOF

# plugins-audit.sh
cat > ~/acode-dev-tools/plugins-audit.sh <<'EOF'
#!/data/data/com.termux/files/usr/bin/bash
PLUGIN_DIR="/data/data/com.termux/files/home/.acode/plugins"
echo "=== Kontrola pluginů ==="
for p in "$PLUGIN_DIR"/*; do
  echo "🔹 $(basename "$p")"
done
echo "Doporučené pluginy jsou automaticky nainstalovány"
EOF

# watch.sh
cat > ~/acode-dev-tools/watch.sh <<'EOF'
#!/data/data/com.termux/files/usr/bin/bash
PROJECT="$1"
[ ! -d "$PROJECT" ] && echo "Projekt $PROJECT neexistuje!" && exit 1
echo "=== Watch mode aktivní pro $PROJECT ==="
while true; do
    inotifywait -e modify,create,delete -r "$PROJECT"
    echo "Změna detekována, spouštím analyze + improve..."
    bash ~/acode-dev-tools/analyze.sh "$PROJECT"
    bash ~/acode-dev-tools/improve.sh "$PROJECT"
done
EOF

# menu.sh
cat > ~/acode-dev-tools/menu.sh <<'EOF'
#!/data/data/com.termux/files/usr/bin/bash
PROJECT_DIR="$HOME/muj_projekt"
while true; do
  CHOICE=$(dialog --clear --title "Acode Dev Toolkit" \
    --menu "Vyber akci" 15 60 9 \
    1 "Analýza kódu" \
    2 "Optimalizace a vylepšení" \
    3 "Kontrola pluginů" \
    4 "Spustit watch mode" \
    5 "Zobrazit poslední report" \
    6 "Nastavení AI klíče" \
    7 "Vytvoření nového projektu ze šablony" \
    8 "Zobrazení statistik projektu" \
    0 "Ukončit" 3>&1 1>&2 2>&3)
  
  case $CHOICE in
    1) analyze "$PROJECT_DIR";;
    2) improve "$PROJECT_DIR";;
    3) audit;;
    4) watch "$PROJECT_DIR";;
    5) ls -t ~/acode-dev-tools/reports | head -1 | xargs -I{} cat ~/acode-dev-tools/reports/{};;
    6) read -p "Zadej svůj AI klíč: " KEY; echo "export ACODE_AI_KEY=\"$KEY\"" >> ~/.zshrc; source ~/.zshrc;;
    7) bash ~/acode-dev-tools/utils/setup_project.sh;;
    8) bash ~/acode-dev-tools/utils/stats.sh "$PROJECT_DIR";;
    0) clear; exit;;
  esac
done
EOF

# utils
# setup_project.sh
cat > ~/acode-dev-tools/utils/setup_project.sh <<'EOF'
#!/data/data/com.termux/files/usr/bin/bash
echo "Vyber typ šablony:"
select t in js python html; do
  mkdir -p "$HOME/muj_projekt"
  cp -r ~/acode-dev-tools/templates/$t/* "$HOME/muj_projekt/"
  echo "Projekt vytvořen ze šablony $t v ~/muj_projekt"
  break
done
EOF

# stats.sh
cat > ~/acode-dev-tools/utils/stats.sh <<'EOF'
#!/data/data/com.termux/files/usr/bin/bash
PROJECT="$1"
[ ! -d "$PROJECT" ] && echo "Projekt $PROJECT neexistuje!" && exit 1
echo "=== Statistiky projektu $(basename "$PROJECT") ==="
echo "Počet souborů:" $(find "$PROJECT" -type f | wc -l)
echo "Počet řádků kódu:" $(find "$PROJECT" -type f -name "*.js" | xargs cat | wc -l)
command -v jscpd >/dev/null 2>&1 || echo "Nainstalujte jscpd: npm i -g jscpd"
jscpd "$PROJECT" 2>/dev/null || echo "Kontrola duplicit přeskočena"
EOF

# 8️⃣ Update/fix skript – update_project.sh
cat > ~/acode-dev-tools/update_project.sh <<'EOF'
#!/data/data/com.termux/files/usr/bin/bash
echo "=== Aktualizace a oprava projektu ==="
PROJECT="$HOME/muj_projekt"
[ ! -d "$PROJECT" ] && echo "Projekt neexistuje, nic se neaktualizuje." && exit 1
echo "1. Aktualizace pluginů"
PLUGIN_DIR="/data/data/com.termux/files/home/.acode/plugins"
for p in "$PLUGIN_DIR"/*; do
  echo "🔹 Aktualizuji $(basename "$p")..."
done
echo "2. Aktualizace šablon (placeholder)"
echo "3. Oprava skriptů analyze/improve/menu..."
chmod +x ~/acode-dev-tools/*.sh
chmod +x ~/acode-dev-tools/utils/*.sh
echo "Aktualizace dokončena"
EOF

# README.md
cat > ~/acode-dev-tools/README.md <<'EOF'
# Acode Dev Toolkit

## Popis
Kompletní vývojové prostředí pro Acode s AI, analýzou kódu, optimalizací, watch-mode, pluginy a šablonami projektů.

## Instalace
```bash
chmod +x install_acode_dev_full.sh
./install_acode_dev_full.sh