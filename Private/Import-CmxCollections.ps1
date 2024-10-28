function Import-CmxCollections {
	[CmdletBinding(SupportsShouldProcess=$True)]
	param (
		[parameter(Mandatory=$True)]
		[ValidateNotNullOrEmpty()]
		$DataSet
	)
	Write-Log -Category "info" -Message "------------------------------ Import-CmxCollections -------------------------------"
	Write-Host "Configuring collections" -ForegroundColor Green
	$result = $True
	$Time1  = Get-Date
	foreach ($item in $DataSet.configuration.cmsite.collections.collection) {
		$collName     = $item.name
		$collType     = $item.type
		$collComm     = $item.comment
		$collBase     = $item.parent
		$collPath     = $item.folder
		$collRuleType = $item.ruletype
		$collRuleText = $item.rule
		Write-Log -Category "info" -Message "collection: $collName"
		if ($coll = Get-CMCollection -Name $collName) {
			Write-Log -Category "info" -Message "collection already created"
		} else {
			try {
				$coll = New-CMCollection -Name $collName -CollectionType $collType -Comment $collComm -LimitingCollectionName $collBase -ErrorAction SilentlyContinue
				Write-Log -Category "info" -Message "collection created successfully"
			} catch {
				Write-Log -Category "error" -Message $_.Exception.Message
				$result = $False
				break
			}
		}
		Write-Log -Category "info" -Message "moving object to folder: $collPath"
		$coll | Move-CMObject -FolderPath $collPath | Out-Null
		Write-Log -Category "info" -Message "configuring membership rules"
		switch ($collRuleType) {
			'direct' {
				Write-Log -Category "info" -Message "associating direct membership rule"
				break
			}
			'query' {
				Write-Log -Category "info" -Message "associating query membership rule"
				try {
					Add-CMUserCollectionQueryMembershipRule -CollectionName $collName -RuleName "1" -QueryExpression $collRuleText
				}
				catch {
					Write-Log -Category "error" -Message $_.Exception.Message
					$result = $False
					break
				}
				break
			}
		} # switch
		Write-Verbose "- - - - - - - - - - - - - - - - - - - - - - - - - - - -"
	} # foreach
	Write-Log -Category info -Message "function runtime: $(Get-TimeOffset $time1)"
	Write-Output $result
}
