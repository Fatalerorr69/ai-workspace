Write-Host '[INFO] Spouštím Starko AI Suite 2.0...' -ForegroundColor Cyan
Write-Host '[INFO] Aktivace virtuálního prostředí...' -ForegroundColor Cyan
& "K:\Projekty\Ollama\Starko_AI_Suite_2.0\venv\Scripts\Activate.ps1"
Write-Host '[INFO] Spouštím paměťový engine...' -ForegroundColor Cyan
python memory\init_memory.py
Write-Host '[INFO] Spouštím webový dashboard...' -ForegroundColor Cyan
python dashboard\main.py
