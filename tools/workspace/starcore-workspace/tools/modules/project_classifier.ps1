# modules/project_classifier.ps1
param([string]$Path = "E:\Git")

$catalog = @()

function Classify($name) {
    if ($name -match "STARCORE-ANDROID") { return "CORE/ANDROID" }
    if ($name -match "starcore-platform") { return "CORE/PLATFORM" }
    if ($name -match "RPI|Raspberry|Ubuntu|UltraOS|recalbox") { return "LINUX/OS" }
    if ($name -match "SuperNastroj|WINPE|Run_OS|Powershell") { return "WINDOWS/TOOLS" }
    if ($name -match "VScode|Workspace|codespace") { return "WORKSPACE" }
    return "OTHER"
}

foreach ($p in Get-ChildItem $Path -Directory) {
    $catalog += [pscustomobject]@{
        Name       = $p.Name
        Category   = Classify($p.Name)
        Path       = $p.FullName
        Timestamp  = (Get-Date)
    }
}

$catalog | ConvertTo-Json -Depth 6 | Set-Content "E:\Git\project_catalog.json"
Write-Output "Project classification complete → project_catalog.json"
