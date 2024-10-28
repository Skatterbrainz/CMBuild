function importCmxServerRolesFile {
	[CmdletBinding(SupportsShouldProcess=$True)]
	param (
		[parameter(Mandatory=$True)]
			[ValidateNotNullOrEmpty()]
			[string] $PackageName,
		[parameter(Mandatory=$True)]
			[ValidateNotNullOrEmpty()]
			[string] $PackageFile,
		[parameter(Mandatory=$False)]
			[string] $LogFile = "serverrolesfile.log"
	)
	Write-Host "Installing Windows Server Roles and Features" -ForegroundColor Green
	if (Test-Path $PackageFile) {
		if ($AltSource -ne "") {
			writeLogFile -Category "info" -Message "referencing alternate windows content source: $AltSource"
			try {
				writeLogFile -Category "info" -Message "installing features from configuration file: $PackageFile using alternate source"
				$result = Install-WindowsFeature -ConfigurationFilePath $PackageFile -LogPath "$CmBuildSettings['LogsFolder']\$LogFile" -Source "$AltSource\sources\sxs" -ErrorAction Continue
				if ($CmBuildSettings['SuccessCodes'].Contains($result.ExitCode.Value__)) {
					$result = 0
					setCmxTaskCompleted -KeyName $PackageName -Value $(Get-Date)
					writeLogFile -Category "info" -Message "installion was successful"
				} else {
					writeLogFile -Category "error" -Message "failed to install features!"
					writeLogFile -Category "error" -Message "result: $($result.ExitCode.Value__)"
					$result = -1
				}
			} catch {
				writeLogFile -Category "error" -Message $_.Exception.Message
				break
			}
		} else {
			try {
				writeLogFile -Category "info" -Message "installing features from configuration file: $PackageFile"
				$result = Install-WindowsFeature -ConfigurationFilePath $PackageFile -LogPath "$CmBuildSettings['LogsFolder']\$LogFile" -ErrorAction Continue
				if ($CmBuildSettings['SuccessCodes'].Contains($result.ExitCode.Value__)) {
					$result = 0
					setCmxTaskCompleted -KeyName $PackageName -Value $(Get-Date)
					writeLogFile -Category "info" -Message "installion was successful"
				} else {
					writeLogFile -Category "error" -Message "failed to install features!"
					writeLogFile -Category "error" -Message "result: $($result.ExitCode.Value__)"
					$result = -1
				}
			} catch {
				writeLogFile -Category "error" -Message "failed to install features!"
				writeLogFile -Category "error" -Message $_.Exception.Message
			}
		}
	} else {
		Write-Warning "ERROR: role configuration file $PackageFile was not found!"
	}
	Write-Output $result
}

