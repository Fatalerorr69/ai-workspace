function Analyze-StarcoreRepository {
    [CmdletBinding()]
    param(
        [string]$ProjectPath
    )

    $files = Get-ChildItem -Path $ProjectPath -Recurse -File -ErrorAction SilentlyContinue

    $report = [ordered]@{
        name            = Split-Path $ProjectPath -Leaf
        path            = $ProjectPath
        file_count      = $files.Count
        largest_files   = $files | Sort-Object Length -Descending | Select-Object -First 10
        file_types      = $files | Group-Object Extension | Sort-Object Count -Descending
        has_readme      = Test-Path (Join-Path $ProjectPath "README.md")
        has_definition  = Test-Path (Join-Path $ProjectPath "PROJECT_DEFINITION.md")
        has_gitignore   = Test-Path (Join-Path $ProjectPath ".gitignore")
        has_ci          = Test-Path (Join-Path $ProjectPath ".github\workflows")
    }

    return [PSCustomObject]$report
}

Export-ModuleMember -Function Analyze-StarcoreRepository
