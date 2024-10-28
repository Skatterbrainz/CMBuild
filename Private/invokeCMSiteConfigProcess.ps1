function invokeCMSiteConfigProcess {
	param (
		[parameter(Mandatory=$True)] $ControlSet,
		[parameter(Mandatory=$True)] $DataSet
	)
	foreach ($control in $controlset) {
		$controlCode = $control.name
		writeLogFile -Category info -Message "processing control code group: $controlCode"
		switch ($controlCode) {
			'ENVIRONMENT' {
				if (testCmxAdContainer) {
					writeLogFile -Category "info" -Message "AD container verified"
				} else {
					writeLogFile -Category "warning" -Message "AD container could not be verified"
				}
				if (testCmxAdSchema) {
					writeLogFile -Category "info" -Message "AD schema has been extended"
				} else {
					writeLogFile -Category "warning" -Message "AD schema has not been extended"
				}
			}
			'ACCOUNTS' {
				$null = importCmxAccounts -DataSet $xmldata
			}
			'SERVERSETTINGS' {
				$null = importCmxServerSettings -DataSet $xmldata
			}
			'ADFOREST' {
				$null = setCmxADForest -DataSet $xmldata
			}
			'DISCOVERY' {
				$null = importCmxDiscoveryMethods -DataSet $xmldata
				$null = Invoke-CMForestDiscovery -SiteCode $sitecode
			}
			'BOUNDARYGROUPS' {
				$null = importCmxBoundaryGroups -DataSet $xmldata
			}
			'BOUNDARIES' {
				if ((-not($AutoBoundaries)) -or ($ForceBoundaries)) {
					$null = setCmxBoundaries -DataSet $xmldata
				}
			}
			'SITEROLES' {
				$null = applyCmxSiteServerRoles -DataSet $xmldata
			}
			'CLIENTSETTINGS' {
				$null = importCmxClientSettings -DataSet $xmldata
			}
			'CLIENTINSTALL' {
				$null = importCmxClientPush -DataSet $xmldata
			}
			'FOLDERS' {
				if (setCmxSiteConfigFolders -SiteCode $sitecode -DataSet $xmldata) {
					Write-Host "Console folders have been created" -ForegroundColor Green
				} else {
					Write-Warning "Failed to create console folders"
				}
			}
			'DPGROUPS' {
				$null = importCmxDPGroups -DataSet $xmldata
			}
			'QUERIES' {
				if (importCmxQueries -DataSet $xmldata) {
					Write-Host "Custom Queries have been created" -ForegroundColor Green
				} else {
					Write-Warning "Failed to create custom queries"
				}
			}
			'COLLECTIONS' {
				$null = importCmxCollections -DataSet $xmldata
			}
			'OSIMAGES' {
				$null = importCmxOSImages -DataSet $xmldata
			}
			'OSINSTALLERS' {
				$null = importCmxOSInstallers -DataSet $xmldata
			}
			'MTASKS' {
				$null = importCmxMaintenanceTasks -DataSet $xmldata
			}
			'APPCATEGORIES' {
				$null = importCmxAppCategories -DataSet $xmldata
			}
			'APPLICATIONS' {
				$null = importCmxApplications -DataSet $xmldata
			}
			'MALWAREPOLICIES' {
				$null = importCmxMalwarePolicies -DataSet $xmldata
			}
		}
	}
}