download_packages() {
  local download_pids=
  wget https://github.com/Open-Shell/Open-Shell-Menu/releases/download/v4.4.191/OpenShellSetup_4_4_191.exe &
  download_pids="$download_pids $!"

  wget https://github.com/git-for-windows/git/releases/download/v2.42.0.windows.2/PortableGit-2.42.0.2-64-bit.7z.exe &
  download_pids="$download_pids $!"

  #
  #wget https://download.visualstudio.microsoft.com/download/pr/7afca223-55d2-470a-8edc-6a1739ae3252/abd170b4b0ec15ad0222a809b761a036/ndp48-x86-x64-allos-enu.exe
  #
  (wget https://www.python.org/ftp/python/3.12.0/python-3.12.0-embed-amd64.zip &&
   unzip -o python-3.12.0-embed-amd64.zip) &
  download_pids="$download_pids $!"

  (wget https://download.sysinternals.com/files/SysinternalsSuite.zip &&
  unzip -o SysinternalsSuite.zip) &
  download_pids="$download_pids $!"

  wget https://download.microsoft.com/download/6/D/F/6DF3FF94-F7F9-4F0B-838C-A328D1A7D0EE/vc_redist.x64.exe
  download_pids="$download_pids $!"

  wget https://github.com/PowerShell/PowerShell/releases/download/v7.3.3/PowerShell-7.3.3-win-x64.msi &
  download_pids="$download_pids $!"

  (wget https://sourceforge.net/projects/processhacker/files/processhacker2/processhacker-2.39-bin.zip &&
  unzip -o processhacker-2.39-bin.zip) &
  download_pids="$download_pids $!"

  wait $download_pids
}
