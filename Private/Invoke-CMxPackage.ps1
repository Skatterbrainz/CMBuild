function Invoke-CMxPackage {
    [CmdletBinding(SupportsShouldProcess=$True)]
    param (
        [parameter(Mandatory=$True)]
            [string] $Name,
        [parameter(Mandatory=$True)]
            [string] $PackageType,
        [parameter(Mandatory=$False)]
            [string] $PayloadSource="",
        [parameter(Mandatory=$False)]
            [string] $PayloadFile="",
        [parameter(Mandatory=$False)]
            [string] $PayloadArguments=""
    )
    Write-Log -Category "info" -Message "function: Invoke-CMxPackage"
    Write-Log -Category "info" -Message "package type = $PackageType"
    switch ($PackageType) {
        'feature' {
            Write-Log -Category "info" -Message "installation feature = $Name"
            Write-Host "Installing $pkgComm" -ForegroundColor Green
            $xdata = ($xmldata.configuration.features.feature | 
                Where-Object {$_.name -eq $Name} | 
                    Foreach-Object {$_.innerText}).Split(',')
            $result = Import-CMxServerRoles -RoleName $Name -FeaturesList $xdata -AlternateSource $AltSource
            Write-Log -Category "info" -Message "exit code = $result"
            if ($result -or ($result -eq 0)) { 
                Set-CMxTaskCompleted -KeyName $Name -Value $(Get-Date) 
            }
            else {
                Write-Warning "error: step failure [feature] at: $Name"
                $continue = $False
            }
            break
        }
        'function' {
            $result = Invoke-CMxFunction -Name $Name -Comment $pkgComm
			if (!($result -or ($result -eq 0))) { 
                Write-Warning "error: step failure [function] at: $Name"
                $continue = $False
            }
            break
        }
        'payload' {
            $result = Start-CMxPayload -Name $Name -SourcePath $PayloadSource -PayloadFile $PayloadFile -PayloadArguments $PayloadArguments
            if (!($result -or ($result -eq 0))) { 
                Write-Warning "error: step failure [payload] at: $Name"
                $continue = $False
            }
            break
        }
        default {
            Write-Warning "invalid package type value: $PackageType"
            $continue
            break
        }
    } # switch
    Write-Log -Category "info" -Message "[Invoke-CMxPackage] result = $result"
    Write-Output $result
}
