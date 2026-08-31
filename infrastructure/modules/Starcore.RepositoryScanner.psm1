function Scan-StarcoreRepositories {
    [CmdletBinding()]
    param(
        [string]$Root = "E:\Git"
    )

    $projects = @()

    Get-ChildItem -Path $Root -Directory | ForEach-Object {
        $name = $_.Name
        $path = $_.FullName

        # OS detection
        $os = "unknown"
        if ($name -match "(?i)android|termux") { $os = "android" }
        elseif ($name -match "(?i)linux|ubuntu|rpi|raspberry|ultraos") { $os = "linux" }
        elseif ($name -match "(?i)win|powershell|vscode|workspace") { $os = "windows" }

        # Category detection
        $category = "other"
        if ($name -match "(?i)starcore-platform") { $category = "core_platform" }
        elseif ($name -match "(?i)starcore-android") { $category = "core_android" }
        elseif ($name -match "(?i)supernastroj|starko") { $category = "tools" }
        elseif ($name -match "(?i)workspace|vscode|codespace") { $category = "workspace" }

        # Git detection
        $hasGit = Test-Path (Join-Path $path ".git")

        $projects += [PSCustomObject]@{
            name     = $name
            path     = $path
            os       = $os
            category = $category
            git      = $hasGit
        }
    }

    return $projects
}

Export-ModuleMember -Function Scan-StarcoreRepositories
