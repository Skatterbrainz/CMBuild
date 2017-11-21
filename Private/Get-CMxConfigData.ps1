function Get-CMxConfigData {
    <#
    .SYNOPSIS
    Import XML Control Data
    
    .DESCRIPTION
    Import XML Control Data
    
    .PARAMETER XmlFile
    Path and Name of XML control file
    
    .EXAMPLE
    Get-CMxConfigData -XmlFile 'https:\\myurl.contoso.nothing\path\filename.xml'
    
    .NOTES
    General notes
    #>

    param (
        [parameter(Mandatory=$True, HelpMessage="Path to XML control file")]
            [ValidateNotNullOrEmpty()]
            [string] $XmlFile
    )
    Write-Host "Loading configuration data" -ForegroundColor Green
    if ($XmlFile.StartsWith("http")) {
        try {
            [xml]$data = ((New-Object System.Net.WebClient).DownloadString($XmlFile))
#            [xml]$data = Invoke-RestMethod -Uri $XmlFile
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
