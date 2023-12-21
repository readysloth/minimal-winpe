#!/usr/bin/env bash

WINEPREFIX="$(mktemp -d)"
WINEDEBUG=-all,+reg
WINE="${WINE:-wine-staging-8.19}"
WINECFG="${WINECFG:-winecfg-staging-8.19}"

WINEPREFIX=$WINEPREFIX $WINECFG -v win11 &>/dev/null
WINEPREFIX=$WINEPREFIX $WINE reg query HKLM /s | grep '^HKEY_LOCAL_MACHINE' | \
  grep \
    --fixed-strings \
    --file \
    <(WINEPREFIX="$WINEPREFIX" WINEDEBUG="$WINEDEBUG" $WINE "$@" 2>&1 | \
      sed -n '/NtOpenKey/ s/.*([^,]*,L"\([^"]*\)".*/\1/p' | \
      sed -e '/wine/Id' \
          -e '/\\\\Registry\\\\Machine\\\\/d'| \
      sort -u) | \
  python3 <(cat << EOF
import sys

registry_keys = (l.strip() for l in sys.stdin.readlines())
hive = {}

for key in registry_keys:
  root = hive
  for part in key.split('\\\\'):
    root[part] = root.get(part, {})
    root = root[part]


def exclude_empty_children(hive):
  new_hive = {}
  for key, subtree in hive.items():
    new_hive[key] = {}
    if all(not v for v in subtree.values()):
      continue
    new_hive[key] = exclude_empty_children(subtree)
  return new_hive


def reconstruct_paths(hive):
  for key, subtree in hive.items():
    if not subtree:
      yield key
      continue
    for path in reconstruct_paths(subtree):
      yield f'{key}\\\\{path}'

hive = exclude_empty_children(hive)
for path in reconstruct_paths(hive):
  print(path)
EOF
)

rm -rf "$WINEPREFIX"
