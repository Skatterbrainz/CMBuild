function Import-CmxClientSettings {
	[CmdletBinding(SupportsShouldProcess=$True)]
	param (
		[parameter(Mandatory=$True)]
		[ValidateNotNullOrEmpty()]
		$DataSet
	)
	Write-Log -Category "info" -Message "------------------------------ Import-CmxClientSettings -------------------------------"
	Write-Host "Configuring Client Settings" -ForegroundColor Green
	$result = $True
	$Time1  = Get-Date
	
	foreach ($item in $DataSet.configuration.cmsite.clientsettings.clientsetting | Where-Object {$_.use -eq '1'}) {
		$csName = $item.Name
		$csComm = $item.comment 
		$csPri  = $item.priority
		$csType = $item.type
		Write-Log -Category "info" -Message "setting group name... $csName"
		if (Get-CMClientSetting -Name $csName) {
			Write-Log -Category info -Message "client setting is already created"
		} else {
			try {
				New-CMClientSetting -Name "$csName" -Description "$csComm" -Type $csType -ErrorAction SilentlyContinue | Out-Null
				Write-Log -Category info -Message "client setting was created successfully."
			} catch {
				Write-Log -Category error -Message "your client setting just fell into a woodchipper. what a mess."
				Write-Error $_.Exception.Message
				$result = $False
				break
			}
		}
		foreach ($csSet in $item.settings.setting | Where-Object {$_.use -eq '1'}) {
			$setName = $csSet.name
			Write-Log -Category "info" -Message "setting name......... $setName"
			$code = "Set-CMClientSetting$setName `-Name `"$csName`""
			foreach ($opt in $csSet.options.option) {
				$optName = $opt.name
				$optVal  = $opt.value
				Write-Log -Category "info" -Message "setting option name.. $optName --> $optVal"
				switch ($optVal) {
					'true' {
						$param = " `-$optName `$true"
					}
					'false' {
						$param = " `-$optName `$false"
					}
					'null' {
						$param = " `-$optName `$null"
					}
					default {
						if ($optName -eq 'SWINVConfiguration') {
							$paramx = "`@`{"
							foreach ($opt in $optVal.Split('|')) {
								$opx = $opt.Split('=')
								$op1 = $opx[0]
								$op2 = $opx[1]
								if (('False','True','null') -icontains $op2) {
									$y = "$op1`=`$$op2`;"
								}
								else {
									$y = "$op1`=`"$op2`"`;"
								}
								$paramx += $y
							}
							$paramx += "`}"
							$param = " `-AddInventoryFileType $paramx"
						} else {
							$param = " `-$optName `"$optVal`""
						}
					}
				} # switch
				$code += $param
			} # foreach - setting option
			Write-Log -Category "info" -Message "CODE >> $code"
			try {
				Invoke-Expression -Command $code -ErrorAction Stop
				Write-Log -Category info -Message "client setting has been applied successfully"
			} catch {
				Write-Log -Category error -Message $_.Exception.Message
				$result = $False
				break
			}
			Write-Log -Category "info" -Message "............................................................"
		} # foreach - setting group
	} # foreach - client setting policy
	Write-Log -Category info -Message "function runtime: $(Get-TimeOffset -StartTime $Time1)"
	Write-Output $result
}
