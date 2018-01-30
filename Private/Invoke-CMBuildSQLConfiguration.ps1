function Invoke-CMBuildSQLConfiguration {
    <#
    .SYNOPSIS
    Configure SQL Server options
    
    .DESCRIPTION
    Configure SQL Server options using XML data set parameters
    
    .PARAMETER DataSet
    XML gibberish read from voodoo, mud and sticks
    
    .EXAMPLE
    Invoke-CMBuildSQLConfiguration -DataSet $xmldata
    
    .NOTES
    part of CMBuild powershell module - David Stein - 11/22/2017
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
        Write-Log -Category "info" -Message "option name..... $optName" -LogFile $logfile
        Write-Log -Category "info" -Message "option db....... $optDB" -LogFile $logfile
        Write-Log -Category "info" -Message "option param.... $optData" -LogFile $logfile
        Write-Log -Category "info" -Message "option comment.. $optComm" -LogFile $logfile
        switch ($optName) {
            'SqlServerMemoryMax' {
                Write-Log -Category "info" -Message "SQL - configuring = maximum memory limit" -LogFile $logfile
                if ($optData.EndsWith("%")) {
                    Write-Log -Category "info" -Message "SQL - configuring relative memory limit" -LogFile $logfile
                    [int]$MemRatio = $optData.Replace("%","")
                    $dblRatio = $MemRatio * 0.01
                    # convert total memory GB to MB
                    $actMax   = Get-CMBuildTotalPhysicalMemory
                    $newMax   = $actMax * $dblRatio
                    $curMax   =  [math]::Round((Get-DbaMaxMemory -SqlServer $HostFullName).SqlMaxMB/1024,0)
                    Write-Log -Category "info" -Message "SQL - total memory (GB)....... $actMax" -LogFile $logfile
                    Write-Log -Category "info" -Message "SQL - recommended max (GB).... $newMax" -LogFile $logfile
                    Write-Log -Category "info" -Message "SQL - current max (GB)........ $curMax" -LogFile $logfile
                    if ($curMax -eq $newMax) {
                        Write-Log -Category "info" -Message "SQL - current max is already set" -LogFile $logfile
                        $result = 0
                    }
                    elseif (($actMax - $newMax) -le 4) {
                        Write-Log -Category "warning" -Message "SQL - recommended max would not allow 4GB for OS (skipping)" -LogFile $logfile
                        $result = 0
                    } 
                    else {
                        # convert GB to MB for cmdlet
                        $newMax = [math]::Round($newMax * 1024,0)
                        Write-Log -Category "info" -Message "SQL - adjusting max memory to $newMax MB" -LogFile $logfile
                        try {
                            Set-DbaMaxMemory -SqlServer $HostFullName -MaxMb $newMax | Out-Null
                            Write-Log -Category "info" -Message "SQL - maximum memory allocation is now: $newMax" -LogFile $logfile
                            Set-CMBuildTaskCompleted -KeyName 'SQLCONFIG' -Value $(Get-Date)
                            $result = 0
                        }
                        catch {
                            Write-Log -Category "error" -Message "SQL - failed to change memory allocation!" -Severity 3 -LogFile $logfile
                        }
                    }
                }
                else {
                    Write-Log -Category "info" -Message "configuring static memory limit" -LogFile $logfile
                    $curMax = (Get-DbaMaxMemory -SqlServer $HostFullName).SqlMaxMB
                    try {
                        Set-DbaMaxMemory -SqlServer $HostFullName -MaxMb [int]$optData | Out-Null
                    }
                    catch {
                        Write-Log -Category "error" -Message "failed to set max memory" -Severity 3 -LogFile $logfile
                    }
                }
                break
            }
            'SetDBRecoveryModel' {
                Write-Log -Category "info" -Message "SQL - configuring = database recovery model" -LogFile $logfile
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
                                Write-Log -Category "info" -Message "SQL - successfully configured for $optData" -LogFile $logfile
                            }
                            catch {
                                Write-Log -Category "error" -Message "SQL - failed to configure for $optData" -Severity 3 -LogFile $logfile
                                $result = $False
                            }
                        }
                        else {
                            try {
                                $db.RecoveryModel = [Microsoft.SqlServer.Management.Smo.RecoveryModel]::Simple;
                                $db.Alter();
                                Write-Log -Category "info" -Message "SQL - successfully configured for $optData" -LogFile $logfile
                            }
                            catch {
                                Write-Log -Category "error" -Message "SQL - failed to configure for $optData" -Severity 3 -LogFile $logfile
                                $result = $False
                            }
                        }
                    } # if
                } # if
            }
        } # switch
    } # foreach
    Write-Log -Category "info" -Message "function runtime = $(Get-TimeOffset -StartTime $timex))" -LogFile $logfile
    Write-Output $result
}
