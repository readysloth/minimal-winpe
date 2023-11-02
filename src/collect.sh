#!/usr/bin/env bash


DOWNLOAD_DIR="$(mktemp -d)"
ISO_MOUNTPOINT="$1"

cp_tree() {
  prefix="$1"
  from="$2"
  to="$3"
  resulting_path="$(echo "$to/$(dirname "$from")" | sed "s@$prefix@@g")"

  mkdir -p "$resulting_path" && cp -vr "$from" "$resulting_path" 2>&1 | tee /tmp/cp_tree.log
}

add_wim_files() {
  wim_mountpoint="$(mktemp -d)"
  wimexport "$ISO_MOUNTPOINT/sources/install.wim" 1 1.wim
  wimmount 1.wim "$wim_mountpoint"


  COMMON_FILES="
  $wim_mountpoint/Windows/FOLDER_STUB/CoreMessaging.dll
  $wim_mountpoint/Windows/FOLDER_STUB/CoreUIComponents.dll
  $wim_mountpoint/Windows/FOLDER_STUB/CredProv2faHelper.dll
  $wim_mountpoint/Windows/FOLDER_STUB/CredProvDataModel.dll
  $wim_mountpoint/Windows/FOLDER_STUB/D3D12.dll
  $wim_mountpoint/Windows/FOLDER_STUB/DWrite.dll
  $wim_mountpoint/Windows/FOLDER_STUB/DXCore.dll
  $wim_mountpoint/Windows/FOLDER_STUB/DataExchange.dll
  $wim_mountpoint/Windows/FOLDER_STUB/DbgModel.dll
  $wim_mountpoint/Windows/FOLDER_STUB/ExplorerFrame.dll
  $wim_mountpoint/Windows/FOLDER_STUB/FWPUCLNT.DLL
  $wim_mountpoint/Windows/FOLDER_STUB/FirewallAPI.dll
  $wim_mountpoint/Windows/FOLDER_STUB/FlightSettings.dll
  $wim_mountpoint/Windows/FOLDER_STUB/IPHLPAPI.DLL
  $wim_mountpoint/Windows/FOLDER_STUB/InputHost.dll
  $wim_mountpoint/Windows/FOLDER_STUB/KerbClientShared.dll
  $wim_mountpoint/Windows/FOLDER_STUB/KernelBase.dll
  $wim_mountpoint/Windows/FOLDER_STUB/KeyCredMgr.dll
  $wim_mountpoint/Windows/FOLDER_STUB/MMDevAPI.dll
  $wim_mountpoint/Windows/FOLDER_STUB/NetDriverInstall.dll
  $wim_mountpoint/Windows/FOLDER_STUB/NetSetupApi.dll
  $wim_mountpoint/Windows/FOLDER_STUB/NetSetupEngine.dll
  $wim_mountpoint/Windows/FOLDER_STUB/NtlmShared.dll
  $wim_mountpoint/Windows/FOLDER_STUB/OnDemandConnRouteHelper.dll
  $wim_mountpoint/Windows/FOLDER_STUB/OneCoreCommonProxyStub.dll
  $wim_mountpoint/Windows/FOLDER_STUB/OneCoreUAPCommonProxyStub.dll
  $wim_mountpoint/Windows/FOLDER_STUB/PresentationHostProxy.dll
  $wim_mountpoint/Windows/FOLDER_STUB/SHCore.dll
  $wim_mountpoint/Windows/FOLDER_STUB/SSShim.dll
  $wim_mountpoint/Windows/FOLDER_STUB/SensApi.dll
  $wim_mountpoint/Windows/FOLDER_STUB/ServicingCommon.dll
  $wim_mountpoint/Windows/FOLDER_STUB/StructuredQuery.dll
  $wim_mountpoint/Windows/FOLDER_STUB/TextInputFramework.dll
  $wim_mountpoint/Windows/FOLDER_STUB/TextShaping.dll
  $wim_mountpoint/Windows/FOLDER_STUB/TrustedSignalCredProv.dll
  $wim_mountpoint/Windows/FOLDER_STUB/UIAnimation.dll
  $wim_mountpoint/Windows/FOLDER_STUB/UIAutomationCore.dll
  $wim_mountpoint/Windows/FOLDER_STUB/VAN.dll
  $wim_mountpoint/Windows/FOLDER_STUB/WcnApi.dll
  $wim_mountpoint/Windows/FOLDER_STUB/WinTypes.dll
  $wim_mountpoint/Windows/FOLDER_STUB/Windows.UI.dll
  $wim_mountpoint/Windows/FOLDER_STUB/WofUtil.dll
  $wim_mountpoint/Windows/FOLDER_STUB/aclui.dll
  $wim_mountpoint/Windows/FOLDER_STUB/activeds.dll
  $wim_mountpoint/Windows/FOLDER_STUB/actxprxy.dll
  $wim_mountpoint/Windows/FOLDER_STUB/adsldp.dll
  $wim_mountpoint/Windows/FOLDER_STUB/adsldpc.dll
  $wim_mountpoint/Windows/FOLDER_STUB/advapi32.dll
  $wim_mountpoint/Windows/FOLDER_STUB/amsi.dll
  $wim_mountpoint/Windows/FOLDER_STUB/apphelp.dll
  $wim_mountpoint/Windows/FOLDER_STUB/asycfilt.dll
  $wim_mountpoint/Windows/FOLDER_STUB/atlthunk.dll
  $wim_mountpoint/Windows/FOLDER_STUB/authui.dll
  $wim_mountpoint/Windows/FOLDER_STUB/authz.dll
  $wim_mountpoint/Windows/FOLDER_STUB/avifil32.dll
  $wim_mountpoint/Windows/FOLDER_STUB/avrt.dll
  $wim_mountpoint/Windows/FOLDER_STUB/browcli.dll
  $wim_mountpoint/Windows/FOLDER_STUB/cabinet.dll
  $wim_mountpoint/Windows/FOLDER_STUB/cfgmgr32.dll
  $wim_mountpoint/Windows/FOLDER_STUB/clbcatq.dll
  $wim_mountpoint/Windows/FOLDER_STUB/cmdext.dll
  $wim_mountpoint/Windows/FOLDER_STUB/combase.dll
  $wim_mountpoint/Windows/FOLDER_STUB/comctl32.dll
  $wim_mountpoint/Windows/FOLDER_STUB/console.dll
  $wim_mountpoint/Windows/FOLDER_STUB/credprovhost.dll
  $wim_mountpoint/Windows/FOLDER_STUB/credprovs.dll
  $wim_mountpoint/Windows/FOLDER_STUB/credprovslegacy.dll
  $wim_mountpoint/Windows/FOLDER_STUB/credssp.dll
  $wim_mountpoint/Windows/FOLDER_STUB/credui.dll
  $wim_mountpoint/Windows/FOLDER_STUB/crtdll.dll
  $wim_mountpoint/Windows/FOLDER_STUB/cscapi.dll
  $wim_mountpoint/Windows/FOLDER_STUB/d2d1.dll
  $wim_mountpoint/Windows/FOLDER_STUB/d3d10warp.dll
  $wim_mountpoint/Windows/FOLDER_STUB/d3d11.dll
  $wim_mountpoint/Windows/FOLDER_STUB/d3d9.dll
  $wim_mountpoint/Windows/FOLDER_STUB/davhlpr.dll
  $wim_mountpoint/Windows/FOLDER_STUB/dbgcore.dll
  $wim_mountpoint/Windows/FOLDER_STUB/dbgeng.dll
  $wim_mountpoint/Windows/FOLDER_STUB/dbghelp.dll
  $wim_mountpoint/Windows/FOLDER_STUB/dciman32.dll
  $wim_mountpoint/Windows/FOLDER_STUB/dcomp.dll
  $wim_mountpoint/Windows/FOLDER_STUB/ddraw.dll
  $wim_mountpoint/Windows/FOLDER_STUB/devenum.dll
  $wim_mountpoint/Windows/FOLDER_STUB/devicengccredprov.dll
  $wim_mountpoint/Windows/FOLDER_STUB/devobj.dll
  $wim_mountpoint/Windows/FOLDER_STUB/devrtl.dll
  $wim_mountpoint/Windows/FOLDER_STUB/dfscli.dll
  $wim_mountpoint/Windows/FOLDER_STUB/dfshim.dll
  $wim_mountpoint/Windows/FOLDER_STUB/dhcpcsvc.dll
  $wim_mountpoint/Windows/FOLDER_STUB/dhcpcsvc6.dll
  $wim_mountpoint/Windows/FOLDER_STUB/diagnosticdataquery.dll
  $wim_mountpoint/Windows/FOLDER_STUB/difxapi.dll
  $wim_mountpoint/Windows/FOLDER_STUB/directmanipulation.dll
  $wim_mountpoint/Windows/FOLDER_STUB/dlnashext.dll
  $wim_mountpoint/Windows/FOLDER_STUB/dnsapi.dll
  $wim_mountpoint/Windows/FOLDER_STUB/downlevel/
  $wim_mountpoint/Windows/FOLDER_STUB/dpapi.dll
  $wim_mountpoint/Windows/FOLDER_STUB/drvsetup.dll
  $wim_mountpoint/Windows/FOLDER_STUB/drvstore.dll
  $wim_mountpoint/Windows/FOLDER_STUB/dsound.dll
  $wim_mountpoint/Windows/FOLDER_STUB/dsrole.dll
  $wim_mountpoint/Windows/FOLDER_STUB/dui70.dll
  $wim_mountpoint/Windows/FOLDER_STUB/duser.dll
  $wim_mountpoint/Windows/FOLDER_STUB/dwmapi.dll
  $wim_mountpoint/Windows/FOLDER_STUB/dxgi.dll
  $wim_mountpoint/Windows/FOLDER_STUB/edgegdi.dll
  $wim_mountpoint/Windows/FOLDER_STUB/edputil.dll
  $wim_mountpoint/Windows/FOLDER_STUB/eventcls.dll
  $wim_mountpoint/Windows/FOLDER_STUB/fdWCN.dll
  $wim_mountpoint/Windows/FOLDER_STUB/fltLib.dll
  $wim_mountpoint/Windows/FOLDER_STUB/framedynos.dll
  $wim_mountpoint/Windows/FOLDER_STUB/fveapi.dll
  $wim_mountpoint/Windows/FOLDER_STUB/fveapibase.dll
  $wim_mountpoint/Windows/FOLDER_STUB/fvecerts.dll
  $wim_mountpoint/Windows/FOLDER_STUB/fwbase.dll
  $wim_mountpoint/Windows/FOLDER_STUB/fwpolicyiomgr.dll
  $wim_mountpoint/Windows/FOLDER_STUB/gdi32.dll
  $wim_mountpoint/Windows/FOLDER_STUB/gdi32full.dll
  $wim_mountpoint/Windows/FOLDER_STUB/glu32.dll
  $wim_mountpoint/Windows/FOLDER_STUB/gpapi.dll
  $wim_mountpoint/Windows/FOLDER_STUB/hhctrl.ocx
  $wim_mountpoint/Windows/FOLDER_STUB/hid.dll
  $wim_mountpoint/Windows/FOLDER_STUB/ieframe.dll
  $wim_mountpoint/Windows/FOLDER_STUB/iertutil.dll
  $wim_mountpoint/Windows/FOLDER_STUB/imagehlp.dll
  $wim_mountpoint/Windows/FOLDER_STUB/imm32.dll
  $wim_mountpoint/Windows/FOLDER_STUB/kernel.appcore.dll
  $wim_mountpoint/Windows/FOLDER_STUB/kernel32.dll
  $wim_mountpoint/Windows/FOLDER_STUB/linkinfo.dll
  $wim_mountpoint/Windows/FOLDER_STUB/logoncli.dll
  $wim_mountpoint/Windows/FOLDER_STUB/lz32.dll
  $wim_mountpoint/Windows/FOLDER_STUB/mfc42.dll
  $wim_mountpoint/Windows/FOLDER_STUB/mfperfhelper.dll
  $wim_mountpoint/Windows/FOLDER_STUB/mibincodec.dll
  $wim_mountpoint/Windows/FOLDER_STUB/migration
  $wim_mountpoint/Windows/FOLDER_STUB/mimofcodec.dll
  $wim_mountpoint/Windows/FOLDER_STUB/mlang.dll
  $wim_mountpoint/Windows/FOLDER_STUB/mpr.dll
  $wim_mountpoint/Windows/FOLDER_STUB/msIso.dll
  $wim_mountpoint/Windows/FOLDER_STUB/msacm32.dll
  $wim_mountpoint/Windows/FOLDER_STUB/msacm32.drv
  $wim_mountpoint/Windows/FOLDER_STUB/msasn1.dll
  $wim_mountpoint/Windows/FOLDER_STUB/mscms.dll
  $wim_mountpoint/Windows/FOLDER_STUB/mscoree.dll
  $wim_mountpoint/Windows/FOLDER_STUB/mscorier.dll
  $wim_mountpoint/Windows/FOLDER_STUB/mscories.dll
  $wim_mountpoint/Windows/FOLDER_STUB/msctf.dll
  $wim_mountpoint/Windows/FOLDER_STUB/msdelta.dll
  $wim_mountpoint/Windows/FOLDER_STUB/msdmo.dll
  $wim_mountpoint/Windows/FOLDER_STUB/mshtml.dll
  $wim_mountpoint/Windows/FOLDER_STUB/msimsg.dll
  $wim_mountpoint/Windows/FOLDER_STUB/mskeyprotect.dll
  $wim_mountpoint/Windows/FOLDER_STUB/msls31.dll
  $wim_mountpoint/Windows/FOLDER_STUB/msvcrt.dll
  $wim_mountpoint/Windows/FOLDER_STUB/mswsock.dll
  $wim_mountpoint/Windows/FOLDER_STUB/ncobjapi.dll
  $wim_mountpoint/Windows/FOLDER_STUB/netapi32.dll
  $wim_mountpoint/Windows/FOLDER_STUB/netfxperf.dll
  $wim_mountpoint/Windows/FOLDER_STUB/netmsg.dll
  $wim_mountpoint/Windows/FOLDER_STUB/netutils.dll
  $wim_mountpoint/Windows/FOLDER_STUB/newdev.dll
  $wim_mountpoint/Windows/FOLDER_STUB/ngclocal.dll
  $wim_mountpoint/Windows/FOLDER_STUB/normaliz.dll
  $wim_mountpoint/Windows/FOLDER_STUB/nsi.dll
  $wim_mountpoint/Windows/FOLDER_STUB/ntasn1.dll
  $wim_mountpoint/Windows/FOLDER_STUB/ntdll.dll
  $wim_mountpoint/Windows/FOLDER_STUB/ntdsapi.dll
  $wim_mountpoint/Windows/FOLDER_STUB/ntlanman.dll
  $wim_mountpoint/Windows/FOLDER_STUB/ntmarta.dll
  $wim_mountpoint/Windows/FOLDER_STUB/ntshrui.dll
  $wim_mountpoint/Windows/FOLDER_STUB/odbc32.dll
  $wim_mountpoint/Windows/FOLDER_STUB/ole32.dll
  $wim_mountpoint/Windows/FOLDER_STUB/oleaut32.dll
  $wim_mountpoint/Windows/FOLDER_STUB/opengl32.dll
  $wim_mountpoint/Windows/FOLDER_STUB/pcacli.dll
  $wim_mountpoint/Windows/FOLDER_STUB/pdh.dll
  $wim_mountpoint/Windows/FOLDER_STUB/policymanager.dll
  $wim_mountpoint/Windows/FOLDER_STUB/powrprof.dll
  $wim_mountpoint/Windows/FOLDER_STUB/profapi.dll
  $wim_mountpoint/Windows/FOLDER_STUB/propsys.dll
  $wim_mountpoint/Windows/FOLDER_STUB/psapi.dll
  $wim_mountpoint/Windows/FOLDER_STUB/quartz.dll
  $wim_mountpoint/Windows/FOLDER_STUB/rasadhlp.dll
  $wim_mountpoint/Windows/FOLDER_STUB/rasapi32.dll
  $wim_mountpoint/Windows/FOLDER_STUB/riched20.dll
  $wim_mountpoint/Windows/FOLDER_STUB/riched32.dll
  $wim_mountpoint/Windows/FOLDER_STUB/rpcrt4.dll
  $wim_mountpoint/Windows/FOLDER_STUB/rpcss.dll
  $wim_mountpoint/Windows/FOLDER_STUB/rsaenh.dll
  $wim_mountpoint/Windows/FOLDER_STUB/rtutils.dll
  $wim_mountpoint/Windows/FOLDER_STUB/samcli.dll
  $wim_mountpoint/Windows/FOLDER_STUB/samlib.dll
  $wim_mountpoint/Windows/FOLDER_STUB/schannel.dll
  $wim_mountpoint/Windows/FOLDER_STUB/sechost.dll
  $wim_mountpoint/Windows/FOLDER_STUB/secur32.dll
  $wim_mountpoint/Windows/FOLDER_STUB/setupapi.dll
  $wim_mountpoint/Windows/FOLDER_STUB/sfc.dll
  $wim_mountpoint/Windows/FOLDER_STUB/sfc_os.dll
  $wim_mountpoint/Windows/FOLDER_STUB/shdocvw.dll
  $wim_mountpoint/Windows/FOLDER_STUB/shell32.dll
  $wim_mountpoint/Windows/FOLDER_STUB/shlwapi.dll
  $wim_mountpoint/Windows/FOLDER_STUB/slc.dll
  $wim_mountpoint/Windows/FOLDER_STUB/spapi.dll
  $wim_mountpoint/Windows/FOLDER_STUB/spfileq.dll
  $wim_mountpoint/Windows/FOLDER_STUB/spinf.dll
  $wim_mountpoint/Windows/FOLDER_STUB/spp.dll
  $wim_mountpoint/Windows/FOLDER_STUB/srpapi.dll
  $wim_mountpoint/Windows/FOLDER_STUB/srvcli.dll
  $wim_mountpoint/Windows/FOLDER_STUB/sspicli.dll
  $wim_mountpoint/Windows/FOLDER_STUB/sud.dll
  $wim_mountpoint/Windows/FOLDER_STUB/sxs.dll
  $wim_mountpoint/Windows/FOLDER_STUB/sxsstore.dll
  $wim_mountpoint/Windows/FOLDER_STUB/syssetup.dll
  $wim_mountpoint/Windows/FOLDER_STUB/thumbcache.dll
  $wim_mountpoint/Windows/FOLDER_STUB/twinapi.appcore.dll
  $wim_mountpoint/Windows/FOLDER_STUB/twinapi.dll
  $wim_mountpoint/Windows/FOLDER_STUB/tzres.dll
  $wim_mountpoint/Windows/FOLDER_STUB/uReFSv1.dll
  $wim_mountpoint/Windows/FOLDER_STUB/ucrtbase.dll
  $wim_mountpoint/Windows/FOLDER_STUB/ulib.dll
  $wim_mountpoint/Windows/FOLDER_STUB/umpdc.dll
  $wim_mountpoint/Windows/FOLDER_STUB/urlmon.dll
  $wim_mountpoint/Windows/FOLDER_STUB/user32.dll
  $wim_mountpoint/Windows/FOLDER_STUB/userenv.dll
  $wim_mountpoint/Windows/FOLDER_STUB/usp10.dll
  $wim_mountpoint/Windows/FOLDER_STUB/uxtheme.dll
  $wim_mountpoint/Windows/FOLDER_STUB/vbscript.dll
  $wim_mountpoint/Windows/FOLDER_STUB/version.dll
  $wim_mountpoint/Windows/FOLDER_STUB/virtdisk.dll
  $wim_mountpoint/Windows/FOLDER_STUB/vssapi.dll
  $wim_mountpoint/Windows/FOLDER_STUB/vsstrace.dll
  $wim_mountpoint/Windows/FOLDER_STUB/wcnwiz.dll
  $wim_mountpoint/Windows/FOLDER_STUB/wdscore.dll
  $wim_mountpoint/Windows/FOLDER_STUB/webio.dll
  $wim_mountpoint/Windows/FOLDER_STUB/wimgapi.dll
  $wim_mountpoint/Windows/FOLDER_STUB/win32u.dll
  $wim_mountpoint/Windows/FOLDER_STUB/winbrand.dll
  $wim_mountpoint/Windows/FOLDER_STUB/wincredui.dll
  $wim_mountpoint/Windows/FOLDER_STUB/windows.storage.dll
  $wim_mountpoint/Windows/FOLDER_STUB/winhttp.dll
  $wim_mountpoint/Windows/FOLDER_STUB/winhttpcom.dll
  $wim_mountpoint/Windows/FOLDER_STUB/winmm.dll
  $wim_mountpoint/Windows/FOLDER_STUB/winmmbase.dll
  $wim_mountpoint/Windows/FOLDER_STUB/winnlsres.dll
  $wim_mountpoint/Windows/FOLDER_STUB/winnsi.dll
  $wim_mountpoint/Windows/FOLDER_STUB/winspool.drv
  $wim_mountpoint/Windows/FOLDER_STUB/winsta.dll
  $wim_mountpoint/Windows/FOLDER_STUB/wintrust.dll
  $wim_mountpoint/Windows/FOLDER_STUB/wkscli.dll
  $wim_mountpoint/Windows/FOLDER_STUB/wldp.dll
  $wim_mountpoint/Windows/FOLDER_STUB/wmi.dll
  $wim_mountpoint/Windows/FOLDER_STUB/wmiclnt.dll
  $wim_mountpoint/Windows/FOLDER_STUB/wow32.dll
  $wim_mountpoint/Windows/FOLDER_STUB/ws2_32.dll
  $wim_mountpoint/Windows/FOLDER_STUB/wsock32.dll
  $wim_mountpoint/Windows/FOLDER_STUB/wtsapi32.dll


  $wim_mountpoint/Windows/FOLDER_STUB/en-US
  $wim_mountpoint/Windows/FOLDER_STUB/Dism
  $wim_mountpoint/Windows/FOLDER_STUB/SMI
  $wim_mountpoint/Windows/FOLDER_STUB/downlevel
  $wim_mountpoint/Windows/FOLDER_STUB/AdvancedInstallers
  "

  COMMON_FILES_GLOB="
  $wim_mountpoint/Windows/FOLDER_STUB/*.mui
  $wim_mountpoint/Windows/FOLDER_STUB/*client*
  $wim_mountpoint/Windows/FOLDER_STUB/*crypt*.dll
  $wim_mountpoint/Windows/FOLDER_STUB/*xml*
  $wim_mountpoint/Windows/FOLDER_STUB/C_*.NLS
  $wim_mountpoint/Windows/FOLDER_STUB/Windows*
  $wim_mountpoint/Windows/FOLDER_STUB/msi*
  $wim_mountpoint/Windows/FOLDER_STUB/msv*
  $wim_mountpoint/Windows/FOLDER_STUB/ole*
  $wim_mountpoint/Windows/FOLDER_STUB/rpc*
  $wim_mountpoint/Windows/FOLDER_STUB/wbem*
  $wim_mountpoint/Windows/FOLDER_STUB/windows*
  $wim_mountpoint/Windows/FOLDER_STUB/wininet*
  $wim_mountpoint/Windows/FOLDER_STUB/vcrun*
  $wim_mountpoint/Windows/FOLDER_STUB/ucrt*
  $wim_mountpoint/Windows/FOLDER_STUB/msvcp*
  "

  WOW64_FILES="
  $wim_mountpoint/Windows/SysWOW64/imageres.dll
  ${COMMON_FILES//FOLDER_STUB/SysWOW64}
  $(for glob in ${COMMON_FILES_GLOB//FOLDER_STUB/SysWOW64}
    do
      compgen -G "$glob"
    done)
  "

  SYSTEM32_FILES="
  $wim_mountpoint/Windows/System32/wow64.dll
  $wim_mountpoint/Windows/System32/wow64base.dll
  $wim_mountpoint/Windows/System32/wow64con.dll
  $wim_mountpoint/Windows/System32/wow64cpu.dll
  $wim_mountpoint/Windows/System32/wow64win.dll

  ${COMMON_FILES//FOLDER_STUB/System32}
  $(for glob in ${COMMON_FILES_GLOB//FOLDER_STUB/System32}
    do
      compgen -G "$glob"
    done)
  "

  DOTNET_FILES="
  $wim_mountpoint/Windows/assembly
  $wim_mountpoint/Windows/Microsoft.NET
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

get https://download.microsoft.com/download/6/D/F/6DF3FF94-F7F9-4F0B-838C-A328D1A7D0EE/vc_redist.x64.exe

#cp /home/user/Coding/minimal-winpe/install.py "$DOWNLOAD_DIR"


(wget https://github.com/lucasg/Dependencies/releases/download/v1.11.1/Dependencies_x64_Release.zip &&
unzip Dependencies_x64_Release.zip) &

add_wim_files &

wait $(jobs -p)

echo "$DOWNLOAD_DIR"
