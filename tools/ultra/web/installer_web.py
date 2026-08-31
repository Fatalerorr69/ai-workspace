from flask import Flask, render_template
import threading

app = Flask(__name__)

@app.route('/')
def index():
    return render_template("index.html")

def run_app():
    app.run(host="0.0.0.0", port=8080)

threading.Thread(target=run_app, daemon=True).start()
