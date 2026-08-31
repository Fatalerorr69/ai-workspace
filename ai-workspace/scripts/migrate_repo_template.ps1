param([Parameter(Mandatory=$true)][string]$RepoName,[Parameter(Mandatory=$true)][string]$Owner,[Parameter(Mandatory=$true)][string]$TargetRepoUrl,[switch]$TestMode,[string]$Branch="main",[switch]$UseFilterRepo)

$backupRoot = "C:\github-inventory\backups"
New-Item -ItemType Directory -Path $backupRoot -Force | Out-Null
$backupDir = Join-Path $backupRoot "$RepoName.git"
$logDir = "C:\github-inventory\logs"
New-Item -ItemType Directory -Path $logDir -Force | Out-Null
$logFile = Join-Path $logDir ("migrate_" + $RepoName + "_" + (Get-Date -Format "yyyyMMdd_HHmmss") + ".log")

function Log($m) { $m | Tee-Object -FilePath $logFile -Append; Write-Host $m }

Log "=== Migration start: $RepoName ==="

# Mirror with retry
if (-not (Test-Path $backupDir)) {
  $tries = 0
  while ($tries -lt 3) {
    try {
      Log "Cloning mirror https://github.com/$Owner/$RepoName.git -> $backupDir (attempt $($tries+1))"
      git clone --mirror "https://github.com/$Owner/$RepoName.git" $backupDir 2>&1 | Tee-Object -FilePath $logFile -Append
      break
    } catch {
      $tries++
      Start-Sleep -Seconds (5 * $tries)
      if ($tries -ge 3) { Log "ERROR: git clone failed after 3 attempts"; throw $_ }
    }
  }
} else {
  Log "Backup exists: $backupDir"
}

# Push mirror
$target = $TargetRepoUrl
if ($TestMode) { Log "TestMode: pushing to $target" } else { Log "Production push target: $target" }

Push-Location $backupDir
try {
  git remote remove target -q 2>$null
} catch {}
git remote add target $target 2>&1 | Tee-Object -FilePath $logFile -Append
git push target --mirror 2>&1 | Tee-Object -FilePath $logFile -Append
Pop-Location

Log "Verify last commits in backup:"
git --git-dir=$backupDir log --oneline -n 5 2>&1 | Tee-Object -FilePath $logFile -Append

if ($UseFilterRepo) {
  Log "Filter-repo import requested. See migration_playbook.md for instructions and run migrate_filterrepo_<repo>.ps1"
}

Log "=== Migration finished for $RepoName ==="
