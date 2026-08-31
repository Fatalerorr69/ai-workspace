#!/bin/bash
echo "🔍 Kontrola běžících služeb..."
cd ~/STARCORE

./starcore status
./starcore hive-status
./starcore ai-status
curl -s http://localhost:8000/health > /dev/null && echo "✅ Dashboard běží" || echo "❌ Dashboard neběží"
curl -s http://localhost:11434 > /dev/null && echo "✅ Ollama běží" || echo "❌ Ollama neběží"
