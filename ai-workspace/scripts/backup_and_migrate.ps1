param(
  [Parameter(Mandatory=\False)][string]\ = (Join-Path \ '..\backups')
)
# Tento skript je template. Před spuštěním upravte cílové URL a ověřte oprávnění.
New-Item -ItemType Directory -Path \ -Force | Out-Null
\ = Join-Path \ '..\repo_inventory.csv'
Get-Content -Path \ | ForEach-Object {
  if (\ -match '^repo_name') { return }
  \ = \ -split ','
  \ = \[0].Trim('"')
  \ = \[1].Trim('"')
  \ = "https://github.com/\/\.git"
  \ = Join-Path \ ("\.git")
  Write-Host "Mirroring \ to \"
  git clone --mirror \ \
}
Write-Host "Backup complete in \"
