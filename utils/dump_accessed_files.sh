#!/usr/bin/env bash

WINEPREFIX="$(mktemp -d)"
WINEDEBUG=-all

WINE="${WINE:-wine-staging-8.19}"
WINECFG="${WINECFG:-winecfg-staging-8.19}"

WINEPREFIX=$WINEPREFIX $WINECFG -v win11 &>/dev/null

loggedfs -f -p "$WINEPREFIX" | \
  cut -d' ' -f 5- | \
  sed -e 's/{SUCCESS}.*//' \
      -e 's/{FAILURE}.*//' \
      -e 's/at offset.*//' \
      -e 's/write [0-9]* bytes to//' \
      -e 's/read [0-9]* bytes from//' \
      -e 's/[0-9]* bytes read from//' \
      -e 's/[0-9]* bytes written to//' \
      -e 's/to [0-9]* bytes//' \
      -e 's/to [0-9]*//' \
      -e 's/100644 S_IFREG (normal file creation)//' \
      -e 's/^[[:space:]]*open//' \
      -e 's/^[[:space:]]*open readwrite//' \
      -e 's/^[[:space:]]*open readonly//' \
      -e 's/^[[:space:]]*open writeonly//' \
      -e 's/^[[:space:]]*chdir//' \
      -e 's/^[[:space:]]*chmod//' \
      -e 's/^[[:space:]]*fsync//' \
      -e 's/^[[:space:]]*getattr//' \
      -e 's/^[[:space:]]*mkdir//' \
      -e 's/^[[:space:]]*mknod//' \
      -e 's/^[[:space:]]*readdir//' \
      -e 's/^[[:space:]]*readlink//' \
      -e 's/^[[:space:]]*rename//' \
      -e 's/^[[:space:]]*rmdir//' \
      -e 's/^[[:space:]]*statfs//' \
      -e 's/^[[:space:]]*truncate//' \
      -e 's/^[[:space:]]*unlink//' \
      -e 's/^[[:space:]]*utimens//' \
      -e 's/^[[:space:]]*release//' \
      -e 's/^[[:space:]]*readwrite//' \
      -e 's/^[[:space:]]*writeonly//' | \
  sed -e 's/[[:space:]]*$//' \
      -e 's/^[[:space:]]*//' | \
  sort -u | \
  grep -v '^LoggedFS' &
WINEPREFIX=$WINEPREFIX WINEDEBUG="$WINEDEBUG" $WINE "$@" &>/dev/null

kill $(jobs -p)
rm -rf "$WINEPREFIX"
