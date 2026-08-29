[CmdletBinding()]
param(
    [string]$Workspace = "E:\GIT",
    [string]$ProjectRoot = "E:\GIT\STARCORE-ANDROID"
)

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

$StartTime = Get-Date

$AuditRoot = Join-Path $ProjectRoot "audit\local"
$RunId = Get-Date -Format "yyyyMMdd_HHmmss"
$RunDir = Join-Path $AuditRoot $RunId

New-Item -ItemType Directory -Force -Path $RunDir | Out-Null

$JsonPath = Join-Path $RunDir "local-inventory.json"
$CsvPath  = Join-Path $RunDir "repositories.csv"
$MdPath   = Join-Path $RunDir "local-audit-report.md"
$TxtPath  = Join-Path $RunDir "local-audit-summary.txt"

function Invoke-GitSafe {
    param(
        [string]$RepoPath,
        [string[]]$Arguments
    )

    Push-Location $RepoPath

    try {
        $Output = & git @Arguments 2>&1
        $ExitCode = $LASTEXITCODE

        return [PSCustomObject]@{
            Output   = ($Output -join "`n").Trim()
            ExitCode = $ExitCode
        }
    }
    catch {
        return [PSCustomObject]@{
            Output   = $_.Exception.Message
            ExitCode = -1
        }
    }
    finally {
        Pop-Location
    }
}

function Get-RelativePathSafe {
    param(
        [string]$BasePath,
        [string]$TargetPath
    )

    try {
        $Base = [System.IO.Path]::GetFullPath($BasePath).TrimEnd('\')
        $Target = [System.IO.Path]::GetFullPath($TargetPath)

        if ($Target.StartsWith($Base, [System.StringComparison]::OrdinalIgnoreCase)) {
            return $Target.Substring($Base.Length).TrimStart('\')
        }

        return $Target
    }
    catch {
        return $TargetPath
    }
}

function Test-IgnoredPath {
    param(
        [string]$Path
    )

    $Patterns = @(
        '\node_modules\',
        '\.git\',
        '\.venv\',
        '\venv\',
        '\__pycache__\',
        '\target\',
        '\bin\',
        '\obj\',
        '\dist\',
        '\build\',
        '\cache\',
        '\.cache\'
    )

    foreach ($Pattern in $Patterns) {
        if ($Path -like "*$Pattern*") {
            return $true
        }
    }

    return $false
}

function Get-DirectoryStatistics {
    param(
        [string]$Path
    )

    [long]$Bytes = 0
    [long]$Files = 0

    try {
        Get-ChildItem `
            -LiteralPath $Path `
            -File `
            -Recurse `
            -Force `
            -ErrorAction SilentlyContinue |
            ForEach-Object {
                if (-not (Test-IgnoredPath $_.FullName)) {
                    $Bytes += $_.Length
                    $Files++
                }
            }
    }
    catch {
    }

    return [PSCustomObject]@{
        Bytes = $Bytes
        Files = $Files
    }
}

Write-Host ""
Write-Host "============================================================" -ForegroundColor Cyan
Write-Host "STARCORE ANDROID - LOCAL ECOSYSTEM AUDIT" -ForegroundColor Cyan
Write-Host "============================================================" -ForegroundColor Cyan
Write-Host "Start       : $($StartTime.ToString('o'))"
Write-Host "Workspace   : $Workspace"
Write-Host "ProjectRoot : $ProjectRoot"
Write-Host "Output      : $RunDir"
Write-Host "============================================================"
Write-Host ""

if (-not (Test-Path -LiteralPath $Workspace -PathType Container)) {
    throw "Workspace does not exist: $Workspace"
}

if (-not (Test-Path -LiteralPath $ProjectRoot -PathType Container)) {
    throw "Project root does not exist: $ProjectRoot"
}

$GitVersion = (& git --version 2>&1) -join " "

Write-Host "[1/8] Workspace inventory..."

$TopLevel = @(
    Get-ChildItem -LiteralPath $Workspace -Force |
    Sort-Object Name |
    ForEach-Object {
        $IsDirectory = $_.PSIsContainer
        $HasGit = $false

        if ($IsDirectory) {
            $HasGit = Test-Path -LiteralPath (Join-Path $_.FullName ".git")
        }

        [PSCustomObject]@{
            Name          = $_.Name
            Type          = if ($IsDirectory) { "Directory" } else { "File" }
            FullName      = $_.FullName
            GitRoot       = $HasGit
            Length        = if ($IsDirectory) { $null } else { $_.Length }
            LastWriteTime = $_.LastWriteTime
        }
    }
)

Write-Host "[2/8] Recursive Git repository discovery..."

$GitDirectories = @(
    Get-ChildItem `
        -LiteralPath $Workspace `
        -Directory `
        -Force `
        -Recurse `
        -ErrorAction SilentlyContinue |
    Where-Object {
        $_.Name -eq ".git" -and
        -not (Test-IgnoredPath $_.FullName)
    }
)

$Repositories = @()

foreach ($GitDir in $GitDirectories) {

    $RepoPath = Split-Path $GitDir.FullName -Parent

    if ($RepoPath -eq $ProjectRoot) {
        continue
    }

    Write-Host "  Inspecting: $RepoPath"

    $Branch = Invoke-GitSafe $RepoPath @("branch", "--show-current")
    $Status = Invoke-GitSafe $RepoPath @("status", "--short", "--branch")
    $Commit = Invoke-GitSafe $RepoPath @("rev-parse", "HEAD")
    $Origin = Invoke-GitSafe $RepoPath @("remote", "get-url", "origin")
    $Upstream = Invoke-GitSafe $RepoPath @(
        "rev-parse",
        "--abbrev-ref",
        "@{upstream}"
    )
    $AheadBehind = Invoke-GitSafe $RepoPath @(
        "rev-list",
        "--left-right",
        "--count",
        "HEAD...@{upstream}"
    )
    $Log = Invoke-GitSafe $RepoPath @(
        "log",
        "-1",
        "--format=%H|%ad|%an|%s",
        "--date=iso-strict"
    )

    $StatusLines = @(
        $Status.Output -split "`n" |
        Where-Object {
            -not [string]::IsNullOrWhiteSpace($_)
        }
    )

    $WorkingTreeDirty = $false

    if ($StatusLines.Count -gt 1) {
        $WorkingTreeDirty = $true
    }

    $Stats = Get-DirectoryStatistics -Path $RepoPath

    $Readme = @(
        Get-ChildItem `
            -LiteralPath $RepoPath `
            -File `
            -Force `
            -ErrorAction SilentlyContinue |
        Where-Object {
            $_.Name -match '^README'
        } |
        Select-Object -ExpandProperty Name
    )

    $ManifestNames = @(
        "package.json",
        "pyproject.toml",
        "requirements.txt",
        "Cargo.toml",
        "go.mod",
        "composer.json",
        "pom.xml",
        "build.gradle",
        "build.gradle.kts",
        "docker-compose.yml",
        "docker-compose.yaml",
        "compose.yml",
        "compose.yaml",
        "Makefile",
        "CMakeLists.txt"
    )

    $Manifests = @(
        Get-ChildItem `
            -LiteralPath $RepoPath `
            -File `
            -Force `
            -ErrorAction SilentlyContinue |
        Where-Object {
            $_.Name -in $ManifestNames
        } |
        Select-Object -ExpandProperty Name
    )

    $LastParts = $Log.Output -split '\|', 4

    $Repositories += [PSCustomObject]@{
        Name              = Split-Path $RepoPath -Leaf
        FullPath          = $RepoPath
        RelativePath      = Get-RelativePathSafe $Workspace $RepoPath
        Branch            = $Branch.Output
        Origin            = $Origin.Output
        Upstream          = $Upstream.Output
        AheadBehind       = $AheadBehind.Output
        HEAD              = $Commit.Output
        WorkingTreeDirty  = $WorkingTreeDirty
        Status            = $Status.Output
        LastCommitHash    = if ($LastParts.Count -ge 1) { $LastParts[0] } else { "" }
        LastCommitDate    = if ($LastParts.Count -ge 2) { $LastParts[1] } else { "" }
        LastCommitAuthor  = if ($LastParts.Count -ge 3) { $LastParts[2] } else { "" }
        LastCommitSubject = if ($LastParts.Count -ge 4) { $LastParts[3] } else { "" }
        SizeBytes         = $Stats.Bytes
        FileCount         = $Stats.Files
        README            = ($Readme -join "; ")
        Manifests         = ($Manifests -join "; ")
    }
}

Write-Host "[3/8] Non-Git project detection..."

$NonGitCandidates = @()

foreach ($Item in $TopLevel | Where-Object { $_.Type -eq "Directory" }) {

    if ($Item.GitRoot) {
        continue
    }

    $Path = $Item.FullName
    $Indicators = @()

    $Checks = @{
        "README.md"          = "README.md"
        "README.txt"         = "README.txt"
        "package.json"       = "package.json"
        "pyproject.toml"     = "pyproject.toml"
        "requirements.txt"   = "requirements.txt"
        "docker-compose.yml" = "docker-compose.yml"
        "docker-compose.yaml" = "docker-compose.yaml"
        "src"                = "src/"
        "scripts"            = "scripts/"
    }

    foreach ($Key in $Checks.Keys) {
        if (Test-Path (Join-Path $Path $Key)) {
            $Indicators += $Checks[$Key]
        }
    }

    $Stats = Get-DirectoryStatistics -Path $Path

    $NonGitCandidates += [PSCustomObject]@{
        Name          = $Item.Name
        FullPath      = $Path
        RelativePath  = Get-RelativePathSafe $Workspace $Path
        FileCount     = $Stats.Files
        SizeBytes     = $Stats.Bytes
        Indicators    = ($Indicators -join "; ")
        LastWriteTime = $Item.LastWriteTime
    }
}

Write-Host "[4/8] STARCORE Android inspection..."

$ProjectFiles = @(
    Get-ChildItem `
        -LiteralPath $ProjectRoot `
        -File `
        -Recurse `
        -Force `
        -ErrorAction SilentlyContinue |
    Where-Object {
        -not (Test-IgnoredPath $_.FullName)
    } |
    Select-Object FullName, Length, LastWriteTime
)

$DefinitionPath = Join-Path `
    $ProjectRoot `
    "STARCORE_ANDROID_PROJECT_DEFINITION.md"

$DefinitionInfo = $null

if (Test-Path -LiteralPath $DefinitionPath) {
    $DefinitionInfo = Get-Item $DefinitionPath |
        Select-Object FullName, Length, LastWriteTime
}

Write-Host "[5/8] Backup / duplicate candidates..."

$BackupCandidates = @(
    $TopLevel |
    Where-Object {
        $_.Name -match '(?i)(backup|bak|old|archive|copy|clone|legacy)' -or
        $_.Name -match '\s+\d+$'
    } |
    Select-Object Name, FullName, Type, LastWriteTime
)

Write-Host "[6/8] STARCORE project Git status..."

$ProjectGit = $null

if (Test-Path -LiteralPath (Join-Path $ProjectRoot ".git")) {

    $ProjectGitBranch = Invoke-GitSafe $ProjectRoot @(
        "branch",
        "--show-current"
    )

    $ProjectGitRemote = Invoke-GitSafe $ProjectRoot @(
        "remote",
        "-v"
    )

    $ProjectGitStatus = Invoke-GitSafe $ProjectRoot @(
        "status",
        "--short",
        "--branch"
    )

    $ProjectGitHead = Invoke-GitSafe $ProjectRoot @(
        "rev-parse",
        "HEAD"
    )

    $ProjectGit = [PSCustomObject]@{
        Branch = $ProjectGitBranch.Output
        Remote = $ProjectGitRemote.Output
        Status = $ProjectGitStatus.Output
        HEAD   = $ProjectGitHead.Output
    }
}

Write-Host "[7/8] Control-file inventory..."

$ControlFiles = @()

$Patterns = @(
    "*.md",
    "*.json",
    "*.yaml",
    "*.yml",
    "*.toml",
    "*.ps1",
    "*.sh",
    "*.py"
)

foreach ($Pattern in $Patterns) {

    Get-ChildItem `
        -LiteralPath $Workspace `
        -File `
        -Recurse `
        -Force `
        -Filter $Pattern `
        -ErrorAction SilentlyContinue |
    Where-Object {
        -not (Test-IgnoredPath $_.FullName) -and
        $_.Length -le 10MB
    } |
    ForEach-Object {

        $ControlFiles += [PSCustomObject]@{
            FullPath     = $_.FullName
            RelativePath = Get-RelativePathSafe $Workspace $_.FullName
            Length       = $_.Length
            LastWriteTime = $_.LastWriteTime
        }
    }
}

Write-Host "[8/8] Writing reports..."

$EndTime = Get-Date

$Summary = [PSCustomObject]@{
    AuditId              = $RunId
    StartTime            = $StartTime.ToString("o")
    EndTime              = $EndTime.ToString("o")
    DurationSeconds      = [math]::Round(($EndTime - $StartTime).TotalSeconds, 2)
    Workspace            = $Workspace
    ProjectRoot          = $ProjectRoot
    GitVersion           = $GitVersion
    TopLevelItems        = $TopLevel.Count
    GitRepositories      = $Repositories.Count
    NonGitCandidates     = $NonGitCandidates.Count
    BackupCandidates     = $BackupCandidates.Count
    ProjectFiles         = $ProjectFiles.Count
    ControlFiles         = $ControlFiles.Count
    HasProjectDefinition = ($null -ne $DefinitionInfo)
}

$Inventory = [PSCustomObject]@{
    Summary          = $Summary
    TopLevel         = $TopLevel
    Repositories     = $Repositories
    NonGitCandidates  = $NonGitCandidates
    BackupCandidates = $BackupCandidates
    ProjectFiles     = $ProjectFiles
    Definition       = $DefinitionInfo
    ProjectGit       = $ProjectGit
    ControlFiles     = $ControlFiles
}

$Inventory |
    ConvertTo-Json -Depth 10 |
    Set-Content -LiteralPath $JsonPath -Encoding UTF8

$Repositories |
    Export-Csv -LiteralPath $CsvPath -NoTypeInformation -Encoding UTF8

$RepoTable = @(
    $Repositories |
    ForEach-Object {
        "| $($_.Name) | $($_.RelativePath) | $($_.Branch) | $($_.Origin) | $($_.WorkingTreeDirty) | $($_.HEAD) | $($_.FileCount) | $($_.SizeBytes) |"
    }
) -join "`n"

$NonGitTable = @(
    $NonGitCandidates |
    ForEach-Object {
        "| $($_.Name) | $($_.RelativePath) | $($_.FileCount) | $($_.SizeBytes) | $($_.Indicators) |"
    }
) -join "`n"

$BackupList = if ($BackupCandidates.Count -eq 0) {
    "No candidates detected."
}
else {
    @(
        $BackupCandidates |
        ForEach-Object {
            "- $($_.Name) — $($_.FullName)"
        }
    ) -join "`n"
}

$Markdown = @"
# STARCORE Android — Local Ecosystem Audit

## Audit

- Audit ID: $RunId
- Start: $($StartTime.ToString("o"))
- End: $($EndTime.ToString("o"))
- Workspace: $Workspace
- Project: $ProjectRoot
- Git: $GitVersion

## Summary

| Metric | Value |
|---|---:|
| Top-level items | $($TopLevel.Count) |
| Git repositories | $($Repositories.Count) |
| Non-Git candidates | $($NonGitCandidates.Count) |
| Backup candidates | $($BackupCandidates.Count) |
| STARCORE project files | $($ProjectFiles.Count) |
| Control files | $($ControlFiles.Count) |
| Project definition present | $($null -ne $DefinitionInfo) |

## Git Repositories

| Name | Relative Path | Branch | Origin | Dirty | HEAD | Files | Size |
|---|---|---|---|---|---|---:|---:|
$RepoTable

## Non-Git Candidates

| Name | Path | Files | Size | Indicators |
|---|---|---:|---:|---|
$NonGitTable

## Backup / Duplicate Candidates

$BackupList

## STARCORE Android Project Definition

$(if ($null -eq $DefinitionInfo) {
    "Project definition not found."
}
else {
    "- Path: $($DefinitionInfo.FullName)`n- Size: $($DefinitionInfo.Length) bytes`n- Last write: $($DefinitionInfo.LastWriteTime)"
})

## Safety

This audit is READ-ONLY.

No repository was:

- pulled
- pushed
- reset
- cleaned
- checked out
- merged
- deleted
- moved
- renamed
- reorganized

## Planned Comparison Phases

The local inventory will later be compared against:

1. GitHub repositories
2. server / Proxmox
3. Android / Termux
4. project documentation
5. historical STARCORE conversations

No repository should be deleted or merged solely from this audit.

"@

$Markdown |
    Set-Content -LiteralPath $MdPath -Encoding UTF8

$Summary |
    Format-List |
    Out-String |
    Set-Content -LiteralPath $TxtPath -Encoding UTF8

Write-Host ""
Write-Host "============================================================" -ForegroundColor Green
Write-Host "LOCAL AUDIT COMPLETE" -ForegroundColor Green
Write-Host "============================================================" -ForegroundColor Green
Write-Host "Audit ID       : $RunId"
Write-Host "Output         : $RunDir"
Write-Host ""
Write-Host "Repositories   : $($Repositories.Count)"
Write-Host "Non-Git        : $($NonGitCandidates.Count)"
Write-Host "Top-level      : $($TopLevel.Count)"
Write-Host "Project files  : $($ProjectFiles.Count)"
Write-Host ""
Write-Host "JSON           : $JsonPath"
Write-Host "CSV            : $CsvPath"
Write-Host "REPORT         : $MdPath"
Write-Host "SUMMARY        : $TxtPath"
Write-Host ""
Write-Host "READ-ONLY AUDIT FINISHED." -ForegroundColor Green
Write-Host "============================================================" -ForegroundColor Green
