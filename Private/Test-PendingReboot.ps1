function Test-PendingReboot {
	if (Get-ChildItem "HKLM:\Software\Microsoft\Windows\CurrentVersion\Component Based Servicing\RebootPending" -EA Ignore) { Write-Output $true }
	if (Get-Item "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\WindowsUpdate\Auto Update\RebootRequired" -EA Ignore) { Write-Output $true }
	if (Get-ItemProperty "HKLM:\SYSTEM\CurrentControlSet\Control\Session Manager" -Name PendingFileRenameOperations -EA Ignore) { Write-Output $true }
	try { 
		$util = [wmiclass]"\\.\root\ccm\clientsdk:CCM_ClientUtilities"
		$status = $util.DetermineIfRebootPending()
		if (($null -ne $status) -and ($status.RebootPending)) {
			Write-Output $true
		}
	} catch {}
	Write-Output $false
}
