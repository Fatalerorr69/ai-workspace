function Invoke-StarcoreLicenseCheck {
    [CmdletBinding()]
    param([string]$Root = "E:\Git")

    $report = @()
    Get-ChildItem -Path $Root -Directory | ForEach-Object {
        $proj = $_.FullName
        $license = ""
        if (Test-Path (Join-Path $proj "LICENSE")) { $license = Get-Content (Join-Path $proj "LICENSE") -Raw -ErrorAction SilentlyContinue | Select-Object -First 1 }
        $report += [PSCustomObject]@{ project = $_.Name; license = ($license -replace "`r`n"," " ) }
    }
    $out = Join-Path $Root "license_report.json"
    $report | ConvertTo-Json -Depth 6 | Set-Content $out -Encoding UTF8
    return $out
}

function Invoke-StarcoreChangelog {
    [CmdletBinding()]
    param([string]$Root = "E:\Git")

    $changelog = @()
    Get-ChildItem -Path $Root -Directory | ForEach-Object {
        $proj = $_.FullName
        $cl = "No changelog"
        if (Test-Path (Join-Path $proj ".git")) {
            try {
                $out = git -C $proj log --pretty=format:"%h %ad %s" --date=short -n 20 2>$null
                $cl = $out -join "`n"
            } catch { $cl = "git log failed" }
        }
        $changelog += [PSCustomObject]@{ project = $_.Name; changelog = $cl }
    }
    $out = Join-Path $Root "changelogs.json"
    $changelog | ConvertTo-Json -Depth 8 | Set-Content $out -Encoding UTF8
    return $out
}

Export-ModuleMember -Function Invoke-StarcoreLicenseCheck, Invoke-StarcoreChangelog
