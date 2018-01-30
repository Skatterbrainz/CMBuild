function Test-ADContainer {
	param()
	Write-Log -Category "info" -Message "------------------------------ Test-ADContainer -------------------------------"
	Write-Host "Searching for AD container: System Management" -ForegroundColor Green
	$strFilter = "(&(objectCategory=Container)(Name=System Management))"
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
