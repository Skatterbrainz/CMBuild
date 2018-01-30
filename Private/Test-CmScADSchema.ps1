function Test-CmScADSchema {
	<#
	.SYNOPSIS
	Test if AD Schema has been extended for ConfigMgr

	.DESCRIPTION
	Returns $True if AD Schema has been extended for ConfigMgr
	
	.EXAMPLE
	if (Test-CMxAdSchema) { Write-Host "Schema has been extended!" }
	
	.NOTES
	...
	#>
	param ()
	Write-Log -Category "info" -Message "------------------------------ Test-CmScADSchema -------------------------------" -LogFile $logfile
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
