param(
    [switch]$Force
)

Write-Host "=== Instalátor Starko AI Suite 2.1 ===" -ForegroundColor Cyan

# Kontrola spuštění jako Admin
if (-not ([Security.Principal.WindowsPrincipal] `
    [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole(`
    [Security.Principal.WindowsBuiltinRole]::Administrator)) {

    Write-Host "Tento instalátor MUSÍ běžet jako administrátor." -ForegroundColor Red
    exit
}

# Adresář projektu
$root = "$PSScriptRoot"
Write-Host "Instaluji do: $root"

# Instalace Pythonu
Write-Host "Kontroluji Python..." -ForegroundColor Yellow
if (-not (Get-Command python.exe -ErrorAction SilentlyContinue)) {
    Write-Host "Python nebyl nalezen. Instaluji..." -ForegroundColor Cyan
    winget install Python.Python.3.11 -h --accept-package-agreements --accept-source-agreements
}

# Instalace Ollama
Write-Host "Instaluji Ollama..." -ForegroundColor Yellow
Invoke-WebRequest -Uri "https://ollama.com/download/OllamaSetup.exe" -OutFile "OllamaSetup.exe"
Start-Process .\OllamaSetup.exe -ArgumentList "/quiet" -Wait

# Virtuální prostředí
Write-Host "Vytvářím virtuální prostředí..." -ForegroundColor Yellow
python -m venv venv
.\venv\Scripts\pip install -r requirements.txt

Write-Host "Hotovo."
