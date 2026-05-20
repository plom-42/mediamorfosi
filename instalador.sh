#!/bin/bash
# instalador.sh - Node de Distribucio Autonom
# Configura automaticament un servidor local amb tunel public Ngrok
# Compatible amb Raspberry Pi OS (Debian-based), ARM64

set -e

VERD="[0;32m"
GROC="[1;33m"
VERMELL="[0;31m"
NC="[0m"

echo ""
echo "=================================================="
echo "   NODE DE DISTRIBUCIO AUTONOM - INSTALLADOR"
echo "=================================================="
echo ""

USUARI=root
NGROK_BIN="/usr/local/bin/ngrok"
NGROK_CFG="/home//.config/ngrok/ngrok.yml"

# 1. Actualitzacio del sistema
echo -e "[1/5] Actualitzant el sistema..."
sudo apt-get update -y
sudo apt-get install -y python3 curl
echo -e "    Llest."

# 2. Installacio de Ngrok
echo -e "[2/5] Installant Ngrok..."
if [ -f "" ]; then
    echo "    Ngrok ja esta installat."
else
    curl -sSL https://ngrok-agent.s3.amazonaws.com/ngrok.asc         | sudo tee /etc/apt/trusted.gpg.d/ngrok.asc > /dev/null
    echo "deb https://ngrok-agent.s3.amazonaws.com bookworm main"         | sudo tee /etc/apt/sources.list.d/ngrok.list > /dev/null
    sudo apt-get update -y
    sudo apt-get install -y ngrok
    echo -e "    Ngrok installat."
fi

# 3. Authtoken
echo -e "[3/5] Configurant Ngrok..."
echo ""
echo "    Crea un compte gratuit a: https://ngrok.com"
echo "    Troba el teu Authtoken a:"
echo "    https://dashboard.ngrok.com/get-started/your-authtoken"
echo ""
read -p "    Enganxa el teu Authtoken i prem Enter: " AUTHTOKEN

if [ -z "" ]; then
    echo -e "    Error: cap token introduit. Torna a executar lscript."
    exit 1
fi

mkdir -p "/home//.config/ngrok"
printf "version: "2"
authtoken: %s
" "" > ""
echo -e "    Token configurat."

# 4. Cerca de la carpeta SERVER
echo -e "[4/5] Buscant la carpeta SERVER..."
DIR_SERVER=

if [ -z "" ]; then
    echo -e "    No sha trobat cap carpeta anomenada SERVER."
    echo "    Crea una carpeta anomenada SERVER i torna a executar lscript."
    echo "    Exemple: mkdir ~/SERVER"
    exit 1
fi

echo -e "    Carpeta trobada: "

# 5. Serveis systemd
echo -e "[5/5] Configurant serveis automatics..."

# Servei Python
printf "[Unit]
Description=Node de Distribucio - Servidor
After=network.target

[Service]
WorkingDirectory=%s
ExecStart=python3 -m http.server 8000
Restart=always
RestartSec=5
User=%s

[Install]
WantedBy=multi-user.target
"     "" "" | sudo tee /etc/systemd/system/server.service > /dev/null

# Servei Ngrok
printf "[Unit]
Description=Node de Distribucio - Tunel
After=network-online.target
Wants=network-online.target

[Service]
ExecStartPre=/bin/sleep 15
ExecStart=%s http 8000 --config %s --pooling-enabled
Restart=always
RestartSec=10
User=%s

[Install]
WantedBy=multi-user.target
"     "" "" "" | sudo tee /etc/systemd/system/ngrok.service > /dev/null

sudo systemctl daemon-reload
sudo systemctl enable server.service ngrok.service
sudo systemctl start server.service ngrok.service

sleep 5

echo ""
echo "=================================================="
echo -e "   INSTALLACIO COMPLETADA"
echo "=================================================="
echo ""

sudo systemctl is-active server.service     && echo -e "  OK  Servidor  ->  actiu (port 8000)"     || echo -e "  ERR Servidor  ->  error"

sudo systemctl is-active ngrok.service     && echo -e "  OK  Tunel     ->  actiu"     || echo -e "  ERR Tunel     ->  error"

echo ""
echo "  Proxims passos:"
echo "  1. Obre https://dashboard.ngrok.com"
echo "  2. A Endpoints trobaras la teva URL publica."
echo "  3. Enganxa la URL al teu sistema NFC o comparteix-la."
echo ""
echo "  El servidor sera accesible des de qualsevol lloc"
echo "  automaticament cada vegada que encenguis la Pi."
echo ""
echo "  Carpeta del servidor: "
echo "  Posa els teus fitxers dins aquesta carpeta."
echo ""
