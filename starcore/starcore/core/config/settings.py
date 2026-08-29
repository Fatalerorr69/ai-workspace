import os
from pathlib import Path

class Settings:
    BASE_DIR = Path(__file__).resolve().parent.parent.parent
    DATA_DIR = BASE_DIR / "data"
    DB_PATH = DATA_DIR / "starcore.db"
    LOG_DIR = DATA_DIR / "logs"

    def __init__(self):
        self.DATA_DIR.mkdir(exist_ok=True)
        self.LOG_DIR.mkdir(exist_ok=True)

settings = Settings()
