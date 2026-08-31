function Invoke-StarcoreCloudBackup {
    [CmdletBinding()]
    param(
        [string]$ProjectPath,
        [string]$Root = "E:\Git",
        [switch]$UseGitHubGist
    )

    $backupDir = Join-Path $Root "backups"
    New-Item -Path $backupDir -ItemType Directory -Force | Out-Null

    $name = Split-Path $ProjectPath -Leaf
    $timestamp = (Get-Date).ToString("yyyyMMdd_HHmmss")
    $archive = Join-Path $backupDir ("{0}_{1}.tar.gz" -f $name, $timestamp)

    try {
        if (Get-Command tar -ErrorAction SilentlyContinue) {
            & tar -czf $archive -C (Split-Path $ProjectPath) $name
        } else {
            $zip = $archive -replace '\.tar\.gz$','.zip'
            Compress-Archive -Path (Join-Path $ProjectPath '*') -DestinationPath $zip -Force
            $archive = $zip
        }
    } catch {
        # bezpečné formátování bez vnořených subexpressions v řetězci
        Write-Warning ("Backup failed for {0}: {1}" -f $name, $_.Exception.Message)
        return $null
    }

    $result = @{ project = $name; archive = $archive; timestamp = $timestamp }

    if ($UseGitHubGist -and $env:GITHUB_TOKEN) {
        try {
            $desc = "Starcore backup metadata for $name at $timestamp"
            $filesObj = @{ ("meta_$name.json") = @{ content = (ConvertTo-Json $result -Depth 6) } }
            $body = @{ description = $desc; public = $false; files = $filesObj } | ConvertTo-Json -Depth 6
            $resp = Invoke-RestMethod -Uri "https://api.github.com/gists" -Method Post -Headers @{ Authorization = "token $env:GITHUB_TOKEN"; "User-Agent" = "Starcore" } -Body $body
            if ($resp -and $resp.html_url) { $result.gist = $resp.html_url }
        } catch {
            Write-Warning ("Gist upload failed for {0}: {1}" -f $name, $_.Exception.Message)
        }
    }

    return $result
}

function Invoke-StarcoreCloudSyncAll {
    [CmdletBinding()]
    param(
        [array]$Projects,
        [string]$Root = "E:\Git",
        [switch]$UseGitHubGist
    )

    $backups = @()
    foreach ($p in $Projects) {
        try {
            $res = Invoke-StarcoreCloudBackup -ProjectPath $p.path -Root $Root -UseGitHubGist:$UseGitHubGist
            if ($res) { $backups += $res }
        } catch {
            Write-Warning ("Cloud backup failed for {0}: {1}" -f $p.name, $_.Exception.Message)
        }
    }
    $out = Join-Path $Root "cloud_backups.json"
    $backups | ConvertTo-Json -Depth 6 | Set-Content $out -Encoding UTF8
    return $out
}

Export-ModuleMember -Function Invoke-StarcoreCloudBackup, Invoke-StarcoreCloudSyncAll
