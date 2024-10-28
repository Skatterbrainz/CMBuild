function importCmxServerRoles {
	[CmdletBinding(SupportsShouldProcess=$True)]
	param (
		[parameter(Mandatory=$True)]
			[ValidateNotNullOrEmpty()]
			[string] $RoleName,
		[parameter(Mandatory=$True)]
			[ValidateNotNullOrEmpty()]
			[string[]] $FeaturesList,
		[parameter(Mandatory=$False)]
			[string] $AlternateSource = "",
		[parameter(Mandatory=$False)]
			[string] $LogFile = "serverroles.log"
	)
	Write-Host "Installing Windows Server Roles and Features" -ForegroundColor Green
	$timex  = Get-Date
	$result = 0
	$FeaturesList | 
	Foreach-Object {
		$FeatureCode = $_
		writeLogFile -Category "info" -Message "installing feature: $FeatureCode"
		$timez = Get-Date
		if ($AlternateSource -ne "") {
			writeLogFile -Category "info" -Message "referencing alternate windows content source"
			try {
				$output   = Install-WindowsFeature -Name $FeatureCode -LogPath "$CmBuildSettings['LogsFolder']\$LogFile" -Source "$AlternateSource\sources\sxs"
				$exitcode = $output.ExitCode.Value__
				if ($CmBuildSettings['SuccessCodes'].Contains($exitcode)) {
					$result = 0
				} else {
					writeLogFile -Category "error" -Message "installation of $FeatureCode failed with exit code: $exitcode"
					$result = -1
				}
			} catch {
				writeLogFile -Category "error" -Message "installation of $FeatureCode failed horribly!"
				writeLogFile -Category "error" -Message $_.Exception.Message
				$result = -2
			}
			writeLogFile -Category "info" -Message "$FeatureCode exitcode: $exitcode"
		} else {
			try {
				$output   = Install-WindowsFeature -Name $FeatureCode -LogPath "$CmBuildSettings['LogsFolder']\$LogFile"
				$exitcode = $output.ExitCode.Value__
				if ($CmBuildSettings['SuccessCodes'].Contains($exitcode)) {
					$result = 0
				} else {
					writeLogFile -Category "error" -Message "installation of $FeatureCode failed with exit code: $exitcode"
					$result = -1
				}
			} catch {
				writeLogFile -Category "error" -Message "installation of $FeatureCode failed horribly!"
				writeLogFile -Category "error" -Message $_.Exception.Message
				$result = -2
			}
			writeLogFile -Category "info" -Message "$FeatureCode exitcode: $exitcode"
		} # if
		writeLogFile -Category "info" -Message "internal : $FeatureCode runtime = $(getTimeOffset -StartTime $timez)"
		writeLogFile -Category "info" -Message "- - - - - - - - - - - - - - - - - - - - - - - - - - -"
	} # foreach-object

	writeLogFile -Category "info" -Message "result = $result"
	if ($result -eq 0) {
		setCmxTaskCompleted -KeyName 'SERVERROLES' -Value $(Get-Date)
	}
	writeLogFile -Category "info" -Message "function runtime = $(getTimeOffset -StartTime $timex)"
	Write-Output $result
}
