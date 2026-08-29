param(
    [string]$MonorepoUrl = "https://github.com/Fatalerorr69/ai-workspace.git",
    [switch]$AutoConfirm,
    [switch]$Resume
)

$ErrorActionPreference = "Stop"
$scriptDir = $PSScriptRoot
$logFile = Join-Path $scriptDir "migration_full.log"
$stateFile = Join-Path $scriptDir "migration_state.csv"
$startTime = Get-Date

function Log($msg) {
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    $logMsg = "[$timestamp] $msg"
    Write-Host $logMsg -ForegroundColor Cyan
    Add-Content -Path $logFile -Value $logMsg
}

function Prompt-User($message) {
    if ($AutoConfirm) { Log "AutoConfirm: $message -> ANO"; return $true }
    $response = Read-Host "$message (a/n)"
    return $response -eq "a"
}

Log "===== ZAHÁJENÍ MIGRACE ====="
Log "Kontrola nástrojů..."
if (-not (Get-Command git -ErrorAction SilentlyContinue)) { throw "Git není nainstalován." }
if (-not (Get-Command git-filter-repo -ErrorAction SilentlyContinue)) { Log "VAROVÁNÍ: git-filter-repo není nainstalován." }
if (-not $env:GITHUB_TOKEN) { throw "GITHUB_TOKEN není nastaven." }

$headers = @{ Authorization = "Bearer $env:GITHUB_TOKEN"; "User-Agent" = "PowerShell"; Accept = "application/vnd.github+json" }
$repoName = ($MonorepoUrl -split "/" | Select-Object -Last 1) -replace "\.git$",""
$owner = "Fatalerorr69"
try {
    $null = Invoke-RestMethod -Uri "https://api.github.com/repos/$owner/$repoName" -Headers $headers -ErrorAction Stop
    Log "Monorepo existuje."
} catch {
    Log "Monorepo neexistuje, vytvářím..."
    $body = @{ name = $repoName; private = $false; auto_init = $true } | ConvertTo-Json
    Invoke-RestMethod -Uri "https://api.github.com/user/repos" -Method Post -Headers $headers -Body $body -ContentType "application/json" | Out-Null
    Start-Sleep -Seconds 3
}

$waves = @(1,2,3)
foreach ($wave in $waves) {
    Log "`n===== VLNA $wave ====="
    Log "Spouštím testovací režim pro vlnu $wave..."
    & "$scriptDir\batch_migrate.ps1" -Wave $wave -MonorepoUrl $MonorepoUrl -TestMode -LogFile $logFile -StateFile $stateFile -Resume:$Resume
    if ($LASTEXITCODE -ne 0) { Log "CHYBA: Testovací běh selhal."; exit 1 }

    if (-not (Prompt-User "Test vlny $wave proběhl. Pokračovat ostrou migrací?")) { Log "Zastaveno uživatelem."; exit 0 }

    Log "Spouštím ostrou migraci pro vlnu $wave..."
    & "$scriptDir\batch_migrate.ps1" -Wave $wave -MonorepoUrl $MonorepoUrl -LogFile $logFile -StateFile $stateFile -Resume:$Resume

    if (-not (Prompt-User "Migrace vlny $wave dokončena. Archivovat zdrojové repozitáře?")) {
        Log "Archivace přeskočena."
    } else {
        Log "Spouštím archivaci..."
        & "$scriptDir\archive_repos.ps1" -Wave $wave -LogFile $logFile
    }

    if ($wave -lt 3) {
        if (-not (Prompt-User "Pokračovat vlnou $($wave+1)?")) { Log "Zastaveno uživatelem."; exit 0 }
    }
}

Log "`n===== PŘEHLED MIGRACE ====="
if (Test-Path $stateFile) {
    $state = Import-Csv $stateFile
    $state | Format-Table -AutoSize | Out-String | Write-Host
} else {
    Log "Žádný stavový soubor."
}

if (-not (Prompt-User "Nastavit branch protection?")) {
    Log "Branch protection přeskočena."
} else {
    & "$scriptDir\setup_branch_protection.ps1" -Repo "$owner/$repoName"
}

$duration = (Get-Date) - $startTime
Log "===== MIGRACE DOKONČENA ====="
Log "Celkový čas: $($duration.ToString())"
# Projekt: minimal-nas-web-edition

## Základní informace
- **Cesta v monorepu:** `infrastructure/minimal-nas-web-edition`
- **Původní repozitář:** `minimal-nas-web-edition`
- **Jazyk:** `Python`
- **Velikost:** `19 KB`
- **Licence:** `None`
- **Stav:** `neudržovaný` (aktivní / udržovaný / neudržovaný / archivovaný)
- **Poslední commit:** `?`
- **Open issues:** `0`
- **Hvězdy:** `0`, **Forky:** `0`
- **Má GitHub Actions:** `ne`

## Cíl projektu
<!-- Popište, co projekt dělá, proč existuje, jaký problém řeší. -->
- 

## Architektura
<!-- Popište vysokou úroveň architektury: monolit, mikroslužby, klient-server, atd. -->
- 

## Komponenty
<!-- Seznam hlavních komponent, modulů, knihoven, adresářů. -->
- 

## Závislosti
<!-- Klíčové externí závislosti, frameworky, runtime. -->
- 

## Stav a kvalita
<!-- Aktuální stav, testy, dokumentace, známé chyby. -->
- 

## Rizika a problémy
<!-- Bezpečnostní rizika, technický dluh, zastaralost. -->
- 

## Doporučení
<!-- Co zlepšit, zda sloučit, archivovat, refaktorovat. -->
- 

## Poznámky
<!-- Další postřehy. -->
- 
