$memoryInit = @"
from chromadb import Client

client = Client()
db = client.get_or_create_collection('starko_memory')
print('[OK] Memory Engine připraven')
"@

$memoryPath = "memory\init_memory.py"
if (-not (Test-Path $memoryPath)) {
    $memoryInit | Out-File -FilePath $memoryPath -Encoding UTF8
    Write-Host "[OK] Skript paměťového engine vytvořen" -ForegroundColor Green
}
