#requires -version 3
function Copy-CMBuildTemplate {
	<#
	.SYNOPSIS
		Clone the default XML templates for custom needs
	.DESCRIPTION
		Clones the default XML templates for cmbuild and cmsiteconfig
		for use offline or publishing to a different online location.
	.PARAMETER Source1
		Path to source cmbuild xml template.
	.PARAMETER Source2
		Path to source cmsiteconfig xml template.
	.PARAMETER Type
		Template option: cmbuild, cmsiteconfig, both.
	.PARAMETER NoScrub
		Copy templates without clearing settings
	.EXAMPLE
		Copy-CMBuildTemplate -Type both -OutputPath '.\control'
	.EXAMPLE
		Copy-CMBuildTemplate -Type cmbuild -NoScrub
	.LINK
		https://github.com/Skatterbrainz/CMBuild/blob/master/Docs/Copy-CMBuildTemplate.md
	#>
	param (
		[parameter(Mandatory=$False, HelpMessage="CMBuild XML source template")]
			[string] $Source1 = "",
		[parameter(Mandatory=$False, HelpMessage="CMSiteConfig XML source template")]
			[string] $Source2 = "",
		[parameter(Mandatory=$True, HelpMessage="Template copy option")]
			[ValidateSet('cmbuild','cmsiteconfig','both')]
			[string] $Type,
		[parameter(Mandatory=$False, HelpMessage="Location to save new templates")]
			[ValidateNotNullOrEmpty()]
			[string] $OutputPath = $PWD.Path,
		[parameter(Mandatory=$False, HelpMessage="Copy templates without scrubbing information")]
			[switch] $NoScrub
	)
	Write-Verbose "source1.......... $Source1"
	Write-Verbose "source2.......... $Source2"
	Write-Verbose "outputpath....... $OutputPath"
	$ModuleData = Get-Module CMBuild
	$ModuleVer  = $ModuleData.Version -join '.'
	$ModulePath = $ModuleData.Path -replace 'CMBuild.psm1', ''
	Write-Verbose "module version... $ModuleVer"
	Write-Verbose "module path...... $ModuelPath"
	$AssetsPath = Join-Path -Path $ModulePath -ChildPath "Assets"
	if ($Source1 -eq "") {
		$Source1 = Join-Path -Path $AssetsPath -ChildPath "cmbuild.xml"
	}
	if ($Source2 -eq "") {
		$Source2 = Join-Path -Path $AssetsPath -ChildPath "cmsiteconfig.xml"
	}
	Write-Verbose "source1.......... $Source1"
	Write-Verbose "source2.......... $Source2"
	# CMBUILD
	if (($Type -eq 'cmbuild') -or ($Type -eq 'both')) {
		$NewFile = "$OutputPath\cmbuild.xml"
		[xml]$XmlData = getCmxTemplateData -Source $Source1
		if (!$NoScrub) {
			[xml]$newData = getCmxTemplateScrubData -XmlData $XmlData
		}
		else {
			[xml]$newData = $XmlData
		}
		try {
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
		} else {
			try {
				[xml]$xmldata = Get-Content -Path $Source2 -ErrorAction SilentlyContinue
			} catch {
				Write-Error $_.Exception.Message
				break
			}
			Write-Verbose "content imported from $Source2"
		}
		try {
			Write-Verbose "scrubbing template data"
			if (-not $NoScrub) {
				[xml]$newdata = getCmSiteConfigCleanXML -XmlData $xmldata
			} else {
				[xml]$newdata = $xmldata
			}
			Write-Verbose "saving new copy as $NewFile"
			$newdata.Save($NewFile)
			Write-Host "$NewFile created successfully" -ForegroundColor Cyan
			Write-Host "be sure to edit the new template before using" -ForegroundColor Magenta
		} catch {
			Write-Error $_.Exception.Message
		}
	}
}