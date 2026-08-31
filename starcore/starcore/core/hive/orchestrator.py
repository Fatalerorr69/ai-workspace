import time
import threading
import json
from typing import Dict, Callable
from core.logging import logger
from core.config import settings

class Orchestrator:
    def __init__(self):
        self.tasks = {}
        self.running = False
        self.thread = None
        self.interval = 30
        self.data_file = settings.DATA_DIR / "orchestrator.json"
        self._load_data()

    def _load_data(self):
        if self.data_file.exists():
            with open(self.data_file, "r") as f:
                self.tasks = json.load(f)
        else:
            self.tasks = {}
            self._save_data()

    def _save_data(self):
        with open(self.data_file, "w") as f:
            json.dump(self.tasks, f, indent=2)

    def register_task(self, name: str, action: Callable, interval: int = 60, enabled: bool = True):
        self.tasks[name] = {
            "action": action.__name__,
            "interval": interval,
            "enabled": enabled,
            "last_run": None,
            "status": "idle"
        }
        self._save_data()
        logger.info(f"Task registered: {name}")

    def start(self):
        if self.running:
            logger.warning("Orchestrator already running")
            return
        try:
            self.running = True
            self.thread = threading.Thread(target=self._run, daemon=True)
            self.thread.start()
            logger.info("Orchestrator started")
        except Exception as e:
            logger.error(f"Orchestrator start error: {e}")

    def stop(self):
        self.running = False
        if self.thread:
            self.thread.join(timeout=2)
            self.thread = None
        logger.info("Orchestrator stopped")

    def _run(self):
        logger.info("Orchestrator main loop started")
        while self.running:
            for name, task in self.tasks.items():
                if task["enabled"]:
                    logger.info(f"Executing task: {name}")
                    task["last_run"] = time.time()
                    task["status"] = "running"
                    self._save_data()
                    time.sleep(0.5)
                    task["status"] = "idle"
                    self._save_data()
            time.sleep(self.interval)
        logger.info("Orchestrator main loop ended")

    def status(self) -> Dict:
        return {
            "running": self.running,
            "tasks": self.tasks
        }

orchestrator = Orchestrator()
