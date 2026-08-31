param()

$inv = Join-Path $PSScriptRoot "..\repo_inventory.csv"
$out = Join-Path $PSScriptRoot "..\audit_summary.csv"

"repo_name,last_commit_date,days_since_last_commit,size_kb,archived,private,language" | Out-File -FilePath $out -Encoding utf8

if (-not (Test-Path $inv)) {
  Write-Error "repo_inventory.csv not found at $inv"
  exit 1
}

Get-Content -Path $inv | ForEach-Object {
  if ($_ -match '^repo_name') { return }
  $cols = $_ -split ','
  $repo = $cols[0].Trim('"')
  $pushed = $cols[2].Trim('"')
  if ([string]::IsNullOrEmpty($pushed)) {
    $days = 'unknown'
  } else {
    try {
      $pushedDate = [datetime]::Parse($pushed)
      $days = (New-TimeSpan -Start $pushedDate -End (Get-Date)).Days
    } catch {
      $days = 'unknown'
    }
  }
  $size = if ($cols.Count -gt 3) { $cols[3] } else { "" }
  $archived = if ($cols.Count -gt 7) { $cols[7] } else { "" }
  $private = if ($cols.Count -gt 8) { $cols[8] } else { "" }
  $lang = if ($cols.Count -gt 5) { $cols[5] } else { "" }
  $line = '{0},{1},{2},{3},{4},{5},{6}' -f $repo,$pushed,$days,$size,$archived,$private,$lang
  $line | Out-File -FilePath $out -Append -Encoding utf8
}
Write-Host "Audit summary saved to $out"
