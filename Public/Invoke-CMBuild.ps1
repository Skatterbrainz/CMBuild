#requires -RunAsAdministrator
#requires -version 5

function Invoke-CMBuild {
	<#
	.SYNOPSIS
	SCCM site server installation script
	.DESCRIPTION
		Yeah, what he said.
	.PARAMETER XmlFile
		Path and Name of XML input file
	.PARAMETER NoCheck
		Skip platform validation restrictions
	.PARAMETER NoReboot
		Suppress reboots until very end
	.PARAMETER Detailed
		Show verbose output
	.PARAMETER ShowMenu
		Choose package items to execute directly from GUI menu
	.PARAMETER Resume
		Indicates a resumed process request
	.EXAMPLE
		Invoke-CMBuild -XmlFile .\cmbuild.xml -Verbose
	.EXAMPLE
		Invoke-CMBuild -XmlFile .\cmbuild.xml -NoCheck -NoReboot -Detailed
	.EXAMPLE
		Invoke-CMBuild -XmlFile .\cmbuild.xml -ShowMenu -Verbose
	.LINK
		https://github.com/Skatterbrainz/CMBuild/blob/master/Docs/Invoke-CMBuild.md
	.NOTES
		Read the associated XML to make sure the path and filename values
		all match up like you need them to.
	#>
	[CmdletBinding(SupportsShouldProcess=$True)]
	param (
		[parameter(Mandatory=$True, HelpMessage="Path or URI of XML input file")]
			[ValidateNotNullOrEmpty()]
			[string] $XmlFile,
		[parameter(Mandatory=$False, HelpMessage="Skip platform validation checking")]
			[switch] $NoCheck,
		[parameter(Mandatory=$False, HelpMessage="Suppress reboots")]
			[switch] $NoReboot,
		[parameter(Mandatory=$False, HelpMessage="Display verbose output")]
			[switch] $Detailed,
		[parameter(Mandatory=$False, HelpMessage="Override control set from XML file")]
			[switch] $ShowMenu,
		[parameter(Mandatory=$False, HelpMessage="Resume from previous unfinished processing")]
			[switch] $Resume
	)
	Write-Host "CMBuild $CmBuildSettings['CMBuildVersion']" -ForegroundColor Cyan
	$ScriptPath = getScriptDirectory
	$RunTime1   = Get-Date
	$CmBuildSettings['tsFile'] = "$CmBuildSettings['LogsFolder']\cm_build`_$CmBuildSettings['ComputerName']`_transaction.log"
	
	try {stop-transcript -ErrorAction SilentlyContinue} catch {}
	try {Start-Transcript -Path $CmBuildSettings['tsFile'] -Force} catch {}

	if ($Resume) {$OpenKey = 'RESUME'} else {$OpenKey = 'BEGIN'}
	writeLogFile -Category "info" -Message "******************* $OpenKey $(Get-Date) *******************"
	writeLogFile -Category "info" -Message "script version = $CmBuildSettings['CMBuildVersion']"

	installCmxPSModules
	
	[xml]$xmldata = getCmxConfigData $XmlFile
	writeLogFile -Category "info" -Message "----------------------------------------------------"
	if ($xmldata.configuration.schemaversion -ge $CmBuildSettings['SchemaVersion']) {
		writeLogFile -Category "info" -Message "xml template schema version is valid"
	} else {
		writeLogFile -Category "info" -Message "xml template schema version is invalid: $($xmldata.configuration.schemaversion)"
		Write-Warning "The specified XML file is not using a current schema version"
		break
	}

	setCmxTaskCompleted -KeyName 'START' -Value $(Get-Date)

	if ($ShowMenu) {
		$controlset = $xmldata.configuration.packages.package | Out-GridView -Title "Select Packages to Run" -PassThru
	} else {
		$controlset = $xmldata.configuration.packages.package | Where-Object {$_.use -eq '1'}
	}

	if ($controlset) {
		$project   = $xmldata.configuration.project
		$AltSource = $xmldata.configuration.sources.source | 
			Where-Object {$_.name -eq 'WIN10'} | 
				Select-Object -ExpandProperty path
		writeLogFile -Category "info" -Message "alternate windows source = $AltSource"
		writeLogFile -Category "info" -Message "----------------------------------------------------"
		writeLogFile -Category "info" -Message "project info....... $($project.comment)"

		if (-not (importCmxFolders -DataSet $xmldata)) {
			Write-Warning "error: failed to create folders (aborting)"
			break
		}
		if (-not (importCmxFiles -DataSet $xmldata)) {
			Write-Warning "error: failed to create files (aborting)"
			break
		}

		Write-Host "Executing project configuration" -ForegroundColor Green

		$null = disableIESC
		$null = setCmxRegKeys -DataSet $xmldata -Order "before"

		writeLogFile -Category "info" -Message "beginning package execution"
		writeLogFile -Category "info" -Message "----------------------------------------------------"
		$continue = $True
		$pkgcount = 0
		foreach ($package in $controlset) {
			if ($continue) {
				$pkgName  = $package.name
				$pkgType  = $package.type 
				$pkgComm  = $package.comment 
				$payload  = $xmldata.configuration.payloads.payload | Where-Object {$_.name -eq $pkgName}
				$pkgSrcX  = $xmldata.configuration.sources.source | Where-Object {$_.name -eq $pkgName}
				$pkgSrc   = $pkgSrcX.path
				$pkgFile  = $payload.file
				$pkgArgs  = $payload.params
				$detRule  = $xmldata.configuration.detections.detect | Where-Object {$_.name -eq $pkgName}
				$detPath  = $detRule.path
				$detType  = $detRule.type
				$depends  = $package.dependson

				writeLogFile -Category "info" -Message "package name.... $pkgName"
				writeLogFile -Category "info" -Message "package type.... $pkgType"
				writeLogFile -Category "info" -Message "package comment. $pkgComm"
				writeLogFile -Category "info" -Message "payload source.. $pkgSrc"
				writeLogFile -Category "info" -Message "payload file.... $pkgFile"
				writeLogFile -Category "info" -Message "payload args.... $pkgArgs"
				writeLogFile -Category "info" -Message "rule type....... $detType"

				if (!(testCmxPackage -PackageName $dependson)) {
					writeLogFile -Category "error" -Message "dependency missing: $depends"
					$continue = $False
					break
				}
				if (($detType -eq "") -or ($detPath -eq "") -or (-not($detPath))) {
					writeLogFile -Category "error" -Message "detection rule is missing for $pkgName (aborting)"
					$continue = $False
					break
				}
				$installed = $False
				$installed = getCmxInstallState -PackageName $pkgName -RuleType $detType -RuleData $detPath
				if ($installed) {
					writeLogFile -Category "info" -Message "install state... $pkgName is INSTALLED"
				} else {
					writeLogFile -Category "info" -Message "install state... $pkgName is NOT INSTALLED"
					$x = invokeCmxPackage -Name $pkgName -PackageType $pkgType -PayloadSource $pkgSrc -PayloadFile $pkgFile -PayloadArguments $pkgArgs
					if ($x -ne 0) {$continue = $False; break}
				}
				$pkgcount += 1
				writeLogFile -Category "info" -Message "----------------------------------------------------"
				if (testPendingReboot) {
					if ($NoReboot) {
						writeLogFile -Category 'info' -Message 'a reboot is required - but NoReboot was requested.'
						Write-Warning "A reboot is required but has been suppressed."
					} else {
						writeLogFile -Category 'info' -Message 'a reboot is requested.'
						invokeCmxRestart -XmlFile $XmlFile
						Write-Warning "A reboot is requested. Reboot now."
						Restart-Computer -Force
						break
					}
				}
			} else {
				Write-Warning "STOP! aborted at step [$pkgName] $(Get-Date)"
				break
			}
		} # foreach

		if (($pkgcount -gt 0) -and ($continue)) {
			$null = setCmxRegKeys -DataSet $xmldata -Order "after"
		}
	}

	Write-Host "Processing finished at $(Get-Date)" -ForegroundColor Green
	$RunTime2 = getTimeOffset -StartTime $RunTime1
	writeLogFile -Category "info" -Message "finished at $(Get-Date) - total runtime = $RunTime2"
	if ((testPendingReboot) -and ($NoReboot)) {
		Write-Host "A REBOOT is REQUIRED" -ForegroundColor Cyan
	}
	Stop-Transcript
}