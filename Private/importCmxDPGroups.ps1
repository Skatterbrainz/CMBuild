function importCmxDPGroups {
	[CmdletBinding(SupportsShouldProcess=$True)]
	param (
		[parameter(Mandatory=$True)]
		[ValidateNotNullOrEmpty()]
		$DataSet
	)
	writeLogFile -Category "info" -Message "------------------------------ importCmxDPGroups -------------------------------"
	Write-Host "Configuring distribution point groups" -ForegroundColor Green
	$result = $true
	$Time1  = Get-Date
	foreach ($item in $DataSet.configuration.cmsite.dpgroups.dpgroup | Where-Object {$_.use -eq '1'}) {
		$dpgName = $item.name
		$dpgComm = $item.comment
		writeLogFile -Category info -Message "distribution point group: $dpgName"
		if (Get-CMDistributionPointGroup -Name $dpgName) {
			writeLogFile -Category info -Message "dp group already exists"
		} else {
			try {
				$null = New-CMDistributionPointGroup -Name $dpgName -Description $dpgComm
				writeLogFile -Category info -Message "dp group created successfully"
			} catch {
				writeLogFile -Category error -Message $_.Exception.Message
				$Result = $False
				break
			}
		}
		Write-Verbose "- - - - - - - - - - - - - - - - - - - - - - - - - - - - - -"
	} # foreach
	writeLogFile -Category info -Message "function runtime: $(getTimeOffset $time1)"
	Write-Output $result
}
