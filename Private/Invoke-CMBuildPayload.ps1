function Invoke-CMBuildPayload {
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
    
    .EXAMPLE
    Invoke-CMBuildPayload
    
    .NOTES
    1.0.7 - 01/29/2018 - David Stein
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
    Write-Log -Category "info" -Message "Start-CMBuildPayload: installation payload = $Name"
    Write-Log -Category "info" -Message "comment = $Comment"
    switch ($pkgName) {
        'CONFIGMGR' {
            Write-Host "Tip: Monitor C:\ConfigMgrSetup.log for progress" -ForegroundColor Green
            $runFile = "$SourcePath\$PayloadFile"
            $x = Invoke-CMBuildPayloadInstaller -Name $Name -SourceFile $runFile -OptionParams $PayloadArguments
            Write-Log -Category "info" -Message "exit code = $x"
            break
        }
        'SQLSERVER' {
            Write-Host "Tip: Monitor $($env:PROGRAMFILES)\Microsoft SQL Server\130\Setup Bootstrap\Logs\summary.txt for progress" -ForegroundColor Green
            $runFile = "$SourcePath\$PayloadFile"
            $x = Invoke-CMBuildPayloadInstaller -Name $Name -SourceFile $runFile -OptionParams $PayloadArguments
            Write-Log -Category "info" -Message "exit code = $x"
            break
        }
        'SERVERROLES' {
            $runFile = "$((Get-ChildItem $xmlfile).DirectoryName)\$PayloadFile"
            $x = Import-CMBuildServerRolesFile -PackageName $Name -PackageFile $runFile
            Write-Log -Category "info" -Message "exit code = $x"
            break
        }
        default {
            $runFile = "$SourcePath\$PayloadFile"
            $x = Invoke-CMBuildPayloadInstaller -Name $Name -SourceFile $runFile -OptionParams $PayloadArguments
            Write-Log -Category "info" -Message "exit code = $x"
            break
        }
    } # switch
    Write-Log -Category "info" -Message "[Invoke-CMxPayload] result = $result"
    Write-Output $x
} 
