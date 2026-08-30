$ErrorActionPreference = "Stop"

# Cesty
$planFile = Join-Path $PSScriptRoot "reorganize_plan.csv"
$inventoryFile = Join-Path $PSScriptRoot "repo_inventory.csv"
$monorepoPath = Join-Path $env:TEMP "migrate_v2\monorepo"
$logFile = Join-Path $PSScriptRoot "deep_analysis.log"
$scriptsRegistry = Join-Path $PSScriptRoot "scripts_registry.csv"
$mergeProposals = Join-Path $monorepoPath "merge_proposals.md"

# Kontrola
if (-not (Test-Path $planFile)) { throw "Chybí $planFile" }
if (-not (Test-Path $inventoryFile)) { throw "Chybí $inventoryFile" }
if (-not (Test-Path $monorepoPath)) { throw "Chybí monorepo: $monorepoPath" }

Set-Location $monorepoPath
git pull origin main

# Načtení plánu
$plan = Import-Csv $planFile
$migrated = $plan | Where-Object { $_.action -eq "migrate" }

# Inicializace registru
$scriptEntries = @()
$mergeGroups = @{}

function Get-FileDescription($file) {
    $desc = ""
    try {
        $content = Get-Content $file.FullName -TotalCount 5 -ErrorAction Stop
        foreach ($line in $content) {
            if ($line -match '^\s*#' -or $line -match '^\s*//' -or $line -match '^\s*/\*' -or $line -match '^\s*<!--') {
                $clean = $line -replace '^\s*[#/;]+\s*', '' -replace '^\s*<!--\s*', '' -replace '\s*-->\s*$', ''
                if ($clean) {
                    $desc = $clean
                    break
                }
            }
        }
    } catch {}
    if (-not $desc) { $desc = "Skript $($file.Name)" }
    return $desc
}

# Projít projekty
Write-Host "Procházím projekty a analyzuji..." -ForegroundColor Cyan
$projectIndex = @()
foreach ($proj in $migrated) {
    $repoName = $proj.repo_name
    $targetPath = $proj.target_path
    $projDir = Join-Path $monorepoPath $targetPath

    if (-not (Test-Path $projDir)) { continue }

    # Najít README
    $readmeFile = Get-ChildItem -Path $projDir -Filter "README*" -File -Recurse -Depth 1 | Select-Object -First 1
    $readmeContent = ""
    if ($readmeFile) {
        $readmeContent = Get-Content $readmeFile.FullName -Raw
    }

    # Detekovat technologie
    $tech = @()
    if (Test-Path (Join-Path $projDir "package.json")) { $tech += "Node.js" }
    if (Test-Path (Join-Path $projDir "requirements.txt")) { $tech += "Python" }
    if (Test-Path (Join-Path $projDir "Dockerfile")) { $tech += "Docker" }
    if (Get-ChildItem -Path $projDir -Filter "*.ps1" -Recurse -Depth 1 | Select-Object -First 1) { $tech += "PowerShell" }
    if (Get-ChildItem -Path $projDir -Filter "*.sh" -Recurse -Depth 1 | Select-Object -First 1) { $tech += "Shell" }
    if (Get-ChildItem -Path $projDir -Filter "*.csproj" -Recurse -Depth 1 | Select-Object -First 1) { $tech += ".NET" }

    # Najít skripty
    $scripts = Get-ChildItem -Path $projDir -Include *.ps1,*.sh,*.py,*.js,*.ts,*.bat,*.cmd -Recurse -File
    foreach ($script in $scripts) {
        $desc = Get-FileDescription $script
        $scriptEntries += [PSCustomObject]@{
            Project     = $repoName
            TargetPath  = $targetPath
            ScriptPath  = $script.FullName.Substring($monorepoPath.Length + 1)
            ScriptType  = $script.Extension
            Description = $desc
        }
    }

    # Vytvořit hlubokou analýzu
    $deepContent = @"
# Hluboká analýza: $repoName

## Základní informace
- **Cílová cesta:** `$targetPath`
- **Detekované technologie:** $($tech -join ', ')
- **Počet skriptů:** $($scripts.Count)

## Popis z README
$($readmeContent -replace '`n', "`n> ")

## Seznam skriptů
$($scripts | ForEach-Object { "- ``$($_.FullName.Substring($monorepoPath.Length + 1))`` – $(Get-FileDescription $_)" } | Out-String)

## Hodnocení a doporučení
<!-- Doplňte na základě výše uvedených informací -->
- 
"@
    Set-Content -Path (Join-Path $projDir "PROJECT_DEEP_ANALYSIS.md") -Value $deepContent

    # Přidat do indexu
    $projectIndex += [PSCustomObject]@{
        Project = $repoName
        TargetPath = $targetPath
        Technologies = $tech -join ','
        ScriptCount = $scripts.Count
        ReadmeExists = [bool]$readmeFile
    }

    # Seskupit pro sloučení podle klíčových slov
    $keywords = @("workspace", "codespace", "environment", "template", "setup", "installer", "builder", "devcontainer")
    foreach ($kw in $keywords) {
        if ($repoName -match $kw -or $targetPath -match $kw) {
            if (-not $mergeGroups.ContainsKey($kw)) { $mergeGroups[$kw] = @() }
            $mergeGroups[$kw] += $repoName
        }
    }

    Write-Host "Analyzováno: $repoName ($($scripts.Count) skriptů)" -ForegroundColor Green
}

# Uložit registr skriptů
$scriptEntries | Export-Csv -Path $scriptsRegistry -NoTypeInformation
Write-Host "Registr skriptů uložen: $scriptsRegistry" -ForegroundColor Green

# Vytvořit merge_proposals.md
$mergeMd = "# Návrhy na sloučení projektů`n`n"
$mergeMd += "Na základě klíčových slov v názvech byly identifikovány následující skupiny projektů, které by mohly být sloučeny.`n`n"
foreach ($key in $mergeGroups.Keys) {
    $projects = $mergeGroups[$key] -join ', '
    $mergeMd += "## Skupina: $key`n- Projekty: $projects`n- Doporučení: Zvážit sloučení do jednoho adresáře nebo vytvoření společné knihovny.`n`n"
}
$mergeMd += "`n## Obecné doporučení`n- Pro workspace/codespace projekty: vytvořit jednotnou šablonu v ``templates/`` a využít devcontainer.`n- Pro instalační skripty: centralizovat do ``infrastructure/installers/``.`n- Pro šablony: uchovávat v ``templates/`` a verzovat.`n"
Set-Content -Path $mergeProposals -Value $mergeMd
Write-Host "Návrhy sloučení uloženy: $mergeProposals" -ForegroundColor Green

# Vytvořit šablony prostředí
$templatesDir = Join-Path $monorepoPath "templates"
New-Item -ItemType Directory -Path $templatesDir -Force | Out-Null

@"
# Šablony prostředí

Tento adresář obsahuje univerzální šablony pro nastavení pracovního prostředí.

## Obsah
- `devcontainer.json` – konfigurace pro VS Code Dev Containers
- `Dockerfile` – univerzální Dockerfile
- `setup_workspace.ps1` – PowerShell skript pro inicializaci workspace
- `setup_workspace.sh` – Bash skript pro inicializaci workspace
- `README.md` – tento soubor

## Použití
1. Zkopírujte příslušné soubory do vašeho projektu.
2. Upravte podle potřeby.
3. Spusťte setup skript.
"@ | Set-Content -Path (Join-Path $templatesDir "README.md")

@"
{
    "name": "Universal Workspace",
    "image": "mcr.microsoft.com/devcontainers/universal:2",
    "features": {
        "ghcr.io/devcontainers/features/common-utils:1": {}
    },
    "postCreateCommand": "bash setup_workspace.sh",
    "customizations": {
        "vscode": {
            "extensions": [
                "ms-vscode.powershell",
                "ms-python.python",
                "dbaeumer.vscode-eslint"
            ]
        }
    }
}
"@ | Set-Content -Path (Join-Path $templatesDir "devcontainer.json")

@"
FROM mcr.microsoft.com/devcontainers/universal:2

# Instalace dalších nástrojů
RUN apt-get update && apt-get install -y \
    git \
    curl \
    wget \
    jq \
    && rm -rf /var/lib/apt/lists/*
"@ | Set-Content -Path (Join-Path $templatesDir "Dockerfile")

@"
# setup_workspace.ps1
param(
    [switch]`$InstallDependencies
)

Write-Host "Nastavuji pracovní prostředí..." -ForegroundColor Cyan

# Zde přidejte instalaci závislostí
if (`$InstallDependencies) {
    Write-Host "Instaluji závislosti..." -ForegroundColor Yellow
    # npm install, pip install -r requirements.txt, atd.
}

Write-Host "Hotovo." -ForegroundColor Green
"@ | Set-Content -Path (Join-Path $templatesDir "setup_workspace.ps1")

@"
#!/bin/bash
# setup_workspace.sh
echo "Nastavuji pracovní prostředí..."
# Zde přidejte instalaci závislostí
echo "Hotovo."
"@ | Set-Content -Path (Join-Path $templatesDir "setup_workspace.sh")

Write-Host "Šablony vytvořeny v $templatesDir" -ForegroundColor Green

# Commit a push
Write-Host "Commituji a pushuji změny..." -ForegroundColor Cyan
git add .
git commit -m "Přidány hluboké analýzy, registr skriptů, návrhy sloučení a šablony"
git push origin main

Write-Host "Hloubková analýza dokončena!" -ForegroundColor Green
