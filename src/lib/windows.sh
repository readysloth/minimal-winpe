. "$(dirname "$0")/lib/common.sh"

add_windows_files() {
  local wim_mountpoint="$(mktemp -d)"
  local iso_mountpoint="$1"
  wimmount "$iso_mountpoint/sources/install.wim" 1 "$wim_mountpoint"

  local STUB_PREFIX="$wim_mountpoint/Windows/FOLDER_STUB"
  local COMMON_FILES="
  $STUB_PREFIX/CoreMessaging.dll
  $STUB_PREFIX/CoreUIComponents.dll
  $STUB_PREFIX/CredProv2faHelper.dll
  $STUB_PREFIX/CredProvDataModel.dll
  $STUB_PREFIX/D3D12.dll
  $STUB_PREFIX/DWrite.dll
  $STUB_PREFIX/DXCore.dll
  $STUB_PREFIX/DataExchange.dll
  $STUB_PREFIX/DbgModel.dll
  $STUB_PREFIX/ExplorerFrame.dll
  $STUB_PREFIX/FWPUCLNT.DLL
  $STUB_PREFIX/FirewallAPI.dll
  $STUB_PREFIX/FlightSettings.dll
  $STUB_PREFIX/IPHLPAPI.DLL
  $STUB_PREFIX/InputHost.dll
  $STUB_PREFIX/KerbClientShared.dll
  $STUB_PREFIX/KernelBase.dll
  $STUB_PREFIX/KeyCredMgr.dll
  $STUB_PREFIX/MMDevAPI.dll
  $STUB_PREFIX/NetDriverInstall.dll
  $STUB_PREFIX/NetSetupApi.dll
  $STUB_PREFIX/NetSetupEngine.dll
  $STUB_PREFIX/NtlmShared.dll
  $STUB_PREFIX/OnDemandConnRouteHelper.dll
  $STUB_PREFIX/OneCoreCommonProxyStub.dll
  $STUB_PREFIX/OneCoreUAPCommonProxyStub.dll
  $STUB_PREFIX/PresentationHostProxy.dll
  $STUB_PREFIX/SHCore.dll
  $STUB_PREFIX/SSShim.dll
  $STUB_PREFIX/SensApi.dll
  $STUB_PREFIX/ServicingCommon.dll
  $STUB_PREFIX/StructuredQuery.dll
  $STUB_PREFIX/TextInputFramework.dll
  $STUB_PREFIX/TextShaping.dll
  $STUB_PREFIX/TrustedSignalCredProv.dll
  $STUB_PREFIX/UIAnimation.dll
  $STUB_PREFIX/UIAutomationCore.dll
  $STUB_PREFIX/VAN.dll
  $STUB_PREFIX/WcnApi.dll
  $STUB_PREFIX/WinTypes.dll
  $STUB_PREFIX/Windows.UI.dll
  $STUB_PREFIX/WofUtil.dll
  $STUB_PREFIX/aclui.dll
  $STUB_PREFIX/activeds.dll
  $STUB_PREFIX/actxprxy.dll
  $STUB_PREFIX/adsldp.dll
  $STUB_PREFIX/adsldpc.dll
  $STUB_PREFIX/advapi32.dll
  $STUB_PREFIX/amsi.dll
  $STUB_PREFIX/apphelp.dll
  $STUB_PREFIX/asycfilt.dll
  $STUB_PREFIX/atlthunk.dll
  $STUB_PREFIX/authui.dll
  $STUB_PREFIX/authz.dll
  $STUB_PREFIX/avifil32.dll
  $STUB_PREFIX/avrt.dll
  $STUB_PREFIX/browcli.dll
  $STUB_PREFIX/cabinet.dll
  $STUB_PREFIX/cfgmgr32.dll
  $STUB_PREFIX/clbcatq.dll
  $STUB_PREFIX/cmdext.dll
  $STUB_PREFIX/combase.dll
  $STUB_PREFIX/comctl32.dll
  $STUB_PREFIX/console.dll
  $STUB_PREFIX/credprovhost.dll
  $STUB_PREFIX/credprovs.dll
  $STUB_PREFIX/credprovslegacy.dll
  $STUB_PREFIX/credssp.dll
  $STUB_PREFIX/credui.dll
  $STUB_PREFIX/crtdll.dll
  $STUB_PREFIX/cscapi.dll
  $STUB_PREFIX/d2d1.dll
  $STUB_PREFIX/d3d10warp.dll
  $STUB_PREFIX/d3d11.dll
  $STUB_PREFIX/d3d9.dll
  $STUB_PREFIX/davhlpr.dll
  $STUB_PREFIX/dbgcore.dll
  $STUB_PREFIX/dbgeng.dll
  $STUB_PREFIX/dbghelp.dll
  $STUB_PREFIX/dciman32.dll
  $STUB_PREFIX/dcomp.dll
  $STUB_PREFIX/ddraw.dll
  $STUB_PREFIX/devenum.dll
  $STUB_PREFIX/devicengccredprov.dll
  $STUB_PREFIX/devobj.dll
  $STUB_PREFIX/devrtl.dll
  $STUB_PREFIX/dfscli.dll
  $STUB_PREFIX/dfshim.dll
  $STUB_PREFIX/dhcpcsvc.dll
  $STUB_PREFIX/dhcpcsvc6.dll
  $STUB_PREFIX/diagnosticdataquery.dll
  $STUB_PREFIX/difxapi.dll
  $STUB_PREFIX/directmanipulation.dll
  $STUB_PREFIX/dlnashext.dll
  $STUB_PREFIX/dnsapi.dll
  $STUB_PREFIX/dpapi.dll
  $STUB_PREFIX/drvsetup.dll
  $STUB_PREFIX/drvstore.dll
  $STUB_PREFIX/dsound.dll
  $STUB_PREFIX/dsrole.dll
  $STUB_PREFIX/dui70.dll
  $STUB_PREFIX/duser.dll
  $STUB_PREFIX/dwmapi.dll
  $STUB_PREFIX/dxgi.dll
  $STUB_PREFIX/edgegdi.dll
  $STUB_PREFIX/edputil.dll
  $STUB_PREFIX/eventcls.dll
  $STUB_PREFIX/fdWCN.dll
  $STUB_PREFIX/fltLib.dll
  $STUB_PREFIX/framedynos.dll
  $STUB_PREFIX/fveapi.dll
  $STUB_PREFIX/fveapibase.dll
  $STUB_PREFIX/fvecerts.dll
  $STUB_PREFIX/fwbase.dll
  $STUB_PREFIX/fwpolicyiomgr.dll
  $STUB_PREFIX/gdi32.dll
  $STUB_PREFIX/gdi32full.dll
  $STUB_PREFIX/glu32.dll
  $STUB_PREFIX/gpapi.dll
  $STUB_PREFIX/hhctrl.ocx
  $STUB_PREFIX/hid.dll
  $STUB_PREFIX/ieframe.dll
  $STUB_PREFIX/iertutil.dll
  $STUB_PREFIX/imagehlp.dll
  $STUB_PREFIX/imm32.dll
  $STUB_PREFIX/kernel.appcore.dll
  $STUB_PREFIX/kernel32.dll
  $STUB_PREFIX/linkinfo.dll
  $STUB_PREFIX/logoncli.dll
  $STUB_PREFIX/lz32.dll
  $STUB_PREFIX/mfc42.dll
  $STUB_PREFIX/mfperfhelper.dll
  $STUB_PREFIX/mibincodec.dll
  $STUB_PREFIX/migration
  $STUB_PREFIX/mimofcodec.dll
  $STUB_PREFIX/mlang.dll
  $STUB_PREFIX/mpr.dll
  $STUB_PREFIX/msIso.dll
  $STUB_PREFIX/msacm32.dll
  $STUB_PREFIX/msacm32.drv
  $STUB_PREFIX/msasn1.dll
  $STUB_PREFIX/mscms.dll
  $STUB_PREFIX/mscoree.dll
  $STUB_PREFIX/mscorier.dll
  $STUB_PREFIX/mscories.dll
  $STUB_PREFIX/msctf.dll
  $STUB_PREFIX/msdelta.dll
  $STUB_PREFIX/msdmo.dll
  $STUB_PREFIX/mshtml.dll
  $STUB_PREFIX/msimsg.dll
  $STUB_PREFIX/mskeyprotect.dll
  $STUB_PREFIX/msls31.dll
  $STUB_PREFIX/msvcrt.dll
  $STUB_PREFIX/mswsock.dll
  $STUB_PREFIX/ncobjapi.dll
  $STUB_PREFIX/netapi32.dll
  $STUB_PREFIX/netfxperf.dll
  $STUB_PREFIX/netmsg.dll
  $STUB_PREFIX/netutils.dll
  $STUB_PREFIX/newdev.dll
  $STUB_PREFIX/ngclocal.dll
  $STUB_PREFIX/normaliz.dll
  $STUB_PREFIX/nsi.dll
  $STUB_PREFIX/ntasn1.dll
  $STUB_PREFIX/ntdll.dll
  $STUB_PREFIX/ntdsapi.dll
  $STUB_PREFIX/ntlanman.dll
  $STUB_PREFIX/ntmarta.dll
  $STUB_PREFIX/ntshrui.dll
  $STUB_PREFIX/odbc32.dll
  $STUB_PREFIX/opengl32.dll
  $STUB_PREFIX/pcacli.dll
  $STUB_PREFIX/pdh.dll
  $STUB_PREFIX/policymanager.dll
  $STUB_PREFIX/powrprof.dll
  $STUB_PREFIX/profapi.dll
  $STUB_PREFIX/propsys.dll
  $STUB_PREFIX/psapi.dll
  $STUB_PREFIX/quartz.dll
  $STUB_PREFIX/rasadhlp.dll
  $STUB_PREFIX/rasapi32.dll
  $STUB_PREFIX/riched20.dll
  $STUB_PREFIX/riched32.dll
  $STUB_PREFIX/rpcrt4.dll
  $STUB_PREFIX/rpcss.dll
  $STUB_PREFIX/rsaenh.dll
  $STUB_PREFIX/rtutils.dll
  $STUB_PREFIX/samcli.dll
  $STUB_PREFIX/samlib.dll
  $STUB_PREFIX/schannel.dll
  $STUB_PREFIX/sechost.dll
  $STUB_PREFIX/secur32.dll
  $STUB_PREFIX/setupapi.dll
  $STUB_PREFIX/sfc.dll
  $STUB_PREFIX/sfc_os.dll
  $STUB_PREFIX/shdocvw.dll
  $STUB_PREFIX/shell32.dll
  $STUB_PREFIX/shunimpl.dll
  $STUB_PREFIX/shlwapi.dll
  $STUB_PREFIX/slc.dll
  $STUB_PREFIX/spapi.dll
  $STUB_PREFIX/spfileq.dll
  $STUB_PREFIX/spinf.dll
  $STUB_PREFIX/spp.dll
  $STUB_PREFIX/srpapi.dll
  $STUB_PREFIX/srvcli.dll
  $STUB_PREFIX/sspicli.dll
  $STUB_PREFIX/sud.dll
  $STUB_PREFIX/sxs.dll
  $STUB_PREFIX/sxsstore.dll
  $STUB_PREFIX/syssetup.dll
  $STUB_PREFIX/thumbcache.dll
  $STUB_PREFIX/twinapi.appcore.dll
  $STUB_PREFIX/twinapi.dll
  $STUB_PREFIX/tzres.dll
  $STUB_PREFIX/uReFSv1.dll
  $STUB_PREFIX/ucrtbase.dll
  $STUB_PREFIX/ulib.dll
  $STUB_PREFIX/umpdc.dll
  $STUB_PREFIX/urlmon.dll
  $STUB_PREFIX/user32.dll
  $STUB_PREFIX/userenv.dll
  $STUB_PREFIX/usp10.dll
  $STUB_PREFIX/uxtheme.dll
  $STUB_PREFIX/vbscript.dll
  $STUB_PREFIX/version.dll
  $STUB_PREFIX/virtdisk.dll
  $STUB_PREFIX/vssapi.dll
  $STUB_PREFIX/vsstrace.dll
  $STUB_PREFIX/wcnwiz.dll
  $STUB_PREFIX/wdscore.dll
  $STUB_PREFIX/webio.dll
  $STUB_PREFIX/wimgapi.dll
  $STUB_PREFIX/win32u.dll
  $STUB_PREFIX/winbrand.dll
  $STUB_PREFIX/wincredui.dll
  $STUB_PREFIX/windows.storage.dll
  $STUB_PREFIX/winhttp.dll
  $STUB_PREFIX/winhttpcom.dll
  $STUB_PREFIX/winmm.dll
  $STUB_PREFIX/winmmbase.dll
  $STUB_PREFIX/winnlsres.dll
  $STUB_PREFIX/winnsi.dll
  $STUB_PREFIX/winspool.drv
  $STUB_PREFIX/winsta.dll
  $STUB_PREFIX/wintrust.dll
  $STUB_PREFIX/wkscli.dll
  $STUB_PREFIX/wldp.dll
  $STUB_PREFIX/wmi.dll
  $STUB_PREFIX/wmiclnt.dll
  $STUB_PREFIX/wow32.dll
  $STUB_PREFIX/ws2_32.dll
  $STUB_PREFIX/wsock32.dll
  $STUB_PREFIX/wtsapi32.dll

  $STUB_PREFIX/regsvr32.exe
  $STUB_PREFIX/msiexec.exe
  $STUB_PREFIX/sc.exe

  $STUB_PREFIX/en-US/
  $STUB_PREFIX/Dism/
  $STUB_PREFIX/SMI/
  $STUB_PREFIX/downlevel/
  $STUB_PREFIX/AdvancedInstallers/
  "

  local COMMON_FILES_GLOB="
  $STUB_PREFIX/*.mui
  $STUB_PREFIX/*client*
  $STUB_PREFIX/*crypt*.dll
  $STUB_PREFIX/*xml*
  $STUB_PREFIX/C_*.NLS
  $STUB_PREFIX/Windows*
  $STUB_PREFIX/msi*
  $STUB_PREFIX/msv*
  $STUB_PREFIX/ole*
  $STUB_PREFIX/rpc*
  $STUB_PREFIX/wbem*
  $STUB_PREFIX/windows*
  $STUB_PREFIX/wininet*
  $STUB_PREFIX/vcrun*
  $STUB_PREFIX/ucrt*
  $STUB_PREFIX/msvcp*
  "

  local WOW64_FILES="
  $wim_mountpoint/Windows/SysWOW64/imageres.dll
  ${COMMON_FILES//FOLDER_STUB/SysWOW64}
  $(for glob in ${COMMON_FILES_GLOB//FOLDER_STUB/SysWOW64}
    do
      compgen -G "$glob"
    done)
  "

  local SYSTEM32_FILES="
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

  local DOTNET_FILES="
  $wim_mountpoint/Windows/assembly
  $wim_mountpoint/Windows/Microsoft.NET
  "

  local WINSXS_FILES="
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
        '*ntdll*' \
        'i..xecutable.resources*'
      do
        compgen -G "$wim_mountpoint/Windows/WinSxS/${arch}_microsoft-windows-$package"
        compgen -G "$wim_mountpoint/Windows/WinSxS/${arch}_microsoft.windows.$package"
        compgen -G "$wim_mountpoint/Windows/WinSxS/Manifests/${arch}_microsoft.windows.$package"
      done
    done)
  "
  local FILES_TO_INSTALL="
  $WOW64_FILES
  $SYSTEM32_FILES
  $WINSXS_FILES
  $DOTNET_FILES
  $wim_mountpoint/Windows/apppatch
  $wim_mountpoint/Windows/servicing
  $wim_mountpoint/Windows/Installer
  "

  for fs_node in $FILES_TO_INSTALL
  do
    cp_tree "$wim_mountpoint" "$fs_node" . &
    cp_pids="$cp_pids $!"
  done
  wait $cp_pids

  umount "$wim_mountpoint"
  rmdir "$wim_mountpoint"
}
