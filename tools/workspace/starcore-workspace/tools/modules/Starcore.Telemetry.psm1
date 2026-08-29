function Invoke-StarcoreTelemetryCollect {
    [CmdletBinding()]
    param(
        [string]$ProjectPath,
        [string]$Root = "E:\Git"
    )

    $telemetryDir = Join-Path $Root "telemetry"
    New-Item -Path $telemetryDir -ItemType Directory -Force | Out-Null

    $projectName = Split-Path $ProjectPath -Leaf
    $timestamp = (Get-Date).ToString("yyyyMMdd_HHmmss")
    $outFile = Join-Path $telemetryDir ("telemetry_{0}_{1}.json" -f $projectName, $timestamp)

    $files = Get-ChildItem -Path $ProjectPath -Recurse -File -ErrorAction SilentlyContinue
    $sizeBytes = ($files | Measure-Object Length -Sum).Sum
    $fileCount = $files.Count
    $gitInfo = $null
    if (Test-Path (Join-Path $ProjectPath ".git")) {
        try {
            $branch = git -C $ProjectPath rev-parse --abbrev-ref HEAD 2>$null
            $commit = git -C $ProjectPath rev-parse --short HEAD 2>$null
            $gitInfo = @{ branch = $branch; commit = $commit }
        } catch { $gitInfo = $null }
    }

    $metrics = [ordered]@{
        project     = $projectName
        path        = $ProjectPath
        timestamp   = (Get-Date).ToString("o")
        file_count  = $fileCount
        total_bytes = $sizeBytes
        git         = $gitInfo
        platform    = (if ($ProjectPath -match "(?i)android|termux") {'android'} elseif ($ProjectPath -match "(?i)linux|rpi|ubuntu|ultraos") {'linux'} elseif ($ProjectPath -match "(?i)win|powershell|vscode|workspace") {'windows'} else {'unknown'})
    }

    $metrics | ConvertTo-Json -Depth 8 | Set-Content $outFile -Encoding UTF8

    return $outFile
}

function Invoke-StarcoreTelemetryAggregate {
    [CmdletBinding()]
    param(
        [string]$Root = "E:\Git"
    )

    $telemetryDir = Join-Path $Root "telemetry"
    New-Item -Path $telemetryDir -ItemType Directory -Force | Out-Null

    $files = Get-ChildItem -Path $telemetryDir -Filter "telemetry_*.json" -File -ErrorAction SilentlyContinue
    $all = @()
    foreach ($f in $files) {
        try {
            $all += (Get-Content $f.FullName -Raw | ConvertFrom-Json)
        } catch { }
    }
    $aggFile = Join-Path $telemetryDir "telemetry_aggregate.json"
    $all | ConvertTo-Json -Depth 8 | Set-Content $aggFile -Encoding UTF8
    return $aggFile
}

Export-ModuleMember -Function Invoke-StarcoreTelemetryCollect, Invoke-StarcoreTelemetryAggregate
