param(
    [Parameter(Mandatory=$true)][int]$Wave,
    [Parameter(Mandatory=$true)][string]$MonorepoUrl,
    [switch]$TestMode,
    [string]$LogFile = "migration.log",
    [string]$StateFile = "migration_state.csv",
    [switch]$Resume
)

$planFile = Join-Path $PSScriptRoot "reorganize_plan.csv"
if (-not (Test-Path $planFile)) { throw "Chybí $planFile" }

$plan = Import-Csv $planFile
$reposToMigrate = $plan | Where-Object { $_.migration_wave -eq $Wave -and $_.action -eq "migrate" }

$doneRepos = @()
if ($Resume -and (Test-Path $StateFile)) {
    $state = Import-Csv $StateFile
    $doneRepos = $state | Where-Object { $_.wave -eq $Wave -and $_.status -eq "migrated" } | Select-Object -ExpandProperty repo_name
    Write-Host "Resume: přeskočím $($doneRepos.Count) již hotových repozitářů." -ForegroundColor DarkCyan
}

Write-Host "Vlna $Wave – počet repozitářů k migraci: $($reposToMigrate.Count)" -ForegroundColor Magenta
Add-Content -Path $LogFile -Value "===== VLNA $Wave - MIGRACE ====="

$index = 0
foreach ($item in $reposToMigrate) {
    $index++
    if ($doneRepos -contains $item.repo_name) {
        Write-Host "[$index/$($reposToMigrate.Count)] PŘESKOČENO $($item.repo_name)" -ForegroundColor Gray
        continue
    }
    Write-Host "`n[$index/$($reposToMigrate.Count)] Zpracovávám $($item.repo_name)" -ForegroundColor Yellow
    & "$PSScriptRoot\migrate_repo.ps1" -RepoName $item.repo_name -TargetPath $item.target_path -MonorepoUrl $MonorepoUrl -TestMode:$TestMode -LogFile $LogFile -StateFile $StateFile -Wave $Wave
    if ($LASTEXITCODE -ne 0) {
        Write-Warning "Migrace $($item.repo_name) skončila s chybou, pokračuji další."
    }
}

Write-Host "`nVlna $Wave – migrace dokončena." -ForegroundColor Green
