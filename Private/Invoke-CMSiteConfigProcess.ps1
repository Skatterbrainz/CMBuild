function Invoke-CMSiteConfigProcess {
	param (
		[parameter(Mandatory=$True)] 
			$ControlSet,
		[parameter(Mandatory=$True)] 
			[xml] $DataSet
	)
	foreach ($control in $controlset) {
		$controlCode = $control.name
		Write-Log -Category info -Message "processing control code group: $controlCode"
		switch ($controlCode) {
			'ENVIRONMENT' {
				if (Test-ADContainer) {
					Write-Log -Category "info" -Message "AD container verified"
				}
				else {
					Write-Log -Category "warning" -Message "AD container could not be verified"
				}
				if (Test-CmScADSchema) {
					Write-Log -Category "info" -Message "AD schema has been extended"
				}
				else {
					Write-Log -Category "warning" -Message "AD schema has not been extended"
				}
				break
			}
			'ACCOUNTS' {
				Import-CmSiteConfigAccounts -DataSet $xmldata | Out-Null
				break
			}
			'SERVERSETTINGS' {
				Import-CmSiteConfigServerSettings -DataSet $xmldata | Out-Null
				break
			}
			'ADFOREST' {
				Import-CmSiteConfigADForest -DataSet $xmldata | Out-Null
				break
			}
			'DISCOVERY' {
				Import-CmSiteConfigDiscoveryMethods -DataSet $xmldata | Out-Null
				break
			}
			'BOUNDARYGROUPS' {
				Import-CmSiteConfigBoundaryGroups -DataSet $xmldata | Out-Null
				break
			}
			'BOUNDARIES' {
				if ((-not($AutoBoundaries)) -or ($ForceBoundaries)) {
					Import-CmSiteConfigSiteBoundaries -DataSet $xmldata | Out-Null
				}
				break
			}
			'SITEROLES' {
				Import-CmSiteConfigSiteServerRoles -DataSet $xmldata | Out-Null
				break
			}
			'CLIENTSETTINGS' {
				Import-CmSiteConfigClientSettings -DataSet $xmldata | Out-Null
				break
			}
			'CLIENTINSTALL' {
				Import-CmSiteConfigClientPush -DataSet $xmldata | Out-Null
				break
			}
			'FOLDERS' {
				if (Import-CmSiteConfigConsoleFolders -SiteCode $sitecode -DataSet $xmldata) {
					Write-Host "Console folders have been created" -ForegroundColor Green
				}
				else {
					Write-Warning "Failed to create console folders"
				}
				break
			}
			'DPGROUPS' {
				Import-CmSiteConfigDPGroups -DataSet $xmldata | Out-Null
				break
			}
			'QUERIES' {
				if (Import-CmSiteConfigQueries -DataSet $xmldata) {
					Write-Host "Custom Queries have been created" -ForegroundColor Green
				}
				else {
					Write-Warning "Failed to create custom queries"
				}
				break
			}
			'COLLECTIONS' {
				Import-CmSiteConfigCollections -DataSet $xmldata | Out-Null
				break
			}
			'OSIMAGES' {
				Import-CmSiteConfigOSImages -DataSet $xmldata | Out-Null
				break
			}
			'OSINSTALLERS' {
				Import-CmSiteConfigOSInstallers -DataSet $xmldata | Out-Null
				break
			}
			'MTASKS' {
				Import-CmSiteConfigMaintenanceTasks -DataSet $xmldata | Out-Null
				break
			}
			'APPCATEGORIES' {
				Import-CmSiteConfigAppCategories -DataSet $xmldata | Out-Null
				break
			}
			'APPLICATIONS' {
				Import-CmSiteConfigApplications -DataSet $xmldata | Out-Null
				break
			}
			'MALWAREPOLICIES' {
				Import-CmSiteConfigMalwarePolicies -DataSet $xmldata | Out-Null
				break
			}
		}
	}
}