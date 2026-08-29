#!/bin/bash
# STARCORE Common Fixes

cd ~/STARCORE
echo "🔧 Opravuji běžné problémy..."

# 1. Oprava importů AI
if grep -q "AIRuntime" ai/__init__.py 2>/dev/null; then
    echo "  Opravuji ai/__init__.py..."
    cat > ai/__init__.py << "FIXEOF"
from . import runtime
from .commands import start, stop, status, config, query, test, local_setup
FIXEOF
fi

# 2. Oprava oprávnění
chmod +x starcore
chmod +x ~/STARCORE/scripts/*.sh

# 3. Kontrola adresářů
mkdir -p data logs

# 4. Reset AI Runtime (pokud je zaseknutý)
pkill -f "starcore.*ai" 2>/dev/null

echo "✅ Opravy dokončeny."
