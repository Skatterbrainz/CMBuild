function Invoke-CMSiteConfigProcess {
	param (
		[parameter(Mandatory=$True)] $ControlSet,
		[parameter(Mandatory=$True)] $DataSet
	)
	foreach ($control in $controlset) {
		$controlCode = $control.name
		Write-Log -Category info -Message "processing control code group: $controlCode"
		switch ($controlCode) {
			'ENVIRONMENT' {
				if (Test-CMxAdContainer) {
					Write-Log -Category "info" -Message "AD container verified"
				}
				else {
					Write-Log -Category "warning" -Message "AD container could not be verified"
				}
				if (Test-CMxAdSchema) {
					Write-Log -Category "info" -Message "AD schema has been extended"
				}
				else {
					Write-Log -Category "warning" -Message "AD schema has not been extended"
				}
				break
			}
			'ACCOUNTS' {
				Import-CmxAccounts -DataSet $xmldata | Out-Null
				break
			}
			'SERVERSETTINGS' {
				Import-CmxServerSettings -DataSet $xmldata | Out-Null
				break
			}
			'ADFOREST' {
				Set-CmxADForest -DataSet $xmldata | Out-Null
				break
			}
			'DISCOVERY' {
				Import-CmxDiscoveryMethods -DataSet $xmldata | Out-Null
				Invoke-CMForestDiscovery -SiteCode $sitecode | Out-Null
				break
			}
			'BOUNDARYGROUPS' {
				Import-CmxBoundaryGroups -DataSet $xmldata | Out-Null
				break
			}
			'BOUNDARIES' {
				if ((-not($AutoBoundaries)) -or ($ForceBoundaries)) {
					Set-CmxBoundaries -DataSet $xmldata | Out-Null
				}
				break
			}
			'SITEROLES' {
				Set-CmxSiteServerRoles -DataSet $xmldata | Out-Null
				break
			}
			'CLIENTSETTINGS' {
				Import-CmxClientSettings -DataSet $xmldata | Out-Null
				break
			}
			'CLIENTINSTALL' {
				Import-CmxClientPush -DataSet $xmldata | Out-Null
				break
			}
			'FOLDERS' {
				if (Set-CMSiteConfigFolders -SiteCode $sitecode -DataSet $xmldata) {
					Write-Host "Console folders have been created" -ForegroundColor Green
				}
				else {
					Write-Warning "Failed to create console folders"
				}
				break
			}
			'DPGROUPS' {
				Import-CmxDPGroups -DataSet $xmldata | Out-Null
				break
			}
			'QUERIES' {
				if (Import-CmxQueries -DataSet $xmldata) {
					Write-Host "Custom Queries have been created" -ForegroundColor Green
				}
				else {
					Write-Warning "Failed to create custom queries"
				}
				break
			}
			'COLLECTIONS' {
				Import-CmxCollections -DataSet $xmldata | Out-Null
				break
			}
			'OSIMAGES' {
				Import-CmxOSImages -DataSet $xmldata | Out-Null
				break
			}
			'OSINSTALLERS' {
				Import-CmxOSInstallers -DataSet $xmldata | Out-Null
				break
			}
			'MTASKS' {
				Import-CmxMaintenanceTasks -DataSet $xmldata | Out-Null
				break
			}
			'APPCATEGORIES' {
				Import-CmxAppCategories -DataSet $xmldata | Out-Null
				break
			}
			'APPLICATIONS' {
				Import-CmxApplications -DataSet $xmldata | Out-Null
				break
			}
			'MALWAREPOLICIES' {
				Import-CmxMalwarePolicies -DataSet $xmldata | Out-Null
				break
			}
		}
	}
}