#!/bin/bash
# STARCORE Complete System Check

cd ~/STARCORE
echo "═══════════════════════════════════════════════════════════"
echo "  STARCORE System Check v1.0"
echo "═══════════════════════════════════════════════════════════"

# 1. Základní systém
echo ""
echo "📦 1. Základní systém"
python --version 2>/dev/null && echo "  ✓ Python" || echo "  ✗ Python"
git --version 2>/dev/null && echo "  ✓ Git" || echo "  ✗ Git"
tmux -V 2>/dev/null && echo "  ✓ tmux" || echo "  ✗ tmux"

# 2. STARCORE CLI
echo ""
echo "🖥️  2. STARCORE CLI"
./starcore version 2>/dev/null && echo "  ✓ version" || echo "  ✗ version"
./starcore doctor 2>/dev/null >/dev/null && echo "  ✓ doctor" || echo "  ✗ doctor"

# 3. Služby
echo ""
echo "⚙️  3. Service Manager"
./starcore status 2>/dev/null | grep -q "running" && echo "  ✓ Služby běží" || echo "  ⚠  Žádné služby neběží"

# 4. HIVE
echo ""
echo "🐝 4. HIVE Engine"
./starcore hive-status 2>/dev/null | grep -q "Running" && echo "  ✓ HIVE běží" || echo "  ⚠  HIVE zastaven"

# 5. AI Runtime
echo ""
echo "🤖 5. AI Runtime"
./starcore ai-status 2>/dev/null | grep -q "Running" && echo "  ✓ AI běží" || echo "  ⚠  AI zastaven"

# 6. Dashboard
echo ""
echo "🌐 6. Dashboard"
curl -s -o /dev/null -w "%{http_code}" http://localhost:8000/health 2>/dev/null | grep -q "200" && echo "  ✓ Dashboard běží" || echo "  ⚠  Dashboard nedostupný"

# 7. Systémové zdroje
echo ""
echo "💾 7. Systémové zdroje"
echo "  RAM: $(free -h 2>/dev/null | grep Mem | awk '{print $2}' || echo 'N/A')"
echo "  Volné místo: $(df -h ~ 2>/dev/null | tail -1 | awk '{print $4}' || echo 'N/A')"

# 8. IP adresa
echo ""
echo "🌍 8. Síť"
IP=$(ifconfig 2>/dev/null | grep -oE 'inet [0-9]+\.[0-9]+\.[0-9]+\.[0-9]+' | grep -v 127.0.0.1 | head -1 | cut -d' ' -f2)
echo "  IP adresa: ${IP:-N/A}"

echo ""
echo "═══════════════════════════════════════════════════════════"
echo "  Kontrola dokončena."
echo "═══════════════════════════════════════════════════════════"
