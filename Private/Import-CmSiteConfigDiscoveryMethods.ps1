function Import-CmSiteConfigDiscoveryMethods {
    [CmdletBinding(SupportsShouldProcess=$True)]
    param (
        [parameter(Mandatory=$True)]
        [ValidateNotNullOrEmpty()]
        [xml] $DataSet
    )
    Write-Log -Category "info" -Message "------------------------------ Import-CmSiteConfigDiscoveryMethods -------------------------------"
    Write-Host "Configuring Discovery Methods" -ForegroundColor Green
    $result = $True
    $Time1  = Get-Date
    foreach ($item in $DataSet.configuration.cmsite.discoveries.discovery | Where-Object {$_.use -eq '1'}) {
        $discName = $item.name
        $discOpts = $item.options
        Write-Log -Category "info" -Message "configuring discovery method = $discName"
        switch ($discName) {
            'ActiveDirectoryForestDiscovery' {
                try {
                    Set-CMDiscoveryMethod -ActiveDirectoryForestDiscovery -SiteCode $sitecode -Enabled $True -ErrorAction SilentlyContinue | Out-Null
                    Write-Log -Category info -Message "discovery has been enabled. configuring options"
                    if ($discOpts.length -gt 0) {
                        foreach ($opt in $discOpts.Split('|')) {
                            Write-Log -Category info -Message "option = $opt"
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
                }
                catch {
                    Write-Log -Category error -Message $_.Exception.Message
                    $result = $False
                }
                break
            }
            'ActiveDirectorySystemDiscovery' {
                try {
                    Set-CMDiscoveryMethod -ActiveDirectorySystemDiscovery -SiteCode $sitecode -Enabled $True -ErrorAction Continue | Out-Null
                    Write-Log -Category info -Message "discovery has been enabled. configuring options"
                    foreach ($opt in $discOpts.Split("|")) {
                        $optx = $opt.Split(':')
                        Write-Log -Category info -Message "option = $($optx[0])"
						Write-Log -Category info -Message "value  = $($optx[$optx.Count-1])"
                        switch ($optx[0]) {
                            'ADContainer' {
                                Set-CMDiscoveryMethod -ActiveDirectorySystemDiscovery -SiteCode $sitecode -ActiveDirectoryContainer "LDAP://$($optx[1])" -Recursive -ErrorAction SilentlyContinue | Out-Null
                                break
                            }
                            'EnableDetaDiscovery' {
                                Set-CMDiscoveryMethod -ActiveDirectorySystemDiscovery -SiteCode $sitecode -EnableDeltaDiscovery $True -ErrorAction SilentlyContinue | Out-Null
                                break
                            }
                            'EnableFilteringExpiredLogon' {
                                Set-CMDiscoveryMethod -ActiveDirectorySystemDiscovery -SiteCode $sitecode -EnableFilteringExpiredLogon $True -TimeSinceLastLogonDays $optx[1] -ErrorAction SilentlyContinue | Out-Null
                                break
                            }
                            'EnableFilteringExpiredPassword' {
                                Set-CMDiscoveryMethod -ActiveDirectorySystemDiscovery -SiteCode $sitecode -EnableFilteringExpiredPassword $True -TimeSinceLastPasswordUpdateDays $optx[1] | Out-Null
                                break
                            }
                        } # switch
                    } # foreach
                }
                catch {
                    Write-Log -Category error -Message $_.Exception.Message
                    $result = $False
                }
                break
            }
            'ActiveDirectoryGroupDiscovery' {
                try {
                    Set-CMDiscoveryMethod -ActiveDirectoryGroupDiscovery -SiteCode $sitecode -Enabled $True -ErrorAction SilentlyContinue | Out-Null
                    Write-Log -Category info -Message "discovery has been enabled. configuring options"
				}
                catch {
                    Write-Log -Category error -Message $_.Exception.Message
					break
                }
				foreach ($opt in $discOpts.Split("|")) {
					$optx = $opt.Split(':')
					Write-Log -Category info -Message "option = $($optx[0])"
					Write-Log -Category info -Message "value  = $($optx[$optx.Count-1])"
					switch ($optx[0]) {
						'EnableDeltaDiscovery' {
							Set-CMDiscoveryMethod -ActiveDirectoryGroupDiscovery -SiteCode $sitecode -EnableDeltaDiscovery $True | Out-Null
							break
						}
						'ADContainer' {
							$scope = New-CMADGroupDiscoveryScope -LdapLocation "LDAP://$($optx[1])" -Name "Domain Root" -RecursiveSearch $True
							try {
								Set-CMDiscoveryMethod -ActiveDirectoryGroupDiscovery -SiteCode $sitecode -AddGroupDiscoveryScope $scope -ErrorAction SilentlyContinue | Out-Null
							}
							catch {
								if ($_.Exception.Message -like "*already exists*") {
									Write-Log -Category info -Message "ldap path is already configured"
								}
								else {
									Write-Log -Category error -Message $_.Exception.Message
								}
							}
							break
						}
						'EnableFilteringExpiredLogon' {
							Set-CMDiscoveryMethod -ActiveDirectoryGroupDiscovery -SiteCode $sitecode -EnableFilteringExpiredLogon $True -TimeSinceLastLogonDays $optx[1] -ErrorAction SilentlyContinue | Out-Null
							break
						}
						'EnableFilteringExpiredPassword' {
							Set-CMDiscoveryMethod -ActiveDirectoryGroupDiscovery -SiteCode $sitecode -EnableFilteringExpiredPassword $True -TimeSinceLastPasswordUpdateDays $optx[1] -ErrorAction SilentlyContinue | Out-Null
							break
						}
					} # switch
				} # foreach
                break
            }
            'ActiveDirectoryUserDiscovery' {
                try {
                    Set-CMDiscoveryMethod -ActiveDirectoryUserDiscovery -SiteCode $sitecode -Enabled $True -ErrorAction SilentlyContinue | Out-Null
                    Write-Log -Category info -Message "discovery has been enabled. configuring options"
                    foreach ($opt in $discOpts.Split("|")) {
                        $optx = $opt.Split(':')
                        Write-Log -Category info -Message "option = $($optx[0])"
						Write-Log -Category info -Message "value  = $($optx[$optx.Count-1])"
                        switch ($optx[0]) {
                            'ADContainer' {
                                Set-CMDiscoveryMethod -ActiveDirectoryUserDiscovery -SiteCode $sitecode -ActiveDirectoryContainer "LDAP://$($optx[1])" -Recursive -ErrorAction SilentlyContinue | Out-Null
                                break
                            }
                            'EnableDetaDiscovery' {
                                Set-CMDiscoveryMethod -ActiveDirectoryUserDiscovery -SiteCode $sitecode -EnableDeltaDiscovery $True -ErrorAction SilentlyContinue | Out-Null
                                break
                            }
                            'ADAttributes' {
                                Set-CMDiscoveryMethod -ActiveDirectoryUserDiscovery -SiteCode $sitecode -AddAdditionalAttribute $optx[1].split(',') -ErrorAction SilentlyContinue | Out-Null
                                break
                            }
                        } # switch
                    } # foreach
                }
                catch {
                    Write-Log -Category error -Message $_.Exception.Message
                    $result = $False
                }
                break
            }
            'NetworkDiscovery' {
                try {
                    Set-CMDiscoveryMethod -NetworkDiscovery -SiteCode $sitecode -Enabled $True -ErrorAction SilentlyContinue | Out-Null
                    Write-Log -Category info -Message "discovery has been enabled. configuring options"
                }
                catch {
                    Write-Log -Category error -Message $_.Exception.Message
                    $result = $False
                }
                break
            }
            'HeartbeatDiscovery' {
                try {
                    Set-CMDiscoveryMethod -Heartbeat -SiteCode $sitecode -Enabled $True -ErrorAction SilentlyContinue | Out-Null
                    Write-Log -Category info -Message "discovery has been enabled. configuring options"
                }
                catch {
                    Write-Log -Category error -Message $_.Exception.Message
                    $result = $False
                }
                break
            }
        } # switch
        Write-Log -Category "info" -Message "- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -"
    } # foreach
    Invoke-CMForestDiscovery -SiteCode $sitecode | Out-Null
    Write-Log -Category info -Message "function runtime: $(Get-TimeOffset $time1)"
    Write-Output $result
} # function
