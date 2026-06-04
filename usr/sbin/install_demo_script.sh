#!/bin/bash

TEK_ORIN=$(cat /proc/device-tree/nvidia,dtsfilename | rev | cut -d '/' -f 1 | rev | grep "tek-orin")
TN316_ORIN=$(cat /proc/device-tree/nvidia,dtsfilename | rev | cut -d '/' -f 1 | rev | grep "vl316")
DEMO_BIN="/opt/vizionviewer/bin/TechNexion_8_Cam_Demo"

if [[ (-z ${TEK_ORIN} && -z ${TN316_ORIN}) || ! -e ${DEMO_BIN} ]];then
	logger -t 8cam-demo '==================================='
	logger -t 8cam-demo 'This board have no 8 camera demo app.'
	logger -t 8cam-demo '==================================='
	exit 0
fi

echo '***********************************' > /dev/ttyTCU0
echo 'Install Demo Script START!!!' > /dev/ttyTCU0
echo '***********************************' > /dev/ttyTCU0

AUTOSSTART_FILE_PATH="/home/ubuntu/.config/autostart/setup_technexion_8_cam_demo.desktop"
DEMO_SCRIPT='/home/ubuntu/Desktop/TechNexion_8_Cam_Demo.desktop'
cp -rv /usr/share/applications/TechNexion_8_Cam_Demo.desktop ${DEMO_SCRIPT}

chmod a+x ${DEMO_SCRIPT}
gio set ${DEMO_SCRIPT} metadata::trusted true

if [ -f "$AUTOSSTART_FILE_PATH" ]; then
    rm -f "$AUTOSSTART_FILE_PATH"
fi

echo '***********************************' > /dev/ttyTCU0
echo 'Install Demo Script FINISH!!!' > /dev/ttyTCU0
echo '***********************************' > /dev/ttyTCU0
