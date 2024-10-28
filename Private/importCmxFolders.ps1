function importCmxFolders {
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
				writeLogFile -Category "info" -Message "creating folder: $fn (comment: $folderComm)"
				try {
					$null = New-Item -Path $fn -ItemType Directory -ErrorAction SilentlyContinue
					$WaitAfter = $True
				} catch {
					writeLogFile -Category "error" -Message $_.Exception.Message
					$result = $False
					break
				}
			} else {
				writeLogFile -Category "info" -Message "folder already exists: $fn"
			}
		}
	}
	if ($WaitAfter) {
		writeLogFile -Category "info" -Message "pausing for 5 seconds"
		Start-Sleep -Seconds 5
	}
	writeLogFile -Category "info" -Message "function runtime = $(getTimeOffset -StartTime $timex)"
	writeLogFile -Category "info" -Message "function result = $result"
	Write-Output $result
}
