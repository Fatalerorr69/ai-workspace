function New-StarcoreWorkspaceVisualizer {
    [CmdletBinding()]
    param(
        [array]$Projects,
        [string]$Root = "E:\Git"
    )

    $outHtml = Join-Path $Root "starcore_workspace_map.html"

    $nodes = @()
    $links = @()
    $i = 0
    foreach ($p in $Projects) {
        $nodes += [PSCustomObject]@{ id = $i; name = $p.name; path = $p.path; category = $p.category; os = $p.os }
        $i++
    }

    # try to load dependency graph if exists
    $graphFile = Join-Path $Root "starcore_dependency_graph.json"
    if (Test-Path $graphFile) {
        $edges = Get-Content $graphFile -Raw | ConvertFrom-Json
        foreach ($e in $edges) {
            $from = ($nodes | Where-Object { $_.name -eq $e.from }).id
            $to   = ($nodes | Where-Object { $_.name -eq $e.to }).id
            if ($from -ne $null -and $to -ne $null) {
                $links += [PSCustomObject]@{ source = $from; target = $to; file = $e.file }
            }
        }
    }

    $nodesJson = $nodes | ConvertTo-Json -Depth 6
    $linksJson = $links | ConvertTo-Json -Depth 6

    $html = @"
<!doctype html>
<html>
<head>
<meta charset='utf-8'>
<title>Starcore Workspace Map</title>
<script src='https://d3js.org/d3.v7.min.js'></script>
<style>
body { font-family: Arial, sans-serif; background:#111; color:#eee; }
.node { stroke: #fff; stroke-width: 1px; }
.link { stroke: #888; stroke-opacity: 0.6; }
.tooltip { position: absolute; background:#222; color:#fff; padding:6px; border-radius:4px; display:none; }
</style>
</head>
<body>
<h1>Starcore Workspace Map</h1>
<div id='chart'></div>
<script>
const nodes = $nodesJson;
const links = $linksJson;

const width = Math.max(900, window.innerWidth - 40);
const height = Math.max(600, window.innerHeight - 200);

const svg = d3.select("#chart").append("svg").attr("width", width).attr("height", height);

const simulation = d3.forceSimulation(nodes)
    .force("link", d3.forceLink(links).id(d => d.id).distance(120))
    .force("charge", d3.forceManyBody().strength(-400))
    .force("center", d3.forceCenter(width/2, height/2));

const link = svg.append("g").selectAll("line").data(links).enter().append("line").attr("class","link");

const node = svg.append("g").selectAll("circle").data(nodes).enter().append("circle")
    .attr("r", 12)
    .attr("fill", d => d.category === "core_platform" ? "#ff8c00" : d.category === "core_android" ? "#1e90ff" : "#7cfc00")
    .call(d3.drag().on("start", dragstarted).on("drag", dragged).on("end", dragended));

const label = svg.append("g").selectAll("text").data(nodes).enter().append("text")
    .text(d => d.name).attr("font-size", 10).attr("dx", 14).attr("dy", 4);

simulation.on("tick", () => {
    link.attr("x1", d => d.source.x).attr("y1", d => d.source.y).attr("x2", d => d.target.x).attr("y2", d => d.target.y);
    node.attr("cx", d => d.x).attr("cy", d => d.y);
    label.attr("x", d => d.x).attr("y", d => d.y);
});

function dragstarted(event,d){ if (!event.active) simulation.alphaTarget(0.3).restart(); d.fx = d.x; d.fy = d.y; }
function dragged(event,d){ d.fx = event.x; d.fy = event.y; }
function dragended(event,d){ if (!event.active) simulation.alphaTarget(0); d.fx = null; d.fy = null; }

node.on("dblclick", (event,d) => {
    window.open("file:///" + d.path.replace(/\\/g, "/"), "_blank");
});
</script>
</body>
</html>
"@

    $html | Set-Content $outHtml -Encoding UTF8
    return $outHtml
}

Export-ModuleMember -Function New-StarcoreWorkspaceVisualizer
