#requires -RunAsAdministrator
#requires -version 5

function Invoke-CMSiteConfig {
	<#
	.SYNOPSIS
		SCCM site configuration script
	.DESCRIPTION
		Yeah, what he said.
	.PARAMETER XmlFile
		Path and Name of XML input file
	.PARAMETER Detailed
		Verbose output without using -Verbose
	.PARAMETER ShowMenu
		Override XML controls using GUI (gridview) selection at runtime
	.EXAMPLE
		Invoke-CMSiteConfig -XmlFile .\cmsiteconfig.xml -Detailed
	.EXAMPLE
		Invoke-CMSiteConfig -XmlFile .\cmsiteconfig.xml -ShowMenu
	.EXAMPLE
		Invoke-CMSiteConfig -XmlFile .\cmsiteconfig.xml -Detailed -ShowMenu
	.EXAMPLE
		Invoke-CMSiteConfig -XmlFile .\cmsiteconfig.xml -Detailed -WhatIf
	.LINK
		https://github.com/Skatterbrainz/CMBuild/blob/master/Docs/Invoke-CMSiteConfig.md
	.NOTES
		Read the associated XML to make sure the path and filename values
		all match up like you need them to.
	#>
	[CmdletBinding(SupportsShouldProcess=$True)]
	param (
		[parameter(Mandatory=$True, HelpMessage="Path and name of XML input file")]
			[ValidateNotNullOrEmpty()]
			[string] $XmlFile,
		[parameter(Mandatory=$False, HelpMessage="Display verbose output")]
			[switch] $Detailed,
		[parameter(Mandatory=$False, HelpMessage="Override control set from XML file")]
			[switch] $ShowMenu
	)
	$RunTime1 = Get-Date
	Write-Host "CMSiteConfig $CmBuildSettings['CMBuildVersion']" -ForegroundColor Cyan
	$Script:CMxLogFile = $Script:CMConfigLogFile
	try {Stop-Transcript -ErrorAction SilentlyContinue} catch {}
	try {Start-Transcript -Path $Script:tsFile -Force} catch {}

	Write-Host "------------------- BEGIN $(Get-Date) -------------------" -ForegroundColor Green
	writeLogFile -Category "info" -Message "Script version.... $ScriptVersion"

	Set-Location "$($env:USERPROFILE)\Documents"
	if (-not(Test-Path $XmlFile)) {
		Write-Warning "unable to locate input file: $XmlFile"
		break
	}

	Set-Location $env:USERPROFILE

	[xml]$xmldata = getCmxConfigData -XmlFile $XmlFile
	writeLogFile -Category "info" -Message "----------------------------------------------------"
	if ($xmldata.configuration.schemaversion -ge $CmBuildSettings['SchemaVersion']) {
		writeLogFile -Category "info" -Message "xml template schema version is valid"
	} else {
		writeLogFile -Category "info" -Message "xml template schema version is invalid: $($xmldata.configuration.schemaversion)"
		Write-Warning "The specified XML file is not using a current schema version"
		break
	}
	$sitecode = $xmldata.configuration.cmsite.sitecode
	if (($sitecode -eq "") -or (-not($sitecode))) {
		Write-Warning "unable to load XML data from $xmlFile"
		break
	}
	writeLogFile -Category "info" -Message "site code = $sitecode"

	if ($sitecode -eq "") {
		Write-Warning "site code could not be obtained"
		break
	}
	if (-not (Import-ConfigMgrModule)) {
		Write-Warning "failed to load ConfigurationManager powershell module"
		break
	}

	# Set the current location to be the site code.
	writeLogFile -Category "info" -Message "mounting CM Site provider_ $sitecode`:"
	Set-Location "$sitecode`:" 

	$Site = Get-CMSite -SiteCode $sitecode
	writeLogFile -Category "info" -Message "site version = $($site.Version)"

	if ($ShowMenu) {
		$controlset = $xmldata.configuration.cmsite.control.ci | Out-GridView -Title "Select Features to Run" -PassThru
	} else {
		$controlset = $xmldata.configuration.cmsite.control.ci | Where-Object {$_.use -eq '1'}
	}
	invokeCMSiteConfigProcess -ControlSet $controlSet -DataSet $xmldata
	writeLogFile -Category "info" -Message "---------------------------------------------------"
	writeLogFile -Category "info" -Message "restore working path to user profile"
	Set-Location -Path $env:USERPROFILE
	Write-Host "---------------- COMPLETED $(Get-Date) ------------------" -ForegroundColor Green
	writeLogFile -Category info -Message "total runtime: $(getTimeOffset $Runtime1)"
	Stop-Transcript
}
