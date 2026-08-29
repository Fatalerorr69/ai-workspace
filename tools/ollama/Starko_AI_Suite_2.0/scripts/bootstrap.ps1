# Aktivace venv
Write-Host "[INFO] Aktivace virtuálního prostředí..."
& ..\venv\Scripts\Activate.ps1

# Spuštění dashboardu
Write-Host "[INFO] Spuštění Web Dashboardu..."
python ..\dashboard\main.py
