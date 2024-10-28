function Set-CmxADForest {
	<#
	.SYNOPSIS
	Short description
	
	.DESCRIPTION
	Long description
	
	.PARAMETER DataSet
	Parameter description
	
	.EXAMPLE
	An example
	
	.NOTES
	General notes
	#>
	[CmdletBinding(SupportsShouldProcess=$True)]
	param (
		[parameter(Mandatory=$True, HelpMessage="XML Data Set")]
		[ValidateNotNullOrEmpty()]
		$DataSet
	)
	Write-Log -Category "info" -Message "------------------------------ Set-CmxADForest -------------------------------"
	$adforest = $DataSet.configuration.cmsite.forest
	Write-Host "Configuring AD Forest" -ForegroundColor Green
	$result = $True
	$Time1  = Get-Date
	Write-Log -Category "info" -Message "forest FQDN is $adforest"
	if (Get-CMActiveDirectoryForest -ForestFqdn "$adforest") {
		Write-Log -Category "info" -Message "AD forest was already configured"
	} else {
		try {
			New-CMActiveDirectoryForest -ForestFqdn "$adforest" -EnableDiscovery $True -ErrorAction SilentlyContinue
			Write-Log -Category "info" -Message "item created successfully: $adforest"
			Write-Output $True
		} catch {
			Write-Log -Category "error" -Message $_.Exception.Message
			$result = $false
			break
		}
	}
	Write-Log -Category "info" -Message "function runtime: $(Get-TimeOffset $time1)"
	Write-Output $result
}
