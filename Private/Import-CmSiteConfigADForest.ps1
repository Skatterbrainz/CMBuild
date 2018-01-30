function Import-CmSiteConfigADForest {
    <#
    .SYNOPSIS
    Set CM AD Forest Settings
    
    .DESCRIPTION
    Set Configuration Manager AD forest settings
    
    .PARAMETER DataSet
    XML data set
    
    .EXAMPLE
    Import-CmSiteConfigADForest -DataSet $xmldata
    
    .NOTES
    General notes
    #>
    [CmdletBinding()]
    param (
        [parameter(Mandatory=$True, HelpMessage="XML Data Set")]
        [ValidateNotNullOrEmpty()]
        [xml] $DataSet
    )
	Write-Log -Category "info" -Message "------------------------------ Import-CmSiteConfigADForest -------------------------------"
    $adforest = $DataSet.configuration.cmsite.forest
    Write-Host "Configuring AD Forest" -ForegroundColor Green
    $result = $True
    $Time1  = Get-Date
	Write-Log -Category "info" -Message "forest FQDN is $adforest"
	if (Get-CMActiveDirectoryForest -ForestFqdn "$adforest") {
		Write-Log -Category "info" -Message "AD forest was already configured"
	}
	else {
		try {
			New-CMActiveDirectoryForest -ForestFqdn "$adforest" -EnableDiscovery $True -ErrorAction SilentlyContinue
			Write-Log -Category "info" -Message "item created successfully: $adforest"
			Write-Output $True
		}
		catch {
            Write-Log -Category "error" -Message $_.Exception.Message
            $result = $false
            break
        }
    }
    Write-Log -Category "info" -Message "function runtime: $(Get-TimeOffset $time1)"
    Write-Output $result
}
