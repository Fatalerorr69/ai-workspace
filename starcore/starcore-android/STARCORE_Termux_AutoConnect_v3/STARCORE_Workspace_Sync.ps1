$ip = "100.88.198.109"
$port = 8022
$user = "u0_a344"

Write-Host "=== STARCORE Workspace Sync ==="

$cmd = "rsync -avz -e 'ssh -p $port' $user@$ip:/data/data/com.termux/files/home/Starcore/ E:\GIT\STARCORE-ANDROID\mirror/"
Write-Host "Running: $cmd"
cmd /c $cmd

Write-Host "=== SYNC DONE ==="
