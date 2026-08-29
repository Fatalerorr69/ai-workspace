from fastapi import FastAPI
from fastapi.staticfiles import StaticFiles
from fastapi.templating import Jinja2Templates
from fastapi.requests import Request
import os, glob

app = FastAPI()
app.mount("/static", StaticFiles(directory="dashboard/static"), name="static")
templates = Jinja2Templates(directory="dashboard/templates")

plugins = [os.path.basename(f) for f in glob.glob("plugins/*.ps1")]

@app.get("/")
async def index(request: Request):
    return templates.TemplateResponse("index.html", {"request": request, "plugins": plugins})

if __name__ == "__main__":
    import uvicorn
    uvicorn.run(app, host="0.0.0.0", port=8000)
