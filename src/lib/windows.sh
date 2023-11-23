. "$(dirname "$0")/lib/common.sh"

add_windows_files() {
  local wim_mountpoint="$(mktemp -d)"
  local iso_mountpoint="$1"
  wimmount "$iso_mountpoint/sources/install.wim" 1 "$wim_mountpoint"

  local common_files=(
    CoreMessaging.dll
    CoreUIComponents.dll
    CredProv2faHelper.dll
    CredProvDataModel.dll
    D3D12.dll
    DWrite.dll
    DXCore.dll
    DataExchange.dll
    DbgModel.dll
    ExplorerFrame.dll
    FWPUCLNT.DLL
    FirewallAPI.dll
    FlightSettings.dll
    IPHLPAPI.DLL
    InputHost.dll
    KerbClientShared.dll
    KernelBase.dll
    KeyCredMgr.dll
    MMDevAPI.dll
    NetDriverInstall.dll
    NetSetupApi.dll
    NetSetupEngine.dll
    NtlmShared.dll
    OnDemandConnRouteHelper.dll
    OneCoreCommonProxyStub.dll
    OneCoreUAPCommonProxyStub.dll
    SHCore.dll
    SSShim.dll
    SensApi.dll
    ServicingCommon.dll
    StructuredQuery.dll
    TextInputFramework.dll
    TextShaping.dll
    TrustedSignalCredProv.dll
    UIAnimation.dll
    UIAutomationCore.dll
    VAN.dll
    WcnApi.dll
    WinTypes.dll
    WofUtil.dll
    aclui.dll
    activeds.dll
    actxprxy.dll
    adsldp.dll
    adsldpc.dll
    advapi32.dll
    amsi.dll
    apphelp.dll
    asycfilt.dll
    atlthunk.dll
    authui.dll
    authz.dll
    avifil32.dll
    avrt.dll
    browcli.dll
    cabinet.dll
    cfgmgr32.dll
    clbcatq.dll
    cmdext.dll
    combase.dll
    comctl32.dll
    console.dll
    credprovhost.dll
    credprovs.dll
    credprovslegacy.dll
    credssp.dll
    credui.dll
    crtdll.dll
    cscapi.dll
    d2d1.dll
    d3d10warp.dll
    d3d11.dll
    d3d9.dll
    davhlpr.dll
    dbgcore.dll
    dbgeng.dll
    dbghelp.dll
    dciman32.dll
    dcomp.dll
    ddraw.dll
    devenum.dll
    devicengccredprov.dll
    devobj.dll
    devrtl.dll
    dfscli.dll
    dfshim.dll
    dhcpcsvc.dll
    dhcpcsvc6.dll
    diagnosticdataquery.dll
    difxapi.dll
    directmanipulation.dll
    dlnashext.dll
    dnsapi.dll
    dpapi.dll
    drvsetup.dll
    drvstore.dll
    dsound.dll
    dsrole.dll
    dui70.dll
    duser.dll
    dwmapi.dll
    dxgi.dll
    edgegdi.dll
    edputil.dll
    eventcls.dll
    fdWCN.dll
    fltLib.dll
    framedynos.dll
    fveapi.dll
    fveapibase.dll
    fvecerts.dll
    fwbase.dll
    fwpolicyiomgr.dll
    gdi32.dll
    gdi32full.dll
    glu32.dll
    gpapi.dll
    hhctrl.ocx
    hid.dll
    ieframe.dll
    iertutil.dll
    imagehlp.dll
    imm32.dll
    kernel.appcore.dll
    kernel32.dll
    linkinfo.dll
    logoncli.dll
    lz32.dll
    mfc42.dll
    mfperfhelper.dll
    mibincodec.dll
    migration
    mimofcodec.dll
    mlang.dll
    mpr.dll
    msIso.dll
    msacm32.dll
    msacm32.drv
    msasn1.dll
    mscms.dll
    mscoree.dll
    mscorier.dll
    mscories.dll
    msctf.dll
    msdelta.dll
    msdmo.dll
    mshtml.dll
    msimsg.dll
    mskeyprotect.dll
    msls31.dll
    msvcrt.dll
    mswsock.dll
    ncobjapi.dll
    netapi32.dll
    netfxperf.dll
    netmsg.dll
    netutils.dll
    newdev.dll
    ngclocal.dll
    normaliz.dll
    nsi.dll
    ntasn1.dll
    ntdll.dll
    ntdsapi.dll
    ntlanman.dll
    ntmarta.dll
    ntshrui.dll
    odbc32.dll
    opengl32.dll
    pcacli.dll
    pdh.dll
    policymanager.dll
    powrprof.dll
    profapi.dll
    propsys.dll
    psapi.dll
    quartz.dll
    rasadhlp.dll
    rasapi32.dll
    riched20.dll
    riched32.dll
    rpcrt4.dll
    rpcss.dll
    rsaenh.dll
    rtutils.dll
    samcli.dll
    samlib.dll
    schannel.dll
    sechost.dll
    secur32.dll
    setupapi.dll
    sfc.dll
    sfc_os.dll
    shdocvw.dll
    shell32.dll
    shunimpl.dll
    shlwapi.dll
    slc.dll
    spapi.dll
    spfileq.dll
    spinf.dll
    spp.dll
    srpapi.dll
    srvcli.dll
    sspicli.dll
    sud.dll
    sxs.dll
    sxsstore.dll
    syssetup.dll
    thumbcache.dll
    twinapi.appcore.dll
    twinapi.dll
    tzres.dll
    uReFSv1.dll
    ulib.dll
    umpdc.dll
    urlmon.dll
    user32.dll
    userenv.dll
    usp10.dll
    uxtheme.dll
    vbscript.dll
    version.dll
    virtdisk.dll
    vssapi.dll
    vsstrace.dll
    wcnwiz.dll
    wdscore.dll
    webio.dll
    wimgapi.dll
    win32u.dll
    winbrand.dll
    wincredui.dll
    windows.storage.dll
    winhttp.dll
    winhttpcom.dll
    winmm.dll
    winmmbase.dll
    winnlsres.dll
    winnsi.dll
    winspool.drv
    winsta.dll
    wintrust.dll
    wkscli.dll
    wldp.dll
    wmi.dll
    wmiclnt.dll
    wow32.dll
    ws2_32.dll
    wsock32.dll
    wtsapi32.dll
    FntCache.dll

    regsvr32.exe
    msiexec.exe
    sc.exe

    en-US/
    Dism/
    SMI/
    downlevel/
    AdvancedInstallers/
  )

  local common_files_glob=(
    *.mui
    *client*
    *crypt*.dll
    *xml*
    C_*.NLS
    Windows*
    msi*
    msv*
    ole*
    rpc*
    wbem*
    windows*
    wininet*
    vcrun*
    ucrt*
    msvcp*
    Presentation*
  )

  local system_files=()

  for system_folder in SysWow64 System32
  do
    mapfile -t individual_files < \
      <(for path_template in "${common_files[@]}"
        do
          echo "$wim_mountpoint/Windows/$system_folder/$path_template"
        done)

    mapfile -t globbed_files < \
      <(for glob in "${common_files_glob[@]}"
        do
          compgen -G "$wim_mountpoint/Windows/$system_folder/$glob"
        done)

    system_files=("${system_files[@]}" "${individual_files[@]}" "${globbed_files[@]}")
  done

  system_files=(
    "${system_files[@]}"
    "$wim_mountpoint/Windows/System32/wow64.dll"
    "$wim_mountpoint/Windows/System32/wow64base.dll"
    "$wim_mountpoint/Windows/System32/wow64con.dll"
    "$wim_mountpoint/Windows/System32/wow64cpu.dll"
    "$wim_mountpoint/Windows/System32/wow64win.dll"
  )


  local dotnet_files=(
  "$wim_mountpoint"/Windows/assembly
  "$wim_mountpoint"/Windows/Microsoft.NET
  "$wim_mountpoint"/Program\ Files/Microsoft.NET
  "$wim_mountpoint"/Program\ Files/Reference\ Assemblies
  "$wim_mountpoint"/Program\ Files\ \(x86\)/Microsoft.NET
  "$wim_mountpoint"/Program\ Files\ \(x86\)/Reference\ Assemblies
  )

  mapfile -t winsxs_files < \
    <(for arch in amd64 x86
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

  local files_to_install=(
  "${system_files[@]}"
  "${dotnet_files[@]}"
  "${winsxs_files[@]}"
  "$wim_mountpoint"/Windows/apppatch
  "$wim_mountpoint"/Windows/servicing
  "$wim_mountpoint"/Windows/Installer
  )

  for fs_node in "${files_to_install[@]}"
  do
    cp_tree "$wim_mountpoint" "$fs_node" . &
    cp_pids="$cp_pids $!"
  done
  wait $cp_pids

  umount "$wim_mountpoint"
  rmdir "$wim_mountpoint"
}
