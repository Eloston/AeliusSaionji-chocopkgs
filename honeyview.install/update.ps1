﻿Import-Module au

$releases = 'http://www.bandisoft.com/honeyview/history/'

function global:au_SearchReplace {
	@{
		".\legal\VERIFICATION.txt" = @{
			"(?i)(^\s*checksum\s*type\:).*" = "`${1} $($Latest.ChecksumType32)"
			"(?i)(^\s*checksum(32)?\:).*"   = "`${1} $($Latest.Checksum32)"
		}
	}
}

function global:au_BeforeUpdate() {
	#Download $Latest.URL32 / $Latest.URL64 in tools directory and remove any older installers.
	Get-RemoteFiles -Purge
}

function global:au_GetLatest {
	$url = 'https://dl.bandisoft.com/honeyview/HONEYVIEW-SETUP.EXE'
	$download_page = (iwr $releases -UseBasicParsing).Content.Split("`n") | Select-String 'margin-right:5px;">' | select -First 1
	$Matches = $null
	$download_page -match "\d+\.\d+"
	$version = $Matches[0]

	return @{ Version = $version; URL32 = $url }
}

if ($MyInvocation.InvocationName -ne '.') { # run the update only if script is not sourced
	Update-Package -ChecksumFor none
}
