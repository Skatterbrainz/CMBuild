function Import-CmxBoundaryGroups {
	[CmdletBinding(SupportsShouldProcess=$True)]
	param (
		[parameter(Mandatory=$True)]
		[ValidateNotNullOrEmpty()]
		$DataSet
	)
	Write-Log -Category "info" -Message "------------------------------ Import-CmxBoundaryGroups -------------------------------"
	Write-Host "Configuring Site Boundary Groups" -ForegroundColor Green
	$result = $True
	$Time1  = Get-Date
	foreach ($item in $DataSet.configuration.cmsite.boundarygroups.boundarygroup | Where-Object {$_.use -eq '1'}) {
		$bgName   = $item.name
		$bgComm   = $item.comment
		$bgServer = $item.SiteSystemServer
		$bgLink   = $item.LinkType
		Write-Log -Category "info" -Message "boundary group name = $bgName"
		if (Get-CMBoundaryGroup -Name $bgName) {
			Write-Log -Category "info" -Message "boundary group already exists"
		} else {
			try {
				$null = New-CMBoundaryGroup -Name $bgName -Description "$bgComm" -DefaultSiteCode $sitecode
				Write-Log -Category "info" -Message "boundary group $bgName created"
			} catch {
				Write-Log -Category "error" -Message $_.Exception.Message
				$result = $false
				break
			}
		}
		if ($bgServer.Length -gt 0) {
			$bgSiteServer = @{$bgServer = $bgLink}
			Write-Log -Category "info" -Message "site server assigned: $bgServer ($bgLink)"
			try {
				$null = Set-CMBoundaryGroup -Name $bgName -DefaultSiteCode $sitecode -AddSiteSystemServer $bgSiteServer -ErrorAction SilentlyContinue
				Write-Log -Category "info" -Message "boundary group $bgName has been updated"
			} catch {
				Write-Log -Category "error" -Message $_.Exception.Message
				$result = $False
				break
			}
		}
		Write-Log -Category "info" -Message "- - - - - - - - - - - - - - - - - - - - - - - - - -"
	} # foreach
	Write-Log -Category info -Message "function runtime: $(Get-TimeOffset $time1)"
	Write-Output $result
}
