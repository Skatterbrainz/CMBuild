function invokeCmxPackage {
	[CmdletBinding(SupportsShouldProcess=$True)]
	param (
		[parameter(Mandatory=$True)]
			[string] $Name,
		[parameter(Mandatory=$True)]
			[string] $PackageType,
		[parameter(Mandatory=$False)]
			[string] $PayloadSource="",
		[parameter(Mandatory=$False)]
			[string] $PayloadFile="",
		[parameter(Mandatory=$False)]
			[string] $PayloadArguments=""
	)
	writeLogFile -Category "info" -Message "function: invokeCmxPackage"
	writeLogFile -Category "info" -Message "package type = $PackageType"
	switch ($PackageType) {
		'feature' {
			writeLogFile -Category "info" -Message "installation feature = $Name"
			Write-Host "Installing $pkgComm" -ForegroundColor Green
			$xdata = ($xmldata.configuration.features.feature | 
				Where-Object {$_.name -eq $Name} | 
					Foreach-Object {$_.innerText}).Split(',')
			$result = importCmxServerRoles -RoleName $Name -FeaturesList $xdata -AlternateSource $AltSource
			writeLogFile -Category "info" -Message "exit code = $result"
			if ($result -or ($result -eq 0)) { 
				setCmxTaskCompleted -KeyName $Name -Value $(Get-Date) 
			} else {
				Write-Warning "error: step failure [feature] at: $Name"
				$continue = $False
			}
		}
		'function' {
			$result = invokeCmxFunction -Name $Name -Comment $pkgComm
			if (!($result -or ($result -eq 0))) { 
				Write-Warning "error: step failure [function] at: $Name"
				$continue = $False
			}
		}
		'payload' {
			$result = startCmxPayload -Name $Name -SourcePath $PayloadSource -PayloadFile $PayloadFile -PayloadArguments $PayloadArguments
			if (!($result -or ($result -eq 0))) { 
				Write-Warning "error: step failure [payload] at: $Name"
				$continue = $False
			}
		}
		default {
			Write-Warning "invalid package type value: $PackageType"
			$continue
		}
	} # switch
	writeLogFile -Category "info" -Message "[invokeCmxPackage] result = $result"
	Write-Output $result
}
