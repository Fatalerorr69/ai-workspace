import os
import subprocess
import json
import time
from pathlib import Path
from typing import Dict, Optional, List
from core.config import settings
from core.logging import logger

class ServiceManager:
    def __init__(self):
        self.services_dir = settings.BASE_DIR / "services"
        self.services_dir.mkdir(exist_ok=True)
        self.tmux_session = "starcore"
        self.services_file = self.services_dir / "services.json"
        self._load_services()

    def _load_services(self):
        if self.services_file.exists():
            with open(self.services_file, "r") as f:
                self.services = json.load(f)
        else:
            self.services = {}
            self._save_services()

    def _save_services(self):
        with open(self.services_file, "w") as f:
            json.dump(self.services, f, indent=2)

    def register(self, name: str, command: str, description: str = "", auto_restart: bool = True):
        self.services[name] = {
            "command": command,
            "description": description,
            "auto_restart": auto_restart,
            "pid": None,
            "status": "stopped",
            "started_at": None
        }
        self._save_services()

    def start(self, name: str) -> bool:
        if name not in self.services:
            logger.error(f"Služba {name} není registrována")
            return False

        # Zajistíme existenci tmux session
        if not self._tmux_has_session():
            subprocess.run(["tmux", "new-session", "-d", "-s", self.tmux_session])

        service = self.services[name]
        window = f"{self.tmux_session}:{name}"

        # Zastavíme, pokud už běží
        if self._window_exists(window):
            self.stop(name)

        # Log soubor
        log_file = settings.LOG_DIR / f"{name}.log"
        log_file.parent.mkdir(parents=True, exist_ok=True)

        # Příkaz s přesměrováním stdout i stderr do logu
        cmd = f"tmux new-window -d -t {self.tmux_session} -n {name} 'bash -c \"{service['command']} >> {log_file} 2>&1\"'"
        try:
            subprocess.run(cmd, shell=True, check=True)
            # Počkáme chvíli, aby se okno vytvořilo
            time.sleep(0.5)
            if self._window_exists(window):
                service["status"] = "running"
                service["started_at"] = time.time()
                self._save_services()
                logger.info(f"Služba {name} spuštěna")
                return True
            else:
                logger.error(f"Okno {window} se nevytvořilo")
                return False
        except subprocess.CalledProcessError as e:
            logger.error(f"Chyba při spuštění {name}: {e}")
            return False

    def stop(self, name: str) -> bool:
        if name not in self.services:
            logger.error(f"Služba {name} není registrována")
            return False

        window = f"{self.tmux_session}:{name}"
        if self._window_exists(window):
            try:
                subprocess.run(f"tmux kill-window -t {window}", shell=True, capture_output=True)
            except Exception as e:
                logger.error(f"Chyba při zabíjení okna {name}: {e}")
        self.services[name]["status"] = "stopped"
        self.services[name]["started_at"] = None
        self._save_services()
        logger.info(f"Služba {name} zastavena")
        return True

    def status(self, name: Optional[str] = None) -> Dict:
        if name:
            if name in self.services:
                return {name: self._get_status_detail(name)}
            return {}

        result = {}
        for s in self.services:
            result[s] = self._get_status_detail(s)
        return result

    def _get_status_detail(self, name: str) -> Dict:
        service = self.services[name]
        window = f"{self.tmux_session}:{name}"
        if self._window_exists(window):
            service["status"] = "running"
        else:
            service["status"] = "stopped"
        self._save_services()
        return service

    def _window_exists(self, window: str) -> bool:
        try:
            subprocess.run(f"tmux list-windows -t {self.tmux_session} | grep -q {window.split(':')[1]}",
                          shell=True, check=True, capture_output=True)
            return True
        except:
            return False

    def logs(self, name: str, lines: int = 50) -> str:
        log_file = settings.LOG_DIR / f"{name}.log"
        if log_file.exists():
            try:
                with open(log_file, "r") as f:
                    lines_list = f.readlines()[-lines:]
                return "".join(lines_list)
            except:
                return "Nelze přečíst log"
        return f"Log pro {name} neexistuje"

    def restart(self, name: str) -> bool:
        if self.stop(name):
            time.sleep(1)
            return self.start(name)
        return False

    def _tmux_has_session(self) -> bool:
        try:
            subprocess.run(f"tmux has-session -t {self.tmux_session}",
                          shell=True, check=True, capture_output=True)
            return True
        except:
            return False

    def list_all(self) -> List[str]:
        return list(self.services.keys())

manager = ServiceManager()
