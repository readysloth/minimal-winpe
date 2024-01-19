download() {
  local directory="$1"
  shift
  wget -q -o /dev/null --content-disposition --directory-prefix="$directory" "$@"
}

install_to() {
  local directory="$1"
  shift
  local install_cmd="$*"

  pushd Applications &> /dev/null || return
    mkdir "$directory"
    pushd "$directory" &> /dev/null || return
      eval "$install_cmd" &> /dev/null
    popd &> /dev/null || return
  popd &> /dev/null || return
}


download_packages() {
  mkdir Installers
  mkdir Applications
  mkdir temp

  local download_pids=()

  download Installers https://github.com/PowerShell/PowerShell/releases/download/v7.4.0/PowerShell-7.4.0-win-x64.msi
  download_pids+=($!)

  download Installers https://sourceforge.net/projects/maxlauncher/files/MaxLauncher/1.31.0.0/maxlauncher_1.31.0.0_setup.exe/download
  download_pids+=($!)

  (download temp https://github.com/lucasg/Dependencies/releases/download/v1.11.1/Dependencies_x64_Release.zip &&
   install_to Dependencies unzip -qq -o "$(readlink -f temp/Dependencies_x64_Release.zip)") &
  download_pids+=($!)

  (download temp https://www.penetworkmanager.de/scripts/PENetwork_x64.7z &&
   7z x -so temp/PENetwork_x64.7z PENetwork.exe > Applications/PENetwork.exe) &
  download_pids+=($!)


  cat > chocolatey.ps1 << "EOF"
[System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072; iex ((New-Object System.Net.WebClient).DownloadString('https://community.chocolatey.org/install.ps1'))
EOF

  cat > scoop.ps1 << "EOF"
iex "& {$(irm get.scoop.sh)} -RunAsAdmin"
EOF

  if [ -n "$NO_PORTABLE_APPS" ]
  then
    wait "${download_pids[@]}"
    rm -rf temp
    return
  fi

  (download temp https://download.sysinternals.com/files/SysinternalsSuite.zip &&
   install_to SysInternals unzip -qq -o "$(readlink -f temp/SysinternalsSuite.zip)") &
  download_pids+=($!)

  (download temp https://sourceforge.net/projects/processhacker/files/processhacker2/processhacker-2.39-bin.zip &&
   install_to ProcessHacker unzip -qq -o "$(readlink -f temp/processhacker-2.39-bin.zip)") &
  download_pids+=($!)

  (download temp https://download.microsoft.com/download/1/4/0/140EBDB7-F631-4191-9DC0-31C8ECB8A11F/wdk/Installers/787bee96dbd26371076b37b13c405890.cab &&
   cabextract --pipe --filter filbad6e2cce5ebc45a401e19c613d0a28f temp/787bee96dbd26371076b37b13c405890.cab > Applications/devcon.exe) &
  download_pids+=($!)

  (download temp https://github.com/BornToBeRoot/NETworkManager/releases/download/2023.12.28.0/NETworkManager_2023.12.28.0_Portable.zip &&
   bash -c "cd Applications && unzip -qq -o '$(readlink -f temp/NETworkManager_2023.12.28.0_Portable.zip)'") &
  download_pids+=($!)

  (download temp https://www.nirsoft.net/utils/nircmd.zip &&
   bash -c "cd Applications && unzip -qq -o '$(readlink -f temp/nircmd.zip)' && rm NirCmd.chm") &
  download_pids+=($!)

  (download temp https://github.com/dnSpyEx/dnSpy/releases/download/v6.4.1/dnSpy-net-win64.zip &&
   install_to dnSpy unzip -qq -o "$(readlink -f temp/dnSpy-net-win64.zip)") &
  download_pids+=($!)

  (download temp https://altushost-swe.dl.sourceforge.net/project/x64dbg/snapshots/snapshot_2023-12-21_21-38.zip &&
   install_to x64dbg "unzip -qq -o '$(readlink -f temp/snapshot_2023-12-21_21-38.zip)' && mv release/* . && rmdir release") &
  download_pids+=($!)

  (download temp https://github.com/doublecmd/doublecmd/releases/download/v1.1.8/doublecmd-1.1.8.x86_64-win64.zip &&
   install_to DoubleCommander "unzip -qq -o '$(readlink -f temp/doublecmd-1.1.8.x86_64-win64.zip)' && mv doublecmd/* . && rmdir doublecmd") &
  download_pids+=($!)

  (download temp https://www.rapidee.com/download/RapidEEx64.zip &&
   install_to RapidEE unzip -qq -o "$(readlink -f temp/RapidEEx64.zip)") &
  download_pids+=($!)

  wait "${download_pids[@]}"
  rm -rf temp
}
