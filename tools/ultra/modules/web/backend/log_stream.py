import time

LOG_FILE = "ultra.log"

def stream_logs():
    with open(LOG_FILE, "r") as f:
        f.seek(0, 2)  # jump to end
        while True:
            line = f.readline()
            if line:
                yield f"data: {line}\n\n"
            else:
                time.sleep(0.5)
