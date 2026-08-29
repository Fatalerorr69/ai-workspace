Export-ModuleMember -Function Invoke-StarcoreStaticAnalysis
function Invoke-StarcoreStaticAnalysis {
    param([string]$Root="E:\Git")
    $reports=@()
    $projects=Get-ChildItem -Path $Root -Directory
    foreach($projItem in $projects){
        $proj=$projItem.FullName
        $rep=[ordered]@{project=$projItem.Name;path=$proj;linters=@()}
        if(Test-Path "$proj\package.json" -and (Get-Command eslint -ErrorAction SilentlyContinue)){
            try{Push-Location $proj;$out=eslint . -f json 2>&1;Pop-Location;$rep.linters+=@{tool="eslint";result=$out}}catch{$rep.linters+=@{tool="eslint";result="error"}}
        }
        if((Test-Path "$proj\requirements.txt" -or Test-Path "$proj\pyproject.toml") -and (Get-Command flake8 -ErrorAction SilentlyContinue)){
            try{Push-Location $proj;$out=flake8 . 2>&1;Pop-Location;$rep.linters+=@{tool="flake8";result=$out}}catch{$rep.linters+=@{tool="flake8";result="error"}}
        }
        $reports+=$rep
    }
    $out=Join-Path $Root "static_analysis.json"
    $reports|ConvertTo-Json -Depth 8|Set-Content $out -Encoding UTF8
    return $out
}
