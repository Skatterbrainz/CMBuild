function Disable-InternetExplorerESC {
    Write-Verbose "----------------------------------------------------"
    Write-Log -Category "info" -Message "Disabling IE Enhanced Security Configuration."
    $AdminKey = "HKLM:\SOFTWARE\Microsoft\Active Setup\Installed Components\{A509B1A7-37EF-4b3f-8CFC-4F3A74704073}"
    $UserKey  = "HKLM:\SOFTWARE\Microsoft\Active Setup\Installed Components\{A509B1A8-37EF-4b3f-8CFC-4F3A74704073}"
    if ((Get-ItemProperty -Path $AdminKey -Name "IsInstalled" | Select-Object -ExpandProperty IsInstalled) -ne 0) {
        try {
            Set-ItemProperty -Path $AdminKey -Name "IsInstalled" -Value 0 -Force
            Set-ItemProperty -Path $UserKey -Name "IsInstalled" -Value 0 -Force
            Stop-Process -Name Explorer -Force
            Write-Output 0
        }
        catch {Write-Output -1}
        Write-Log -Category "info" -Message "IE Enhanced Security Configuration (ESC) has been disabled."
    }
    else {
        Write-Log -Category "info" -Message "IE Enhanced Security Configuration (ESC) is already disabled."
    }
}
