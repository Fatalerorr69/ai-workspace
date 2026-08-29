#!/bin/bash

set -e

echo "🚀 Starting Universal AI Development Environment Setup..."

# Update system and install basic tools
echo "📦 Updating system and installing base tools..."
sudo apt-get update
sudo apt-get upgrade -y
sudo apt-get install -y \
    curl \
    wget \
    git \
    build-essential \
    python3-pip \
    nodejs \
    npm \
    jq \
    htop \
    nano \
    vim \
    tree \
    silversearcher-ag

# Install Ollama
echo "🦙 Installing Ollama..."
curl -fsSL https://ollama.ai/install.sh | sh

# Add Ollama to PATH
echo 'export PATH="$PATH:$HOME/.ollama/bin"' >> ~/.bashrc
echo 'export OLLAMA_HOST="0.0.0.0"' >> ~/.bashrc
source ~/.bashrc

# Install Python packages for general development
echo "🐍 Installing Python packages..."
pip3 install --upgrade pip
pip3 install \
    jupyter \
    jupyterlab \
    notebook \
    pandas \
    numpy \
    matplotlib \
    seaborn \
    scikit-learn \
    requests \
    flask \
    fastapi \
    django \
    pyyaml \
    docker \
    virtualenv

# Install Node.js packages
echo "📦 Installing Node.js global packages..."
sudo npm install -g \
    n \
    typescript \
    ts-node \
    nodemon \
    yarn \
    create-react-app \
    express-generator

# Install useful system tools
echo "🔧 Installing development tools..."
sudo apt-get install -y \
    git-extras \
    bat \
    exa \
    fd-find \
    ripgrep

# Create symbolic links for modern tools
sudo ln -sf /usr/bin/batcat /usr/local/bin/bat
sudo ln -sf /usr/bin/fdfind /usr/local/bin/fd

# Create development directories
mkdir -p /workspaces/development/{python,node,go,rust,web,docker}

# Download AI models in background
echo "📥 Downloading AI models (this will run in background)..."
{
    echo "Starting model downloads..."
    
    # Code-specific models
    ollama pull codellama:7b
    ollama pull codellama:13b
    
    # General purpose models
    ollama pull mistral:7b
    ollama pull llama2:13b
    ollama pull phi:2.7b
    
    # Chat-optimized models
    ollama pull zephyr:7b
    
    echo "✅ All AI models downloaded!"
} &

# Create AI assistant script
echo "📁 Creating AI assistant scripts..."
mkdir -p /workspaces/scripts

cat > /workspaces/scripts/ai-assistant.sh << 'EOF'
#!/bin/bash

# Universal AI Assistant for Development
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Color codes for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# AI Chat functions
ai-chat() {
    local model="${1:-codellama:7b}"
    local prompt="${2:-$*}"
    
    if [ -z "$prompt" ]; then
        echo -e "${YELLOW}Usage: ai-chat [model] [prompt]${NC}"
        echo -e "${BLUE}Available models:${NC}"
        ollama list | tail -n +2 | awk '{print "  - " $1}'
        return 1
    fi
    
    echo -e "${GREEN}🤖 Using model: $model${NC}"
    ollama run "$model" "$prompt"
}

ai-code() {
    local language="$1"
    local task="$2"
    
    if [ -z "$task" ]; then
        echo -e "${YELLOW}Usage: ai-code [language] [task]${NC}"
        echo -e "${BLUE}Example: ai-code python 'read CSV file and calculate average'${NC}"
        return 1
    fi
    
    ollama run codellama:7b "Write $language code to: $task. Include comments and error handling."
}

ai-explain() {
    local file="$1"
    
    if [ -z "$file" ] || [ ! -f "$file" ]; then
        echo -e "${RED}❌ File not found: $file${NC}"
        return 1
    fi
    
    local content
    content=$(head -50 "$file")  # First 50 lines to avoid context limits
    
    echo -e "${GREEN}📚 Explaining code: $file${NC}"
    ollama run mistral:7b "Explain this code:\n\n$content"
}

ai-debug() {
    local file="$1"
    local error="$2"
    
    if [ -z "$file" ] || [ ! -f "$file" ]; then
        echo -e "${RED}❌ File not found: $file${NC}"
        return 1
    fi
    
    local content
    content=$(cat "$file")
    
    echo -e "${GREEN}🐛 Debugging: $file${NC}"
    ollama run codellama:13b "Help debug this code. Error: $error\n\nCode:\n$content"
}

ai-review() {
    local file="$1"
    
    if [ -z "$file" ] || [ ! -f "$file" ]; then
        echo -e "${RED}❌ File not found: $file${NC}"
        return 1
    fi
    
    local content
    content=$(cat "$file")
    
    echo -e "${GREEN}🔍 Code review: $file${NC}"
    ollama run zephyr:7b "Review this code for best practices, potential issues, and improvements:\n\n$content"
}

# Project setup helpers
ai-setup-python() {
    local project_name="$1"
    
    if [ -z "$project_name" ]; then
        echo -e "${YELLOW}Usage: ai-setup-python [project-name]${NC}"
        return 1
    fi
    
    ollama run codellama:7b "Create a complete Python project structure for: $project_name. Include requirements.txt, setup.py, README.md, and basic project layout."
}

ai-setup-node() {
    local project_name="$1"
    
    if [ -z "$project_name" ]; then
        echo -e "${YELLOW}Usage: ai-setup-node [project-name]${NC}"
        return 1
    fi
    
    ollama run codellama:7b "Create a complete Node.js project structure for: $project_name. Include package.json, basic Express server, and project layout."
}

# Show available commands
ai-help() {
    echo -e "${GREEN}🚀 Universal AI Assistant Commands:${NC}"
    echo -e "${BLUE}Chat & Code:${NC}"
    echo "  ai-chat [model] [prompt]    - Chat with AI model"
    echo "  ai-code [lang] [task]       - Generate code for specific task"
    echo "  ai-explain [file]           - Explain code in file"
    echo "  ai-debug [file] [error]     - Help debug code with error"
    echo "  ai-review [file]            - Code review for best practices"
    echo ""
    echo -e "${BLUE}Project Setup:${NC}"
    echo "  ai-setup-python [name]      - Create Python project structure"
    echo "  ai-setup-node [name]        - Create Node.js project structure"
    echo ""
    echo -e "${BLUE}Utilities:${NC}"
    echo "  ai-help                     - Show this help"
    echo "  ai-models                   - Show available AI models"
    echo ""
    echo -e "${YELLOW}Available AI models:${NC}"
    ollama list | tail -n +2 | awk '{print "  - " $1}'
}

ai-models() {
    echo -e "${GREEN}📊 Available AI Models:${NC}"
    ollama list
}

# Export functions to make them available in shell
export -f ai-chat
export -f ai-code
export -f ai-explain
export -f ai-debug
export -f ai-review
export -f ai-setup-python
export -f ai-setup-node
export -f ai-help
export -f ai-models

echo -e "${GREEN}✅ Universal AI Assistant loaded!${NC}"
echo -e "${YELLOW}Type 'ai-help' to see available commands${NC}"
EOF

chmod +x /workspaces/scripts/ai-assistant.sh

# Add to bashrc
echo "source /workspaces/scripts/ai-assistant.sh" >> ~/.bashrc
source ~/.bashrc

echo "✅ AI assistant setup complete!"
