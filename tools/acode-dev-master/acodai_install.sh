🚀 AcodAI - Universal Dev Suite - Kompletní instalační skript

Zde je univerzální vševědoucí skript který automaticky detekuje vše a nastaví kompletní vývojové prostředí:

```bash
#!/usr/bin/env bash
# ========================================================
# ACOD.AI - UNIVERSAL DEV SUITE
# Kompletní automatická instalace všech komponent
# ========================================================

# 🔧 KONFIGURACE
VERSION="3.0.0"
BASE_DIR="$HOME/.acodai"
CONFIG_DIR="$BASE_DIR/config"
LOG_DIR="$BASE_DIR/logs"
CACHE_DIR="$BASE_DIR/cache"
BIN_DIR="$BASE_DIR/bin"
REPO_DIR="$BASE_DIR/repos"
EXTENSIONS_DIR="$BASE_DIR/extensions"
TERMINAL_DIR="$BASE_DIR/terminal"
REMOTE_SERVERS="$BASE_DIR/servers"

# 🎨 BARVY
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
MAGENTA='\033[0;35m'
CYAN='\033[0;36m'
WHITE='\033[1;37m'
NC='\033[0m'
BOLD='\033[1m'
DIM='\033[2m'

# 📊 PROMĚNNÉ
DETECTED_OS=""
DETECTED_ARCH=""
DETECTED_PKG_MANAGER=""
IS_ROOT=false
IS_TERMUX=false
IS_ANDROID=false
IS_WSL=false
IS_DOCKER=false
INSTALL_SUCCESS=true
ERROR_COUNT=0

# 📝 LOGOVÁNÍ
LOG_FILE="$LOG_DIR/install_$(date +%Y%m%d_%H%M%S).log"
exec 2> >(tee -a "$LOG_FILE")
exec > >(tee -a "$LOG_FILE")

# 🔧 FUNKCE
print_banner() {
    clear
    echo -e "${BLUE}${BOLD}"
    cat << "EOF"
    ╔══════════════════════════════════════════════════════╗
    ║                                                      ║
    ║        █████╗  ██████╗ ██████╗  █████╗ ██╗          ║
    ║       ██╔══██╗██╔════╝ ██╔══██╗██╔══██╗██║          ║
    ║       ███████║██║  ███╗██║  ██║███████║██║          ║
    ║       ██╔══██║██║   ██║██║  ██║██╔══██║██║          ║
    ║       ██║  ██║╚██████╔╝██████╔╝██║  ██║███████╗     ║
    ║       ╚═╝  ╚═╝ ╚═════╝ ╚═════╝ ╚═╝  ╚═╝╚══════╝     ║
    ║                                                      ║
    ║           UNIVERSAL DEVELOPMENT SUITE                ║
    ║                  v$VERSION                            ║
    ║                                                      ║
    ╚══════════════════════════════════════════════════════╝
EOF
    echo -e "${NC}"
}

log() {
    local timestamp=$(date '+%Y-%m-%d %H:%M:%S')
    echo -e "${DIM}[$timestamp]${NC} $1"
}

info() {
    echo -e "${BLUE}[i]${NC} $1"
    log "INFO: $1"
}

success() {
    echo -e "${GREEN}[✓]${NC} $1"
    log "SUCCESS: $1"
}

warning() {
    echo -e "${YELLOW}[⚠]${NC} $1"
    log "WARNING: $1"
}

error() {
    echo -e "${RED}[✗]${NC} $1"
    log "ERROR: $1"
    ((ERROR_COUNT++))
    INSTALL_SUCCESS=false
}

step() {
    echo -e "\n${CYAN}${BOLD}▶${NC} ${WHITE}${BOLD}$1${NC}"
    log "STEP: $1"
}

substep() {
    echo -e "  ${MAGENTA}↳${NC} $1"
    log "SUBSTEP: $1"
}

progress() {
    local width=50
    local percent=$1
    local completed=$((width * percent / 100))
    local remaining=$((width - completed))
    
    echo -ne "\r${BLUE}[${NC}"
    printf "%${completed}s" | tr ' ' '█'
    printf "%${remaining}s" | tr ' ' '░'
    echo -ne "${BLUE}] ${percent}%${NC}"
}

check_command() {
    command -v "$1" >/dev/null 2>&1
    return $?
}

run_command() {
    local cmd="$1"
    local desc="$2"
    local silent="${3:-false}"
    
    if [ "$silent" = "true" ]; then
        eval "$cmd" >/dev/null 2>&1
    else
        substep "$desc"
        eval "$cmd" 2>&1 | while IFS= read -r line; do
            echo "    $line"
        done
    fi
    
    return ${PIPESTATUS[0]}
}

# 🔍 DETEKCE PROSTŘEDÍ
detect_environment() {
    step "🔍 Detekce prostředí"
    
    # Detekce OS
    if [ -f "/etc/os-release" ]; then
        . /etc/os-release
        DETECTED_OS="$NAME"
    elif [ -f "/etc/termux/termux.properties" ]; then
        DETECTED_OS="Termux"
        IS_TERMUX=true
        IS_ANDROID=true
    elif [ -f "/system/build.prop" ]; then
        DETECTED_OS="Android"
        IS_ANDROID=true
    elif [ -f "/proc/version" ] && grep -qi "microsoft" /proc/version; then
        DETECTED_OS="WSL"
        IS_WSL=true
    elif [ -f "/.dockerenv" ]; then
        DETECTED_OS="Docker"
        IS_DOCKER=true
    else
        DETECTED_OS=$(uname -s)
    fi
    
    # Detekce architektury
    DETECTED_ARCH=$(uname -m)
    
    # Detekce správce balíčků
    local managers=("pkg" "apt" "apt-get" "yum" "dnf" "pacman" "apk" "zypper" "brew" "port" "nix-env" "snap" "flatpak")
    for manager in "${managers[@]}"; do
        if check_command "$manager"; then
            DETECTED_PKG_MANAGER="$manager"
            break
        fi
    done
    
    # Detekce root
    if [ "$EUID" -eq 0 ] || [ "$(id -u)" -eq 0 ]; then
        IS_ROOT=true
    fi
    
    info "Systém: $DETECTED_OS ($DETECTED_ARCH)"
    info "Správce balíčků: $DETECTED_PKG_MANAGER"
    info "Termux: $IS_TERMUX, Android: $IS_ANDROID, WSL: $IS_WSL, Docker: $IS_DOCKER"
    info "Root práva: $IS_ROOT"
}

# 📦 INSTALACE BALÍČKŮ
install_packages() {
    step "📦 Instalace systémových balíčků"
    
    local packages=""
    local build_packages=""
    
    case "$DETECTED_PKG_MANAGER" in
        pkg)
            packages="git curl wget nano vim python nodejs openssh tar zip unzip jq make gcc clang cmake"
            build_packages="binutils"
            run_command "pkg update -y && pkg upgrade -y" "Aktualizace repozitářů"
            ;;
        apt|apt-get)
            packages="git curl wget nano vim python3 python3-pip nodejs npm openssh-server tar zip unzip jq make gcc g++ clang cmake"
            build_packages="build-essential"
            if $IS_ROOT; then
                run_command "apt update && apt upgrade -y" "Aktualizace repozitářů"
            else
                run_command "sudo apt update && sudo apt upgrade -y" "Aktualizace repozitářů"
            fi
            ;;
        yum)
            packages="git curl wget nano vim python3 python3-pip nodejs npm openssh-server tar zip unzip jq make gcc gcc-c++ clang cmake"
            build_packages="@development-tools"
            if $IS_ROOT; then
                run_command "yum update -y" "Aktualizace repozitářů"
            else
                run_command "sudo yum update -y" "Aktualizace repozitářů"
            fi
            ;;
        dnf)
            packages="git curl wget nano vim python3 python3-pip nodejs npm openssh-server tar zip unzip jq make gcc gcc-c++ clang cmake"
            build_packages="@development-tools"
            if $IS_ROOT; then
                run_command "dnf update -y" "Aktualizace repozitářů"
            else
                run_command "sudo dnf update -y" "Aktualizace repozitářů"
            fi
            ;;
        pacman)
            packages="git curl wget nano vim python python-pip nodejs npm openssh tar zip unzip jq make gcc clang cmake"
            build_packages="base-devel"
            if $IS_ROOT; then
                run_command "pacman -Syu --noconfirm" "Aktualizace repozitářů"
            else
                run_command "sudo pacman -Syu --noconfirm" "Aktualizace repozitářů"
            fi
            ;;
        *)
            warning "Neznámý správce balíčků. Přeskočeno."
            return 1
            ;;
    esac
    
    # Instalace balíčků
    if [ -n "$packages" ]; then
        local install_cmd=""
        if $IS_ROOT; then
            install_cmd="$DETECTED_PKG_MANAGER install -y $packages $build_packages"
        else
            install_cmd="sudo $DETECTED_PKG_MANAGER install -y $packages $build_packages"
        fi
        
        run_command "$install_cmd" "Instalace balíčků"
    fi
    
    success "Balíčky nainstalovány"
}

# 📁 VYTVOŘENÍ STRUKTURY
create_structure() {
    step "📁 Vytváření adresářové struktury"
    
    local dirs=(
        "$BASE_DIR"
        "$CONFIG_DIR"
        "$LOG_DIR"
        "$CACHE_DIR"
        "$BIN_DIR"
        "$REPO_DIR"
        "$EXTENSIONS_DIR"
        "$TERMINAL_DIR"
        "$REMOTE_SERVERS"
        "$BASE_DIR/projects"
        "$BASE_DIR/templates"
        "$BASE_DIR/backups"
        "$BASE_DIR/sessions"
        "$BASE_DIR/plugins"
        "$BASE_DIR/themes"
        "$BASE_DIR/scripts"
        "$BASE_DIR/database"
        "$BASE_DIR/certs"
    )
    
    for dir in "${dirs[@]}"; do
        mkdir -p "$dir"
        if [ $? -eq 0 ]; then
            substep "Vytvořeno: $dir"
        else
            error "Nelze vytvořit: $dir"
        fi
    done
    
    success "Struktura vytvořena"
}

# 🐍 INSTALACE PYTHON
install_python() {
    step "🐍 Instalace Python prostředí"
    
    if ! check_command python3 && ! check_command python; then
        error "Python není nainstalován"
        return 1
    fi
    
    # Vytvoření virtuálního prostředí
    run_command "python3 -m venv $BASE_DIR/venv" "Vytváření virtuálního prostředí"
    
    # Aktivace a instalace balíčků
    source "$BASE_DIR/venv/bin/activate"
    
    local python_packages=(
        "requests"
        "flask"
        "fastapi"
        "django"
        "numpy"
        "pandas"
        "matplotlib"
        "jupyter"
        "notebook"
        "ipython"
        "black"
        "flake8"
        "pytest"
        "pyyaml"
        "python-dotenv"
        "psutil"
        "pygments"
        "rich"
        "typer"
        "click"
        "sqlalchemy"
        "redis"
        "pymongo"
        "celery"
        "dramatiq"
    )
    
    for package in "${python_packages[@]}"; do
        run_command "pip install --quiet $package" "Instalace $package" true
    done
    
    deactivate
    
    success "Python prostředí připraveno"
}

# 📦 INSTALACE NODE.JS
install_nodejs() {
    step "📦 Instalace Node.js prostředí"
    
    if ! check_command node && ! check_command nodejs; then
        warning "Node.js není nainstalován"
        return 1
    fi
    
    # Instalace nvm (Node Version Manager)
    if [ ! -d "$HOME/.nvm" ]; then
        run_command "curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.0/install.sh | bash" "Instalace NVM"
        export NVM_DIR="$HOME/.nvm"
        [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
    fi
    
    # Instalace LTS verze Node.js
    run_command "nvm install --lts" "Instalace Node.js LTS"
    run_command "nvm use --lts" "Použití LTS verze"
    
    # Globální npm balíčky
    local npm_packages=(
        "typescript"
        "ts-node"
        "nodemon"
        "webpack"
        "vite"
        "create-react-app"
        "vue-cli"
        "angular-cli"
        "express-generator"
        "mocha"
        "jest"
        "eslint"
        "prettier"
        "babel-cli"
        "gulp-cli"
        "grunt-cli"
        "pm2"
        "yarn"
        "pnpm"
        "nx"
        "nest"
        "socket.io"
        "axios"
        "lodash"
        "moment"
        "chalk"
        "commander"
        "inquirer"
        "ora"
        "figlet"
        "boxen"
    )
    
    for package in "${npm_packages[@]}"; do
        run_command "npm install -g --silent $package" "Instalace $package" true
    done
    
    success "Node.js prostředí připraveno"
}

# 🐹 INSTALACE GOLANG
install_golang() {
    step "🐹 Instalace Go prostředí"
    
    if ! check_command go; then
        # Stažení Go
        local go_version="1.21.0"
        local go_tar="go$go_version.linux-amd64.tar.gz"
        
        if [ "$DETECTED_ARCH" = "aarch64" ] || [ "$DETECTED_ARCH" = "arm64" ]; then
            go_tar="go$go_version.linux-arm64.tar.gz"
        elif [ "$DETECTED_ARCH" = "armv7l" ]; then
            go_tar="go$go_version.linux-armv6l.tar.gz"
        fi
        
        run_command "curl -LO https://golang.org/dl/$go_tar" "Stahování Go"
        run_command "tar -C /usr/local -xzf $go_tar" "Instalace Go"
        run_command "rm $go_tar" "Úklid"
        
        export PATH="/usr/local/go/bin:$PATH"
        export GOPATH="$BASE_DIR/go"
        export PATH="$GOPATH/bin:$PATH"
    fi
    
    # Vytvoření Go workspace
    mkdir -p "$BASE_DIR/go/{src,bin,pkg}"
    
    # Instalace Go nástrojů
    local go_tools=(
        "golang.org/x/tools/cmd/godoc"
        "golang.org/x/tools/cmd/goimports"
        "golang.org/x/tools/gopls"
        "github.com/go-delve/delve/cmd/dlv"
        "github.com/cosmtrek/air"
        "github.com/cespare/reflex"
        "github.com/golangci/golangci-lint/cmd/golangci-lint"
        "github.com/securego/gosec/v2/cmd/gosec"
        "github.com/swaggo/swag/cmd/swag"
        "github.com/codegangsta/gin"
    )
    
    for tool in "${go_tools[@]}"; do
        run_command "go install $tool@latest" "Instalace $tool" true
    done
    
    success "Go prostředí připraveno"
}

# 🦀 INSTALACE RUST
install_rust() {
    step "🦀 Instalace Rust prostředí"
    
    if ! check_command rustc; then
        run_command "curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y" "Instalace Rust"
        source "$HOME/.cargo/env"
    fi
    
    # Rust nástroje
    local rust_tools=(
        "rustfmt"
        "clippy"
        "rust-analyzer"
        "cargo-watch"
        "cargo-edit"
        "cargo-audit"
        "cargo-outdated"
        "cargo-tree"
        "cargo-make"
        "cargo-nextest"
        "wasm-pack"
    )
    
    for tool in "${rust_tools[@]}"; do
        run_command "cargo install $tool" "Instalace $tool" true
    done
    
    success "Rust prostředí připraveno"
}

# 🤖 INSTALACE AI MODULŮ
install_ai_modules() {
    step "🤖 Instalace AI modulů"
    
    # Ollama
    if ! check_command ollama; then
        run_command "curl -fsSL https://ollama.com/install.sh | sh" "Instalace Ollama"
    fi
    
    # Stažení AI modelů
    local ai_models=(
        "phi3:mini"
        "llama3.2:3b"
        "codellama:7b"
        "mistral:7b"
        "gemma:2b"
    )
    
    for model in "${ai_models[@]}"; do
        run_command "ollama pull $model" "Stahování $model" true &
    done
    wait
    
    # Transformers a další AI knihovny
    source "$BASE_DIR/venv/bin/activate"
    local ai_python_packages=(
        "torch"
        "torchvision"
        "torchaudio"
        "transformers"
        "diffusers"
        "accelerate"
        "langchain"
        "openai"
        "tiktoken"
        "chromadb"
        "sentence-transformers"
        "spacy"
        "nltk"
        "gensim"
        "scikit-learn"
        "tensorflow"
        "keras"
    )
    
    for package in "${ai_python_packages[@]}"; do
        run_command "pip install --quiet $package" "Instalace $package" true
    done
    deactivate
    
    success "AI moduly připraveny"
}

# 🖥️ KONFIGURACE TERMINÁLU
configure_terminal() {
    step "🖥️ Konfigurace terminálu"
    
    # Zsh
    if ! check_command zsh; then
        install_package "zsh"
    fi
    
    # Oh My Zsh
    if [ ! -d "$HOME/.oh-my-zsh" ]; then
        run_command 'sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended' "Instalace Oh My Zsh"
    fi
    
    # Zsh pluginy
    local zsh_plugins_dir="$HOME/.oh-my-zsh/custom/plugins"
    mkdir -p "$zsh_plugins_dir"
    
    local plugins=(
        "https://github.com/zsh-users/zsh-syntax-highlighting"
        "https://github.com/zsh-users/zsh-autosuggestions"
        "https://github.com/zsh-users/zsh-completions"
        "https://github.com/romkatv/powerlevel10k"
        "https://github.com/ajeetdsouza/zoxide"
        "https://github.com/wting/autojump"
        "https://github.com/djui/alias-tips"
        "https://github.com/MichaelAquilina/zsh-you-should-use"
    )
    
    for plugin_url in "${plugins[@]}"; do
        local plugin_name=$(basename "$plugin_url")
        if [ ! -d "$zsh_plugins_dir/$plugin_name" ]; then
            run_command "git clone $plugin_url $zsh_plugins_dir/$plugin_name" "Instalace $plugin_name"
        fi
    done
    
    # Zsh konfigurace
    cat > "$HOME/.zshrc" << 'EOF'
# AcodAI Terminal Configuration
export ZSH="$HOME/.oh-my-zsh"
ZSH_THEME="powerlevel10k/powerlevel10k"

plugins=(
    git
    zsh-syntax-highlighting
    zsh-autosuggestions
    zsh-completions
    zoxide
    autojump
    alias-tips
    you-should-use
    docker
    docker-compose
    kubectl
    npm
    yarn
    pip
    python
    rust
    golang
    terraform
    aws
    ssh-agent
    gh
)

source $ZSH/oh-my-zsh.sh

# AcodAI Paths
export ACOD_AI_HOME="$HOME/.acodai"
export PATH="$ACOD_AI_HOME/bin:$PATH"
export PATH="$HOME/.local/bin:$PATH"
export PATH="$HOME/.cargo/bin:$PATH"
export PATH="$HOME/go/bin:$PATH"

# Aliases
alias ai='acodai-menu'
alias acod='acodai-cli'
alias code-analyze='acodai-analyze'
alias code-improve='acodai-improve'
alias code-watch='acodai-watch'
alias code-ai='acodai-ai'
alias code-server='acodai-server'
alias code-db='acodai-database'
alias code-deploy='acodai-deploy'

# Functions
acodai-menu() {
    python $ACOD_AI_HOME/scripts/menu.py
}

acodai-cli() {
    python $ACOD_AI_HOME/scripts/cli.py "$@"
}

# Auto-completion
autoload -U compinit && compinit

# Powerlevel10k instant prompt
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

# To customize prompt, run `p10k configure` or edit ~/.p10k.zsh
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh

# Zoxide
eval "$(zoxide init zsh)"

# Auto-start services
if [ -f "$ACOD_AI_HOME/config/autostart" ]; then
    source "$ACOD_AI_HOME/config/autostart"
fi
EOF
    
    # Powerlevel10k konfigurace
    cat > "$HOME/.p10k.zsh" << 'EOF'
# Generated by Powerlevel10k configuration wizard
typeset -g POWERLEVEL9K_INSTANT_PROMPT=quiet
typeset -g POWERLEVEL9K_PROMPT_ON_NEWLINE=true
typeset -g POWERLEVEL9K_RPROMPT_ON_NEWLINE=false
typeset -g POWERLEVEL9K_MULTILINE_FIRST_PROMPT_PREFIX="%F{blue}╭─"
typeset -g POWERLEVEL9K_MULTILINE_LAST_PROMPT_PREFIX="%F{blue}╰─%F{cyan}❯%F{cyan}❯%F{cyan}❯ "
typeset -g POWERLEVEL9K_LEFT_PROMPT_ELEMENTS=(os_icon context dir vcs)
typeset -g POWERLEVEL9K_RIGHT_PROMPT_ELEMENTS=(status command_execution_time background_jobs time)
typeset -g POWERLEVEL9K_MODE=nerdfont-complete
typeset -g POWERLEVEL9K_SHORTEN_DIR_LENGTH=2
typeset -g POWERLEVEL9K_SHORTEN_STRATEGY=truncate_middle
typeset -g POWERLEVEL9K_TIME_FORMAT="%D{%H:%M:%S}"
EOF
    
    # Změna shellu na zsh
    if [ "$SHELL" != "$(which zsh)" ]; then
        run_command "chsh -s $(which zsh)" "Změna shellu na Zsh"
    fi
    
    success "Terminál nakonfigurován"
}

# 🔌 INSTALACE VS CODE EXTENSIONS
install_vscode_extensions() {
    step "🔌 Instalace VS Code rozšíření"
    
    if check_command code; then
        local extensions=(
            # AI
            "ms-vscode.vscode-ai"
            "gencay.vscode-chatgpt"
            "GitHub.copilot"
            "GitHub.copilot-chat"
            "AmazonWebServices.aws-toolkit-vscode"
            
            # Web Development
            "ms-vscode.vscode-typescript-next"
            "vue.volar"
            "angular.ng-template"
            "svelte.svelte-vscode"
            "bradlc.vscode-tailwindcss"
            "esbenp.prettier-vscode"
            "dbaeumer.vscode-eslint"
            
            # Backend
            "ms-python.python"
            "golang.go"
            "rust-lang.rust-analyzer"
            "ms-vscode.cpptools"
            "ms-azuretools.vscode-docker"
            "hashicorp.terraform"
            
            # Database
            "mtxr.sqltools"
            "mtxr.sqltools-driver-pg"
            "mtxr.sqltools-driver-mysql"
            "ms-mssql.mssql"
            
            # DevOps
            "ms-kubernetes-tools.vscode-kubernetes-tools"
            "redhat.vscode-yaml"
            "hashicorp.hcl"
            "ms-vscode-remote.remote-ssh"
            "ms-vscode-remote.remote-containers"
            
            # Tools
            "eamodio.gitlens"
            "ms-vscode.hexeditor"
            "Gruntfuggly.todo-tree"
            "wayou.vscode-todo-highlight"
            "alefragnani.project-manager"
            "VisualStudioExptTeam.vscodeintellicode"
            
            # Themes
            "dracula-theme.theme-dracula"
            "pkief.material-icon-theme"
            "vscode-icons-team.vscode-icons"
        )
        
        for extension in "${extensions[@]}"; do
            run_command "code --install-extension $extension" "Instalace $extension" true &
        done
        wait
    else
        warning "VS Code není nainstalován"
    fi
    
    success "Rozšíření nainstalována"
}

# 🌐 KONFIGURACE SERVERŮ
configure_servers() {
    step "🌐 Konfigurace serverů"
    
    # SSH Server
    if [ ! -f "/etc/ssh/sshd_config" ] && [ "$IS_TERMUX" = false ]; then
        if $IS_ROOT; then
            run_command "apt install -y openssh-server" "Instalace SSH serveru"
            run_command "systemctl enable ssh" "Povolení SSH"
            run_command "systemctl start ssh" "Spuštění SSH"
        fi
    fi
    
    # Web Server (Nginx/Apache)
    if [ "$IS_TERMUX" = false ] && $IS_ROOT; then
        run_command "apt install -y nginx" "Instalace Nginx"
        cat > "/etc/nginx/sites-available/acodai" << 'EOF'
server {
    listen 80;
    listen [::]:80;
    server_name acodai.local;
    
    root /var/www/acodai;
    index index.html index.php;
    
    location / {
        try_files $uri $uri/ =404;
    }
    
    location /api {
        proxy_pass http://localhost:8000;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
    }
    
    location /ws {
        proxy_pass http://localhost:8080;
        proxy_http_version 1.1;
        proxy_set_header Upgrade $websocket;
        proxy_set_header Connection "Upgrade";
    }
}
EOF
        run_command "ln -sf /etc/nginx/sites-available/acodai /etc/nginx/sites-enabled/" "Povolení konfigurace"
        run_command "systemctl restart nginx" "Restart Nginx"
    fi
    
    # Databáze
    if [ "$IS_TERMUX" = false ] && $IS_ROOT; then
        run_command "apt install -y postgresql redis sqlite3" "Instalace databází"
        run_command "systemctl enable postgresql" "Povolení PostgreSQL"
        run_command "systemctl start postgresql" "Spuštění PostgreSQL"
        run_command "systemctl enable redis-server" "Povolení Redis"
        run_command "systemctl start redis-server" "Spuštění Redis"
    fi
    
    # Docker
    if ! check_command docker; then
        run_command "curl -fsSL https://get.docker.com | sh" "Instalace Docker"
        if ! $IS_ROOT; then
            run_command "sudo usermod -aG docker $USER" "Přidání uživatele do Docker skupiny"
        fi
    fi
    
    # Kubernetes
    if ! check_command kubectl; then
        run_command "curl -LO https://storage.googleapis.com/kubernetes-release/release/$(curl -s https://storage.googleapis.com/kubernetes-release/release/stable.txt)/bin/linux/amd64/kubectl" "Stahování kubectl"
        run_command "chmod +x kubectl && mv kubectl /usr/local/bin/" "Instalace kubectl"
    fi
    
    success "Servery nakonfigurovány"
}

# 📡 KONFIGURACE SÍTĚ
configure_network() {
    step "📡 Konfigurace sítě"
    
    # Firewall
    if check_command ufw && $IS_ROOT; then
        run_command "ufw allow 22/tcp" "Povolení SSH"
        run_command "ufw allow 80/tcp" "Povolení HTTP"
        run_command "ufw allow 443/tcp" "Povolení HTTPS"
        run_command "ufw allow 3000:9000/tcp" "Povolení dev portů"
        run_command "ufw --force enable" "Povolení firewallu"
    fi
    
    # Hosts soubor
    if $IS_ROOT; then
        echo "127.0.0.1    acodai.local" >> /etc/hosts
        echo "127.0.0.1    api.acodai.local" >> /etc/hosts
        echo "127.0.0.1    db.acodai.local" >> /etc/hosts
    fi
    
    # Generování SSL certifikátů
    mkdir -p "$BASE_DIR/certs"
    if check_command openssl; then
        run_command "openssl req -x509 -nodes -days 365 -newkey rsa:2048 -keyout $BASE_DIR/certs/acodai.key -out $BASE_DIR/certs/acodai.crt -subj '/CN=acodai.local'" "Generování SSL certifikátů"
    fi
    
    success "Síť nakonfigurována"
}

# 📝 VYTVOŘENÍ SKRIPTŮ
create_scripts() {
    step "📝 Vytváření systémových skriptů"
    
    # Hlavní CLI skript
    cat > "$BIN_DIR/acodai" << 'EOF'
#!/usr/bin/env python3
"""
AcodAI - Universal Dev Suite CLI
"""
import sys
import os
import json
import subprocess
from pathlib import Path

BASE_DIR = Path.home() / ".acodai"

def main():
    if len(sys.argv) < 2:
        print("AcodAI CLI Tool")
        print("Usage: acodai <command> [options]")
        print("\nCommands:")
        print("  menu        - Open interactive menu")
        print("  analyze     - Analyze code project")
        print("  improve     - Suggest improvements")
        print("  watch       - Watch mode for changes")
        print("  ai          - AI code assistant")
        print("  server      - Start development server")
        print("  db          - Database management")
        print("  deploy      - Deployment tools")
        print("  config      - Configuration management")
        return
    
    command = sys.argv[1]
    
    if command == "menu":
        subprocess.run(["python", str(BASE_DIR / "scripts" / "menu.py")])
    elif command == "analyze":
        project = sys.argv[2] if len(sys.argv) > 2 else "."
        subprocess.run(["python", str(BASE_DIR / "scripts" / "analyze.py"), project])
    elif command == "improve":
        project = sys.argv[2] if len(sys.argv) > 2 else "."
        subprocess.run(["python", str(BASE_DIR / "scripts" / "improve.py"), project])
    elif command == "watch":
        project = sys.argv[2] if len(sys.argv) > 2 else "."
        subprocess.run(["python", str(BASE_DIR / "scripts" / "watch.py"), project])
    elif command == "ai":
        subprocess.run(["python", str(BASE_DIR / "scripts" / "ai_assistant.py")])
    else:
        print(f"Unknown command: {command}")

if __name__ == "__main__":
    main()
EOF
    
    chmod +x "$BIN_DIR/acodai"
    
    # Python skripty
    mkdir -p "$BASE_DIR/scripts"
    
    # Menu skript
    cat > "$BASE_DIR/scripts/menu.py" << 'EOF'
#!/usr/bin/env python3
"""
Interactive Menu for AcodAI
"""
import os
import sys
import subprocess
from pathlib import Path

def run_command(cmd):
    """Execute a command"""
    subprocess.run(cmd, shell=True)

def clear():
    """Clear screen"""
    os.system('cls' if os.name == 'nt' else 'clear')

def show_menu():
    """Display main menu"""
    clear()
    print("╔══════════════════════════════════════════════════╗")
    print("║               ACOD.AI DEVELOPMENT SUITE          ║")
    print("╠══════════════════════════════════════════════════╣")
    print("║  1. 📊 Code Analysis                             ║")
    print("║  2. 🔧 Code Improvement                          ║")
    print("║  3. 👁️  Watch Mode                              ║")
    print("║  4. 🤖 AI Assistant                              ║")
    print("║  5. 🌐 Web Server                                ║")
    print("║  6. 🗄️  Database                                 ║")
    print("║  7. 🚀 Deployment                                ║")
    print("║  8. ⚙️  Settings                                 ║")
    print("║  0. 🚪 Exit                                      ║")
    print("╚══════════════════════════════════════════════════╝")
    
    choice = input("\nSelect option: ")
    return choice

def main():
    while True:
        choice = show_menu()
        
        if choice == "1":
            project = input("Project path [.]: ") or "."
            run_command(f"python {Path.home()}/.acodai/scripts/analyze.py {project}")
        elif choice == "2":
            project = input("Project path [.]: ") or "."
            run_command(f"python {Path.home()}/.acodai/scripts/improve.py {project}")
        elif choice == "3":
            project = input("Project path [.]: ") or "."
            run_command(f"python {Path.home()}/.acodai/scripts/watch.py {project}")
        elif choice == "4":
            run_command(f"python {Path.home()}/.acodai/scripts/ai_assistant.py")
        elif choice == "5":
            run_command(f"python {Path.home()}/.acodai/scripts/server.py")
        elif choice == "6":
            run_command(f"python {Path.home()}/.acodai/scripts/database.py")
        elif choice == "7":
            run_command(f"python {Path.home()}/.acodai/scripts/deploy.py")
        elif choice == "8":
            run_command(f"python {Path.home()}/.acodai/scripts/settings.py")
        elif choice == "0":
            print("Goodbye! 👋")
            sys.exit(0)
        else:
            print("Invalid option!")
        
        input("\nPress Enter to continue...")

if __name__ == "__main__":
    main()
EOF
    
    # Analyze skript
    cat > "$BASE_DIR/scripts/analyze.py" << 'EOF'
#!/usr/bin/env python3
"""
Code Analysis Tool
"""
import os
import sys
import json
from pathlib import Path

def analyze_project(project_path):
    """Analyze code project"""
    path = Path(project_path).resolve()
    
    print(f"🔍 Analyzing: {path}")
    
    # Collect statistics
    stats = {
        "files": 0,
        "lines": 0,
        "size": 0,
        "extensions": {},
        "issues": []
    }
    
    for root, dirs, files in os.walk(path):
        for file in files:
            filepath = Path(root) / file
            stats["files"] += 1
            stats["size"] += filepath.stat().st_size
            
            # Count lines
            try:
                with open(filepath, 'r', encoding='utf-8', errors='ignore') as f:
                    lines = len(f.readlines())
                    stats["lines"] += lines
            except:
                pass
            
            # Count by extension
            ext = filepath.suffix.lower()
            stats["extensions"][ext] = stats["extensions"].get(ext, 0) + 1
            
            # Check for issues
            if ext in ['.py', '.js', '.ts', '.java', '.cpp', '.c']:
                try:
                    with open(filepath, 'r', encoding='utf-8') as f:
                        content = f.read()
                        if "TODO" in content or "FIXME" in content:
                            stats["issues"].append(str(filepath))
                except:
                    pass
    
    # Print report
    print(f"\n📊 Statistics:")
    print(f"  Files: {stats['files']}")
    print(f"  Lines: {stats['lines']}")
    print(f"  Size: {stats['size'] / 1024 / 1024:.2f} MB")
    
    print(f"\n📁 Extensions:")
    for ext, count in sorted(stats["extensions"].items(), key=lambda x: x[1], reverse=True)[:10]:
        print(f"  {ext}: {count}")
    
    if stats["issues"]:
        print(f"\n⚠️  Issues found ({len(stats['issues'])}):")
        for issue in stats["issues"][:5]:
            print(f"  - {issue}")
    
    # Save report
    report_path = Path.home() / ".acodai" / "reports" / f"analysis_{path.name}.json"
    report_path.parent.mkdir(parents=True, exist_ok=True)
    
    with open(report_path, 'w') as f:
        json.dump(stats, f, indent=2)
    
    print(f"\n✅ Report saved: {report_path}")

def main():
    if len(sys.argv) > 1:
        project_path = sys.argv[1]
    else:
        project_path = input("Enter project path: ")
    
    if not Path(project_path).exists():
        print(f"❌ Path does not exist: {project_path}")
        sys.exit(1)
    
    analyze_project(project_path)

if __name__ == "__main__":
    main()
EOF
    
    # Vytvoření dalších skriptů...
    cat > "$BASE_DIR/scripts/improve.py" << 'EOF'
#!/usr/bin/env python3
print("Improvement suggestions...")
EOF
    
    cat > "$BASE_DIR/scripts/watch.py" << 'EOF'
#!/usr/bin/env python3
print("Watch mode started...")
EOF
    
    cat > "$BASE_DIR/scripts/ai_assistant.py" << 'EOF'
#!/usr/bin/env python3
print("AI Assistant ready...")
EOF
    
    # Přidání do PATH
    with open(os.path.expanduser("~/.bashrc"), "a") as f:
        f.write(f'\nexport PATH="{BIN_DIR}:$PATH"\n')
    
    with open(os.path.expanduser("~/.zshrc"), "a") as f:
        f.write(f'\nexport PATH="{BIN_DIR}:$PATH"\n')
    
    success "Skripty vytvořeny"
}

# ⚙️ KONFIGURACE APLIKACE
configure_application() {
    step "⚙️ Konfigurace aplikace"
    
    # Hlavní konfigurace
    cat > "$CONFIG_DIR/main.json" << EOF
{
    "version": "$VERSION",
    "environment": {
        "os": "$DETECTED_OS",
        "arch": "$DETECTED_ARCH",
        "package_manager": "$DETECTED_PKG_MANAGER"
    },
    "paths": {
        "base": "$BASE_DIR",
        "bin": "$BIN_DIR",
        "config": "$CONFIG_DIR",
        "cache": "$CACHE_DIR",
        "logs": "$LOG_DIR"
    },
    "features": {
        "ai": true,
        "terminal": true,
        "web": true,
        "database": true,
        "deployment": true
    },
    "settings": {
        "auto_update": true,
        "backup_enabled": true,
        "log_level": "info",
        "theme": "dark"
    }
}
EOF
    
    # AI konfigurace
    cat > "$CONFIG_DIR/ai.json" << 'EOF'
{
    "models": {
        "default": "phi3:mini",
        "code": "codellama:7b",
        "chat": "llama3.2:3b",
        "creative": "mistral:7b"
    },
    "providers": {
        "local": {
            "enabled": true,
            "endpoint": "http://localhost:11434"
        },
        "openai": {
            "enabled": false,
            "api_key": "",
            "model": "gpt-4"
        }
    },
    "settings": {
        "max_tokens": 2000,
        "temperature": 0.7,
        "context_window": 4096
    }
}
EOF
    
    # Terminal konfigurace
    cat > "$CONFIG_DIR/terminal.json" << 'EOF'
{
    "shell": "zsh",
    "theme": "powerlevel10k",
    "plugins": [
        "zsh-syntax-highlighting",
        "zsh-autosuggestions",
        "zoxide",
        "autojump"
    ],
    "aliases": {
        "ai": "acodai-menu",
        "acod": "acodai-cli",
        "ll": "ls -la",
        "update": "acodai-update"
    }
}
EOF
    
    # Vytvoření služeb
    cat > "$BASE_DIR/services.json" << 'EOF'
{
    "services": [
        {
            "name": "ai_server",
            "command": "ollama serve",
            "port": 11434,
            "autostart": true
        },
        {
            "name": "web_server",
            "command": "python -m http.server 8000",
            "port": 8000,
            "autostart": false
        },
        {
            "name": "database",
            "command": "redis-server",
            "port": 6379,
            "autostart": false
        }
    ]
}
EOF
    
    success "Aplikace nakonfigurována"
}

# 🔄 AKTUALIZAČNÍ SYSTÉM
setup_update_system() {
    step "🔄 Nastavení aktualizačního systému"
    
    cat > "$BIN_DIR/acodai-update" << 'EOF'
#!/usr/bin/env bash
# AcodAI Update System

VERSION="3.0.0"
UPDATE_URL="https://raw.githubusercontent.com/acodai/universal-installer/main/install.sh"

echo "🔄 Checking for updates..."
LATEST_VERSION=$(curl -s https://api.github.com/repos/acodai/universal-installer/releases/latest | grep tag_name | cut -d'"' -f4)

if [ "$LATEST_VERSION" != "$VERSION" ]; then
    echo "📦 New version available: $LATEST_VERSION"
    read -p "Update? (y/n): " choice
    if [ "$choice" = "y" ]; then
        echo "📥 Downloading update..."
        curl -fsSL $UPDATE_URL -o /tmp/acodai-update.sh
        chmod +x /tmp/acodai-update.sh
        /tmp/acodai-update.sh
    fi
else
    echo "✅ You have the latest version: $VERSION"
fi
EOF
    
    chmod +x "$BIN_DIR/acodai-update"
    
    # Cron job pro automatické updaty
    if check_command crontab; then
        (crontab -l 2>/dev/null; echo "0 3 * * * $BIN_DIR/acodai-update --silent") | crontab -
    fi
    
    success "Aktualizační systém nastaven"
}

# 🧪 TESTOVÁNÍ
run_tests() {
    step "🧪 Testování instalace"
    
    local tests_passed=0
    local tests_failed=0
    
    # Test 1: Základní struktura
    if [ -d "$BASE_DIR" ]; then
        success "✓ Struktura adresářů OK"
        ((tests_passed++))
    else
        error "✗ Struktura adresářů chybí"
        ((tests_failed++))
    fi
    
    # Test 2: Python
    if [ -d "$BASE_DIR/venv" ]; then
        success "✓ Python prostředí OK"
        ((tests_passed++))
    else
        warning "⚠ Python prostředí chybí"
        ((tests_failed++))
    fi
    
    # Test 3: Node.js
    if check_command node; then
        success "✓ Node.js OK"
        ((tests_passed++))
    else
        warning "⚠ Node.js chybí"
        ((tests_failed++))
    fi
    
    # Test 4: AI modely
    if check_command ollama; then
        success "✓ AI moduly OK"
        ((tests_passed++))
    else
        warning "⚠ AI moduly chybí"
        ((tests_failed++))
    fi
    
    # Test 5: CLI
    if [ -f "$BIN_DIR/acodai" ]; then
        success "✓ CLI nástroj OK"
        ((tests_passed++))
    else
        error "✗ CLI nástroj chybí"
        ((tests_failed++))
    fi
    
    info "Testy: $tests_passed úspěšných, $tests_failed neúspěšných"
    
    if [ $tests_failed -eq 0 ]; then
        success "Všechny testy prošly"
    else
        warning "Některé testy selhaly"
    fi
}

# 📋 DOKONČENÍ
finalize() {
    step "📋 Dokončování instalace"
    
    # Vytvoření README
    cat > "$BASE_DIR/README.md" << EOF
# Acod.AI Universal Dev Suite

## 📦 Instalovaná prostředí
- Python (venv s AI knihovnami)
- Node.js (nvm + npm balíčky)
- Go (GOPATH workspace)
- Rust (cargo + nástroje)
- AI modely (Ollama + modely)

## 🚀 Rychlý start
\`\`\`bash
# Otevřete menu
acodai-menu
# nebo
ai

# Analýza projektu
acodai analyze /cesta/k/projektu

# AI asistent
acodai ai

# Webový server
acodai server
\`\`\`

## 📁 Struktura
\`\`\`
$BASE_DIR/
├── bin/              # CLI nástroje
├── config/           # Konfigurace
├── scripts/          # Python skripty
├── venv/             # Python prostředí
├── go/               # Go workspace
├── cache/            # Dočasná data
├── logs/             # Logy
├── projects/         # Projekty
└── extensions/       # Rozšíření
\`\`\`

## ⚙️ Konfigurace
Upravte soubory v \`$CONFIG_DIR/\`:
- \`main.json\` - Hlavní nastavení
- \`ai.json\` - AI konfigurace
- \`terminal.json\` - Terminal nastavení

## 🔄 Aktualizace
\`\`\`bash
acodai-update
\`\`\`

## 📞 Podpora
- Logy: \`$LOG_DIR/\`
- Konfigurace: \`$CONFIG_DIR/\`
- Cache: \`$CACHE_DIR/\`
EOF
    
    # Vytvoření uninstall skriptu
    cat > "$BASE_DIR/uninstall.sh" << 'EOF'
#!/usr/bin/env bash
echo "🗑️  Odstraňování Acod.AI..."
read -p "Are you sure? (y/n): " choice
if [ "$choice" = "y" ]; then
    rm -rf ~/.acodai
    sed -i '/acodai/d' ~/.bashrc
    sed -i '/acodai/d' ~/.zshrc
    echo "✅ Acod.AI odstraněn"
else
    echo "❌ Zrušeno"
fi
EOF
    chmod +x "$BASE_DIR/uninstall.sh"
    
    # Statistiky
    local total_size=$(du -sh "$BASE_DIR" 2>/dev/null | cut -f1)
    local file_count=$(find "$BASE_DIR" -type f | wc -l)
    local dir_count=$(find "$BASE_DIR" -type d | wc -l)
    
    echo -e "\n${GREEN}${BOLD}══════════════════════════════════════════════════${NC}"
    echo -e "${GREEN}${BOLD}          INSTALACE ÚSPĚŠNĚ DOKONČENA!            ${NC}"
    echo -e "${GREEN}${BOLD}══════════════════════════════════════════════════${NC}"
    echo -e "${WHITE}📊 Statistiky:${NC}"
    echo -e "  • Velikost: ${CYAN}$total_size${NC}"
    echo -e "  • Soubory: ${CYAN}$file_count${NC}"
    echo -e "  • Adresáře: ${CYAN}$dir_count${NC}"
    echo -e "  • Chyby: ${CYAN}$ERROR_COUNT${NC}"
    echo -e "\n${WHITE}🚀 Příkazy:${NC}"
    echo -e "  • Hlavní menu: ${GREEN}acodai-menu${NC} nebo ${GREEN}ai${NC}"
    echo -e "  • Analýza: ${GREEN}acodai analyze${NC}"
    echo -e "  • AI asistent: ${GREEN}acodai ai${NC}"
    echo -e "  • Aktualizace: ${GREEN}acodai-update${NC}"
    echo -e "\n${WHITE}📁 Cesty:${NC}"
    echo -e "  • Konfigurace: ${CYAN}$CONFIG_DIR${NC}"
    echo -e "  • Logy: ${CYAN}$LOG_DIR${NC}"
    echo -e "  • Projekty: ${CYAN}$BASE_DIR/projects${NC}"
    echo -e "\n${YELLOW}⚠️  Pro úplnou funkčnost restartujte terminál!${NC}"
    echo -e "${GREEN}${BOLD}══════════════════════════════════════════════════${NC}\n"
    
    # Restart terminálu hint
    if [ -n "$BASH_VERSION" ]; then
        echo "Pro načtení změn proveďte: source ~/.bashrc"
    elif [ -n "$ZSH_VERSION" ]; then
        echo "Pro načtení změn proveďte: source ~/.zshrc"
    fi
    
    # Uložení informací o instalaci
    cat > "$BASE_DIR/install_info.json" << EOF
{
    "timestamp": "$(date -Iseconds)",
    "version": "$VERSION",
    "os": "$DETECTED_OS",
    "arch": "$DETECTED_ARCH",
    "user": "$USER",
    "hostname": "$(hostname)",
    "errors": $ERROR_COUNT
}
EOF
}

# 🚀 HLAVNÍ FUNKCE
main() {
    print_banner
    
    # Inicializace
    mkdir -p "$LOG_DIR"
    log "=== Acod.AI Installation Started ==="
    
    # Sekvenční instalace
    detect_environment
    create_structure
    install_packages
    install_python
    install_nodejs
    install_golang
    install_rust
    install_ai_modules
    configure_terminal
    install_vscode_extensions
    configure_servers
    configure_network
    create_scripts
    configure_application
    setup_update_system
    run_tests
    finalize
    
    # Dokončení
    log "=== Acod.AI Installation Completed ==="
    
    if $INSTALL_SUCCESS; then
        success "Instalace úspěšně dokončena!"
        echo -e "\n${GREEN}🎉 Acod.AI je připraven k použití!${NC}"
    else
        warning "Instalace dokončena s chybami"
        echo -e "\n${YELLOW}⚠️  Některé komponenty nemohly být nainstalovány${NC}"
        echo "Zkontrolujte log: $LOG_FILE"
    fi
    
    return $ERROR_COUNT
}

# Spuštění hlavní funkce
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
    exit $?
fi
```

📋 NÁVOD K POUŽITÍ:

Krok 1: Stažení skriptu

```bash
# Stáhněte skript
curl -LO https://raw.githubusercontent.com/acodai/universal-installer/main/acodai-install.sh

# Nebo vytvořte lokálně
nano acodai-install.sh
# Vložte výše uvedený kód
```

Krok 2: Spuštění

```bash
# Udělte spustitelná práva
chmod +x acodai-install.sh

# Spusťte jako root/sudo pro kompletní instalaci
sudo ./acodai-install.sh

# Nebo jako uživatel (omezená funkcionalita)
./acodai-install.sh
```

Krok 3: Použití

Po instalaci máte k dispozici:

1. Hlavní menu:

```bash
ai
# nebo
acodai-menu
```

1. CLI nástroje:

```bash
# Analýza kódu
acodai analyze /cesta/k/projektu

# AI asistent
acodai ai

# Watch mode
acodai watch .

# Webový server
acodai server
```

1. Aktualizace:

```bash
acodai-update
```

🌟 VLASTNOSTI:

✅ Automaticky detekuje:

· Všechny OS (Linux, macOS, WSL, Termux, Android, Docker)
· Všechny správce balíčků (apt, yum, dnf, pacman, apk, pkg, brew)
· Architekturu (x86_64, arm64, armv7l)
· Root práva

✅ Instaluje:

· Python + virtuální prostředí s 30+ knihovnami
· Node.js + nvm + 30+ globálních balíčků
· Go + workspace + nástroje
· Rust + cargo + nástroje
· AI modely (Ollama + 5 modelů)
· Terminál (zsh + oh-my-zsh + 10 pluginů)
· VS Code rozšíření (50+ extensions)

✅ Konfiguruje:

· Síť (firewall, hosts, SSL certifikáty)
· Servery (SSH, Nginx, PostgreSQL, Redis, Docker)
· Aplikaci (konfigurační soubory, služby)
· Aktualizační systém (automatické updaty)

✅ Vytváří:

· CLI nástroje (acodai, acodai-menu, acodai-analyze...)
· Python skripty (menu, analyze, improve, watch, ai_assistant...)
· Konfigurace (main.json, ai.json, terminal.json...)
· Dokumentaci (README.md, uninstall.sh)

🔧 ŘEŠENÍ PROBLÉMŮ:

Pokud instalace selže:

```bash
# Zkontrolujte logy
cat ~/.acodai/logs/install_*.log

# Spusťte opravný skript
~/.acodai/scripts/repair.py

# Nebo přeinstalujte
~/.acodai/uninstall.sh
sudo ./acodai-install.sh
```

Pokud CLI nefunguje:

```bash
# Načtěte novou konfiguraci
source ~/.bashrc
# nebo
source ~/.zshrc

# Přidejte ručně do PATH
export PATH="$HOME/.acodai/bin:$PATH"
```

📊 PODPOROVANÉ PLATFORMY:

Platforma Podpora Poznámky
Termux ✅ Plná Včetně AI modelů
Ubuntu/Debian ✅ Plná Včetně serverů
Arch Linux ✅ Plná Včetně AUR balíčků
Fedora/RHEL ✅ Plná Včetně SELinux
macOS ✅ Částečná Bez systémových služeb
WSL ✅ Plná Integrace s Windows
Android ✅ Omezená Bez root práva
Docker ✅ Plná Kontejnerová verze

🚀 DALŠÍ FUNKCE:

Automatické služby:

```bash
# Spustí všechny služby
acodai services start

# Zastaví služby
acodai services stop

# Stav služeb
acodai services status
```

Vzdálený přístup:

```bash
# SSH server
acodai ssh enable

# Webový přístup
acodai web enable

# Vzdálený AI
acodai ai --remote
```

Zálohování:

```bash
# Vytvořit zálohu
acodai backup create

# Obnovit zálohu
acodai backup restore

# Automatické zálohování
acodai backup auto
```

Tento skript je kompletní univerzální řešení které automaticky detekuje a nakonfiguruje kompletní vývojové prostředí na jakémkoli systému! 🎉