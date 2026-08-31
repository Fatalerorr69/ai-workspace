import os
import json
import httpx
from typing import Dict, List, Optional
from rich.console import Console
from rich.table import Table
from rich.panel import Panel
from core.config import settings
from core.logging import logger

console = Console()
CONFIG_FILE = settings.DATA_DIR / "proxmox_config.json"

def _load_config() -> Dict:
    if CONFIG_FILE.exists():
        with open(CONFIG_FILE, "r") as f:
            return json.load(f)
    return {"host": "", "user": "", "password": "", "token": "", "verify_ssl": False}

def _save_config(config: Dict):
    with open(CONFIG_FILE, "w") as f:
        json.dump(config, f, indent=2)

def config(host: str = None, user: str = None, password: str = None, token: str = None):
    """Nastaví Proxmox konfiguraci."""
    cfg = _load_config()
    if host: cfg["host"] = host
    if user: cfg["user"] = user
    if password: cfg["password"] = password
    if token: cfg["token"] = token
    _save_config(cfg)
    console.print("[green]✅ Proxmox konfigurace uložena[/green]")
    # Ověříme připojení
    try:
        _get_client()
        console.print("[green]✅ Připojení k Proxmox ověřeno[/green]")
    except Exception as e:
        console.print(f"[red]❌ Připojení selhalo: {e}[/red]")

def _get_client() -> httpx.Client:
    """Vrátí HTTP klienta s přihlášením."""
    cfg = _load_config()
    if not cfg.get("host"):
        raise Exception("Proxmox není nakonfigurován")
    client = httpx.Client(verify=cfg.get("verify_ssl", False), timeout=30.0)
    # Přihlášení
    if cfg.get("token"):
        client.headers["Authorization"] = f"PVEAPIToken={cfg['token']}"
    elif cfg.get("user") and cfg.get("password"):
        resp = client.post(
            f"https://{cfg['host']}:8006/api2/json/access/ticket",
            data={"username": cfg["user"], "password": cfg["password"]}
        )
        if resp.status_code != 200:
            raise Exception(f"Přihlášení selhalo: {resp.text}")
        data = resp.json()["data"]
        client.headers["Cookie"] = f"PVEAuthCookie={data['ticket']}"
        client.headers["CSRFPreventionToken"] = data["CSRFPreventionToken"]
    else:
        raise Exception("Chybí přihlašovací údaje (user/password nebo token)")
    return client

def list_vms():
    """Zobrazí seznam všech VM a kontejnerů."""
    try:
        client = _get_client()
        cfg = _load_config()
        resp = client.get(f"https://{cfg['host']}:8006/api2/json/nodes/localhost/qemu")
        if resp.status_code != 200:
            console.print(f"[red]Chyba: {resp.text}[/red]")
            return
        data = resp.json()["data"]
        if not data:
            console.print("[yellow]Žádné VM[/yellow]")
            return
        table = Table(title="Proxmox VMs", show_header=True)
        table.add_column("ID", style="cyan")
        table.add_column("Name", style="yellow")
        table.add_column("Status", style="green")
        table.add_column("Memory", style="blue")
        table.add_column("CPU", style="magenta")
        for vm in data:
            table.add_row(
                str(vm.get("vmid", "N/A")),
                vm.get("name", "N/A"),
                vm.get("status", "N/A"),
                f"{vm.get('mem', 0)//1024} MB",
                f"{vm.get('cpus', 0)} jader"
            )
        console.print(table)
    except Exception as e:
        console.print(f"[red]Chyba: {e}[/red]")

def start(vmid: int):
    """Spustí VM."""
    try:
        client = _get_client()
        cfg = _load_config()
        resp = client.post(f"https://{cfg['host']}:8006/api2/json/nodes/localhost/qemu/{vmid}/status/start")
        if resp.status_code == 200:
            console.print(f"[green]✅ VM {vmid} spuštěno[/green]")
        else:
            console.print(f"[red]Chyba: {resp.text}[/red]")
    except Exception as e:
        console.print(f"[red]Chyba: {e}[/red]")

def stop(vmid: int):
    """Zastaví VM."""
    try:
        client = _get_client()
        cfg = _load_config()
        resp = client.post(f"https://{cfg['host']}:8006/api2/json/nodes/localhost/qemu/{vmid}/status/stop")
        if resp.status_code == 200:
            console.print(f"[yellow]✅ VM {vmid} zastaveno[/yellow]")
        else:
            console.print(f"[red]Chyba: {resp.text}[/red]")
    except Exception as e:
        console.print(f"[red]Chyba: {e}[/red]")

def restart(vmid: int):
    """Restartuje VM."""
    try:
        client = _get_client()
        cfg = _load_config()
        resp = client.post(f"https://{cfg['host']}:8006/api2/json/nodes/localhost/qemu/{vmid}/status/reboot")
        if resp.status_code == 200:
            console.print(f"[green]✅ VM {vmid} restartováno[/green]")
        else:
            console.print(f"[red]Chyba: {resp.text}[/red]")
    except Exception as e:
        console.print(f"[red]Chyba: {e}[/red]")

def snapshot(vmid: int, name: str = None):
    """Vytvoří snapshot VM."""
    if not name:
        import datetime
        name = f"snapshot_{datetime.datetime.now().strftime('%Y%m%d_%H%M%S')}"
    try:
        client = _get_client()
        cfg = _load_config()
        resp = client.post(
            f"https://{cfg['host']}:8006/api2/json/nodes/localhost/qemu/{vmid}/snapshot",
            json={"snapname": name}
        )
        if resp.status_code == 200:
            console.print(f"[green]✅ Snapshot '{name}' vytvořen pro VM {vmid}[/green]")
        else:
            console.print(f"[red]Chyba: {resp.text}[/red]")
    except Exception as e:
        console.print(f"[red]Chyba: {e}[/red]")
