function importCmxMaintenanceTasks {
	[CmdletBinding(SupportsShouldProcess=$True)]
	param (
		[parameter(Mandatory=$True)]
		[ValidateNotNullOrEmpty()]
		$DataSet
	)
	writeLogFile -Category "info" -Message "------------------------------ importCmxMaintenanceTasks -------------------------------"
	Write-Host "Configuring site maintenance tasks" -ForegroundColor Green
	$result = $true
	$Time1  = Get-Date
	foreach ($item in $DataSet.configuration.cmsite.mtasks.mtask) {
		$mtName = $item.name
		$mtEnab = $item.enabled
		$mtOpts = $item.options
		if ($mtEnab -eq 'true') {
			writeLogFile -Category "info" -Message "enabling task: $mtName"
			try {
				$null = Set-CMSiteMaintenanceTask -MaintenanceTaskName $mtName -Enabled $True -SiteCode $sitecode
			} catch {
				writeLogFile -Category error -Message $_.Exception.Message
				$result = $False
				break
			}
		} else {
			writeLogFile -Category "info" -Message "disabling task: $mtName"
			try {
				$null = Set-CMSiteMaintenanceTask -MaintenanceTaskName $mtName -Enabled $False -SiteCode $sitecode
			} catch {
				writeLogFile -Category "error" -Message $_.Exception.Message
				$result = $False
				break
			}
		}
		Write-Verbose "- - - - - - - - - - - - - - - - - - - - - - - - - - - - - -"
	} # foreach
	writeLogFile -Category info -Message "function runtime: $(getTimeOffset $time1)"
	Write-Output $result
}
