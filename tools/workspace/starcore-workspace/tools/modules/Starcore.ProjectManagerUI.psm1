function New-StarcoreProjectManagerUI {
    [CmdletBinding()]
    param([string]$Root = "E:\Git")

    $indexFile = Join-Path $Root "project_index.json"
    if (-not (Test-Path $indexFile)) { return $null }
    $projects = Get-Content $indexFile -Raw | ConvertFrom-Json

    $html = "<html><head><meta charset='utf-8'><title>Starcore Manager</title></head><body><h1>Projects</h1><table border='1'><tr><th>Name</th><th>Files</th><th>Size</th><th>Top Ext</th></tr>"
    foreach ($p in $projects) {
        $html += "<tr><td>$($p.name)</td><td>$($p.file_count)</td><td>$([math]::Round($p.total_bytes/1MB,2)) MB</td><td>$($p.top_extensions)</td></tr>"
    }
    $html += "</table></body></html>"

    $out = Join-Path $Root "project_manager.html"
    $html | Set-Content $out -Encoding UTF8
    return $out
}

Export-ModuleMember -Function New-StarcoreProjectManagerUI
