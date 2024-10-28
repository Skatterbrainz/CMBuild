function importCmxCollections {
	[CmdletBinding(SupportsShouldProcess=$True)]
	param (
		[parameter(Mandatory=$True)]
		[ValidateNotNullOrEmpty()]
		$DataSet
	)
	writeLogFile -Category "info" -Message "------------------------------ importCmxCollections -------------------------------"
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
		writeLogFile -Category "info" -Message "collection: $collName"
		if ($coll = Get-CMCollection -Name $collName) {
			writeLogFile -Category "info" -Message "collection already created"
		} else {
			try {
				$coll = New-CMCollection -Name $collName -CollectionType $collType -Comment $collComm -LimitingCollectionName $collBase -ErrorAction SilentlyContinue
				writeLogFile -Category "info" -Message "collection created successfully"
			} catch {
				writeLogFile -Category "error" -Message $_.Exception.Message
				$result = $False
				break
			}
		}
		writeLogFile -Category "info" -Message "moving object to folder: $collPath"
		$coll | Move-CMObject -FolderPath $collPath | Out-Null
		writeLogFile -Category "info" -Message "configuring membership rules"
		switch ($collRuleType) {
			'direct' {
				writeLogFile -Category "info" -Message "associating direct membership rule"
				break
			}
			'query' {
				writeLogFile -Category "info" -Message "associating query membership rule"
				try {
					Add-CMUserCollectionQueryMembershipRule -CollectionName $collName -RuleName "1" -QueryExpression $collRuleText
				}
				catch {
					writeLogFile -Category "error" -Message $_.Exception.Message
					$result = $False
					break
				}
				break
			}
		} # switch
		Write-Verbose "- - - - - - - - - - - - - - - - - - - - - - - - - - - -"
	} # foreach
	writeLogFile -Category info -Message "function runtime: $(getTimeOffset $time1)"
	Write-Output $result
}
