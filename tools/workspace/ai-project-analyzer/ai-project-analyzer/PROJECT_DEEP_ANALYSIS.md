# Hluboká analýza: ai-project-analyzer

## Základní informace
- **Cílová cesta:** $targetPath
- **Detekované technologie:** Python, Shell
- **Počet skriptů:** 13

## Popis z README
# AI PROJECT ANALYZER

Univerzální nástroj pro analýzu projektů a automatickou rekonstrukci nové soběstačné struktury pomocí LLM.
Podporuje cloudové i lokální modely, webové UI (Streamlit), FastAPI backend, ChromaDB paměť a pluginy.

## Hlavní funkce
- Analýza celé složky (kódy, configy, dokumentace)
- Paralelizované zpracování souborů
- Plugin systém (detekce tajemství, dockerfile, závislosti)
- Generování nové projektové struktury (
> ew_structure.md`)
- Automatický codegen (převod 
> ew_structure.md` → soubory)
- Podpora modelů: OpenAI, Anthropic, Google Gemini, Ollama/LocalAI
- Volitelná podpora GPU (NVIDIA/ROCm)
- Systemd service + CI workflow

## Struktura repozitáře
AI-PROJECT-ANALYZER/
├── install_universal_ai_analyzer.sh
├── README.md
├── requirements.txt
├── docker-compose.yml
├── .gitignore
├── .gitattributes
├── .github/
│ └── workflows/
│ └── build.yml
├── src/
│ ├── main.py
│ ├── analyzer/
│ │ ├── structure_scanner.py
│ │ ├── ai_brain.py
│ │ ├── reconstructor.py
│ │ ├── memory.py
│ │ └── utils.py
│ └── webui/
│ └── app.py
└── data/
├── projects/
└── outputs/

## Rychlý start (po nahrání na server)
1. Přihlas se do stroje a spusť:
   ```bash
   sudo chmod +x install_universal_ai_analyzer.sh
   sudo ./install_universal_ai_analyzer.sh
Po dokončení otevři web UI: http://<IP>:8501

Nahraj projekt do /opt/ai_project_analyzer/data/input nebo přes UI a spusť Run analysis.

Poté Generate new_structure.md a Run codegen.

Bezpečnost
API klíče se ukládají do /etc/ai_project_analyzer/env s právy 600.

Neblokuj veřejný přístup na produkční stroj bez autentizace (když vystavuješ Streamlit, použij reverzní proxy + auth).

Contributing
Přidej plugin do plugins/ — Python modul s funkcí analyze(path, content) -> dict.


## Seznam skriptů
- `tools\ai-project-analyzer\plugins\deploy_script_generator.py` – deploy_script_generator.py
- `tools\ai-project-analyzer\plugins\secret_detector_enhanced.py` – enhanced secret detector
- `tools\ai-project-analyzer\plugins\static_analysis.py` – static_analysis.py
- `tools\ai-project-analyzer\src\analyzer\ai_brain.py` – ai_brain.py
- `tools\ai-project-analyzer\src\analyzer\analyzer.py` – !/usr/bin/env python3
- `tools\ai-project-analyzer\src\analyzer\memory.py` – memory.py
- `tools\ai-project-analyzer\src\analyzer\reconstructor.py` – reconstructor.py
- `tools\ai-project-analyzer\src\analyzer\structure_scanner.py` – structure_scanner.py
- `tools\ai-project-analyzer\src\analyzer\utils.py` – utils.py
- `tools\ai-project-analyzer\src\generator\generator.py` – !/usr/bin/env python3
- `tools\ai-project-analyzer\src\webui\app.py` – (this file is already provided as webui/app.py in install script and earlier)
- `tools\ai-project-analyzer\utils\git_autocommit.py` – !/usr/bin/env python3
- `tools\ai-project-analyzer\install_universal_ai_analyzer.sh` – !/usr/bin/env bash


## Hodnocení a doporučení
<!-- Doplňte na základě výše uvedených informací -->
- 
