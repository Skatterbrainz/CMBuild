function Get-CMxConfigData {
    param (
        [parameter(Mandatory=$True)]
            [ValidateNotNullOrEmpty()]
            [string] $XmlFile
    )
    Write-Host "Loading configuration data" -ForegroundColor Green
    if ($XmlFile.StartsWith("http")) {
        try {
            [xml]$data = Invoke-RestMethod -Uri $XmlFile
            Write-Output $data
        }
        catch {
            Write-Log -Category "error" -Message "failed to import data from Uri: $XmlFile"
        }
    }
    else {
        if (-not(Test-Path $XmlFile)) {
            Write-Warning "ERROR: configuration file not found: $XmlFile"
        }
        else {
            try {
                [xml]$data = Get-Content $XmlFile
                Write-Output $data
            }
            catch {
                Write-Log -Category "error" -Message "failed to import data from file: $XmlFile"
            }
        }
    }
}
