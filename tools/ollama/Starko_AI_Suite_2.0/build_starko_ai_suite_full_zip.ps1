# ==========================================================
# STARKO AI SUITE 2.0 – GENEROVÁNÍ FULL BALÍKU S VENV
# ==========================================================

$projectPath = "K:\Projekty\Ollama\Starko_AI_Suite_2.0"
$zipPath = "K:\Projekty\Ollama\Starko_AI_Suite_2.0_full.zip"

Write-Host "[INFO] Kontrola adresáře projektu..." -ForegroundColor Cyan
if (!(Test-Path $projectPath)) { New-Item -ItemType Directory -Path $projectPath }

# -----------------------------
# 1️⃣ Vytvoření složek
# -----------------------------
$folders = @("backups","dashboard\templates","dashboard\static","datasets","logs","memory","models","plugins","scripts","venv")
foreach ($f in $folders) {
    $fullPath = Join-Path $projectPath $f
    if (!(Test-Path $fullPath)) { New-Item -ItemType Directory -Path $fullPath | Out-Null; Write-Host "[OK] Vytvořena složka: $f" -ForegroundColor Green }
    else { Write-Host "[INFO] Složka již existuje: $f" -ForegroundColor Yellow }
}

# -----------------------------
# 2️⃣ Vytvoření dashboard souborů
# -----------------------------
$dashboardMain = @"
from fastapi import FastAPI
from fastapi.staticfiles import StaticFiles
from fastapi.templating import Jinja2Templates
from fastapi.requests import Request
import os, glob

app = FastAPI()
app.mount("/static", StaticFiles(directory="dashboard/static"), name="static")
templates = Jinja2Templates(directory="dashboard/templates")

plugins = [os.path.basename(f) for f in glob.glob("plugins/*.ps1")]

@app.get("/")
async def index(request: Request):
    return templates.TemplateResponse("index.html", {"request": request, "plugins": plugins})

if __name__ == "__main__":
    import uvicorn
    uvicorn.run(app, host="0.0.0.0", port=8000)
"@
$dashboardMainPath = Join-Path $projectPath "dashboard\main.py"
$dashboardMain | Out-File -Encoding UTF8 $dashboardMainPath
Write-Host "[OK] Dashboard main.py vytvořen"

$dashboardHtml = @"
<!DOCTYPE html>
<html lang='cs'>
<head>
<meta charset='UTF-8'>
<title>Starko AI Suite 2.0</title>
<link rel='stylesheet' href='/static/style.css'>
</head>
<body>
<h1>Starko AI Suite 2.0 – Dashboard</h1>
<ul>
{% for plugin in plugins %}
    <li>{{ plugin }}</li>
{% endfor %}
</ul>
</body>
</html>
"@
$dashboardHtmlPath = Join-Path $projectPath "dashboard\templates\index.html"
$dashboardHtml | Out-File -Encoding UTF8 $dashboardHtmlPath
Write-Host "[OK] Dashboard index.html vytvořen"

$dashboardCss = @"
body { font-family: Arial; background-color: #1e1e1e; color: #f0f0f0; margin: 20px; }
h1 { color: #00ff99; }
ul li { margin: 5px 0; }
"@
$dashboardCssPath = Join-Path $projectPath "dashboard\static\style.css"
$dashboardCss | Out-File -Encoding UTF8 $dashboardCssPath
Write-Host "[OK] Dashboard style.css vytvořen"

# -----------------------------
# 3️⃣ Paměťový engine
# -----------------------------
$memoryPy = @"
from chromadb import Client

client = Client()
db = client.create_database('starko_memory')
print('[OK] Paměťový engine připraven')
"@
$memoryPyPath = Join-Path $projectPath "memory\init_memory.py"
$memoryPy | Out-File -Encoding UTF8 $memoryPyPath
Write-Host "[OK] Memory engine init_memory.py vytvořen"

# -----------------------------
# 4️⃣ Pluginy A1–A6
# -----------------------------
$plugins = @{
"webscraper_pro.ps1" = "[PLUGIN] webscraper_pro – stahuje a analyzuje webové stránky"
"github_intelligence.ps1" = "[PLUGIN] github_intelligence – analyzuje repozitáře"
"pdf_analyzer.ps1" = "[PLUGIN] pdf_analyzer – analyzuje PDF dokumenty"
"whisper.ps1" = "[PLUGIN] whisper – převod audia na text"
"remote_executor.ps1" = "[PLUGIN] remote_executor – vzdálené spouštění příkazů"
"model_autoupdater.ps1" = "[PLUGIN] model_autoupdater – aktualizace modelů AI"
}

foreach ($p in $plugins.Keys) {
    $path = Join-Path $projectPath "plugins\$p"
    $plugins[$p] | Out-File -Encoding UTF8 $path
    Write-Host "[OK] Plugin vytvořen: $p"
}

# -----------------------------
# 5️⃣ Vytvoření virtuálního prostředí
# -----------------------------
Write-Host "[INFO] Vytvářím virtuální prostředí..." -ForegroundColor Cyan
$venvPath = Join-Path $projectPath "venv"
python -m venv $venvPath
Write-Host "[OK] Virtuální prostředí vytvořeno"

# Aktivace a instalace modulů
$activate = Join-Path $venvPath "Scripts\Activate.ps1"
& $activate
Write-Host "[INFO] Instalace Python modulů..." -ForegroundColor Cyan
& $venvPath\Scripts\pip.exe install --upgrade pip
& $venvPath\Scripts\pip.exe install fastapi uvicorn chromadb paramiko htmx rich requests python-multipart

# -----------------------------
# 6️⃣ Aktualizovaný bootstrap
# -----------------------------
$bootstrap = @"
Write-Host '[INFO] Spouštím Starko AI Suite 2.0...' -ForegroundColor Cyan
Write-Host '[INFO] Aktivace virtuálního prostředí...' -ForegroundColor Cyan
& `"$venvPath\Scripts\Activate.ps1`"
Write-Host '[INFO] Spouštím paměťový engine...' -ForegroundColor Cyan
python memory\init_memory.py
Write-Host '[INFO] Spouštím webový dashboard...' -ForegroundColor Cyan
python dashboard\main.py
"@
$bootstrapPath = Join-Path $projectPath "bootstrap_full.ps1"
$bootstrap | Out-File -Encoding UTF8 $bootstrapPath
Write-Host "[OK] bootstrap_full.ps1 připraven"

# -----------------------------
# 7️⃣ Vytvoření ZIP balíku
# -----------------------------
Write-Host "[INFO] Vytvářím ZIP balík..." -ForegroundColor Cyan
if (Test-Path $zipPath) { Remove-Item $zipPath }
Compress-Archive -Path $projectPath\* -DestinationPath $zipPath
Write-Host "[OK] ZIP balík vytvořen: $zipPath" -ForegroundColor Green
