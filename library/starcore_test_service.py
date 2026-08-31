import sys
import os
import time

# Přidáme cestu k projektu, aby import fungoval i při spuštění z tmux
PROJECT_ROOT = os.path.expanduser("~/STARCORE")
if PROJECT_ROOT not in sys.path:
    sys.path.insert(0, PROJECT_ROOT)

from core.logging import logger

def main():
    logger.info("Test service started")
    counter = 0
    while True:
        msg = f"Tick {counter}"
        logger.info(msg)
        print(msg, flush=True)
        counter += 1
        time.sleep(5)

if __name__ == "__main__":
    main()
