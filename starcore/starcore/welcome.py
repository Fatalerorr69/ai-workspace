#!/usr/bin/env python
# -*- coding: utf-8 -*-
# STARCORE Welcome Screen - Stabilní verze

import os
import sys
import subprocess
import signal
from pathlib import Path
from rich.console import Console
from rich.panel import Panel
from rich.table import Table
from rich import box

PROJECT_ROOT = Path(__file__).resolve().parent
sys.path.insert(0, str(PROJECT_ROOT))
console = Console()

def timeout_handler(signum, frame):
    raise TimeoutError("Subprocess timeout")

def get_status():
    status = {
        "version": "0.1.0",
        "services": {"total": 0, "running": 0},
        "hive": False,
        "ai": False,
        "dashboard": False,
        "ip": "N/A",
    }
    try:
        # Verze
        r = subprocess.run(["./starcore", "version"], capture_output=True, text=True, cwd=PROJECT_ROOT, timeout=2)
        if r.returncode == 0 and r.stdout:
            status["version"] = r.stdout.strip().split("v")[-1]

        # Služby
        r = subprocess.run(["./starcore", "status"], capture_output=True, text=True, cwd=PROJECT_ROOT, timeout=2)
        if r.returncode == 0:
            for line in r.stdout.splitlines():
                if "running" in line:
                    status["services"]["running"] += 1
                if "Služba" in line or "┃" in line:
                    status["services"]["total"] += 1

        # HIVE
        r = subprocess.run(["./starcore", "hive-status"], capture_output=True, text=True, cwd=PROJECT_ROOT, timeout=2)
        if "Running" in r.stdout:
            status["hive"] = True

        # AI
        r = subprocess.run(["./starcore", "ai-status"], capture_output=True, text=True, cwd=PROJECT_ROOT, timeout=2)
        if "Running" in r.stdout:
            status["ai"] = True

        # Dashboard
        try:
            import httpx
            resp = httpx.get("http://localhost:8000/health", timeout=1)
            status["dashboard"] = resp.status_code == 200
        except:
            pass

        # IP
        r = subprocess.run(["ifconfig"], capture_output=True, text=True, timeout=2)
        for line in r.stdout.splitlines():
            if "inet " in line and "127.0.0.1" not in line and ":" not in line:
                status["ip"] = line.split()[1]
                break

    except (subprocess.TimeoutExpired, TimeoutError):
        console.print("[yellow]⚠️ Timeout při načítání stavu[/yellow]")
    except Exception as e:
        console.print(f"[red]Error: {e}[/red]")
    return status

def logo(version):
    return f"""
[bold cyan]
  ███████╗████████╗ █████╗ ██████╗  ██████╗ ██████╗ ███████╗
  ██╔════╝╚══██╔══╝██╔══██╗██╔══██╗██╔═══██╗██╔══██╗██╔════╝
  ███████╗   ██║   ███████║██████╔╝██║   ██║██████╔╝█████╗  
  ╚════██║   ██║   ██╔══██║██╔══██╗██║   ██║██╔══██╗██╔══╝  
  ███████║   ██║   ██║  ██║██║  ██║╚██████╔╝██║  ██║███████╗
  ╚══════╝   ╚═╝   ╚═╝  ╚═╝╚═╝  ╚═╝ ╚═════╝ ╚═╝  ╚═╝╚══════╝
[/bold cyan]
[bold yellow]  STARCORE Mobile v{version} – Termux Edition[/bold yellow]
"""

def main():
    status = get_status()
    console.clear()
    console.print(Panel(logo(status["version"]), border_style="green"))

    tabs = ["Status", "Services", "AI", "System", "Extensions"]
    current = 0

    while True:
        line = ""
        for i, tab in enumerate(tabs):
            if i == current:
                line += f"[bold green]> {tab}[/bold green]  "
            else:
                line += f"[dim]{tab}[/dim]  "
        console.print(line)
        console.print("-" * 50)

        if current == 0:
            grid = Table.grid(padding=1, expand=True)
            grid.add_column(justify="center", width=18)
            grid.add_column(justify="center", width=18)
            grid.add_column(justify="center", width=18)
            grid.add_column(justify="center", width=18)
            grid.add_row(
                f"[bold]Services[/bold]\n[green]{status['services']['running']}/{status['services']['total']}[/green]",
                f"[bold]HIVE[/bold]\n[{'green' if status['hive'] else 'red'}]{'RUNNING' if status['hive'] else 'STOPPED'}[/]",
                f"[bold]AI[/bold]\n[{'green' if status['ai'] else 'red'}]{'RUNNING' if status['ai'] else 'STOPPED'}[/]",
                f"[bold]Dashboard[/bold]\n[{'green' if status['dashboard'] else 'red'}]{'ON' if status['dashboard'] else 'OFF'}[/]"
            )
            grid.add_row(
                f"[bold]IP[/bold]\n[cyan]{status['ip']}[/cyan]",
                f"[bold]Version[/bold]\n[magenta]{status['version']}[/magenta]",
                "",
                ""
            )
            console.print(Panel(grid, title="STARCORE Status", border_style="blue"))

        elif current == 1:
            r = subprocess.run(["./starcore", "status"], capture_output=True, text=True, cwd=PROJECT_ROOT, timeout=2)
            console.print(Panel(r.stdout or "No services", title="Services", border_style="yellow"))

        elif current == 2:
            r = subprocess.run(["./starcore", "ai-status"], capture_output=True, text=True, cwd=PROJECT_ROOT, timeout=2)
            c = subprocess.run(["./starcore", "ai-config"], capture_output=True, text=True, cwd=PROJECT_ROOT, timeout=2)
            console.print(Panel(r.stdout + "\n" + c.stdout, title="AI Runtime", border_style="magenta"))

        elif current == 3:
            info = {}
            try:
                info["OS"] = subprocess.check_output(["uname", "-a"], text=True, timeout=2).strip()
                info["Arch"] = subprocess.check_output(["uname", "-m"], text=True, timeout=2).strip()
                info["Termux"] = "Yes" if "com.termux" in os.environ.get("PREFIX", "") else "No"
                info["User"] = os.environ.get("USER", "unknown")
                info["Home"] = os.path.expanduser("~")
            except:
                pass
            output = "\n".join([f"{k}: {v}" for k, v in info.items()]) + f"\nIP: {status['ip']}"
            console.print(Panel(output, title="System", border_style="cyan"))

        elif current == 4:
            exts = {
                "Vision": "OCR - text recognition from images",
                "Network": "Ping, speedtest",
                "Sync": "File sync via rsync",
                "Backup": "STARCORE data backup",
                "SSH": "SSH connection manager",
                "Proxmox": "VM and container management"
            }
            table = Table(title="STARCORE Extensions", box=box.ROUNDED)
            table.add_column("Extension", style="cyan")
            table.add_column("Description", style="white")
            for name, desc in exts.items():
                table.add_row(name, desc)
            console.print(table)

        console.print("\n[dim](arrows: < > | q: quit | r: refresh)[/dim]")
        try:
            key = console.input("[cyan]Choice: [/cyan]")
        except KeyboardInterrupt:
            break

        if key.lower() == "q":
            break
        elif key == "\x1b[C":
            current = (current + 1) % len(tabs)
        elif key == "\x1b[D":
            current = (current - 1) % len(tabs)
        elif key.lower() == "r":
            status = get_status()

if __name__ == "__main__":
    try:
        main()
    except KeyboardInterrupt:
        console.print("\n[green]Goodbye![/green]")
    except Exception as e:
        console.print(f"[red]Error: {e}[/red]")
