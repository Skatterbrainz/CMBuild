function Get-ScriptDirectory {
    $Invocation = (Get-Variable MyInvocation -Scope 1).Value
    try {
		Write-Output $(Split-Path $Invocation.MyCommand.Path)
	}
	catch {
		Write-Output $pwd
	}
}
