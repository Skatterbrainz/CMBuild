function importCmxAccounts {
	[CmdletBinding(SupportsShouldProcess=$True)]
	param (
		[parameter(Mandatory=$True)]
		[ValidateNotNullOrEmpty()]
		$DataSet
	)
	writeLogFile -Category "info" -Message "------------------------------ importCmxAccounts -------------------------------"
	Write-Host "Configuring accounts" -ForegroundColor Green
	$result = $true
	$time1  = Get-Date
	foreach ($item in $DataSet.configuration.cmsite.accounts.account | Where-Object {$_.use -eq '1'}) {
		$acctName = $item.name
		$acctPwd  = $item.password
		writeLogFile -Category "info" -Message "account: $acctName"
		if (Get-CMAccount -UserName $acctName) {
			writeLogFile -Category "info" -Message "account already created"
		} else {
			if (testCmxAdUser -UserName $acctName) {
				try {
					$secpwd = ConvertTo-SecureString -String $acctPwd -AsPlainText -Force
					$null = New-CMAccount -UserName $acctName -Password $secpwd -SiteCode $sitecode
					writeLogFile -Category "info" -Message "account added successfully: $acctName"
				} catch {
					writeLogFile -Category "error" -Message $_.Exception.Message
					$Result = $False
					break
				}
			} else {
				writeLogFile -Category "error" -Message "account not found in domain: $acctName"
				$result = $False
				break
			}
		}
		Write-Verbose "- - - - - - - - - - - - - - - - - - - - - - - - - - - - - -"
	} # foreach
	writeLogFile -Category info -Message "function runtime: $(getTimeOffset $time1)"
	Write-Output $result
}
