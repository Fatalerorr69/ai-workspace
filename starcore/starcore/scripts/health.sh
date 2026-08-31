#!/bin/bash
# STARCORE Health Check & Repair

cd ~/STARCORE
echo "═══════════════════════════════════════════════════════════"
echo "  STARCORE Health Check & Repair"
echo "═══════════════════════════════════════════════════════════"

# 1. Základní systém
echo ""
echo "📦 1. Základní systém"
python3 --version 2>/dev/null && echo "  ✅ Python" || echo "  ❌ Python"
git --version 2>/dev/null && echo "  ✅ Git" || echo "  ❌ Git"
tmux -V 2>/dev/null && echo "  ✅ tmux" || echo "  ❌ tmux"

# 2. STARCORE CLI
echo ""
echo "🖥️  2. STARCORE CLI"
./starcore version 2>/dev/null && echo "  ✅ version" || echo "  ❌ version"
./starcore doctor 2>/dev/null >/dev/null && echo "  ✅ doctor" || echo "  ❌ doctor"

# 3. Služby
echo ""
echo "⚙️  3. Service Manager"
./starcore status 2>/dev/null | grep -q "running" && echo "  ✅ Služby běží" || echo "  ⚠️  Žádné služby neběží"

# 4. HIVE
echo ""
echo "🐝 4. HIVE Engine"
if ./starcore hive-status 2>/dev/null | grep -q "Running"; then
    echo "  ✅ HIVE běží"
else
    echo "  ⚠️  HIVE zastaven – spouštím..."
    ./starcore hive-start
fi

# 5. AI
echo ""
echo "🤖 5. AI Runtime"
if ./starcore ai-status 2>/dev/null | grep -q "Running"; then
    echo "  ✅ AI běží"
else
    echo "  ⚠️  AI zastaven – spouštím..."
    ./starcore ai-start
fi

# 6. Dashboard
echo ""
echo "🌐 6. Dashboard"
if curl -s -o /dev/null -w "%{http_code}" http://localhost:8000/health 2>/dev/null | grep -q "200"; then
    echo "  ✅ Dashboard běží"
else
    echo "  ⚠️  Dashboard nedostupný – spouštím..."
    ./starcore start dashboard
fi

# 7. Welcome screen
echo ""
echo "🖼️  7. Welcome screen"
python3 welcome.py 2>/dev/null >/dev/null && echo "  ✅ Welcome.py OK" || echo "  ❌ Welcome.py chyba"

# 8. Rozšíření
echo ""
echo "📦 8. Rozšíření"
for ext in vision network sync backup; do
    if python3 -c "import extensions.$ext" 2>/dev/null; then
        echo "  ✅ $ext"
    else
        echo "  ❌ $ext"
    fi
done

# 9. Logy
echo ""
echo "📄 9. Logy"
for log in data/logs/*.log; do
    if [ -f "$log" ]; then
        echo "  ✅ $(basename $log) - $(tail -1 $log 2>/dev/null | head -c 50)"
    fi
done

echo ""
echo "═══════════════════════════════════════════════════════════"
echo "  Health check dokončen."
echo "═══════════════════════════════════════════════════════════"
