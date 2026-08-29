#!/bin/bash
# STARCORE Full System Check

cd ~/STARCORE
echo "═══════════════════════════════════════════════════════════"
echo "  STARCORE Full System Check"
echo "═══════════════════════════════════════════════════════════"

# 1. Spuštění interního checku
./starcore check

# 2. Kontrola běžících procesů
echo ""
echo "🔍 Běžící procesy STARCORE:"
ps aux | grep -E "starcore|ollama|uvicorn" | grep -v grep

# 3. Kontrola přístupnosti API
echo ""
echo "🌐 Test API endpointů:"
for endpoint in "/health" "/api/status" "/api/services"; do
    curl -s -o /dev/null -w "%{http_code}" http://localhost:8000$endpoint | grep -q 200 && echo "  ✅ $endpoint OK" || echo "  ❌ $endpoint FAIL"
done

# 4. Test AI dotazu
echo ""
echo "🤖 Test AI dotazu (OpenRouter):"
./starcore ai-start > /dev/null 2>&1
RESPONSE=$(./starcore ai-query "Řekni 'Ahoj'" --system "Odpověz jedním slovem.")
./starcore ai-stop > /dev/null 2>&1
if [[ "$RESPONSE" == *"Ahoj"* ]]; then
    echo "  ✅ AI odpovídá"
else
    echo "  ❌ AI neodpovídá: $RESPONSE"
fi

echo ""
echo "═══════════════════════════════════════════════════════════"
echo "  Kontrola dokončena."
echo "═══════════════════════════════════════════════════════════"
