function applyCmxWsusConfiguration {
	[CmdletBinding(SupportsShouldProcess=$True)]
	param (
		[parameter(Mandatory=$True)]
		[ValidateNotNullOrEmpty()]
		[string] $UpdatesFolder
	)
	Write-Host "Configuring WSUS features" -ForegroundColor Green
	$timex = Get-Date
	writeLogFile -Category "info" -Message "verifying WSUS role installation for SQL database connectivity"
	if (-not ((Get-WindowsFeature UpdateServices-DB | Select-Object -ExpandProperty Installed) -eq $True)) {
		writeLogFile -Category "error" -Message "WSUS is not installed properly (aborting)"
		break
	}
	$sqlhost = "$($env:COMPUTERNAME).$($env:USERDNSDOMAIN)"
	writeLogFile -Category "info" -Message "wsus SQL_INSTANCE_NAME=$sqlhost"
	writeLogFile -Category "info" -Message "wsus CONTENT_DIR=$UpdatesFolder"
	try {
		& 'C:\Program Files\Update Services\Tools\WsusUtil.exe' postinstall SQL_INSTANCE_NAME=$sqlhost CONTENT_DIR=$UpdatesFolder | Out-Null
		$result = 0
	} catch {
		Write-Warning "ERROR: Unable to invoke WSUS post-install configuration"
		writeLogFile -Category "error" -Message $_.Exception.Message
		$result = $false
	}
	writeLogFile -Category "info" -Message "function runtime = $(getTimeOffset -StartTime $timex)"
	Write-Output $result
}
