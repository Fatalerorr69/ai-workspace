<#
.SYNOPSIS
  Nastaví branch protection pro hlavní větev monorepa.
.PARAMETER Repo
  Cesta k repozitáři (owner/repo).
#>
param(
    [Parameter(Mandatory=$true)][string]$Repo = "Fatalerorr69/ai-workspace"
)

if (-not $env:GITHUB_TOKEN) {
    throw "GITHUB_TOKEN není nastaven"
}

$headers = @{
    Authorization = "Bearer $env:GITHUB_TOKEN"
    "User-Agent"  = "PowerShell-Protection"
    Accept        = "application/vnd.github+json"
}

$uri = "https://api.github.com/repos/$Repo/branches/main/protection"
$body = @{
    required_status_checks = $null
    enforce_admins = $true
    required_pull_request_reviews = @{
        required_approving_review_count = 1
    }
    restrictions = $null
} | ConvertTo-Json -Depth 3

Write-Host "Nastavuji branch protection pro $Repo ..."
Invoke-RestMethod -Uri $uri -Method Put -Headers $headers -Body $body -ContentType "application/json" | Out-Null
Write-Host "Hotovo." -ForegroundColor Green