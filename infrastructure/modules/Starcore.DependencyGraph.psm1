function New-StarcoreDependencyGraph {
    [CmdletBinding()]
    param(
        [array]$Projects,
        [string]$Root = "E:\Git"
    )

    $graphFile = Join-Path $Root "starcore_dependency_graph.json"
    $edges = @()

    foreach ($p in $Projects) {
        $projName = $p.name
        $projPath = $p.path

        $files = Get-ChildItem -Path $projPath -Recurse -File -ErrorAction SilentlyContinue

        foreach ($f in $files) {
            $content = Get-Content $f.FullName -ErrorAction SilentlyContinue

            foreach ($other in $Projects) {
                if ($other.name -ne $projName) {
                    if ($content -match $other.name) {
                        $edges += [PSCustomObject]@{
                            from = $projName
                            to   = $other.name
                            file = $f.FullName
                        }
                    }
                }
            }
        }
    }

    $edges | ConvertTo-Json -Depth 64 | Set-Content $graphFile -Encoding UTF8
    return $graphFile
}

Export-ModuleMember -Function New-StarcoreDependencyGraph
