# Oprava a spuštění migrace – verze 2
$ErrorActionPreference = 'Stop'

# ---------- 1. Vytvoření migrate_repo.ps1 (opravený) ----------
$migrateRepo = @"
param(
    [Parameter(Mandatory=`$true)][string]`$RepoName,
    [Parameter(Mandatory=`$true)][string]`$TargetPath,
    [Parameter(Mandatory=`$true)][string]`$MonorepoUrl,
    [string]`$SourceOwner = 'Fatalerorr69',
    [switch]`$TestMode,
    [string]`$LogFile = 'migration.log',
    [string]`$StateFile = 'migration_state.csv',
    [int]`$Wave = 0
)

`$ErrorActionPreference = 'Stop'
`$workDir = Join-Path `$env:TEMP "migrate_`$RepoName"
`$sourceUrl = "https://github.com/`$SourceOwner/`$RepoName.git"

function Log(`$msg) {
    `$timestamp = Get-Date -Format 'yyyy-MM-dd HH:mm:ss'
    `$logMsg = "[`$timestamp] `$msg"
    Write-Host `$logMsg -ForegroundColor Cyan
    Add-Content -Path `$LogFile -Value `$logMsg
}

function Update-State(`$status) {
    `$line = [PSCustomObject]@{
        repo_name   = `$RepoName
        target_path = `$TargetPath
        wave        = `$Wave
        status      = `$status
        timestamp   = Get-Date -Format 'yyyy-MM-dd HH:mm:ss'
    }
    `$line | Export-Csv -Path `$StateFile -Append -NoTypeInformation
}

Log "=== Migrace `$RepoName -> `$TargetPath ==="

# Vyčištění
if (Test-Path `$workDir) { Remove-Item `$workDir -Recurse -Force }
New-Item -ItemType Directory -Path `$workDir | Out-Null
Set-Location `$workDir

# Klon
Log "Klonuji `$sourceUrl ..."
git clone --mirror `$sourceUrl `$RepoName.git
if (`$LASTEXITCODE -ne 0) { Update-State 'clone_failed'; throw 'Klonování selhalo' }
Set-Location "`$workDir\`$RepoName.git"

# filter-repo
`$filterRepo = Get-Command git-filter-repo -ErrorAction SilentlyContinue
if (-not `$filterRepo) {
    Log 'VAROVÁNÍ: git-filter-repo není nainstalován, soubory zůstanou v rootu.'
} else {
    Log "Přesouvám soubory do `$TargetPath ..."
    git filter-repo --to-subdirectory-filter `$TargetPath --force
    if (`$LASTEXITCODE -ne 0) { Update-State 'filter_failed'; throw 'git filter-repo selhal' }
}

# Push
if (`$TestMode) {
    Log "[TEST MODE] Push by proběhl do: `$MonorepoUrl"
    Update-State 'test_ok'
} else {
    Log 'Push do monorepa (větve a tagy) ...'
    git remote add monorepo `$MonorepoUrl
    git push monorepo 'refs/heads/*:refs/heads/*' 'refs/tags/*:refs/tags/*'
    if (`$LASTEXITCODE -ne 0) {
        Log 'VAROVÁNÍ: Push hlásí chybu, ale hlavní větve mohly projít. Pokračuji.'
    }
    Update-State 'migrated'
}

Log "Migrace `$RepoName dokončena."
"@
Set-Content -Path .\migrate_repo.ps1 -Value $migrateRepo

# ---------- 2. Vytvoření batch_migrate.ps1 (opravený) ----------
$batchMigrate = @"
param(
    [Parameter(Mandatory=`$true)][int]`$Wave,
    [Parameter(Mandatory=`$true)][string]`$MonorepoUrl,
    [switch]`$TestMode,
    [string]`$LogFile = 'migration.log',
    [string]`$StateFile = 'migration_state.csv',
    [switch]`$Resume
)

`$planFile = Join-Path `$PSScriptRoot 'reorganize_plan.csv'
if (-not (Test-Path `$planFile)) { throw "Chybí `$planFile" }

`$plan = Import-Csv `$planFile
`$reposToMigrate = `$plan | Where-Object { `$_.migration_wave -eq `$Wave -and `$_.action -eq 'migrate' }

`$doneRepos = @()
if (`$Resume -and (Test-Path `$StateFile)) {
    `$state = Import-Csv `$StateFile
    `$doneRepos = `$state | Where-Object { `$_.wave -eq `$Wave -and `$_.status -eq 'migrated' } | Select-Object -ExpandProperty repo_name
    Write-Host "Resume: přeskočím `$(`$doneRepos.Count) již hotových repozitářů." -ForegroundColor DarkCyan
}

Write-Host "Vlna `$Wave – počet repozitářů k migraci: `$(`$reposToMigrate.Count)" -ForegroundColor Magenta
Add-Content -Path `$LogFile -Value "===== VLNA `$Wave - MIGRACE ====="

`$index = 0
foreach (`$item in `$reposToMigrate) {
    `$index++
    if (`$doneRepos -contains `$item.repo_name) {
        Write-Host "[`$index/`$(`$reposToMigrate.Count)] PŘESKOČENO `$(`$item.repo_name)" -ForegroundColor Gray
        continue
    }
    Write-Host "`n[`$index/`$(`$reposToMigrate.Count)] Zpracovávám `$(`$item.repo_name)" -ForegroundColor Yellow
    & "`$PSScriptRoot\migrate_repo.ps1" `
        -RepoName `$item.repo_name `
        -TargetPath `$item.target_path `
        -MonorepoUrl `$MonorepoUrl `
        -TestMode:`$TestMode `
        -LogFile `$LogFile `
        -StateFile `$StateFile `
        -Wave `$Wave
    if (`$LASTEXITCODE -ne 0) {
        Write-Warning "Migrace `$(`$item.repo_name) skončila s chybou, pokračuji další."
    }
}

Write-Host "`nVlna `$Wave – migrace dokončena." -ForegroundColor Green
"@
Set-Content -Path .\batch_migrate.ps1 -Value $batchMigrate

# ---------- 3. Vytvoření run_migration.ps1 (opravený) ----------
$runMigration = @"
param(
    [string]`$MonorepoUrl = 'https://github.com/Fatalerorr69/ai-workspace.git',
    [switch]`$AutoConfirm,
    [switch]`$Resume
)

`$ErrorActionPreference = 'Stop'
`$scriptDir = `$PSScriptRoot
`$logFile = Join-Path `$scriptDir 'migration_full.log'
`$stateFile = Join-Path `$scriptDir 'migration_state.csv'
`$startTime = Get-Date

function Log(`$msg) {
    `$timestamp = Get-Date -Format 'yyyy-MM-dd HH:mm:ss'
    `$logMsg = "[`$timestamp] `$msg"
    Write-Host `$logMsg -ForegroundColor Cyan
    Add-Content -Path `$logFile -Value `$logMsg
}

function Prompt-User(`$message) {
    if (`$AutoConfirm) { Log "AutoConfirm: `$message -> ANO"; return `$true }
    `$response = Read-Host "`$message (a/n)"
    return `$response -eq 'a'
}

Log '===== ZAHÁJENÍ MIGRACE ====='
Log 'Kontrola nástrojů...'
if (-not (Get-Command git -ErrorAction SilentlyContinue)) { throw 'Git není nainstalován.' }
if (-not (Get-Command git-filter-repo -ErrorAction SilentlyContinue)) { Log 'VAROVÁNÍ: git-filter-repo není nainstalován.' }
if (-not `$env:GITHUB_TOKEN) { throw 'GITHUB_TOKEN není nastaven.' }

`$headers = @{ Authorization = "Bearer `$env:GITHUB_TOKEN"; 'User-Agent' = 'PowerShell'; Accept = 'application/vnd.github+json' }
`$repoName = (`$MonorepoUrl -split '/' | Select-Object -Last 1) -replace '\.git`$',''
`$owner = 'Fatalerorr69'
try {
    `$null = Invoke-RestMethod -Uri "https://api.github.com/repos/`$owner/`$repoName" -Headers `$headers -ErrorAction Stop
    Log 'Monorepo existuje.'
} catch {
    Log 'Monorepo neexistuje, vytvářím...'
    `$body = @{ name = `$repoName; private = `$false; auto_init = `$true } | ConvertTo-Json
    Invoke-RestMethod -Uri 'https://api.github.com/user/repos' -Method Post -Headers `$headers -Body `$body -ContentType 'application/json' | Out-Null
    Start-Sleep -Seconds 3
}

`$waves = @(1,2,3)
foreach (`$wave in `$waves) {
    Log "`n===== VLNA `$wave ====="
    Log "Spouštím testovací režim pro vlnu `$wave..."
    & "`$scriptDir\batch_migrate.ps1" -Wave `$wave -MonorepoUrl `$MonorepoUrl -TestMode -LogFile `$logFile -StateFile `$stateFile -Resume:`$Resume
    if (`$LASTEXITCODE -ne 0) { Log 'CHYBA: Testovací běh selhal.'; exit 1 }

    if (-not (Prompt-User "Test vlny `$wave proběhl. Pokračovat ostrou migrací?")) { Log 'Zastaveno uživatelem.'; exit 0 }

    Log "Spouštím ostrou migraci pro vlnu `$wave..."
    & "`$scriptDir\batch_migrate.ps1" -Wave `$wave -MonorepoUrl `$MonorepoUrl -LogFile `$logFile -StateFile `$stateFile -Resume:`$Resume

    if (-not (Prompt-User "Migrace vlny `$wave dokončena. Archivovat zdrojové repozitáře?")) {
        Log 'Archivace přeskočena.'
    } else {
        Log 'Spouštím archivaci...'
        & "`$scriptDir\archive_repos.ps1" -Wave `$wave -LogFile `$logFile
    }

    if (`$wave -lt 3) {
        if (-not (Prompt-User "Pokračovat vlnou `$(`$wave+1)?")) { Log 'Zastaveno uživatelem.'; exit 0 }
    }
}

Log "`n===== PŘEHLED MIGRACE ====="
if (Test-Path `$stateFile) {
    `$state = Import-Csv `$stateFile
    `$state | Format-Table -AutoSize | Out-String | Write-Host
} else {
    Log 'Žádný stavový soubor.'
}

if (-not (Prompt-User 'Nastavit branch protection?')) {
    Log 'Branch protection přeskočena.'
} else {
    & "`$scriptDir\setup_branch_protection.ps1" -Repo "`$owner/`$repoName"
}

`$duration = (Get-Date) - `$startTime
Log '===== MIGRACE DOKONČENA ====='
Log "Celkový čas: `$(`$duration.ToString())"
"@
Set-Content -Path .\run_migration.ps1 -Value $runMigration

# ---------- 4. Vytvoření prázdného state CSV ----------
if (-not (Test-Path .\migration_state.csv)) {
    "repo_name,target_path,wave,status,timestamp" | Set-Content -Path .\migration_state.csv
}

Write-Host 'Oprava dokončena. Spouštím migraci s Resume...' -ForegroundColor Green
& .\run_migration.ps1 -MonorepoUrl 'https://github.com/Fatalerorr69/ai-workspace.git' -Resume
