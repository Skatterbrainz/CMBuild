function applyCmxSiteServerRoles {
	[CmdletBinding(SupportsShouldProcess=$True)]
	param (
		[parameter(Mandatory=$True)] 
		[ValidateNotNullOrEmpty()]
		$DataSet
	)
	writeLogFile -Category "info" -Message "------------------------------ applyCmxSiteServerRoles -------------------------------"
	Write-Host "Configuring Site System Roles" -ForegroundColor Green
	$result = $True
	$Time1  = Get-Date
	foreach ($item in $DataSet.configuration.cmsite.sitesystemroles.sitesystemrole | Where-Object {$_.use -eq '1'}) {
		$roleName = $item.name
		$roleComm = $item.comment
		$roleopts = $item.roleoptions.roleoption | Where-Object {$_.use -eq '1'}
		writeLogFile -Category "info" -Message "configuring site system role: $roleComm [$roleName]"
		switch ($RoleName) {
			'aisp' {
				if (Get-CMAssetIntelligenceSynchronizationPoint -SiteCode "$sitecode" -SiteSystemServerName "$CmBuildSettings['ComputerName']") {
					writeLogFile -Category "info" -Message "asset intelligence sync point was already enabled"
				} else {
					try {
						Add-CMAssetIntelligenceSynchronizationPoint -SiteSystemServerName "$CmBuildSettings['ComputerName']" -ErrorAction SilentlyContinue | Out-Null
						writeLogFile -Category "info" -Message "asset intelligence sync point enabled successfully"
						Set-CMAssetIntelligenceSynchronizationPoint -EnableSynchronization $True -ErrorAction SilentlyContinue | Out-Null
					} catch {
						writeLogFile -Category error -Message $_.Exception.Message
						$result = $False
						break
					}
				}
				foreach ($roleopt in $roleopts) {
					switch ($roleopt.name) {
						'EnableAllReportingClass' {
							writeLogFile -Category info -Message "enabling all reporting classes"
							try {
								Set-CMAssetIntelligenceClass -EnableAllReportingClass | Out-Null
							} catch {
								writeLogFile -Category error -Message $_.Exception.Message
								$result = $False
							}
						}
						'EnabledReportingClass' {
							writeLogFile -Category info -Message "enabling class: $($roleopt.params)"
							try {
								Set-CMAssetIntelligenceClass -EnableReportingClass $roleopt.params | Out-Null
							} catch {
								writeLogFile -Category error -Message $_.Exception.Message
								$result = $False
							}
						}
					} # switch
				} # foreach
				break
			}
			'dp' {
				if (Get-CMDistributionPoint -SiteSystemServerName "$CmBuildSettings['ComputerName']" -ErrorAction SilentlyContinue) {
					writeLogFile -Category "info" -Message "distribution point role already added"
				} else {
					try {
						Add-CMDistributionPoint -SiteSystemServerName "$CmBuildSettings['ComputerName']" -ErrorAction SilentlyContinue | Out-Null
						writeLogFile -Category "info" -Message "distribution point role added successfully"
					} catch {
						writeLogFile -Category error -Message $_.Exception.Message
						$result = $False
						break
					}
				}
				$code = "Set-CMDistributionPoint `-SiteCode `"$sitecode`" `-SiteSystemServerName `"$CmBuildSettings['ComputerName']`""
				foreach ($roleopt in $roleopts) {
					$param = $roleopt.params
					if ($param -eq '@') {
						$param = "`-$($roleopt.name)"
					} elseif ($param -eq 'true') {
						$param = "`-$($roleopt.name) `$True"
					} elseif ($param -eq 'false') {
						$param = "`-$($roleopt.name) `$False"
					} elseif ($roleopt.name -like "*password*") {
						$param = "`-$($roleopt.name) `$(ConvertTo-SecureString -String `"$param`" -AsPlainText -Force)"
					} else {
						$param = "`-$($roleopt.name) `"$($roleopt.params)`""
					}
					$code += " $param"
					writeLogFile -Category "info" -Message "dp option >> $param"
				} # foreach
				writeLogFile -Category "info" -Message "command >> $code"
				try {
					Invoke-Expression -Command $code -ErrorAction Stop
					writeLogFile -Category info -Message "expression has been applied successfully"
				} catch {
					writeLogFile -Category error -Message $_.Exception.Message
					$result = $False
					break
				}
			}
			'sup' {
				if (Get-CMSoftwareUpdatePoint -SiteCode "$sitecode" -SiteSystemServerName "$CmBuildSettings['ComputerName']") {
					writeLogFile -Category info -Message "software update point has already been configured"
					$code1 = ""
					$code2 = "Set-CMSoftwareUpdatePointComponent `-SiteCode `"$sitecode`" `-EnableSynchronization `$True"
				} else {
					$code1 = "Add-CMSoftwareUpdatePoint `-SiteSystemServerName `"$CmBuildSettings['ComputerName']`" `-SiteCode `"$sitecode`""
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
						}
						'HttpsPort' {
							if ($code1.Length -gt 0) {
								$code1 += " `-WsusIisSslPort $params"
							}
						}
						'ClientConnectionType' {
							if ($code1.Length -gt 0) {
								$code1 += " `-ClientConnectionType $params"
							}
						}
						'SynchronizeAction' {
							$code2 += " `-SynchronizeAction $params"
						}
						'AddUpdateClassifications' {
							$code2 += " `-AddUpdateClassification "
							foreach ($uclass in $params.Split(',')) {
								if ($code2.EndsWith("AddUpdateClassification ")) {
									$code2 += " `"$uclass`""
								} else {
									$code2 += ",`"$uclass`""
								}
							}
						}
						'AddProducts' {
							$code2 += " `-AddProduct "
							foreach ($product in $params.Split(',')) {
								if ($code2.EndsWith("AddProduct ")) {
									$code2 += " `"$product`""
								} else {
									$code2 += ",`"$product`""
								}
							}
						}
						'ImmediatelyExpireSupersedence' {
							$code2 += " `-ImmediatelyExpireSupersedence `$$params"
						}
						'EnableCallWsusCleanupWizard' {
							$code2 += " `-EnableCallWsusCleanupWizard `$$params"
						}
					} # switch
				} # foreach
				if ($code1.Length -gt 0) {
					writeLogFile -Category "info" -Message "command1 >> $code1"
					try {
						Invoke-Expression -Command $code1 -ErrorAction Stop
						writeLogFile -Category info -Message "expression has been applied successfully"
					} catch {
						writeLogFile -Category error -Message $_.Exception.Message
						$result = $False
						break
					}
				}
				if ($code2.Length -gt 0) {
					writeLogFile -Category "info" -Message "command2 >> $code2"
					try {
						Invoke-Expression -Command $code2 -ErrorAction Stop
						writeLogFile -Category info -Message "expression has been applied successfully"
					} catch {
						writeLogFile -Category error -Message $_.Exception.Message
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
							writeLogFile -Category info -Message "setting $($roleopt.name) = $($roleopt.params)"
							Set-CMServiceConnectionPoint -SiteCode P01 -SiteSystemServerName "$CmBuildSettings['ComputerName']" -Mode $roleopt.params
							break
						}
					} # switch
				} # foreach
			}
			'mp' {
				foreach ($roleopt in $roleopts) {
					switch ($roleopt.name) {
						'PublicFqdn' {
							writeLogFile -Category info -Message "setting $($roleopt.name) = $($roleopt.params)"
							Set-CMSiteSystemServer -SiteCode $sitecode -SiteSystemServerName "$CmBuildSettings['ComputerName']" -PublicFqdn "$($roleopt.params)"
						}
						'FdmOperation' {
							writeLogFile -Category info -Message "setting $($roleopt.name) = $($roleopt.params)"
							if ($roleopt.params -eq 'FALSE') {
								Set-CMSiteSystemServer -SiteCode $sitecode -SiteSystemServerName "$CmBuildSettings['ComputerName']" -FdmOperation $False
							} else {
								Set-CMSiteSystemServer -SiteCode $sitecode -SiteSystemServerName "$CmBuildSettings['ComputerName']" -FdmOperation $True
							}
						}
						'AccountName' {
							writeLogFile -Category info -Message "setting $($roleopt.name) = $($roleopt.params)"
							if ($roleopt.params -eq 'NULL') {
								Set-CMSiteSystemServer -SiteCode $sitecode -SiteSystemServerName "$CmBuildSettings['ComputerName']" -AccountName $null
							} else {
								Set-CMSiteSystemServer -SiteCode $sitecode -SiteSystemServerName "$CmBuildSettings['ComputerName']" -AccountName "$($roleopt.params)"
							}
						}
						'EnableProxy' {
							Set-CMSiteSystemServer -SiteCode $sitecode -EnableProxy $True
							# ProxyAccessAccount=NAME,ProxyServerName=NAME,ProxyServerPort=INT
							$params = $roleopt.params
							if ($params.length -gt 0) {
								foreach ($param in $roleopt.params.split(',')) {
									$pset = $param.split('=')
									writeLogFile -Category info -Message "setting $($pset[0]) = $($pset[1])"
									switch ($pset[0]) {
										'ProxyAccessAccount' {
											Set-CMSiteSystemServer -SiteCode $sitecode -ProxyAccessAccount "$($pset[1])"
										}
										'ProxyServerName' {
											Set-CMSiteSystemServer -SiteCode $sitecode -ProxyServerName "$($pset[1])"
										}
										'ProxyServerPort' {
											Set-CMSiteSystemServer -SiteCode $sitecode -ProxyServerPort $pset[1]
										}
									} # switch
								} # foreach
							} else {
								writeLogFile -Category "warning" -Message "EnableProxy parameters list is empty"
							}
						}
						'PublishDNS' {
							try {
								if ($roleopt.params -eq 'True') {
									Set-CMManagementPointComponent -SiteCode "$sitecode" -PublishDns $True | Out-Null
									writeLogFile -Category info -Message "publishing to DNS enabled"
								} catch {
									writeLogFile -Category error -Message $_.Exception.Message
								}
							}
							catch {}
						}
					} #switch
				} # foreach
			}
			'ssrp' {
				# sql server reporting services point
				foreach ($roleopt in $roleopts) {
					writeLogFile -Category info -Message "setting $($roleopt.name) = $($roleopt.params)"
					switch ($roleopt.name) {
						'DatabaseServerName' {
							$dbserver = $roleopt.params
						}
						'DatabaseName' {
							$dbname = $roleopt.params
						}
						'UserName' {
							$dbuser = $roleopt.params
						}
						'FolderName' {
							$foldername = $roleopt.params
						}
					} # switch
				} # foreach
				if ($dbserver -and $dbname -and $dbuser) {
					if (Get-WmiObject -Class Win32_UserAccount | Where-Object {$_.Caption -eq "$dbUser"}) {
						if (Get-CMReportingServicePoint -SiteCode "$sitecode" -SiteSystemServerName "$CmBuildSettings['ComputerName']") {
							writeLogFile -Category info -Message "reporting services point is already active"
						} else {
							try {
								Add-CMReportingServicePoint -SiteCode "$sitecode" -SiteSystemServerName "$CmBuildSettings['ComputerName']" -DatabaseServerName "$dbserver" -DatabaseName "$dbname" -UserName "$dbuser" -ErrorAction SilentlyContinue | Out-Null
								writeLogFile -Category info -Message "reporting services point has been configured"
							} catch {
								writeLogFile -Category error -Message "your code just blew chunks. what a mess."
								writeLogFile -Category error -Message $_.Exception.Message
								$result = $False
								break
							}
						}
					} else {
						writeLogFile -Category "error" -Message "user account $dbuser was not found in the current AD domain"
						$result = $False
						break
					}
				}
			}
			'cmg' {
				# cloud management gateway
				writeLogFile -Category "info" -Message "configuring role options"
				foreach ($roleopt in $roleopts) {
					switch ($roleopt.name) {
						'CloudManagementGatewayName' {
							try {
								Add-CMCloudManagementGatewayConnectionPoint -CloudManagementGatewayName "$($roleopt.params)" -SiteSystemServerName "$CmBuildSettings['ComputerName']" -SiteCode "$sitecode" | Out-Null
								writeLogFile -Category info -Message "cloud management gateway has been configured"
							} catch {
								writeLogFile -Category error -Message $_.Exception.Message
							}
						}
					} # switch
				} # foreach
			}
			'acwsp' {
				if (Get-CMApplicationCatalogWebServicePoint) {
					writeLogFile -Category info -Message "application web catalog service point role is already configured"
				} else {
					try {
						Add-CMApplicationCatalogWebServicePoint -SiteCode "$sitecode" -SiteSystemServerName "$CmBuildSettings['ComputerName']" | Out-Null
						writeLogFile -Category info -Message "application web catalog service point role added successfully"
					} catch {
						writeLogFile -Category error -Message $_.Exception.Message
						writeLogFile -Category error -Message $_
						$result = $False
						break
					}
				}
			}
			'acwp' {
				if (Get-CMApplicationCatalogWebsitePoint) {
					writeLogFile -Category "info" -Message "application website point site role already added"
				} else {
					$code = "Add-CMApplicationCatalogWebsitePoint `-SiteSystemServerName `"$CmBuildSettings['ComputerName']`" `-SiteCode `"$sitecode`""
					$code += " `-ApplicationWebServicePointServerName `"$CmBuildSettings['ComputerName']`""
					foreach ($roleopt in $roleopts) {
						$optName = $roleopt.name
						$optData = $roleopt.params
						switch ($optName) {
							'CommuncationType' {
								$code += " `-CommunicationType $optData"
							}
							'ClientConnectionType' {
								$code += " `-ClientConnectionType $optData"
							}
							'OrganizationName' {
								$code += " `-OrganizationName `"$optData`""
							}
							'ThemeColor' {
								$code += " `-Color $optData"
							}
						} # switch
					} # foreach
					writeLogFile -Category "info" -Message "command >> $code"
					try {
						Invoke-Expression -Command $code -ErrorAction Stop
						writeLogFile -Category info -Message "expression has been applied successfully"
					} catch {
						writeLogFile -Category error -Message $_.Exception.Message
						$result = $False
						break
					}
				} # if
			}
			'epp' {
				if (Get-CMEndpointProtectionPoint -SiteCode "P01") {
					writeLogFile -Category "info" -Message "endpoint protection role already added"
				} else {
					try {
						Add-CMEndpointProtectionPoint -SiteCode "P01" -SiteSystemServerName $CmBuildSettings['ComputerName'] -ProtectionService BasicMembership -ErrorAction SilentlyContinue | Out-Null
						writeLogFile -Category "info" -Message "endpoint protection role added successfully"
					} catch {
						writeLogFile -Category "error" -Message $_.Exception.Message
						$result = $False
						break
					}
				}
			}
		} # switch
		writeLogFile -Category info -Message "- - - - - - - - - - - - - - - - - - - - - - - - - -"
	} # foreach
	writeLogFile -Category info -Message "function runtime: $(getTimeOffset $time1)"
	Write-Output $result
}
