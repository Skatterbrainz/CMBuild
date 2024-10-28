function invokeCmxPayloadInstaller {
	[CmdletBinding(SupportsShouldProcess=$True)]
	param (
		[parameter(Mandatory=$True)]
			[ValidateNotNullOrEmpty()]
			[string] $Name,
		[parameter(Mandatory=$True)]
			[ValidateNotNullOrEmpty()]
			[string] $SourceFile,
		[parameter(Mandatory=$False)]
			[string] $OptionParams = ""
	)
	writeLogFile -Category "info" -Message "----------------------------------------------------"
	writeLogFile -Category "info" -Message "function: invokeCmxPayloadInstaller"
	writeLogFile -Category "info" -Message "payload name..... $Name"
	writeLogFile -Category "info" -Message "sourcefile....... $SourceFile"
	writeLogFile -Category "info" -Message "input arguments.. $OptionParams"
	
	if (-not(Test-Path $SourceFile)) {
		writeLogFile -Category "error" -Message "source file not found: $SourceFile"
		Write-Output -1
		break
	}
	if ($SourceFile.EndsWith('.msi')) {
		if ($OptionParams -ne "") {
			$ArgList = "/i $SourceFile $OptionParams"
		} else {
			$ArgList = "/i $SourceFile /qb! /norestart"
		}
		$SourceFile = "msiexec.exe"
	} else {
		$ArgList = $OptionParams
	}
	writeLogFile -Category "info" -Message "source file...... $SourceFile"
	writeLogFile -Category "info" -Message "new arguments.... $ArgList"
	$time1 = Get-Date
	$result = 0
	try {
		$p = Start-Process -FilePath $SourceFile -ArgumentList $ArgList -NoNewWindow -Wait -PassThru -ErrorAction Continue
		if ((0,3010,1605,1641,1618,1707).Contains($p.ExitCode)) {
			writeLogFile -Category "info" -Message "aggregating a success code."
			setCmxTaskCompleted -KeyName $Name -Value $(Get-Date)
			$result = 0
		} else {
			writeLogFile -Category "info" -Message "internal : exit code = $($p.ExitCode)"
			$result = $p.ExitCode
		}
	} catch {
		Write-Warning "error: failed to execute installation: $Name"
		Write-Warning "error: $($error[0].Exception)"
		writeLogFile -Category "error" -Message "internal : exit code = -1"
		$result = -1
	}
	if (testPendingReboot) {
		if ($NoReboot) {
			Write-Host "Reboot is required but suppressed" -ForegroundColor Cyan
		} else {
			Write-Host "Reboot will be requested" -ForegroundColor Magenta
		}
	}
	writeLogFile -Category "info" -Message "function runtime = $(getTimeOffset -StartTime $time1)"
	writeLogFile -Category "info" -Message "function result = $result"
	Write-Output $result
}
