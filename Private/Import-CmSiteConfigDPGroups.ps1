function Import-CmSiteConfigDPGroups {
    <#
    .SYNOPSIS
    Create DP Server Groups
    
    .DESCRIPTION
    Create DP Server Groups
    
    .PARAMETER DataSet
    XML data set
    
    .EXAMPLE
    Import-CmxDPGroups -DataSet $xmldata
    
    .NOTES
    General notes
    #>

    [CmdletBinding(SupportsShouldProcess=$True)]
    param (
        [parameter(Mandatory=$True)]
        [ValidateNotNullOrEmpty()]
        [xml] $DataSet
    )
	Write-Log -Category "info" -Message "------------------------------ Import-CmSiteConfigDPGroups -------------------------------"
    Write-Host "Configuring distribution point groups" -ForegroundColor Green
    $result = $true
    $Time1  = Get-Date
    foreach ($item in $DataSet.configuration.cmsite.dpgroups.dpgroup | Where-Object {$_.use -eq '1'}) {
        $dpgName = $item.name
        $dpgComm = $item.comment
		Write-Log -Category info -Message "distribution point group: $dpgName"
		if (Get-CMDistributionPointGroup -Name $dpgName) {
			Write-Log -Category info -Message "dp group already exists"
		}
		else {
			try {
				New-CMDistributionPointGroup -Name $dpgName -Description $dpgComm | Out-Null
				Write-Log -Category info -Message "dp group created successfully"
			}
			catch {
				Write-Log -Category error -Message $_.Exception.Message
				$Result = $False
				break
			}
		}
        Write-Verbose "- - - - - - - - - - - - - - - - - - - - - - - - - - - - - -"
    } # foreach
    Write-Log -Category info -Message "function runtime: $(Get-TimeOffset $time1)"
    Write-Output $result
}
