#!/bin/bash

echo '***********************************' > /dev/ttyTCU0
echo 'Install Demo Script START!!!' > /dev/ttyTCU0
echo '***********************************' > /dev/ttyTCU0

TEK_ORIN=$(cat /proc/device-tree/nvidia,dtsfilename | rev | cut -d '/' -f 1 | rev | grep "tek-orin")
TN316_ORIN=$(cat /proc/device-tree/nvidia,dtsfilename | rev | cut -d '/' -f 1 | rev | grep "vl316")

if [ -z ${TEK_ORIN} ] && [ -z ${TN316_ORIN} ];then
	echo '===================================' > /dev/ttyTCU0
	echo 'This board have no 8 camera demo script.' > /dev/ttyTCU0
	echo '===================================' > /dev/ttyTCU0
	return 0
fi

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
