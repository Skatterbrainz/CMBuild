function importCmxAppCategories {
	[CmdletBinding(SupportsShouldProcess=$True)]
	param (
		[parameter(Mandatory=$True)]
		[ValidateNotNullOrEmpty()]
		$DataSet
	)
	writeLogFile -Category "info" -Message "------------------------------ importCmxAppCategories -------------------------------"
	Write-Host "Configuring application categories" -ForegroundColor Green
	$result = $true
	$Time1  = Get-Date
	foreach ($item in $DataSet.configuration.cmsite.appcategories.appcategory | Where-Object {$_.use -eq '1'}) {
		$catName = $item.name
		$catComm = $item.comment
		writeLogFile -Category "info" -Message "application category: $catName"
		if (Get-CMCategory -Name $catName -CategoryType AppCategories) {
			writeLogFile -Category "info" -Message "category already exists"
		} else {
			try {
				$null = New-CMCategory -CategoryType AppCategories -Name $catName -ErrorAction SilentlyContinue
				writeLogFile -Category "info" -Message "category was created successfully"
			} catch {
				writeLogFile -Category error -Message $_.Exception.Message
				$result = $False
				break
			}
		}
	} # foreach
	writeLogFile -Category info -Message "function runtime: $(getTimeOffset $time1)"
	Write-Output $result
}
