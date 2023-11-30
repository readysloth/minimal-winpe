. "$(dirname "$0")/lib/common.sh"

export_key() {
  local file="$1"
  local key="$2"
  key_ptr="$key"
  upper_keys=
  while echo $key_ptr | grep -F \\ &>/dev/null
  do
    key_ptr="$(echo "$key_ptr" | sed 's/\\[^\\]*$//')"
    upper_keys="[\\$key_ptr] $upper_keys"
  done

  local text="$(echo "$upper_keys" | sed -e 's@\\@&&@g' -e 's@\] \[@]\\n\\n[@g')"
  hivexregedit --export "$file" "$2" | sed -e "1a\\$text"
}


export_multiple() {
  local file="$1"
  shift
  for key in "$@"
  do
    export_key "$file" "$key" | sed '/Windows Registry Editor/d'
  done | sed '1i\Windows Registry Editor Version 5.00'
}


merge_registry() {
  local file="$1"
  local prefix="$2"
  hivexregedit \
    --merge "$file" \
    --prefix "$prefix"
}


export_multiple_and_merge() {
  local prefix="$1"
  local from="$2"
  local to="$3"
  shift 3

  export_multiple "$from" "$@" | merge_registry "$to" "$prefix"
}


change_registry() {
  local system="Windows/System32/config/SYSTEM"
  local software="Windows/System32/config/SOFTWARE"
  local drivers="Windows/System32/config/DRIVERS"

  local wim_mountpoint="$(mktemp -d)"
  local wim_build_mountpoint="$(mktemp -d)"

  local default_wim="$1"
  local iso_mountpoint="$2"
  wimmount "$iso_mountpoint/sources/install.wim" 1 "$wim_mountpoint"
  wimmountrw "$default_wim" "$wim_build_mountpoint"

  local software_wow6432_branches=(
  WOW6432Node
  Microsoft\\Wow64
  Microsoft\\Windows\\CurrentVersion\\SideBySide
  Microsoft\\Windows\\CurrentVersion\\SMI
  Microsoft\\Windows\ NT\\CurrentVersion\\Image\ File\ Execution\ Options
  )

  local msi_guid_start=000C10
  local msi_guid_end=-0000-0000-C000-000000000046
  local msi_interface_bytes=(1C 1D 3E 25 33 90 92 93 94 95 96 97 98 99 9A 9B 9C 9D 9E 9F A0 A1)
  #local byterange=({0..9}{0..9} {0..9}{A..F} {A..F}{0..9} {A..F}{A..F})
  mapfile -t msi_guids < \
    <(for byte in "${msi_interface_bytes[@]}"
      do
        echo "${msi_guid_start}${byte}${msi_guid_end}"
      done)

  mapfile -t classes_msi_branches < \
    <(for guid in "${msi_guids[@]}"
      do
        echo "Classes\\Wow6432Node\\AppID\\{$guid}"
        echo "Classes\\Wow6432Node\\CLSID\\{$guid}"
        echo "Classes\\Wow6432Node\\TypeLib\\{$guid}"
        echo "Classes\\Wow6432Node\\Interface\\{$guid}"
        echo "Classes\\AppID\\{$guid}"
        echo "Classes\\CLSID\\{$guid}"
        echo "Classes\\TypeLib\\{$guid}"
        echo "Classes\\Interface\\{$guid}"
      done)

  local software_msxml_branches=(
    Classes\\CLSID\\\{F6D90F11-9C73-11D3-B32E-00C04F990BB4\}
    Classes\\Wow6432Node\\CLSID\\\{F6D90F11-9C73-11D3-B32E-00C04F990BB4\}
    Classes\\CLSID\\\{F6D90F14-9C73-11D3-B32E-00C04F990BB4\}
    Classes\\Wow6432Node\\CLSID\\\{F6D90F14-9C73-11D3-B32E-00C04F990BB4\}
    Classes\\CLSID\\\{F5078F32-C551-11D3-89B9-0000F81FE221\}
    Classes\\Wow6432Node\\CLSID\\\{F5078F32-C551-11D3-89B9-0000F81FE221\}
  )

  local software_msi_branches=(
  Classes\\.msi
  Classes\\.msp
  Classes\\IMsiServer
  Classes\\Msi.Package
  Classes\\Msi.Patch
  Classes\\WindowsInstaller.Message
  Classes\\WindowsInstaller.Installer
  Classes\\CLSID\\\{BE0A9830-2B8B-11D1-A949-0060181EBBAD\}
  Microsoft\\Windows\\CurrentVersion\\Installer
  Microsoft\\Cryptography
  "${classes_msi_branches[@]}"
  "${software_msxml_branches[@]}"
  )

  local system_msi_branches=(
    ControlSet001\\Services\\msiserver
    ControlSet001\\Services\\TrustedInstaller
    ControlSet001\\Services\\eventlog
  )

  local software_dotnet_branches=(
    Microsoft\\Fusion
    Microsoft\\.NETFramework
    Microsoft\\NET\ Framework\ Setup
    Microsoft\\ASP.NET
    Microsoft\\DevDiv
    Microsoft\\MSBuild
  )

  local system_dotnet_branches=(
    ControlSet001\\VSS
    ControlSet001\\Services\\FontCache
    ControlSet001\\Services\\.NET\ CLR\ {Data,Networking}
    ControlSet001\\SharedAccess
    ControlSet001\\W32Time
  )

  export_multiple_and_merge \
    'HKEY_LOCAL_MACHINE\Software' \
    "$wim_mountpoint/$software" \
    "$wim_build_mountpoint/$software" \
    "${software_wow6432_branches[@]}" \
    "${software_msi_branches[@]}" \
    "${software_dotnet_branches[@]}" \
    &
  local merge_pids="$merge_pids $!"

  export_multiple_and_merge \
    'HKEY_LOCAL_MACHINE\System' \
    "$wim_mountpoint/$system" \
    "$wim_build_mountpoint/$system" \
    "${system_msi_branches[@]}" \
    "${system_dotnet_branches[@]}" \
    &
  merge_pids="$merge_pids $!"

  wait $merge_pids

  cp_tree "$wim_build_mountpoint" "$wim_build_mountpoint/$system" .
  cp_tree "$wim_build_mountpoint" "$wim_build_mountpoint/$software" .
  cp_tree "$wim_build_mountpoint" "$wim_build_mountpoint/$drivers" .

  umount "$wim_mountpoint"
  umount "$wim_build_mountpoint"
  rmdir "$wim_mountpoint"
  rmdir "$wim_build_mountpoint"
}
