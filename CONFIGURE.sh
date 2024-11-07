#!/usr/bin/env bash
# If you are executing this script in cron with a restricted environment,
# modify the shebang to specify appropriate path; /bin/bash in most distros.
# And, also if you aren't comfortable using(abuse?) env command.
MOUNT_POINT="/home/pi/printer_data/gcodes/USB"
PATH="$PATH:/usr/bin:/usr/local/bin:/usr/sbin:/usr/local/sbin:/bin:/sbin"
chmod 755 ./*.sh

cp ./usb-mount.sh /usr/local/bin/

# Systemd unit file for USB automount/unmount 
cp ./usb-mount@.service /etc/systemd/system/usb-mount@.service

# Create udev rule to start/stop usb-mount@.service on hotplug/unplug
cat ./99-local.rules.usb-mount >> /etc/udev/rules.d/99-local.rules
sudo chmod +x /usr/local/bin/usb-mount.sh
sudo chmod 644 /etc/systemd/system/usb-mount@.service
sudo chmod 644 /etc/udev/rules.d/99-local.rules


sudo systemctl daemon-reload
sudo udevadm control --reload-rules
sudo udevadm trigger

# Create folder mount point for klipper
if [ ! -d "$MOUNT_POINT" ]; then
    mkdir -p "$MOUNT_POINT"
    if [ $? -eq 0 ]; then
        echo "$(date): Dossier $MOUNT_POINT créé" >> "$LOG_FILE"
        chmod 777 "$MOUNT_POINT"
        sudo chown pi:pi "$MOUNT_POINT"

    else
        echo "$(date): Erreur lors de la création du dossier $MOUNT_POINT" >> "$LOG_FILE"
        exit 1
    fi
fi
