<#
.SYNOPSIS
  Vytvori repo_inventory.csv pro ucet/org GitHub pres REST API.
.DESCRIPTION
  Pouziva GITHUB_TOKEN z prostredi, stahne vsechny repozitare (vcetne
  privatnich) a pro kazdy zjisti, zda ma nakonfigurovane GitHub Actions.
.PARAMETER Owner
  Uzivatelske jmeno nebo nazev organizace.
.PARAMETER IsOrg
  Prepinac indikujici, ze Owner je organizace.
.EXAMPLE
  $env:GITHUB_TOKEN = "ghp_..."
  .\Get-RepoInventory.ps1 -Owner "Fatalerorr69"
#>

param(
    [Parameter(Mandatory = $true)]
    [string]$Owner,

    [switch]$IsOrg
)

$ErrorActionPreference = "Stop"

# Kontrola tokenu
if (-not $env:GITHUB_TOKEN) {
    Write-Error "GITHUB_TOKEN neni nastaven. Pouzij: `$env:GITHUB_TOKEN = 'ghp_...'"
}

$headers = @{
    Authorization = "Bearer $env:GITHUB_TOKEN"
    "User-Agent"  = "PowerShell-Inventory"
    Accept        = "application/vnd.github+json"
}

# Ziskani vsech repozitaru s paginaci
Write-Host "Stahuji seznam repozitářů pro '$Owner'..." -ForegroundColor Cyan
$baseUri = if ($IsOrg) {
    "https://api.github.com/orgs/$Owner/repos"
} else {
    "https://api.github.com/user/repos?affiliation=owner"
}

$repos = @()
$page = 1
do {
    $separator = if ($baseUri -match '\?') { '&' } else { '?' }
    $uri = "${baseUri}${separator}per_page=100&page=$page"
    Write-Host "  Strana $page ..." -ForegroundColor DarkGray
    
    $response = Invoke-WebRequest -Uri $uri -Headers $headers -UseBasicParsing
    $pageRepos = $response.Content | ConvertFrom-Json
    if ($pageRepos) {
        $repos += $pageRepos
    }
    
    # Zjisteni dalsi strany z hlavicky Link
    $linkHeader = $response.Headers['Link']
    $hasNext = $linkHeader -match 'rel="next"'
    $page++
} while ($hasNext)

Write-Host "Nalezeno $($repos.Count) repozitářů." -ForegroundColor Green

# Priprava vystupnich dat
$results = @()
$counter = 0
foreach ($repo in $repos) {
    $counter++
    Write-Progress -Activity "Zpracovávám repozitáře" -Status "$counter z $($repos.Count)" -PercentComplete (($counter / $repos.Count) * 100)

    $repoFullName = $repo.full_name
    $repoName     = $repo.name
    $ownerLogin   = $repo.owner.login

    # Zjisteni has_actions pres /actions/workflows
    $hasActions = $false
    try {
        $wfUri = "https://api.github.com/repos/$repoFullName/actions/workflows"
        $wfResponse = Invoke-WebRequest -Uri $wfUri -Headers $headers -UseBasicParsing -ErrorAction Stop
        $workflows = $wfResponse.Content | ConvertFrom-Json
        # workflows.total_count > 0 znamena existenci alespon jednoho workflow
        $hasActions = ($workflows.total_count -gt 0)
    }
    catch {
        # 404 znamena zadne workflows, 403 muze byt omezeni, ale nebereme jako chybu
        $hasActions = $false
    }

    # Bezpecna konverze datumu
    $pushedAt = $null
    if ($repo.pushed_at) {
        try { $pushedAt = [datetime]::Parse($repo.pushed_at) } catch { $pushedAt = $null }
    }
    $createdAt = $null
    if ($repo.created_at) {
        try { $createdAt = [datetime]::Parse($repo.created_at) } catch { $createdAt = $null }
    }

    $results += [PSCustomObject]@{
        repo_name          = $repoName
        owner              = $ownerLogin
        last_commit_date   = if ($pushedAt) { $pushedAt.ToString("yyyy-MM-ddTHH:mm:ssZ") } else { "" }
        size_kb            = [int]$repo.size
        license            = if ($repo.license) { $repo.license.spdx_id } else { "None" }
        primary_language   = if ($repo.language) { $repo.language } else { "" }
        open_issues        = [int]$repo.open_issues_count
        archived           = [bool]$repo.archived
        private            = [bool]$repo.private
        has_actions        = $hasActions
        stars              = [int]$repo.stargazers_count
        forks              = [int]$repo.forks_count
        topics             = if ($repo.topics) { ($repo.topics -join ';') } else { "" }
        default_branch     = $repo.default_branch
        has_wiki           = [bool]$repo.has_wiki
        has_pages          = [bool]$repo.has_pages
    }
}

Write-Progress -Activity "Zpracovávám repozitáře" -Completed

# Export do CSV
$outFile = Join-Path -Path $PSScriptRoot -ChildPath "repo_inventory.csv"
$results | Export-Csv -Path $outFile -NoTypeInformation -Encoding UTF8

Write-Host "Hotovo: $outFile ($($results.Count) řádků)." -ForegroundColor Green