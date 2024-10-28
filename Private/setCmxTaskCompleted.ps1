function setCmxTaskCompleted {
	<#
	.SYNOPSIS
	Add Registry Key to indicate Completed Task

	.DESCRIPTION
	Adds a Registry Key to indicate a Completed Task

	.PARAMETER KeyName
	Path and Name of Registry Key

	.PARAMETER Value
	Value to assign to Registry Key (Data)

	.EXAMPLE
	setCmxTaskCompleted -KeyName 'HKLM:\SOFTWARE\CMBUILD\FOO' -Value 123
	#>
	[CmdletBinding(SupportsShouldProcess = $True)]
	param (
		[parameter(Mandatory = $True)]
		[ValidateNotNullOrEmpty()]
		[string] $KeyName, 
		[parameter(Mandatory = $True)]
		[ValidateNotNullOrEmpty()]
		[string] $Value
	)
	writeLogFile -Category "info" -Message "function: setCmxTaskCompleted"
	try {
		$null = New-Item -Path $CmBuildSettings['RegistryPath1'] -ErrorAction SilentlyContinue
		$null = New-Item -Path $CmBuildSettings['RegistryPath1']\PROCESSED -ErrorAction SilentlyContinue
	} catch {
		Write-Error "FAIL: Unable to set registry path"
	}
	try {
		$null = New-Item -Path $CmBuildSettings['RegistryPath1']\PROCESSED\$KeyName -Value $Value -ErrorAction SilentlyContinue
		writeLogFile -Category "info" -Message "writing registry key $KeyName"
	} catch {
		writeLogFile -Category "error" -Message "failed to write to registry!"
	}
}
