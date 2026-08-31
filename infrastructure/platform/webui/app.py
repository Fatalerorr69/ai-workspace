from flask import Flask, render_template, request, redirect, session, jsonify
import psutil
import subprocess
import json
import os

app = Flask(__name__)
app.secret_key = "platform-secret-key"

CONFIG_PATH = "/opt/platform/config.json"

with open(CONFIG_PATH) as f:
    config = json.load(f)

WEB_USER = config["webui"]["user"]
WEB_PASS = config["webui"]["password"]

@app.route("/", methods=["GET", "POST"])
def login():
    if request.method == "POST":
        user = request.form.get("user")
        password = request.form.get("password")

        if user == WEB_USER and password == WEB_PASS:
            session["auth"] = True
            return redirect("/dashboard")
        else:
            return render_template("login.html", error="Neplatné přihlašovací údaje")

    return render_template("login.html")

@app.route("/dashboard")
def dashboard():
    if not session.get("auth"):
        return redirect("/")

    return render_template("index.html")

@app.route("/services")
def services():
    if not session.get("auth"):
        return redirect("/")

    services = subprocess.getoutput("systemctl --type=service --state=running")
    return render_template("services.html", services=services)

@app.route("/api/stats")
def api_stats():
    data = {
        "cpu": psutil.cpu_percent(interval=1),
        "ram": psutil.virtual_memory().percent,
        "disk": psutil.disk_usage("/").percent,
        "uptime": subprocess.getoutput("uptime -p")
    }
    return jsonify(data)

@app.route("/api/backup")
def api_backup():
    if not session.get("auth"):
        return "Unauthorized", 401

    subprocess.Popen(["/opt/platform/modules/backup.sh"])
    return "Backup started"

@app.route("/logout")
def logout():
    session.pop("auth", None)
    return redirect("/")

if __name__ == "__main__":
    port = config["webui"]["port"]
    app.run(host="0.0.0.0", port=port)
