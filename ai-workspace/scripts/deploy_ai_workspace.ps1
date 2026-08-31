# File: deploy_ai_workspace.ps1
param(
  [string]$Owner = "Fatalerorr69",
  [string]$RepoName = "ai-workspace",
  [string]$LocalSource = "C:\github-inventory",   # lokální složka s obsahem
  [switch]$UseTestOrg
)

if ($UseTestOrg) { $Owner = "$Owner-test" }

if (-not $env:GITHUB_TOKEN) { Write-Error "Nastavte GITHUB_TOKEN v prostředí před spuštěním"; exit 1 }

# Helper: GitHub API call
function GhApi($method, $uri, $body = $null) {
  $headers = @{ Authorization = "token $env:GITHUB_TOKEN"; "User-Agent" = "ai-workspace-deployer" }
  if ($body) {
    return Invoke-RestMethod -Method $method -Uri $uri -Headers $headers -Body ($body | ConvertTo-Json -Depth 10) -ContentType "application/json"
  } else {
    return Invoke-RestMethod -Method $method -Uri $uri -Headers $headers
  }
}

# 1) Create repository
$createUri = "https://api.github.com/orgs/$Owner/repos"
# If owner is a user, use /user/repos
try {
  # detect if owner is org or user
  $ownerInfo = GhApi "GET" "https://api.github.com/users/$Owner"
  if ($ownerInfo.type -eq "User") {
    $createUri = "https://api.github.com/user/repos"
  } else {
    $createUri = "https://api.github.com/orgs/$Owner/repos"
  }
} catch {
  Write-Host "Nelze získat informace o $Owner, pokusím se vytvořit repo pod uživatelem (user) endpoint."
  $createUri = "https://api.github.com/user/repos"
}

$body = @{
  name = $RepoName
  description = "Centralized AI workspace for inventory, audit, prompts and migration orchestration"
  private = $true
  has_issues = $true
  has_projects = $false
  has_wiki = $false
}
try {
  Write-Host "Vytvářím repozitář $Owner/$RepoName ..."
  $resp = GhApi "POST" $createUri $body
  Write-Host "Repo vytvořeno: $($resp.html_url)"
} catch {
  Write-Host "Repo pravděpodobně již existuje nebo došlo k chybě: $($_.Exception.Message)"
}

# 2) Initialize local git and push content (if LocalSource exists)
if (Test-Path $LocalSource) {
  Write-Host "Připravím lokální obsah z $LocalSource a pushnu do $Owner/$RepoName"
  $tmp = Join-Path $env:TEMP ("ai_workspace_push_" + (Get-Date -Format "yyyyMMddHHmmss"))
  New-Item -ItemType Directory -Path $tmp -Force | Out-Null
  # Copy files (exclude .git)
  robocopy $LocalSource $tmp /MIR /XD ".git" | Out-Null

  Push-Location $tmp
  git init
  git checkout -b main
  git add -A
  git commit -m "Initial ai-workspace import"
  $remoteUrl = "https://github.com/$Owner/$RepoName.git"
  git remote add origin $remoteUrl
  # Use token for push if necessary (optional): embed token in URL (temporary)
  $pushUrl = $remoteUrl
  try {
    git push -u origin main
    Write-Host "Push successful to $remoteUrl"
  } catch {
    Write-Host "Push failed, retrying with token-authenticated URL"
    $tokenUrl = "https://$($env:GITHUB_TOKEN)@github.com/$Owner/$RepoName.git"
    git remote set-url origin $tokenUrl
    git push -u origin main
    # reset remote to normal URL
    git remote set-url origin $remoteUrl
    Write-Host "Push done with token URL"
  }
  Pop-Location
  Remove-Item -Recurse -Force $tmp
} else {
  Write-Host "Lokální zdroj $LocalSource neexistuje. Vytvořím základní strukturu přímo v repozitáři přes API (README)."
  $readmeUri = "https://api.github.com/repos/$Owner/$RepoName/contents/README.md"
  $content = [Convert]::ToBase64String([Text.Encoding]::UTF8.GetBytes("# AI Workspace`n`nCentralized workspace for inventory, audit and migration orchestration."))
  $body = @{ message = "Add README"; content = $content }
  GhApi "PUT" $readmeUri $body | Out-Null
  Write-Host "README vytvořen v $Owner/$RepoName"
}

# 3) Set GitHub Secrets for Actions (example: AI_WORKSPACE_TOKEN)
$secretName = "AI_WORKSPACE_TOKEN"
$secretValue = $env:GITHUB_TOKEN
# To set secret via API we need repo public key; implement helper
function Set-RepoSecret($owner,$repo,$name,$value) {
  $pubKey = GhApi "GET" "https://api.github.com/repos/$owner/$repo/actions/secrets/public-key"
  $keyId = $pubKey.key_id
  $key = $pubKey.key
  # encrypt value using RSA (requires .NET)
  $bytes = [System.Text.Encoding]::UTF8.GetBytes($value)
  $rsa = [System.Security.Cryptography.RSA]::Create()
  $rsa.ImportSubjectPublicKeyInfo([Convert]::FromBase64String($key), [ref]0) | Out-Null
  $encrypted = $rsa.Encrypt($bytes, [System.Security.Cryptography.RSAEncryptionPadding]::OaepSHA1)
  $encryptedValue = [Convert]::ToBase64String($encrypted)
  $body = @{ encrypted_value = $encryptedValue; key_id = $keyId }
  GhApi "PUT" "https://api.github.com/repos/$owner/$repo/actions/secrets/$name" $body | Out-Null
  Write-Host "Secret $name set for $owner/$repo"
}

try {
  Set-RepoSecret -owner $Owner -repo $RepoName -name $secretName -value $secretValue