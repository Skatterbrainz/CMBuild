function importCmxDiscoveryMethods {
	[CmdletBinding(SupportsShouldProcess=$True)]
	param (
		[parameter(Mandatory=$True)]
		[ValidateNotNullOrEmpty()]
		$DataSet
	)
	writeLogFile -Category "info" -Message "------------------------------ importCmxDiscoveryMethods -------------------------------"
	Write-Host "Configuring Discovery Methods" -ForegroundColor Green
	$result = $True
	$Time1  = Get-Date
	foreach ($item in $DataSet.configuration.cmsite.discoveries.discovery | Where-Object {$_.use -eq '1'}) {
		$discName = $item.name
		$discOpts = $item.options
		writeLogFile -Category "info" -Message "configuring discovery method = $discName"
		switch ($discName) {
			'ActiveDirectoryForestDiscovery' {
				try {
					Set-CMDiscoveryMethod -ActiveDirectoryForestDiscovery -SiteCode $sitecode -Enabled $True -ErrorAction SilentlyContinue | Out-Null
					writeLogFile -Category info -Message "discovery has been enabled. configuring options"
					if ($discOpts.length -gt 0) {
						foreach ($opt in $discOpts.Split('|')) {
							writeLogFile -Category info -Message "option = $opt"
							switch ($opt) {
								'EnableActiveDirectorySiteBoundaryCreation' {
									Set-CMDiscoveryMethod -ActiveDirectoryForestDiscovery -SiteCode $sitecode -Enabled $True -EnableActiveDirectorySiteBoundaryCreation $True -ErrorAction SilentlyContinue | Out-Null
								}
								'EnableSubnetBoundaryCreation' {
									Set-CMDiscoveryMethod -ActiveDirectoryForestDiscovery -SiteCode $sitecode -Enabled $True -EnableSubnetBoundaryCreation $True -ErrorAction SilentlyContinue | Out-Null
								}
							}
						} # foreach
					}
				} catch {
					writeLogFile -Category error -Message $_.Exception.Message
					$result = $False
				}
			}
			'ActiveDirectorySystemDiscovery' {
				try {
					Set-CMDiscoveryMethod -ActiveDirectorySystemDiscovery -SiteCode $sitecode -Enabled $True -ErrorAction Continue | Out-Null
					writeLogFile -Category info -Message "discovery has been enabled. configuring options"
					foreach ($opt in $discOpts.Split("|")) {
						$optx = $opt.Split(':')
						writeLogFile -Category info -Message "option = $($optx[0])"
						writeLogFile -Category info -Message "value  = $($optx[$optx.Count-1])"
						switch ($optx[0]) {
							'ADContainer' {
								Set-CMDiscoveryMethod -ActiveDirectorySystemDiscovery -SiteCode $sitecode -ActiveDirectoryContainer "LDAP://$($optx[1])" -Recursive -ErrorAction SilentlyContinue | Out-Null
							}
							'EnableDetaDiscovery' {
								Set-CMDiscoveryMethod -ActiveDirectorySystemDiscovery -SiteCode $sitecode -EnableDeltaDiscovery $True -ErrorAction SilentlyContinue | Out-Null
							}
							'EnableFilteringExpiredLogon' {
								Set-CMDiscoveryMethod -ActiveDirectorySystemDiscovery -SiteCode $sitecode -EnableFilteringExpiredLogon $True -TimeSinceLastLogonDays $optx[1] -ErrorAction SilentlyContinue | Out-Null
							}
							'EnableFilteringExpiredPassword' {
								Set-CMDiscoveryMethod -ActiveDirectorySystemDiscovery -SiteCode $sitecode -EnableFilteringExpiredPassword $True -TimeSinceLastPasswordUpdateDays $optx[1] | Out-Null
							}
						} # switch
					} # foreach
				} catch {
					writeLogFile -Category error -Message $_.Exception.Message
					$result = $False
				}
			}
			'ActiveDirectoryGroupDiscovery' {
				try {
					$null = Set-CMDiscoveryMethod -ActiveDirectoryGroupDiscovery -SiteCode $sitecode -Enabled $True -ErrorAction SilentlyContinue
					writeLogFile -Category info -Message "discovery has been enabled. configuring options"
				} catch {
					writeLogFile -Category error -Message $_.Exception.Message
					break
				}
				foreach ($opt in $discOpts.Split("|")) {
					$optx = $opt.Split(':')
					writeLogFile -Category info -Message "option = $($optx[0])"
					writeLogFile -Category info -Message "value  = $($optx[$optx.Count-1])"
					switch ($optx[0]) {
						'EnableDeltaDiscovery' {
							$null = Set-CMDiscoveryMethod -ActiveDirectoryGroupDiscovery -SiteCode $sitecode -EnableDeltaDiscovery $True
							break
						}
						'ADContainer' {
							$scope = New-CMADGroupDiscoveryScope -LdapLocation "LDAP://$($optx[1])" -Name "Domain Root" -RecursiveSearch $True
							try {
								$null = Set-CMDiscoveryMethod -ActiveDirectoryGroupDiscovery -SiteCode $sitecode -AddGroupDiscoveryScope $scope -ErrorAction SilentlyContinue
							} catch {
								if ($_.Exception.Message -like "*already exists*") {
									writeLogFile -Category info -Message "ldap path is already configured"
								} else {
									writeLogFile -Category error -Message $_.Exception.Message
								}
							}
						}
						'EnableFilteringExpiredLogon' {
							$null = Set-CMDiscoveryMethod -ActiveDirectoryGroupDiscovery -SiteCode $sitecode -EnableFilteringExpiredLogon $True -TimeSinceLastLogonDays $optx[1] -ErrorAction SilentlyContinue
						}
						'EnableFilteringExpiredPassword' {
							$null = Set-CMDiscoveryMethod -ActiveDirectoryGroupDiscovery -SiteCode $sitecode -EnableFilteringExpiredPassword $True -TimeSinceLastPasswordUpdateDays $optx[1] -ErrorAction SilentlyContinue
						}
					} # switch
				} # foreach
			}
			'ActiveDirectoryUserDiscovery' {
				try {
					$null = Set-CMDiscoveryMethod -ActiveDirectoryUserDiscovery -SiteCode $sitecode -Enabled $True -ErrorAction SilentlyContinue
					writeLogFile -Category info -Message "discovery has been enabled. configuring options"
					foreach ($opt in $discOpts.Split("|")) {
						$optx = $opt.Split(':')
						writeLogFile -Category info -Message "option = $($optx[0])"
						writeLogFile -Category info -Message "value  = $($optx[$optx.Count-1])"
						switch ($optx[0]) {
							'ADContainer' {
								$null = Set-CMDiscoveryMethod -ActiveDirectoryUserDiscovery -SiteCode $sitecode -ActiveDirectoryContainer "LDAP://$($optx[1])" -Recursive -ErrorAction SilentlyContinue
							}
							'EnableDetaDiscovery' {
								$null = Set-CMDiscoveryMethod -ActiveDirectoryUserDiscovery -SiteCode $sitecode -EnableDeltaDiscovery $True -ErrorAction SilentlyContinue
							}
							'ADAttributes' {
								$null = Set-CMDiscoveryMethod -ActiveDirectoryUserDiscovery -SiteCode $sitecode -AddAdditionalAttribute $optx[1].split(',') -ErrorAction SilentlyContinue
							}
						} # switch
					} # foreach
				} catch {
					writeLogFile -Category error -Message $_.Exception.Message
					$result = $False
				}
			}
			'NetworkDiscovery' {
				try {
					$null = Set-CMDiscoveryMethod -NetworkDiscovery -SiteCode $sitecode -Enabled $True -ErrorAction SilentlyContinue
					writeLogFile -Category info -Message "discovery has been enabled. configuring options"
				} catch {
					writeLogFile -Category error -Message $_.Exception.Message
					$result = $False
				}
			}
			'HeartbeatDiscovery' {
				try {
					$null = Set-CMDiscoveryMethod -Heartbeat -SiteCode $sitecode -Enabled $True -ErrorAction SilentlyContinue
					writeLogFile -Category info -Message "discovery has been enabled. configuring options"
				} catch {
					writeLogFile -Category error -Message $_.Exception.Message
					$result = $False
				}
				break
			}
		} # switch
		writeLogFile -Category "info" -Message "- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -"
	} # foreach
	writeLogFile -Category info -Message "function runtime: $(getTimeOffset $time1)"
	Write-Output $result
} # function
