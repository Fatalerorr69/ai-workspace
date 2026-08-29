function Generate-StarcoreManifest {
    [CmdletBinding()]
    param(
        [array]$Projects,
        [string]$Root = "E:\Git"
    )

    $manifestPath = Join-Path $Root "starcore_manifest.yaml"

    $yaml = @("projects:")

    foreach ($p in $Projects) {
        $yaml += "  - name: $($p.name)"
        $yaml += "    path: $($p.path)"
        $yaml += "    os: $($p.os)"
        $yaml += "    category: $($p.category)"
        $yaml += "    git: $($p.git)"
    }

    $yaml | Set-Content $manifestPath -Encoding UTF8
    return $manifestPath
}

Export-ModuleMember -Function Generate-StarcoreManifest
