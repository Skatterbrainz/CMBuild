function getCmxConfigData {
	<#
	.SYNOPSIS
	Import XML Control Data
	
	.DESCRIPTION
	Import XML Control Data
	
	.PARAMETER XmlFile
	Path and Name of XML control file
	
	.EXAMPLE
	getCmxConfigData -XmlFile 'https:\\myurl.contoso.nothing\path\filename.xml'
	#>
	param (
		[parameter(Mandatory=$True, HelpMessage="Path to XML control file")]
			[ValidateNotNullOrEmpty()]
			[string] $XmlFile
	)
	Write-Host "Loading configuration data" -ForegroundColor Green
	if ($XmlFile.StartsWith("http")) {
		try {
			[xml]$data = ((New-Object System.Net.WebClient).DownloadString($XmlFile))
			Write-Output $data
		} catch {
			writeLogFile -Category "error" -Message "failed to import data from Uri: $XmlFile"
		}
	} else {
		if (-not(Test-Path $XmlFile)) {
			Write-Warning "ERROR: configuration file not found: $XmlFile"
		} else {
			try {
				[xml]$data = Get-Content $XmlFile
				Write-Output $data
			} catch {
				writeLogFile -Category "error" -Message "failed to import data from file: $XmlFile"
			}
		}
	}
}
