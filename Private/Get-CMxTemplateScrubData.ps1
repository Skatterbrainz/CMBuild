function Get-CMxTemplateScrubData {
	param (
		[parameter(Mandatory=$True)]
		$XmlData
	)
	try {
		Write-Verbose "scrubbing template data"
		if (-not $NoScrub) {
			[xml]$result = Get-CMBuildCleanXML -XmlData $XmlData
		} else {
			[xml]$result = $xmldata
		}
	} catch {
		Write-Error $_.Exception.Message
	}
	Write-Output $result
}
