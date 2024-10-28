function Import-CmxOSInstallers {
	[CmdletBinding(SupportsShouldProcess=$True)]
	param (
		[parameter(Mandatory=$True)]
		[ValidateNotNullOrEmpty()]
		$DataSet
	)
	Write-Log -Category "info" -Message "------------------------------ Import-CmxOSInstallers -------------------------------"
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
			Write-Log -Category "info" -Message "installer name: $instName"
			if ($osi = Get-CMOperatingSystemInstaller -Name $instName) {
				Write-Log -Category "info" -Message "operating system installer already created"
			} else {
				try {
					$osi = New-CMOperatingSystemInstaller -Name $instName -Path $instPath -Description $instDesc -Version $instVer -ErrorAction SilentlyContinue
					Write-Log -Category "info" -Message "operating system installer created successfully"
				} catch {
					Write-Log -Category "error" -Message $_.Exception.Message
					$result = $False
					break
				}
			}
			Write-Log -Category "info" -Message "moving object to folder: $imgFolder"
			$osi | Move-CMObject -FolderPath $imgFolder | Out-Null
		} else {
			Set-Location $oldLoc
			Write-Log -Category "error" -Message "failed to locate: $instPath"
		}
		Write-Verbose "- - - - - - - - - - - - - - - - - - - - - - - - - - - - - -"
	} # foreach
	Write-Log -Category info -Message "function runtime: $(Get-TimeOffset $time1)"
	Write-Output $result
}
