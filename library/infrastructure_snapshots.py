import subprocess
from datetime import datetime

def list():
    return subprocess.getoutput(
        "zfs list -t snapshot -o name,creation"
    ).splitlines()

def create(dataset):
    ts = datetime.now().strftime("%Y%m%d-%H%M")
    subprocess.call(["zfs", "snapshot", f"{dataset}@{ts}"])
