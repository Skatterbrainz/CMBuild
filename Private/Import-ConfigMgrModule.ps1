function Import-ConfigMgrModule {
    [CmdletBinding()]
    param ()
	Write-Log -Category "info" -Message "------------------------------ Import-CmxModule -------------------------------"
    if (-not(Get-Module ConfigurationManager)) {
        Write-Host "Importing the ConfigurationManager powershell module" -ForegroundColor Green
        try {
            Import-Module "$($ENV:SMS_ADMIN_UI_PATH)\..\ConfigurationManager.psd1" 
            Write-Output $True
        }
        catch {}
    }
    else {
        Write-Output $True
    }
}
