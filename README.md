# Debian_kindle
Debian on kindle
Debian Linux on Kindle Paperwhite 4

This is beta! Use at your own risk!

ill update packages and update kual when im done

Here you find a set of utilities to get Debian Linux running on Kindle Paperwhite 4. This has only been tested on the Kindle PW4, and while it might work on other Kindle models with touchscreens and sufficient resources (at least 2GB free storage and 512MiB RAM), there’s no guarantee it will function properly.

Note: There are many bugs, and this is very much experimental. There are no separate user accounts — everything runs as root. The window manager used is IceWM, which is lightweight but limited in features.

Overview

Kindle devices run a Linux-based OS with X11 capabilities. This setup utilizes that by running a full Debian environment in a chroot. Your Kindle remains usable for reading books, though launching Debian will use additional system resources.

Quick Start

1. Install KUAL Launcher: the debian kual .zip file

2. extract debian.zip to /mnt/us on kindle

3. Copy conf file (press the button on top)

4. Start Debian from the Launcher



---

!!WARNING!!

DO NOT connect your Kindle to a computer via USB while Debian is running unless USBNetworking is enabled. Debian’s root filesystem resides in /mnt/us, which is also the Kindle's USB storage area. Dual access can corrupt partition 4, possibly bricking the Kindle. Use the KUAL USBNetwork indicator to verify status before connecting.


---

Manual Installation or building for yourself

1. Jailbreak Your Kindle

You must jailbreak your Kindle. This depends on your model and firmware version. Refer to:

MobileRead Forums

MobileRead Wiki


Also install:

KUAL

Kterm for terminal access

USBNetworking for SSH access



---

2. Prepare a Debian Image

Download or create a Debian image:

Use the release from your project or build one using QEMU and debootstrap (i used debootstrap on my android tablet)

Ensure the image is in ext3 format

Final output: debian.ext3

for debian.sh and debian.conf, you might want to use one in the file list.
if you want to launch gui you need to mount to ext3 on kindle and make startgui.sh in order to run



---

3. Transfer to Kindle

Ensure there’s at least 2GB free on /mnt/us:

df -h /mnt/us

Transfer the debian.zip to /mnt/us:

scp -C debian.zip root@192.168.15.244:/mnt/us/

Unzip it on the Kindle:

cd /mnt/us
unzip debian.zip

Then copy debian.conf to the Upstart directory:

mntroot rw
cp /mnt/us/debian.conf /etc/upstart/
mntroot r


---

4. Run Debian

Option 1 – Manual (Good for debugging):
In Kterm:

cd /mnt/us
sh debian.sh

This launches a Debian shell. From here, you can start the IceWM desktop using:

sh startgui.sh

Option 2 – Recommended (More stable):
In Kterm:

start debian

This directly launches the GUI using Upstart.

You can also do either step via SSH if USBNetworking is active.


---

NOTES:

Default user is root (no other users available)

Desktop uses IceWM, which is fast but basic

Tested only on Kindle PW4

There are many bugs; expect crashes and display glitches even in apt install command. Consider asking ChatGPT if error occurs.
(expected errors: dpkg related errors)
If your kindle is bricked or shows error 2 or dosent boot, use ssh to recover
