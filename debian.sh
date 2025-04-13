#!/bin/sh

# debian.sh - Launch Debian chroot from extracted files in /mnt/debian/debian-armhf

ALREADYMOUNTED="no"

# Check if /mnt/debian is already mounted
if mount | grep -q "on /mnt/debian "; then
    ALREADYMOUNTED="yes"
    echo "ATTENTION! Debian's rootfs is already mounted; you'll be dropped into it."
    echo "BE CAREFUL: if you exit, no unmount will occur (to avoid disturbing another session)."
else
    echo "Mounting Debian rootfs"
    mkdir -p /mnt/debian

    # Mount the ext3 image from /mnt/us/debian.ext3 onto /mnt/debian
    mount -o loop,noatime -t ext3 /mnt/us/debian.ext3 /mnt/debian
    if [ $? -ne 0 ]; then
        echo "Error: Failed to mount /mnt/us/debian.ext3 on /mnt/debian"
        exit 1
    fi

    # Ensure required directories exist in the chroot before binding
    mkdir -p /mnt/debian/debian-armhf/dev 
    mkdir -p /mnt/debian/debian-armhf/dev/pts 
    mkdir -p /mnt/debian/debian-armhf/proc 
    mkdir -p /mnt/debian/debian-armhf/sys 
    mkdir -p /mnt/debian/debian-armhf/run/dbus 
    mkdir -p /mnt/debian/debian-armhf/etc

    # Bind mount essential filesystems
    mount -o bind /dev /mnt/debian/debian-armhf/dev
    mount -o bind /dev/pts /mnt/debian/debian-armhf/dev/pts
    mount -o bind /proc /mnt/debian/debian-armhf/proc
    mount -o bind /sys /mnt/debian/debian-armhf/sys
    mount -o bind /var/run/dbus/ /mnt/debian/debian-armhf/run/dbus/

    # Copy hosts file for proper networking inside chroot
    cp /etc/hosts /mnt/debian/debian-armhf/etc/hosts

    # Set shared memory permissions if needed
    chmod a+w /dev/shm
fi

echo "You're now being dropped into Debian's shell..."

# Chroot directly to the debian-armhf directory
chroot /mnt/debian/debian-armhf /bin/bash

# After exiting the chroot, perform cleanup if we mounted it here
if [ "$ALREADYMOUNTED" = "yes" ]; then
    echo "Unmount is being skipped, as the rootfs was mounted already. You're now back at your device's shell."
else
    echo "You returned from Debian, cleaning up and unmounting..."
    # (Optional) Kill processes related to the chroot if necessary
    kill $(pgrep Xephyr) 2>/dev/null
    kill -9 $(lsof -t /var/tmp/debian/) 2>/dev/null

    echo "Unmounting bound filesystems..."
    LOOPDEV="$(mount | grep loop | grep /mnt/debian | awk '{print $1}')"
    
    umount /mnt/debian/debian-armhf/run/dbus/
    umount /mnt/debian/debian-armhf/sys
    sleep 1
    umount /mnt/debian/debian-armhf/proc
    umount /mnt/debian/debian-armhf/dev/pts
    umount /mnt/debian/debian-armhf/dev

    # Sync to flush filesystem buffers
    sync

    umount /mnt/debian || true
    # Retry unmounting if necessary
    while mount | grep -q "on /mnt/debian "; do
        echo "Debian rootfs is still mounted, trying again shortly..."
        sleep 3
        umount /mnt/debian || true
    done
    echo "Debian rootfs unmounted."

    # Detach the loop device if one was associated
    if [ -n "$LOOPDEV" ]; then
        echo "Disassociating loop device >>$LOOPDEV<<"
        losetup -d "$LOOPDEV"
    fi

    echo "All done, you're now back at your device's shell."
fi
