function Disable-UserAccessControl {
	Write-Verbose "----------------------------------------------------"
	Write-Log -Category "info" -Message "Disabling User Access Control (UAC)."
	$null = Set-ItemProperty "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System" -Name "ConsentPromptBehaviorAdmin" -Value 00000000 -Force
	Write-Log -Category "info" -Message "User Access Control (UAC) has been disabled."
}
