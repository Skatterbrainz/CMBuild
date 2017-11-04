#requires -RunAsAdministrator
#requires -version 3
<#
.SYNOPSIS
    SCCM site configuration script
.DESCRIPTION
    Yeah, what he said.
.PARAMETER XmlFile
    [string](optional) Path and Name of XML input file
.PARAMETER Detailed
    [switch](optional) Verbose output without using -Verbose
.PARAMETER Override
    [switch](optional) Allow override of Controls in XML file using GUI (gridview) selection at runtime
.NOTES
    Read the associated XML to make sure the path and filename values
    all match up like you need them to.

.EXAMPLE
    Invoke-CMSiteConfig -XmlFile .\cm_siteconfig.xml -Detailed
.EXAMPLE
    Invoke-CMSiteConfig -XmlFile .\cm_siteconfig.xml -Override
.EXAMPLE
    Invoke-CMSiteConfig -XmlFile .\cm_siteconfig.xml -Detailed -Override
.EXAMPLE
	Invoke-CMSiteConfig -XmlFile .\cm_siteconfig.xml -Detailed -WhatIf
#>

function Invoke-CMSiteConfig {
	[CmdletBinding(SupportsShouldProcess=$True)]
	param (
		[parameter(Mandatory=$True, HelpMessage="Path and name of XML input file")]
			[ValidateNotNullOrEmpty()]
			[string] $XmlFile,
		[parameter(Mandatory=$False, HelpMessage="Display verbose output")]
			[switch] $Detailed,
		[parameter(Mandatory=$False, HelpMessage="Override control set from XML file")]
			[switch] $Override
	)
	Write-Host "CMSiteConfig $CMBuildVersion" -ForegroundColor Cyan
	
	try {stop-transcript -ErrorAction SilentlyContinue} catch {}
	try {Start-Transcript -Path $tsFile -Force} catch {}

	Write-Host "------------------- BEGIN $(Get-Date) -------------------" -ForegroundColor Green

	$RunTime1 = Get-Date
	Write-Log -Category "info" -Message "Script version.... $ScriptVersion"

	Set-Location "$($env:USERPROFILE)\Documents"
	if (-not(Test-Path $XmlFile)) {
		Write-Warning "unable to locate input file: $XmlFile"
		break
	}

	Set-Location $env:USERPROFILE

	[xml]$xmldata = Get-CMxConfigData -XmlFile $XmlFile
	Write-Log -Category "info" -Message "----------------------------------------------------"
	if ($xmldata.configuration.schemaversion -ge $SchemaVersion) {
		Write-Log -Category "info" -Message "xml template schema version is valid"
	}
	else {
		Write-Log -Category "info" -Message "xml template schema version is invalid: $($xmldata.configuration.schemaversion)"
		Write-Warning "The specified XML file is not using a current schema version"
		break
	}
	$sitecode = $xmldata.configuration.cmsite.sitecode
	if (($sitecode -eq "") -or (-not($sitecode))) {
		Write-Warning "unable to load XML data from $xmlFile"
		break
	}
	Write-Log -Category "info" -Message "site code = $sitecode"

	if ($sitecode -eq "") {
		Write-Warning "site code could not be obtained"
		break
	}
	if (-not (Import-ConfigMgrModule)) {
		Write-Warning "failed to load ConfigurationManager powershell module"
		break
	}

	# Set the current location to be the site code.
	Write-Log -Category "info" -Message "mounting CM Site provider_ $sitecode`:"
	Set-Location "$sitecode`:" 

	$Site = Get-CMSite -SiteCode $sitecode
	Write-Log -Category "info" -Message "site version = $($site.Version)"

	if ($Override) {
		$controlset = $xmldata.configuration.cmsite.control.ci | Out-GridView -Title "Select Features to Run" -PassThru
	}
	else {
		$controlset = $xmldata.configuration.cmsite.control.ci | Where-Object {$_.use -eq '1'}
	}

	Invoke-CMSiteConfigProcess -ControlSet $controlSet -DataSet $xmldata

	Write-Log -Category "info" -Message "---------------------------------------------------"
	Write-Log -Category "info" -Message "restore working path to user profile"
	Set-Location -Path $env:USERPROFILE
	Write-Host "---------------- COMPLETED $(Get-Date) ------------------" -ForegroundColor Green
	Write-Log -Category info -Message "total runtime: $(Get-TimeOffset $Runtime1)"
	Stop-Transcript
}

Export-ModuleMember -Function Invoke-CMSiteConfig
