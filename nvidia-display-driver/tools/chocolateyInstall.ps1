﻿$packageName = 'nvidia-display-driver'
$fileType = 'exe'
$silentArgs = '-s -noreboot'
$unpackFile = "${ENV:TEMP}\nvidiadriver.zip"
$unpackDir  = "${ENV:TEMP}\nvidiadriver"
$instDir    = "${ENV:TEMP}\nvidiainstall"
$file = "$instDir\setup.exe"
$url   = 'https://us.download.nvidia.com/Windows/391.35/391.35-desktop-win10-32bit-international-whql.exe'
$url64 = 'https://us.download.nvidia.com/Windows/391.35/391.35-desktop-win10-64bit-international-whql.exe'
$checksum   = '5128180228d63d550869d615d9d165eabbc1bc1ce1c5a8235466e16d4867cb4e'
$checksum64 = 'd352ad886b250482385ae1b597cf1be301e2e3378567e10feb8942fec0c964c2'
$checksumType = 'sha256'

If ( [System.Environment]::OSVersion.Version.Major -ne '10' ) {
	$url   = 'https://us.download.nvidia.com/Windows/391.35/391.35-desktop-win8-win7-32bit-international-whql.exe'
	$url64 = 'https://us.download.nvidia.com/Windows/391.35/391.35-desktop-win8-win7-64bit-international-whql.exe'
	$checksum   = '1687319094fbcf7bb3e45ffa713916d94ebd9c838672720558553132becd2ac3'
	$checksum64 = '7dd05b645433129b86ced17fcd8d29bf98eca2f3ac4834c19f24fb1161ea9e5c'
}

# Clean up
Remove-Item "$instDir" -Recurse -Force
New-Item -Path "$instDir" -ItemType Directory

# Download driver package as a zip
Get-ChocolateyWebFile $packageName $unpackFile $url $url64 `
-Checksum $checksum -ChecksumType $checksumType -Checksum64 $checksum64 

# Unzip driver package
Get-ChocolateyUnzip $unpackFile $unpackDir

# Inclusive filter
Move-Item "$unpackDir\Display.Driver"  -Destination "$instDir"
Move-Item "$unpackDir\Display.Optimus" -Destination "$instDir"
Move-Item "$unpackDir\NVI2"            -Destination "$instDir"
Move-Item "$unpackDir\PhysX"           -Destination "$instDir"
Move-Item "$unpackDir\EULA.txt"        -Destination "$instDir"
Move-Item "$unpackDir\license.txt"     -Destination "$instDir"
Move-Item "$unpackDir\ListDevices.txt" -Destination "$instDir"
Move-Item "$unpackDir\setup.cfg"       -Destination "$instDir"
Move-Item "$unpackDir\setup.exe"       -Destination "$instDir"
$pp = Get-PackageParameters
if ( $pp.NV3DVision ) {
  Move-Item "$unpackDir\NV3DVision"               -Destination "$instDir"
  Move-Item "$unpackDir\NV3DVisionUSB.Driver"     -Destination "$instDir"
}
if ( $pp.HDAudio ) {
  Move-Item "$unpackDir\HDAudio"                  -Destination "$instDir"
}
Remove-Item "$unpackDir" -Recurse -Force

# Finally, install
Install-ChocolateyInstallPackage $packageName $fileType $silentArgs $file -ValidExitCodes @(0,1)

