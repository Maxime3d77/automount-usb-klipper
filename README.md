### Automount USB drives with systemd

_This is a dirty solution; but works. A good approach would be to use 
__libudev__._

Mount point is /home/pi/printer_data/gcodes/USB

## Install
```
git clone https://github.com/Maxime3d77/automount-usb-klipper.git
cd automount-usb-klipper/
sudo ./CONFIGURE.sh
```

## Unintall
```
sudo ./REMOVE.sh
```

On inserting an USB drive, automounts the drive at /media/ as a
directory named by device label; just the device name if label is
empty: /media/usbtest, /media/sdd

Tracks the list of mounted drives in /var/log/usb-mount.track.

Logs the actions in /var/log/messages with tag 'usb-mount.sh'
```
cat /var/log/messages | grep usb-mount.sh
```

Please do not expect it to perfectly handle all your needs.
Be warned, minimally tested; okay for temporary plug-ins but certainly
not recommended for enclosures with longer TTL.

**To setup, run `CONFIGURE.sh` with sudo or as root; `REMOVE.sh` to undo the
setup.**
