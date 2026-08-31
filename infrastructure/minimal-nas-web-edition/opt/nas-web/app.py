from flask import Flask, render_template
import subprocess
import psutil

app = Flask(__name__)

def cmd(c):
    return subprocess.getoutput(c)

@app.route("/")
def index():
    data = {
        "hostname": cmd("hostname"),
        "uptime": cmd("uptime -p"),
        "disk": cmd("zpool list"),
        "datasets": cmd("zfs list"),
        "memory": psutil.virtual_memory().percent,
        "cpu": psutil.cpu_percent(interval=1),
        "services": {
            "samba": cmd("systemctl is-active smbd"),
            "nfs": cmd("systemctl is-active nfs-server"),
            "iscsi": cmd("systemctl is-active target"),
        }
    }
    return render_template("index.html", data=data)

app.run(host="0.0.0.0", port=8080)
