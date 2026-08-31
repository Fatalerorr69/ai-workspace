import os
import subprocess
import json
from pathlib import Path
from rich.console import Console
from rich.table import Table
from core.config import settings

console = Console()
SSH_CONFIG_DIR = settings.BASE_DIR / "ssh_configs"
SSH_CONFIG_DIR.mkdir(exist_ok=True)

def add(name: str, host: str, user: str = None, port: int = 22, key_path: str = None):
    """Přidá SSH spojení do konfigurace."""
    config = {
        "host": host,
        "user": user or os.environ.get("USER", "root"),
        "port": port,
        "key_path": key_path,
        "active": True
    }
    config_file = SSH_CONFIG_DIR / f"{name}.json"
    with open(config_file, "w") as f:
        json.dump(config, f, indent=2)
    console.print(f"[green]✅ SSH spojení '{name}' přidáno[/green]")

def list_connections():
    """Zobrazí seznam SSH spojení."""
    connections = []
    for f in SSH_CONFIG_DIR.glob("*.json"):
        with open(f, "r") as fp:
            data = json.load(fp)
            data["name"] = f.stem
            connections.append(data)
    if connections:
        table = Table(title="SSH Connections", show_header=True)
        table.add_column("Název", style="cyan")
        table.add_column("Host", style="yellow")
        table.add_column("User", style="green")
        table.add_column("Port", style="blue")
        for c in connections:
            table.add_row(c["name"], c["host"], c["user"], str(c["port"]))
        console.print(table)
    else:
        console.print("❌ Žádné SSH spojení")

def connect(name: str):
    """Připojí se přes SSH k zadanému spojení."""
    config_file = SSH_CONFIG_DIR / f"{name}.json"
    if not config_file.exists():
        console.print(f"[red]❌ Spojení '{name}' neexistuje[/red]")
        return
    with open(config_file, "r") as f:
        config = json.load(f)
    cmd = f"ssh {config['user']}@{config['host']} -p {config['port']}"
    if config.get("key_path"):
        cmd += f" -i {config['key_path']}"
    console.print(f"[yellow]🔗 Připojuji se: {cmd}[/yellow]")
    subprocess.run(cmd, shell=True)

def exec_cmd(name: str, command: str):
    """Spustí příkaz na vzdáleném serveru přes SSH."""
    config_file = SSH_CONFIG_DIR / f"{name}.json"
    if not config_file.exists():
        console.print(f"[red]❌ Spojení '{name}' neexistuje[/red]")
        return
    with open(config_file, "r") as f:
        config = json.load(f)
    cmd = f"ssh {config['user']}@{config['host']} -p {config['port']} '{command}'"
    if config.get("key_path"):
        cmd = f"ssh -i {config['key_path']} {config['user']}@{config['host']} -p {config['port']} '{command}'"
    subprocess.run(cmd, shell=True)

def keygen(name: str = "starcore"):
    """Vygeneruje nový SSH klíč."""
    key_path = os.path.expanduser(f"~/.ssh/{name}_ed25519")
    if os.path.exists(key_path):
        console.print(f"[yellow]Klíč {key_path} již existuje[/yellow]")
        return
    subprocess.run(["ssh-keygen", "-t", "ed25519", "-f", key_path, "-N", ""], check=True)
    console.print(f"[green]✅ Klíč vygenerován: {key_path}[/green]")
    console.print(f"[yellow]Veřejný klíč:[/yellow]")
    with open(f"{key_path}.pub", "r") as f:
        console.print(f.read())

def copy_id(name: str, server: str):
    """Zkopíruje veřejný klíč na server."""
    key_path = os.path.expanduser(f"~/.ssh/{name}_ed25519.pub")
    if not os.path.exists(key_path):
        console.print(f"[red]Klíč {key_path} neexistuje, vygenerujte ho nejprve[/red]")
        return
    subprocess.run(["ssh-copy-id", "-i", key_path, server], check=True)
    console.print(f"[green]✅ Klíč zkopírován na {server}[/green]")
