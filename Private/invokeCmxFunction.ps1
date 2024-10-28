function invokeCmxFunction {
	[CmdletBinding(SupportsShouldProcess=$True)]
	param (
		[parameter(Mandatory=$True)]
			[ValidateNotNullOrEmpty()]
			[string] $Name,
		[parameter(Mandatory=$False)]
			[string] $Comment=""
	)
	writeLogFile -Category "info" -Message "installation function = $Name"
	switch ($Name) {
		'SQLCONFIG' {
			Write-Host "$Comment" -ForegroundColor Green
			$result = applyCmxSqlConfiguration -DataSet $xmldata
			Write-Verbose "info: exit code = $result"
			setCmxTaskCompleted -KeyName $Name -Value $(Get-Date)
		}
		'WSUSCONFIG' {
			Write-Host "$Comment" -ForegroundColor Green
			$fpath = getCmxWsusUpdatesPath -FolderSet $xmldata.configuration.folders.folder
			if (-not($fpath)) {
				$result = -1
				break
			}
			$result = applyCmxWsusConfiguration -UpdatesFolder $fpath
			Write-Verbose "info: exit code = $result"
			setCmxTaskCompleted -KeyName $Name -Value $(Get-Date)
		}
		'LOCALACCOUNTS' {
			$result = importCmxLocalAccounts -DataSet $xmldata
			if ($result -eq $True) {
				setCmxTaskCompleted -KeyName $Name -Value $(Get-Date)
			}
		}
		default {
			Write-Warning "There is no function mapping for: $Name"
		}
	} # switch
	writeLogFile -Category "info" -Message "[invokeCmxFunction] result = $result"
	Write-Output $result
}
