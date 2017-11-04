function Import-CMxServerRolesFile {
    [CmdletBinding(SupportsShouldProcess=$True)]
    param (
        [parameter(Mandatory=$True)]
            [ValidateNotNullOrEmpty()]
            [string] $PackageName,
        [parameter(Mandatory=$True)]
            [ValidateNotNullOrEmpty()]
            [string] $PackageFile,
        [parameter(Mandatory=$False)]
            [string] $LogFile = "serverrolesfile.log"
    )
    Write-Host "Installing Windows Server Roles and Features" -ForegroundColor Green
    if (Test-Path $PackageFile) {
        if ($AltSource -ne "") {
            Write-Log -Category "info" -Message "referencing alternate windows content source: $AltSource"
            try {
                Write-Log -Category "info" -Message "installing features from configuration file: $PackageFile using alternate source"
                $result = Install-WindowsFeature -ConfigurationFilePath $PackageFile -LogPath "$LogsFolder\$LogFile" -Source "$AltSource\sources\sxs" -ErrorAction Continue
                if ($successcodes.Contains($result.ExitCode.Value__)) {
                    $result = 0
                    Set-CMxTaskCompleted -KeyName $PackageName -Value $(Get-Date)
                    Write-Log -Category "info" -Message "installion was successful"
                }
                else {
                    Write-Log -Category "error" -Message "failed to install features!"
                    Write-Log -Category "error" -Message "result: $($result.ExitCode.Value__)"
                    $result = -1
                }
            }
            catch {
                Write-Log -Category "error" -Message $_.Exception.Message
                break
            }
        }
        else {
            try {
                Write-Log -Category "info" -Message "installing features from configuration file: $PackageFile"
                $result = Install-WindowsFeature -ConfigurationFilePath $PackageFile -LogPath "$LogsFolder\$LogFile" -ErrorAction Continue | Out-Null
                if ($successcodes.Contains($result.ExitCode.Value__)) {
                    $result = 0
                    Set-CMxTaskCompleted -KeyName $PackageName -Value $(Get-Date)
                    Write-Log -Category "info" -Message "installion was successful"
                }
                else {
                    Write-Log -Category "error" -Message "failed to install features!"
                    Write-Log -Category "error" -Message "result: $($result.ExitCode.Value__)"
                    $result = -1
                }
            }
            catch {
                Write-Log -Category "error" -Message "failed to install features!"
                Write-Log -Category "error" -Message $_.Exception.Message
            }
        }
    }
    else {
        Write-Warning "ERROR: role configuration file $PackageFile was not found!"
        break
    }
    Write-Output $result
}

