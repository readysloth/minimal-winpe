#!/usr/bin/env bash

WINEPREFIX="$(mktemp -d)"
WINEDEBUG=-all,+loaddll

WINE="${WINE:-wine-staging-8.19}"
WINECFG="${WINECFG:-winecfg-staging-8.19}"

WINEPREFIX=$WINEPREFIX $WINECFG -v win11 &>/dev/null
WINEPREFIX=$WINEPREFIX WINEDEBUG="$WINEDEBUG" $WINE "$@" 2>&1 | \
  sed -n 's/.*Loaded L"\([^"]*\)".*/\1/p' | \
  sort -u

rm -rf "$WINEPREFIX"
