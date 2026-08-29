#!/usr/bin/env python3
import os
import sys
import time
import socket
import subprocess
from pathlib import Path

from rich.console import Console
from rich.panel import Panel
from rich.table import Table

try:
    from pymongo import MongoClient
except ImportError:
    print("❌ pymongo není nainstalováno – aktivuj venv")
    sys.exit(1)

console = Console()

# ===============================
# CONFIG
# ===============================
ULTRA_HOME = Path(os.getenv("ULTRA_HOME", Path.home() / ".ultra"))
INSTALL_DIR = Path(os.getenv("ULTRA_INSTALL", Path.cwd()))
MONGO_URI = os.getenv("MONGO_URI", "mongodb://127.0.0.1:27017")
START_TIME = time.time()

# ===============================
# HELPERS
# ===============================
def banner():
    console.print(Panel.fit(
        "[bold cyan]ULTRA v18 FINAL[/bold cyan]\n"
        "[white]Unified Pentest & Dev Platform[/white]\n\n"
        "[green]Launcher & Healthcheck[/green]",
        border_style="cyan"
    ))

def check_python():
    v = sys.version_info
    return v.major == 3 and v.minor >= 10, f"{v.major}.{v.minor}.{v.micro}"

def check_env():
    return ULTRA_HOME.exists(), str(ULTRA_HOME)

def check_port(host, port):
    try:
        with socket.create_connection((host, port), timeout=2):
            return True
    except Exception:
        return False

def check_mongo():
    try:
        client = MongoClient(MONGO_URI, serverSelectionTimeoutMS=2000)
        client.admin.command("ping")
        return True
    except Exception:
        return False

def init_db():
    client = MongoClient(MONGO_URI)
    db = client["ultra"]
    db.meta.update_one(
        {"_id": "install"},
        {"$set": {"version": "18.0", "ts": time.time()}},
        upsert=True
    )

# ===============================
# HEALTHCHECK
# ===============================
def healthcheck():
    table = Table(title="ULTRA – System Healthcheck", expand=True)
    table.add_column("Komponenta", style="cyan")
    table.add_column("Stav", style="green")
    table.add_column("Detail", style="white")

    ok_py, py_ver = check_python()
    table.add_row("Python", "OK" if ok_py else "FAIL", py_ver)

    ok_env, env_path = check_env()
    table.add_row("ULTRA_HOME", "OK" if ok_env else "FAIL", env_path)

    mongo_port = int(MONGO_URI.split(":")[-1])
    port_ok = check_port("127.0.0.1", mongo_port)
    table.add_row("MongoDB Port", "OK" if port_ok else "FAIL", str(mongo_port))

    mongo_ok = check_mongo()
    table.add_row("MongoDB Ping", "OK" if mongo_ok else "FAIL", MONGO_URI)

    console.print(table)

    if not all([ok_py, ok_env, port_ok, mongo_ok]):
        console.print("\n[bold red]❌ Healthcheck selhal – ULTRA se nespustí[/bold red]")
        sys.exit(1)

# ===============================
# MODULE LOADER (placeholder)
# ===============================
def load_modules():
    modules_dir = INSTALL_DIR / "modules"
    if not modules_dir.exists():
        return

    for m in modules_dir.iterdir():
        if m.is_dir():
            console.print(f"[blue]→ Modul připraven:[/blue] {m.name}")

# ===============================
# MAIN
# ===============================
def main():
    banner()
    healthcheck()
    init_db()
    load_modules()

    elapsed = round(time.time() - START_TIME, 2)
    console.print(f"\n[bold green]✅ ULTRA je připraveno[/bold green] ({elapsed}s)")
    console.print("[white]Další krok: Web GUI / AI / Moduly[/white]\n")

if __name__ == "__main__":
    main()
