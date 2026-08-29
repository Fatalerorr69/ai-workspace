# structure_scanner.py
import os
from pathlib import Path

def scan_folder(base_dir, max_file_size=5*1024*1024):
    files=[]
    for root, _, filenames in os.walk(base_dir):
        for f in filenames:
            p=Path(root)/f
            try:
                size=p.stat().st_size
                if size <= max_file_size:
                    files.append({"path": str(p), "size": size})
            except Exception:
                continue
    return files
