Export-ModuleMember -Function Invoke-StarcoreVulnScan
function Invoke-StarcoreVulnScan {
    param([string]$Root="E:\Git")
    $reports=@()
    $projects=Get-ChildItem -Path $Root -Directory
    foreach($projItem in $projects){
        $proj=$projItem.FullName
        $rep=[ordered]@{project=$projItem.Name;path=$proj;scans=@()}
        if(Test-Path "$proj\package.json"){
            try{$out=npm --prefix $proj audit --json 2>&1;$rep.scans+=@{tool="npm audit";result=$out}}catch{$rep.scans+=@{tool="npm audit";result="error"}}
        }
        if(Test-Path "$proj\requirements.txt" -and (Get-Command pip-audit -ErrorAction SilentlyContinue)){
            try{Push-Location $proj;$out=pip-audit --format json 2>&1;Pop-Location;$rep.scans+=@{tool="pip-audit";result=$out}}catch{$rep.scans+=@{tool="pip-audit";result="error"}}
        }
        $reports+=$rep
    }
    $out=Join-Path $Root "vuln_scan.json"
    $reports|ConvertTo-Json -Depth 8|Set-Content $out -Encoding UTF8
    return $out
}
