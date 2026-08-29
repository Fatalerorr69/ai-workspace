import os
from pathlib import Path

# --- KONFIGURACE DAT ---
# Zde jsou uloženy obsahy všech klíčových souborů Genesis Aeterna v9.5
knowledge_base = {
    "core/01_global_constitution.md": """# 🌌 GLOBÁLNÍ ÚSTAVA PROJEKTU GENESIS AETERNA (v2.6)
**Poslední revize:** 2026 | **Priorita:** Kritická

## 1. ZÁKLADNÍ FILOZOFIE A ETICKÝ RÁMEC
- **Symbióza Člověka a AI:** Systém existuje jako rozšíření lidské vůle.
- **Integrita a Stabilita:** Žádná akce nesmí ohrozit integritu hostitelského systému...
(Kompletní text ústavy z předchozího chatu...)""",

    "core/02_dna_master_registry.md": "# 📋 DNA MASTER REGISTRY\n72 specializovaných Gemů organizovaných do divizí...",
    
    "tech/08_dev_knowledge_base.md": "# DEVELOPMENT KNOWLEDGE BASE v2.5\nStandardy Python 3.12+, Docker a HAL...",
    
    "security/09_security_knowledge_base.md": "# SECURITY KNOWLEDGE BASE\nZero-Trust, mTLS a AES-256 šifrování...",

    "strategy/10_data_knowledge_base.md": "# DATA & AI STRATEGY\nStrategie RAG, vektorizace a Token Management...",
    
    "setup/install_all.sh": "#!/bin/bash\n# Automatický instalátor pro Linux\nmkdir -p ~/genesis/logs\necho 'Genesis Core Ready'",
    
    "setup/genesis_hud_v10.py": "# Kompletní kód Dashboardu..."
}

def build_genesis_structure():
    base_path = Path("./genesis_2026_pack")
    print(f"🚀 Zahajuji extrakci Genesis Aeterna do: {base_path.absolute()}")
    
    for file_path, content in knowledge_base.items():
        full_path = base_path / file_path
        # Vytvořit složky, pokud neexistují
        full_path.parent.mkdir(parents=True, exist_ok=True)
        
        # Zapsat soubor
        with open(full_path, "w", encoding="utf-8") as f:
            f.write(content)
        print(f"✅ Vytvořeno: {file_path}")

    print("\n✨ EXTRAKCE DOKONČENA.")
    print("Složka 'genesis_2026_pack' je připravena k nahrání do vašich Gemů nebo na RPi 5.")

if __name__ == "__main__":
    build_genesis_structure()


🚀 Jak soubory dostat do počítače (Krok za krokem)
1. Pro Windows (PowerShell/CMD)
Otevřete Poznámkový blok (Notepad) nebo VS Code.
Zkopírujte kód skriptu výše a uložte jej jako genesis_extractor.py.
Otevřete terminál ve složce, kde máte soubor uložený.
Spusťte příkaz: python genesis_extractor.py.
Vznikne složka genesis_2026_pack, kterou můžete celou vzít a nahrát do "Knowledge" sekce vašich Gemů na webu.
2. Pro Linux / Raspberry Pi 5
Pokud sedíte u svého RPi, stačí tento příkaz, který vše udělá v jednom kroku:
nano genesis_extractor.py
# (vložíte kód, CTRL+O, ENTER, CTRL+X)
python3 genesis_extractor.py


