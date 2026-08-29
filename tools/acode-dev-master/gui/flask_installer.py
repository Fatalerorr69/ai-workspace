#!/usr/bin/env python3
from flask import Flask, render_template, request, jsonify
import subprocess, threading, os

app = Flask(__name__)
WORKDIR = os.path.expanduser("~/.acode_dev_master")

def run_cmd(cmd):
    try:
        subprocess.run(cmd, shell=True, check=True, cwd=WORKDIR)
        return True
    except subprocess.CalledProcessError:
        return False

@app.route("/")
def index():
    return render_template("installer.html")

@app.route("/run", methods=["POST"])
def run():
    module = request.form.get("module")
    mapping = {
        "core": "./master_install_core.sh",
        "ai": "./master_install_ai.sh",
        "android": "./master_install_android.sh",
        "wsl": "./master_install_wsl.sh",
        "lcd": "./master_install_lcd.sh",
        "zip": "./create_zip.sh"
    }
    cmd = mapping.get(module)
    if not cmd:
        return jsonify({"ok": False, "msg": "Neznámý modul"}), 400
    threading.Thread(target=run_cmd, args=(cmd,)).start()
    return jsonify({"ok": True, "msg": "Spuštěno: " + module})

if __name__ == "__main__":
    app.run(host="127.0.0.1", port=5001, debug=False)
