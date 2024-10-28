function Import-CmxMaintenanceTasks {
	[CmdletBinding(SupportsShouldProcess=$True)]
	param (
		[parameter(Mandatory=$True)]
		[ValidateNotNullOrEmpty()]
		$DataSet
	)
	Write-Log -Category "info" -Message "------------------------------ Import-CmxMaintenanceTasks -------------------------------"
	Write-Host "Configuring site maintenance tasks" -ForegroundColor Green
	$result = $true
	$Time1  = Get-Date
	foreach ($item in $DataSet.configuration.cmsite.mtasks.mtask) {
		$mtName = $item.name
		$mtEnab = $item.enabled
		$mtOpts = $item.options
		if ($mtEnab -eq 'true') {
			Write-Log -Category "info" -Message "enabling task: $mtName"
			try {
				$null = Set-CMSiteMaintenanceTask -MaintenanceTaskName $mtName -Enabled $True -SiteCode $sitecode
			} catch {
				Write-Log -Category error -Message $_.Exception.Message
				$result = $False
				break
			}
		} else {
			Write-Log -Category "info" -Message "disabling task: $mtName"
			try {
				$null = Set-CMSiteMaintenanceTask -MaintenanceTaskName $mtName -Enabled $False -SiteCode $sitecode
			} catch {
				Write-Log -Category "error" -Message $_.Exception.Message
				$result = $False
				break
			}
		}
		Write-Verbose "- - - - - - - - - - - - - - - - - - - - - - - - - - - - - -"
	} # foreach
	Write-Log -Category info -Message "function runtime: $(Get-TimeOffset $time1)"
	Write-Output $result
}
