#!/bin/bash
# STARCORE Mobile Setup & Verification

echo "════════════════════════════════════════════════════════════"
echo "  STARCORE MOBILE SETUP & VERIFICATION"
echo "════════════════════════════════════════════════════════════"
echo ""

# Kontrola Termux:API
echo "🔍 Kontrola Termux:API..."
if command -v termux-battery-status &>/dev/null; then
    echo "  ✅ termux-battery-status"
else
    echo "  ❌ Termux:API není nainstalováno"
    echo "  📦 Instalujte: pkg install termux-api"
    exit 1
fi

# Ověření jednotlivých funkcí
echo ""
echo "🧪 Ověření funkcí:"

echo -n "  Baterie: "
if termux-battery-status &>/dev/null; then
    echo "✅"
else
    echo "❌"
fi

echo -n "  WiFi: "
if termux-wifi-connectioninfo &>/dev/null; then
    echo "✅"
else
    echo "❌"
fi

echo -n "  Notifikace: "
if termux-notification --title "Test" --content "STARCORE test" &>/dev/null; then
    echo "✅"
else
    echo "❌"
fi

echo -n "  Senzory: "
if termux-sensor -s all &>/dev/null; then
    echo "✅"
else
    echo "❌"
fi

echo -n "  TTS (hlas): "
if termux-tts-speak -l cs-CZ "Test" &>/dev/null; then
    echo "✅"
else
    echo "❌"
fi

echo -n "  Speech-to-Text: "
if termux-speech-to-text -t 2 &>/dev/null; then
    echo "✅"
else
    echo "❌"
fi

echo ""
echo "✅ Základní ověření dokončeno."
echo "📋 Pro podrobnější test spusťte: ./starcore battery"
