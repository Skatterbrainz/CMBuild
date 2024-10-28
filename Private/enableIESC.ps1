function enableIESC {
	Write-Verbose "----------------------------------------------------"
	writeLogFile -Category "info" -Message "Enabling IE Enhanced Security Configuration."
	$AdminKey = "HKLM:\SOFTWARE\Microsoft\Active Setup\Installed Components\{A509B1A7-37EF-4b3f-8CFC-4F3A74704073}"
	$UserKey  = "HKLM:\SOFTWARE\Microsoft\Active Setup\Installed Components\{A509B1A8-37EF-4b3f-8CFC-4F3A74704073}"
	if ((Get-ItemProperty -Path $AdminKey -Name "IsInstalled" | Select-Object -ExpandProperty IsInstalled) -ne 1) {
		try {
			$null = Set-ItemProperty -Path $AdminKey -Name "IsInstalled" -Value 1 -Force
			$null = Set-ItemProperty -Path $UserKey -Name "IsInstalled" -Value 1 -Force
			Stop-Process -Name Explorer -Force
			writeLogFile -Category "info" -Message "IE Enhanced Security Configuration (ESC) has been enabled."
		} catch {
			Write-Output -1
		}
	} else {
		writeLogFile -Category "info" -Message "IE Enhanced Security Configuration (ESC) is already enabled."
	}
}
