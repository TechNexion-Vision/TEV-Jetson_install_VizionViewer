#!/bin/sh

echo '' > /dev/ttyTCU0
echo '***********************************' > /dev/ttyTCU0
echo 'Install VizionViewer START' > /dev/ttyTCU0
echo '***********************************' > /dev/ttyTCU0

USER_NAME="ubuntu"
USER_ID=$(id -u $USER_NAME)
BUS_PATH="/run/user/${USER_ID}/bus"
for i in {1..60}; do
    if [ -S "$BUS_PATH" ]; then
        echo "[INFO] Found DBus session at $BUS_PATH" > /dev/ttyTCU0
        break
    fi
    sleep 2
done

if [ ! -S "$BUS_PATH" ]; then
    echo "[ERROR] DBus session not found after 120s." > /dev/ttyTCU0
    exit 1
fi

USER_PATH=$(find /run/user -name bus)
sudo -u ubuntu DISPLAY=$(w| tr -s ' '| cut -d ' ' -f 3|grep :) \
	DBUS_SESSION_BUS_ADDRESS=unix:path=${USER_PATH} \
	gsettings set org.gnome.shell favorite-apps \
	"$(gsettings get org.gnome.shell favorite-apps | sed "s/]$/, 'vizionviewer.desktop']/")"

echo '***********************************' > /dev/ttyTCU0
echo 'Install VizionViewer FINISH!!!' > /dev/ttyTCU0
echo '***********************************' > /dev/ttyTCU0
