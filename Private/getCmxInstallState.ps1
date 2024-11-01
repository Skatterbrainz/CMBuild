function getCmxInstallState {
	<#
	.SYNOPSIS
	Get Install State of a Given Feature or Application
	
	.DESCRIPTION
	Long description
	
	.PARAMETER PackageName
	Name of control Package
	
	.PARAMETER RuleType
	Rule type to process
	
	.PARAMETER RuleData
	Rule data to process
	
	#>
	param (
		[parameter(Mandatory=$True)]
			[ValidateNotNullOrEmpty()]
			[string] $PackageName,
		[parameter(Mandatory=$True)]
			[ValidateNotNullOrEmpty()]
			[string] $RuleType, 
		[parameter(Mandatory=$True)]
			[ValidateNotNullOrEmpty()]
			[string] $RuleData
	)
	writeLogFile -Category "info" -Message "[function: getCmxInstallState]"
	writeLogFile -Category "info" -Message "detection type = $RuleType"
	writeLogFile -Category "info" -Message "detection rule = $RuleData"
	switch ($RuleType.ToLower()) {
		'automatic' {
			$result = (Test-Path $RuleData)
		}
		'synthetic' {
			$detPath = "$RuleData\$PackageName"
			writeLogFile -Category "info" -Message "detection rule = $detPath"
			$result  = (Test-Path $detPath)
		}
		'feature' {
			try {
				$result = ((Get-WindowsFeature $RuleData | Select-Object -ExpandProperty Installed) -eq $True)
			}
			catch {}
		}
	}
	writeLogFile -Category "info" -Message "function result = $result"
	Write-Output $result
}
