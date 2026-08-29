#!/bin/bash

echo "🎯 Starting Universal AI Development Environment..."

# Start Ollama service if not running
if ! pgrep -x "ollama" > /dev/null; then
    echo "🦙 Starting Ollama service..."
    ollama serve &
    sleep 5
fi

# Check if models are downloaded, start downloading if not
if ! ollama list | grep -q "codellama:7b"; then
    echo "📥 Starting AI model downloads in background..."
    {
        ollama pull codellama:7b
        echo "✅ codellama:7b downloaded"
    } &
fi

# Display welcome message and available commands
echo ""
echo "🚀 Universal AI Development Environment Ready!"
echo ""
echo "📚 Available AI Commands:"
echo "   ai-chat [model] [prompt]    - Chat with AI"
echo "   ai-code [language] [task]   - Generate code"
echo "   ai-explain [file]           - Explain code"
echo "   ai-debug [file] [error]     - Debug code"
echo "   ai-review [file]            - Code review"
echo "   ai-help                     - Show all commands"
echo ""
echo "🔧 Development Tools:"
echo "   python 3.11, node.js 18, docker, git"
echo "   jupyter, pandas, flask, react"
echo ""
echo "💡 Tip: Start with 'ai-help' to see all AI commands"

# Make scripts executable
chmod +x /workspaces/scripts/*.sh
