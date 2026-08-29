# static_analysis.py
# Pokusí se spustit dostupné lint/scan nástroje pro daný typ souboru.
# Vyžaduje externí nástroje nainstalované v systému (např. cppcheck, ruff, bandit).
import shutil
import subprocess
from pathlib import Path

def run_cmd(cmd):
    try:
        p = subprocess.run(cmd, stdout=subprocess.PIPE, stderr=subprocess.PIPE, timeout=30, text=True)
        return {"rc": p.returncode, "out": p.stdout.strip(), "err": p.stderr.strip()}
    except Exception as e:
        return {"error": str(e)}

def analyze(path, content):
    p = Path(path)
    ext = p.suffix.lower()
    results = {"plugin": "static_analysis", "analyzed": False, "tool_results": []}
    # python -> bandit or ruff
    if ext == ".py":
        if shutil.which("ruff"):
            results["analyzed"] = True
            results["tool_results"].append({"tool": "ruff", "result": run_cmd(["ruff", "check", str(p)])})
        if shutil.which("bandit"):
            results["analyzed"] = True
            results["tool_results"].append({"tool": "bandit", "result": run_cmd(["bandit", "-r", str(p)])})
    # c/c++ -> cppcheck
    if ext in (".c", ".cpp", ".h", ".hpp"):
        if shutil.which("cppcheck"):
            results["analyzed"] = True
            results["tool_results"].append({"tool": "cppcheck", "result": run_cmd(["cppcheck", "--enable=all", str(p)])})
    return results
