<#
.SYNOPSIS
  Kontinuální analýza GitHub repozitářů – běží po zadanou dobu a prohlubuje poznatky.
.DESCRIPTION
  Skript prochází repozitáře (dle repo_inventory.csv) v cyklech. V každém cyklu provede
  jednu fázi analýzy (metadata, technologie, závislosti, bezpečnost, aktivita).
  Výsledky ukládá do analysis_output/ (JSON, CSV, report).
.PARAMETER MaxDurationMinutes
  Maximální doba běhu v minutách (výchozí 120).
.PARAMETER IntervalSeconds
  Pauza mezi cykly v sekundách (výchozí 300).
.PARAMETER Owner
  Vlastník repozitářů.
.PARAMETER InventoryCsv
  Cesta k repo_inventory.csv.
.PARAMETER OutputDir
  Kam ukládat výsledky.
.PARAMETER Resume
  Pokračovat z existujícího analysis_results.json.
#>
param(
    [int]$MaxDurationMinutes = 120,
    [int]$IntervalSeconds = 300,
    [string]$Owner = "Fatalerorr69",
    [string]$InventoryCsv = ".\repo_inventory.csv",
    [string]$OutputDir = ".\analysis_output",
    [switch]$Resume
)

$ErrorActionPreference = "Stop"

# Kontrola tokenu
if (-not $env:GITHUB_TOKEN) {
    Write-Warning "GITHUB_TOKEN není nastaven. Analýza poběží bez API přístupu."
    $headers = @{ "User-Agent" = "PowerShell" }
} else {
    $headers = @{
        Authorization = "Bearer $env:GITHUB_TOKEN"
        "User-Agent"  = "PowerShell-Analysis"
        Accept        = "application/vnd.github+json"
    }
}

# Vytvoření výstupního adresáře
if (-not (Test-Path $OutputDir)) {
    New-Item -ItemType Directory -Path $OutputDir -Force | Out-Null
}
$logFile = Join-Path $OutputDir "analysis_log.txt"
$jsonFile = Join-Path $OutputDir "analysis_results.json"
$csvFile  = Join-Path $OutputDir "analysis_data.csv"
$reportFile = Join-Path $OutputDir "analysis_report.md"

# Načtení seznamu repozitářů
if (-not (Test-Path $InventoryCsv)) {
    throw "Chybí $InventoryCsv"
}
$repos = Import-Csv $InventoryCsv
$repoNames = $repos.repo_name
Write-Host "Nalezeno $($repoNames.Count) repozitářů k analýze." -ForegroundColor Cyan

# Inicializace struktury výsledků
$allResults = @{}
if ($Resume -and (Test-Path $jsonFile)) {
    $allResults = Get-Content $jsonFile -Raw | ConvertFrom-Json -AsHashtable
    Write-Host "Obnovuji předchozí výsledky z $jsonFile" -ForegroundColor DarkCyan
}

# Fáze analýzy (každý cyklus provede jednu fázi pro všechny repozitáře)
$phases = @(
    "metadata",       # základní metadata z API
    "technologies",   # detekce technologií ze souborů
    "dependencies",   # závislosti z package.json/requirements.txt
    "security",       # hledání secrets, TODO, atd.
    "activity"        # historie commitů, issues, PR
)
$phaseIndex = 0

function Get-Api($uri) {
    try {
        $response = Invoke-RestMethod -Uri $uri -Headers $headers -ErrorAction Stop
        return $response
    } catch {
        return $null
    }
}

function Analyze-Metadata($repoName) {
    $uri = "https://api.github.com/repos/$Owner/$repoName"
    $data = Get-Api $uri
    if ($data) {
        return @{
            full_name = $data.full_name
            description = $data.description
            language = $data.language
            size_kb = $data.size
            license = $data.license.spdx_id
            stars = $data.stargazers_count
            forks = $data.forks_count
            open_issues = $data.open_issues_count
            default_branch = $data.default_branch
            created_at = $data.created_at
            updated_at = $data.updated_at
            pushed_at = $data.pushed_at
            archived = $data.archived
            has_wiki = $data.has_wiki
            has_pages = $data.has_pages
            topics = $data.topics -join ';'
        }
    }
    return $null
}

function Get-RepoFiles($repoName, $path = "") {
    $uri = "https://api.github.com/repos/$Owner/$repoName/contents/$path"
    $items = Get-Api $uri
    return $items
}

function Analyze-Technologies($repoName) {
    $tech = @()
    $files = Get-RepoFiles $repoName
    if (-not $files) { return $tech }

    # Zkontrolovat klíčové soubory
    $fileNames = $files | Where-Object { $_.type -eq "file" } | Select-Object -ExpandProperty name
    if ($fileNames -contains "package.json") { $tech += "Node.js" }
    if ($fileNames -contains "requirements.txt" -or $fileNames -contains "pyproject.toml") { $tech += "Python" }
    if ($fileNames -contains "Dockerfile") { $tech += "Docker" }
    if ($fileNames -contains "go.mod") { $tech += "Go" }
    if ($fileNames -contains "Cargo.toml") { $tech += "Rust" }
    if ($fileNames -match '\.csproj$') { $tech += ".NET" }
    if ($fileNames -match '\.sln$') { $tech += "Visual Studio" }
    # Podle přípon
    $exts = $files | Where-Object { $_.type -eq "file" } | ForEach-Object { [System.IO.Path]::GetExtension($_.name) } | Sort-Object -Unique
    if ($exts -contains ".ps1") { $tech += "PowerShell" }
    if ($exts -contains ".sh") { $tech += "Shell" }
    if ($exts -contains ".py") { $tech += "Python (scripts)" }
    if ($exts -contains ".ts") { $tech += "TypeScript" }
    if ($exts -contains ".js") { $tech += "JavaScript" }
    if ($exts -contains ".java") { $tech += "Java" }
    if ($exts -contains ".cpp" -or $exts -contains ".c") { $tech += "C/C++" }
    if ($exts -contains ".html") { $tech += "HTML" }
    if ($exts -contains ".css") { $tech += "CSS" }
    return $tech | Sort-Object -Unique
}

function Analyze-Dependencies($repoName) {
    $deps = @()
    # Stáhnout package.json
    $file = Get-RepoFiles $repoName | Where-Object { $_.name -eq "package.json" }
    if ($file -and $file.download_url) {
        try {
            $content = Invoke-WebRequest -Uri $file.download_url -UseBasicParsing -ErrorAction Stop | Select-Object -ExpandProperty Content
            $package = $content | ConvertFrom-Json
            $deps += $package.dependencies.PSObject.Properties.Name
            $deps += $package.devDependencies.PSObject.Properties.Name
        } catch {}
    }
    # requirements.txt
    $file = Get-RepoFiles $repoName | Where-Object { $_.name -eq "requirements.txt" }
    if ($file -and $file.download_url) {
        try {
            $content = Invoke-WebRequest -Uri $file.download_url -UseBasicParsing -ErrorAction Stop | Select-Object -ExpandProperty Content
            $deps += $content -split "`n" | ForEach-Object { ($_ -split '==')[0] -split '>=' | Select-Object -First 1 } | Where-Object { $_ -and $_ -notmatch '^#' }
        } catch {}
    }
    return $deps | Sort-Object -Unique
}

function Analyze-Security($repoName) {
    $secrets = @()
    $todoCount = 0
    $files = Get-RepoFiles $repoName
    if (-not $files) { return @{ secrets = $secrets; todo_count = $todoCount } }

    foreach ($file in $files | Where-Object { $_.type -eq "file" -and $_.size -lt 1000000 }) {
        try {
            $content = Invoke-WebRequest -Uri $file.download_url -UseBasicParsing -ErrorAction Stop | Select-Object -ExpandProperty Content
            if ($content -match '(?i)(api[_-]?key|secret|password|token)\s*[:=]\s*["''][^"'']+["'']') {
                $secrets += $file.name
            }
            $todoCount += ([regex]::Matches($content, '(?i)TODO|FIXME')).Count
        } catch {}
    }
    return @{ secrets = $secrets; todo_count = $todoCount }
}

function Analyze-Activity($repoName) {
    $commits = Get-Api "https://api.github.com/repos/$Owner/$repoName/commits?per_page=5"
    $issues = Get-Api "https://api.github.com/repos/$Owner/$repoName/issues?per_page=5"
    $prs = Get-Api "https://api.github.com/repos/$Owner/$repoName/pulls?per_page=5"
    return @{
        recent_commits = if ($commits) { $commits | ForEach-Object { $_.commit.message } } else { @() }
        open_issues_count = if ($issues) { $issues.Count } else { 0 }
        open_prs_count = if ($prs) { $prs.Count } else { 0 }
    }
}

# Hlavní smyčka
$startTime = Get-Date
$endTime = $startTime.AddMinutes($MaxDurationMinutes)
$cycle = 0

Write-Host "Spouštím kontinuální analýzu (max $MaxDurationMinutes minut, interval $IntervalSeconds s)." -ForegroundColor Green
Write-Host "Fáze analýzy: $($phases -join ', ')" -ForegroundColor DarkGray

while ((Get-Date) -lt $endTime) {
    $cycle++
    $phase = $phases[$phaseIndex % $phases.Count]
    Write-Host "`n========== Cyklus $cycle – Fáze: $phase ==========" -ForegroundColor Magenta

    foreach ($repoName in $repoNames) {
        Write-Host "  Analýza: $repoName (fáze $phase)..." -ForegroundColor DarkCyan

        # Zajištění existence záznamu
        if (-not $allResults.ContainsKey($repoName)) {
            $allResults[$repoName] = @{
                name = $repoName
                metadata = $null
                technologies = @()
                dependencies = @()
                security = @{}
                activity = @{}
                last_phase = ""
            }
        }

        switch ($phase) {
            "metadata" {
                $allResults[$repoName].metadata = Analyze-Metadata $repoName
                $allResults[$repoName].last_phase = "metadata"
            }
            "technologies" {
                $allResults[$repoName].technologies = Analyze-Technologies $repoName
                $allResults[$repoName].last_phase = "technologies"
            }
            "dependencies" {
                $allResults[$repoName].dependencies = Analyze-Dependencies $repoName
                $allResults[$repoName].last_phase = "dependencies"
            }
            "security" {
                $allResults[$repoName].security = Analyze-Security $repoName
                $allResults[$repoName].last_phase = "security"
            }
            "activity" {
                $allResults[$repoName].activity = Analyze-Activity $repoName
                $allResults[$repoName].last_phase = "activity"
            }
        }

        # Průběžné ukládání JSON
        $allResults | ConvertTo-Json -Depth 5 | Set-Content -Path $jsonFile
    }

    # Po každém cyklu uložit CSV a report
    $csvRows = foreach ($repo in $allResults.Keys) {
        $r = $allResults[$repo]
        [PSCustomObject]@{
            RepoName    = $repo
            Description = if ($r.metadata.description) { $r.metadata.description } else { "" }
            Language    = if ($r.metadata.language) { $r.metadata.language } else { "" }
            SizeKB      = if ($r.metadata.size_kb) { $r.metadata.size_kb } else { "" }
            License     = if ($r.metadata.license) { $r.metadata.license } else { "" }
            Stars       = if ($r.metadata.stars) { $r.metadata.stars } else { 0 }
            OpenIssues  = if ($r.metadata.open_issues) { $r.metadata.open_issues } else { 0 }
            Technologies = $r.technologies -join ';'
            Dependencies = $r.dependencies -join ';'
            Secrets     = if ($r.security.secrets) { $r.security.secrets -join ';' } else { "" }
            TodoCount   = if ($r.security.todo_count) { $r.security.todo_count } else { 0 }
            LastPhase   = $r.last_phase
        }
    }
    $csvRows | Export-Csv -Path $csvFile -NoTypeInformation -Force

    $md = "# Kontinuální analýza – stav po $cycle cyklech`n`n"
    $md += "Čas: $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')`n`n"
    $md += "## Repozitáře`n`n"
    $md += "| Repozitář | Popis | Jazyk | Technologie | Závislosti | Secrets | TODO |`n"
    $md += "|-----------|-------|-------|-------------|------------|---------|------|`n"
    foreach ($repo in $allResults.Keys) {
        $r = $allResults[$repo]
        $desc = if ($r.metadata.description) { $r.metadata.description } else { "" }
        $desc = $desc.Substring(0, [Math]::Min(50, $desc.Length))
        $tech = $r.technologies -join ', '
        $deps = ($r.dependencies | Select-Object -First 3) -join ', '
        $secrets = if ($r.security.secrets) { $r.security.secrets -join ', ' } else { "" }
        $todo = if ($r.security.todo_count) { $r.security.todo_count } else { 0 }
        $md += "| $repo | $desc | $($r.metadata.language) | $tech | $deps | $secrets | $todo |`n"
    }
    $md | Set-Content -Path $reportFile -Force

    Write-Host "Cyklus $cycle dokončen. Výsledky uloženy do $OutputDir" -ForegroundColor Green
    Add-Content -Path $logFile -Value "[$(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')] Cyklus $cycle ($phase) dokončen."

    # Posun fáze
    $phaseIndex++

    # Pauza, pokud zbývá čas
    if ((Get-Date) -lt $endTime) {
        Write-Host "Čekám $IntervalSeconds sekund..." -ForegroundColor DarkYellow
        Start-Sleep -Seconds $IntervalSeconds
    }
}

Write-Host "Analýza ukončena po $MaxDurationMinutes minutách." -ForegroundColor Cyan
Write-Host "Výsledky: $jsonFile, $csvFile, $reportFile" -ForegroundColor Cyan
