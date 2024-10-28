function Set-CMSiteConfigFolders {
	<#
	.SYNOPSIS
	Create folders in ConfigMgr Console
	
	.DESCRIPTION
	Create folders in ConfigMgr Console
	
	.PARAMETER SiteCode
	Site code
	
	.PARAMETER DataSet
	XML data set
	
	.EXAMPLE
	Set-CMSiteConfigFolders -SiteCode 'P01' -DataSet $xmldata
	
	.NOTES
	1.0.7 - 11/21/2017 - David Stein
	#>

	[CmdletBinding(SupportsShouldProcess=$True)]
	param (
		[parameter(Mandatory=$True)]
			[ValidateNotNullOrEmpty()]
			[string] $SiteCode,
		[parameter(Mandatory=$True)]
			$DataSet
	)
	Write-Log -Category "info" -Message "------------------------------ Set-CMSiteConfigFolders -------------------------------"
	Write-Host "Configuring console folders" -ForegroundColor Green
	$result = $true
	$Time1  = Get-Date
	foreach ($item in $DataSet.configuration.cmsite.folders.folder | Where-Object {$_.use -eq '1'}) {
		$folderName = $item.name
		$folderPath = $item.path
		Write-Log -Category "info" -Message "folder path: $folderPath\folderName"
		if (Test-Path "$folderPath\$folderName") {
			Write-Log -Category "info" -Message "folder already exists"
		} else {
			try {
				$null = New-Item -Path "$SiteCode`:\$folderPath" -Name $folderName -ErrorAction SilentlyContinue
				Write-Log -Category "info" -Message "folder created successfully"
			} catch {
				Write-Log -Category "error" -Message $_.Exception.Message
			}
		}
		Write-Verbose "- - - - - - - - - - - - - - - - - - - - - - - - - - - - - -"
	} # foreach
	Write-Log -Category info -Message "function runtime: $(Get-TimeOffset $time1)"
	Write-Output $result
}
