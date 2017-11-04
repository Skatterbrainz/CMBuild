function Import-CMxFolders {
    [CmdletBinding(SupportsShouldProcess=$True)]
    param(
        [parameter(Mandatory=$True)]
        [ValidateNotNullOrEmpty()]
        $DataSet
    )
    Write-Host "Configuring folders" -ForegroundColor Green
    $result = $True
    $timex  = Get-Date
    foreach ($item in $DataSet.configuration.folders.folder | Where-Object {$_.use -eq '1'}) {
        $folderName = $item.name
		$folderComm = $item.comment
        foreach ($fn in $folderName.split(',')) {
            if (-not(Test-Path $fn)) {
                Write-Log -Category "info" -Message "creating folder: $fn (comment: $folderComm)"
                try {
                    New-Item -Path $fn -ItemType Directory -ErrorAction SilentlyContinue | Out-Null
                    $WaitAfter = $True
                }
                catch {
                    Write-Log -Category "error" -Message $_.Exception.Message
                    $result = $False
                    break
                }
            }
            else {
                Write-Log -Category "info" -Message "folder already exists: $fn"
            }
        }
    }
    if ($WaitAfter) {
        Write-Log -Category "info" -Message "pausing for 5 seconds"
        Start-Sleep -Seconds 5
    }
    Write-Log -Category "info" -Message "function runtime = $(Get-TimeOffset -StartTime $timex)"
    Write-Log -Category "info" -Message "function result = $result"
    Write-Output $result
}
