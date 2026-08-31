#!/bin/bash
set -e

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
LOG="$ROOT/logs/repair.log"
mkdir -p "$ROOT/logs"

log(){ echo "[GEN $(date '+%H:%M:%S')] $1" | tee -a "$LOG"; }

log "▶ Spouštím auto-generaci chybějících souborů"

# ===============================
# CORE FILES
# ===============================
declare -A CORE_FILES

CORE_FILES["core/env.sh"]='
#!/bin/bash
export ULTRA_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
export ULTRA_VERSION="v16 FINAL"
export PATH="$ULTRA_ROOT/bin:$PATH"
'

CORE_FILES["core/logger.sh"]='
#!/bin/bash
log(){ echo "[ULTRA] $1"; }
warn(){ echo "[WARN] $1" >&2; }
err(){ echo "[ERR] $1" >&2; }
'

CORE_FILES["core/repair.sh"]='
#!/bin/bash
echo "[REPAIR] Kontrola oprávnění a struktury"
chmod -R u+rw "$ULTRA_ROOT" || true
'

CORE_FILES["core/generate_registry.sh"]='
#!/bin/bash
REG="$ULTRA_ROOT/registry/modules.json"
mkdir -p "$(dirname "$REG")"
echo "{}" > "$REG"
'

# ===============================
# MODULE TEMPLATE
# ===============================
generate_module() {
  MOD="$1"
  DIR="$ROOT/modules/$MOD"
  FILE="$DIR/install.sh"

  if [ ! -f "$FILE" ]; then
    log "➕ Generuji modul $MOD"
    mkdir -p "$DIR"
    cat > "$FILE" <<EOF
#!/bin/bash
echo "[MODULE:$MOD] Instalace spuštěna"
EOF
    chmod +x "$FILE"
  fi
}

# ===============================
# WEB
# ===============================
if [ ! -f "$ROOT/web/service.sh" ]; then
  log "➕ Generuji web/service.sh"
  cat > "$ROOT/web/service.sh" <<'EOF'
#!/bin/bash
echo "[WEB] Spuštění web dashboardu"
python3 app.py
EOF
  chmod +x "$ROOT/web/service.sh"
fi

if [ ! -f "$ROOT/web/app.py" ]; then
  log "➕ Generuji web/app.py"
  cat > "$ROOT/web/app.py" <<'EOF'
from flask import Flask
app = Flask(__name__)

@app.route("/")
def index():
    return "ULTRA Web Dashboard running"

app.run(host="0.0.0.0", port=8080)
EOF
fi

# ===============================
# GUI
# ===============================
if [ ! -f "$ROOT/gui/installer.html" ]; then
  log "➕ Generuji GUI installer"
  cat > "$ROOT/gui/installer.html" <<'EOF'
<!DOCTYPE html>
<html>
<head>
<meta name="viewport" content="width=device-width">
<title>ULTRA Installer</title>
<style>
body{background:#0b0b0b;color:#00ff88;font-family:monospace}
button{padding:12px;margin:8px}
</style>
</head>
<body>
<h1>ULTRA v16 FINAL</h1>
<p>Vyber profil instalace</p>
<button onclick="fetch('/core')">CORE</button>
<button onclick="fetch('/full')">FULL</button>
<button onclick="fetch('/pentest')">PENTEST</button>
</body>
</html>
EOF
fi

# ===============================
# APPLY CORE FILES
# ===============================
for FILE in "${!CORE_FILES[@]}"; do
  TARGET="$ROOT/$FILE"
  if [ ! -f "$TARGET" ]; then
    log "➕ Generuji $FILE"
    mkdir -p "$(dirname "$TARGET")"
    echo "${CORE_FILES[$FILE]}" > "$TARGET"
    chmod +x "$TARGET"
  fi
done

# ===============================
# MODULES
# ===============================
MODULES=(ai android web pentest plugins system docker updater marketplace)

for M in "${MODULES[@]}"; do
  generate_module "$M"
done

log "✅ Auto-generace dokončena"
