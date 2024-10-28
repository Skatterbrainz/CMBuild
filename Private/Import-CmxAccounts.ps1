function Import-CmxAccounts {
	[CmdletBinding(SupportsShouldProcess=$True)]
	param (
		[parameter(Mandatory=$True)]
		[ValidateNotNullOrEmpty()]
		$DataSet
	)
	Write-Log -Category "info" -Message "------------------------------ Import-CmxAccounts -------------------------------"
	Write-Host "Configuring accounts" -ForegroundColor Green
	$result = $true
	$time1  = Get-Date
	foreach ($item in $DataSet.configuration.cmsite.accounts.account | Where-Object {$_.use -eq '1'}) {
		$acctName = $item.name
		$acctPwd  = $item.password
		Write-Log -Category "info" -Message "account: $acctName"
		if (Get-CMAccount -UserName $acctName) {
			Write-Log -Category "info" -Message "account already created"
		} else {
			if (Test-CMxAdUser -UserName $acctName) {
				try {
					$secpwd = ConvertTo-SecureString -String $acctPwd -AsPlainText -Force
					$null = New-CMAccount -UserName $acctName -Password $secpwd -SiteCode $sitecode
					Write-Log -Category "info" -Message "account added successfully: $acctName"
				} catch {
					Write-Log -Category "error" -Message $_.Exception.Message
					$Result = $False
					break
				}
			} else {
				Write-Log -Category "error" -Message "account not found in domain: $acctName"
				$result = $False
				break
			}
		}
		Write-Verbose "- - - - - - - - - - - - - - - - - - - - - - - - - - - - - -"
	} # foreach
	Write-Log -Category info -Message "function runtime: $(Get-TimeOffset $time1)"
	Write-Output $result
}
