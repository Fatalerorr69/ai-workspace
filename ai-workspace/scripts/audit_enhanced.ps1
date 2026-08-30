param([string]$OrgOrUser)

if (-not $env:GITHUB_TOKEN) { Write-Error "Set GITHUB_TOKEN"; exit 1 }

$out = Join-Path $PSScriptRoot "..\repo_inventory.csv"
"repo_name,owner,last_commit_date,size_kb,license,primary_language,open_issues,archived,private,has_actions,stars,forks,topics,default_branch,has_wiki,has_pages" | Out-File -FilePath $out -Encoding utf8

$page = 1
while ($true) {
  $url = "https://api.github.com/users/$OrgOrUser/repos?per_page=100&page=$page"
  $resp = Invoke-RestMethod -Headers @{ Authorization = "token $env:GITHUB_TOKEN"; "User-Agent"="inventory-enhanced" } -Uri $url -Method Get
  if (-not $resp -or $resp.Count -eq 0) { break }
  foreach ($r in $resp) {
    $topics = ($r.topics -join ';')
    $license = if ($r.license) { $r.license.spdx_id } else { "none" }
    $line = '{0},{1},{2},{3},{4},{5},{6},{7},{8},{9},{10},{11},{12},{13},{14},{15}' -f $r.name,$r.owner.login,$r.pushed_at,$r.size,$license,($r.language -ne $null ? $r.language : "none"),$r.open_issues_count,$r.archived,$r.private,($r.has_actions -ne $null ? $r.has_actions : $false),$r.stargazers_count,$r.forks_count,$topics,$r.default_branch,$r.has_wiki,$r.has_pages
    $line | Out-File -FilePath $out -Append -Encoding utf8
  }
  $page++
}
Write-Host "Saved enhanced inventory to $out"
