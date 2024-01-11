#!/usr/bin/env bash

set -e

ISO="$1"
PROGRAM="$2"
export PROGRAM
PERMISSION_LIFTER="${3:-sudo}"

SCRIPT_DIR="$(readlink -f "$(dirname "$(command -v "$0")")")"
FS_FILE="$(mktemp)"
MOUNT_FOLDER="$(mktemp -d)"

qemu-img create -f raw "$FS_FILE" 20M > /dev/null

"$SCRIPT_DIR/qemu-automation/launch_qemu.sh" \
        "$SCRIPT_DIR/procmon_scenario.sh" \
        "$FS_FILE" \
        procmon.log \
        4096 \
        -boot order=d \
        -cdrom "$ISO" > /dev/null

$PERMISSION_LIFTER sh -c "
LOOPBACK_DEV=\"\$(losetup --find --partscan --show $FS_FILE)\"
mount \${LOOPBACK_DEV}p1 $MOUNT_FOLDER;
cp $MOUNT_FOLDER/log.csv procmon.csv;
umount $MOUNT_FOLDER;
losetup --detach \$LOOPBACK_DEV
"

grep \
        --ignore-case \
        "$(basename "${PROGRAM//\\/\/}")\|msiexec" \
        procmon.csv
rm -rf "$FS_FILE" "$MOUNT_FOLDER"
