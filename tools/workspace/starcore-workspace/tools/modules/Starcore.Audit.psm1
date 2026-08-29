Export-ModuleMember -Function Invoke-ProjectAudit

function Invoke-ProjectAudit {
    param([string]$ProjectPath)
    $report = [ordered]@{
        name = Split-Path $ProjectPath -Leaf
        path = $ProjectPath
        has_git = Test-Path (Join-Path $ProjectPath ".git")
        has_readme = Test-Path (Join-Path $ProjectPath "README.md")
        has_project_definition = Test-Path (Join-Path $ProjectPath "PROJECT_DEFINITION.md")
        has_gitignore = Test-Path (Join-Path $ProjectPath ".gitignore")
        has_ci = Test-Path (Join-Path $ProjectPath ".github\workflows")
        uncommitted = $false
        branch = $null
    }
    if ($report.has_git) {
        try {
            $status = git -C $ProjectPath status --porcelain 2>$null
            if ($status) { $report.uncommitted = $true }
            $report.branch = (git -C $ProjectPath rev-parse --abbrev-ref HEAD 2>$null)
        } catch { }
    }
    return $report
}
