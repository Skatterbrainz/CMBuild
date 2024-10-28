function getCmxTemplateScrubData {
	param (
		[parameter(Mandatory=$True)]
		$XmlData
	)
	try {
		Write-Verbose "scrubbing template data"
		if (-not $NoScrub) {
			[xml]$result = getCmBuildCleanXML -XmlData $XmlData
		} else {
			[xml]$result = $xmldata
		}
	} catch {
		Write-Error $_.Exception.Message
	}
	Write-Output $result
}
