# modules/project_audit.ps1
param([string]$Path = "E:\Git")

$projects = Get-ChildItem $Path -Directory
$audit = @()

foreach ($p in $projects) {
    $readme = Test-Path (Join-Path $p.FullName "README.md")
    $license = Test-Path (Join-Path $p.FullName "LICENSE")
    $gitignore = Test-Path (Join-Path $p.FullName ".gitignore")
    $ci = Test-Path (Join-Path $p.FullName ".github/workflows")

    $audit += [pscustomobject]@{
        Name       = $p.Name
        HasREADME  = $readme
        HasLicense = $license
        HasGitignore = $gitignore
        HasCI      = $ci
        NeedsFix   = -not ($readme -and $gitignore)
        Timestamp  = (Get-Date)
    }
}

$audit | ConvertTo-Json -Depth 6 | Set-Content "E:\Git\project_audit.json"
Write-Output "Project audit complete → project_audit.json"
