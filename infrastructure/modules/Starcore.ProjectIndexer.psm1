Export-ModuleMember -Function Invoke-StarcoreProjectIndex
function Invoke-StarcoreProjectIndex {
    param([string]$Root="E:\Git")
    $index=@()
    $projects=Get-ChildItem -Path $Root -Directory
    foreach($p in $projects){
        $proj=$p.FullName
        $files=Get-ChildItem -Path $proj -Recurse -File
        $totalBytes=($files|Measure-Object Length -Sum).Sum
        $topExt=$files|Group-Object Extension|Sort-Object Count -Descending|Select-Object -First 10|ForEach-Object{"$($_.Name):$($_.Count)"}
        $index+=[ordered]@{
            name=$p.Name
            path=$proj
            file_count=$files.Count
            total_bytes=$totalBytes
            top_extensions=($topExt -join ";")
        }
    }
    $out=Join-Path $Root "project_index.json"
    $index|ConvertTo-Json -Depth 8|Set-Content $out -Encoding UTF8
    return $out
}
