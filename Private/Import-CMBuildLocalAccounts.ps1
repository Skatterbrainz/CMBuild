function Import-CMBuildLocalAccounts {
	[CmdletBinding(SupportsShouldProcess=$True)]
	param (
		[parameter(Mandatory=$True)]
		[ValidateNotNullOrEmpty()]
		[xml] $DataSet
	)
	Write-Host "Configuring Local accounts and group memberships" -ForegroundColor Green
	$result = 0
	$time1  = Get-Date
	foreach ($item in $DataSet.configuration.localaccounts.localaccount | Where-Object {$_.use -eq "1"}) {
		$itemName   = $item.name
		$itemGroup  = $item.memberof
		$itemRights = $item.rights
		if (Get-LocalGroupMember -Group "$itemGroup" -Member "$itemName" -ErrorAction SilentlyContinue) {
			Write-Log -Category "info" -Message "$itemName is already a member of $itemGroup"
			if ($itemRights.Length -gt 0) {
				Set-CMBuildLocalAccountRights -UserName "$itemName" -Privileges "$itemRights" | Out-Null
			}
		}
		else {
			Write-Log -Category "info" -Message "$itemName is not a member of $itemGroup"
			try {
				Add-LocalGroupMember -Group "$itemGroup" -Member "$itemName"
				if (Get-LocalGroupMember -Group "$itemGroup" -Member "$itemName" -ErrorAction SilentlyContinue) {
					Write-Log -Category "info" -Message "$itemName has been added to $itemGroup"
					if ($itemRights.Length -gt 0) {
						Set-CMBuildLocalAccountRights -UserName "$itemName" -Privileges "$itemRights" | Out-Null
					}
				}
				else {
					Write-Log -Category "error" -Message $_.Exception.Message
					$result = $False
					break
				}
			}
			catch {
				Write-Log -Category "error" -Message $_.Exception.Message
				$result = $False
				break
			}
		}
	} # foreach
    Write-Log -Category "info" -Message "function runtime = $(Get-TimeOffset -StartTime $time1)"
	Write-Output $result
}
