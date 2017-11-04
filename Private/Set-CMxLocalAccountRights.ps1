<#
.NOTES
	reference: http://get-carbon.org/Grant-Privilege.html
#>

function Set-CMxLocalAccountRights {
	param (
		[parameter(Mandatory=$True)]
			[ValidateNotNullOrEmpty()]
			[string] $UserName,
		[parameter(Mandatory=$True)]
			[ValidateNotNullOrEmpty()]
			[string] $Privileges
	)
	Write-Log -Category "info" -Message "Set-CMxServiceLogonRights: $UserName"
	[array]$privs = Get-Privilege -Identity $UserName
	$result = $False
	if ($privs.Count -gt 0) {
		foreach ($right in $Privileges.Split(',')) {
			if ($privs -contains $right) {
				Write-Log -Category "info" -Message "$right, already granted to: $UserName"
				$result = $True
			}
			else {
				Write-Log -Category "info" -Message "granting: $right, to: $UserName"
				Grant-Privilege -Identity $UserName -Privilege $right
			}
		} # foreach
	}
	else {
		foreach ($right in $Privileges.Split(',')) {
			Write-Log -Category "info" -Message "granting: $right, to: $UserName"
			Grant-Privilege -Identity $UserName -Privilege $right
		} # foreach
	}
	Write-Output $result
}
