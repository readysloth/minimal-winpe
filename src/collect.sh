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


mkdir -p postinstall_tree/Windows/System32
mv Windows/System32/startnet.cmd postinstall_tree/regsvr32.cmd

cat >> postinstall_tree/Windows/System32/startnet.cmd << EOF
call %SystemDrive%\regsvr32.cmd
move %SystemDrive%\regsvr32.cmd %SystemDrive%\regsvr32.cmd.done
EOF

cat >> ./Windows/System32/startnet.cmd << "EOF"
wpeutil SetKeyboardLayout 0409:00000409
wpeutil SetUserLocale en-US
cls

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
EOF

cat >> diskpart.script << EOF
select disk 0
clean
create partition primary size=16000
format quick fs=ntfs label="Windows PE"
assign letter=Z
active
EOF

cat > postinstall_tree/first_boot_setup.cmd << EOF
start PENetwork.exe
timeout 5 > NUL
echo start PENetwork >> %SystemDrive%\Windows\System32\startnet.cmd

start /wait msiexec /i %SystemDrive%\Installers\PowerShell-7.4.0-win-x64.msi ALL_USERS=1 ADD_PATH=1 USE_MU=0 ENABLE_MU=0 /qn
start /wait %SystemDrive%\Installers\maxlauncher_1.31.0.0_setup.exe /VERYSILENT /NORESTART /DIR=%SystemDrive%\Applications
type chocolatey.ps1 | pwsh
type scoop.ps1 | pwsh

mklink /D %WINDIR%\SysWOW64\config\systemprofile %USERPROFILE%

call scoop install -g main/git
call scoop update
call scoop bucket add main
call scoop bucket add extras
call scoop bucket add versions

call scoop install -g extras/windowsdesktop-runtime
call scoop install -g extras/vcredist2022
call scoop install -g versions/dotnet-nightly
move first_boot_setup.cmd first_boot_setup.cmd.done
EOF

cat > postinstall_tree/recommended_apps.cmd << EOF
call scoop bucket add nirsoft
call scoop bucket add nonportable

call scoop install -g main/7zip
call scoop install -g main/neovim
call scoop install -g main/coreutils
call scoop install -g main/gdisk
call scoop install -g main/curl
call scoop install -g extras/firefox
call scoop install -g extras/explorerplusplus
call scoop install -g extras/networkmanager
call scoop install -g extras/processhacker
call scoop install -g extras/sysinternals
call scoop install -g extras/doublecmd
call scoop install -g extras/conemu
call scoop install -g extras/driverstoreexplorer
call scoop install -g extras/wingetui
call scoop install -g extras/librehardwaremonitor
call scoop install -g nonportable/open-shell-np

choco install change-screen-resolution -y
echo start changescreenresolution >> Windows/System32/startnet.cmd
EOF


cat > postinstall_tree/poweruser_apps.cmd << EOF
call scoop install -g extras/komorebi
call scoop install -g extras/smartsystemmenu
EOF

cat > postinstall_tree/winpe_maint.cmd << EOF
call scoop install -g nirsoft/runtimeclassesview
call scoop install -g nirsoft/regdllview
call scoop install -g nirsoft/appcrashview
call scoop install -g nirsoft/serviwin
EOF

cat > postinstall_tree/full_first_boot.cmd << EOF
call %SystemDrive%\first_boot_setup.cmd
call %SystemDrive%\recommended_apps.cmd
call %SystemDrive%\poweruser_apps.cmd
call %SystemDrive%\winpe_maint.cmd
EOF

for entity in postinstall_tree/*
do
  target_path=${entity/postinstall_tree\//}
  target_path=${target_path//\//\\}
  echo "echo F | xcopy X:\\postinstall_tree\\${target_path} Z:\\$target_path /s /e /y" >> ./Windows/System32/startnet.cmd
done

echo "$DOWNLOAD_DIR"
