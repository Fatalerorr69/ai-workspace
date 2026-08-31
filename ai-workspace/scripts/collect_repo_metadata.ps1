param(
  [Parameter(Mandatory=$true)]
  [string]$Org
)

if (-not $env:GITHUB_TOKEN) {
  Write-Error "Nastavte GITHUB_TOKEN v prostředí"
  exit 1
}

$out = Join-Path $PSScriptRoot '..\repo_inventory.csv'
"repo_name,owner,last_commit_date,size_kb,license,primary_language,open_issues,archived,private,has_actions" | Out-File -FilePath $out -Encoding utf8

$page = 1
while ($true) {
  $url = "https://api.github.com/orgs/$Org/repos?per_page=100&page=$page"
  try {
    $resp = Invoke-RestMethod -Headers @{ Authorization = "token $env:GITHUB_TOKEN"; "User-Agent"="inventory-script" } -Uri $url -Method Get
  } catch {
    Write-Error "API call failed for page $page: $($_.Exception.Message)"
    exit 1
  }
  if (-not $resp -or $resp.Count -eq 0) { break }
  foreach ($r in $resp) {
    $license = if ($r.license) { $r.license.name } else { "none" }
    $language = if ($r.language) { $r.language } else { "none" }
    $line = '{0},{1},{2},{3},{4},{5},{6},{7},{8},{9}' -f $r.name,$r.owner.login,$r.pushed_at,$r.size,$license,$language,$r.open_issues_count,$r.archived,$r.private,($r.has_actions -ne $null ? $r.has_actions : $false)
    $line | Out-File -FilePath $out -Append -Encoding utf8
  }
  $page++
}
Write-Host "Saved inventory to $out"
