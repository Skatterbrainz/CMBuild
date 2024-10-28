function importCmxLocalAccounts {
	[CmdletBinding(SupportsShouldProcess=$True)]
	param (
		[parameter(Mandatory=$True)]
		[ValidateNotNullOrEmpty()]
		$DataSet
	)
	Write-Host "Configuring Local accounts and group memberships" -ForegroundColor Green
	$result = 0
	$time1  = Get-Date
	foreach ($item in $DataSet.configuration.localaccounts.localaccount | Where-Object {$_.use -eq "1"}) {
		$itemName   = $item.name
		$itemGroup  = $item.memberof
		$itemRights = $item.rights
		if (Get-LocalGroupMember -Group "$itemGroup" -Member "$itemName" -ErrorAction SilentlyContinue) {
			writeLogFile -Category "info" -Message "$itemName is already a member of $itemGroup"
			if ($itemRights.Length -gt 0) {
				$null = applyCmxLocalAccountRights -UserName "$itemName" -Privileges "$itemRights"
			}
		} else {
			writeLogFile -Category "info" -Message "$itemName is not a member of $itemGroup"
			try {
				Add-LocalGroupMember -Group "$itemGroup" -Member "$itemName"
				if (Get-LocalGroupMember -Group "$itemGroup" -Member "$itemName" -ErrorAction SilentlyContinue) {
					writeLogFile -Category "info" -Message "$itemName has been added to $itemGroup"
					if ($itemRights.Length -gt 0) {
						$null = applyCmxLocalAccountRights -UserName "$itemName" -Privileges "$itemRights"
					}
				} else {
					writeLogFile -Category "error" -Message $_.Exception.Message
					$result = $False
					break
				}
			} catch {
				writeLogFile -Category "error" -Message $_.Exception.Message
				$result = $False
				break
			}
		}
	} # foreach
	writeLogFile -Category "info" -Message "function runtime = $(getTimeOffset -StartTime $time1)"
	Write-Output $result
}
