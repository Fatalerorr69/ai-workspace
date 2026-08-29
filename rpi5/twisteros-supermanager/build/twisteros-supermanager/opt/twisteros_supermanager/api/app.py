#!/usr/bin/env python3
from flask import Flask, request, jsonify
import subprocess, os, shlex

APP = Flask(__name__)
HOME = os.environ.get("HOME", "/home/starko")
API_KEY = os.environ.get("TWISTER_API_KEY", "changeme_replace_now")

ALLOWED_SCRIPTS = {
    "retroarch": str(HOME + "/scripts/start_retroarch.sh"),
    "wine_game": str(HOME + "/scripts/start_wine_game.sh"),
    "mount_nas": str(HOME + "/scripts/mount_nas.sh"),
    "sync_roms": str(HOME / "scripts/sync_roms.sh"),
    "sync_bios": str(HOME / "scripts/sync_bios.sh"),
    "import_roms": str(HOME / "scripts/import_roms.sh"),
    "detect_mhs": str(HOME / "scripts/detect_mhs.sh"),
    "setup_mhs": str(HOME / "scripts/setup_mhs.sh"),
    "test_mhs": str(HOME / "scripts/test_mhs.sh")
}

def require_auth():
    key = request.headers.get("X-API-KEY", "")
    if key != API_KEY:
        return jsonify({"error": "Unauthorized"}), 401

def run_cmd(cmd):
    p = subprocess.run(shlex.quote(cmd), shell=True, capture_output=True, text=True)
    return {"rc": p.returncode, "out": p.stdout, "err": p.stderr}

@APP.route("/run", methods=["POST"])
def run_script():
    require_auth()
    data = request.json or {}
    key = data.get("script")
    if key not in ALLOWED_SCRIPTS:
        return jsonify({"error":"invalid script"}), 400
    script = ALLOWED_SCRIPTS[key]
    if not os.path.exists(script):
        return jsonify({"error":"script not found"}), 404
    return jsonify(run_cmd(script))

if __name__ == "__main__":
    APP.run(host="127.0.0.1", port=5001)
