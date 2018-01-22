function Set-CMSiteConfigFolders {
    <#
    .SYNOPSIS
    Create folders in ConfigMgr Console
    
    .DESCRIPTION
    Create folders in ConfigMgr Console
    
    .PARAMETER SiteCode
    Site code
    
    .PARAMETER DataSet
    XML data set
    
    .EXAMPLE
    Set-CMSiteConfigFolders -SiteCode 'P01' -DataSet $xmldata
    
    .NOTES
    1.0.7 - 01/22/2018 - David Stein
    #>

    [CmdletBinding(SupportsShouldProcess=$True)]
    param (
        [parameter(Mandatory=$True, HelpMessage="Site Code")]
            [ValidateNotNullOrEmpty()]
            [string] $SiteCode,
        [parameter(Mandatory=$True, HelpMessage="XML Data Set")]
            [ValidateNotNullOrEmpty()]
            [xml] $DataSet
    )
	Write-Log -Category "info" -Message "------------------------------ Set-CMSiteConfigFolders -------------------------------" -LogFile $logfile
    Write-Host "Configuring console folders" -ForegroundColor Green
    $result = $true
    $Time1  = Get-Date
    foreach ($item in $DataSet.configuration.cmsite.folders.folder | Where-Object {$_.use -eq '1'}) {
        $folderName = $item.name
        $folderPath = $item.path
		Write-Log -Category "info" -Message "folder path: $folderPath\$folderName"
		if (Test-Path "$folderPath\$folderName") {
			Write-Log -Category "info" -Message "folder already exists" -LogFile $logfile
		}
		else {
			try {
				New-Item -Path "$SiteCode`:\$folderPath" -Name $folderName -ErrorAction SilentlyContinue | Out-Null
				Write-Log -Category "info" -Message "created successfully: $folderPath\$folderName" -LogFile $logfile
			}
			catch {
				Write-Log -Category "error" -Message $_.Exception.Message -Severity 3 -LogFile $logfile
			}
		}
        Write-Log -Category "info" -Message "- - - - - - - - - - - - - - - - - - - - - - - - - - - - - -" -LogFile $logfile
    } # foreach
    Write-Log -Category info -Message "function runtime: $(Get-TimeOffset $time1)" -LogFile $logfile
    Write-Output $result
}
