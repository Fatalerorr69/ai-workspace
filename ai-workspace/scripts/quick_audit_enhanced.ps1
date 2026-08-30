param()

$Base = "C:\github-inventory"
$inv = Join-Path $Base "repo_inventory.csv"
$out = Join-Path $Base "audit_summary.csv"

if (-not (Test-Path $inv)) { Write-Error "repo_inventory.csv not found at $inv"; exit 1 }

"repo_name,last_commit_date,days_since_last_commit,size_kb,archived,private,language,stars,forks,open_issues,risk_score,priority,notes" | Out-File -FilePath $out -Encoding utf8

Get-Content $inv | ForEach-Object {
  if ($_ -match '^repo_name') { return }
  $cols = $_ -split ','
  $repo = $cols[0].Trim('"')
  $pushed = $cols[2].Trim('"')
  $size = if ($cols.Count -gt 3) { $cols[3] } else { 0 }
  $archived = if ($cols.Count -gt 7) { $cols[7] } else { "False" }
  $private = if ($cols.Count -gt 8) { $cols[8] } else { "False" }
  $lang = if ($cols.Count -gt 5) { $cols[5] } else { "" }
  $stars = if ($cols.Count -gt 10) { $cols[10] } else { 0 }
  $forks = if ($cols.Count -gt 11) { $cols[11] } else { 0 }
  $open_issues = if ($cols.Count -gt 6) { $cols[6] } else { 0 }

  try {
    if ([string]::IsNullOrEmpty($pushed)) { $days = 9999 } else { $days = (New-TimeSpan -Start ([datetime]::Parse($pushed)) -End (Get-Date)).Days }
  } catch { $days = 9999 }

  # Simple risk scoring heuristic
  $risk = 0
  if ($days -gt 365) { $risk += 40 } elseif ($days -gt 90) { $risk += 20 }
  if ($private -eq "True") { $risk += 10 }
  if ([int]$open_issues -gt 10) { $risk += 15 }
  if ([int]$stars -lt 1) { $risk += 5 }
  if ($archived -eq "True") { $risk += 50 }

  if ($risk -ge 60) { $priority = "high" } elseif ($risk -ge 30) { $priority = "medium" } else { $priority = "low" }

  $line = '{0},{1},{2},{3},{4},{5},{6},{7},{8},{9},{10},{11},{12}' -f $repo,$pushed,$days,$size,$archived,$private,$lang,$stars,$forks,$open_issues,$risk,$priority,""
  $line | Out-File -FilePath $out -Append -Encoding utf8
}

Write-Host "Quick audit saved to $out"
