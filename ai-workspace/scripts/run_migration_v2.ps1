$ErrorActionPreference = "Stop"

# Parametry
$MonorepoUrl = "https://github.com/Fatalerorr69/ai-workspace.git"
$Owner = "Fatalerorr69"
$StateFile = Join-Path $PSScriptRoot "migration_state_v2.csv"
$LogFile = Join-Path $PSScriptRoot "migration_v2.log"
$TempRoot = Join-Path $env:TEMP "migrate_v2"

# Kontrola tokenu
if (-not $env:GITHUB_TOKEN) { throw "GITHUB_TOKEN není nastaven" }
$headers = @{
    Authorization = "Bearer $env:GITHUB_TOKEN"
    "User-Agent"  = "PowerShell"
    Accept        = "application/vnd.github+json"
}

function Log($msg) {
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    $logMsg = "[$timestamp] $msg"
    Write-Host $logMsg -ForegroundColor Cyan
    Add-Content -Path $LogFile -Value $logMsg
}

function Update-State($repo, $target, $wave, $status) {
    $line = [PSCustomObject]@{
        repo_name   = $repo
        target_path = $target
        wave        = $wave
        status      = $status
        timestamp   = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    }
    $line | Export-Csv -Path $StateFile -Append -NoTypeInformation
}

# ---------- 1. Připravit monorepo ----------
Log "Připravuji monorepo..."
$repoName = ($MonorepoUrl -split '/' | Select-Object -Last 1) -replace '\.git$',''

# Smazat existující monorepo
try {
    $existing = Invoke-RestMethod -Uri "https://api.github.com/repos/$Owner/$repoName" -Headers $headers -ErrorAction Stop
    Log "Mažu existující monorepo $Owner/$repoName..."
    Invoke-RestMethod -Uri "https://api.github.com/repos/$Owner/$repoName" -Method Delete -Headers $headers | Out-Null
    Start-Sleep -Seconds 2
} catch {
    Log "Monorepo neexistuje, pokračuji."
}

# Vytvořit nové monorepo (bez auto_init, aby bylo prázdné)
$body = @{ name = $repoName; private = $false; auto_init = $false } | ConvertTo-Json
Invoke-RestMethod -Uri "https://api.github.com/user/repos" -Method Post -Headers $headers -Body $body -ContentType "application/json" | Out-Null
Start-Sleep -Seconds 3
Log "Monorepo $Owner/$repoName vytvořeno."

# Klonovat prázdné monorepo
$monoDir = Join-Path $TempRoot "monorepo"
if (Test-Path $monoDir) { Remove-Item $monoDir -Recurse -Force }
New-Item -ItemType Directory -Path $monoDir -Force | Out-Null
git clone $MonorepoUrl $monoDir
Set-Location $monoDir

# Vytvořit úvodní commit (prázdný)
New-Item -ItemType File -Path .gitkeep -Force | Out-Null
git add .gitkeep
git commit -m "Initial empty commit"
git push origin main
Log "Monorepo inicializováno."

# ---------- 2. Načíst plán ----------
$planFile = Join-Path $PSScriptRoot "reorganize_plan.csv"
if (-not (Test-Path $planFile)) { throw "Chybí $planFile" }
$plan = Import-Csv $planFile

# ---------- 3. Migrace po vlnách ----------
$waves = @(1,2,3)
foreach ($wave in $waves) {
    Log "`n===== VLNA $wave ====="
    $repos = $plan | Where-Object { $_.migration_wave -eq $wave -and $_.action -eq "migrate" }
    Log "Počet repozitářů k migraci: $($repos.Count)"

    foreach ($item in $repos) {
        $repoName = $item.repo_name
        $targetPath = $item.target_path
        $sourceUrl = "https://github.com/$Owner/$repoName.git"
        $workDir = Join-Path $TempRoot "repo_$repoName"

        Log "Migrace $repoName -> $targetPath"

        # Přeskočit, pokud už hotovo
        if (Test-Path $StateFile) {
            $state = Import-Csv $StateFile
            if ($state | Where-Object { $_.repo_name -eq $repoName -and $_.status -eq "migrated" }) {
                Log "  Přeskočeno (již hotovo)."
                continue
            }
        }

        # Vyčistit pracovní adresář
        if (Test-Path $workDir) { Remove-Item $workDir -Recurse -Force }
        New-Item -ItemType Directory -Path $workDir | Out-Null

        # Naklonovat zdrojový repozitář (ne mirror)
        Log "  Klonuji $sourceUrl ..."
        git clone $sourceUrl $workDir
        if ($LASTEXITCODE -ne 0) {
            Update-State $repoName $targetPath $wave "clone_failed"
            Log "  CHYBA: Klon selhal, pokračuji."
            continue
        }

        # Vytvořit cílový adresář v monorepu
        $destDir = Join-Path $monoDir $targetPath
        New-Item -ItemType Directory -Path $destDir -Force | Out-Null

        # Zkopírovat obsah (kromě .git) do cílového adresáře
        Log "  Kopíruji soubory do $targetPath ..."
        Get-ChildItem -Path $workDir -Force | Where-Object { $_.Name -ne '.git' } | Copy-Item -Destination $destDir -Recurse -Force

        # Commit v monorepu
        Set-Location $monoDir
        git add $targetPath
        $commitMsg = "Import $repoName -> $targetPath"
        git commit -m $commitMsg
        if ($LASTEXITCODE -ne 0) {
            Log "  Commit selhal (možná žádné soubory), pokračuji."
        }

        # Push do monorepa
        git push origin main
        if ($LASTEXITCODE -ne 0) {
            Log "  Push selhal, zkouším znovu s pull..."
            git pull --rebase origin main
            git push origin main
        }

        Update-State $repoName $targetPath $wave "migrated"
        Log "  Migrace dokončena."
    }

    # Archivace pro danou vlnu
    $archives = $plan | Where-Object { $_.migration_wave -eq $wave -and $_.action -eq "archive" }
    if ($archives.Count -gt 0) {
        Log "Archivuji $($archives.Count) repozitářů..."
        foreach ($arch in $archives) {
            $repoToArchive = $arch.repo_name
            $uri = "https://api.github.com/repos/$Owner/$repoToArchive"
            $body = @{ archived = $true } | ConvertTo-Json
            try {
                Invoke-RestMethod -Uri $uri -Method Patch -Headers $headers -Body $body -ContentType "application/json" | Out-Null
                Log "  Archivováno: $repoToArchive"
            } catch {
                Log "  Selhalo archivace: $repoToArchive - $_"
            }
        }
    }
}

# ---------- 4. Branch protection ----------
Log "Nastavuji branch protection..."
$uriProt = "https://api.github.com/repos/$Owner/$repoName/branches/main/protection"
$bodyProt = @{
    required_status_checks = $null
    enforce_admins = $true
    required_pull_request_reviews = @{
        required_approving_review_count = 1
    }
    restrictions = $null
} | ConvertTo-Json -Depth 3
Invoke-RestMethod -Uri $uriProt -Method Put -Headers $headers -Body $bodyProt -ContentType "application/json" | Out-Null
Log "Branch protection nastavena."

Log "===== MIGRACE KOMPLETNÍ ====="
