$ErrorActionPreference = "Stop"

$monorepoPath = Join-Path $env:TEMP "migrate_v2\monorepo"
$logFile = Join-Path $PSScriptRoot "optimization_final.log"

if (-not (Test-Path $monorepoPath)) { throw "Monorepo cesta neexistuje: $monorepoPath" }

Set-Location $monorepoPath
git pull origin main

function Log($msg) {
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    $logMsg = "[$timestamp] $msg"
    Write-Host $logMsg -ForegroundColor Cyan
    Add-Content -Path $logFile -Value $logMsg
}

Log "Zahajuji optimalizaci..."

# 1. Knihovna skriptů
$libraryDir = Join-Path $monorepoPath "library"
New-Item -ItemType Directory -Path $libraryDir -Force | Out-Null
$registry = @()
$projects = Get-ChildItem -Path $monorepoPath -Directory | Where-Object { $_.Name -notin @(".git",".github","archive","ai-workspace","docs","reports","library","templates") }
foreach ($proj in $projects) {
    $scripts = Get-ChildItem -Path $proj.FullName -Include *.ps1,*.sh,*.py,*.js,*.ts -Recurse -File -ErrorAction SilentlyContinue
    foreach ($script in $scripts) {
        $destName = "$($proj.Name)_$($script.Name)"
        Copy-Item -Path $script.FullName -Destination (Join-Path $libraryDir $destName) -Force
        $registry += [PSCustomObject]@{ Project = $proj.Name; Script = $script.Name; LibraryPath = "library/$destName" }
    }
}
$registry | Export-Csv -Path (Join-Path $libraryDir "library_index.csv") -NoTypeInformation
"# Centrální knihovna skriptů" | Set-Content -Path (Join-Path $libraryDir "README.md")
Log "Knihovna hotova."

# 2. Šablony
$templateDir = Join-Path $monorepoPath "templates/project-template"
New-Item -ItemType Directory -Path $templateDir -Force | Out-Null
New-Item -ItemType Directory -Path (Join-Path $templateDir ".github/workflows") -Force | Out-Null
"# OS`n.DS_Store`nThumbs.db`n.vscode/`n.idea/`n*.log`n.env`nnode_modules/`n__pycache__/" | Set-Content -Path (Join-Path $templateDir ".gitignore")
"# Název projektu`nPopis" | Set-Content -Path (Join-Path $templateDir "README.md")
"name: CI`non: [push, pull_request]`njobs:`n  lint:`n    runs-on: ubuntu-latest`n    steps:`n      - uses: actions/checkout@v4`n      - run: echo \"No lint yet\"" | Set-Content -Path (Join-Path $templateDir ".github/workflows/ci.yml")
Log "Šablony hotovy."

# 3. Workflows
$ghDir = Join-Path $monorepoPath ".github/workflows"
New-Item -ItemType Directory -Path $ghDir -Force | Out-Null
"name: Security Scan`non:`n  schedule:`n    - cron: \"0 6 * * 1\"`n  workflow_dispatch:`njobs:`n  security:`n    runs-on: ubuntu-latest`n    steps:`n      - uses: actions/checkout@v4`n      - uses: gitleaks/gitleaks-action@v2`n      - uses: actions/dependency-review-action@v4" | Set-Content -Path (Join-Path $ghDir "security.yml")
"name: Auto Label`non:`n  issues:`n    types: [opened]`njobs:`n  label:`n    runs-on: ubuntu-latest`n    steps:`n      - uses: actions/github-script@v7`n        with:`n          script: |`n            const labels = [];`n            if (context.payload.issue.body?.includes(\"bug\")) labels.push(\"bug\");`n            if (context.payload.issue.body?.includes(\"feature\")) labels.push(\"enhancement\");`n            if (labels.length) github.rest.issues.addLabels({owner: context.repo.owner, repo: context.repo.repo, issue_number: context.payload.issue.number, labels});" | Set-Content -Path (Join-Path $ghDir "auto-label.yml")
Log "Workflows hotovy."

# 4. Indexy
foreach ($cat in @("starcore","rpi5","infrastructure","tools","archive")) {
    $catPath = Join-Path $monorepoPath $cat
    if (Test-Path $catPath) {
        $items = Get-ChildItem $catPath -Directory | Select-Object -ExpandProperty Name
        $readme = "# Kategorie: $cat`n`nProjekty:`n"
        foreach ($item in $items) { $readme += "- $item`n" }
        $readme += "`n## Popis`n"
        Set-Content -Path (Join-Path $catPath "README.md") -Value $readme
    }
}
Log "Indexy hotovy."

# 5. Sloučení workspace
$workspaceDir = Join-Path $monorepoPath "tools/workspace"
New-Item -ItemType Directory -Path $workspaceDir -Force | Out-Null
foreach ($name in @("universal-ai-codespace","ai-project-analyzer","starko-rpi5-ai-workspace","starcore-workspace")) {
    $src = Get-ChildItem -Path $monorepoPath -Recurse -Directory -Filter $name | Select-Object -First 1
    if ($src) { Move-Item -Path $src.FullName -Destination (Join-Path $workspaceDir $name) -Force; Log "  Presunuto: $name" }
}
"# Workspace projekty`nSjednocené projekty pro pracovní prostředí." | Set-Content -Path (Join-Path $workspaceDir "README.md")
Log "Sloučení hotovo."

# 6. AI agenti
$aiDir = Join-Path $monorepoPath "ai-workspace"
New-Item -ItemType Directory -Path (Join-Path $aiDir "agents") -Force | Out-Null
"# Auditor`nparam([string]$ConfigPath = \"../config.json\")`nWrite-Host \"Audit agent\"" | Set-Content -Path (Join-Path $aiDir "agents/auditor.ps1")
"# Planner`nparam([string]$ConfigPath = \"../config.json\")`nWrite-Host \"Planner agent\"" | Set-Content -Path (Join-Path $aiDir "agents/planner.ps1")
"# Migrator`nparam([string]$ConfigPath = \"../config.json\")`nWrite-Host \"Migrator agent\"" | Set-Content -Path (Join-Path $aiDir "agents/migrator.ps1")
"# Orchestrator`n& ./agents/auditor.ps1`n& ./agents/planner.ps1`n& ./agents/migrator.ps1" | Set-Content -Path (Join-Path $aiDir "orchestrator.ps1")
@{ monorepo_url = "https://github.com/Fatalerorr69/ai-workspace.git"; source_owner = "Fatalerorr69" } | ConvertTo-Json | Set-Content -Path (Join-Path $aiDir "config.json")
Log "AI agenti hotovi."

# 7. Dokumentace
$docsDir = Join-Path $monorepoPath "docs"
New-Item -ItemType Directory -Path (Join-Path $docsDir "adr") -Force | Out-Null
"# Dokumentace monorepa ai-workspace`n`n## Struktura`n- starcore/`n- rpi5/`n- infrastructure/`n- tools/`n- library/`n- templates/`n- ai-workspace/`n- archive/`n`n## Automatizace`n- security.yml`n- auto-label.yml" | Set-Content -Path (Join-Path $docsDir "README.md")
"# ADR 001: Monorepo struktura`n`nPřijato." | Set-Content -Path (Join-Path $docsDir "adr/0001-monorepo.md")
Log "Dokumentace hotova."

# 8. Commit a push
Set-Location $monorepoPath
git add .
git commit -m "Optimalizace: knihovna, šablony, workflows, indexy, sloučení, AI, dokumentace"
git push origin main
Log "Push hotov."

Log "Všechny optimalizace dokončeny!" -ForegroundColor Green
