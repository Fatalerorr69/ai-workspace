<#
.SYNOPSIS
    Univerzální migrační skript pro ai-workspace monorepo.
.DESCRIPTION
    Podporuje migraci repozitářů do monorepa podle specifikace v CSV souborech.
    Verze v1 a v2 se liší způsobem zpracování (v1 = starší, v2 = novější s pokročilým loggingem).
.PARAMETER Version
    Verze migračního postupu: "v1" nebo "v2" (výchozí "v2").
.PARAMETER Resume
    Pokračuje v přerušené migraci (čte stav z migration_state.csv).
.PARAMETER AutoConfirm
    Automaticky potvrzuje všechny dotazy (pro bezobslužný běh).
.PARAMETER MonorepoUrl
    URL cílového monorepa (výchozí https://github.com/Fatalerorr69/ai-workspace.git).
.PARAMETER LogFile
    Cesta k log souboru (výchozí logs/migration_$(Get-Date -Format yyyy-MM).log).
.EXAMPLE
    .\run_migration.ps1 -Version v2 -Resume
.EXAMPLE
    .\run_migration.ps1 -Version v1 -AutoConfirm -MonorepoUrl https://github.com/example/repo.git
#>

param(
    [ValidateSet('v1', 'v2')]
    [string]$Version = 'v2',
    [switch]$Resume,
    [switch]$AutoConfirm,
    [string]$MonorepoUrl = "https://github.com/Fatalerorr69/ai-workspace.git",
    [string]$LogFile = "logs\migration_$(Get-Date -Format 'yyyy-MM').log"
)

# --- Globální nastavení ---
$ErrorActionPreference = "Stop"
$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$DataDir = Join-Path $ScriptDir "..\data"
$MigrationStateFile = Join-Path $DataDir "migration_state.csv"

# --- Logovací funkce ---
function Write-Log {
    param([string]$Message, [ValidateSet('INFO','WARN','ERROR')][string]$Level = 'INFO')
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    $line = "[$timestamp] [$Level] $Message"
    $logDir = Split-Path $LogFile -Parent
    if (-not (Test-Path $logDir)) { New-Item -Path $logDir -ItemType Directory -Force | Out-Null }
    Add-Content -Path $LogFile -Value $line
    if ($Level -eq 'ERROR') { Add-Content -Path "logs\errors_$(Get-Date -Format 'yyyy-MM').log" -Value $line }
    $color = @{INFO='Cyan'; WARN='Yellow'; ERROR='Red'}[$Level]
    Write-Host $line -ForegroundColor $color
}

# --- Kontrola závislostí ---
function Test-Prerequisites {
    Write-Log "Kontrola předpokladů..." "INFO"
    if (-not (Get-Command git -ErrorAction SilentlyContinue)) {
        Write-Log "Git není nainstalován." "ERROR"
        return $false
    }
    if (-not (Get-Command git-filter-repo -ErrorAction SilentlyContinue)) {
        Write-Log "git-filter-repo není nainstalován (pip install git-filter-repo)." "WARN"
        Write-Host "⚠️ git-filter-repo chybí, ale pokračujeme (některé funkce mohou selhat)." -ForegroundColor Yellow
    }
    if (-not $env:GITHUB_TOKEN -and -not $AutoConfirm) {
        Write-Log "Proměnná GITHUB_TOKEN není nastavena." "WARN"
        Write-Host "⚠️ Nastav $env:GITHUB_TOKEN pro přístup k GitHub API." -ForegroundColor Yellow
    }
    return $true
}

# --- Hlavní logika podle verze ---
function Invoke-Migration {
    Write-Log "Spouštím migraci verze $Version..." "INFO"
    if ($Resume) { Write-Log "Režim RESUMEN – pokračuji od posledního stavu." "INFO" }
    
    # Simulace migrace (ve skutečnosti sem vlož konkrétní logiku z původních skriptů)
    # Pro ukázku jen vypíšeme, co by se dělalo.
    Write-Host "🔧 Migrace verze $Version – simulace" -ForegroundColor Cyan
    if ($Resume) { Write-Host "  ➡️ Pokračuji z posledního bodu." -ForegroundColor Yellow }
    if ($AutoConfirm) { Write-Host "  ➡️ Automatické potvrzování zapnuto." -ForegroundColor Gray }
    
    # Zde by následovala reálná migrační logika (fork/clone, git-filter-repo, push atd.)
    Write-Log "Migrace verze $Version dokončena (simulace)." "INFO"
}

# --- Spuštění ---
Write-Host "🚀 Spouštím run_migration.ps1 (verze $Version)..." -ForegroundColor Cyan
if (-not (Test-Prerequisites)) { exit 1 }
Invoke-Migration
Write-Host "✅ Skript dokončen." -ForegroundColor Green
