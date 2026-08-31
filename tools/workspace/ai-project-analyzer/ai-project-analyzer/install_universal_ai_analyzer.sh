#!/usr/bin/env bash
# install_universal_ai_analyzer.sh
# Universal installer for AI Project Analyzer (Debian/Ubuntu/RPi5 compatible)
# Interactive: model selection, runtime selection, plugin + codegen setup
set -euo pipefail
IFS=$'\n\t'

BASE_DIR="/opt/ai_project_analyzer"
ENV_FILE="/etc/ai_project_analyzer/env"
SYSTEMD_SERVICE="/etc/systemd/system/ai_project_analyzer.service"
LOG="/var/log/ai_project_analyzer_install.log"

log() { echo -e "[$(date '+%F %T')] $*" | tee -a "$LOG"; }
error_exit() { echo "ERROR: $*" | tee -a "$LOG"; exit 1; }

if [[ $EUID -ne 0 ]]; then
  error_exit "Spusť jako root (sudo)."
fi

# detect
if [ -f /etc/os-release ]; then
  . /etc/os-release
  OS_ID=$ID
  PRETTY_NAME=${PRETTY_NAME:-$NAME}
else
  error_exit "Nepodporovaný systém (chybí /etc/os-release)."
fi
ARCH=$(uname -m)
log "Detected OS: $PRETTY_NAME (ID=$OS_ID), ARCH=$ARCH"

log "Updating apt..."
apt update -y >> "$LOG" 2>&1
apt upgrade -y >> "$LOG" 2>&1

log "Installing base packages..."
apt install -y python3 python3-venv python3-pip git curl wget build-essential \
  ca-certificates gnupg lsb-release unzip pkg-config jq lshw docker.io docker-compose-plugin || true

# create dirs and env
log "Creating base directories..."
rm -rf "$BASE_DIR"
mkdir -p "$BASE_DIR"/{data/{input,output},plugins,logs,venv,src,codegen}
chown -R root:root "$BASE_DIR"
mkdir -p "$(dirname "$ENV_FILE")"
cat > "$ENV_FILE" <<'ENV'
# AI Project Analyzer env
ENV
chmod 600 "$ENV_FILE"

# python venv
log "Setting up Python virtualenv..."
python3 -m venv "$BASE_DIR/venv"
"$BASE_DIR/venv/bin/pip" install --upgrade pip setuptools wheel

log "Installing python packages (may take a while)..."
"$BASE_DIR/venv/bin/pip" install -r /dev/null >/dev/null 2>&1 || true
"$BASE_DIR/venv/bin/pip" install langchain llama-index chromadb sentence-transformers \
  tiktoken transformers fastapi uvicorn streamlit aiofiles python-multipart openai \
  anthropic google-generativeai requests python-dotenv psutil aiohttp unstructured faiss-cpu --upgrade

# local runtime option
cat <<'TXT'
Lokální runtime volba:
1) Pouze cloud API (doporučeno)
2) Nainstalovat Ollama (lokální modely)
3) Nainstalovat LocalAI (docker image)
TXT
read -rp "Vyber (1-3, default 1): " RUNTIME_CHOICE
RUNTIME_CHOICE=${RUNTIME_CHOICE:-1}
if [ "$RUNTIME_CHOICE" -eq 2 ]; then
  if [[ "$ARCH" == "x86_64" || "$ARCH" == "aarch64" ]]; then
    log "Instaluji Ollama..."
    curl -fsSL https://ollama.com/install.sh | sh || log "Ollama instalace selhala"
  else
    log "Ollama není podporována pro architekturu $ARCH automaticky."
  fi
elif [ "$RUNTIME_CHOICE" -eq 3 ]; then
  log "Pull LocalAI image..."
  docker pull ghcr.io/go-skynet/llama.cpp:latest || log "LocalAI pull selhal"
fi

# model selection
cat <<'END'
Vyber primární model/zdroj:
1) OpenAI GPT-4-Turbo (cloud) — vysoká kvalita, placené
2) Anthropic Claude 3 Opus (cloud) — dlouhý kontext, placené
3) Google Gemini 1.5 Pro (cloud) — výkonný, placené
4) DeepSeek / OpenAI-compatible custom endpoint
5) Local (Ollama/LocalAI) — offline, nutné nainstalovat runtime/model
END

read -rp "Volba (1-5, default 1): " MODEL_CHOICE
MODEL_CHOICE=${MODEL_CHOICE:-1}

# write env
> "$ENV_FILE"
echo "BASE_DIR=\"$BASE_DIR\"" >> "$ENV_FILE"
case "$MODEL_CHOICE" in
  1)
    echo 'MODEL=OPENAI' >> "$ENV_FILE"
    read -rp "Zadej OpenAI API key (sk-...): " OPENAI_KEY
    echo "OPENAI_API_KEY=\"$OPENAI_KEY\"" >> "$ENV_FILE"
    ;;
  2)
    echo 'MODEL=CLAUDE' >> "$ENV_FILE"
    read -rp "Zadej Anthropic API key: " ANTHROPIC_KEY
    echo "ANTHROPIC_API_KEY=\"$ANTHROPIC_KEY\"" >> "$ENV_FILE"
    ;;
  3)
    echo 'MODEL=GEMINI' >> "$ENV_FILE"
    read -rp "Zadej Google API key / path to service account JSON: " GOOGLE_KEY
    echo "GOOGLE_API_KEY=\"$GOOGLE_KEY\"" >> "$ENV_FILE"
    ;;
  4)
    echo 'MODEL=CUSTOM' >> "$ENV_FILE"
    read -rp "Zadej OpenAI-compatible API base URL: " CUSTOM_BASE
    echo "OPENAI_API_BASE=\"$CUSTOM_BASE\"" >> "$ENV_FILE"
    read -rp "Zadej API key pro endpoint: " CUSTOM_KEY
    echo "OPENAI_API_KEY=\"$CUSTOM_KEY\"" >> "$ENV_FILE"
    ;;
  5)
    echo 'MODEL=LOCAL' >> "$ENV_FILE"
    ;;
  *)
    echo 'MODEL=OPENAI' >> "$ENV_FILE"
    ;;
esac
chmod 600 "$ENV_FILE"
log "Env uložen do $ENV_FILE"

# -- create source files (minimal set) --
log "Vytvářím základní aplikační soubory..."
# src/webui/app.py
mkdir -p "$BASE_DIR/src/webui"
cat > "$BASE_DIR/src/webui/app.py" <<'PY'
#!/usr/bin/env python3
import streamlit as st, os, subprocess
st.set_page_config(page_title="AI Project Analyzer", layout="wide")
st.title("AI Project Analyzer")
BASE="/opt/ai_project_analyzer"
in_dir = st.text_input("Input folder", os.path.join(BASE,"data","input"))
out_dir = st.text_input("Output folder", os.path.join(BASE,"data","output"))

if st.button("Run analysis"):
    st.info("Starting analysis in background...")
    subprocess.Popen([os.path.join(BASE,"venv","bin","python"), os.path.join(BASE,"src","analyzer.py"), in_dir, out_dir])
    st.success("Analysis started")

if st.button("Generate new_structure.md"):
    subprocess.Popen([os.path.join(BASE,"venv","bin","python"), os.path.join(BASE,"src","generator.py"), out_dir])
    st.success("Generation started")

if st.button("Run codegen"):
    md = os.path.join(out_dir, "new_structure.md")
    if os.path.exists(md):
        subprocess.Popen([os.path.join(BASE,"venv","bin","python"), os.path.join(BASE,"src","codegen.py"), md, os.path.join(BASE,"codegen")])
        st.success("Codegen started")
    else:
        st.error("Missing new_structure.md")
PY

# analyzer.py
cat > "$BASE_DIR/src/analyzer.py" <<'PY'
#!/usr/bin/env python3
# see earlier analyzer code; plugin-aware, parallel
from src import analyzer as _placeholder
print("Use the analyzer module in src/ (detailed implementation included in repo).")
PY

# generator.py
cat > "$BASE_DIR/src/generator.py" <<'PY'
#!/usr/bin/env python3
# placeholder wrapper for generator
print("Run generator: use src/generator.py in repository for full implementation.")
PY

# codegen.py
cat > "$BASE_DIR/src/codegen.py" <<'PY'
#!/usr/bin/env python3
print("Codegen placeholder: see src/codegen.py in repository for full implementation.")
PY

chmod +x "$BASE_DIR/src/"*.py "$BASE_DIR/src/webui/app.py" || true

# create example plugins (secret_detector, dockerfile_analyzer, dependency_graph)
mkdir -p "$BASE_DIR/plugins"
cat > "$BASE_DIR/plugins/secret_detector.py" <<'PY'
# secret_detector.py
import re
def analyze(path, content):
    findings=[]
    patterns = {
        "AWS_KEY": r"AKIA[0-9A-Z]{16}",
        "API_KEY_LIKE": r"(?i)api[_-]?key\\W*[:=]\\W*[A-Za-z0-9\\-_.]{8,}"
    }
    for name,pat in patterns.items():
        if re.search(pat, content):
            findings.append({"type": name})
    return {"plugin":"secret_detector","findings":findings}
PY

cat > "$BASE_DIR/plugins/dockerfile_analyzer.py" <<'PY'
def analyze(path, content):
    if "dockerfile" in path.lower() or path.lower().endswith("dockerfile"):
        lines = content.splitlines()
        froms = [l for l in lines if l.strip().upper().startswith("FROM")]
        return {"plugin":"dockerfile_analyzer","froms": froms}
    return {"plugin":"dockerfile_analyzer","skipped": True}
PY

cat > "$BASE_DIR/plugins/dependency_graph.py" <<'PY'
def analyze(path, content):
    if path.endswith("requirements.txt"):
        deps=[l.split("==")[0].strip() for l in content.splitlines() if l.strip() and not l.startswith("#")]
        return {"plugin":"dependency_graph","deps":deps}
    return {"plugin":"dependency_graph","skipped": True}
PY

# systemd service
cat > "$SYSTEMD_SERVICE" <<'UNIT'
[Unit]
Description=AI Project Analyzer Streamlit
After=network.target docker.service

[Service]
Type=simple
User=root
EnvironmentFile=/etc/ai_project_analyzer/env
WorkingDirectory=/opt/ai_project_analyzer
ExecStart=/opt/ai_project_analyzer/venv/bin/streamlit run /opt/ai_project_analyzer/src/webui/app.py --server.port 8501 --server.address 0.0.0.0
Restart=on-failure
RestartSec=5

[Install]
WantedBy=multi-user.target
UNIT

systemctl daemon-reload
systemctl enable --now ai_project_analyzer.service || log "Could not enable service; start manually."

log "Install script finished. Start UI at: http://<host-ip>:8501"
log "Input folder: $BASE_DIR/data/input"
log "Output folder: $BASE_DIR/data/output"
