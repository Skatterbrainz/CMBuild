function Invoke-CMxRestart {
	<#
	.SYNOPSIS
	Configure a Restart with Post-Start Resume
	.DESCRIPTION
	Configures scripts and a scheduled task to resume CMBuild after 
	a restart.  Then invokes a restart.
	.PARAMETER XmlFile
	Name of XML template file
	.EXAMPLE
	Invoke-CMxRestart -XmlFile .\cmbuild.xml
	.NOTES
	#>
	param (
		[parameter(Mandatory=$True)]
		[string] $XmlFile
	)
	$psfile  = "$($env:SYSTEMROOT)\temp\resume_cmbuild.ps1"
	$batfile = "$($env:SYSTEMROOT)\temp\resume_cmbuild.bat"
	$stask = 'SCHTASKS /Create /TN $($Script:RSJobName) /TR '+$batfile+' /RU SYSTEM /SC OnStart /RL HIGHEST /F'
	$psx = @"
Import-Module CMBuild -Force
Get-ScheduledTask -TaskName `"$($Script:RSJobName)`" | Unregister-ScheduledTask -Confirm`:`$False
Invoke-CMBuild -XmlFile $((Get-Item $XmlFile).FullName) -NoCheck -NoReboot -Detailed -Verbose
"@
	$psx | Out-File $psfile -Encoding utf8
	Write-Log -Category 'Info' -Message "PowerShell file... $psfile"
	$cmd = @"
`@echo off
set LOG=$($env:TEMP)\resume_cmbuild.log
echo %DATE% %TIME% user context... %USERNAME% >%LOG% 
echo %DATE% %TIME% host name...... %COMPUTERNAME% >%LOG% 
powershell.exe -ExecutionPolicy ByPass -NoProfile -File $psfile >>%LOG%
"@
	$cmd | Out-File $batfile -Encoding utf8
	Write-Log -Category 'Info' -Message "Batch file........ $batfile"

	try {
		Invoke-Expression -Command $stask -ErrorAction Stop
		Write-Log -Category 'Info' -Message "Scheduled Task.... $stask"
	} catch {
		Write-Log -Category 'Error' -Message $_.Exception.Message
		Write-Error $_.Exception.Message
	}
}