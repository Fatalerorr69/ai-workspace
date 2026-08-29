Export-ModuleMember -Function SafeSync, PushWithRetry

function SafeSync {
  param([string]$RepoPath, [switch]$AutoStash)
  Push-Location $RepoPath
  try {
    $porcelain = git status --porcelain 2>$null
    if ($porcelain) {
      if ($AutoStash) {
        $stash = git stash push -m "auto-sync-$(Get-Date -Format yyyyMMdd_HHmmss)" 2>$null
        Write-Host "Stashed: $stash"
      } else {
        throw "Uncommitted changes exist in $RepoPath"
      }
    }
    git fetch origin --prune
    $branch = git rev-parse --abbrev-ref HEAD
    git pull --rebase origin $branch
  } catch {
    Write-Warning $_.Exception.Message
    throw
  } finally {
    if ($AutoStash) {
      try { git stash pop } catch { Write-Warning "No stash to pop or conflict occurred." }
    }
    Pop-Location
  }
}

function PushWithRetry {
  param([string]$RepoPath, [int]$Retries = 3)
  Push-Location $RepoPath
  for ($i=1; $i -le $Retries; $i++) {
    try {
      git push origin (git rev-parse --abbrev-ref HEAD)
      Write-Host "Push succeeded for $RepoPath"
      break
    } catch {
      Write-Warning ("Push failed attempt {0}: {1}" -f $i, $_.Exception.Message)
      Start-Sleep -Seconds (5 * $i)
      if ($i -eq $Retries) { throw "Push failed after $Retries attempts for $RepoPath" }
    }
  }
  Pop-Location
}
