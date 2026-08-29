Export-ModuleMember -Function Invoke-StarcoreRunTests
function Invoke-StarcoreRunTests {
    [CmdletBinding()]
    param([string]$Root="E:\Git",[switch]$Parallel,[int]$Throttle=4)
    $results=@()
    $projects=Get-ChildItem -Path $Root -Directory -ErrorAction SilentlyContinue
    foreach($projItem in $projects){
        $proj=$projItem.FullName
        $res=[ordered]@{project=$projItem.Name;path=$proj;tests=$null;status="skipped"}
        if(Test-Path "$proj\package.json"){
            try{$out=& npm --prefix $proj test 2>&1;$res.tests=$out -join "`n";$res.status="ok"}catch{$res.status="error";$res.tests=$_.Exception.Message}
        }elseif(Test-Path "$proj\requirements.txt" -or Test-Path "$proj\pyproject.toml"){
            if(Get-Command pytest -ErrorAction SilentlyContinue){
                try{Push-Location $proj;$out=pytest -q 2>&1;Pop-Location;$res.tests=$out -join "`n";$res.status="ok"}catch{Pop-Location;$res.status="error";$res.tests=$_.Exception.Message}
            }else{$res.tests="pytest not installed"}
        }elseif(Test-Path "$proj\go.mod"){
            try{Push-Location $proj;$out=& go test ./... 2>&1;Pop-Location;$res.tests=$out -join "`n";$res.status="ok"}catch{Pop-Location;$res.status="error";$res.tests=$_.Exception.Message}
        }else{$res.tests="No recognized test runner"}
        $results+=$res
    }
    $out=Join-Path $Root "test_results.json"
    $results|ConvertTo-Json -Depth 8|Set-Content $out -Encoding UTF8
    return $out
}
