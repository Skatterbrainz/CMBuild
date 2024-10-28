function importCmxQueries {
	[CmdletBinding(SupportsShouldProcess=$True)]
	param (
		[parameter(Mandatory=$True)]
		[ValidateNotNullOrEmpty()]
		$DataSet
	)
	writeLogFile -Category "info" -Message "------------------------------ importCmxQueries -------------------------------"
	Write-Host "Importing custom Queries" -ForegroundColor Green
	$result = $True
	$Time1  = Get-Date
	foreach ($item in $DataSet.configuration.cmsite.queries.query | Where-Object {$_.use -eq '1'}) {
		$queryName = $item.name
		$queryComm = $item.comment
		$queryType = $item.class
		$queryExp  = $item.expression
		try {
			$null = New-CMQuery -Name $queryName -Expression $queryExp -Comment $queryComm -TargetClassName $queryType
			writeLogFile -Category "info" -Message "item created successfully: $queryName"
		} catch {
			if ($_.Exception.Message -like "*already exists*") {
				writeLogFile -Category "info" -Message "item already exists: $queryname"
			} else {
				writeLogFile -Category "error" -Message $_.Exception.Message
				$result = $False
				break
			}
		}
		Write-Verbose "- - - - - - - - - - - - - - - - - - - - - - - - - - - - - -"
	} # foreach
	writeLogFile -Category info -Message "function runtime: $(getTimeOffset $time1)"
	Write-Output $result
}
