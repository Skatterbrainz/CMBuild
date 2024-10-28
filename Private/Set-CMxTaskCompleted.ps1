function Set-CMxTaskCompleted {
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
	Set-CMxTaskCompleted -KeyName 'HKLM:\SOFTWARE\CMBUILD\FOO' -Value 123

	.NOTES

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
	Write-Log -Category "info" -Message "function: Set-CMxTaskCompleted"
	try {
		$null = New-Item -Path $CMBuildRegRoot1 -ErrorAction SilentlyContinue
		$null = New-Item -Path $CMBuildRegRoot1\PROCESSED -ErrorAction SilentlyContinue
	} catch {
		Write-Error "FAIL: Unable to set registry path"
	}
	try {
		$null = New-Item -Path $CMBuildRegRoot1\PROCESSED\$KeyName -Value $Value -ErrorAction SilentlyContinue
		Write-Log -Category "info" -Message "writing registry key $KeyName"
	} catch {
		Write-Log -Category "error" -Message "failed to write to registry!"
	}
}
