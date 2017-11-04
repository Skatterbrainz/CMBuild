function Invoke-CMxSqlConfiguration {
    [CmdletBinding(SupportsShouldProcess=$True)]
    param(
        [parameter(Mandatory=$True)]
        [ValidateNotNullOrEmpty()]
        $DataSet
    )
    Write-Host "Configuring SQL Server settings" -ForegroundColor Green
    $timex  = Get-Date
    $result = 0
    foreach ($item in $DataSet.configuration.sqloptions.sqloption | Where-Object {$_.use -eq '1'}) {
        $optName = $item.name
        $optData = $item.param
        $optDB   = $item.db
        $optComm = $item.comment
        Write-Log -Category "info" -Message "option name..... $optName"
        Write-Log -Category "info" -Message "option db....... $optDB"
        Write-Log -Category "info" -Message "option param.... $optData"
        Write-Log -Category "info" -Message "option comment.. $optComm"
        switch ($optName) {
            'SqlServerMemoryMax' {
                Write-Log -Category "info" -Message "SQL - configuring = maximum memory limit"
                if ($optData.EndsWith("%")) {
                    Write-Log -Category "info" -Message "SQL - configuring relative memory limit"
                    [int]$MemRatio = $optData.Replace("%","")
                    $dblRatio = $MemRatio * 0.01
                    # convert total memory GB to MB
                    $actMax   = Get-CMxTotalMemory
                    $newMax   = $actMax * $dblRatio
                    #$curMax   = [math]::Round((Get-SqlMaxMemory -SqlInstance $HostFullName).SqlMaxMB/1024,0)
					$curMax   =  [math]::Round((Get-DbaMaxMemory -SqlServer $HostFullName).SqlMaxMB/1024,0)
                    Write-Log -Category "info" -Message "SQL - total memory (GB)....... $actMax"
                    Write-Log -Category "info" -Message "SQL - recommended max (GB).... $newMax"
                    Write-Log -Category "info" -Message "SQL - current max (GB)........ $curMax"
                    if ($curMax -eq $newMax) {
                        Write-Log -Category "info" -Message "SQL - current max is already set"
                        $result = 0
                    }
                    elseif (($actMax - $newMax) -le 4) {
                        Write-Log -Category "warning" -Message "SQL - recommended max would not allow 4GB for OS (skipping)"
                        $result = 0
                    } 
                    else {
                        # convert GB to MB for cmdlet
                        $newMax = [math]::Round($newMax * 1024,0)
                        Write-Log -Category "info" -Message "SQL - adjusting max memory to $newMax MB"
                        try {
                            #Set-SqlMaxMemory -SqlInstance $HostFullName -MaxMB $newMax | Out-Null
							Set-DbaMaxMemory -SqlServer $HostFullName -MaxMb $newMax | Out-Null
                            Write-Log -Category "info" -Message "SQL - maximum memory allocation is now: $newMax"
                            Set-CMxTaskCompleted -KeyName 'SQLCONFIG' -Value $(Get-Date)
                            $result = 0
                        }
                        catch {
                            Write-Log -Category "error" -Message "SQL - failed to change memory allocation!"
                        }
                    }
                }
                else {
                    Write-Log -Category "info" -Message "configuring static memory limit"
                    #$curMax = (Get-SqlMaxMemory -SqlInstance $HostFullName).SqlMaxMB
					$curMax = (Get-DbaMaxMemory -SqlServer $HostFullName).SqlMaxMB
                    try {
						Set-DbaMaxMemory -SqlServer $HostFullName -MaxMb [int]$optData | Out-Null
                        #Set-SqlMaxMemory -SqlInstance $HostFullName -MaxMb [int]$optData -Silent | Out-Null
                    }
                    catch {
                        Write-Log -Category "error" -Message "failed to set max memory"
                    }
                }
                break
            }
            'SetDBRecoveryModel' {
                Write-Log -Category "info" -Message "SQL - configuring = database recovery model"
                try {
                    $db = Get-SqlDatabase -ServerInstance $HostFullName -Name $optDB
                }
                catch {
                    $db = $null
                }
                if ($db) {
                    $curModel = $db.RecoveryModel
                    Write-Log -Category "info" -Message "SQL - current recovery model.... $curModel"
                    if ($curModel -ne $optData) {
                        if ($optData -eq 'FULL') {
                            try {
                                $db.RecoveryModel = [Microsoft.SqlServer.Management.Smo.RecoveryModel]::Full;
                                $db.Alter();
                                Write-Log -Category "info" -Message "SQL - successfully configured for $optData"
                            }
                            catch {
                                Write-Log -Category "error" -Message "SQL - failed to configure for $optData"
                                $result = $False
                            }
                        }
                        else {
                            try {
                                $db.RecoveryModel = [Microsoft.SqlServer.Management.Smo.RecoveryModel]::Simple;
                                $db.Alter();
                                Write-Log -Category "info" -Message "SQL - successfully configured for $optData"
                            }
                            catch {
                                Write-Log -Category "error" -Message "SQL - failed to configure for $optData"
                                $result = $False
                            }
                        }
                    } # if
                } # if
            }
        } # switch
    } # foreach
    Write-Log -Category "info" -Message "function runtime = $(Get-TimeOffset -StartTime $timex))"
    Write-Output $result
}
