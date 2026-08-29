#!/usr/bin/env python3
import gi, requests, json, os
gi.require_version("Gtk", "3.0")
from gi.repository import Gtk

API = "http://127.0.0.1:5001"
API_KEY = os.environ.get("TWISTER_API_KEY", "changeme_replace_now")

def call(api_path, method="GET", body=None):
    headers = {"X-API-KEY": API_KEY}
    try:
        if method=="GET":
            r = requests.get(API+api_path, headers=headers, timeout=10)
        else:
            r = requests.post(API+api_path, json=body, headers=headers, timeout=60)
        return r.json()
    except Exception as e:
        return {"error": str(e)}

class MainWin(Gtk.Window):
    def __init__(self):
        Gtk.Window.__init__(self, title="Twister Smart Control")
        self.set_default_size(700, 420)
        box = Gtk.Box(orientation=Gtk.Orientation.VERTICAL, spacing=6, margin=10)
        self.add(box)

        hb = Gtk.Box(spacing=6)
        btn_refresh = Gtk.Button(label="Aktualizovat stav")
        btn_refresh.connect("clicked", self.on_status)
        hb.pack_start(btn_refresh, False, False, 0)
        box.pack_start(hb, False, False, 0)

        self.text = Gtk.TextView()
        self.text.set_editable(False)
        box.pack_start(self.text, True, True, 0)

        grid = Gtk.Grid(column_spacing=10, row_spacing=6)
        box.pack_start(grid, False, False, 0)

        btn_retro = Gtk.Button(label="Spustit RetroArch")
        btn_retro.connect("clicked", lambda w: self.run_script("retroarch"))
        grid.attach(btn_retro, 0, 0, 1, 1)

        btn_wine = Gtk.Button(label="Spustit Wine hru")
        btn_wine.connect("clicked", lambda w: self.run_script("wine_game"))
        grid.attach(btn_wine, 1, 0, 1, 1)

        btn_nas = Gtk.Button(label="Připojit NAS")
        btn_nas.connect("clicked", lambda w: self.run_script("mount_nas"))
        grid.attach(btn_nas, 2, 0, 1, 1)

        self.on_status(None)

    def append(self, text):
        buf = self.text.get_buffer()
        buf.set_text(str(text))

    def on_status(self, widget):
        r = call("/run", "POST", {"script": "mount_nas"})
        self.append(json.dumps(r, indent=2))

    def run_script(self, key):
        r = call("/run", "POST", {"script": key})
        self.append(json.dumps(r, indent=2))

def main():
    win = MainWin()
    win.connect("destroy", Gtk.main_quit)
    win.show_all()
    Gtk.main()

if __name__=="__main__":
    main()
