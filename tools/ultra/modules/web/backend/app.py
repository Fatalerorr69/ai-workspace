from flask import Flask, jsonify, render_template, Response, request, redirect, session
import psutil
from auth import login_required
from log_stream import stream_logs
from api_install import install_api
from api_ai import ai_api
from api_plugins import plugin_api


app = Flask(__name__, static_folder="../frontend", template_folder="../frontend")
app.secret_key = "ultra-secret-key"
app.register_blueprint(install_api, url_prefix="/api/install")
app.register_blueprint(ai_api, url_prefix="/api/ai")
app.register_blueprint(plugin_api, url_prefix="/api/plugins")

@app.route("/")
def index():
    return {"status": "ULTRA backend running"}


@app.route("/login", methods=["GET", "POST"])
def login():
    if request.method == "POST":
        if request.form.get("password") == "ultra123":
            session["auth"] = True
            return redirect("/")
    return render_template("login.html")


from auth import token_required, generate_token

@app.route("/api/login", methods=["POST"])
def api_login():
    if request.json.get("password") == "ultra123":
        return jsonify({"token": generate_token()})
    return jsonify({"error":"auth failed"}), 403

@app.route("/api/system")
@token_required
def system():
    ...


@app.route("/api/ai")
@login_required
def ai_recommendations():
    try:
        with open("../ai/ultra_ai.log", "r") as f:
            content = f.read()
        return Response(content, mimetype="text/plain")
    except FileNotFoundError:
        return "AI log neexistuje", 404


@app.route("/api/plugins/market")
@token_required
def plugin_market():
    with open("../plugins/marketplace/index.json") as f:
        return jsonify(json.load(f))


@app.route("/")
@login_required
def index():
    return render_template("index.html")

@app.route("/api/system")
@login_required
def system():
    return jsonify({
        "cpu": psutil.cpu_percent(),
        "ram": psutil.virtual_memory().percent,
        "disk": psutil.disk_usage("/").percent
    })

@app.route("/api/logs")
@login_required
def logs():
    return Response(stream_logs(), mimetype="text/event-stream")

app.run(host="0.0.0.0", port=8080, threaded=True)
