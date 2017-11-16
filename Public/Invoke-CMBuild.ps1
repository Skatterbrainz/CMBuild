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
	.NOTES
		1.0.6 - 11/16/2017 - David Stein

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
	Write-Host "CMBuild $CMBuildVersion" -ForegroundColor Cyan
	$ScriptPath = Get-ScriptDirectory
	$RunTime1   = Get-Date
	$tsFile     = "$LogsFolder\cm_build`_$HostName`_transaction.log"
	
	try {stop-transcript -ErrorAction SilentlyContinue} catch {}
	try {Start-Transcript -Path $tsFile -Force} catch {}

	if ($Resume) {$OpenKey = 'RESUME'} else {$OpenKey = 'BEGIN'}
	Write-Log -Category "info" -Message "******************* $OpenKey $(Get-Date) *******************"
	Write-Log -Category "info" -Message "script version = $CMBuildVersion"

	Install-CMBuildModules
	
	[xml]$xmldata = Get-CMxConfigData $XmlFile
	Write-Log -Category "info" -Message "----------------------------------------------------"
	if ($xmldata.configuration.schemaversion -ge $SchemaVersion) {
		Write-Log -Category "info" -Message "xml template schema version is valid"
	}
	else {
		Write-Log -Category "info" -Message "xml template schema version is invalid: $($xmldata.configuration.schemaversion)"
		Write-Warning "The specified XML file is not using a current schema version"
		break
	}

	Set-CMxTaskCompleted -KeyName 'START' -Value $(Get-Date)

	if ($ShowMenu) {
		$controlset = $xmldata.configuration.packages.package | Out-GridView -Title "Select Packages to Run" -PassThru
	}
	else {
		$controlset = $xmldata.configuration.packages.package | Where-Object {$_.use -eq '1'}
	}

	if ($controlset) {
		$project   = $xmldata.configuration.project
		$AltSource = $xmldata.configuration.sources.source | 
			Where-Object {$_.name -eq 'WIN10'} | 
				Select-Object -ExpandProperty path
		Write-Log -Category "info" -Message "alternate windows source = $AltSource"
		Write-Log -Category "info" -Message "----------------------------------------------------"
		Write-Log -Category "info" -Message "project info....... $($project.comment)"

		if (-not (Import-CMxFolders -DataSet $xmldata)) {
			Write-Warning "error: failed to create folders (aborting)"
			break
		}
		if (-not (Import-CMxFiles -DataSet $xmldata)) {
			Write-Warning "error: failed to create files (aborting)"
			break
		}

		Write-Host "Executing project configuration" -ForegroundColor Green

		Disable-InternetExplorerESC | Out-Null
		Set-CMxRegKeys -DataSet $xmldata -Order "before" | Out-Null

		Write-Log -Category "info" -Message "beginning package execution"
		Write-Log -Category "info" -Message "----------------------------------------------------"
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

				Write-Log -Category "info" -Message "package name.... $pkgName"
				Write-Log -Category "info" -Message "package type.... $pkgType"
				Write-Log -Category "info" -Message "package comment. $pkgComm"
				Write-Log -Category "info" -Message "payload source.. $pkgSrc"
				Write-Log -Category "info" -Message "payload file.... $pkgFile"
				Write-Log -Category "info" -Message "payload args.... $pkgArgs"
				Write-Log -Category "info" -Message "rule type....... $detType"

				if (!(Test-CMxPackage -PackageName $dependson)) {
					Write-Log -Category "error" -Message "dependency missing: $depends"
					$continue = $False
					break
				}
				if (($detType -eq "") -or ($detPath -eq "") -or (-not($detPath))) {
					Write-Log -Category "error" -Message "detection rule is missing for $pkgName (aborting)"
					$continue = $False
					break
				}
				$installed = $False
				$installed = Get-CMxInstallState -PackageName $pkgName -RuleType $detType -RuleData $detPath
				if ($installed) {
					Write-Log -Category "info" -Message "install state... $pkgName is INSTALLED"
				}
				else {
					Write-Log -Category "info" -Message "install state... $pkgName is NOT INSTALLED"
					$x = Invoke-CMxPackage -Name $pkgName -PackageType $pkgType -PayloadSource $pkgSrc -PayloadFile $pkgFile -PayloadArguments $pkgArgs
					if ($x -ne 0) {$continue = $False; break}
				}
				$pkgcount += 1
				Write-Log -Category "info" -Message "----------------------------------------------------"
				if (Test-PendingReboot) {
					if ($NoReboot) {
						Write-Log -Category 'info' -Message 'a reboot is required - but NoReboot was requested.'
						Write-Warning "A reboot is required but has been suppressed."
					}
					else {
						Write-Log -Category 'info' -Message 'a reboot is requested.'
						Invoke-CMxRestart -XmlFile $XmlFile
						Write-Warning "A reboot is requested. Reboot now."
						Restart-Computer -Force
						break
					}
				}
			}
			else {
				Write-Warning "STOP! aborted at step [$pkgName] $(Get-Date)"
				break
			}
		} # foreach

		if (($pkgcount -gt 0) -and ($continue)) {
			Set-CMxRegKeys -DataSet $xmldata -Order "after" | Out-Null
		}
	}

	Write-Host "Processing finished at $(Get-Date)" -ForegroundColor Green
	$RunTime2 = Get-TimeOffset -StartTime $RunTime1
	Write-Log -Category "info" -Message "finished at $(Get-Date) - total runtime = $RunTime2"
	if ((Test-PendingReboot) -and ($NoReboot)) {
		Write-Host "A REBOOT is REQUIRED" -ForegroundColor Cyan
	}
	Stop-Transcript
}

Export-ModuleMember -Function Invoke-CMBuild