function New-StarcoreDashboard {
    [CmdletBinding()]
    param(
        [array]$Projects,
        [string]$Root = "E:\Git"
    )

    $dashboard = Join-Path $Root "starcore_dashboard.html"

    $html = @"
<html>
<head>
<title>Starcore Dashboard</title>
<style>
body { font-family: Arial; background:#111; color:#eee; }
table { width:100%; border-collapse: collapse; }
td, th { border:1px solid #444; padding:8px; }
th { background:#222; }
</style>
</head>
<body>
<h1>Starcore Project Dashboard</h1>
<table>
<tr><th>Name</th><th>Path</th><th>OS</th><th>Category</th><th>Git</th></tr>
"@

    foreach ($p in $Projects) {
        $html += "<tr><td>$($p.name)</td><td>$($p.path)</td><td>$($p.os)</td><td>$($p.category)</td><td>$($p.git)</td></tr>"
    }

    $html += "</table></body></html>"

    $html | Set-Content $dashboard -Encoding UTF8

    return $dashboard
}

Export-ModuleMember -Function New-StarcoreDashboard
