from flask import Flask, jsonify
import psutil

app = Flask(__name__)

@app.route("/api/system")
def system():
    return jsonify({
        "cpu": psutil.cpu_percent(),
        "ram": psutil.virtual_memory().percent,
        "disk": psutil.disk_usage("/").percent
    })

app.run(host="0.0.0.0", port=8080)
