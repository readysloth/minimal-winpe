#!/usr/bin/env bash

. "$(dirname "$0")/lib/pkgs.sh"
. "$(dirname "$0")/lib/common.sh"
. "$(dirname "$0")/lib/windows.sh"
. "$(dirname "$0")/lib/registry.sh"


DOWNLOAD_DIR="$(mktemp -d)"
ISO_MOUNTPOINT="$1"
DEFAULT_WIM="$2"

cd "$DOWNLOAD_DIR"

regsvr() {
  from="$1"
  resulting_path="$2"

  filename="$(basename "$from")"
  resulting_file="$resulting_path/$filename"

  if [[ "$resulting_file" == *System32/*dll ]]
  then
    echo "%SystemRoot%\\System32\\regsvr32.exe /S \"%SystemRoot%\\System32\\$filename\"" >> ./Windows/System32/startnet.cmd
  fi
}

download_packages 2>/dev/null &
add_windows_files "$ISO_MOUNTPOINT" regsvr &>/dev/null &
change_registry "$DEFAULT_WIM" "$ISO_MOUNTPOINT" &>/dev/null &

wait $(jobs -p)

pkgs_path=""
for path in Applications Applications/*/
do
  win_path="${path/$PWD/}"
  win_path="$(printf "%%SystemDrive%%\\%s" "${win_path//\//\\}")"
  pkgs_path="$pkgs_path;$win_path"
  pkgs_path="$pkgs_path;$win_path\\x32"
  pkgs_path="$pkgs_path;$win_path\\x64"
  pkgs_path="$pkgs_path;$win_path\\x86"
done
append_to_system_path Windows/System32/config/SYSTEM "$pkgs_path"

mkdir -p postinstall_tree/Windows/System32
cp Windows/System32/startnet.cmd postinstall_tree/Windows/System32/startnet.cmd

cat >> ./Windows/System32/startnet.cmd << "EOF"
REM PENetwork.exe

wpeutil SetKeyboardLayout 0409:00000409
wpeutil SetUserLocale en-US
cls

diskpart /s X:\diskpart.script
dism /Apply-Image /ImageFile:"D:\sources\boot.wim" /Index:1 /ApplyDir:Z:\
BCDboot Z:\Windows /s Z: /f ALL
EOF

for entity in postinstall_tree/*
do
  target_path=${entity/postinstall_tree\//}
  target_path=${target_path//\//\\}
  echo "xcopy X:\\postinstall_tree\\${target_path} Z:\\$target_path /e /y" >> ./Windows/System32/startnet.cmd
done


cat >> ./Windows/System32/startnet.cmd << "EOF"
del /s /q Z:\postinstall_tree
EOF


cat >> diskpart.script << EOF
select disk 0
clean
create partition primary size=16000
format quick fs=fat32 label="Windows PE"
assign letter=Z
active
EOF

echo "$DOWNLOAD_DIR"
