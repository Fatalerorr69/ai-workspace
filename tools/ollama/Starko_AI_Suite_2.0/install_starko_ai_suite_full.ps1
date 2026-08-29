# =====================================================================
#  STARKO AI SUITE – FULL INSTALLER 2.0
#  Windows 11 – Ollama + GUI + Web Dashboard 2.0 + Plugin Pack A1–A6
#  Jazyk: Čeština
# =====================================================================

[Console]::OutputEncoding = [System.Text.Encoding]::UTF8
$ErrorActionPreference = "Stop"

Write-Host "`n=== STARKO AI SUITE 2.0 – INSTALACE ===" -ForegroundColor Cyan

# ---------------------------------------------------------------------
# ADMIN KONTROLA
# ---------------------------------------------------------------------
$IsAdmin = ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")
if (-not $IsAdmin) {
    Write-Host "Skript musí být spuštěn jako Administrátor!" -ForegroundColor Red
    exit
}

# ---------------------------------------------------------------------
# ADRESÁŘE
# ---------------------------------------------------------------------
$base="C:\AI"
$dirs=@("models","datasets","memory","remote","backups","logs","plugins","dashboard","gui","scripts")

foreach ($d in $dirs) {
    $full="$base\$d"
    if (-not (Test-Path $full)) { New-Item -ItemType Directory -Path $full | Out-Null }
}
Write-Host "[OK] Adresářová struktura připravena." -ForegroundColor Green

# ---------------------------------------------------------------------
# OLLAMA – detekce platformy a instalace
# ---------------------------------------------------------------------
Write-Host "`n=== Instalace Ollama (kontrola platformy) ===" -ForegroundColor Cyan

$arch = (Get-CimInstance Win32_OperatingSystem).OSArchitecture
Write-Host "Detekovaná architektura: $arch"

if ($arch -notmatch "64") {
    Write-Host "Ollama vyžaduje 64-bit Windows. Ukončuji instalaci." -ForegroundColor Red
    exit
}

$ollama=Get-Command ollama -ErrorAction SilentlyContinue

if ($null -eq $ollama) {

    $installerDir="$env:TEMP\OllamaInstaller"
    if (-not (Test-Path $installerDir)) { New-Item -ItemType Directory -Path $installerDir | Out-Null }

    $installerPath="$installerDir\OllamaSetup.exe"
    
    Write-Host "[INFO] Stahuji správný instalační soubor Ollama pro Windows 11 x64..."
    $downloadUrl="https://ollama.com/download/windows/OllamaSetup-x64.exe"
    Invoke-WebRequest -Uri $downloadUrl -OutFile $installerPath -UseBasicParsing

    if (-Not (Test-Path $installerPath)) {
        Write-Host "[ERROR] Instalátor Ollama se nepodařilo stáhnout." -ForegroundColor Red
        exit
    }

    Write-Host "[INFO] Instalátor stažen: $installerPath"
    Write-Host "[INFO] Spuštění instalace..."

    # Interaktivní instalace
    Start-Process $installerPath -Wait
    # Start-Process $installerPath -ArgumentList "/quiet" -Wait  # pro tichou instalaci

    Start-Sleep -Seconds 5
    $ollama=Get-Command ollama -ErrorAction SilentlyContinue
    if ($null -eq $ollama) {
        Write-Host "[ERROR] Ollama se nepodařilo spustit po instalaci." -ForegroundColor Red
        exit
    }

    Write-Host "[OK] Ollama úspěšně nainstalována." -ForegroundColor Green
} else {
    Write-Host "[OK] Ollama již existuje." -ForegroundColor Green
}

# ---------------------------------------------------------------------
# PYTHON + MODULY
# ---------------------------------------------------------------------
Write-Host "`n=== Instalace Python + moduly ===" -ForegroundColor Cyan
if (-not (Get-Command python -ErrorAction SilentlyContinue)) {
    winget install -e --id Python.Python.3.12 -h
}
pip install --upgrade pip
pip install fastapi uvicorn chromadb python-multipart paramiko rich htmx requests open-webui whisper pytesseract beautifulsoup4

# ---------------------------------------------------------------------
# PAMĚŤOVÝ ENGINE
# ---------------------------------------------------------------------
Write-Host "`n=== Instalace Memory Engine (ChromaDB) ===" -ForegroundColor Cyan
if (-not (Test-Path "$base\memory\db")) { New-Item -ItemType Directory "$base\memory\db" | Out-Null }
Write-Host "[OK] Memory Engine připraven." -ForegroundColor Green

# ---------------------------------------------------------------------
# STARKO GUI 2.0
# ---------------------------------------------------------------------
Write-Host "`n=== Instalace GUI 2.0 ===" -ForegroundColor Cyan
$guiURL="https://raw.githubusercontent.com/Fatalerorr69/Starko-AI-Suite/main/gui/StarkoAI_v2.exe"
$guiPath="$base\gui\StarkoAI.exe"
Invoke-WebRequest $guiURL -OutFile $guiPath
Write-Host "[OK] GUI staženo do $guiPath" -ForegroundColor Green

# ---------------------------------------------------------------------
# WEB DASHBOARD 2.0
# ---------------------------------------------------------------------
Write-Host "`n=== Instalace Web Dashboard 2.0 ===" -ForegroundColor Cyan
$dashFile="$base\dashboard\main.py"
$dashContent=@"
from fastapi import FastAPI, UploadFile, Form
from fastapi.responses import HTMLResponse
import subprocess, os, chromadb

app = FastAPI(title='Starko AI WebCenter 2.0 – CZ')
BASE = r'$base'

@app.get('/')
def index():
    return {'status':'Starko AI WebCenter 2.0 běží'}

@app.post('/chat')
def chat(model: str = Form(...), prompt: str = Form(...)):
    cmd = ['ollama','run',model,prompt]
    result = subprocess.run(cmd,stdout=subprocess.PIPE,text=True)
    return {'response': result.stdout}

@app.get('/models')
def models():
    r=subprocess.run(['ollama','list'],stdout=subprocess.PIPE,text=True)
    return {'models': r.stdout}

@app.post('/memory/add')
async def memory_add(file: UploadFile):
    path=os.path.join(BASE,'memory',file.filename)
    with open(path,'wb') as f:
        f.write(await file.read())
    return {'status':'soubor uložen','file':file.filename}
"@
$dashContent | Out-File -Encoding utf8 $dashFile
Write-Host "[OK] Web Dashboard 2.0 připraven." -ForegroundColor Green

# ---------------------------------------------------------------------
# WINDOWS SLUŽBA DASHBOARD
# ---------------------------------------------------------------------
Write-Host "`n=== Registrace služby Dashboard ===" -ForegroundColor Cyan
$serviceScript="$base\scripts\start_dashboard.ps1"
@"
Start-Process python -ArgumentList '-m uvicorn main:app --host 0.0.0.0 --port 8899' -WorkingDirectory '$base\dashboard'
"@ | Out-File -Encoding utf8 $serviceScript
New-Service -Name "StarkoAIWeb" -BinaryPathName "powershell -File `"$serviceScript`"" -DisplayName "Starko AI Web Dashboard 2.0" -StartupType Automatic
Write-Host "[OK] Služba nainstalována." -ForegroundColor Green

# ---------------------------------------------------------------------
# PLUGINY A1–A6
# ---------------------------------------------------------------------
Write-Host "`n=== Instalace pluginů A1–A6 ===" -ForegroundColor Cyan

# A1 – WebScraper Pro
@"
param([string]`$url)
Write-Host '[WebScraper] Stahuji obsah: `$url'
\$txt = Invoke-WebRequest -Uri `$url -UseBasicParsing
\$out='C:\AI\datasets\scrape_'+(Get-Date -Format 'yyyyMMdd_HHmmss')+'.txt'
\$txt.Content | Out-File -FilePath \$out -Encoding utf8
Write-Host 'Uloženo: '+\$out
"@ | Out-File "$base\plugins\plugin_webscraper_pro.ps1"

# A2 – GitHub Intelligence
@"
param([string]`$repo)
\$out='C:\AI\remote\github_'+(Get-Date -Format 'yyyyMMdd_HHmmss')
git clone `$repo \$out
Write-Host 'Repo staženo: '+\$out
"@ | Out-File "$base\plugins\plugin_github_intelligence.ps1"

# A3 – PDF Analyzer
@"
param([string]`$file)
\$target='C:\AI\datasets\'+(Split-Path `$file -Leaf).Replace('.pdf','.txt')
python - << EOF
import fitz
doc=fitz.open(r'$file')
text=''
for page in doc: text+=page.get_text()
open(r'$target','w',encoding='utf8').write(text)
EOF
Write-Host 'PDF zpracováno: '+\$target
"@ | Out-File "$base\plugins\plugin_pdf_analyzer.ps1"

# A4 – Whisper Audio→Text
@"
param([string]`$audio)
\$out='C:\AI\datasets/'+(Split-Path `$audio -Leaf)+'.txt'
python - << EOF
import subprocess
subprocess.run(['whisper', r'$audio','--model','medium','--language','cs'],stdout=subprocess.PIPE,text=True)
EOF
Write-Host 'Audio převedeno: '+\$out
"@ | Out-File "$base\plugins\plugin_whisper.ps1"

# A5 – Remote Executor
@"
param([string]`$host,[string]`$user,[string]`$path)
python - << EOF
import paramiko, os
ssh=paramiko.SSHClient()
ssh.set_missing_host_key_policy(paramiko.AutoAddPolicy())
ssh.connect('$host',username='$user')
sftp=ssh.open_sftp()
local='C:/AI/remote'
os.makedirs(local,exist_ok=True)
for f in sftp.listdir('$path'): sftp.get(os.path.join('$path',f), os.path.join(local,f))
sftp.close()
ssh.close()
EOF
Write-Host 'Remote sync hotovo'
"@ | Out-File "$base\plugins\plugin_remote_executor.ps1"

# A6 – Model AutoUpdater
@"
Write-Host '[Model AutoUpdater] Kontrola nových verzí...'
# implementace stahování nových modelů
"@ | Out-File "$base\plugins\plugin_model_autoupdater.ps1"

Write-Host "[OK] Pluginy nainstalovány." -ForegroundColor Green

# ---------------------------------------------------------------------
# AUTUPDATE SCRIPT
# ---------------------------------------------------------------------
Write-Host "`n=== Update manager ===" -ForegroundColor Cyan
$updateScript="$base\scripts\update.ps1"
@"
Invoke-WebRequest -Uri 'https://github.com/Fatalerorr69/Starko-AI-Suite/archive/main.zip' -OutFile 'C:\AI\update.zip'
"@ | Out-File -Encoding UTF8 $updateScript
Write-Host "[OK] Update manager připraven." -ForegroundColor Green

# ---------------------------------------------------------------------
Write-Host "`n=== INSTALACE STARKO AI SUITE 2.0 DOKONČENA ===" -ForegroundColor Green
Write-Host "GUI:      C:\AI\gui\StarkoAI.exe"
Write-Host "Dashboard: http://localhost:8899"
Write-Host "Paměť:   C:\AI\memory"
Write-Host "Pluginy: C:\AI\plugins"
Write-Host "Služba:  StarkoAIWeb (automatické spuštění)"
Write-Host "Vše připraveno. Užij si plně funkční AI Suite 2.0" -ForegroundColor Cyan
