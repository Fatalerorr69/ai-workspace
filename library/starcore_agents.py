import json
from typing import Dict, Optional
from core.config import settings

class AgentManager:
    def __init__(self):
        self.agents_file = settings.DATA_DIR / "agents.json"
        self._load_agents()

    def _load_agents(self):
        if self.agents_file.exists():
            with open(self.agents_file, "r") as f:
                self.agents = json.load(f)
        else:
            self.agents = {}
            self._save_agents()

    def _save_agents(self):
        with open(self.agents_file, "w") as f:
            json.dump(self.agents, f, indent=2)

    def add(self, name: str, config: Dict):
        self.agents[name] = config
        self._save_agents()

    def remove(self, name: str):
        if name in self.agents:
            del self.agents[name]
            self._save_agents()

    def get(self, name: str) -> Optional[Dict]:
        return self.agents.get(name)

    def list(self) -> Dict:
        return self.agents

    def status(self) -> Dict:
        return {"total": len(self.agents), "agents": list(self.agents.keys())}
