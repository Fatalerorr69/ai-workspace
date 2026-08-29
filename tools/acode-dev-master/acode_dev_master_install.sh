#!/usr/bin/env bash
set -e

### ===============================
### KONFIGURACE
### ===============================
BASE="$HOME/acode-dev-tools"
BIN="$HOME/.local/bin"
CACHE="$HOME/.cache/acode-dev"
REPO_URL="https://github.com/Fatalerorr69/acode-dev-tools"

mkdir -p "$BASE" "$BIN" "$CACHE"

log() {
  echo "[ACODE-DEV] $1"
}

### ===============================
### DETEKCE PROSTŘEDÍ
### ===============================
if command -v pkg >/dev/null; then
  PKG_INSTALL="pkg install -y"
elif command -v apt >/dev/null; then
  PKG_INSTALL="apt install -y"
else
  PKG_INSTALL=""
fi

### ===============================
### ZÁKLADNÍ NÁSTROJE
### ===============================
for p in git curl dialog unzip nodejs npm inotify-tools nc; do
  command -v $p >/dev/null || {
    [ -n "$PKG_INSTALL" ] && $PKG_INSTALL $p || log "⚠️ $p nenainstalován"
  }
done

### ===============================
### STRUKTURA
### ===============================
mkdir -p \
"$BASE"/{core,ai,gui,web,watcher,plugins,docs,update}

### ===============================
### CORE
### ===============================
cat > "$BASE/core/env.sh" <<'EOF'
export ACODE_DEV_HOME="$HOME/acode-dev-tools"
export ACODE_CACHE="$HOME/.cache/acode-dev"
export PATH="$HOME/.local/bin:$PATH"
EOF

cat > "$BASE/core/plugin_loader.sh" <<'EOF'
for p in ~/acode-dev-tools/plugins/*.sh; do
  [ -x "$p" ] && source "$p"
done
EOF

### ===============================
### AI KONFIGURACE
### ===============================
cat > "$BASE/ai/ai_config.env" <<'EOF'
AI_MODEL_LIGHT=phi
AI_MODEL_FULL=codellama:7b
EOF

cat > "$BASE/ai/install_ai.sh" <<'EOF'
#!/usr/bin/env bash
if ! command -v ollama >/dev/null; then
  curl -fsSL https://ollama.com/install.sh | sh
fi
ollama pull phi
ollama pull codellama:7b
EOF
chmod +x "$BASE/ai/install_ai.sh"

### ===============================
### AI MODULY
### ===============================
cat > "$BASE/ai/ai_analyze.sh" <<'EOF'
#!/usr/bin/env bash
ollama run phi "Analyze project structure and code quality."
EOF
chmod +x "$BASE/ai/ai_analyze.sh"

cat > "$BASE/ai/ai_autofix.sh" <<'EOF'
#!/usr/bin/env bash
BACKUP=".ai_backup_$(date +%s)"
cp -r . "$BACKUP"
ollama run codellama:7b "Generate unified diff patch." > fix.patch
patch -p1 < fix.patch
EOF
chmod +x "$BASE/ai/ai_autofix.sh"

### ===============================
### WATCHER
### ===============================
cat > "$BASE/watcher/watch_ai.sh" <<'EOF'
#!/usr/bin/env bash
inotifywait -m -e modify . | while read; do
  bash ~/acode-dev-tools/ai/ai_analyze.sh
done
EOF
chmod +x "$BASE/watcher/watch_ai.sh"

### ===============================
### WEB GUI (PLNOHODNOTNÉ)
### ===============================
cat > "$BASE/web/server.sh" <<'EOF'
#!/usr/bin/env bash
PORT=8686
while true; do
{
echo "HTTP/1.1 200 OK"
echo "Content-Type: text/html"
echo ""
cat <<HTML
<html>
<head>
<title>Acode Dev Toolkit</title>
<style>
body{background:#0f111a;color:#eaeaea;font-family:monospace}
button{padding:10px;margin:5px}
</style>
</head>
<body>
<h2>Acode Dev Toolkit</h2>
<button onclick="run('analyze')">AI Analyze</button>
<button onclick="run('autofix')">AI AutoFix</button>
<button onclick="run('watch')">Watch</button>
<pre id="out"></pre>
<script>
function run(cmd){
 fetch('/'+cmd).then(r=>r.text()).then(t=>out.innerText=t)
}
</script>
</body>
</html>
HTML
} | nc -l -p $PORT
done
EOF
chmod +x "$BASE/web/server.sh"

### ===============================
### TUI GUI
### ===============================
cat > "$BASE/gui/tui.sh" <<'EOF'
#!/usr/bin/env bash
source ~/acode-dev-tools/core/plugin_loader.sh
dialog --menu "Acode Dev Toolkit" 20 70 10 \
1 "AI Analyze" \
2 "AI AutoFix" \
3 "Watch Mode" \
4 "Web GUI" \
0 "Exit" 3>&1 1>&2 2>&3 | {
read c
case $c in
1) bash ~/acode-dev-tools/ai/ai_analyze.sh ;;
2) bash ~/acode-dev-tools/ai/ai_autofix.sh ;;
3) bash ~/acode-dev-tools/watcher/watch_ai.sh ;;
4) bash ~/acode-dev-tools/web/server.sh ;;
esac
}
EOF
chmod +x "$BASE/gui/tui.sh"

### ===============================
### GITHUB UPDATER
### ===============================
cat > "$BASE/update/update.sh" <<'EOF'
#!/usr/bin/env bash
cd ~/acode-dev-tools
git pull origin main
EOF
chmod +x "$BASE/update/update.sh"

### ===============================
### ALIAS
### ===============================
grep -q "alias ai=" ~/.bashrc || echo "alias ai='bash ~/acode-dev-tools/gui/tui.sh'" >> ~/.bashrc

log "✅ Instalace dokončena"
log "➡ Spusť: ai"
log "🌐 Web GUI: http://localhost:8686"