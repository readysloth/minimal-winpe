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

cat >> Windows/System32/startnet.cmd << EOF
set PSHOME=X:\Program Files\PowerShell\7
set PSModulePath=X:\Program Files\PowerShell\7\Modules
set ChocolateyInstall=X:\ProgramData\chocolatey
set PATH_APPEND=$pkgs_path;%PSHOME%;%ChocolateyInstall%;%ChocolateyInstall%\bin
set PATH=%PATH%;%PATH_APPEND%
start PENetwork
EOF

#TODO: Modifcation of registry breaks .NET applications. Why?
#create_env_val PATH_APPEND "$pkgs_path" Windows/System32/config/SYSTEM

mkdir -p postinstall_tree/Windows/System32
cp Windows/System32/startnet.cmd postinstall_tree/Windows/System32/startnet.cmd

cat > postinstall_tree/first_boot_setup.cmd << EOF
start /wait msiexec /i X:\Installers\PowerShell-7.4.0-win-x64.msi ALL_USERS=1 ADD_PATH=1 USE_MU=0 ENABLE_MU=0 /qn
type chocolatey.cmd | pwsh
choco install dotnet-8.0-desktopruntime -y
move first_boot_setup.cmd first_boot_setup.cmd.done
EOF

cat > postinstall_tree/recommended_apps.cmd << EOF
choco install git -y
choco install vim -y
choco install firefox -y
choco install change-screen-resolution -y
choco install open-shell -y
choco install 7zip -y
echo start changescreenresolution >> Windows/System32/startnet.cmd
EOF

cat >> ./Windows/System32/startnet.cmd << "EOF"
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
  echo "echo F | xcopy X:\\postinstall_tree\\${target_path} Z:\\$target_path /s /e /y" >> ./Windows/System32/startnet.cmd
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
