#!/bin/bash
# Přepínání AI modelů
case "$1" in
  cloud)
    ./starcore ai-config provider openrouter
    ./starcore ai-config model openai/gpt-4o
    echo "✅ Přepnuto na cloudový model (OpenRouter)"
    ;;
  local)
    ./starcore ai-config provider local
    ./starcore ai-config base_url "http://localhost:11434/v1"
    ./starcore ai-config model llama3.2
    echo "✅ Přepnuto na lokální model (Ollama)"
    ;;
  *)
    echo "Použití: switch_model.sh [cloud|local]"
    ;;
esac
