from flask import Flask, render_template
from api import system, storage, shares, users, snapshots, services

app = Flask(__name__)
app.secret_key = "CHANGE_ME"

@app.route("/")
def dashboard():
    return render_template("dashboard.html", data=system.status())

@app.route("/storage")
def storage_page():
    return render_template("storage.html", pools=storage.pools())

@app.route("/shares")
def shares_page():
    return render_template("shares.html", shares=shares.list())

@app.route("/users")
def users_page():
    return render_template("users.html", users=users.list())

@app.route("/services")
def services_page():
    return render_template("services.html", services=services.status())

@app.route("/snapshots")
def snapshots_page():
    return render_template("snapshots.html", snaps=snapshots.list())

app.run(host="0.0.0.0", port=8443)
