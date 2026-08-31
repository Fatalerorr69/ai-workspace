from flask import Flask, render_template, jsonify, request
import subprocess, threading, queue

app = Flask(__name__)
log_queue = queue.Queue()

modules = ["ai", "android", "web", "pentest", "pwa"]
install_status = {m: "pending" for m in modules}

def run_install(module):
    install_status[module] = "running"
    try:
        subprocess.run(["bash", f"modules/{module}/{module}_install.sh"], check=True)
        install_status[module] = "done"
        log_queue.put(f"[{module}] Instalace dokončena")
    except subprocess.CalledProcessError:
        install_status[module] = "failed"
        log_queue.put(f"[{module}] Chyba při instalaci")

@app.route("/")
def index():
    return render_template("index.html", modules=modules, status=install_status)

@app.route("/install/<module>", methods=["POST"])
def install_module(module):
    if module in modules:
        threading.Thread(target=run_install, args=(module,), daemon=True).start()
        return jsonify({"status": "started"})
    return jsonify({"status": "unknown module"}), 400

@app.route("/logs")
def get_logs():
    logs = []
    while not log_queue.empty():
        logs.append(log_queue.get())
    return jsonify(logs)
    
if __name__ == "__main__":
    app.run(host="0.0.0.0", port=8080)
