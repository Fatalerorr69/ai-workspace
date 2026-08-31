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
        
        for extension in "${
