function Invoke-CMxFunction {
	[CmdletBinding(SupportsShouldProcess=$True)]
	param (
		[parameter(Mandatory=$True)]
			[ValidateNotNullOrEmpty()]
			[string] $Name,
		[parameter(Mandatory=$False)]
			[string] $Comment=""
	)
	Write-Log -Category "info" -Message "installation function = $Name"
	switch ($Name) {
		'SQLCONFIG' {
			Write-Host "$Comment" -ForegroundColor Green
			$result = Invoke-CMxSqlConfiguration -DataSet $xmldata
			Write-Verbose "info: exit code = $result"
			Set-CMxTaskCompleted -KeyName $Name -Value $(Get-Date)
		}
		'WSUSCONFIG' {
			Write-Host "$Comment" -ForegroundColor Green
			$fpath = Get-CmxWsusUpdatesPath -FolderSet $xmldata.configuration.folders.folder
			if (-not($fpath)) {
				$result = -1
				break
			}
			$result = Invoke-CMxWsusConfiguration -UpdatesFolder $fpath
			Write-Verbose "info: exit code = $result"
			Set-CMxTaskCompleted -KeyName $Name -Value $(Get-Date)
		}
		'LOCALACCOUNTS' {
			$result = Import-CMxLocalAccounts -DataSet $xmldata
			if ($result -eq $True) {
				Set-CMxTaskCompleted -KeyName $Name -Value $(Get-Date)
			}
		}
		default {
			Write-Warning "There is no function mapping for: $Name"
		}
	} # switch
	Write-Log -Category "info" -Message "[Invoke-CMxFunction] result = $result"
	Write-Output $result
}
