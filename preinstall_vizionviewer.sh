#!/bin/bash

VIZION_DEB_DIR="/usr/share/vizionviewer"
VIZION_SDK_DEB="vizionsdk.deb"
VIZION_VIEWER_DEB="vizionviewer.deb"
DEMO_BIN="TechNexion_8_Cam_Demo"

error_exit() {
    echo "ERROR: $1" >&2
    cleanup_chroot_env
    exit 1
}

prepare_chroot_env() {
    echo "--- Prepare the chroot environment (mount virtual filesystems) ---"
    mount -t proc /proc "${ROOTFS_PATH}/proc" || error_exit "Failed to mount proc."
    mount -t sysfs /sys "${ROOTFS_PATH}/sys" || error_exit "Failed to mount sys."
    mount -o bind /dev "${ROOTFS_PATH}/dev" || error_exit "Failed to mount dev."
    mount -o bind /dev/pts "${ROOTFS_PATH}/dev/pts" || error_exit "Failed to mount dev/pts."
}

cleanup_chroot_env() {
    echo "--- clean chroot env (unmount virtual filesystems) ---"
    # check first, for avoid umount error
    umount -l "${ROOTFS_PATH}/dev/pts" 2>/dev/null
    umount -l "${ROOTFS_PATH}/dev" 2>/dev/null
    umount -l "${ROOTFS_PATH}/sys" 2>/dev/null
    umount -l "${ROOTFS_PATH}/proc" 2>/dev/null
    echo "--- clean done ---"
}

#########################
# Main function
#########################
echo "--- Starting installation of VizionViewer packages into rootfs ---"

# Check if running with root
if [ "$EUID" -ne 0 ]; then
    echo "Please run this script with sudo."
    exit 1
fi

skip_demo=0
while getopts ":-:" o; do
	case "${o}" in
	-) case ${OPTARG} in
		skip-demo)
			skip_demo=1
			;;
		*) usage allunknown 1; ;;
		esac;;
        *)
		usage
		;;
	esac
done
shift $((OPTIND-1))

# Set rootfs path
LDK_DIR=$(cd "$(dirname "$0")" && pwd);
LDK_DIR="${LDK_DIR}/Linux_for_Tegra"
ROOTFS_PATH="./rootfs"
DPKG_STATUS="./rootfs/var/lib/dpkg/status"
if [[ ${skip_demo} -eq 0 ]]; then
    DM_FILE=$(basename $(ls ${LDK_DIR}/${ROOTFS_PATH}/jetpack_8_cam_demo_patch_for_*.tar.xz))
fi

cd ${LDK_DIR}
# Check if rootfs directory exists
if [ ! -d "$ROOTFS_PATH" ]; then
    error_exit "The rootfs directory does not exist. Please ensure you are running this script from the Linux_for_Tegra/ directory."
fi

# check VizionViewer DEB files
if [ ! -f "${ROOTFS_PATH}${VIZION_DEB_DIR}/${VIZION_SDK_DEB}" ] || \
   [ ! -f "${ROOTFS_PATH}${VIZION_DEB_DIR}/${VIZION_VIEWER_DEB}" ]; then
    error_exit "Could not find VizionSDK or VizionViewer .deb files.\nPlease ensure they are located in ${ROOTFS_PATH}${VIZION_DEB_DIR}/"
fi

# check if VizionViewer is intalled or not
VV_ins=$(grep "Package: vizionviewer" -A1 ${DPKG_STATUS} | grep "install ok installed")
VS_ins=$(grep "Package: vizionsdk" -A1 ${DPKG_STATUS} | grep "install ok installed")
if [[ ${skip_demo} -eq 0 ]]; then
    DM_bin=$(ls ${ROOTFS_PATH}/opt/vizionviewer/bin | grep ${DEMO_BIN})
    if [ -n "${VV_ins}" ] && [ -n "$VS_ins" ] && [ -n "$DM_bin" ]; then
        echo "VizionViewer had installed. Exiting install process."
        exit 0
    fi
else
    if [ -n "${VV_ins}" ] && [ -n "$VS_ins" ]; then
        echo "VizionViewer had installed. Exiting install process."
        exit 0
    fi
fi

# Prepare the chroot environment (mount virtual filesystems)
prepare_chroot_env

# Install .deb files within the chroot environment
echo "--- Ready to enter chroot ---"
chroot "${ROOTFS_PATH}" /bin/bash -c "
    echo '--- Inside chroot: Updating APT package lists ---'
    apt update

    echo '--- Inside chroot: Installing additional packages ---'
    apt install -y libxcb-cursor0 || exit 1
    apt install -y libxcb-xinput0 || exit 1
    apt install -y libv4l2rds0 || exit 1
    apt install -y v4l-utils || exit 1
    apt install -y nvidia-l4t-gstreamer || exit 1

    echo '--- Inside chroot: Installing ${VIZION_SDK_DEB} ---'
    cd ${VIZION_DEB_DIR} || exit 1
    apt install -y ./${VIZION_SDK_DEB} || exit 1

    echo '--- Inside chroot: Installing ${VIZION_VIEWER_DEB} ---'
    apt install -y ./${VIZION_VIEWER_DEB} || exit 1

    #echo '--- Inside chroot: Cleaning APT cache ---'
    #apt clean

    echo '--- Inside chroot: Removing .deb files ---'
    rm ${VIZION_SDK_DEB} ${VIZION_VIEWER_DEB}

    if [[ ${skip_demo} -eq 0 ]]; then
        echo '--- Moving TechNexion_8_Cam_Demo into rootfs ---'
        cd /
        tar -xf ${DM_FILE} || exit 1
        sed -i 's|cp|mv|g' install_8_cam_demo.sh
        ./install_8_cam_demo.sh 2>/dev/null || exit 1
        mv install_8_cam_demo.sh /opt/vizionviewer/
    fi

    echo '--- Inside chroot: Package installation complete ---'
" || error_exit "Chroot internal installation script failed."

# Clean up the chroot env (unmount)
cleanup_chroot_env

echo "--- Ending installation of VizionViewer packages into rootfs ---"