function Import-CMxFiles {
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
		Write-Log -Category "info" -Message "filename: $fullName (comment: $fileComm)"
		if (-not (Test-Path $fullName)) {
			Write-Log -Category "info" -Message "creating new file: $fullName"
		}
		else {
			Write-Log -Category "info" -Message "overwriting file: $fullName"
		}
		$data = ""
		foreach ($filekey in $filekeys) {
			$keyname = $filekey.name
			$keyval  = Convert-CmxString $DataSet -Stringval $filekey.value
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
			Write-Log -Category error -Message "Failed to write file: $fullname"
			$result = $False
		}
	} # foreach
	Write-Log -Category "info" -Message "function result = $result"
	Write-Log -Category "info" -Message "function runtime = $(Get-TimeOffset -StartTime $timex)"
	Write-Output $result
}
