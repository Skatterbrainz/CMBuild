function setCmxADForest {
	<#
	.SYNOPSIS
	Short description
	
	.DESCRIPTION
	Long description
	
	.PARAMETER DataSet
	Parameter description
	
	.EXAMPLE
	setCmxADforest -DataSet $xmldata
	#>
	[CmdletBinding(SupportsShouldProcess=$True)]
	param (
		[parameter(Mandatory=$True, HelpMessage="XML Data Set")]
		[ValidateNotNullOrEmpty()]
		$DataSet
	)
	writeLogFile -Category "info" -Message "------------------------------ setCmxADForest -------------------------------"
	$adforest = $DataSet.configuration.cmsite.forest
	Write-Host "Configuring AD Forest" -ForegroundColor Green
	$result = $True
	$Time1  = Get-Date
	writeLogFile -Category "info" -Message "forest FQDN is $adforest"
	if (Get-CMActiveDirectoryForest -ForestFqdn "$adforest") {
		writeLogFile -Category "info" -Message "AD forest was already configured"
	} else {
		try {
			New-CMActiveDirectoryForest -ForestFqdn "$adforest" -EnableDiscovery $True -ErrorAction SilentlyContinue
			writeLogFile -Category "info" -Message "item created successfully: $adforest"
			Write-Output $True
		} catch {
			writeLogFile -Category "error" -Message $_.Exception.Message
			$result = $false
			break
		}
	}
	writeLogFile -Category "info" -Message "function runtime: $(getTimeOffset $time1)"
	Write-Output $result
}
