function Set-RepoArchived([string]$Owner,[string]$Repo,[bool]$Archived) {
  if (-not $env:GITHUB_TOKEN) { throw "Set GITHUB_TOKEN" }
  $uri = "https://api.github.com/repos/$Owner/$Repo"
  $body = @{ archived = $Archived } | ConvertTo-Json
  Invoke-RestMethod -Method Patch -Uri $uri -Headers @{ Authorization = "token $env:GITHUB_TOKEN"; "User-Agent"="reorg-script" } -Body $body -ContentType "application/json"
  Write-Host "Set archived=$Archived for $Owner/$Repo"
}

function Set-BranchProtection([string]$Owner,[string]$Repo,[string]$Branch) {
  if (-not $env:GITHUB_TOKEN) { throw "Set GITHUB_TOKEN" }
  $uri = "https://api.github.com/repos/$Owner/$Repo/branches/$Branch/protection"
  $body = @{
    required_status_checks = @{ strict = $true; contexts = @() }
    enforce_admins = $true
    required_pull_request_reviews = @{ dismissal_restrictions = @{}; dismiss_stale_reviews = $true; require_code_owner_reviews = $true }
    restrictions = $null
  } | ConvertTo-Json -Depth 10
  Invoke-RestMethod -Method Put -Uri $uri -Headers @{ Authorization = "token $env:GITHUB_TOKEN"; "User-Agent"="reorg-script" } -Body $body -ContentType "application/json"
  Write-Host "Branch protection set for $Owner/$Repo:$Branch"
}
