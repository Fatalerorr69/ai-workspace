\# SOUBOR: genesis\_hud\_v10.py  
\# CÍL: Univerzální HUD pro Windows/Linux/RPi  
import dash  
import dash\_bootstrap\_components as dbc  
from dash import dcc, html, Input, Output  
import psutil  
import platform  
import socket  
import os

\# Inicializace aplikace s tmavým tématem  
app \= dash.Dash(\_\_name\_\_, external\_stylesheets=\[dbc.themes.CYBORG\])

def get\_ip():  
    try:  
        s \= socket.socket(socket.AF\_INET, socket.SOCK\_DGRAM)  
        s.connect(("8.8.8.8", 80))  
        ip \= s.getsockname()\[0\]  
        s.close()  
        return ip  
    except:  
        return "127.0.0.1"

app.layout \= dbc.Container(\[  
    html.Div(\[  
        html.H1("🌌 GENESIS AETERNA v10.0", className="text-center text-success pt-4"),  
        html.P(f"Environment: {platform.system()} {platform.machine()}", className="text-center text-muted"),  
    \]),

    dbc.Row(\[  
        \# Monitorovací panel  
        dbc.Col(\[  
            dbc.Card(\[  
                dbc.CardHeader("SYSTÉMOVÉ METRIKY"),  
                dbc.CardBody(\[  
                    html.Div(id="live-metrics"),  
                    dcc.Interval(id="metric-tick", interval=2000)  
                \])  
            \])  
        \], width=4),

        \# Ovládací centrum  
        dbc.Col(\[  
            dbc.Card(\[  
                dbc.CardHeader("CENTRÁLNÍ OPERACE"),  
                dbc.CardBody(\[  
                    dbc.Button("START AI AGENTS", id="btn-ai", color="success", className="m-1 w-100"),  
                    dbc.Button("SECURITY SCAN", id="btn-sec", color="danger", className="m-1 w-100"),  
                    dbc.Button("VAULT BACKUP", id="btn-vault", color="info", className="m-1 w-100"),  
                \])  
            \])  
        \], width=8),  
    \], className="mt-4"),

    dbc.Row(\[  
        dbc.Col(\[  
            html.Div(id="terminal-output", style={  
                "background": "black",   
                "color": "\#00FF00",   
                "padding": "15px",   
                "borderRadius": "5px",  
                "height": "300px",  
                "overflowY": "scroll",  
                "fontFamily": "monospace",  
                "marginTop": "20px"  
            }, children="\[SYSTEM\] Inicializace Genesis v10.0 dokončena...")  
        \])  
    \])  
\], fluid=True)

@app.callback(  
    Output("live-metrics", "children"),  
    Input("metric-tick", "n\_intervals")  
)  
def update\_metrics(n):  
    cpu \= psutil.cpu\_percent()  
    ram \= psutil.virtual\_memory().percent  
    ip \= get\_ip()  
    return html.Ul(\[  
        html.Li(f"CPU LOAD: {cpu}%"),  
        html.Li(f"RAM USAGE: {ram}%"),  
        html.Li(f"LOCAL IP: {ip}")  
    \])

if \_\_name\_\_ \== "\_\_main\_\_":  
    app.run\_server(host="0.0.0.0", port=8050)  
