#!/usr/bin/env bash

set -e

ISO="$1"
export PROGRAM
PERMISSION_LIFTER="${2:-sudo}"

SCRIPT_DIR="$(readlink -f "$(dirname "$(command -v "$0")")")"
FS_FILE="$(mktemp)"
MOUNT_FOLDER="$(mktemp -d)"

qemu-img create -f raw "$FS_FILE" 4G > /dev/null

parted -a optimal --script "$FS_FILE" 'mklabel msdos'
parted -a optimal --script "$FS_FILE" 'mkpart primary 128 -1'

$PERMISSION_LIFTER sh -c "
LOOPBACK_DEV=\"\$(losetup --find --partscan --show $FS_FILE)\"
mkfs.vfat \${LOOPBACK_DEV}p1;
losetup --detach \$LOOPBACK_DEV
"

"$SCRIPT_DIR/qemu-automation/launch_qemu.sh" \
        "$SCRIPT_DIR/bsod_scenario.sh" \
        - \
        bsod_dump.log \
        4096 \
        -fda "$FS_FILE" \
        -boot order=d \
        -cdrom "$ISO" > /dev/null

$PERMISSION_LIFTER sh -c "
LOOPBACK_DEV=\"\$(losetup --find --partscan --show $FS_FILE)\"
mount \${LOOPBACK_DEV}p1 $MOUNT_FOLDER;
cp $MOUNT_FOLDER/memory.dmp .;
umount $MOUNT_FOLDER;
losetup --detach \$LOOPBACK_DEV
"

rm -rf "$FS_FILE" "$MOUNT_FOLDER"
