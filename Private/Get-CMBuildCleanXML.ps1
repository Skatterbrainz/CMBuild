function Get-CMBuildCleanXML {
    <#
    .SYNOPSIS
    Scrub XML data

    .DESCRIPTION
    Scrub template XML data to force user to manually update values

    .PARAMETER XmlData
    XML data obtained from source template

    .EXAMPLE
    [xml]$xdata = (New-Object System.Net.WebClient).DownloadString($Source1)
    $newxml = Get-CMBuildCleanXML -XmlData $xdata
    $newxml.Save('myfile.xml')

    .NOTES
    General notes
    #>
    [CmdletBinding()]
    param (
        [parameter(Mandatory=$True)]
        [xml] $XmlData
    )
    [xml]$result = $XmlData
    $DefPath = '__PATH__'
    $DefSADate = (Get-Date -f 'yyyy-M-dd 00:00:00.000')
    Write-Verbose "clearing source path values"
    try {
        $result.configuration.sources.source | %{$_.path = $DefPath}
        Write-Verbose "clearing project values"
        $result.configuration.project.hostname='__FQDNHOSTNAME__'
        $result.configuration.project.host='__HOST__'
        $result.configuration.project.sitecode='___'
        $result.configuration.project.comment='SCCM site server configuration for __NAME__, 1.0.0 by __YOU__'
        Write-Verbose "clearing payload path references"
        ($result.configuration.payloads.payload | ?{$_.name -eq 'SQLSERVER'}).params = '/Configuration=__PATH__\sqlsetup.ini'
        ($result.configuration.payloads.payload | ?{$_.name -eq 'CONFIGMGR'}).params = '/script __PATH__\cmsetup.ini'
        ($result.configuration.payloads.payload | ?{$_.name -eq 'ADK'}).params = '/installpath __PATH__ /Features OptionId.DeploymentTools OptionId.WindowsPreinstallationEnvironment OptionId.ImagingAndConfigurationDesigner OptionId.UserStateMigrationTool /norestart /quiet /ceip off'
        Write-Verbose "clearing file values"
        (($result.configuration.files.file | ?{$_.pkg -eq 'CONFIGMGR'}).keys.key | ?{$_.name -eq 'ProductID'}).value = 'EVAL'
        (($result.configuration.files.file | ?{$_.pkg -eq 'CONFIGMGR'}).keys.key | ?{$_.name -eq 'SAExpiration'}).value = "$DefSADate"
        (($result.configuration.files.file | ?{$_.pkg -eq 'CONFIGMGR'}).keys.key | ?{$_.name -eq 'SMSInstallDir'}).value = $DefPath
        (($result.configuration.files.file | ?{$_.pkg -eq 'CONFIGMGR'}).keys.key | ?{$_.name -eq 'PrerequisitePath'}).value = $DefPath
        ($result.configuration.files.file | ?{$_.pkg -eq 'CONFIGMGR'}).path = $DefPath
        ($result.configuration.files.file | ?{$_.pkg -eq 'SQLSERVER'}).path = $DefPath
        Write-Verbose "clearing local accounts properties"
        ($result.configuration.localaccounts.localaccount | ?{$_.name -eq 'CONTOSO\sql-svc'}).name = '__SERVICEACCOUNT__'
        ($result.configuration.localaccounts.localaccount | ?{$_.name -eq 'CONTOSO\sccmadmin'}).name = '__SCCMADMINACCOUNT__'
        ($result.configuration.localaccounts.localaccount | ?{$_.name -eq 'CONTOSO\IT sccm admins'}).use = '0'
        ($result.configuration.localaccounts.localaccount | ?{$_.name -eq 'CONTOSO\IT sccm admins'}).name = '__ANOTHERADMINGROUP__'
        ($result.configuration.files.file | ?{$_.pkg -eq 'SQLSERVER'}).keys.key | ? {$_.name -match "dir"} | % {$x = $_.value ; $_.value = '__DRIVE__:'+$x.substring(3)}
        ($result.configuration.files.file | ?{$_.pkg -eq 'SQLSERVER'}).keys.key | ? {$_.name -match "ADMINACCOUNTS"} | % {$_.value = '__ACCOUNT1__,__ACCOUNT2__'}
        ($result.configuration.files.file | ?{$_.pkg -eq 'SQLSERVER'}).keys.key | ? {$_.name -match "SVCACCOUNT"} | %{$_.value = '__ACCOUNTNAME__'}
        ($result.configuration.files.file | ?{$_.pkg -eq 'SQLSERVER'}).keys.key | ? {$_.name -match "SVCACCT"} | %{$_.value = '__ACCOUNTNAME__'}
        ($result.configuration.files.file | ?{$_.pkg -eq 'SQLSERVER'}).keys.key | ? {$_.name -match "PASSWORD"} | %{$_.value = '__PASSWORD__'}
        $result.configuration.folders.folder | %{$x = $_.name; $_.name = '__DRIVE__:'+$x.substring(3)}
        $result.configuration.regkeys.regkey | %{$_.use = '0'}
    }
    catch {
        Write-Error $_.Exception.Message
    }
    Write-Output $result
}
