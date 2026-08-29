from flask import Blueprint, request
import subprocess

install_api = Blueprint("install", __name__)

@install_api.route("/run", methods=["POST"])
def run_install():
    profile = request.json.get("profile", "core")
    subprocess.Popen(
        ["bash", "install.sh", profile],
        cwd=".."
    )
    return {"status": "install started", "profile": profile}
