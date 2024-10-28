function Test-CMxPlatform {
	param ()
	Write-Log -Category "info" -Message "function: Test-CMxPlatform"
	$os = Get-WmiObject -Class Win32_OperatingSystem | Select-Object -ExpandProperty caption
	if (($os -like "*Windows Server 2012 R2*") -or ($os -like "*Windows Server 2016*")) {
		Write-Log -Category "info" -Message "passed rule = operating system"
		$mem = [math]::Round($(Get-WmiObject -Class Win32_ComputerSystem | 
			Select-Object -ExpandProperty TotalPhysicalMemory)/1GB,0)
		if ($mem -ge 16) {
			Write-Log -Category "info" -Message "passed rule = minimmum memory allocation"
			Write-Output $True
		} else {
			Write-Host "FAIL: System has $mem GB of memory. ConfigMgr requires 16 GB of memory or more" -ForegroundColor Red
		}
	} else {
		Write-Host "FAIL: Operating System must be Windows Server 2012 R2 or 2016" -ForegroundColor Red
	}
}
