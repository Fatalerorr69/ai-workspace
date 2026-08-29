# SOUBOR: ~/genesis/tools/genesis_hud.py
# INTEGROVANÁ VERZE 9.0 - OMNI-CONSOLE
import dash
import dash_bootstrap_components as dbc
from dash import dcc, html, Input, Output, State
import psutil, os, subprocess, socket

app = dash.Dash(__name__, external_stylesheets=[dbc.themes.CYBORG])

app.layout = dbc.Container([
    html.H1("🌌 GENESIS AETERNA: OMNI-CONSOLE v9.0", className="text-center text-success my-4"),
    
    dbc.Row([
        # PANEL SEKTORŮ (Levý)
        dbc.Col([
            dbc.Card([
                dbc.CardHeader("SECTOR COMMAND"),
                dbc.CardBody([
                    dbc.Button("S07: TELEGRAM BOT", id="btn-s07", color="info", className="mb-2 w-100"),
                    dbc.Button("S08: ANDROID LAB", id="btn-s08", color="warning", className="mb-2 w-100"),
                    dbc.Button("S09: NET-WATCHER", id="btn-s09", color="danger", className="mb-2 w-100"),
                    dbc.Button("S11: DARK-WAVE", id="btn-s11", color="secondary", className="mb-2 w-100"),
                ])
            ], className="mb-4")
        ], width=3),

        # MONITORING A GRAFY (Střed)
        dbc.Col([
            dbc.Card([
                dbc.CardHeader("SYSTEM ANALYTICS"),
                dbc.CardBody([
                    html.H4(id="live-stats", className="text-center"),
                    dcc.Interval(id="tick", interval=2000),
                    # Zde může být později dcc.Graph pro historii teploty
                ])
            ])
        ], width=6),

        # AI ANALÝZA A TERMINÁL (Pravý)
        dbc.Col([
            dbc.Card([
                dbc.CardHeader("AI SENTINEL (S10)"),
                dbc.CardBody([
                    dbc.Button("ANALYZE SYSTEM LOGS", id="btn-s10", color="success", className="mb-2 w-100"),
                    html.Pre(id="terminal-view", style={"height":"300px", "overflow":"auto", "background":"black", "color":"#00FF00", "font-size":"12px"})
                ])
            ])
        ], width=3),
    ]),
], fluid=True)

# LOGIKA OVLÁDÁNÍ
@app.callback(
    [Output("live-stats", "children"), Output("terminal-view", "children")],
    [Input("tick", "n_intervals"), 
     Input("btn-s07", "n_clicks"), Input("btn-s08", "n_clicks"), 
     Input("btn-s09", "n_clicks"), Input("btn-s10", "n_clicks")]
)
def update_console(n, s07, s08, s09, s10):
    ctx = dash.callback_context
    triggered_id = ctx.triggered[0]['prop_id'].split('.')[0] if ctx.triggered else ""
    
    # Základní metriky [cite: 19, 20]
    cpu = psutil.cpu_percent()
    ram = psutil.virtual_memory().percent
    with open("/sys/class/thermal/thermal_zone0/temp", "r") as f:
        temp = int(f.read()) / 1000
    
    msg = "Standby: Waiting for command..."
    
    if triggered_id == "btn-s08":
        subprocess.Popen(["/home/$USER/genesis/tools/android_dump.sh"])
        msg = ">>> S08: Android Forensic Dump initiated..."
    elif triggered_id == "btn-s09":
        subprocess.Popen(["/home/$USER/genesis/tools/net_audit.sh"])
        msg = ">>> S09: Advanced Network Scan running..."
    elif triggered_id == "btn-s10":
        msg = ">>> S10: AI Sentinel analyzing logs for self-healing..."

    return f"CPU: {cpu}% | RAM: {ram}% | TEMP: {temp:.1f}°C", msg

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=8050)
