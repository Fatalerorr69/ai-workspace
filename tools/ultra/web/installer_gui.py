from flask import Flask, render_template, request, jsonify
import subprocess, threading

app = Flask(__name__, template_folder='templates')

LOG_FILE = "logs/install_gui.log"

def run_module(module):
    with open(LOG_FILE, "a") as f:
        f.write(f"--- Instalace {module} ---\n")
    subprocess.call(["bash", f"modules/{module}/{module}_install.sh"], stdout=open(LOG_FILE, "a"), stderr=open(LOG_FILE, "a"))

@app.route("/")
def index():
    return render_template("index.html")

@app.route("/install/<module>")
def install(module):
    thread = threading.Thread(target=run_module, args=(module,))
    thread.start()
    return jsonify({"status": "running", "module": module})

@app.route("/log")
def log():
    try:
        with open(LOG_FILE) as f:
            return f.read()
    except:
        return ""
