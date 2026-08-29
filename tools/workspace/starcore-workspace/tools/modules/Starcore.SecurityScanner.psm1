function Invoke-StarcoreSecurityScan {
    [CmdletBinding()]
    param(
        [string]$ProjectPath
    )

    $patterns = @(
        "token",
        "apikey",
        "secret",
        "password",
        "passwd",
        "privatekey",
        "BEGIN RSA",
        "BEGIN OPENSSH",
        "BEGIN PRIVATE"
    )

    $findings = @()

    Get-ChildItem -Path $ProjectPath -Recurse -File -ErrorAction SilentlyContinue | ForEach-Object {
        $file = $_.FullName
        $content = Get-Content $file -ErrorAction SilentlyContinue

        foreach ($pattern in $patterns) {
            if ($content -match $pattern) {
                $findings += [PSCustomObject]@{
                    file    = $file
                    pattern = $pattern
                }
            }
        }
    }

    return $findings
}

Export-ModuleMember -Function Invoke-StarcoreSecurityScan
