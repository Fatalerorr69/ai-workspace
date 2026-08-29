Export-ModuleMember -Function Invoke-StarcoreProjectOrganize
function Invoke-StarcoreProjectOrganize {
    param([string]$Root="E:\Git",[switch]$DryRun)
    $rules=@(
        @{ext=".md";folder="docs"},
        @{ext=".ps1";folder="scripts"},
        @{ext=".py";folder="src"},
        @{ext=".json";folder="config"}
    )
    $map=@()
    $projects=Get-ChildItem -Path $Root -Directory
    foreach($projItem in $projects){
        $proj=$projItem.FullName
        Get-ChildItem -Path $proj -Recurse -File | ForEach-Object {
            $ext=$_.Extension.ToLower()
            $rule=$rules|Where-Object{$_.ext -eq $ext}|Select-Object -First 1
            if($rule){
                $targetDir=Join-Path (Split-Path $_.FullName -Parent) $rule.folder
                $targetPath=Join-Path $targetDir $_.Name
                $map+=@{file=$_.FullName;target=$targetPath}
            }
        }
    }
    $renameMap=Join-Path $Root ("organize_map_{0}.json" -f (Get-Date -Format "yyyyMMdd_HHmmss"))
    $actions=@()
    foreach($m in $map){
        if($DryRun){
            $actions+=@{action="move";from=$m.file;to=$m.target;status="dry-run"}
        }else{
            $dir=Split-Path $m.target -Parent
            if(-not(Test-Path $dir)){New-Item -ItemType Directory -Path $dir -Force|Out-Null}
            Move-Item $m.file $m.target -Force
            $actions+=@{action="move";from=$m.file;to=$m.target;status="ok"}
        }
    }
    $actions|ConvertTo-Json -Depth 6|Set-Content $renameMap -Encoding UTF8
    return @{map=$renameMap;actions=$actions.Count}
}
