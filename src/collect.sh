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
    echo "%SystemRoot%\\System32\\regsvr32.exe /S \"%SystemRoot%\\System32\\$filename\"" >> postinstall_tree/regsvr32.cmd
  fi
}

mkdir -p postinstall_tree/Windows/System32

download_packages 2>/dev/null &
add_windows_files "$ISO_MOUNTPOINT" regsvr &>/dev/null &
change_registry "$ISO_MOUNTPOINT" &>/dev/null &

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

win_path="$(get_env_val Path "$ISO_MOUNTPOINT" Windows/System32/config/SYSTEM)"

{
create_env_val PSHOME '%SystemDrive%\Program Files\PowerShell\7'
create_env_val PSModulePath '%SystemDrive%\Program Files\PowerShell\7\Modules'
create_env_val ChocolateyInstall '%SystemDrive%\ProgramData\chocolatey'
create_env_val SCOOP "%SystemDrive%\ProgramData\scoop"
create_env_val SCOOP_GLOBAL "%SystemDrive%\ProgramData\scoop"
create_env_val PATH_APPEND "$pkgs_path;%PSHOME%;%ChocolateyInstall%;%ChocolateyInstall%\bin;%SCOOP_GLOBAL%\shims"
create_env_val Path "$win_path;%PATH_APPEND%"
} > win_environment_reg.cmd


cat >> ./postinstall_tree/init.cmd << "EOF"
start %SystemDrive%\ProgramData\chocolatey\bin\ChangeScreenResolution.exe
start %SystemDrive%\Applications\PENetwork.exe
EOF

cat >> ./postinstall_tree/Windows/System32/winpeshl.ini << "EOF"
[LaunchApps]
%SystemDrive%\init.cmd
%SystemDrive%\Applications\LaunchBar_x64.exe, LARGE=1 POSITION=4 %USERPROFILE%\AppData\Roaming\Microsoft\Internet Explorer\Quick Launch
EOF

cat >> ./Windows/System32/startnet.cmd << "EOF"
diskpart /s %SystemDrive%\diskpart.script
dism /Apply-Image /ImageFile:"D:\sources\boot.wim" /Index:1 /ApplyDir:Z:\
BCDboot Z:\Windows /s Z: /f ALL
del /s /q Z:\postinstall_tree

reg load HKEY_LOCAL_MACHINE\MOUNT Z:\Windows\System32\config\SYSTEM
reg import %SystemDrive%\system.reg
call %SystemDrive%\win_environment_reg.cmd
reg unload HKEY_LOCAL_MACHINE\MOUNT

reg load HKEY_LOCAL_MACHINE\MOUNT Z:\Windows\System32\config\SOFTWARE
reg import %SystemDrive%\software.reg
reg unload HKEY_LOCAL_MACHINE\MOUNT

mkdir "Z:\Windows\System32\config\systemprofile\AppData\Roaming\Microsoft\Internet Explorer\Quick Launch"
del Z:\Windows\System32\startnet.cmd
EOF

cat >> diskpart.script << EOF
select disk 0
clean
create partition primary size=16000
format quick fs=ntfs label="Windows PE"
assign letter=Z
active
EOF

pushd postinstall_tree
  create_first_boot_scripts
popd

for entity in postinstall_tree/*
do
  target_path=${entity/postinstall_tree\//}
  target_path=${target_path//\//\\}
  echo "echo F | xcopy X:\\postinstall_tree\\${target_path} Z:\\$target_path /s /e /y" >> ./Windows/System32/startnet.cmd
done
cp -r postinstall_tree /tmp/
echo "$DOWNLOAD_DIR"
