. "$(dirname "$0")/lib/common.sh"

add_windows_files() {
  local wim_mountpoint
  wim_mountpoint="$(mktemp -d)"
  local iso_mountpoint="$1"
  local callback="${2:-:}"
  wimmount "$iso_mountpoint/sources/install.wim" 1 "$wim_mountpoint"

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
    msvcrt.dll
    msvcp_win.dll
    msvfw32.dll
    msxml3.dll
    newdev.dll
    nsi.dll
    ntdll.dll
    odbccp32.dll
    ole32.dll
    oleaut32.dll
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
    ucrtbase.dll
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

    regsvr32.exe
    msiexec.exe

    wow*
  )

  local FIND
  local find_args
  find_args="$(for file in "${common_files[@]}"; do printf " -o -iname '$file' "; done)"
  find_args="${find_args/-o/}"

  FIND+=("find '$wim_mountpoint/Windows/SysWOW64' -maxdepth 1 $find_args")
  FIND+=("find '$wim_mountpoint/Windows/System32' -maxdepth 1 $find_args")

  find_args="$(for arch in amd64 x86 wow64
               do
                 for package in \
                  ucrt \
                  common-controls \
                  isolationautomation \
                  i..utomation.proxystub \
                  systemcompatible
                 do
                   printf " -o -iname '${arch}_microsoft*$package*' -o -iname '${arch}_policy*$package*' "
                 done
               done)"
  find_args="${find_args/-o/}"
  FIND+=("find '$wim_mountpoint/Windows/WinSxS/' -maxdepth 2 -type d $find_args")

  mapfile -t files_to_install < \
    <(local parallel_outputs=()
      local find_pids=()
      for find_cmd in "${FIND[@]}"
      do
        local parallel_output
        parallel_output="$(mktemp)"
        parallel_outputs=("${parallel_outputs[@]}" "$parallel_output")
        eval "$find_cmd" > "$parallel_output" &
        find_pids=("${find_pids[@]}" "$!")
      done
      wait "${find_pids[@]}"
      cat "${parallel_outputs[@]}"
      rm "${parallel_outputs[@]}")


  printf '%s\n' "${files_to_install[@]}" > /tmp/files

  for fs_node in "${files_to_install[@]}"
  do
    cp_tree "$wim_mountpoint" "$fs_node" . "$callback" &
    cp_pids="$cp_pids $!"
  done
  wait $cp_pids

  umount "$wim_mountpoint"
  rmdir "$wim_mountpoint"
}
