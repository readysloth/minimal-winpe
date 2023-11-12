#!/usr/bin/env bash

. "$(dirname "$0")/lib/common.sh"
. "$(dirname "$0")/lib/windows.sh"
. "$(dirname "$0")/lib/registry.sh"


DOWNLOAD_DIR="$(mktemp -d)"
ISO_MOUNTPOINT="$1"
DEFAULT_WIM="$2"

cd "$DOWNLOAD_DIR"

wget https://github.com/Open-Shell/Open-Shell-Menu/releases/download/v4.4.191/OpenShellSetup_4_4_191.exe &
##
##WINETRICKS="https://raw.githubusercontent.com/Winetricks/winetricks/master/src/winetricks"
##wget "$WINETRICKS"
##
#wget https://github.com/git-for-windows/git/releases/download/v2.42.0.windows.2/PortableGit-2.42.0.2-64-bit.7z.exe &
#
#wget https://download.visualstudio.microsoft.com/download/pr/7afca223-55d2-470a-8edc-6a1739ae3252/abd170b4b0ec15ad0222a809b761a036/ndp48-x86-x64-allos-enu.exe
#
##wget https://www.python.org/ftp/python/3.12.0/python-3.12.0-embed-win32.zip
##unzip -o python-3.12.0-embed-win32.zip
#
#(wget https://www.python.org/ftp/python/3.12.0/python-3.12.0-embed-amd64.zip &&
#unzip -o python-3.12.0-embed-amd64.zip) &
#
(wget https://download.sysinternals.com/files/SysinternalsSuite.zip &&
unzip -o SysinternalsSuite.zip) &
#
#wget https://download.microsoft.com/download/6/D/F/6DF3FF94-F7F9-4F0B-838C-A328D1A7D0EE/vc_redist.x64.exe
#
##cp /home/user/Coding/minimal-winpe/install.py "$DOWNLOAD_DIR"
#
wget https://github.com/PowerShell/PowerShell/releases/download/v7.3.3/PowerShell-7.3.3-win-x64.msi &

(wget https://sourceforge.net/projects/processhacker/files/processhacker2/processhacker-2.39-bin.zip &&
unzip -o processhacker-2.39-bin.zip) &
#
#(wget https://github.com/lucasg/Dependencies/releases/download/v1.11.1/Dependencies_x64_Release.zip &&
#unzip -o Dependencies_x64_Release.zip) &
# "

add_windows_files "$ISO_MOUNTPOINT" &
change_registry "$DEFAULT_WIM" "$ISO_MOUNTPOINT" &

wait $(jobs -p)

echo "$DOWNLOAD_DIR"
