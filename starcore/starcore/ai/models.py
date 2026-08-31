#!/usr/bin/env python
# STARCORE AI Model Manager

import json
from core.config import settings
from core.logging import logger

class ModelManager:
    def __init__(self):
        self.config_file = settings.DATA_DIR / "models.json"
        self._load_models()
    
    def _load_models(self):
        if self.config_file.exists():
            with open(self.config_file, "r") as f:
                self.models = json.load(f)
        else:
            self.models = {
                "openai/gpt-4o": {
                    "provider": "openrouter",
                    "cost": "medium",
                    "capabilities": ["chat", "vision", "functions"]
                },
                "openai/gpt-3.5-turbo": {
                    "provider": "openrouter",
                    "cost": "low",
                    "capabilities": ["chat", "functions"]
                },
                "llama3.2": {
                    "provider": "local",
                    "cost": "free",
                    "capabilities": ["chat"],
                    "requires": "ollama"
                },
                "mistral:7b": {
                    "provider": "local",
                    "cost": "free",
                    "capabilities": ["chat"],
                    "requires": "ollama"
                }
            }
            self._save_models()
    
    def _save_models(self):
        with open(self.config_file, "w") as f:
            json.dump(self.models, f, indent=2)
    
    def list_models(self):
        return self.models
    
    def switch_model(self, model_name: str):
        from .runtime import ai
        config = ai.get_config()
        if model_name in self.models:
            model = self.models[model_name]
            ai.set_config("model", model_name)
            ai.set_config("provider", model["provider"])
            logger.info(f"Switched to model: {model_name}")
            return True
        return False

model_manager = ModelManager()
