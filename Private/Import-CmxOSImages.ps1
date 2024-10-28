function Import-CmxOSImages {
	[CmdletBinding(SupportsShouldProcess=$True)]
	param (
		[parameter(Mandatory=$True)]
		[ValidateNotNullOrEmpty()]
		$DataSet
	)
	Write-Log -Category "info" -Message "------------------------------ Import-CmxOSImages -------------------------------"
	Write-Host "Importing OS images" -ForegroundColor Green
	$result = $True
	$Time1  = Get-Date
	foreach ($item in $DataSet.configuration.cmsite.osimages.osimage | Where-Object {$_.use -eq '1'}) {
		$imageName = $item.name
		$imagePath = $item.path
		$imageDesc = $item.comment
		$imgFolder = $item.folder
		$oldLoc    = Get-Location
		if ($osi = Get-CMOperatingSystemImage -Name "$imageName") {
			Write-Log -Category "info" -Message "operating system image already created"
		} else {
			Set-Location c:
			if (Test-Path $imagePath) {
				Set-Location $oldLoc
				Write-Log -Category "info" -Message "image name: $imageName"
				Write-Log -Category "info" -Message "image path: $imagePath"
				try {
					$osi = New-CMOperatingSystemImage -Name "$imageName" -Path $imagePath -Description "$imageDesc" -ErrorAction SilentlyContinue
					Write-Log -Category "info" -Message "item created successfully"
				} catch {
					Write-Log -Category "error" -Message $_.Exception.Message
					Write-Error $_
					$result = $False
					break
				}
			} else {
				Write-Log -Category "error" -Message "failed to locate image source: $imagePath"
				$result = $False
				break
			}
		}
		Write-Log -Category "info" -Message "moving object to folder: $imgFolder"
		$osi | Move-CMObject -FolderPath $imgFolder | Out-Null
		Write-Verbose "- - - - - - - - - - - - - - - - - - - - - - - - - - - - - -"
	} # foreach
	Write-Log -Category info -Message "function runtime: $(Get-TimeOffset $time1)"
	Write-Output $result
}
