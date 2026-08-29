$dashboardMain = @"
from fastapi import FastAPI
from fastapi.staticfiles import StaticFiles
from fastapi.templating import Jinja2Templates
from fastapi.requests import Request
import uvicorn

app = FastAPI(title='Starko AI Suite 2.0')

templates = Jinja2Templates(directory='templates')
app.mount('/static', StaticFiles(directory='static'), name='static')

@app.get('/')
def dashboard(request: Request):
    return templates.TemplateResponse('index.html', {'request': request})

if __name__ == '__main__':
    uvicorn.run(app, host='127.0.0.1', port=8899, log_level='info')
"@

$dashboardPath = "dashboard\main.py"
$templatesIndex = @"
<!DOCTYPE html>
<html lang='cs'>
<head>
<meta charset='UTF-8'>
<title>Starko AI Suite 2.0</title>
</head>
<body>
<h1>Starko AI Suite 2.0 – Web Dashboard</h1>
<p>Všechny pluginy a paměťový engine připraveny.</p>
</body>
</html>
"@

if (-not (Test-Path $dashboardPath)) {
    $dashboardMain | Out-File -FilePath $dashboardPath -Encoding UTF8
    Write-Host "[OK] Dashboard main.py vytvořen" -ForegroundColor Green
}

$templatesPath = "dashboard\templates\index.html"
if (-not (Test-Path $templatesPath)) {
    $templatesIndex | Out-File -FilePath $templatesPath -Encoding UTF8
    Write-Host "[OK] Dashboard šablona index.html vytvořena" -ForegroundColor Green
}
