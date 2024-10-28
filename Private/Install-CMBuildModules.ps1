function Install-CMBuildModules {
	<#
	.SYNOPSIS
		Load required modules
	.DESCRIPTION
		Load required powershell modules
	.EXAMPLE
		Install-CMBuildModules -Verbose
	#>
	[CmdletBinding(SupportsShouldProcess=$True)]
	param ()
	Write-Log -Category 'Info' -Message 'Installing nuget provider'
	try {
		Install-PackageProvider -Name NuGet -MinimumVersion 2.8.5.201 -Force -ErrorAction Stop
	} catch {
		Write-Log -Category 'Error' -Message $_.Exception.Message
		Write-Error $_.Exception.Message
		break
	}

	if (Get-Module -ListAvailable -Name PowerShellGet) {
		Write-Log -Category 'Info' -Message "PowerShellGet module is already installed"
	} else {
		Write-Log -Category 'Info' -Message "installing PowerShellGet module"
		Install-Module -Name PowerShellGet -Force
	}

	if (Get-Module -ListAvailable -Name SqlServer) {
		Write-Log -Category 'Info' -Message "SqlServer module is already installed"
	} else {
		Write-Log -Category 'Info' -Message "installing SqlServer module"
		Install-Module SqlServer -Force -AllowClobber
	}

	if (Get-Module -ListAvailable -Name dbatools) {
		Write-Log -Category 'Info' -Message "DbaTools module is already installed"
	} else {
		Write-Log -Category 'Info' -Message "installing DbaTools module"
		Install-Module dbatools -Force -AllowClobber
	}

	if (-not(Test-Path "c:\ProgramData\chocolatey\choco.exe")) {
		Write-Log -Category 'Info' -Message "installing chocolatey..."
		if ($WhatIfPreference) {
			Write-Log -Category 'Info' -Message "Chocolatey is not installed. Bummer dude. This script would attempt to install it first."
		} else {
			#Invoke-Expression ((New-Object Net.WebClient).DownloadString('https://chocolatey.org/install.ps1'))
			Invoke-Expression ((Invoke-WebRequest -Uri 'https://chocolatey.org/install.ps1').Content)
		}
		Write-Log -Category 'Info' -Message "installation completed"
	} else {
		Write-Log -Category 'Info' -Message "chocolatey is already installed"
	}

	if (-not(Test-Path "c:\ProgramData\chocolatey\choco.exe")) {
		Write-Log -Category 'Error' -Message "chocolatey install failed!"
		break
	}
	if (-not(Get-Module -Name "Carbon")) {
		Write-Log -Category 'Info' -Message "installing Carbon package"
		choco install carbon -y
	}
	Write-Log -Category 'Info' -Message 'Loading ServerManager module'
	Import-Module ServerManager
	Write-Log -Category 'Info' -Message 'all powershell modules are installed and loaded.'
}