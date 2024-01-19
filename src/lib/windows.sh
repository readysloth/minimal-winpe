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
  )

  local common_files=(
    aclui.dll
    advapi32.dll
    advpack.dll
    atl100.dll
    avicap32.dll
    bcrypt.dll
    cabinet.dll
    combase.dll
    compstui.dll
    crypt32.dll
    cryptdlg.dll
    cryptnet.dll
    cryptui.dll
    dbghelp.dll
    devenum.dll
    dnsapi.dll
    dsound.dll
    dxgi.dll
    explorerframe.dll
    gdi32.dll
    gdi32full.dll
    ieframe.dll
    imagehlp.dll
    imm32.dll
    iphlpapi.dll
    kernel32.dll
    kernelbase.dll
    localspl.dll
    mfplat.dll
    mp3dmod.dll
    mpr.dll
    msacm32.dll
    mscoree.dll
    msdmo.dll
    mshtml.dll
    msi.dll
    msimg32.dll
    msisip.dll
    mspatcha.dll
    msvfw32.dll
    msxml3.dll
    newdev.dll
    nsi.dll
    ntdll.dll
    odbccp32.dll
    ole32.dll
    opengl32.dll
    propsys.dll
    qcap.dll
    qedit.dll
    quartz.dll
    rpcrt4.dll
    rsaenh.dll
    rtworkq.dll
    sechost.dll
    setupapi.dll
    sfc_os.dll
    shcore.dll
    shell32.dll
    shlwapi.dll
    spoolss.dll
    srclient.dll
    sxs.dll
    urlmon.dll
    user32.dll
    userenv.dll
    uxtheme.dll
    version.dll
    wevtsvc.dll
    win32u.dll
    windowscodecs.dll
    wininet.dll
    winmm.dll
    wintrust.dll
    ws2_32.dll
    wuapi.dll
    rpcss.dll
    kernel.appcore.dll
    cryptbase.dll
    dpapi.dll
    srpapi.dll
    tsappcmp.dll
    msimsg.dll
    msctf.dll
    textshaping.dll
    textinputframework.dll
    msxml3r.dll
    wintypes.dll
    cryptsp.dll
    coremessaging.dll
    msasn1.dll
    profapi.dll
    psapi.dll
    winnsi.dll
    dwmapi.dll
    ntmarta.dll
    feclient.dll
    srvcli.dll
    netutils.dll
    iertutil.dll
    edputil.dll
    cfgmgr32.dll
    propsys.dll
    wsock32.dll
    msihnd.dll
    pcacli.dll
    tsappcmp.dll
    apphelp.dll
    pwrshsip.dll
    pwrshplugin.dll
    netapi32.dll
    wshext.dll
    winhttp.dll
    riched20.dll
    riched32.dll
    windowscodecs.dll
    msheif.dll
    mswebp.dll
    msls31.dll
    usp10.dll
    policymanager.dll
    scrrun.dll
    uac.dll
    atl.dll
    atlthunk.dll
    clbcatq.dll
    secur32.dll
    sspicli.dll
    shutdownext.dll
    shfolder.dll
    wtsapi32.dll
    powrprof.dll
    iconcodecservice.dll
    dwrite.dll
    wkscli.dll
    netmsg.dll
    imageres.dll
    tzres.dll
    dinput.dll
    ddraw.dll
    winmm.dll
    dciman32.dll

    drvstore.dll
    dnsapi.dll
    devobj.dll
    devrtl.dll
    cscapi.dll
    spinf.dll
    netutils.dll
    newdev.dll
    mobilenetworking.dll
    joinutil.dll
    wofutil.dll
    samcli.dll
    fltlib.dll
    mscms.dll
    mswsock.dll
    glu32.dll
    ntdsapi.dll
    browseui.dll
    logoncli.dll
    umpdc.dll
    prnfldr.dll
    pdh.dll

    regsvr32.exe
    msiexec.exe
    shutdown.exe
    where.exe
    cmd.exe

    winspool.drv

    wow*
    msvcr*
    ucrt*
    msvcp*
    vcruntime*
    d3d*
    dx*
    ole*
    wlan*
    cert*
    msvbvm*
    windows.*
    twinapi*
    xml*

    en-US
    downlevel
    wbem
    windowspowershell
    driverstore
    drivers
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
