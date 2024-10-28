function setCmxSiteConfigFolders {
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
	setCmxSiteConfigFolders -SiteCode 'P01' -DataSet $xmldata
	#>

	[CmdletBinding(SupportsShouldProcess=$True)]
	param (
		[parameter(Mandatory=$True)]
			[ValidateNotNullOrEmpty()]
			[string] $SiteCode,
		[parameter(Mandatory=$True)]
			$DataSet
	)
	writeLogFile -Category "info" -Message "------------------------------ setCmxSiteConfigFolders -------------------------------"
	Write-Host "Configuring console folders" -ForegroundColor Green
	$result = $true
	$Time1  = Get-Date
	foreach ($item in $DataSet.configuration.cmsite.folders.folder | Where-Object {$_.use -eq '1'}) {
		$folderName = $item.name
		$folderPath = $item.path
		writeLogFile -Category "info" -Message "folder path: $folderPath\folderName"
		if (Test-Path "$folderPath\$folderName") {
			writeLogFile -Category "info" -Message "folder already exists"
		} else {
			try {
				$null = New-Item -Path "$SiteCode`:\$folderPath" -Name $folderName -ErrorAction SilentlyContinue
				writeLogFile -Category "info" -Message "folder created successfully"
			} catch {
				writeLogFile -Category "error" -Message $_.Exception.Message
			}
		}
		Write-Verbose "- - - - - - - - - - - - - - - - - - - - - - - - - - - - - -"
	} # foreach
	writeLogFile -Category info -Message "function runtime: $(getTimeOffset $time1)"
	Write-Output $result
}
