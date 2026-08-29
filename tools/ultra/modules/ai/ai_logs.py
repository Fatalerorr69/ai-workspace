import time
from ai_config import LOG_FILE

def tail_logs():
    with open(LOG_FILE, "r") as f:
        f.seek(0,2)  # konec souboru
        while True:
            line = f.readline()
            if line:
                yield line.strip()
            else:
                time.sleep(0.5)
