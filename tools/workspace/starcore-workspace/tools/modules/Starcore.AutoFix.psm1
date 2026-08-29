function Invoke-StarcoreAutoFix {
    [CmdletBinding()]
    param(
        [string]$ProjectPath,
        [switch]$DryRun,
        [switch]$WriteRenameMap,
        [string]$RenameMapFile = ""
    )

    $name = Split-Path $ProjectPath -Leaf
    $fixes = @()
    $actions = @()

    # --- FIX 1: README ---
    $readme = Join-Path $ProjectPath "README.md"
    if (-not (Test-Path $readme)) {
        $actions += @{ action="create"; file=$readme; content="# $name`n`nAutoFix: README created." }
        $fixes += "Will create README.md"
    }

    # --- FIX 2: PROJECT_DEFINITION ---
    $def = Join-Path $ProjectPath "PROJECT_DEFINITION.md"
    if (-not (Test-Path $def)) {
        $actions += @{ action="create"; file=$def; content="# PROJECT DEFINITION: $name`nAutoFix: Definition created." }
        $fixes += "Will create PROJECT_DEFINITION.md"
    }

    # --- FIX 3: .gitignore ---
    $gi = Join-Path $ProjectPath ".gitignore"
    if (-not (Test-Path $gi)) {
        $actions += @{ action="create"; file=$gi; content="*.log`n*.tmp`n*.cache`n*.venv`nAutoFix" }
        $fixes += "Will create .gitignore"
    }

    # --- FIX 4: .github/workflows ---
    $workflowDir = Join-Path $ProjectPath ".github\workflows"
    if (-not (Test-Path $workflowDir)) {
        $actions += @{ action="mkdir"; path=$workflowDir }
        $fixes += "Will create .github/workflows"
    }

    # --- FIX 5: Basic CI workflow ---
    $workflowFile = Join-Path $workflowDir "autofix-ci.yml"
    if (-not (Test-Path $workflowFile)) {
        $content = @"
name: AutoFix CI
on: [push]
jobs:
  validate:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      - name: AutoFix validation
        run: echo 'AutoFix CI executed'
"@
        $actions += @{ action="create"; file=$workflowFile; content=$content }
        $fixes += "Will create AutoFix CI workflow"
    }

    # --- FIX 6: Normalize folder name (lowercase + hyphens) ---
    $normalized = $name.ToLower() -replace '\s+','-' -replace '—','-' -replace '–','-'
    $renamePerformed = $null
    if ($normalized -ne $name) {
        $parent = Split-Path $ProjectPath -Parent
        $newPath = Join-Path $parent $normalized
        $actions += @{ action="rename"; from=$ProjectPath; to=$newPath }
        $fixes += "Will rename folder to $normalized"
        $renamePerformed = @{ original=$name; new=$normalized; originalPath=$ProjectPath; newPath=$newPath }
    }

    # --- FIX 7: Git remote URL normalization (dry attempt) ---
    $gitPath = Join-Path $ProjectPath ".git"
    if (Test-Path $gitPath) {
        $sshUrl = "git@github.com:Fatalerorr69/$normalized.git"
        $actions += @{ action="git-set-remote"; path=$ProjectPath; url=$sshUrl }
        $fixes += "Will set git origin to $sshUrl"
    }

    # Execute or dry-run
    $performed = @()
    foreach ($a in $actions) {
        switch ($a.action) {
            "create" {
                if ($DryRun) {
                    $performed += @{ action="create"; file=$a.file; status="dry-run" }
                } else {
                    try {
                        $dir = Split-Path $a.file -Parent
                        if (-not (Test-Path $dir)) { New-Item -ItemType Directory -Path $dir -Force | Out-Null }
                        $a.content | Set-Content -Path $a.file -Encoding UTF8
                        $performed += @{ action="create"; file=$a.file; status="ok" }
                    } catch {
                        $performed += @{ action="create"; file=$a.file; status="error"; error=$_.Exception.Message }
                    }
                }
            }
            "mkdir" {
                if ($DryRun) {
                    $performed += @{ action="mkdir"; path=$a.path; status="dry-run" }
                } else {
                    try {
                        New-Item -ItemType Directory -Path $a.path -Force | Out-Null
                        $performed += @{ action="mkdir"; path=$a.path; status="ok" }
                    } catch {
                        $performed += @{ action="mkdir"; path=$a.path; status="error"; error=$_.Exception.Message }
                    }
                }
            }
            "rename" {
                if ($DryRun) {
                    $performed += @{ action="rename"; from=$a.from; to=$a.to; status="dry-run" }
                } else {
                    try {
                        if (-not (Test-Path $a.to)) {
                            Rename-Item -Path $a.from -NewName (Split-Path $a.to -Leaf) -ErrorAction Stop
                            $performed += @{ action="rename"; from=$a.from; to=$a.to; status="ok" }
                        } else {
                            $performed += @{ action="rename"; from=$a.from; to=$a.to; status="skipped"; reason="target exists" }
                        }
                    } catch {
                        $performed += @{ action="rename"; from=$a.from; to=$a.to; status="error"; error=$_.Exception.Message }
                    }
                }
            }
            "git-set-remote" {
                if ($DryRun) {
                    $performed += @{ action="git-set-remote"; path=$a.path; url=$a.url; status="dry-run" }
                } else {
                    try {
                        git -C $a.path remote set-url origin $a.url 2>$null
                        $performed += @{ action="git-set-remote"; path=$a.path; url=$a.url; status="ok" }
                    } catch {
                        $performed += @{ action="git-set-remote"; path=$a.path; url=$a.url; status="error"; error=$_.Exception.Message }
                    }
                }
            }
        }
    }

    # Write rename map if requested
    if ($WriteRenameMap -and $renamePerformed) {
        if (-not $RenameMapFile) {
            $RenameMapFile = Join-Path (Split-Path $ProjectPath -Parent) ("backup_rename_map_{0}.json" -f (Get-Date -Format "yyyyMMdd_HHmmss"))
        }
        $mapObj = @{ original = $renamePerformed.original; new = $renamePerformed.new; originalPath = $renamePerformed.originalPath; newPath = $renamePerformed.newPath; timestamp = (Get-Date).ToString("o") }
        try {
            $existing = @()
            if (Test-Path $RenameMapFile) { $existing = (Get-Content $RenameMapFile -Raw | ConvertFrom-Json) }
            $existing += $mapObj
            $existing | ConvertTo-Json -Depth 6 | Set-Content $RenameMapFile -Encoding UTF8
        } catch {
            # ignore write errors
        }
    }

    return [PSCustomObject]@{
        project = $name
        dryRun  = [bool]$DryRun
        fixesPlanned = $fixes
        performed = $performed
        renameMapFile = (if ($WriteRenameMap) { $RenameMapFile } else { $null })
    }
}

Export-ModuleMember -Function Invoke-StarcoreAutoFix
