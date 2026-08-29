function Invoke-StarcoreDuplicateFind {
    [CmdletBinding()]
    param([string]$Root = "E:\Git", [int]$MinSizeKB = 1)

    $hashes = @{}
    $dups = @()
    Get-ChildItem -Path $Root -Recurse -File -ErrorAction SilentlyContinue | Where-Object { $_.Length -gt ($MinSizeKB*1024) } | ForEach-Object {
        try {
            $h = (Get-FileHash -Path $_.FullName -Algorithm SHA256).Hash
            if ($hashes.ContainsKey($h)) { $dups += [PSCustomObject]@{ file = $_.FullName; duplicateOf = $hashes[$h] } }
            else { $hashes[$h] = $_.FullName }
        } catch {}
    }
    $out = Join-Path $Root "duplicates.json"
    $dups | ConvertTo-Json -Depth 6 | Set-Content $out -Encoding UTF8
    return $out
}

function Invoke-StarcoreLargeFiles {
    [CmdletBinding()]
    param([string]$Root = "E:\Git", [int]$ThresholdMB = 50)

    $large = Get-ChildItem -Path $Root -Recurse -File -ErrorAction SilentlyContinue | Where-Object { $_.Length -gt ($ThresholdMB*1MB) } | Select-Object FullName, Length
    $out = Join-Path $Root "large_files.json"
    $large | ConvertTo-Json -Depth 4 | Set-Content $out -Encoding UTF8
    return $out
}

Export-ModuleMember -Function Invoke-StarcoreDuplicateFind, Invoke-StarcoreLargeFiles
