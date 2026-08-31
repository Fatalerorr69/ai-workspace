<#
.SYNOPSIS
  Archivuje repozitáře s action=archive pro danou vlnu.
.PARAMETER Wave
  Číslo vlny.
.PARAMETER LogFile
  Cesta k logu.
#>
param(
    [Parameter(Mandatory=$true)][int]$Wave,
    [string]$LogFile = "migration.log"
)

if (-not $env:GITHUB_TOKEN) {
    throw "GITHUB_TOKEN není nastaven"
}

$headers = @{
    Authorization = "Bearer $env:GITHUB_TOKEN"
    "User-Agent"  = "PowerShell-Archive"
    Accept        = "application/vnd.github+json"
}

$planFile = Join-Path $PSScriptRoot "reorganize_plan.csv"
$plan = Import-Csv $planFile
$reposToArchive = $plan | Where-Object { $_.migration_wave -eq $Wave -and $_.action -eq "archive" }

Write-Host "Vlna $Wave – počet repozitářů k archivaci: $($reposToArchive.Count)" -ForegroundColor Magenta
Add-Content -Path $LogFile -Value "===== VLNA $Wave - ARCHIVACE ====="

foreach ($repo in $reposToArchive) {
    $repoName = $repo.repo_name
    $owner = "Fatalerorr69"  # upravte dle potřeby
    $uri = "https://api.github.com/repos/$owner/$repoName"
    $body = @{ archived = $true } | ConvertTo-Json

    Write-Host "Archivuji $owner/$repoName ..." -ForegroundColor Yellow
    try {
        Invoke-RestMethod -Uri $uri -Method Patch -Headers $headers -Body $body -ContentType "application/json" | Out-Null
        $msg = "  Archivováno: $repoName"
        Write-Host $msg -ForegroundColor Green
        Add-Content -Path $LogFile -Value $msg
    }
    catch {
        $msg = "  Selhalo: $repoName - $_"
        Write-Warning $msg
        Add-Content -Path $LogFile -Value $msg
    }
}