function Import-CmSiteConfigSiteServerRoles {
	<#
	.SYNOPSIS
	Configure ConfigMgr Site Server Roles and Features
	
	.DESCRIPTION
	Configure ConfigMgr Site Server Roles and Features
	
	.PARAMETER DataSet
	XML data set
	
	.EXAMPLE
	Set-CmxSiteServerRoles -DataSet $xmldata
	
	.NOTES
	General notes
	#>

    [CmdletBinding(SupportsShouldProcess=$True)]
    param (
        [parameter(Mandatory=$True)] 
        [ValidateNotNullOrEmpty()]
        [xml] $DataSet
    )
	Write-Log -Category "info" -Message "------------------------------ Import-CmSiteConfigSiteServerRoles -------------------------------"
    Write-Host "Configuring Site System Roles" -ForegroundColor Green
    $result = $True
    $Time1  = Get-Date
    foreach ($item in $DataSet.configuration.cmsite.sitesystemroles.sitesystemrole | Where-Object {$_.use -eq '1'}) {
        $roleName = $item.name
        $roleComm = $item.comment
		$roleopts = $item.roleoptions.roleoption | Where-Object {$_.use -eq '1'}
        Write-Log -Category "info" -Message "configuring site system role: $roleComm [$roleName]"
        switch ($RoleName) {
            'aisp' {
				if (Get-CMAssetIntelligenceSynchronizationPoint -SiteCode "$sitecode" -SiteSystemServerName "$hostname") {
					Write-Log -Category "info" -Message "asset intelligence sync point was already enabled"
				}
				else {
					try {
						Add-CMAssetIntelligenceSynchronizationPoint -SiteSystemServerName "$hostname" -ErrorAction SilentlyContinue | Out-Null
						Write-Log -Category "info" -Message "asset intelligence sync point enabled successfully"
						Set-CMAssetIntelligenceSynchronizationPoint -EnableSynchronization $True -ErrorAction SilentlyContinue | Out-Null
					}
					catch {
						Write-Log -Category error -Message $_.Exception.Message
						$result = $False
						break
					}
				}
				foreach ($roleopt in $roleopts) {
					switch ($roleopt.name) {
						'EnableAllReportingClass' {
							Write-Log -Category info -Message "enabling all reporting classes"
							try {
								Set-CMAssetIntelligenceClass -EnableAllReportingClass | Out-Null
							}
							catch {
								Write-Log -Category error -Message $_.Exception.Message
								$result = $False
							}
							break
						}
						'EnabledReportingClass' {
							Write-Log -Category info -Message "enabling class: $($roleopt.params)"
							try {
								Set-CMAssetIntelligenceClass -EnableReportingClass $roleopt.params | Out-Null
							}
							catch {
								Write-Log -Category error -Message $_.Exception.Message
								$result = $False
							}
							break
						}
					} # switch
				} # foreach
                break
            }
            'dp' {
				if (Get-CMDistributionPoint -SiteSystemServerName "$hostname" -ErrorAction SilentlyContinue) {
                    Write-Log -Category "info" -Message "distribution point role already added"
                }
				else {
					try {
						Add-CMDistributionPoint -SiteSystemServerName "$hostname" -ErrorAction SilentlyContinue | Out-Null
						Write-Log -Category "info" -Message "distribution point role added successfully"
					}
					catch {
						Write-Log -Category error -Message $_.Exception.Message
						$result = $False
						break
					}
				}
				$code = "Set-CMDistributionPoint `-SiteCode `"$sitecode`" `-SiteSystemServerName `"$hostname`""
				foreach ($roleopt in $roleopts) {
					$param = $roleopt.params
					if ($param -eq '@') {
						$param = "`-$($roleopt.name)"
					}
					elseif ($param -eq 'true') {
						$param = "`-$($roleopt.name) `$True"
					}
					elseif ($param -eq 'false') {
						$param = "`-$($roleopt.name) `$False"
					}
					elseif ($roleopt.name -like "*password*") {
						$param = "`-$($roleopt.name) `$(ConvertTo-SecureString -String `"$param`" -AsPlainText -Force)"
					}
					else {
						$param = "`-$($roleopt.name) `"$($roleopt.params)`""
					}
					$code += " $param"
					Write-Log -Category "info" -Message "dp option >> $param"
				} # foreach
				Write-Log -Category "info" -Message "command >> $code"
				try {
					Invoke-Expression -Command $code -ErrorAction Stop
					Write-Log -Category info -Message "expression has been applied successfully"
				}
				catch {
					Write-Log -Category error -Message $_.Exception.Message
					$result = $False
					break
				}
                break
            }
            'sup' {
                if (Get-CMSoftwareUpdatePoint -SiteCode "$sitecode" -SiteSystemServerName "$hostname") {
                    Write-Log -Category info -Message "software update point has already been configured"
					$code1 = ""
					$code2 = "Set-CMSoftwareUpdatePointComponent `-SiteCode `"$sitecode`" `-EnableSynchronization `$True"
                }
                else {
                    $code1 = "Add-CMSoftwareUpdatePoint `-SiteSystemServerName `"$hostname`" `-SiteCode `"$sitecode`""
					$code2 = "Set-CMSoftwareUpdatePointComponent `-SiteCode `"$sitecode`" `-EnableSynchronization `$True"
				}
				foreach ($roleopt in $roleopts) {
					$optname = $roleopt.name
					$params  = $roleopt.params
					switch ($optname) {
<#						'WsusAccessAccount' {
							if ($code1.Length -gt 0) {
								if ($params -eq 'NULL') {
									$code1 += " `-WsusAccessAccount `$null"
								}
								else {
									$code1 += " `-WsusAccessAccount `"$params`""
								}
							}
							break
						}
#>
						'HttpPort' {
							if ($code1.Length -gt 0) {
								$code1 += " `-WsusIisPort $params"
							}
							break
						}
						'HttpsPort' {
							if ($code1.Length -gt 0) {
								$code1 += " `-WsusIisSslPort $params"
							}
							break
						}
						'ClientConnectionType' {
							if ($code1.Length -gt 0) {
								$code1 += " `-ClientConnectionType $params"
							}
							break
						}
						'SynchronizeAction' {
							$code2 += " `-SynchronizeAction $params"
							break
						}
						'AddUpdateClassifications' {
							$code2 += " `-AddUpdateClassification "
							foreach ($uclass in $params.Split(',')) {
								if ($code2.EndsWith("AddUpdateClassification ")) {
									$code2 += " `"$uclass`""
								}
								else {
									$code2 += ",`"$uclass`""
								}
							}
							break
						}
						'AddProducts' {
							$code2 += " `-AddProduct "
							foreach ($product in $params.Split(',')) {
								if ($code2.EndsWith("AddProduct ")) {
									$code2 += " `"$product`""
								}
								else {
									$code2 += ",`"$product`""
								}
							}
							break
						}
						'ImmediatelyExpireSupersedence' {
							$code2 += " `-ImmediatelyExpireSupersedence `$$params"
							break
						}
						'EnableCallWsusCleanupWizard' {
							$code2 += " `-EnableCallWsusCleanupWizard `$$params"
							break
						}
					} # switch
				} # foreach
				if ($code1.Length -gt 0) {
					Write-Log -Category "info" -Message "command1 >> $code1"
                    try {
                        Invoke-Expression -Command $code1 -ErrorAction Stop
                        Write-Log -Category info -Message "expression has been applied successfully"
                    }
                    catch {
                        Write-Log -Category error -Message $_.Exception.Message
                        $result = $False
						break
                    }
				}
				if ($code2.Length -gt 0) {
					Write-Log -Category "info" -Message "command2 >> $code2"
					try {
						Invoke-Expression -Command $code2 -ErrorAction Stop
						Write-Log -Category info -Message "expression has been applied successfully"
					}
                    catch {
                        Write-Log -Category error -Message $_.Exception.Message
                        $result = $False
						break
                    }
				} # if
                break
            }
            'scp' {
                foreach ($roleopt in $siterole.roleoptions.roleoption | Where-Object {$_.use -eq '1'}) {
                    switch ($roleopt.name) {
                        'Mode' {
                            Write-Log -Category info -Message "setting $($roleopt.name) = $($roleopt.params)"
                            Set-CMServiceConnectionPoint -SiteCode P01 -SiteSystemServerName "$HostName" -Mode $roleopt.params
                            break
                        }
                    } # switch
                } # foreach
                break
            }
            'mp' {
                foreach ($roleopt in $roleopts) {
                    switch ($roleopt.name) {
                        'PublicFqdn' {
                            Write-Log -Category info -Message "setting $($roleopt.name) = $($roleopt.params)"
                            Set-CMSiteSystemServer -SiteCode $sitecode -SiteSystemServerName "$HostName" -PublicFqdn "$($roleopt.params)"
                            break
                        }
                        'FdmOperation' {
                            Write-Log -Category info -Message "setting $($roleopt.name) = $($roleopt.params)"
                            if ($roleopt.params -eq 'FALSE') {
                                Set-CMSiteSystemServer -SiteCode $sitecode -SiteSystemServerName "$HostName" -FdmOperation $False
                            }
                            else {
                                Set-CMSiteSystemServer -SiteCode $sitecode -SiteSystemServerName "$HostName" -FdmOperation $True
                            }
                            break
                        }
                        'AccountName' {
                            Write-Log -Category info -Message "setting $($roleopt.name) = $($roleopt.params)"
                            if ($roleopt.params -eq 'NULL') {
                                Set-CMSiteSystemServer -SiteCode $sitecode -SiteSystemServerName "$HostName" -AccountName $null
                            }
                            else {
                                Set-CMSiteSystemServer -SiteCode $sitecode -SiteSystemServerName "$HostName" -AccountName "$($roleopt.params)"
                            }
                            break
                        }
                        'EnableProxy' {
                            Set-CMSiteSystemServer -SiteCode $sitecode -EnableProxy $True
                            # ProxyAccessAccount=NAME,ProxyServerName=NAME,ProxyServerPort=INT
                            $params = $roleopt.params
                            if ($params.length -gt 0) {
                                foreach ($param in $roleopt.params.split(',')) {
                                    $pset = $param.split('=')
                                    Write-Log -Category info -Message "setting $($pset[0]) = $($pset[1])"
                                    switch ($pset[0]) {
                                        'ProxyAccessAccount' {
                                            Set-CMSiteSystemServer -SiteCode $sitecode -ProxyAccessAccount "$($pset[1])"
                                            break
                                        }
                                        'ProxyServerName' {
                                            Set-CMSiteSystemServer -SiteCode $sitecode -ProxyServerName "$($pset[1])"
                                            break
                                        }
                                        'ProxyServerPort' {
                                            Set-CMSiteSystemServer -SiteCode $sitecode -ProxyServerPort $pset[1]
                                            break
                                        }
                                    } # switch
                                } # foreach
                            }
                            else {
                                Write-Log -Category "warning" -Message "EnableProxy parameters list is empty"
                            }
                            break
                        }
                        'PublishDNS' {
                            try {
                                if ($roleopt.params -eq 'True') {
                                    Set-CMManagementPointComponent -SiteCode "$sitecode" -PublishDns $True | Out-Null
                                    Write-Log -Category info -Message "publishing to DNS enabled"
                                }
                                catch {
                                    Write-Log -Category error -Message $_.Exception.Message
                                }
                            }
                            catch {}
                            break
                        }
                    } #switch
                } # foreach
                break
            }
            'ssrp' {
                # sql server reporting services point
                foreach ($roleopt in $roleopts) {
                    Write-Log -Category info -Message "setting $($roleopt.name) = $($roleopt.params)"
                    switch ($roleopt.name) {
                        'DatabaseServerName' {
                            $dbserver = $roleopt.params
                            break
                        }
                        'DatabaseName' {
                            $dbname = $roleopt.params
                            break
                        }
                        'UserName' {
                            $dbuser = $roleopt.params
                            break
                        }
                        'FolderName' {
                            $foldername = $roleopt.params
                            break
                        }
                    } # switch
                } # foreach
                if ($dbserver -and $dbname -and $dbuser) {
					if (Get-WmiObject -Class Win32_UserAccount | Where-Object {$_.Caption -eq "$dbUser"}) {
						if (Get-CMReportingServicePoint -SiteCode "$sitecode" -SiteSystemServerName "$HostName") {
							Write-Log -Category info -Message "reporting services point is already active"
						}
						else {
							try {
								Add-CMReportingServicePoint -SiteCode "$sitecode" -SiteSystemServerName "$HostName" -DatabaseServerName "$dbserver" -DatabaseName "$dbname" -UserName "$dbuser" -ErrorAction SilentlyContinue | Out-Null
								Write-Log -Category info -Message "reporting services point has been configured"
							}
							catch {
								Write-Log -Category error -Message "your code just blew chunks. what a mess."
								Write-Log -Category error -Message $_.Exception.Message
								$result = $False
								break
							}
						}
					}
					else {
						Write-Log -Category "error" -Message "user account $dbuser was not found in the current AD domain"
						$result = $False
						break
                    }
                }
                break
            }
            'cmg' {
                # cloud management gateway
				Write-Log -Category "info" -Message "configuring role options"
                foreach ($roleopt in $roleopts) {
                    switch ($roleopt.name) {
                        'CloudManagementGatewayName' {
                            try {
                                Add-CMCloudManagementGatewayConnectionPoint -CloudManagementGatewayName "$($roleopt.params)" -SiteSystemServerName "$HostName" -SiteCode "$sitecode" | Out-Null
                                Write-Log -Category info -Message "cloud management gateway has been configured"
                            }
                            catch {
                                Write-Log -Category error -Message $_.Exception.Message
                            }
                            break
                        }
                    } # switch
                } # foreach
                break
            }
            'acwsp' {
                if (Get-CMApplicationCatalogWebServicePoint) {
                    Write-Log -Category info -Message "application web catalog service point role is already configured"
                }
                else {
                    try {
                        Add-CMApplicationCatalogWebServicePoint -SiteCode "$sitecode" -SiteSystemServerName "$hostname" | Out-Null
                        Write-Log -Category info -Message "application web catalog service point role added successfully"
                    }
                    catch {
                        Write-Log -Category error -Message $_.Exception.Message
						Write-Log -Category error -Message $_
                        $result = $False
						break
                    }
                }
                break
            }
            'acwp' {
				if (Get-CMApplicationCatalogWebsitePoint) {
					Write-Log -Category "info" -Message "application website point site role already added"
				}
				else {
					$code = "Add-CMApplicationCatalogWebsitePoint `-SiteSystemServerName `"$hostname`" `-SiteCode `"$sitecode`""
					$code += " `-ApplicationWebServicePointServerName `"$hostname`""
					foreach ($roleopt in $roleopts) {
						$optName = $roleopt.name
						$optData = $roleopt.params
						switch ($optName) {
							'CommuncationType' {
								$code += " `-CommunicationType $optData"
								break
							}
							'ClientConnectionType' {
								$code += " `-ClientConnectionType $optData"
								break
							}
							'OrganizationName' {
								$code += " `-OrganizationName `"$optData`""
								break
							}
							'ThemeColor' {
								$code += " `-Color $optData"
								break
							}
						} # switch
					} # foreach
					Write-Log -Category "info" -Message "command >> $code"
					try {
						Invoke-Expression -Command $code -ErrorAction Stop
						Write-Log -Category info -Message "expression has been applied successfully"
					}
                    catch {
                        Write-Log -Category error -Message $_.Exception.Message
                        $result = $False
						break
                    }
				} # if
                break
            }
			'epp' {
				if (Get-CMEndpointProtectionPoint -SiteCode "P01") {
					Write-Log -Category "info" -Message "endpoint protection role already added"
				}
				else {
					try {
						Add-CMEndpointProtectionPoint -SiteCode "P01" -SiteSystemServerName $hostname -ProtectionService BasicMembership -ErrorAction SilentlyContinue | Out-Null
						Write-Log -Category "info" -Message "endpoint protection role added successfully"
					}
					catch {
						Write-Log -Category "error" -Message $_.Exception.Message
						$result = $False
						break
					}
				}
				break
			}
        } # switch
        Write-Log -Category info -Message "- - - - - - - - - - - - - - - - - - - - - - - - - -"
    } # foreach
    Write-Log -Category info -Message "function runtime: $(Get-TimeOffset $time1)"
    Write-Output $result
}
