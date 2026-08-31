# deploy_script_generator.py
# Generuje návrhy Dockerfile / docker-compose fragmentů podle jednoduchých heuristik.
from pathlib import Path

def analyze(path, content):
    fname = Path(path).name.lower()
    ret = {"plugin": "deploy_script_generator", "suggestions": []}
    if "requirements.txt" in fname or "pyproject" in fname:
        dockerfile = """# Dockerfile (python)
FROM python:3.11-slim
WORKDIR /app
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt
COPY . .
CMD ["python", "main.py"]
"""
        compose = """version: '3.8'\nservices:\n  app:\n    build: .\n    ports:\n      - '8000:8000'\n"""
        ret["suggestions"].append({"type": "python", "dockerfile": dockerfile, "compose": compose})
    if "package.json" in fname:
        dockerfile = """# Node Dockerfile\nFROM node:18-alpine\nWORKDIR /app\nCOPY package*.json ./\nRUN npm ci --production\nCOPY . .\nCMD [\"node\", \"index.js\"]\n"""
        ret["suggestions"].append({"type": "node", "dockerfile": dockerfile})
    return ret
