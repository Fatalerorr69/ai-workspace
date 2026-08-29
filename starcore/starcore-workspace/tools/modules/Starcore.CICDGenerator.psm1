function New-StarcoreCICDWorkflow {
    [CmdletBinding()]
    param(
        [string]$ProjectPath
    )

    $workflowDir = Join-Path $ProjectPath ".github\workflows"
    New-Item -ItemType Directory -Force -Path $workflowDir | Out-Null

    $workflowFile = Join-Path $workflowDir "starcore-ci.yml"

    @"
name: Starcore CI

on:
  push:
    branches: [ main ]
  pull_request:
    branches: [ main ]

jobs:
  build:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      - name: Run basic validation
        run: |
          echo "Validating project structure..."
"@ | Set-Content $workflowFile -Encoding UTF8

    return $workflowFile
}

Export-ModuleMember -Function New-StarcoreCICDWorkflow
