function testCmxPackage {
	param (
		[parameter(Mandatory=$False)]
		[string] $PackageName = ""
	)
	writeLogFile -Category "info" -Message "[function: testCmxPackage]"
	$detRule = $detects | Where-Object {$_.name -eq $PackageName}
	if (($detRule) -and ($detRule -ne "")) {
		Write-Output (Test-Path $detRule)
	} else {
		Write-Output $True
	}
}
