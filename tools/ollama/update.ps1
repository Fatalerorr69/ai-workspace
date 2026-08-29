Write-Host "=== Aktualizace Starko AI Suite 2.1 ===" -ForegroundColor Cyan

git pull

Write-Host "Aktualizuji Python závislosti..."
.\venv\Scripts\pip install -r requirements.txt --upgrade

Write-Host "Aktualizuji pluginy..."
# do budoucna rozšířitelné

Write-Host "Aktualizace dokončena." -ForegroundColor Green
