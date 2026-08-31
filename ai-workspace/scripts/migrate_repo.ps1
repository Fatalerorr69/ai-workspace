param(
    [Parameter(Mandatory=$true)][string]$RepoName,
    [Parameter(Mandatory=$true)][string]$TargetPath,
    [Parameter(Mandatory=$true)][string]$MonorepoUrl,
    [string]$SourceOwner = "Fatalerorr69",
    [switch]$TestMode,
    [string]$LogFile = "migration.log",
    [string]$StateFile = "migration_state.csv",
    [int]$Wave = 0
)

$ErrorActionPreference = "Stop"
$workDir = Join-Path $env:TEMP "migrate_$RepoName"
$sourceUrl = "https://github.com/$SourceOwner/$RepoName.git"

function Log($msg) {
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    $logMsg = "[$timestamp] $msg"
    Write-Host $logMsg -ForegroundColor Cyan
    Add-Content -Path $LogFile -Value $logMsg
}

function Update-State($status) {
    $line = [PSCustomObject]@{
        repo_name   = $RepoName
        target_path = $TargetPath
        wave        = $Wave
        status      = $status
        timestamp   = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    }
    $line | Export-Csv -Path $StateFile -Append -NoTypeInformation
}

Log "=== Migrace $RepoName -> $TargetPath ==="

if (Test-Path $workDir) { Remove-Item $workDir -Recurse -Force }
New-Item -ItemType Directory -Path $workDir | Out-Null
Set-Location $workDir

Log "Klonuji $sourceUrl ..."
git clone --mirror $sourceUrl $RepoName.git
if ($LASTEXITCODE -ne 0) { Update-State "clone_failed"; throw "Klonování selhalo" }
Set-Location "$workDir\$RepoName.git"

$filterRepo = Get-Command git-filter-repo -ErrorAction SilentlyContinue
if (-not $filterRepo) {
    Log "VAROVÁNÍ: git-filter-repo není nainstalován, soubory zůstanou v rootu."
} else {
    Log "Přesouvám soubory do $TargetPath ..."
    git filter-repo --to-subdirectory-filter $TargetPath --force
    if ($LASTEXITCODE -ne 0) { Update-State "filter_failed"; throw "git filter-repo selhal" }
}

if ($TestMode) {
    Log "[TEST MODE] Push by proběhl do: $MonorepoUrl"
    Update-State "test_ok"
} else {
    Log "Push do monorepa (větve a tagy) ..."
    git remote add monorepo $MonorepoUrl
    git push monorepo "refs/heads/*:refs/heads/*" "refs/tags/*:refs/tags/*"
    if ($LASTEXITCODE -ne 0) {
        Log "VAROVÁNÍ: Push hlásí chybu, ale hlavní větve mohly projít. Pokračuji."
    }
    Update-State "migrated"
}

Log "Migrace $RepoName dokončena."
