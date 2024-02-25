. "$(dirname "$0")/lib/common.sh"

format_filenames_for_find() {
  find_opts="$(printf " -o -iname %s " "$@")"
  echo "${find_opts/-o/}"
}

find_files_cmd() {
  local src_folder="$1"
  shift
  local args="$*"
  echo "find '$src_folder' $args"
}

parallel_get_filelist() {
  local cmd_array=("$@")
  local parallel_outputs=()
  local find_pids=()
  for cmd in "${cmd_array[@]}"
  do
    local parallel_output
    parallel_output="$(mktemp)"
    parallel_outputs=("${parallel_outputs[@]}" "$parallel_output")
    eval "$cmd" > "$parallel_output" &
    find_pids=("${find_pids[@]}" "$!")
  done
  wait "${find_pids[@]}"
  cat "${parallel_outputs[@]}"
  rm -rf "${parallel_outputs[@]}"
}

windows_filelist() {
  local wim_mountpoint="$1"
  local bad_dlls=(
    comctl32.dll
    comdlg32.dll
    gdiplus.dll
    wldap32.dll
  )

  local common_files=(
    aclui.dll
    advapi32.dll
    advpack.dll
    apphelp.dll
    atl.dll
    atl100.dll
    atlthunk.dll
    avicap32.dll
    bcrypt.dll
    browseui.dll
    cabinet.dll
    cfgmgr32.dll
    clbcatq.dll
    cldapi.dll
    combase.dll
    compstui.dll
    coremessaging.dll
    crypt32.dll
    cryptbase.dll
    cryptdlg.dll
    cryptnet.dll
    cryptsp.dll
    cryptui.dll
    cscapi.dll
    dbghelp.dll
    dciman32.dll
    ddraw.dll
    devenum.dll
    devobj.dll
    devrtl.dll
    dnsapi.dll
    dpapi.dll
    drvstore.dll
    dsound.dll
    dwmapi.dll
    dwrite.dll
    dxgi.dll
    edputil.dll
    efswrt.dll
    explorerframe.dll
    feclient.dll
    fltlib.dll
    gdi32.dll
    gdi32full.dll
    glu32.dll
    iconcodecservice.dll
    ieframe.dll
    iertutil.dll
    imagehlp.dll
    imageres.dll
    imm32.dll
    iphlpapi.dll
    joinutil.dll
    kernel.appcore.dll
    kernel32.dll
    kernelbase.dll
    localspl.dll
    logoncli.dll
    mfplat.dll
    mobilenetworking.dll
    mp3dmod.dll
    mpr.dll
    msacm32.dll
    msasn1.dll
    mscms.dll
    mscoree.dll
    mscories.dll
    msctf.dll
    msdmo.dll
    msheif.dll
    mshtml.dll
    msi.dll
    msihnd.dll
    msimg32.dll
    msimsg.dll
    msisip.dll
    msls31.dll
    mspatcha.dll
    mswebp.dll
    mswsock.dll
    msxml3.dll
    msxml3r.dll
    netapi32.dll
    netmsg.dll
    netutils.dll
    newdev.dll
    nsi.dll
    ntdll.dll
    ntdsapi.dll
    ntmarta.dll
    odbccp32.dll
    ole32.dll
    opengl32.dll
    pcacli.dll
    pdh.dll
    policymanager.dll
    powrprof.dll
    prnfldr.dll
    profapi.dll
    propsys.dll
    psapi.dll
    pwrshplugin.dll
    pwrshsip.dll
    qcap.dll
    qedit.dll
    quartz.dll
    riched20.dll
    riched32.dll
    rpcrt4.dll
    rpcss.dll
    rsaenh.dll
    rtworkq.dll
    samcli.dll
    scrrun.dll
    sechost.dll
    secur32.dll
    setupapi.dll
    sfc_os.dll
    shcore.dll
    shell32.dll
    shfolder.dll
    shlwapi.dll
    shutdownext.dll
    spinf.dll
    spoolss.dll
    srclient.dll
    srpapi.dll
    srvcli.dll
    sspicli.dll
    sxs.dll
    textinputframework.dll
    textshaping.dll
    tsappcmp.dll
    tzres.dll
    uac.dll
    umpdc.dll
    urlmon.dll
    user32.dll
    userenv.dll
    usp10.dll
    uxtheme.dll
    version.dll
    wevtsvc.dll
    win32u.dll
    windowscodecs.dll
    windowscodecsext.dll
    winhttp.dll
    wininet.dll
    winmm.dll
    winnsi.dll
    wintrust.dll
    wintypes.dll
    wkscli.dll
    wofutil.dll
    ws2_32.dll
    wshext.dll
    wsock32.dll
    wtsapi32.dll
    wuapi.dll
    resampledmo.dll
    acledit.dll
    activeds.dll
    actxprxy.dll
    adsldp.dll
    adsldpc.dll
    amsi.dll
    amstream.dll
    apisetschema.dll
    appxdeploymentclient.dll
    atmlib.dll
    authz.dll
    avifil32.dll
    avifile.dll
    avrt.dll
    bluetoothapis.dll
    cards.dll
    cdosys.dll
    clusapi.dll
    comcat.dll
    commdlg.dll
    compobj.dll
    comsvcs.dll
    concrt140.dll
    connect.dll
    credui.dll
    crtdll.dll
    cryptdll.dll
    cryptext.dll
    cryptowinrt.dll
    ctapi32.dll
    d2d1.dll
    davclnt.dll
    dbgeng.dll
    dcomp.dll
    ddrawex.dll
    dhcpcsvc.dll
    dhcpcsvc6.dll
    difxapi.dll
    directmanipulation.dll
    dispdib.dll
    dispex.dll
    dmband.dll
    dmcompos.dll
    dmime.dll
    dmloader.dll
    dmscript.dll
    dmstyle.dll
    dmsynth.dll
    dmusic.dll
    dmusic32.dll
    dplay.dll
    dplayx.dll
    dpnaddr.dll
    dpnet.dll
    dpnhpast.dll
    dpnhupnp.dll
    dpnlobby.dll
    dpvoice.dll
    dpwsockx.dll
    dsdmo.dll
    dsquery.dll
    dssenh.dll
    dsuiext.dll
    dswave.dll
    esent.dll
    evr.dll
    faultrep.dll
    hid.dll
    jsproxy.dll
    kerberos.dll
    mfreadwrite.dll
    mmdevapi.dll
    normaliz.dll
    url.dll
    fwpuclnt.dll
    wbemcomn.dll
    winmmbase.dll
    mstask.dll
    shellstyle.dll
    appresolver.dll
    framedynos.dll
    msiso.dll

    regsvr32.exe
    msiexec.exe
    shutdown.exe
    where.exe
    cmd.exe
    timeout.exe
    netsh.exe
    openwith.exe

    winspool.drv

    wow*
    ucrt*
    msv*
    vcruntime*
    d3d*
    dx*
    ole*
    wlan*
    cert*
    windows.*
    twinapi*
    xml*
    input*
    dinput*
    ondemand*
    rasa*
    xinput*
    dism*
    task*
    mfc*
    catsrv*
    netprof*
    *.ocx

    en-US
    downlevel
    wbem
    windowspowershell
    driverstore
    drivers
    dism
    com
  )

  local sxs_globs=(
{amd64,\
x86,\
wow64,\
x86_wpf,\
amd64_wpf,\
msil}\
*\
{\
ucrt,\
common-controls,\
isolationautomation,\
i..utomation.proxystub,\
systemcompatible,\
presentationframework,\
windowsbase,\
comdlg32,\
msiprovider,\
powershell\
}\
*
  )

  mapfile -t find_cmds < \
    <(find_files_cmd "$wim_mountpoint/Windows/SysWOW64" -maxdepth 1 "$(format_filenames_for_find "${bad_dlls[@]}")";
      find_files_cmd "$wim_mountpoint/Windows/System32" -maxdepth 1 "$(format_filenames_for_find "${bad_dlls[@]}")")
  parallel_get_filelist "${find_cmds[@]}" | sed 's/.*/&->postinstall_tree/'

  mapfile -t find_cmds < \
    <(find_files_cmd "$wim_mountpoint/Windows/SysWOW64" -maxdepth 1 "$(format_filenames_for_find "${common_files[@]}")";
      find_files_cmd "$wim_mountpoint/Windows/System32" -maxdepth 1 "$(format_filenames_for_find "${common_files[@]}")";
      find_files_cmd "$wim_mountpoint/Windows/WinSxS" -maxdepth 2 -type d "$(format_filenames_for_find "${sxs_globs[@]}")";)
  parallel_get_filelist "${find_cmds[@]}" | sed 's/.*/&->./'

  cat <<EOF
$wim_mountpoint/Windows/SystemResources->.
$wim_mountpoint/Windows/Microsoft.NET->.
$wim_mountpoint/Windows/assembly->.
$wim_mountpoint/Windows/Fonts->.
$wim_mountpoint/Windows/Installer->.
$wim_mountpoint/Windows/INF->.
EOF
}

add_windows_files() {
  local wim_mountpoint
  wim_mountpoint="$(mktemp -d)"
  local iso_mountpoint="$1"
  local callback="${2:-:}"
  local cp_pids=()
  wimmount "$iso_mountpoint/sources/install.wim" 1 "$wim_mountpoint"

  local filelist
  filelist="$(mktemp)"
  windows_filelist "$wim_mountpoint" > "$filelist"
  mapfile -t copy_nodes < "$filelist"
  rm "$filelist"

  regex='(.*)->(.*)'
  for src_dest in "${copy_nodes[@]}"
  do
    [[ "$src_dest" =~ $regex ]]
    local src="${BASH_REMATCH[1]}"
    local dest="${BASH_REMATCH[2]}"
    cp_tree "$wim_mountpoint" "$src" "$dest" "$callback" &
    cp_pids+=($!)
  done
  wait "${cp_pids[@]}"

  umount "$wim_mountpoint"
  rmdir "$wim_mountpoint"
}
