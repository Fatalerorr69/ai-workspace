#!/bin/bash
# GENESIS AETERNA - SEKTOR 07: MOBILE COMMAND
G='\033[0;32m'; B='\033[0;34m'; NC='\033[0m'

echo -e "${B}--- AKTIVACE SEKTORU 07: MOBILE COMMAND ---${NC}"

# Instalace Python knihovny pro Telegram
pip3 install python-telegram-bot --break-system-packages

# Vytvoření Python Control Bota
cat > ~/genesis/tools/genesis_bot.py <<EOF
import telebot
import os
import subprocess

TOKEN = "TVUJ_BOT_TOKEN" # <--- SEM VLOŽ TOKEN
bot = telebot.TeleBot(TOKEN)

@bot.message_handler(commands=['status'])
def send_status(message):
    cpu = os.popen("top -n1 | grep 'Cpu(s)'").read()
    temp = os.popen("vcgencmd measure_temp").read()
    bot.reply_to(message, f"📊 GENESIS STATUS:\n{temp}\n{cpu}")

@bot.message_handler(commands=['scan'])
def run_scan(message):
    bot.reply_to(message, "🔍 Spouštím síťový sken Sektoru 09...")
    subprocess.run(["/home/\$USER/genesis/tools/net_audit.sh"])
    bot.send_message(message.chat.id, "✅ Sken dokončen. Výsledek uložen v logách.")

@bot.message_handler(commands=['reboot'])
def reboot_sys(message):
    bot.reply_to(message, "⚠️ Restartuji Genesis Core...")
    os.system("sudo reboot")

bot.polling()
EOF

# Vytvoření Systemd služby pro Bota
sudo bash -c "cat > /etc/systemd/system/genesis_bot.service <<EOF
[Unit]
Description=Genesis Telegram Bot
After=network.target
[Service]
ExecStart=/usr/bin/python3 /home/$USER/genesis/tools/genesis_bot.py
Restart=always
User=$USER
[Install]
WantedBy=multi-user.target
EOF"

sudo systemctl daemon-reload && sudo systemctl enable genesis_bot.service
echo -e "${G}Sektor 07 ONLINE: Telegram Bot je připraven na povely /status, /scan a /reboot.${NC}"
