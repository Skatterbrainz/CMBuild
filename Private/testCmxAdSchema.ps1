function testCmxAdSchema {
	param ()
	writeLogFile -Category "info" -Message "------------------------------ testCmxAdSchema -------------------------------"
	Write-Host "Verifying for AD Schema extension" -ForegroundColor Green
	$strFilter = "(&(objectClass=mSSMSSite)(Name=*))"
	$objDomain = New-Object System.DirectoryServices.DirectoryEntry
	$objSearcher = New-Object System.DirectoryServices.DirectorySearcher
	$objSearcher.SearchRoot = $objDomain
	$objSearcher.PageSize = 1000
	$objSearcher.Filter = $strFilter
	$objSearcher.SearchScope = "Subtree"
	$colProplist = "name"
	foreach ($i in $colProplist){$objSearcher.PropertiesToLoad.Add($i) | Out-Null}
	$colResults = $objSearcher.FindAll()
	Write-Output ($colResults.Count -gt 0)
}
