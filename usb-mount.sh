#!/usr/bin/env bash
# This script is based on https://serverfault.com/a/767079 posted
# by Mike Blackwell, modified to our needs. Credits to the author.

PATH="$PATH:/usr/bin:/usr/local/bin:/usr/sbin:/usr/local/sbin:/bin:/sbin"
log="logger -t usb-mount.sh -s"

usage() {
    ${log} "Usage: $0 {add|remove} device_name (e.g. sda1)"
    exit 1
}

if [[ $# -ne 2 ]]; then
    usage
fi

ACTION=$1
DEVBASE=$2
DEVICE="/dev/${DEVBASE}"

# Get the mount point based on the device name
MOUNT_POINT="/home/pi/printer_data/gcodes/USB"

do_mount() {
    if mount | grep -q "${DEVICE}"; then
        ${log} "Warning: ${DEVICE} is already mounted"
        exit 1
    fi

    # Create a mount point if necessary
    mkdir -p ${MOUNT_POINT}

    # Mount options (for vfat filesystems, adjust as needed for others)
    OPTS="rw,relatime"
    eval $(blkid -o udev ${DEVICE} | grep -i -e "ID_FS_LABEL" -e "ID_FS_TYPE")
    if [[ ${ID_FS_TYPE} == "vfat" ]]; then
        OPTS+=",users,gid=100,umask=000,shortname=mixed,utf8=1,flush"
    fi

    # Mount the device
    if ! mount -o ${OPTS} ${DEVICE} ${MOUNT_POINT}; then
        ${log} "Error mounting ${DEVICE} (status = $?)"
        rmdir "${MOUNT_POINT}"
        exit 1
    else
        echo "${MOUNT_POINT}:${DEVBASE}" | cat >> "/var/log/usb-mount.track"
        ${log} "Mounted ${DEVICE} at ${MOUNT_POINT}"
    fi
}

do_unmount() {
    if mount | grep -q "${DEVICE}"; then
        umount ${DEVICE}
        ${log} "Unmounted ${DEVICE} from ${MOUNT_POINT}"
        /bin/rmdir ${MOUNT_POINT}
        sed -i.bak "\@${MOUNT_POINT}@d" /var/log/usb-mount.track
    else
        ${log} "Warning: ${DEVICE} is not mounted"
    fi
}

case "${ACTION}" in
    add)
        do_mount
        ;;
    remove)
        do_unmount
        ;;
    *)
        usage
        ;;
esac
