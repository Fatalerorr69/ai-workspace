import sys
import os
from pathlib import Path

PROJECT_ROOT = Path(__file__).resolve().parent.parent
sys.path.insert(0, str(PROJECT_ROOT))

from fastapi import FastAPI, HTTPException
from fastapi.responses import HTMLResponse, JSONResponse
from fastapi.staticfiles import StaticFiles
import json
import httpx

from core.services.manager import manager as service_manager
from core.hive.engine import hive

app = FastAPI(title="STARCORE Dashboard", version="0.1.0")

# ====== API ENDPOINTY ======

@app.get("/api/status")
async def api_status():
    services = service_manager.status()
    hive_status = hive.status()
    return {
        "version": "0.1.0",
        "services": {
            "total": len(services),
            "running": sum(1 for s in services.values() if s["status"] == "running")
        },
        "hive": {
            "running": hive_status["running"],
            "agents": len(hive_status["agents"]["agents"])
        },
        "system": {
            "python": sys.version.split()[0],
            "os": "Android" if "com.termux" in os.environ.get("PREFIX", "") else "Linux"
        }
    }

@app.get("/api/services")
async def api_services():
    return service_manager.status()

@app.get("/api/services/{name}")
async def api_service_detail(name: str):
    if name not in service_manager.services:
        raise HTTPException(status_code=404, detail="Služba nenalezena")
    return service_manager.services[name]

@app.get("/api/services/{name}/logs")
async def api_service_logs(name: str, lines: int = 50):
    if name not in service_manager.services:
        raise HTTPException(status_code=404, detail="Služba nenalezena")
    log_content = service_manager.logs(name, lines)
    return {"service": name, "logs": log_content}

@app.get("/api/hive")
async def api_hive():
    return hive.status()

@app.get("/api/hive/agents")
async def api_hive_agents():
    return hive.agents.list()

# ====== WEB ROZHRANÍ – PŘÍMÉ VRÁCENÍ HTML ======

HTML_FILE = Path(__file__).parent / "templates" / "dashboard.html"

@app.get("/", response_class=HTMLResponse)
async def dashboard():
    if HTML_FILE.exists():
        with open(HTML_FILE, "r", encoding="utf-8") as f:
            html_content = f.read()
        return html_content
    return HTMLResponse("<h1>Dashboard template not found</h1>", status_code=404)

@app.get("/health")
async def health():
    return {"status": "ok"}

# Spuštění (pro přímý běh)
if __name__ == "__main__":
    import uvicorn
    uvicorn.run(app, host="0.0.0.0", port=8000)
