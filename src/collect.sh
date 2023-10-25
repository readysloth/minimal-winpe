#!/usr/bin/env bash


DOWNLOAD_DIR="$(mktemp -d)"
ISO_MOUNTPOINT="$1"

cp_tree() {
  prefix="$1"
  from="$2"
  to="$3"
  resulting_path="$(echo "$to/$(dirname "$from")" | sed "s@$prefix@@g")"

  mkdir -p "$resulting_path" && cp -vr "$from" "$resulting_path" >&2
}

add_wim_files() {
  wim_mountpoint="$(mktemp -d)"
  wimexport "$ISO_MOUNTPOINT/sources/install.wim" 1 1.wim
  wimmount 1.wim "$wim_mountpoint"

  WOW64_FILES="
  $wim_mountpoint/Windows/SysWOW64/CoreMessaging.dll
  $wim_mountpoint/Windows/SysWOW64/CoreUIComponents.dll
  $wim_mountpoint/Windows/SysWOW64/KernelBase.dll
  $wim_mountpoint/Windows/SysWOW64/TextInputFramework.dll
  $wim_mountpoint/Windows/SysWOW64/TextShaping.dll
  $wim_mountpoint/Windows/SysWOW64/WinTypes.dll
  $wim_mountpoint/Windows/SysWOW64/advapi32.dll
  $wim_mountpoint/Windows/SysWOW64/apphelp.dll
  $wim_mountpoint/Windows/SysWOW64/bcryptprimitives.dll
  $wim_mountpoint/Windows/SysWOW64/combase.dll
  $wim_mountpoint/Windows/SysWOW64/gdi32.dll
  $wim_mountpoint/Windows/SysWOW64/gdi32full.dll
  $wim_mountpoint/Windows/SysWOW64/imm32.dll
  $wim_mountpoint/Windows/SysWOW64/kernel.appcore.dll
  $wim_mountpoint/Windows/SysWOW64/kernel32.dll
  $wim_mountpoint/Windows/SysWOW64/msctf.dll
  $wim_mountpoint/Windows/SysWOW64/msvcp_win.dll
  $wim_mountpoint/Windows/SysWOW64/msvcrt.dll
  $wim_mountpoint/Windows/SysWOW64/ntdll.dll
  $wim_mountpoint/Windows/SysWOW64/ole32.dll
  $wim_mountpoint/Windows/SysWOW64/oleaut32.dll
  $wim_mountpoint/Windows/SysWOW64/rpcrt4.dll
  $wim_mountpoint/Windows/SysWOW64/rpcss.dll
  $wim_mountpoint/Windows/SysWOW64/sechost.dll
  $wim_mountpoint/Windows/SysWOW64/shell32.dll
  $wim_mountpoint/Windows/SysWOW64/ucrtbase.dll
  $wim_mountpoint/Windows/SysWOW64/user32.dll
  $wim_mountpoint/Windows/SysWOW64/uxtheme.dll
  $wim_mountpoint/Windows/SysWOW64/win32u.dll

  $wim_mountpoint/Windows/SysWOW64/edgegdi.dll
  $wim_mountpoint/Windows/SysWOW64/edputil.dll
  $wim_mountpoint/Windows/SysWOW64/en-US
  $wim_mountpoint/Windows/SysWOW64/fltLib.dll
  $wim_mountpoint/Windows/SysWOW64/iertutil.dll
  $wim_mountpoint/Windows/SysWOW64/imageres.dll
  $wim_mountpoint/Windows/SysWOW64/mpr.dll
  $wim_mountpoint/Windows/SysWOW64/msvcp110_win.dll
  $wim_mountpoint/Windows/SysWOW64/netutils.dll
  $wim_mountpoint/Windows/SysWOW64/ntmarta.dll
  $wim_mountpoint/Windows/SysWOW64/SHCore.dll
  $wim_mountpoint/Windows/SysWOW64/ServicingCommon.dll
  $wim_mountpoint/Windows/SysWOW64/bcrypt.dll
  $wim_mountpoint/Windows/SysWOW64/cfgmgr32.dll

  $wim_mountpoint/Windows/SysWOW64/cscapi.dll
  $wim_mountpoint/Windows/SysWOW64/dwmapi.dll
  $wim_mountpoint/Windows/SysWOW64/clbcatq.dll

  $wim_mountpoint/Windows/SysWOW64/pcacli.dll
  $wim_mountpoint/Windows/SysWOW64/policymanager.dll
  $wim_mountpoint/Windows/SysWOW64/profapi.dll
  $wim_mountpoint/Windows/SysWOW64/propsys.dll
  $wim_mountpoint/Windows/SysWOW64/sfc_os.dll
  $wim_mountpoint/Windows/SysWOW64/shdocvw.dll
  $wim_mountpoint/Windows/SysWOW64/setupapi.dll
  $wim_mountpoint/Windows/SysWOW64/shlwapi.dll
  $wim_mountpoint/Windows/SysWOW64/srvcli.dll
  $wim_mountpoint/Windows/SysWOW64/sspicli.dll
  $wim_mountpoint/Windows/SysWOW64/urlmon.dll
  $wim_mountpoint/Windows/SysWOW64/version.dll
  $wim_mountpoint/Windows/SysWOW64/virtdisk.dll
  $wim_mountpoint/Windows/SysWOW64/windows.storage.dll
  $wim_mountpoint/Windows/SysWOW64/wldp.dll
  $wim_mountpoint/Windows/SysWOW64/ws2_32.dll
  $wim_mountpoint/Windows/SysWOW64/cabinet.dll

  $wim_mountpoint/Windows/SysWOW64/comctl32.dll
  $wim_mountpoint/Windows/SysWOW64/wow32.dll
  $wim_mountpoint/Windows/SysWOW64/msasn1.dll
  $wim_mountpoint/Windows/SysWOW64/mscoree.dll
  $wim_mountpoint/Windows/SysWOW64/duser.dll
  $wim_mountpoint/Windows/SysWOW64/srpapi.dll
  $wim_mountpoint/Windows/SysWOW64/Windows.UI.dll
  $wim_mountpoint/Windows/SysWOW64/msimsg.dll

  $wim_mountpoint/Windows/SysWOW64/spp.dll
  $wim_mountpoint/Windows/SysWOW64/powrprof.dll
  $wim_mountpoint/Windows/SysWOW64/umpdc.dll
  $wim_mountpoint/Windows/SysWOW64/msiexec.exe

  $(eval echo "$wim_mountpoint/Windows/SysWOW64/*.mui")
  $(eval echo "$wim_mountpoint/Windows/SysWOW64/crypt*.dll")
  $(eval echo "$wim_mountpoint/Windows/SysWOW64/wbem*")
  $(eval echo "$wim_mountpoint/Windows/SysWOW64/msi*")
  $(eval echo "$wim_mountpoint/Windows/SysWOW64/wininet*")
  $(eval echo "$wim_mountpoint/Windows/SysWOW64/rpc*")
  $(eval echo "$wim_mountpoint/Windows/SysWOW64/*xml*")
  $(eval echo "$wim_mountpoint/Windows/SysWOW64/*client*")
  "
  SYSTEM32_FILES="
  $wim_mountpoint/Windows/System32/rpcss.dll
  $wim_mountpoint/Windows/System32/C_1251.NLS
  $wim_mountpoint/Windows/System32/C_866.NLS
  $wim_mountpoint/Windows/System32/l_intl.nls
  $wim_mountpoint/Windows/System32/locale.nls
  $wim_mountpoint/Windows/System32/wow64.dll
  $wim_mountpoint/Windows/System32/wow64base.dll
  $wim_mountpoint/Windows/System32/wow64con.dll
  $wim_mountpoint/Windows/System32/wow64cpu.dll
  $wim_mountpoint/Windows/System32/wow64win.dll

  $wim_mountpoint/Windows/System32/comdlg32.dll
  $wim_mountpoint/Windows/System32/win32k.sys
  $wim_mountpoint/Windows/System32/msiexec.exe
  $wim_mountpoint/Windows/System32/mscoree.dll
  $wim_mountpoint/Windows/System32/duser.dll
  $wim_mountpoint/Windows/System32/spapi.dll
  $wim_mountpoint/Windows/System32/msi.dll
  $wim_mountpoint/Windows/System32/Windows.UI.dll
  $wim_mountpoint/Windows/System32/msimsg.dll
  "
  WINSXS_FILES="
  $(for arch in amd64 x86
    do
      for package in \
        'c..-controls.resources*en-us*' \
        'common-controls*' \
        'gdiplus*' \
        'isolationautomation*' \
        'i..utomation.proxystub*' \
        'systemcompatible*' \
        'servicingstack*' \
        'comdlg32*' \
        'windowui*' \
        'installer-engine*' \
        'i..xecutable.resources*'
      do
        eval echo "$wim_mountpoint/Windows/WinSxS/${arch}_microsoft-windows-$package"
        eval echo "$wim_mountpoint/Windows/WinSxS/${arch}_microsoft.windows.$package"
        eval echo "$wim_mountpoint/Windows/WinSxS/Manifests/${arch}_microsoft.windows.$package"
      done
    done)
  "
  DOTNET_FILES="
  $wim_mountpoint/Windows/assembly
  $wim_mountpoint/Windows/Microsoft.NET
  "
  FILES_TO_INSTALL="
  $WOW64_FILES
  $SYSTEM32_FILES
  $WINSXS_FILES
  $DOTNET_FILES
  "

  for fs_node in $FILES_TO_INSTALL
  do
    cp_tree "$wim_mountpoint" "$fs_node" . &
  done

  wait $(jobs -p)


  (for key in \
   WOW6432Node \
   Classes\\Wow6432Node \
   Microsoft\\Wow64 \
   Microsoft\\Windows\\CurrentVersion\\SideBySide \
   Microsoft\\Windows\\CurrentVersion\\SMI
   do
      hivexregedit --export "$wim_mountpoint/Windows/System32/config/SOFTWARE" "$key" | \
        sed -e 's@^\[@&HKEY_LOCAL_MACHINE\\Software@' -e '/Windows Registry Editor/d'
   done) | sed '1i\Windows Registry Editor Version 5.00' > wow6432.reg

  cp wow6432.reg /tmp

  wimunmount "$wim_mountpoint"
  rmdir "$wim_mountpoint"
  rm 1.wim
}


cd "$DOWNLOAD_DIR"

wget https://github.com/Open-Shell/Open-Shell-Menu/releases/download/v4.4.191/OpenShellSetup_4_4_191.exe &
#
#WINETRICKS="https://raw.githubusercontent.com/Winetricks/winetricks/master/src/winetricks"
#wget "$WINETRICKS"
#
wget https://github.com/git-for-windows/git/releases/download/v2.42.0.windows.2/PortableGit-2.42.0.2-64-bit.7z.exe &

#wget https://download.visualstudio.microsoft.com/download/pr/7afca223-55d2-470a-8edc-6a1739ae3252/abd170b4b0ec15ad0222a809b761a036/ndp48-x86-x64-allos-enu.exe

#wget https://www.python.org/ftp/python/3.12.0/python-3.12.0-embed-win32.zip
#unzip python-3.12.0-embed-win32.zip

(wget https://www.python.org/ftp/python/3.12.0/python-3.12.0-embed-amd64.zip &&
unzip python-3.12.0-embed-amd64.zip) &

(wget https://download.sysinternals.com/files/SysinternalsSuite.zip &&
unzip SysinternalsSuite.zip) &

wget https://download.microsoft.com/download/6/D/F/6DF3FF94-F7F9-4F0B-838C-A328D1A7D0EE/vc_redist.x64.exe

#cp /home/user/Coding/minimal-winpe/install.py "$DOWNLOAD_DIR"


(wget https://github.com/lucasg/Dependencies/releases/download/v1.11.1/Dependencies_x64_Release.zip &&
unzip Dependencies_x64_Release.zip) &

add_wim_files &

wait $(jobs -p)

echo "$DOWNLOAD_DIR"
