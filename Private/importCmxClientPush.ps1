function importCmxClientPush {
	[CmdletBinding(SupportsShouldProcess=$True)]
	param (
		[parameter(Mandatory=$True)]
		[ValidateNotNullOrEmpty()]
		$DataSet
	)
	writeLogFile -Category "info" -Message "------------------------------ importCmxClientPush -------------------------------"
	foreach ($set in $DataSet.configuration.cmsite.clientoptions.CMClientPushInstallation | Where-Object {$_.use -eq '1'}) {
		if ($set.AutomaticInstall -eq 'true') {
			try {
				$null = Set-CMClientPushInstallation -SiteCode "$sitecode" -EnableAutomaticClientPushInstallation $True
				writeLogFile -Category "info" -Message "client push: enabled automatic client push installation"
			} catch {
				writeLogFile -Category "error" -Message $_.Exception.Message
			}
		}
		if ($set.ClientCMServer -eq 'true') {
			try {
				$null = Set-CMClientPushInstallation -SiteCode "$sitecode" -EnableSystemTypeConfigurationManager $True
				writeLogFile -Category "info" -Message "client push: enabled client install on CM site systems"
			} catch {
				writeLogFile -Category "error" -Message $_.Exception.Message
			}
		}
		if ($set.ClientServer -eq 'true') {
			try {
				$null = Set-CMClientPushInstallation -SiteCode "$sitecode" -EnableSystemTypeServer $True
				writeLogFile -Category "info" -Message "client push: enabled client install on servers"
			} catch {
				writeLogFile -Category "error" -Message $_.Exception.Message
			}
		}
		if ($set.ClientDC -eq 'true') {
			try {
				$null = Set-CMClientPushInstallation -SiteCode "$sitecode" -InstallClientToDomainController $True
				writeLogFile -Category "info" -Message "client push: enabled client install on domain controllers"
			} catch {
				writeLogFile -Category "error" -Message $_.Exception.Message
			}
		}
		if ($set.ClientWorkstation -eq 'true') {
			try {
				$null = Set-CMClientPushInstallation -SiteCode "$sitecode" -EnableSystemTypeWorkstation $True
				writeLogFile -Category "info" -Message "client push: enabled client install on workstations"
			} catch {
				writeLogFile -Category "error" -Message $_.Exception.Message
			}
		}
		if ($set.Accounts.length -gt 0) {
			foreach ($acct in $set.Accounts.Split(",")) {
				writeLogFile -Category "info" -Message "assigning user account to client push list: $acct"
				if (Get-WmiObject -Class Win32_UserAccount | Where-Object {$_.Caption -eq "$acct"}) {
					try {
						$null = Set-CMClientPushInstallation -SiteCode "$sitecode" -AddAccount $acct
						writeLogFile -Category "info" -Message "client push: set installation account to $($acct)"
					} catch {
						writeLogFile -Category "error" -Message $_.Exception.Message
						$result = $False
						break
					}
				} else {
					writeLogFile -Category "error" -Message "user account $acct was not found in the current AD domain"
					$result = $False
					break
				}
			} # foreach
		}
		if ($set.InstallationProperty.Length -gt 0) {
			try {
				$null = Set-CMClientPushInstallation -SiteCode "$sitecode" -InstallationProperty $set.InstallationProperty
				writeLogFile -Category "info" -Message "client push: set installation property $($set.InstallationProperty)"
			} catch {
				writeLogFile -Category "error" -Message $_.Exception.Message
			}
		}
	} # foreach
}
