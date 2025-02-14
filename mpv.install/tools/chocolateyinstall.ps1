﻿$ErrorActionPreference = 'Stop'
$toolsDir = "$(Split-Path -parent $MyInvocation.MyCommand.Definition)"

$packageArgs = @{
  packageName = 'mpv.install'
  file        = gi "$toolsDir\*_x32.7z"
  file64      = gi "$toolsDir\*_x64.7z"
  destination = "$toolsDir"
}

If ( Get-Item $toolsDir\doc\mpv.html -ea 0) {
  Write-Warning 'For technical reasons, please uninstall then reinstall mpv.'
  Write-Warning 'cuninst mpv.install; cinst mpv.install'
  Write-Error 'The builds provided by this package have changed and mpv needs to be reinstalled.'
}

Get-ChocolateyUnzip @packageArgs
Get-ChocolateyUnzip -file "$toolsDir\rossy.zip" -destination $toolsDir
Move-Item "$toolsDir\mpv-install-master\*" $toolsDir -Force
Remove-Item "$toolsDir\mpv-install-master"
Start-ChocolateyProcessAsAdmin -Statements "/K $toolsDir\mpv-install.bat /u" -ExeToRun 'cmd.exe' -Elevated -validExitCodes '0'
Remove-Item -force "$toolsDir\*.zip","$toolsDir\*.7z" -ea 0

# mpv can't be shimmed, the shim doesn't work with mpv.com
# as of 2016.01.18, there is a dll dependency, so mpv can't be hardlinked to chocolatey\bin
# adding to PATH until chocolatey implements a /usr/lib equivalent
$pathType = 'User'
If ( Test-ProcessAdminRights ) { $pathType = 'Machine' }
Install-ChocolateyPath $toolsDir $pathType
