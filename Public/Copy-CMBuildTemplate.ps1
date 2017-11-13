<#
.SYNOPSIS
	Clone the default XML templates for custom needs
.DESCRIPTION
	Clones the default XML templates for cmbuild and cmsiteconfig
	for use offline or publishing to a different online location.
.PARAMETER Source1
	[optional] [string] Path to source cmbuild xml template.
.PARAMETER Source2
	[optional] [string] Path to source cmsiteconfig xml template.
.PARAMETER Type
	[required] [string] Template option: cmbuild, cmsiteconfig, both.
.PARAMETER NoScrub
	[optional] [switch] Copy templates without clearing settings
.NOTES
	11/12/2017 - 1.0.0 - David Stein
.EXAMPLE
#>

function Copy-CMBuildTemplate {
	param (
		[parameter(Mandatory=$False, HelpMessage="CMBuild XML source template")]
			[ValidateNotNullOrEmpty()]
			[string] $Source1 = 'https://raw.githubusercontent.com/Skatterbrainz/CM_Build/master/cm_build.xml',
		[parameter(Mandatory=$False, HelpMessage="CMSiteConfig XML source template")]
			[ValidateNotNullOrEmpty()]
			[string] $Source2 = 'https://raw.githubusercontent.com/Skatterbrainz/CM_Build/master/cm_siteconfig.xml',
		[parameter(Mandatory=$True, HelpMessage="Template copy option")]
			[ValidateSet('cmbuild','cmsiteconfig','both')]
			[string] $Type,
		[parameter(Mandatory=$False, HelpMessage="Location to save new templates")]
			[ValidateNotNullOrEmpty()]
			[string] $OutputPath = $PWD.Path,
		[parameter(Mandatory=$False, HelpMessage="Copy templates without scrubbing information")]
			[switch] $NoScrub
	)
	Write-Verbose "source1....... $Source1"
	Write-Verbose "source2....... $Source2"
	Write-Verbose "outputpath.... $OutputPath"
	# CMBUILD
	if (($Type -eq 'cmbuild') -or ($Type -eq 'both')) {
		$NewFile = "$OutputPath\cmbuild.xml"
		if ($Source1.StartsWith('http')) {
			try {
				[xml]$xmldata = (New-Object System.Net.WebClient).DownloadString($Source1)
			}
			catch {
				Write-Error $_.Exception.Message
				break
			}
			Write-Verbose "content imported from $Source1"
		}
		else {
			try {
				[xml]$xmldata = Get-Content -Path $Source1 -ErrorAction SilentlyContinue
			}
			catch {
				Write-Error $_.Exception.Message
				break
			}
			Write-Verbose "content imported from $Source1"
		}
		try {
			Write-Verbose "scrubbing template data"
			if (-not $NoScrub) {
				[xml]$newdata = Get-CMBuildCleanXML -XmlData $xmldata
			}
			else {
				[xml]$newdata = $xmldata
			}
			Write-Verbose "saving new copy as $NewFile"
			$newdata.Save($NewFile)
			Write-Host "$NewFile created successfully" -ForegroundColor Cyan
			Write-Host "be sure to edit the new template before using" -ForegroundColor Magenta
		}
		catch {
			Write-Error $_.Exception.Message
		}
	}
	# SITECONFIG
	if (($Type -eq 'cmsiteconfig') -or ($Type -eq 'both')) {
		$NewFile = "$OutputPath\cmsiteconfig.xml"
		if ($Source2.StartsWith('http')) {
			try {
				[xml]$xmldata = (New-Object System.Net.WebClient).DownloadString($Source2)
			}
			catch {
				Write-Error $_.Exception.Message
				break
			}
			Write-Verbose "content imported from $Source2"
		}
		else {
			try {
				[xml]$xmldata = Get-Content -Path $Source2 -ErrorAction SilentlyContinue
			}
			catch {
				Write-Error $_.Exception.Message
				break
			}
			Write-Verbose "content imported from $Source2"
		}
		try {
			Write-Verbose "scrubbing template data"
			if (-not $NoScrub) {
				[xml]$newdata = Get-CMSiteConfigCleanXML -XmlData $xmldata
			}
			else {
				[xml]$newdata = $xmldata
			}
			Write-Verbose "saving new copy as $NewFile"
			$newdata.Save($NewFile)
			Write-Host "$NewFile created successfully" -ForegroundColor Cyan
			Write-Host "be sure to edit the new template before using" -ForegroundColor Magenta
		}
		catch {
			Write-Error $_.Exception.Message
		}
	}
}

Export-ModuleMember -Function Copy-CMBuildTemplate