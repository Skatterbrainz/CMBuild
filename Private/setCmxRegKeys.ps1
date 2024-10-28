function setCmxRegKeys {
	[CmdletBinding(SupportsShouldProcess=$True)]
	param (
		[parameter(Mandatory=$True)]
			[ValidateNotNullOrEmpty()]
			$DataSet,
		[parameter(Mandatory=$True)]
			[ValidateSet('before','after')]
			[string] $Order
	)
	Write-Host "Configuring registry keys" -ForegroundColor Green
	writeLogFile -Category "info" -Message "keygroup order = $Order"
	$result = $True
	foreach ($item in $DataSet.configuration.regkeys.regkey | Where-Object {$_.use -eq '1'}) {
		$regName  = $item.name
		$regOrder = $item.order
		$reg      = $null
		writeLogFile -Category "info" -Message "registry name...: $regName"
		writeLogFile -Category "info" -Message "registry order..: $regOrder"
		if ($regOrder -eq $Order) {
			$regPath = $item.path
			$regVal  = $item.value
			$regData = $item.data
			writeLogFile -Category "info" -Message "registry path...: $regPath"
			writeLogFile -Category "info" -Message "registry value..: $regVal"
			writeLogFile -Category "info" -Message "registry data...: $regData"
			switch ($regPath.substring(0,4)) {
				'HKLM' {
					writeLogFile -Category "info" -Message "registry hive...: Local Machine"
					try {
						$reg = [Microsoft.Win32.RegistryKey]::OpenBaseKey([Microsoft.Win32.RegistryHive]::LocalMachine,'default')
						writeLogFile -Category "info" -Message "opened registry hive $($regPath.Substring(0,4)) successfully"
					} catch {
						writeLogFile -Category "error" -Message $_.Exception.Message
						$result = $False
					}
				}
			}
			if ($reg) {
				try {
					$keyset = $reg.OpenSubKey($regPath.Substring(6))
					$val = $keyset.GetValue($regVal)
					writeLogFile -Category "info" -Message "current value = $val"
					if (!!(Get-Item -Path $regPath)) {
						writeLogFile -Category "info" -Message "registry key path exists: $regPath"
					} else {
						writeLogFile -Category "info" -Message "registry key path not found, creating: $regPath"
						New-Item -Path $regPath -Force | Out-Null
					}
					writeLogFile -Category "info" -Message "adding/updating registry value: $regVal --> $regData"
					$null = New-ItemProperty -Path $regPath -Name $regVal -Value $regData -PropertyType STRING -Force
					$keyset = $reg.OpenSubKey($regPath.Substring(6))
					$val = $keyset.GetValue($regVal)
					writeLogFile -Category "info" -Message "registry value updated: $val"
				} catch {
					writeLogFile -Category "error" -Message $_.Exception.Message
					$result = $False
				}
			}
		}
	}
	Write-Output $result
}
