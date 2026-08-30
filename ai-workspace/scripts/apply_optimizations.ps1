$ErrorActionPreference = "Stop"

# Cesty
$monorepoPath = Join-Path $env:TEMP "migrate_v2\monorepo"
$logFile = Join-Path $PSScriptRoot "optimization.log"

if (-not (Test-Path $monorepoPath)) { throw "Monorepo cesta neexistuje: $monorepoPath" }
Set-Location $monorepoPath
git pull origin main

function Log($msg) {
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    $logMsg = "[$timestamp] $msg"
    Write-Host $logMsg -ForegroundColor Cyan
    Add-Content -Path $logFile -Value $logMsg
}

Log "Zahajuji optimalizaci monorepa..."

# ========== 1. Centrální knihovna skriptů ==========
Log "Vytvářím centrální knihovnu skriptů..."
$libraryDir = Join-Path $monorepoPath "library"
New-Item -ItemType Directory -Path $libraryDir -Force | Out-Null

# Zkopírovat skripty z projektů do knihovny (s prefixem názvu projektu)
$scriptRegistry = @()
$projects = Get-ChildItem -Path $monorepoPath -Directory | Where-Object {
    $_.Name -notin @('.git', '.github', 'archive', 'ai-workspace', 'docs', 'reports', 'library', 'templates')
}
foreach ($proj in $projects) {
    $scripts = Get-ChildItem -Path $proj.FullName -Include *.ps1,*.sh,*.py,*.js,*.ts -Recurse -File -ErrorAction SilentlyContinue
    foreach ($script in $scripts) {
        $destName = "$($proj.Name)_$($script.Name)"
        Copy-Item -Path $script.FullName -Destination (Join-Path $libraryDir $destName) -Force
        $scriptRegistry += [PSCustomObject]@{
            OriginalProject = $proj.Name
            ScriptName = $script.Name
            LibraryName = $destName
            Type = $script.Extension
            Path = "library/$destName"
        }
    }
}
$scriptRegistry | Export-Csv -Path (Join-Path $libraryDir "library_index.csv") -NoTypeInformation

# README pro knihovnu
@"
# Centrální knihovna skriptů

Tento adresář obsahuje kopie skriptů ze všech projektů pro snadnou znovupoužitelnost.

## Evidence
Seznam skriptů je v `library_index.csv`.

## Použití
- Prohledávejte podle názvu projektu (prefix před prvním podtržítkem).
- Skripty jsou kopie – úpravy provádějte v původních projektech.

## Automatická synchronizace
Knihovna je generována automaticky skriptem `apply_optimizations.ps1`.
"@ | Set-Content -Path (Join-Path $libraryDir "README.md")

Log "Knihovna skriptů vytvořena: $libraryDir"

# ========== 2. Šablony projektů ==========
Log "Vytvářím šablony projektů..."
$templateDir = Join-Path $monorepoPath "templates/project-template"
New-Item -ItemType Directory -Path $templateDir -Force | Out-Null

# .gitignore
@"
# OS
.DS_Store
Thumbs.db

# IDE
.vscode/
.idea/

# Logs
*.log

# Environment
.env
.env.local

# Dependencies
node_modules/
__pycache__/
*.pyc
"@ | Set-Content -Path (Join-Path $templateDir ".gitignore")

# README
@"
# Název projektu

## Popis
<!-- Popište projekt -->

## Instalace
<!-- Jak nainstalovat -->

## Použití
<!-- Jak používat -->

## Licence
<!-- Licence -->
"@ | Set-Content -Path (Join-Path $templateDir "README.md")

# CI workflow pro šablonu
$workflowDir = Join-Path $templateDir ".github/workflows"
New-Item -ItemType Directory -Path $workflowDir -Force | Out-Null
@"
name: CI

on:
  push:
    branches: [ main ]
  pull_request:
    branches: [ main ]

jobs:
  lint:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - name: Run generic checks
        run: |
          echo "No specific lint configured yet"
"@ | Set-Content -Path (Join-Path $workflowDir "ci.yml")

Log "Šablona projektu vytvořena."

# ========== 3. GitHub Actions automatizace ==========
Log "Vytvářím GitHub Actions workflows..."
$ghWorkflows = Join-Path $monorepoPath ".github/workflows"
New-Item -ItemType Directory -Path $ghWorkflows -Force | Out-Null

# 3.1 Security scanning
@"
name: Security Scan
on:
  schedule:
    - cron: '0 6 * * 1'  # každé pondělí
  workflow_dispatch:

jobs:
  security:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - name: Run gitleaks
        uses: gitleaks/gitleaks-action@v2
        env:
          GITHUB_TOKEN: \${{ secrets.GITHUB_TOKEN }}
      - name: Run dependency review
        uses: actions/dependency-review-action@v4
"@ | Set-Content -Path (Join-Path $ghWorkflows "security.yml")

# 3.2 Auto-label issues
@"
name: Auto Label
on:
  issues:
    types: [opened]

jobs:
  label:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/github-script@v7
        with:
          script: |
            const issue = context.payload.issue;
            const labels = [];
            if (issue.body && issue.body.includes('bug')) labels.push('bug');
            if (issue.body && issue.body.includes('feature')) labels.push('enhancement');
            if (labels.length > 0) {
              github.rest.issues.addLabels({
                owner: context.repo.owner,
                repo: context.repo.repo,
                issue_number: issue.number,
                labels: labels
              });
            }
"@ | Set-Content -Path (Join-Path $ghWorkflows "auto-label.yml")

Log "GitHub Actions workflows vytvořeny."

# ========== 4. Indexy kategorií ==========
Log "Vytvářím indexy kategorií..."
$categories = @('starcore', 'rpi5', 'infrastructure', 'tools', 'archive')
foreach ($cat in $categories) {
    $catPath = Join-Path $monorepoPath $cat
    if (Test-Path $catPath) {
        $items = Get-ChildItem -Path $catPath -Directory | Select-Object -ExpandProperty Name
        $readme = "# Kategorie: $cat`n`nProjekty:`n"
        foreach ($item in $items) {
            $readme += "- $item`n"
        }
        $readme += "`n## Popis`n<!-- Přidejte popis kategorie -->`n"
        Set-Content -Path (Join-Path $catPath "README.md") -Value $readme
    }
}
Log "Indexy kategorií vytvořeny."

# ========== 5. Sloučení workspace/codespace projektů ==========
Log "Slučuji workspace/codespace projekty..."
$workspaceDir = Join-Path $monorepoPath "tools/workspace"
New-Item -ItemType Directory -Path $workspaceDir -Force | Out-Null

# Seznam projektů k sloučení (dle merge_proposals.md a analýzy)
$mergeTargets = @(
    'universal-ai-codespace',
    'ai-project-analyzer',
    'starko-rpi5-ai-workspace',
    'starcore-workspace'
)

foreach ($projName in $mergeTargets) {
    $srcPath = Join-Path $monorepoPath $projName
    if (-not (Test-Path $srcPath)) {
        # hledat v kategoriích
        $found = Get-ChildItem -Path $monorepoPath -Recurse -Directory -Filter $projName | Select-Object -First 1
        if ($found) { $srcPath = $found.FullName }
    }
    if (Test-Path $srcPath) {
        $destPath = Join-Path $workspaceDir $projName
        Move-Item -Path $srcPath -Destination $destPath -Force
        Log "  Přesunuto: $projName -> tools/workspace/$projName"
    }
}
@"
# Workspace projekty

Tento adresář sdružuje projekty zaměřené na pracovní prostředí a codespace.

## Obsah
- `universal-ai-codespace` – univerzální AI codespace
- `ai-project-analyzer` – analyzátor projektů
- `starko-rpi5-ai-workspace` – AI workspace pro Raspberry Pi 5
- `starcore-workspace` – pracovní prostředí StarCore

## Doporučení
Zvážit vytvoření jednotného workspace nástroje, který kombinuje funkce výše uvedených.
"@ | Set-Content -Path (Join-Path $workspaceDir "README.md")

Log "Sloučení dokončeno."

# ========== 6. AI Workspace agenti ==========
Log "Vytvářím AI Workspace agenty..."
$aiDir = Join-Path $monorepoPath "ai-workspace"
New-Item -ItemType Directory -Path (Join-Path $aiDir "agents") -Force | Out-Null

# Auditor agent
@"
# Auditor-AI
param(
    [string]$ConfigPath = "../config.json"
)

Write-Host "Auditor-AI: Spouštím audit repozitářů..." -ForegroundColor Cyan
$config = Get-Content $ConfigPath | ConvertFrom-Json
$inventoryPath = Join-Path $PSScriptRoot $config.inventory_file
if (Test-Path $inventoryPath) {
    $repos = Import-Csv $inventoryPath
    $issues = @()
    foreach ($repo in $repos) {
        if ($repo.size_kb -eq 0) { $issues += "Prázdný repozitář: $($repo.repo_name)" }
        if ($repo.archived -eq 'True') { $issues += "Archivovaný: $($repo.repo_name)" }
    }
    $issues | Out-File -FilePath "audit_report.md"
    Write-Host "Audit dokončen. Nalezeno $($issues.Count) problémů." -ForegroundColor Green
} else {
    Write-Warning "Inventář nenalezen."
}
"@ | Set-Content -Path (Join-Path $aiDir "agents/auditor.ps1")

# Planner agent
@"
# Reorg-Planner
param(
    [string]$ConfigPath = "../config.json"
)

Write-Host "Reorg-Planner: Navrhuji reorganizační plán..." -ForegroundColor Cyan
$config = Get-Content $ConfigPath | ConvertFrom-Json
$plan = @()
# Zde by byla logika pro návrh
$plan += "Návrh: Vytvořit kategorii 'tools/workspace' pro workspace projekty."
$plan += "Návrh: Sloučit acode projekty do jednoho."
$plan | Out-File -FilePath "plan_proposals.md"
Write-Host "Plán uložen do plan_proposals.md" -ForegroundColor Green
"@ | Set-Content -Path (Join-Path $aiDir "agents/planner.ps1")

# Migrator agent
@"
# Migration-AI
param(
    [string]$ConfigPath = "../config.json"
)

Write-Host "Migration-AI: Provádím migrace..." -ForegroundColor Cyan
$config = Get-Content $ConfigPath | ConvertFrom-Json
Write-Host "Konfigurace načtena z $ConfigPath"
# Zde by byla logika migrace
Write-Host "Migrace dokončena." -ForegroundColor Green
"@ | Set-Content -Path (Join-Path $aiDir "agents/migrator.ps1")

# Orchestrátor
@"
# Orchestrátor
param(
    [string]$ConfigPath = ".\config.json"
)

Write-Host "Spouštím AI Workspace agenty..." -ForegroundColor Cyan
& ".\agents\auditor.ps1" -ConfigPath $ConfigPath
& ".\agents\planner.ps1" -ConfigPath $ConfigPath
& ".\agents\migrator.ps1" -ConfigPath $ConfigPath
Write-Host "Všichni agenti dokončeni." -ForegroundColor Green
"@ | Set-Content -Path (Join-Path $aiDir "orchestrator.ps1")

# config.json
@"
{
  "monorepo_url": "https://github.com/Fatalerorr69/ai-workspace.git",
  "source_owner": "Fatalerorr69",
  "inventory_file": "../repo_inventory.csv",
  "log_file": "../optimization.log"
}
"@ | Set-Content -Path (Join-Path $aiDir "config.json")

Log "AI Workspace agenti vytvořeni."

# ========== 7. Dokumentace ==========
Log "Vytvářím dokumentaci..."
$docsDir = Join-Path $monorepoPath "docs"
New-Item -ItemType Directory -Path $docsDir -Force | Out-Null

@"
# Dokumentace monorepa ai-workspace

## Struktura
- `starcore/` – projekty StarCore
- `rpi5/` – projekty pro Raspberry Pi 5
- `infrastructure/` – serverové a síťové nástroje
- `tools/` – obecné nástroje (včetně workspace)
- `library/` – centrální knihovna skriptů
- `templates/` – šablony projektů
- `ai-workspace/` – agenti a orchestrátor
- `archive/` – archivované repozitáře

## Automatizace
- `.github/workflows/ci.yml` – lint a základní kontroly
- `.github/workflows/security.yml` – bezpečnostní sken (týdně)
- `.github/workflows/auto-label.yml` – automatické štítkování issues

## Rozhodnutí
Viz `docs/adr/` pro záznamy architektonických rozhodnutí.

## Roadmapa
- [ ] Integrovat Dependabot alerts
- [ ] Vytvořit CodeQL workflow
- [ ] Centralizovat závislosti
"@ | Set-Content -Path (Join-Path $docsDir "README.md")

# ADR adresář
New-Item -ItemType Directory -Path (Join-Path $docsDir "adr") -Force | Out-Null
@"
# ADR 001: Monorepo struktura

## Status
Přijato

## Kontext
Původních 80 repozitářů bylo roztříštěno. Monorepo zlepšuje přehled a správu.

## Rozhodnutí
Sloučit do kategorií: starcore, rpi5, infrastructure, tools, archive.

## Důsledky
- Snadnější vyhledávání
- Jednotná CI/CD
- Vyšší nároky na velikost repozitáře
"@ | Set-Content -Path (Join-Path $docsDir "adr/0001-monorepo-structure.md")

Log "Dokumentace vytvořena."

# ========== 8. Commit a push ==========
Log "Commituji a pushuji optimalizace..."
git add .
git commit -m "Optimalizace: knihovna skriptů, šablony, workflows, sloučení workspace, AI agenti, dokumentace"
git push origin main

Log "Optimalizace dokončena!" -ForegroundColor Green
