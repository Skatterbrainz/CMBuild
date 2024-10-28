function applyCmxLocalAccountRights {
	<#
	.SYNOPSIS
	Configure Local User Rights
	
	.DESCRIPTION
	Configure Local User Account Security Access Rights
	
	.PARAMETER UserName
	Name of local user account
	
	.PARAMETER Privileges
	Security privileges
	
	.EXAMPLE
	applyCmxLocalAccountRights -UserName "sccmadmin" -Privileges 'SeServiceLogonRight'
	
	.NOTES
	reference: http://get-carbon.org/Grant-Privilege.html
	#>
	param (
		[parameter(Mandatory=$True, HelpMessage="User Account Name")]
			[ValidateNotNullOrEmpty()]
			[string] $UserName,
		[parameter(Mandatory=$True, HelpMessage="Privilege Identifier")]
			[ValidateNotNullOrEmpty()]
			[string] $Privileges
	)
	writeLogFile -Category "info" -Message "Set-CMxServiceLogonRights: $UserName"
	[array]$privs = Get-Privilege -Identity $UserName
	$result = $False
	if ($privs.Count -gt 0) {
		foreach ($right in $Privileges.Split(',')) {
			if ($privs -contains $right) {
				writeLogFile -Category "info" -Message "$right, already granted to: $UserName"
				$result = $True
			} else {
				writeLogFile -Category "info" -Message "granting: $right, to: $UserName"
				Grant-Privilege -Identity $UserName -Privilege $right
			}
		} # foreach
	} else {
		foreach ($right in $Privileges.Split(',')) {
			writeLogFile -Category "info" -Message "granting: $right, to: $UserName"
			Grant-Privilege -Identity $UserName -Privilege $right
		} # foreach
	}
	Write-Output $result
}
