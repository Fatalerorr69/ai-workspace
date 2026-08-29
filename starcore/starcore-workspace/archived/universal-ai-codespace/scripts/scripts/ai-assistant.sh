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
    # join remaining args into prompt if provided
    shift || true
    local prompt="${*:-$model}"
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
    shift || true
    local task="$*"
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
    shift || true
    local error="$*"

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
