function importCmxFiles {
	[CmdletBinding(SupportsShouldProcess=$True)]
	param (
		[parameter(Mandatory=$True)]
		[ValidateNotNullOrEmpty()]
		$DataSet
	)
	Write-Host "Configuring files" -ForegroundColor Green
	$result = $True
	$timex  = Get-Date
	foreach ($item in $DataSet.configuration.files.file | Where-Object {$_.use -eq '1'}) {
		$filename = $item.name
		$filepath = $item.path 
		$fullName = "$filePath\$filename"
		$fileComm = $item.comment 
		$filekeys = $item.keys.key
		writeLogFile -Category "info" -Message "filename: $fullName (comment: $fileComm)"
		if (-not (Test-Path $fullName)) {
			writeLogFile -Category "info" -Message "creating new file: $fullName"
		}
		else {
			writeLogFile -Category "info" -Message "overwriting file: $fullName"
		}
		$data = ""
		foreach ($filekey in $filekeys) {
			$keyname = $filekey.name
			$keyval  = convertToCmxString $DataSet -Stringval $filekey.value
			if ($keyname.StartsWith('__')) {
				if ($data -ne "") {
					$data += "`r`n`[$keyval`]`r`n"
				} else {
					$data += "`[$keyval`]`r`n"
				}
			} else {
				if ($keyname -eq "SQLSYSADMINACCOUNTS") {
					$kv = $(foreach ($y in $keyval.split(',')) {'"' + $y + '"'}) -join " "
					$data += "$keyname=$kv`r`n"
				} else {
					$data += "$keyname=`"$keyval`"`r`n"
				}
			}
		} # foreach
		try {
			$data | Out-File $fullname -Force
		} catch {
			writeLogFile -Category error -Message "Failed to write file: $fullname"
			$result = $False
		}
	} # foreach
	writeLogFile -Category "info" -Message "function result = $result"
	writeLogFile -Category "info" -Message "function runtime = $(getTimeOffset -StartTime $timex)"
	Write-Output $result
}
