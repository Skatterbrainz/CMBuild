function Invoke-CMBuildFunction {
    [CmdletBinding()]
    param (
        [parameter(Mandatory=$True, HelpMessage="Function Name")]
            [ValidateNotNullOrEmpty()]
            [string] $Name,
        [parameter(Mandatory=$False, HelpMessage="Comment string")]
            [string] $Comment=""
    )
    Write-Log -Category "info" -Message "installation function = $Name"
    switch ($Name) {
        'SQLCONFIG' {
            Write-Host "$Comment" -ForegroundColor Green
            $result = Invoke-CMxSqlConfiguration -DataSet $xmldata
            Write-Verbose "info: exit code = $result"
            Set-CMBuildTaskCompleted -KeyName $Name -Value $(Get-Date)
            Invoke-CMxRestartRequest
            break
        }
        'WSUSCONFIG' {
            Write-Host "$Comment" -ForegroundColor Green
            $fpath = Get-CMBuildWSUSUpdatesPath -FolderSet $xmldata.configuration.folders.folder
            if (-not($fpath)) {
                $result = -1
                break
            }
            $result = Import-CMBuildWsusConfiguration -UpdatesFolder $fpath
            Write-Verbose "info: exit code = $result"
            Set-CMBuildTaskCompleted -KeyName $Name -Value $(Get-Date)
            Invoke-CMxRestartRequest
            break
        }
		'LOCALACCOUNTS' {
			$result = Import-CMBuildLocalAccounts -DataSet $xmldata
			if ($result -eq $True) {
				Set-CMBuildTaskCompleted -KeyName $Name -Value $(Get-Date)
			}
			break
		}
        default {
            Write-Warning "There is no function mapping for: $Name"
            break
        }
    } # switch
    Write-Log -Category "info" -Message "[Invoke-CMxFunction] result = $result"
    Write-Output $result
}
