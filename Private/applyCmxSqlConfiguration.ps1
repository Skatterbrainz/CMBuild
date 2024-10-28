function applyCmxSqlConfiguration {
	<#
	.SYNOPSIS
	Configure SQL Server options
	
	.DESCRIPTION
	Configure SQL Server options using XML data set parameters
	
	.PARAMETER DataSet
	XML gibberish read from voodoo, mud and sticks
	
	.EXAMPLE
	applyCmxSqlConfiguration -DataSet $xmldata
	#>
	[CmdletBinding()]
	param(
		[parameter(Mandatory=$True, HelpMessage="XML Data Set")]
		[ValidateNotNullOrEmpty()]
		[xml] $DataSet
	)
	Write-Host "Configuring SQL Server settings" -ForegroundColor Green
	$timex  = Get-Date
	$result = 0
	foreach ($item in $DataSet.configuration.sqloptions.sqloption | Where-Object {$_.use -eq '1'}) {
		$optName = $item.name
		$optData = $item.param
		$optDB   = $item.db
		$optComm = $item.comment
		writeLogFile -Category "info" -Message "option name..... $optName" -LogFile $logfile
		writeLogFile -Category "info" -Message "option db....... $optDB" -LogFile $logfile
		writeLogFile -Category "info" -Message "option param.... $optData" -LogFile $logfile
		writeLogFile -Category "info" -Message "option comment.. $optComm" -LogFile $logfile
		switch ($optName) {
			'SqlServerMemoryMax' {
				writeLogFile -Category "info" -Message "SQL - configuring = maximum memory limit" -LogFile $logfile
				if ($optData.EndsWith("%")) {
					writeLogFile -Category "info" -Message "SQL - configuring relative memory limit" -LogFile $logfile
					[int]$MemRatio = $optData.Replace("%","")
					$dblRatio = $MemRatio * 0.01
					# convert total memory GB to MB
					$actMax   = getCmxTotalMemory
					$newMax   = $actMax * $dblRatio
					$curMax   =  [math]::Round((Get-DbaMaxMemory -SqlServer $CmBuildSettings['HostFullName']).SqlMaxMB/1024,0)
					writeLogFile -Category "info" -Message "SQL - total memory (GB)....... $actMax" -LogFile $logfile
					writeLogFile -Category "info" -Message "SQL - recommended max (GB).... $newMax" -LogFile $logfile
					writeLogFile -Category "info" -Message "SQL - current max (GB)........ $curMax" -LogFile $logfile
					if ($curMax -eq $newMax) {
						writeLogFile -Category "info" -Message "SQL - current max is already set" -LogFile $logfile
						$result = 0
					} elseif (($actMax - $newMax) -le 4) {
						writeLogFile -Category "warning" -Message "SQL - recommended max would not allow 4GB for OS (skipping)" -LogFile $logfile
						$result = 0
					} else {
						# convert GB to MB for cmdlet
						$newMax = [math]::Round($newMax * 1024,0)
						writeLogFile -Category "info" -Message "SQL - adjusting max memory to $newMax MB" -LogFile $logfile
						try {
							Set-DbaMaxMemory -SqlServer $CmBuildSettings['HostFullName'] -MaxMb $newMax | Out-Null
							writeLogFile -Category "info" -Message "SQL - maximum memory allocation is now: $newMax" -LogFile $logfile
							setCmxTaskCompleted -KeyName 'SQLCONFIG' -Value $(Get-Date)
							$result = 0
						} catch {
							writeLogFile -Category "error" -Message "SQL - failed to change memory allocation!" -Severity 3 -LogFile $logfile
						}
					}
				} else {
					writeLogFile -Category "info" -Message "configuring static memory limit" -LogFile $logfile
					$curMax = (Get-DbaMaxMemory -SqlServer $CmBuildSettings['HostFullName']).SqlMaxMB
					try {
						Set-DbaMaxMemory -SqlServer $CmBuildSettings['HostFullName'] -MaxMb [int]$optData | Out-Null
					} catch {
						writeLogFile -Category "error" -Message "failed to set max memory" -Severity 3 -LogFile $logfile
					}
				}
			}
			'SetDBRecoveryModel' {
				writeLogFile -Category "info" -Message "SQL - configuring = database recovery model" -LogFile $logfile
				try {
					$db = Get-SqlDatabase -ServerInstance $CmBuildSettings['HostFullName'] -Name $optDB
				} catch {
					$db = $null
				}
				if ($db) {
					$curModel = $db.RecoveryModel
					writeLogFile -Category "info" -Message "SQL - current recovery model.... $curModel"
					if ($curModel -ne $optData) {
						if ($optData -eq 'FULL') {
							try {
								$db.RecoveryModel = [Microsoft.SqlServer.Management.Smo.RecoveryModel]::Full;
								$db.Alter();
								writeLogFile -Category "info" -Message "SQL - successfully configured for $optData" -LogFile $logfile
							} catch {
								writeLogFile -Category "error" -Message "SQL - failed to configure for $optData" -Severity 3 -LogFile $logfile
								$result = $False
							}
						} else {
							try {
								$db.RecoveryModel = [Microsoft.SqlServer.Management.Smo.RecoveryModel]::Simple;
								$db.Alter();
								writeLogFile -Category "info" -Message "SQL - successfully configured for $optData" -LogFile $logfile
							} catch {
								writeLogFile -Category "error" -Message "SQL - failed to configure for $optData" -Severity 3 -LogFile $logfile
								$result = $False
							}
						}
					} # if
				} # if
			}
		} # switch
	} # foreach
	writeLogFile -Category "info" -Message "function runtime = $(getTimeOffset -StartTime $timex))" -LogFile $logfile
	Write-Output $result
}
