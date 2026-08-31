# modules/project_analyzer.ps1
param([string]$Path = "E:\Git")

$projects = Get-ChildItem $Path -Directory
$analysis = @()

foreach ($p in $projects) {
    $git = Test-Path (Join-Path $p.FullName ".git")
    $files = Get-ChildItem $p.FullName -Recurse -File -ErrorAction SilentlyContinue
    $languages = $files | Group-Object { $_.Extension.ToLower() } | Sort-Object Count -Descending

    $analysis += [pscustomobject]@{
        Name       = $p.Name
        Path       = $p.FullName
        GitRepo    = $git
        FileCount  = $files.Count
        SizeMB     = [math]::Round(($files | Measure-Object Length -Sum).Sum / 1MB, 2)
        Languages  = $languages | Select-Object Name,Count
        Timestamp  = (Get-Date)
    }
}

$analysis | ConvertTo-Json -Depth 6 | Set-Content "E:\Git\project_analysis.json"
Write-Output "Project analysis complete → project_analysis.json"
