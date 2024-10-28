function setCmxBoundaries {
	[CmdletBinding(SupportsShouldProcess=$True)]
	param (
		[parameter(Mandatory=$True)]
		[ValidateNotNullOrEmpty()]
		$DataSet
	)
	writeLogFile -Category "info" -Message "------------------------------ setCmxBoundaries -------------------------------"
	Write-Host "Configuring Site Boundaries" -ForegroundColor Green
	$result = $True
	$Time1  = Get-Date
	foreach ($item in $DataSet.configuration.cmsite.boundaries.boundary | Where-Object {$_.use -eq '1'}) {
		$bName = $item.name
		$bType = $item.type
		$bData = $item.value
		$bGrp  = $item.boundarygroup
		$bComm = $item.comment
		writeLogFile -Category "info" -Message "- - - - - - - - - - - - - - - - - - - - - - - - - -"
		writeLogFile -Category "info" -Message "boundary name = $bName"
		writeLogFile -Category "info" -Message "comment = $bComm"
		writeLogFile -Category "info" -Message "data = $bData"
		writeLogFile -Category "info" -Message "type = $bType"
		writeLogFile -Category "info" -Message "boundary group = $bGrp"
		try {
			$bx = New-CMBoundary -Name $bName -Type IPRange -Value $bData -ErrorAction Stop
			writeLogFile -Category "info" -Message "boundary [$bName] created"
		} catch {
			writeLogFile -Category "info" -Message "boundary [$bName] already exists"
			try {
				$bx = Get-CMBoundary -BoundaryName $bName -ErrorAction SilentlyContinue
				writeLogFile -Category "info" -Message "getting boundary information for $bName"
				$bID = $bx.BoundaryID
				writeLogFile -Category "info" -Message "boundary [$bName] identifier = $bID"
			} catch {
				writeLogFile -Category "error" -Message "unable to create or update boundary: $bName"
				$bID = $null
				break
			}
		}
		if ($bID -and $bGrp) {
			writeLogFile -Category "info" -Message "assigning boundary [$bName] to boundary group: $bGrp"
			try {
				$bg = Get-CMBoundaryGroup -Name $bGrp -ErrorAction SilentlyContinue
				$bgID = $bg.GroupID
				writeLogFile -Category "info" -Message "boundary group identifier = $bgID"
			} catch {
				writeLogFile -Category "error" -Message "unable to obtain boundary group [$bGrp]"
				$bgID = $null
			}
			if ($bgID) {
				try {
					Add-CMBoundaryToGroup -BoundaryId $bx.BoundaryID -BoundaryGroupId $bg.GroupID
					writeLogFile -Category "info" -Message "boundary ($bName) added to boundary group ($bGrp)"
				} catch {
					writeLogFile -Category "error" -Message "oops?"
				}
			}
		} else {
			writeLogFile -Category "info" -Message "oundary [$bName] is not assigned to a boundary group"
		}
	} # foreach
	writeLogFile -Category info -Message "function runtime: $(getTimeOffset $time1)"
	Write-Output $result
}
