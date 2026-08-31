function Configure-StarcoreRepository {
    [CmdletBinding()]
    param(
        [string]$ProjectPath
    )

    $name = Split-Path $ProjectPath -Leaf

    # README
    $readme = Join-Path $ProjectPath "README.md"
    if (-not (Test-Path $readme)) {
        "# $name`n`nProjekt je součástí Starcore ekosystému." | Set-Content $readme -Encoding UTF8
    }

    # PROJECT_DEFINITION
    $def = Join-Path $ProjectPath "PROJECT_DEFINITION.md"
    if (-not (Test-Path $def)) {
        "# Definice projektu: $name`n`nPopis, účel, funkce." | Set-Content $def -Encoding UTF8
    }

    # .gitignore
    $gi = Join-Path $ProjectPath ".gitignore"
    if (-not (Test-Path $gi)) {
        "*.log`n*.tmp`n*.cache`n*.venv`n" | Set-Content $gi -Encoding UTF8
    }

    return $true
}

Export-ModuleMember -Function Configure-StarcoreRepository
