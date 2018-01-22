function Import-CmxAccounts {
	<#
	.SYNOPSIS
	Create ConfigMgr Security Accounts
	
	.DESCRIPTION
	Create ConfigMgr Security Accounts from XML input data
	
	.PARAMETER DataSet
	XML data set
	
	.EXAMPLE
	Import-CmxAccounts -DataSet $xmlData
	
	.NOTES
	...
	#>
    [CmdletBinding()]
    param (
        [parameter(Mandatory=$True, HelpMessage="XML Data Set")]
        [ValidateNotNullOrEmpty()]
        [xml] $DataSet
    )
	Write-Log -Category "info" -Message "------------------------------ Import-CmxAccounts -------------------------------" -LogFile $logfile
    Write-Host "Configuring accounts" -ForegroundColor Green
    $result = $true
    $time1  = Get-Date
    foreach ($item in $DataSet.configuration.cmsite.accounts.account | Where-Object {$_.use -eq '1'}) {
        $acctName = $item.name
		$acctPwd  = $item.password
		if ($domain -and ($domain.Length -gt 0)) {
			$accountName = $acctName -replace '@DOMAIN@', $domain
		}
		else {
			$accountName = $acctName
		}
		Write-Log -Category "info" -Message "account: $accountName" -LogFile $logfile
        if (Get-CMAccount -UserName $accountName) {
			Write-Log -Category "info" -Message "account already created" -LogFile $logfile
		}
		else {
			if (Test-CMxAdUser -UserName $accountName) {
				try {
					$pwd = ConvertTo-SecureString -String $acctPwd -AsPlainText -Force
					New-CMAccount -UserName $acctName -Password $pwd -SiteCode $sitecode | Out-Null
					Write-Log -Category "info" -Message "account added successfully: $accountName" -LogFile $logfile
				}
				catch {
					Write-Log -Category "error" -Message $_.Exception.Message -Severity 3 -LogFile $logfile
					$Result = $False
					break
				}
			}
			else {
				Write-Log -Category "error" -Message "account not found in domain: $accountName" -Severity 3 -LogFile $logfile
				$result = $False
				break
			}
        }
        Write-Verbose "- - - - - - - - - - - - - - - - - - - - - - - - - - - - - -" -LogFile $logfile
    } # foreach
    Write-Log -Category info -Message "function runtime: $(Get-TimeOffset $time1)" -LogFile $logfile
    Write-Output $result
}
