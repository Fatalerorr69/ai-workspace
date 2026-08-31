$ErrorActionPreference = "Stop"
$monorepo = Join-Path $env:TEMP "migrate_v2\monorepo"
Set-Location $monorepo
New-Item -ItemType Directory -Path library -Force | Out-Null
$projects = Get-ChildItem -Directory | Where-Object { $_.Name -notin @('.git','.github','archive','ai-workspace','docs','reports','library','templates') }
$registry = @()
foreach ($p in $projects) {
    Get-ChildItem $p.FullName -Include *.ps1,*.sh,*.py,*.js,*.ts -Recurse -File | ForEach-Object {
        $dest = "library/$($p.Name)_$($_.Name)"
        Copy-Item $_.FullName $dest -Force
        $registry += [PSCustomObject]@{ Project=$p.Name; Script=$_.Name; LibraryPath=$dest }
    }
}
$registry | Export-Csv library/library_index.csv -NoTypeInformation
Write-Host "Knihovna hotova" -ForegroundColor Green
