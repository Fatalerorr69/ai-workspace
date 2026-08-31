Export-ModuleMember -Function Invoke-ReadmeTemplateApply

function Invoke-ReadmeTemplateApply {
    param([string]$Root = "E:\Git")
    $template = @"
# {{NAME}}

Krátký popis projektu.

## Účel a zaměření
- ...

## Platforma
- ...

## Role v ekosystému
- ...

## Instalace
- ...

"@
    Get-ChildItem $Root -Directory | ForEach-Object {
        $p = $_.FullName
        $name = $_.Name
        $readme = Join-Path $p "README.md"
        if (-not (Test-Path $readme)) {
            $content = $template -replace "{{NAME}}",$name
            $content | Set-Content $readme -Encoding UTF8
            try { git -C $p add README.md; git -C $p commit -m "Add README from template" } catch { }
            try { git -C $p push origin (git -C $p rev-parse --abbrev-ref HEAD) } catch { }
        }
    }
}
