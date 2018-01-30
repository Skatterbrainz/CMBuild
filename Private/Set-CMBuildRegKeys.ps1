function Set-CMBuildRegKeys {
    <#
    .SYNOPSIS
    Write Registry Data
    
    .DESCRIPTION
    Write Registry Daa
    
    .PARAMETER DataSet
    XML data set
    
    .PARAMETER Order
    Sequence order: Before or After
    
    .EXAMPLE
    An example
    
    .NOTES
    General notes
    #>

    [CmdletBinding(SupportsShouldProcess=$True)]
    param (
        [parameter(Mandatory=$True)]
            [ValidateNotNullOrEmpty()]
            [xml] $DataSet,
        [parameter(Mandatory=$True)]
            [ValidateSet('before','after')]
            [string] $Order
    )
    Write-Host "Configuring registry keys" -ForegroundColor Green
    Write-Log -Category "info" -Message "keygroup order = $Order"
    $result = $True
    foreach ($item in $DataSet.configuration.regkeys.regkey | Where-Object {$_.use -eq '1'}) {
        $regName  = $item.name
        $regOrder = $item.order
        $reg = $null
        Write-Log -Category "info" -Message "registry name...: $regName"
        Write-Log -Category "info" -Message "registry order..: $regOrder"
        if ($regOrder -eq $Order) {
            $regPath = $item.path
            $regVal  = $item.value
            $regData = $item.data
            Write-Log -Category "info" -Message "registry path...: $regPath"
            Write-Log -Category "info" -Message "registry value..: $regVal"
            Write-Log -Category "info" -Message "registry data...: $regData"
            switch ($regPath.substring(0,4)) {
                'HKLM' {
                    Write-Log -Category "info" -Message "registry hive...: Local Machine"
                    try {
                        $reg = [Microsoft.Win32.RegistryKey]::OpenBaseKey([Microsoft.Win32.RegistryHive]::LocalMachine,'default')
                        Write-Log -Category "info" -Message "opened registry hive $($regPath.Substring(0,4)) successfully"
                    }
                    catch {
                        Write-Log -Category "error" -Message $_.Exception.Message
                        $result = $False
                    }
                    break
                }
            }
            if ($reg) {
                try {
                    $keyset = $reg.OpenSubKey($regPath.Substring(6))
                    $val = $keyset.GetValue($regVal)
                    Write-Log -Category "info" -Message "current value = $val"
                    if (!!(Get-Item -Path $regPath)) {
                        Write-Log -Category "info" -Message "registry key path exists: $regPath"
                    }
                    else {
                        Write-Log -Category "info" -Message "registry key path not found, creating: $regPath"
                        New-Item -Path $regPath -Force | Out-Null
                    }
                    Write-Log -Category "info" -Message "adding/updating registry value: $regVal --> $regData"
                    New-ItemProperty -Path $regPath -Name $regVal -Value $regData -PropertyType STRING -Force | Out-Null
                    $keyset = $reg.OpenSubKey($regPath.Substring(6))
                    $val = $keyset.GetValue($regVal)
                    Write-Log -Category "info" -Message "registry value updated: $val"
                }
                catch {
                    Write-Log -Category "error" -Message $_.Exception.Message
                    $result = $False
                }
            }
        }
    }
    Write-Output $result
}
