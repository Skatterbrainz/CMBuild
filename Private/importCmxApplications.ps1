function importCmxApplications {
	[CmdletBinding(SupportsShouldProcess=$True)]
	param (
		[parameter(Mandatory=$True)]
		[ValidateNotNullOrEmpty()]
		$DataSet
	)
	writeLogFile -Category "info" -Message "------------------------------ importCmxApplications -------------------------------"
	Write-Host "Importing applications" -ForegroundColor Green
	$result = $true
	$Time1  = Get-Date
	$PSDefaultParameterValues = @{
		"get-cimclass:namespace"="Root\SMS\site_$sitecode"
		"get-cimclass:computername"="$CmBuildSettings['ComputerName']"
		"get-cimInstance:computername"="$CmBuildSettings['ComputerName']"
		"get-ciminstance:namespace"="Root\SMS\site_$sitecode"}
	foreach ($item in $DataSet.configuration.cmsite.applications.application | Where-Object {$_.use -eq '1'}) {
		$timex = Get-Date
		$appName   = $item.name 
		$appComm   = $item.comment
		$appPub    = $item.publisher
		$appVer    = $item.version
		$appCats   = $item.categories
		$appKeys   = $item.keywords
		$appFolder = $item.folder

		writeLogFile -Category "info" -Message "app name......... $appName"
		writeLogFile -Category "info" -Message "app publisher.... $appPub"
		writeLogFile -Category "info" -Message "app comment...... $appComm"
		writeLogFile -Category "info" -Message "app version...... $appVer"
		writeLogFile -Category "info" -Message "app categories... $appCats"
		writeLogFile -Category "info" -Message "app keywords..... $appKeys"
		writeLogFile -Category "info" -Message "app folder....... $appFolder"

		try {
			$app = New-CMApplication -Name "$appName" -Description "appComm" -SoftwareVersion "1.0" -AutoInstall $true -Publisher $appPub -ErrorAction SilentlyContinue
			writeLogFile -Category "info" -Message "application created successfully"
		} catch {
			if ($_.Exception.Message -like "*already exists*") {
				writeLogFile -Category "info" -Message "item already exists"
				$app = Get-CMApplication -Name $appName
			} else {
				writeLogFile -Category error -Message $_.Exception.Message
				$result = $False
				$app = $null
			}
		}
		if ($app) {
			if ($appKeys.Length -gt 0) {
				writeLogFile -Category "info" -Message "assigning keywords: $appKeys"
				try {
					$app | Set-CMApplication -Keyword $appKeys -ErrorAction SilentlyContinue
					writeLogFile -Category info -Message "keywords have been assigned successfully"
				} catch {
					writeLogFile -Category "info" -Message "the object is locked by an evil person"
				}
			}
			if ($appCats.Length -gt 0) {
				writeLogFile -Category "info" -Message "assigning categories: $appCats"
				try {
					$app | Set-CMApplication -AppCategories $appCats.Split(',') -ErrorAction SilentlyContinue
					writeLogFile -Category info -Message "categories have been assigned successfully."
				} catch {
					if ($_.Exception.Message -contains '*DeniedLockAlreadyAssigned*') {
						writeLogFile -Category "error" -Message "some idiot has the object open in a console and locked it."
					} else {
						Write-Error "barf-o-matic - your code just puked up a buick!"
					}
				}
			}
			if ($appFolder.Length -gt 0) {
				writeLogFile -Category "info" -Message "Moving application object to folder: $appFolder"
				#$app = Get-CMApplication -Name $appName
				$app | Move-CMObject -FolderPath "Application\$appFolder" | Out-Null
			}
			foreach ($depType in $appSet.deptypes.deptype) {
				$depName   = $depType.name
				$depSource = $depType.source
				$depOpts   = $depType.options
				$depData   = $depType.detect
				$uninst    = $depType.uninstall
				$depComm   = $depType.comment
				$reqts     = $depType.requires
				$depCPU    = $depType.platform
				$depPath   = Split-Path -Path $depSource
				$depFile   = Split-Path -Path $depSource -Leaf
				$program   = "$depFile $depOpts"

				writeLogFile -Category "info" -Message "dep name........ $depName"
				writeLogFile -Category "info" -Message "dep comment..... $depComm"
				writeLogFile -Category "info" -Message "dep Source...... $depSource"
				writeLogFile -Category "info" -Message "dep options..... $depOpts"
				writeLogFile -Category "info" -Message "dep detect...... $depData"
				writeLogFile -Category "info" -Message "dep uninstall... $uninst"
				writeLogFile -Category "info" -Message "dep reqts....... $reqts"
				writeLogFile -Category "info" -Message "dep path........ $depPath"
				writeLogFile -Category "info" -Message "dep file........ $depFile"
				writeLogFile -Category "info" -Message "dep program..... $program"
				writeLogFile -Category "info" -Message "dep platform.... $depCPU"

				if ($depOpts -eq 'auto') {
					writeLogFile -Category "info" -Message "installer type: msi"
					try {
						if ($depCPU -eq '32') {
							$null = Add-CMDeploymentType -ApplicationName $appName -AutoIdentifyFromInstallationFile -ForceForUnknownPublisher $true -InstallationFileLocation $depSource -MsiInstaller -DeploymentTypeName $depName -Force32BitInstaller $True
						} else {
							$null = Add-CMDeploymentType -ApplicationName $appName -AutoIdentifyFromInstallationFile -ForceForUnknownPublisher $true -InstallationFileLocation $depSource -MsiInstaller -DeploymentTypeName $depName
						}
						writeLogFile -Category "info" -Message "deployment type created"
					} catch {
						if ($_.Exception.Message -like '*already exists.') {
							writeLogFile -Category "info" -Message "deployment type already exists"
						} else {
							Write-Error $_
						}
					}
				} else {
					if ($depData.StartsWith("registry")) {
						writeLogFile -Category "info" -Message "detection type: registry"
						# "registry:HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\Notepad++,DisplayVersion,-ge,7.5"
						$depDetect  = $depData.Split(":")[1]
						$depRuleSet = $depDetect.Split(",")
						$ruleKey    = $depRuleSet[0] # "HKLM:\...."
						$ruleKey    = $ruleKey.Substring(5)
						$ruleVal    = $depRuleSet[1] # "DisplayVersion"
						$ruleChk    = $depRuleSet[2] # "-ge"
						$ruleData   = $depRuleSet[3] # "7.5"
						$scriptDetection = @"
try {
	`$Reg = [Microsoft.Win32.RegistryKey]::OpenBaseKey([Microsoft.Win32.RegistryHive]::LocalMachine, "default")
	`$key = `$reg.OpenSubKey("$ruleKey")
	`$val = `$key.GetValue("$ruleVal")
	if (`$val $ruleChk "$ruleData") {Write-Host 'Installed'}
}
catch {}
"@
					} elseif (($depData.StartsWith("file")) -or ($depData.StartsWith("folder"))) {
						# "file:\Program Files\Something\file.exe"
						# "folder:\Program Files\Something"
						writeLogFile -Category "info" -Message "detection type: file or folder"
						$depDetect  = $depData.Split(":")[1]
						$depRuleSet = $depDetect.Split(",")
						$ruleKey    = $depRuleSet[0] # "\Program Files\Something\file.exe"
						$ruleKey    = 'C:'+$ruleKey  # "C:\Program Files\Something\file.exe"
						$ruleVal    = $null
						$ruleChk    = $null
						$ruleData   = $null
						$scriptDetection = "if (Test-Path `"$ruleKey`") { Write-Host 'Installed' }"
					}
					writeLogFile -Category "info" -Message "rule: $scriptDetection"
					if ($uninst.length -gt 0) {
						$DeploymentTypeHash = @{
							ManualSpecifyDeploymentType        = $true
							ApplicationName                    = "$appName"
							DeploymentTypeName                 = "$DepName"
							DetectDeploymentTypeByCustomScript = $true
							ScriptInstaller                    = $true
							ScriptType                         = 'PowerShell'
							ScriptContent                      = $scriptDetection
							AdministratorComment               = "$depComm"
							ContentLocation                    = "$depPath"
							InstallationProgram                = "$program"
							UninstallProgram                   = "$uninst"
							RequiresUserInteraction            = $false
							InstallationBehaviorType           = 'InstallForSystem'
							InstallationProgramVisibility      = 'Hidden'
						}
					} else {
						$DeploymentTypeHash = @{
							ManualSpecifyDeploymentType        = $true
							ApplicationName                    = "$appName"
							DeploymentTypeName                 = "$DepName"
							DetectDeploymentTypeByCustomScript = $true
							ScriptInstaller                    = $true
							ScriptType                         = 'PowerShell'
							ScriptContent                      = $scriptDetection
							AdministratorComment               = "$depComm"
							ContentLocation                    = "$depPath"
							InstallationProgram                = "$program"
							RequiresUserInteraction            = $false
							InstallationBehaviorType           = 'InstallForSystem'
							InstallationProgramVisibility      = 'Hidden'
						}
					}
					writeLogFile -Category "info" -Message "Adding Deployment Type"

					try {
						if ($depCPU -eq '32') {
							$null = Add-CMDeploymentType @DeploymentTypeHash -EnableBranchCache $True -Force32BitInstaller $True
						} else {
							$null = Add-CMDeploymentType @DeploymentTypeHash -EnableBranchCache $True
						}
						writeLogFile -Category "info" -Message "deployment type created"
					} catch {
						if ($_.Exception.Message -like '*already exists.') {
							writeLogFile -Category "info" -Message "deployment type already exists: $depName"
						} else {
							Write-Error $_.Exception.Message
						}
					}
				} # if
			} # foreach - deployment type
			writeLogFile -Category "info" -Message "- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -"
		} # if
		writeLogFile -Category info -Message "task runtime: $(getTimeOffset $timex)"
	} # foreach - application
	writeLogFile -Category info -Message "function runtime: $(getTimeOffset $time1)"
	Write-Output $result
}
