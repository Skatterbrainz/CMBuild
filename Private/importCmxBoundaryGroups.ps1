function importCmxBoundaryGroups {
	[CmdletBinding(SupportsShouldProcess=$True)]
	param (
		[parameter(Mandatory=$True)]
		[ValidateNotNullOrEmpty()]
		$DataSet
	)
	writeLogFile -Category "info" -Message "------------------------------ importCmxBoundaryGroups -------------------------------"
	Write-Host "Configuring Site Boundary Groups" -ForegroundColor Green
	$result = $True
	$Time1  = Get-Date
	foreach ($item in $DataSet.configuration.cmsite.boundarygroups.boundarygroup | Where-Object {$_.use -eq '1'}) {
		$bgName   = $item.name
		$bgComm   = $item.comment
		$bgServer = $item.SiteSystemServer
		$bgLink   = $item.LinkType
		writeLogFile -Category "info" -Message "boundary group name = $bgName"
		if (Get-CMBoundaryGroup -Name $bgName) {
			writeLogFile -Category "info" -Message "boundary group already exists"
		} else {
			try {
				$null = New-CMBoundaryGroup -Name $bgName -Description "$bgComm" -DefaultSiteCode $sitecode
				writeLogFile -Category "info" -Message "boundary group $bgName created"
			} catch {
				writeLogFile -Category "error" -Message $_.Exception.Message
				$result = $false
				break
			}
		}
		if ($bgServer.Length -gt 0) {
			$bgSiteServer = @{$bgServer = $bgLink}
			writeLogFile -Category "info" -Message "site server assigned: $bgServer ($bgLink)"
			try {
				$null = Set-CMBoundaryGroup -Name $bgName -DefaultSiteCode $sitecode -AddSiteSystemServer $bgSiteServer -ErrorAction SilentlyContinue
				writeLogFile -Category "info" -Message "boundary group $bgName has been updated"
			} catch {
				writeLogFile -Category "error" -Message $_.Exception.Message
				$result = $False
				break
			}
		}
		writeLogFile -Category "info" -Message "- - - - - - - - - - - - - - - - - - - - - - - - - -"
	} # foreach
	writeLogFile -Category info -Message "function runtime: $(getTimeOffset $time1)"
	Write-Output $result
}
