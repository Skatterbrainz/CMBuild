function startCmxPayload {
	<#
	.SYNOPSIS
	Execute a CMBuild or CMSiteConfig payload ruleset
	
	.DESCRIPTION
	Execute a CMBuild or CMSiteConfig payload ruleset
	
	.PARAMETER Name
	Name of Payload
	
	.PARAMETER SourcePath
	Path of source content to execute
	
	.PARAMETER PayloadFile
	If payload type is a file, this is the path and name of the file
	
	.PARAMETER PayloadArguments
	Optional parameters or switches to pass into the payload executable
	
	.PARAMETER Comment
	Comment read from XML control entry
	#>
	[CmdletBinding()]
	param (
		[parameter(Mandatory=$True)]
			[ValidateNotNullOrEmpty()]
			[string] $Name,
		[parameter(Mandatory=$True)]
			[ValidateNotNullOrEmpty()]    
			[string] $SourcePath,
		[parameter(Mandatory=$True)]
			[ValidateNotNullOrEmpty()]
			[string] $PayloadFile,
		[parameter(Mandatory=$False)]
			[string] $PayloadArguments = "",
		[parameter(Mandatory=$False)]
			[string] $Comment = ""
	)
	Write-Host "Installing payload: $Name" -ForegroundColor Green
	writeLogFile -Category "info" -Message "installation payload = $Name"
	writeLogFile -Category "info" -Message "comment = $Comment"
	switch ($pkgName) {
		'CONFIGMGR' {
			Write-Host "Tip: Monitor C:\ConfigMgrSetup.log for progress" -ForegroundColor Green
			$runFile = "$SourcePath\$PayloadFile"
			$x = invokeCmxPayloadInstaller -Name $Name -SourceFile $runFile -OptionParams $PayloadArguments
			writeLogFile -Category "info" -Message "exit code = $x"
		}
		'SQLSERVER' {
			Write-Host "Tip: Monitor $($env:PROGRAMFILES)\Microsoft SQL Server\130\Setup Bootstrap\Logs\summary.txt for progress" -ForegroundColor Green
			$runFile = "$SourcePath\$PayloadFile"
			$x = invokeCmxPayloadInstaller -Name $Name -SourceFile $runFile -OptionParams $PayloadArguments
			writeLogFile -Category "info" -Message "exit code = $x"
		}
		'SERVERROLES' {
			$runFile = "$((Get-ChildItem $xmlfile).DirectoryName)\$PayloadFile"
			$x = importCmxServerRolesFile -PackageName $Name -PackageFile $runFile
			writeLogFile -Category "info" -Message "exit code = $x"
		}
		default {
			$runFile = "$SourcePath\$PayloadFile"
			$x = invokeCmxPayloadInstaller -Name $Name -SourceFile $runFile -OptionParams $PayloadArguments
			writeLogFile -Category "info" -Message "exit code = $x"
		}
	} # switch
	writeLogFile -Category "info" -Message "[Invoke-CMxPayload] result = $result"
	Write-Output $x
} 
