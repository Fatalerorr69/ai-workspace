<#
    ===============================================================
            StarkoAI Suite 2.1 – AUTOMATICKÝ BUILD ZIP
    ===============================================================

    Funkce:
    - vyčistí staré buildy
    - vytvoří dist/
    - zkompletuje GUI, dashboard, pluginy, memory, venv
    - ověří strukturu projektu
    - vytvoří ZIP: StarkoAI_Suite_2.1.zip

    Autor: Starko
    Verze skriptu: 2.1.0
#>

# -------------------------
# Nastavení cest
# -------------------------
$Root = Split-Path -Parent $MyInvocation.MyCommand.Path
$Dist = Join-Path $Root "dist"
$ZipPath = Join-Path $Dist "StarkoAI_Suite_2.1.zip"
$LogFile = Join-Path $Dist "build_log.txt"

# -------------------------
# Funkce pro logování
# -------------------------
function Log($msg) {
    $timestamp = (Get-Date).ToString("yyyy-MM-dd HH:mm:ss")
    Add-Content -Path $LogFile -Value "[$timestamp] $msg"
    Write-Host $msg -ForegroundColor Cyan
}

# -------------------------
# Start
# -------------------------
Write-Host "============================================================="
Write-Host "          SPUŠTĚNÍ BUILDU StarkoAI Suite 2.1" -ForegroundColor Green
Write-Host "============================================================="

# -------------------------
# Vytvoří dist + čistka
# -------------------------
Log "Čištění dist složky..."

if (Test-Path $Dist) {
    Remove-Item $Dist -Recurse -Force -ErrorAction SilentlyContinue
}
New-Item -ItemType Directory -Path $Dist | Out-Null

Set-Content -Path $LogFile -Value "==== Build log StarkoAI Suite 2.1 ===="

# -------------------------
# Kontrola složek projektu
# -------------------------
$Expected = @(
    "gui",
    "dashboard",
    "plugins",
    "datasets",
    "memory",
    "scripts",
    "models",
    "static",
    "templates",
    "backups",
    "logs",
    "venv"
)

foreach ($folder in $Expected) {
    $path = Join-Path $Root $folder
    if (-not (Test-Path $path)) {
        Log "CHYBA – chybí složka: $folder"
    } else {
        Log "OK – složka existuje: $folder"
    }
}

# -------------------------
# Kopírování všech souborů do sestavy
# -------------------------
Log "Kopírování projektu do dist/StarkoAI_Suite_2.1..."

$BuildRoot = Join-Path $Dist "StarkoAI_Suite_2.1"
New-Item -ItemType Directory -Path $BuildRoot | Out-Null

foreach ($folder in $Expected) {
    $src = Join-Path $Root $folder
    $dst = Join-Path $BuildRoot $folder
    Copy-Item $src $dst -Recurse -Force -ErrorAction Stop
    Log "Přenesen obsah: $folder"
}

# -------------------------
# Kopírování hlavních build skriptů
# -------------------------
$MainScripts = @(
    "install_starko_ai_suite_full.ps1",
    "build_starko_ai_suite_2.1.ps1",
    "update_suite.ps1"
)

foreach ($file in $MainScripts) {
    $src = Join-Path $Root $file
    if (Test-Path $src) {
        Copy-Item $src $BuildRoot -Force
        Log "Přenesen hlavní skript: $file"
    }
}

# -------------------------
# Vyčištění nepotřebných souborů
# -------------------------
Log "Vyčištění nepotřebných souborů..."

$PatternsToDelete = @(
    "*~",
    "*.tmp",
    "*.log",
    "Thumbs.db",
    "*.cache",
    "__pycache__"
)

foreach ($pattern in $PatternsToDelete) {
    Get-ChildItem -Path $BuildRoot -Recurse -Filter $pattern -ErrorAction SilentlyContinue |
        Remove-Item -Force -Recurse -ErrorAction SilentlyContinue
}

Log "Čistka dokončena."

# -------------------------
# Vytvoření ZIP archivu
# -------------------------
Log "Tvorba ZIP archivu StarkoAI_Suite_2.1.zip..."

Compress-Archive -Path "$BuildRoot\*" -DestinationPath $ZipPath -Force

if (Test-Path $ZipPath) {
    Log "ZIP vytvořen úspěšně: $ZipPath"
} else {
    Log "CHYBA – ZIP se nepodařilo vytvořit!"
}

# -------------------------
# Konec
# -------------------------
Write-Host ""
Write-Host "============================================================="
Write-Host "   HOTOVO – StarkoAI Suite 2.1 byl úspěšně sestaven" -ForegroundColor Green
Write-Host "   Výstupní ZIP: $ZipPath"
Write-Host "============================================================="

Log "Build dokončen."
