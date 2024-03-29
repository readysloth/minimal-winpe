#!/usr/bin/env bash

set -e

__ScriptVersion="version"

#===  FUNCTION  ================================================================
#         NAME:  usage
#  DESCRIPTION:  Display usage information.
#===============================================================================
function usage ()
{
  echo "Usage :  $0 [options] [--]

    Options:
    -h Display this message
    -v Display script version
    -s Windows installation iso (REQUIRED)
    -o Resulting WinPE iso
    -p do not include portable apps (are downloaded in build time)
    "

}    # ----------  end of function usage  ----------

#-----------------------------------------------------------------------
#  Handle command line arguments
#-----------------------------------------------------------------------

[ $# -lt 2 ] && usage && exit 1

while getopts "hvs:op" opt
do
  case $opt in

  h) usage; exit 0   ;;

  v) echo "$0 -- Version $__ScriptVersion"; exit 0   ;;

  s) SOURCE_ISO="$OPTARG";;

  o) OUTPUT_ISO="$OPTARG";;

  p) export NO_PORTABLE_APPS="true";;

  *) usage; exit 1 ;;

  esac    # --- end of case ---
done
shift $(($OPTIND-1))

MOUNT_DIR="$(mktemp -d)"
OUTPUT_ISO="${OUTPUT_ISO:-winpe.iso}"

mount "$SOURCE_ISO" "$MOUNT_DIR"
OVERLAY="$("$(dirname "$0")/collect.sh" "$MOUNT_DIR" | tail -n1)"

mkwinpeimg --iso --windows-dir="$MOUNT_DIR" --overlay="$OVERLAY" "$OUTPUT_ISO"

wait $(jobs -p)

umount "$MOUNT_DIR"
rmdir "$MOUNT_DIR"
rm -rf "$OVERLAY"
