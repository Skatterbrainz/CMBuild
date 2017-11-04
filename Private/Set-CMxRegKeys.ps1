function Set-CMxRegKeys {
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
    Write-Log -Category "info" -Message "keygroup order = $Order"
    $result = $True
    foreach ($item in $DataSet.configuration.regkeys.regkey | Where-Object {$_.use -eq '1'}) {
        $regName  = $item.name
        $regOrder = $item.order
        $reg = $null
        if ($regOrder -eq $Order) {
            $regPath = $item.path
            $regVal  = $item.value
            $regData = $item.data
            switch ($regPath.substring(0,4)) {
                'HKLM' {
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
