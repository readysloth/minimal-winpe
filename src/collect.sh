#!/usr/bin/env bash

. "$(dirname "$0")/lib/pkgs.sh"
. "$(dirname "$0")/lib/common.sh"
. "$(dirname "$0")/lib/windows.sh"
. "$(dirname "$0")/lib/registry.sh"


DOWNLOAD_DIR="$(mktemp -d)"
ISO_MOUNTPOINT="$1"
DEFAULT_WIM="$2"

cd "$DOWNLOAD_DIR"

add_windows_files "$ISO_MOUNTPOINT" &
change_registry "$DEFAULT_WIM" "$ISO_MOUNTPOINT"

wait $(jobs -p)

echo "$DOWNLOAD_DIR"
