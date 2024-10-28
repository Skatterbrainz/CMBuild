function importCmxServerSettings {
	[CmdletBinding(SupportsShouldProcess=$True)]
	param (
		[parameter(Mandatory=$True)]
		[ValidateNotNullOrEmpty()]
		$DataSet
	)
	writeLogFile -Category "info" -Message "------------------------------ importCmxServerSettings -------------------------------"
	Write-Host "Configuring Server Settings" -ForegroundColor Green
	$result = $True
	$Time1  = Get-Date
	foreach ($item in $DataSet.configuration.cmsite.serversettings.serversetting | Where-Object {$_.use -eq "1"}) {
		$setName = $item.name
		$setComm = $item.comment
		$setKey  = $item.key
		$setVal  = $item.value
		writeLogFile -Category "info" -Message "setting name: $setName"
		writeLogFile -Category "info" -Message "comment.....: $setComm"
		switch ($setName) {
			'CMSoftwareDistributionComponent' {
				switch ($setKey) {
					'NetworkAccessAccountName' {
						writeLogFile -Category "info" -Message "setting $setKey == $setVal"
						if (Get-WmiObject -Class Win32_UserAccount | Where-Object {$_.Domain -eq "$($env:USERDOMAIN)" -and $_.Name -eq "$setVal"}) {
							try {
								Set-CMSoftwareDistributionComponent -SiteCode "$sitecode" -NetworkAccessAccountName "$setVal"
							} catch {
								writeLogFile -Category "error" -Message $_.Exception.Message
								$result = $False
								break
							}
						} else {
							writeLogFile -Category "error" -Message "account $setVal was not found in domain $($env:USERDOMAIN)"
							$result = $False
							break
						}
					}
				} # switch
			}
			## next condition / future use ##
		} # switch
	} # foreach
	writeLogFile -Category "info" -Message "function runtime: $(getTimeOffset $time1)"
	Write-Output $result
}
