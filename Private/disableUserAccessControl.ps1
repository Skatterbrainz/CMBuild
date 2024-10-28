function disableUserAccessControl {
	Write-Verbose "----------------------------------------------------"
	writeLogFile -Category "info" -Message "Disabling User Access Control (UAC)."
	$null = Set-ItemProperty "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System" -Name "ConsentPromptBehaviorAdmin" -Value 00000000 -Force
	writeLogFile -Category "info" -Message "User Access Control (UAC) has been disabled."
}
