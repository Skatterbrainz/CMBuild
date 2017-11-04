function Install-CMBuildModules {
	param ()
	try {
		Install-PackageProvider -Name NuGet -MinimumVersion 2.8.5.201 -ErrorAction Stop
	}
	catch {}

	if (Get-Module -ListAvailable -Name PowerShellGet) {
		Write-Log -Category "info" -Message "PowerShellGet module is already installed"
	}
	else {
		Write-Log -Category "info" -Message "installing PowerShellGet module"
		Install-Module -Name PowerShellGet
	}

	if (Get-Module -ListAvailable -Name SqlServer) {
		Write-Log -Category "info" -Message "SqlServer module is already installed"
	}
	else {
		Write-Log -Category "info" -Message "installing SqlServer module"
		Install-Module SqlServer -Force -AllowClobber
	}

	if (Get-Module -ListAvailable -Name dbatools) {
		Write-Log -Category "info" -Message "DbaTools module is already installed"
	}
	else {
		Write-Log -Category "info" -Message "installing DbaTools module"
		Install-Module DbaTools -Force -AllowClobber
	}

	if (-not(Test-Path "c:\ProgramData\chocolatey\choco.exe")) {
		Write-Log -Category "info" -Message "installing chocolatey..."
		if ($WhatIfPreference) {
			Write-Log -Category "info" -Message "Chocolatey is not installed. Bummer dude. This script would attempt to install it first."
		}
		else {
			Invoke-Expression ((New-Object Net.WebClient).DownloadString('https://chocolatey.org/install.ps1'))
		}
		Write-Log -Category "info" -Message "installation completed"
	}
	else {
		Write-Log -Category "info" -Message "chocolatey is already installed"
	}

	if (-not(Test-Path "c:\ProgramData\chocolatey\choco.exe")) {
		Write-Log -Category "error" -Message "chocolatey install failed!"
		break
	}
	if (-not(Get-Module -Name "Carbon")) {
		Write-Log -Category "info" -Message "installing Carbon package"
		cinst carbon -y
	}

	Import-Module ServerManager
}