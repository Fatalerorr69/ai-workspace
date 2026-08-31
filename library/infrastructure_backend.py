from flask import Flask, render_template, request, redirect
import subprocess

app = Flask(__name__)

@app.route("/")
def index():
    return render_template("nodes.html", nodes=get_nodes())

@app.route("/nodes")
def nodes():
    return render_template("nodes.html", nodes=get_nodes())

@app.route("/pods")
def pods():
    return render_template("pods.html", pods=get_pods())

@app.route("/services")
def services():
    return render_template("services.html", services=get_services())

@app.route("/logs", methods=["GET", "POST"])
def logs():
    output = ""
    if request.method == "POST":
        pod = request.form.get("pod")
        output = subprocess.getoutput(f"kubectl logs {pod}")
    return render_template("logs.html", output=output)

@app.route("/scale", methods=["POST"])
def scale():
    appname = request.form.get("appname")
    replicas = request.form.get("replicas")
    subprocess.call(["kubectl", "scale", "deployment", appname, f"--replicas={replicas}"])
    return redirect("/pods")

def get_nodes():
    return subprocess.getoutput("kubectl get nodes -o wide")

def get_pods():
    return subprocess.getoutput("kubectl get pods -A")

def get_services():
    return subprocess.getoutput("kubectl get svc -A")

if __name__ == "__main__":
    app.run(host="0.0.0.0", port=9090)
