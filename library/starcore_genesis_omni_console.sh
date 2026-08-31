#!/bin/bash
# GENESIS AETERNA - OMNI-CONSOLE v9.0
G='\033[0;32m'; B='\033[0;34m'; NC='\033[0m'

echo -e "${B}--- AKTIVACE CENTRÁLNÍ OMNI-CONSOLE v9.0 ---${NC}"

cat > ~/genesis/tools/genesis_hud.py <<EOF
import dash
import dash_bootstrap_components as dbc
from dash import dcc, html, Input, Output, State
import psutil, os, subprocess

app = dash.Dash(__name__, external_stylesheets=[dbc.themes.CYBORG])

app.layout = dbc.Container([
    html.H1("🌌 GENESIS AETERNA: OMNI-CONSOLE", className="text-center text-success my-4"),
    
    dbc.Row([
        # SEKTOR PANEL - LEVÝ
        dbc.Col([
            dbc.Card([
                dbc.CardHeader("CORE COMMAND"),
                dbc.CardBody([
                    dbc.Button("S07: TELEGRAM BOT", id="btn-s07", color="info", className="mb-2 w-100"),
                    dbc.Button("S08: ANDROID DUMP", id="btn-s08", color="warning", className="mb-2 w-100"),
                    dbc.Button("S09: NETWORK SCAN", id="btn-s09", color="danger", className="mb-2 w-100"),
                    dbc.Button("S11: PROXY/TOR", id="btn-s11", color="secondary", className="mb-2 w-100"),
                ])
            ])
        ], width=3),

        # MONITORING PANEL - STŘED
        dbc.Col([
            dbc.Card([
                dbc.CardHeader("LIVE ANALYTICS"),
                dbc.CardBody([
                    html.Div(id="stats-display"),
                    dcc.Graph(id='live-graph', config={'displayModeBar': False})
                ])
            ])
        ], width=6),

        # AI & LOGS PANEL - PRAVÝ
        dbc.Col([
            dbc.Card([
                dbc.CardHeader("AI SENTINEL & LOGS"),
                dbc.CardBody([
                    dbc.Button("S10: AI ANALYZE LOGS", id="btn-s10", color="success", className="mb-2 w-100"),
                    html.Pre(id="terminal-output", style={"height":"300px", "overflow":"auto", "background":"black", "color":"#00FF00"})
                ])
            ])
        ], width=3),
    ]),
    dcc.Interval(id="update", interval=2000)
], fluid=True)

@app.callback(
    [Output("stats-display", "children"), Output("terminal-output", "children")],
    [Input("update", "n_intervals"), Input("btn-s07", "n_clicks"), Input("btn-s08", "n_clicks"), Input("btn-s09", "n_clicks"), Input("btn-s10", "n_clicks")]
)
def handle_commands(n, s07, s08, s09, s10):
    ctx = dash.callback_context
    triggered = ctx.triggered[0]['prop_id'].split('.')[0] if ctx.triggered else ""
    
    out = "System Ready..."
    if triggered == "btn-s08":
        subprocess.Popen(["/home/\$USER/genesis/tools/android_dump.sh"])
        out = "Android Forensic Dump started..."
    elif triggered == "btn-s09":
        subprocess.Popen(["/home/\$USER/genesis/tools/net_audit.sh"])
        out = "Network Audit initiated..."
        
    stats = f"CPU: {psutil.cpu_percent()}% | RAM: {psutil.virtual_memory().percent}%"
    return stats, out

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=8050)
EOF

sudo systemctl restart genesis_hud.service
echo -e "${G}Omni-Console byla nasazena na portu 8050.${NC}"
