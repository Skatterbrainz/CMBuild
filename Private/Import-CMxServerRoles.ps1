function Import-CMxServerRoles {
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
		Write-Log -Category "info" -Message "installing feature: $FeatureCode"
		$timez = Get-Date
		if ($AlternateSource -ne "") {
			Write-Log -Category "info" -Message "referencing alternate windows content source"
			try {
				$output   = Install-WindowsFeature -Name $FeatureCode -LogPath "$LogsFolder\$LogFile" -Source "$AlternateSource\sources\sxs"
				$exitcode = $output.ExitCode.Value__
				if ($successcodes.Contains($exitcode)) {
					$result = 0
				} else {
					Write-Log -Category "error" -Message "installation of $FeatureCode failed with exit code: $exitcode"
					$result = -1
				}
			} catch {
				Write-Log -Category "error" -Message "installation of $FeatureCode failed horribly!"
				Write-Log -Category "error" -Message $_.Exception.Message
				$result = -2
			}
			Write-Log -Category "info" -Message "$FeatureCode exitcode: $exitcode"
		} else {
			try {
				$output   = Install-WindowsFeature -Name $FeatureCode -LogPath "$LogsFolder\$LogFile"
				$exitcode = $output.ExitCode.Value__
				if ($successcodes.Contains($exitcode)) {
					$result = 0
				} else {
					Write-Log -Category "error" -Message "installation of $FeatureCode failed with exit code: $exitcode"
					$result = -1
				}
			} catch {
				Write-Log -Category "error" -Message "installation of $FeatureCode failed horribly!"
				Write-Log -Category "error" -Message $_.Exception.Message
				$result = -2
			}
			Write-Log -Category "info" -Message "$FeatureCode exitcode: $exitcode"
		} # if
		Write-Log -Category "info" -Message "internal : $FeatureCode runtime = $(Get-TimeOffset -StartTime $timez)"
		Write-Log -Category "info" -Message "- - - - - - - - - - - - - - - - - - - - - - - - - - -"
	} # foreach-object

	Write-Log -Category "info" -Message "result = $result"
	if ($result -eq 0) {
		Set-CMxTaskCompleted -KeyName 'SERVERROLES' -Value $(Get-Date)
	}
	Write-Log -Category "info" -Message "function runtime = $(Get-TimeOffset -StartTime $timex)"
	Write-Output $result
}
