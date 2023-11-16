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

  local wim_mountpoint="$(mktemp -d)"
  local wim_build_mountpoint="$(mktemp -d)"

  local default_wim="$1"
  local iso_mountpoint="$2"
  wimmount "$iso_mountpoint/sources/install.wim" 1 "$wim_mountpoint"
  wimmountrw "$default_wim" "$wim_build_mountpoint"

  MSI_GUID_START=000C10
  MSI_GUID_END=-0000-0000-C000-000000000046
  MSI_INTERFACE_BYTES=1C,1D,25,33,90,93,95,96,97,98,99,9A,9B,9C,9D,9E,9F,A0,A1
  MSI_CLSID_BYTES=1C,1D,3E,90,94

  export_multiple_and_merge \
    'HKEY_LOCAL_MACHINE\Software' \
    "$wim_mountpoint/$software" \
    "$wim_build_mountpoint/$software" \
    WOW6432Node \
    Microsoft\\Wow64 \
    Microsoft\\Windows\\CurrentVersion\\SideBySide \
    Microsoft\\Windows\\CurrentVersion\\SMI \
    Microsoft\\Windows\ NT\\CurrentVersion\\Image\ File\ Execution\ Options \
    \
    Classes\\.msi \
    Classes\\.msp \
    Classes\\IMsiServer \
    Classes\\Msi.Package \
    Classes\\Msi.Patch \
    Classes\\WindowsInstaller.Message \
    Classes\\WindowsInstaller.Installer \
    Microsoft\\Windows\\CurrentVersion\\Installer \
    Microsoft\\Cryptography \
    Classes\\AppID\\\{000C101C-0000-0000-C000-000000000046\} \
    Classes\\TypeLib\\\{000C1092-0000-0000-C000-000000000046\} \
    $(for guid in $(eval echo "${MSI_GUID_START}{${MSI_INTERFACE_BYTES}}${MSI_GUID_END}")
      do
        echo "Classes\\Wow6432Node\\Interface\\{$guid}"
        echo "Classes\\Interface\\{$guid}"
      done) \
    $(for guid in $(eval echo "${MSI_GUID_START}{${MSI_CLSID_BYTES}}${MSI_GUID_END}")
      do
        echo "Classes\\Wow6432Node\\CLSID\\{$guid}"
      done) \
    &
  local merge_pids="$merge_pids $!"

  export_multiple_and_merge \
    'HKEY_LOCAL_MACHINE\System' \
    "$wim_mountpoint/$system" \
    "$wim_build_mountpoint/$system" \
    ControlSet001\\Services\\msiserver \
    ControlSet001\\Services\\TrustedInstaller \
    ControlSet001\\Services\\eventlog \
    &
  merge_pids="$merge_pids $!"

  wait $merge_pids

  cp_tree "$wim_build_mountpoint" "$wim_build_mountpoint/$system" .
  cp_tree "$wim_build_mountpoint" "$wim_build_mountpoint/$software" .

  umount "$wim_mountpoint"
  umount "$wim_build_mountpoint"
  rmdir "$wim_mountpoint"
  rmdir "$wim_build_mountpoint"
}
