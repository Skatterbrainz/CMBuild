function Start-CMxPayload {
    [CmdletBinding(SupportsShouldProcess=$True)]
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
    Write-Log -Category "info" -Message "installation payload = $Name"
    Write-Log -Category "info" -Message "comment = $Comment"
    switch ($pkgName) {
        'CONFIGMGR' {
            Write-Host "Tip: Monitor C:\ConfigMgrSetup.log for progress" -ForegroundColor Green
            $runFile = "$SourcePath\$PayloadFile"
            $x = Invoke-CMxPayloadInstaller -Name $Name -SourceFile $runFile -OptionParams $PayloadArguments
            Write-Log -Category "info" -Message "exit code = $x"
            break
        }
        'SQLSERVER' {
            Write-Host "Tip: Monitor $($env:PROGRAMFILES)\Microsoft SQL Server\130\Setup Bootstrap\Logs\summary.txt for progress" -ForegroundColor Green
            $runFile = "$SourcePath\$PayloadFile"
            $x = Invoke-CMxPayloadInstaller -Name $Name -SourceFile $runFile -OptionParams $PayloadArguments
            Write-Log -Category "info" -Message "exit code = $x"
            break
        }
        'SERVERROLES' {
            $runFile = "$((Get-ChildItem $xmlfile).DirectoryName)\$PayloadFile"
            $x = Import-CMxServerRolesFile -PackageName $Name -PackageFile $runFile
            Write-Log -Category "info" -Message "exit code = $x"
            break
        }
        default {
            $runFile = "$SourcePath\$PayloadFile"
            $x = Invoke-CMxPayloadInstaller -Name $Name -SourceFile $runFile -OptionParams $PayloadArguments
            Write-Log -Category "info" -Message "exit code = $x"
            break
        }
    } # switch
    Write-Log -Category "info" -Message "[Invoke-CMxPayload] result = $result"
    Write-Output $x
} 
