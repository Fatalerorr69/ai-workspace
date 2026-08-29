function Invoke-StarcoreAIAnalyzer {
    [CmdletBinding()]
    param(
        [string]$ProjectPath
    )

    $score = 0
    $notes = @()

    if (Test-Path (Join-Path $ProjectPath "README.md")) {
        $score += 10
        $notes += "README present"
    } else {
        $notes += "Missing README"
    }

    if (Test-Path (Join-Path $ProjectPath "PROJECT_DEFINITION.md")) {
        $score += 10
        $notes += "Definition present"
    } else {
        $notes += "Missing definition"
    }

    if (Test-Path (Join-Path $ProjectPath ".gitignore")) {
        $score += 5
        $notes += "Gitignore present"
    }

    $files = Get-ChildItem -Path $ProjectPath -Recurse -File -ErrorAction SilentlyContinue
    if ($files.Count -gt 200) {
        $score += 5
        $notes += "Large project"
    }

    return [PSCustomObject]@{
        project = Split-Path $ProjectPath -Leaf
        score   = $score
        notes   = $notes
    }
}

Export-ModuleMember -Function Invoke-StarcoreAIAnalyzer
