#!/bin/bash
# STARCORE – Automatické nahrání na GitHub
# Verze 1.0

set -e

cd ~/STARCORE

echo "════════════════════════════════════════════════════════════"
echo "  🚀 STARCORE – Nahrání na GitHub"
echo "════════════════════════════════════════════════════════════"
echo ""

# 1. Záloha citlivých souborů
echo "📦 Záloha citlivých souborů..."
mkdir -p ~/STARCORE_backup
cp data/ai_config.json ~/STARCORE_backup/ 2>/dev/null || echo "  (žádný ai_config.json)"
cp data/logs/*.log ~/STARCORE_backup/ 2>/dev/null || echo "  (žádné logy)"
echo "✅ Záloha uložena do ~/STARCORE_backup"

# 2. Odstranění starého .git
echo ""
echo "🗑️  Odstraňuji starý .git..."
rm -rf .git
echo "✅ Starý repozitář odstraněn"

# 3. Inicializace nového repozitáře
echo ""
echo "🔄 Inicializuji nový repozitář..."
git init
echo "✅ Nový repozitář vytvořen"

# 4. Vytvoření .gitignore
echo ""
echo "📝 Vytvářím .gitignore..."
cat > .gitignore << 'GITIGNORE'
# Python
__pycache__/
*.py[cod]
*$py.class
*.so
.Python
env/
venv/
ENV/
build/
develop-eggs/
dist/
downloads/
eggs/
.eggs/
lib/
lib64/
parts/
sdist/
var/
wheels/
*.egg-info/
.installed.cfg
*.egg
MANIFEST

# STARCORE specific – citlivé soubory
data/ai_config.json
data/*.log
data/logs/*.log
data/agents.json
data/hive_state.json
data/orchestrator.json
*.env
.venv
.vscode/
.idea/
*.swp
*.swo
*~
.DS_Store
GITIGNORE
echo "✅ .gitignore vytvořen"

# 5. Přidání souborů
echo ""
echo "📂 Přidávám soubory do repozitáře..."
git add .
echo "✅ Soubory přidány"

# 6. Commit
echo ""
echo "📝 Vytvářím commit..."
git commit -m "STARCORE Mobile v1.0 – finální verze"
echo "✅ Commit vytvořen"

# 7. Přidání remote
echo ""
echo "🔗 Přidávám remote origin..."
git remote add origin https://github.com/Fatalerorr69/STARCORE.git
echo "✅ Remote přidán"

# 8. Push na GitHub
echo ""
echo "⬆️  Nahrávám na GitHub..."
git push -u origin main --force
echo "✅ Kód nahrán"

# 9. Tag v1.0
echo ""
echo "🏷️  Vytvářím tag v1.0..."
git tag -f v1.0
git push origin v1.0 --force
echo "✅ Tag v1.0 vytvořen a nahrán"

# 10. Obnovení citlivých souborů (pro lokální použití)
echo ""
echo "📂 Obnovuji citlivé soubory lokálně..."
cp ~/STARCORE_backup/ai_config.json data/ 2>/dev/null || echo "  (žádný ai_config.json k obnově)"
cp ~/STARCORE_backup/*.log data/logs/ 2>/dev/null || echo "  (žádné logy k obnově)"
echo "✅ Citlivé soubory obnoveny"

echo ""
echo "════════════════════════════════════════════════════════════"
echo "  ✅ HOTOVO! Repozitář byl vyčištěn a nahrán na GitHub."
echo "════════════════════════════════════════════════════════════"
echo ""
echo "🔗 https://github.com/Fatalerorr69/STARCORE"
echo ""
echo "📌 Lokální konfigurace (API klíče, logy) byla obnovena."
echo "📌 .gitignore chrání citlivé soubory před dalším nahráním."
