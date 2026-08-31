Export-ModuleMember -Function Get-StarcoreProjectProfile, Ensure-ProjectDefinition

function Get-StarcoreProjectProfile {
    param([string]$Root = "E:\Git")
    Get-ChildItem $Root -Directory | ForEach-Object {
        $name = $_.Name
        $path = $_.FullName
        $hasGit = Test-Path (Join-Path $path ".git")
        $platform = "mixed"
        if ($name -match "(?i)android|termux") { $platform = "android" }
        elseif ($name -match "(?i)rpi|raspberry|ubuntu|ultraos|linux") { $platform = "linux" }
        elseif ($name -match "(?i)winpe|powershell|vscode|workspace|run_os") { $platform = "windows" }
        $category = "other"
        if ($name -match "(?i)starcore-platform") { $category = "core_platform" }
        elseif ($name -match "(?i)starcore-android") { $category = "core_android" }
        elseif ($name -match "(?i)workspace|vscode|codespace") { $category = "workspace" }
        elseif ($name -match "(?i)supernastroj|starko") { $category = "tools" }
        [PSCustomObject]@{
            name = $name; path = $path; git = $hasGit; platform = $platform; category = $category
        }
    }
}

function Ensure-ProjectDefinition {
    param([string]$ProjectPath)
    $pd = Join-Path $ProjectPath "PROJECT_DEFINITION.md"
    if (-not (Test-Path $pd)) {
        $name = Split-Path $ProjectPath -Leaf
        $templatePath = Join-Path (Split-Path $PSScriptRoot -Parent) "project_definition_template.md"
        if (Test-Path $templatePath) {
            $template = Get-Content $templatePath -Raw
        } else {
            $template = "# $name`n`nKrátký popis projektu."
        }
        $template = $template -replace "{{NAME}}",$name
        $template | Set-Content $pd -Encoding UTF8
        return $true
    }
    return $false
}
