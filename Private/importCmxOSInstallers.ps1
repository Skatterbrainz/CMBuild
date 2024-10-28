function importCmxOSInstallers {
	[CmdletBinding(SupportsShouldProcess=$True)]
	param (
		[parameter(Mandatory=$True)]
		[ValidateNotNullOrEmpty()]
		$DataSet
	)
	writeLogFile -Category "info" -Message "------------------------------ importCmxOSInstallers -------------------------------"
	Write-Host "Configuring OS upgrade installers" -ForegroundColor Green
	$result = $True
	$Time1  = Get-Date
	foreach ($item in $DataSet.configuration.cmsite.osinstallers.osinstaller | Where-Object {$_.use -eq '1'}) {
		$instName  = $item.name
		$instPath  = $item.path
		$instDesc  = $item.comment
		$instVer   = $item.version
		$imgFolder = $item.folder
		$oldLoc    = Get-Location
		Set-Location c:
		if (Test-Path $instPath) {
			Set-Location $oldLoc
			writeLogFile -Category "info" -Message "installer name: $instName"
			if ($osi = Get-CMOperatingSystemInstaller -Name $instName) {
				writeLogFile -Category "info" -Message "operating system installer already created"
			} else {
				try {
					$osi = New-CMOperatingSystemInstaller -Name $instName -Path $instPath -Description $instDesc -Version $instVer -ErrorAction SilentlyContinue
					writeLogFile -Category "info" -Message "operating system installer created successfully"
				} catch {
					writeLogFile -Category "error" -Message $_.Exception.Message
					$result = $False
					break
				}
			}
			writeLogFile -Category "info" -Message "moving object to folder: $imgFolder"
			$osi | Move-CMObject -FolderPath $imgFolder | Out-Null
		} else {
			Set-Location $oldLoc
			writeLogFile -Category "error" -Message "failed to locate: $instPath"
		}
		Write-Verbose "- - - - - - - - - - - - - - - - - - - - - - - - - - - - - -"
	} # foreach
	writeLogFile -Category info -Message "function runtime: $(getTimeOffset $time1)"
	Write-Output $result
}
