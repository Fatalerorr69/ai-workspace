import tkinter as tk
from tkinter import scrolledtext

root = tk.Tk()
root.title("ULTRA Installer GUI")
root.geometry("600x400")

txt = scrolledtext.ScrolledText(root, width=80, height=20)
txt.pack()

txt.insert(tk.END, "ULTRA Installer spuštěn...\n")
txt.insert(tk.END, "Sleduji průběh instalace...\n")

root.mainloop()
