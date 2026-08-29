import sqlite3
from core.config import settings

class Database:
    def __init__(self):
        self.conn = sqlite3.connect(settings.DB_PATH)
        self._init_tables()

    def _init_tables(self):
        self.conn.execute("""
            CREATE TABLE IF NOT EXISTS metadata (
                key TEXT PRIMARY KEY,
                value TEXT
            )
        """)
        self.conn.commit()

    def get(self, key):
        cur = self.conn.execute("SELECT value FROM metadata WHERE key = ?", (key,))
        row = cur.fetchone()
        return row[0] if row else None

    def set(self, key, value):
        self.conn.execute("REPLACE INTO metadata (key, value) VALUES (?, ?)", (key, value))
        self.conn.commit()

db = Database()
