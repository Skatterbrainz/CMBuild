function Get-CMxTemplateData {
	<#
	.SYNOPSIS
		Get XML template data
	.DESCRIPTION
		Long description
	.EXAMPLE
		Get-CMxTemplateData -Source $filepath
	.NOTES
		General notes
	#> 
	param (
		[parameter(Mandatory=$True, HelpMessage="Path to Source XML file")]    
		[ValidateNotNullOrEmpty()]
		[string] $Source
	)
	if ($Source1.StartsWith('http')) {
		try {
			[xml]$result = (New-Object System.Net.WebClient).DownloadString($Source)
		} catch {
			Write-Error $_.Exception.Message
			break
		}
		Write-Verbose "content imported from $Source"
	} else {
		try {
			[xml]$result = Get-Content -Path $Source -ErrorAction SilentlyContinue
		} catch {
			Write-Error $_.Exception.Message
			break
		}
		Write-Verbose "content imported from $Source"
	}
	Write-Output $result
}
  