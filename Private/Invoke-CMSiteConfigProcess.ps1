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
				} else {
					Write-Log -Category "warning" -Message "AD container could not be verified"
				}
				if (Test-CMxAdSchema) {
					Write-Log -Category "info" -Message "AD schema has been extended"
				} else {
					Write-Log -Category "warning" -Message "AD schema has not been extended"
				}
			}
			'ACCOUNTS' {
				$null = Import-CmxAccounts -DataSet $xmldata
			}
			'SERVERSETTINGS' {
				$null = Import-CmxServerSettings -DataSet $xmldata
			}
			'ADFOREST' {
				$null = Set-CmxADForest -DataSet $xmldata
			}
			'DISCOVERY' {
				$null = Import-CmxDiscoveryMethods -DataSet $xmldata
				$null = Invoke-CMForestDiscovery -SiteCode $sitecode
			}
			'BOUNDARYGROUPS' {
				$null = Import-CmxBoundaryGroups -DataSet $xmldata
			}
			'BOUNDARIES' {
				if ((-not($AutoBoundaries)) -or ($ForceBoundaries)) {
					$null = Set-CmxBoundaries -DataSet $xmldata
				}
			}
			'SITEROLES' {
				$null = Set-CmxSiteServerRoles -DataSet $xmldata
			}
			'CLIENTSETTINGS' {
				$null = Import-CmxClientSettings -DataSet $xmldata
			}
			'CLIENTINSTALL' {
				$null = Import-CmxClientPush -DataSet $xmldata
			}
			'FOLDERS' {
				if (Set-CMSiteConfigFolders -SiteCode $sitecode -DataSet $xmldata) {
					Write-Host "Console folders have been created" -ForegroundColor Green
				} else {
					Write-Warning "Failed to create console folders"
				}
			}
			'DPGROUPS' {
				$null = Import-CmxDPGroups -DataSet $xmldata
			}
			'QUERIES' {
				if (Import-CmxQueries -DataSet $xmldata) {
					Write-Host "Custom Queries have been created" -ForegroundColor Green
				} else {
					Write-Warning "Failed to create custom queries"
				}
			}
			'COLLECTIONS' {
				$null = Import-CmxCollections -DataSet $xmldata
			}
			'OSIMAGES' {
				$null = Import-CmxOSImages -DataSet $xmldata
			}
			'OSINSTALLERS' {
				$null = Import-CmxOSInstallers -DataSet $xmldata
			}
			'MTASKS' {
				$null = Import-CmxMaintenanceTasks -DataSet $xmldata
			}
			'APPCATEGORIES' {
				$null = Import-CmxAppCategories -DataSet $xmldata
			}
			'APPLICATIONS' {
				$null = Import-CmxApplications -DataSet $xmldata
			}
			'MALWAREPOLICIES' {
				$null = Import-CmxMalwarePolicies -DataSet $xmldata
			}
		}
	}
}