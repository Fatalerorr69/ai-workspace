import time
import threading
import json
from typing import Dict
from pathlib import Path
from core.logging import logger
from core.config import settings
from .scheduler import Scheduler
from .agents import AgentManager
from .orchestrator import orchestrator

STATE_FILE = settings.DATA_DIR / "hive_state.json"

class HIVEEngine:
    def __init__(self):
        self.scheduler = Scheduler()
        self.agents = AgentManager()
        self._load_state()
        logger.info("HIVE Engine initialized")

    def _load_state(self):
        if STATE_FILE.exists():
            with open(STATE_FILE, "r") as f:
                state = json.load(f)
                self.running = state.get("running", False)
                self.pid = state.get("pid", None)
        else:
            self.running = False
            self.pid = None
            self._save_state()

    def _save_state(self):
        with open(STATE_FILE, "w") as f:
            json.dump({"running": self.running, "pid": self.pid}, f, indent=2)

    def start(self):
        if self.running:
            logger.warning("HIVE already running")
            return
        logger.info("HIVE Engine starting...")
        self.running = True
        self.pid = threading.get_ident()
        self._save_state()
        self.scheduler.start()
        orchestrator.start()
        time.sleep(0.5)
        self.thread = threading.Thread(target=self._run, daemon=True)
        self.thread.start()
        logger.info(f"HIVE Engine started (PID: {self.pid})")

    def stop(self):
        self.running = False
        self.pid = None
        self._save_state()
        orchestrator.stop()
        if hasattr(self, 'thread') and self.thread:
            self.thread.join(timeout=2)
        self.scheduler.shutdown()
        logger.info("HIVE Engine stopped")

    def _run(self):
        logger.info("HIVE main loop started")
        counter = 0
        while self.running:
            counter += 1
            if counter % 10 == 0:
                logger.info(f"HIVE loop tick {counter}")
            time.sleep(1)
        logger.info("HIVE main loop ended")

    def status(self) -> Dict:
        self._load_state()
        return {
            "running": self.running,
            "pid": self.pid,
            "scheduler": self.scheduler.status(),
            "agents": self.agents.status(),
            "orchestrator": orchestrator.status()
        }

# Vytvoření instance a export
hive = HIVEEngine()
scheduler = hive.scheduler  # export scheduleru pro přímý import
