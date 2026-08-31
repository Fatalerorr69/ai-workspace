# starko_dashboard_server.ps1
Add-Type -AssemblyName System.Net.HttpListener

$listener = New-Object System.Net.HttpListener
$listener.Prefixes.Add("http://localhost:8080/run/")
$listener.Start()
Write-Host "Dashboard server spuštěn na http://localhost:8080/run/"

while ($true) {
    $ctx = $listener.GetContext()
    $req = $ctx.Request
    $resp = $ctx.Response

    $query = [System.Web.HttpUtility]::ParseQueryString($req.Url.Query)
    $cmd = $query["cmd"]

    if ($cmd) {
        Write-Host "[EXEC] $cmd"
        $output = Invoke-Expression $cmd 2>&1 | Out-String
        $buffer = [System.Text.Encoding]::UTF8.GetBytes($output)
        $resp.ContentLength64 = $buffer.Length
        $resp.OutputStream.Write($buffer,0,$buffer.Length)
    }
    $resp.OutputStream.Close()
}
