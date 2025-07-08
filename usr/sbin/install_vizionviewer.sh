#!/bin/sh

echo '' > /dev/ttyTCU0
echo '***********************************' > /dev/ttyTCU0
echo 'Install VizionViewer START' > /dev/ttyTCU0
echo '***********************************' > /dev/ttyTCU0

USER_PATH=$(find /run/user -name bus)
sudo -u ubuntu DISPLAY=$(w| tr -s ' '| cut -d ' ' -f 3|grep :) \
	DBUS_SESSION_BUS_ADDRESS=unix:path=${USER_PATH} \
	gsettings set org.gnome.shell favorite-apps \
	"[ 'vizionviewer.desktop', $(gsettings get org.gnome.shell favorite-apps | sed s/.//)"

echo '***********************************' > /dev/ttyTCU0
echo 'Install VizionViewer FINISH!!!' > /dev/ttyTCU0
echo '***********************************' > /dev/ttyTCU0
