$ErrorActionPreference = "Stop"

# Cesty
$planFile = Join-Path $PSScriptRoot "reorganize_plan.csv"
$inventoryFile = Join-Path $PSScriptRoot "repo_inventory.csv"
$templateFile = Join-Path $PSScriptRoot "project_analysis_template.md"
$monorepoPath = Join-Path $env:TEMP "migrate_v2\monorepo"
$outputIndex = Join-Path $PSScriptRoot "project_analysis_index.csv"

# Kontrola souborů
if (-not (Test-Path $planFile)) { throw "Chybí $planFile" }
if (-not (Test-Path $inventoryFile)) { throw "Chybí $inventoryFile" }
if (-not (Test-Path $templateFile)) { throw "Chybí $templateFile" }
if (-not (Test-Path $monorepoPath)) { throw "Chybí monorepo cesta: $monorepoPath" }

# Načtení dat
$plan = Import-Csv $planFile
$inventory = Import-Csv $inventoryFile
$template = Get-Content $templateFile -Raw

# Filtrujeme pouze migrované projekty (action = migrate)
$migratedProjects = $plan | Where-Object { $_.action -eq "migrate" }

Write-Host "Generuji analýzy pro $($migratedProjects.Count) projektů..." -ForegroundColor Cyan

$index = @()
foreach ($proj in $migratedProjects) {
    $repoName = $proj.repo_name
    $targetPath = $proj.target_path
    $destDir = Join-Path $monorepoPath $targetPath

    if (-not (Test-Path $destDir)) {
        Write-Warning "Adresář $destDir neexistuje, přeskakuji."
        continue
    }

    # Najít metadata v inventáři
    $meta = $inventory | Where-Object { $_.repo_name -eq $repoName } | Select-Object -First 1

    # Určení stavu
    $status = "neudržovaný"
    if ($meta -and $meta.archived -eq 'True') { $status = "archivovaný" }
    elseif ($meta -and $meta.last_commit_date -ne '') { $status = "aktivní" }

    # Nahrazení placeholderů v šabloně
    $content = $template
    $content = $content -replace '\{PROJECT_NAME\}', $repoName
    $content = $content -replace '\{TARGET_PATH\}', $targetPath
    $content = $content -replace '\{REPO_NAME\}', $repoName
    $content = $content -replace '\{PRIMARY_LANGUAGE\}', $(if ($meta -and $meta.primary_language) { $meta.primary_language } else { '?' })
    $content = $content -replace '\{SIZE_KB\}', $(if ($meta) { $meta.size_kb } else { '?' })
    $content = $content -replace '\{LICENSE\}', $(if ($meta -and $meta.license) { $meta.license } else { '?' })
    $content = $content -replace '\{STATUS\}', $status
    $content = $content -replace '\{LAST_COMMIT_DATE\}', $(if ($meta -and $meta.last_commit_date) { $meta.last_commit_date } else { '?' })
    $content = $content -replace '\{OPEN_ISSUES\}', $(if ($meta) { $meta.open_issues } else { '?' })
    $content = $content -replace '\{STARS\}', $(if ($meta) { $meta.stars } else { '?' })
    $content = $content -replace '\{FORKS\}', $(if ($meta) { $meta.forks } else { '?' })
    $content = $content -replace '\{HAS_ACTIONS\}', $(if ($meta -and $meta.has_actions -eq 'True') { 'ano' } else { 'ne' })

    # Uložit PROJECT_ANALYSIS.md do adresáře projektu
    $analysisFile = Join-Path $destDir "PROJECT_ANALYSIS.md"
    Set-Content -Path $analysisFile -Value $content
    Write-Host "Vygenerováno: $analysisFile" -ForegroundColor Green

    # Přidat do indexu
    $index += [PSCustomObject]@{
        ProjectName  = $repoName
        TargetPath   = $targetPath
        Language     = $(if ($meta -and $meta.primary_language) { $meta.primary_language } else { '?' })
        SizeKB       = $(if ($meta) { $meta.size_kb } else { '?' })
        License      = $(if ($meta -and $meta.license) { $meta.license } else { '?' })
        LastCommit   = $(if ($meta -and $meta.last_commit_date) { $meta.last_commit_date } else { '?' })
        OpenIssues   = $(if ($meta) { $meta.open_issues } else { '?' })
        HasActions   = $(if ($meta -and $meta.has_actions -eq 'True') { 'ano' } else { 'ne' })
        AnalysisFile = "PROJECT_ANALYSIS.md"
    }
}

# Uložit index
$index | Export-Csv -Path $outputIndex -NoTypeInformation
Write-Host "Index uložen: $outputIndex" -ForegroundColor Green
Write-Host "Generování dokončeno." -ForegroundColor Green
