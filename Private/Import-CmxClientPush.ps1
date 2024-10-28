function Import-CmxClientPush {
	[CmdletBinding(SupportsShouldProcess=$True)]
	param (
		[parameter(Mandatory=$True)]
		[ValidateNotNullOrEmpty()]
		$DataSet
	)
	Write-Log -Category "info" -Message "------------------------------ Import-CmxClientPush -------------------------------"
	foreach ($set in $DataSet.configuration.cmsite.clientoptions.CMClientPushInstallation | Where-Object {$_.use -eq '1'}) {
		if ($set.AutomaticInstall -eq 'true') {
			try {
				$null = Set-CMClientPushInstallation -SiteCode "$sitecode" -EnableAutomaticClientPushInstallation $True
				Write-Log -Category "info" -Message "client push: enabled automatic client push installation"
			} catch {
				Write-Log -Category "error" -Message $_.Exception.Message
			}
		}
		if ($set.ClientCMServer -eq 'true') {
			try {
				$null = Set-CMClientPushInstallation -SiteCode "$sitecode" -EnableSystemTypeConfigurationManager $True
				Write-Log -Category "info" -Message "client push: enabled client install on CM site systems"
			} catch {
				Write-Log -Category "error" -Message $_.Exception.Message
			}
		}
		if ($set.ClientServer -eq 'true') {
			try {
				$null = Set-CMClientPushInstallation -SiteCode "$sitecode" -EnableSystemTypeServer $True
				Write-Log -Category "info" -Message "client push: enabled client install on servers"
			} catch {
				Write-Log -Category "error" -Message $_.Exception.Message
			}
		}
		if ($set.ClientDC -eq 'true') {
			try {
				$null = Set-CMClientPushInstallation -SiteCode "$sitecode" -InstallClientToDomainController $True
				Write-Log -Category "info" -Message "client push: enabled client install on domain controllers"
			} catch {
				Write-Log -Category "error" -Message $_.Exception.Message
			}
		}
		if ($set.ClientWorkstation -eq 'true') {
			try {
				$null = Set-CMClientPushInstallation -SiteCode "$sitecode" -EnableSystemTypeWorkstation $True
				Write-Log -Category "info" -Message "client push: enabled client install on workstations"
			} catch {
				Write-Log -Category "error" -Message $_.Exception.Message
			}
		}
		if ($set.Accounts.length -gt 0) {
			foreach ($acct in $set.Accounts.Split(",")) {
				Write-Log -Category "info" -Message "assigning user account to client push list: $acct"
				if (Get-WmiObject -Class Win32_UserAccount | Where-Object {$_.Caption -eq "$acct"}) {
					try {
						$null = Set-CMClientPushInstallation -SiteCode "$sitecode" -AddAccount $acct
						Write-Log -Category "info" -Message "client push: set installation account to $($acct)"
					} catch {
						Write-Log -Category "error" -Message $_.Exception.Message
						$result = $False
						break
					}
				} else {
					Write-Log -Category "error" -Message "user account $acct was not found in the current AD domain"
					$result = $False
					break
				}
			} # foreach
		}
		if ($set.InstallationProperty.Length -gt 0) {
			try {
				$null = Set-CMClientPushInstallation -SiteCode "$sitecode" -InstallationProperty $set.InstallationProperty
				Write-Log -Category "info" -Message "client push: set installation property $($set.InstallationProperty)"
			} catch {
				Write-Log -Category "error" -Message $_.Exception.Message
			}
		}
	} # foreach
}
