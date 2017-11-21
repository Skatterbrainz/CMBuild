function Get-CMSiteConfigCleanXML {
    <#
    .SYNOPSIS
    Scrub XML data

    .DESCRIPTION
    Scrub template XML data to force user to manually update values

    .PARAMETER XmlData
    XML data obtained from source template

    .EXAMPLE
    [xml]$xdata = (New-Object System.Net.WebClient).DownloadString($Source1)
    $newxml = Get-CMSiteConfigCleanXML -XmlData $xdata
    $newxml.Save('myfile.xml')

    .NOTES
    General notes
    #>
    [CmdletBinding()]
    param (
        [parameter(Mandatory=$True)]
        [xml] $XmlData
    )
    Write-Verbose "clearing source path values"
    try {
        [xml]$result = $XmlData
        $result.configuration.comment = 'SCCM site ___ configuration template for __HOSTNAME__, 1.0.0 by __YOU__'
        Write-Verbose "clearing discovery options"
        $result.configuration.cmsite.discoveries.discovery | %{$_.use='0'}
        $result.configuration.cmsite.discoveries.discovery | ?{$_.options -match 'contoso'} | %{$x = $_.options; $_.options = $x -replace('contoso','______')}
        Write-Verbose "clearing boundary group properties"
        $result.configuration.cmsite.boundarygroups.boundarygroup | %{$_.SiteSystemServer='__HOSTNAME__'}
        $result.configuration.cmsite.boundarygroups.boundarygroup | %{$_.name='__NAME__'}
        $result.configuration.cmsite.boundarygroups.boundarygroup | %{$_.comment='__COMMENT__'}
        $result.configuration.cmsite.boundaries.boundary | %{$_.Use='0'}
        $result.configuration.cmsite.boundaries.boundary | %{$_.name='__NAME__'}
        $result.configuration.cmsite.boundaries.boundary | %{$_.value='__IPRANGE__'}
        $result.configuration.cmsite.boundaries.boundary | %{$_.comment='__COMMENT__'}
        $result.configuration.cmsite.boundaries.boundary | %{$_.boundarygroup='__GROUPNAME__'}
        ($result.configuration.cmsite.clientsettings.clientsetting).settings.setting | %{$_.use = '0'}
        Write-Verbose "clearing site system role properties"
        (($result.configuration.cmsite.sitesystemroles.sitesystemrole | ?{$_.name -eq 'mp'}).roleoptions.roleoption | ? {$_.name -eq 'PublicFqdn'}).params = '__HOSTNAME__'
        (($result.configuration.cmsite.sitesystemroles.sitesystemrole | ?{$_.name -eq 'ssrp'}).roleoptions.roleoption | ? {$_.name -eq 'DatabaseServerName'}).params = '__HOSTNAME__'
        (($result.configuration.cmsite.sitesystemroles.sitesystemrole | ?{$_.name -eq 'ssrp'}).roleoptions.roleoption | ? {$_.name -eq 'DatabaseName'}).params = 'CM_XXX'
        (($result.configuration.cmsite.sitesystemroles.sitesystemrole | ?{$_.name -eq 'ssrp'}).roleoptions.roleoption | ? {$_.name -eq 'UserName'}).params = '__ACCOUNTNAME__'
        (($result.configuration.cmsite.sitesystemroles.sitesystemrole | ?{$_.name -eq 'acwp'}).roleoptions.roleoption | ? {$_.name -eq 'OrganizationName'}).params = '__ORGNAME__'
        (($result.configuration.cmsite.serversettings.serversetting | ?{$_.name -eq 'CMSoftwareDistributionComponent'})).value = '__ACCOUNTNAME__'
        ($result.configuration.cmsite.clientoptions.CMClientPushInstallation).Accounts = '__ACCOUNT__,__ACCOUNT__'
        ($result.configuration.cmsite.clientoptions.CMClientPushInstallation).InstallationProperty = 'SMSSITECODE=___'
        Write-Verbose "clearing client settings"
        ($result.configuration.cmsite.clientsettings.clientsetting.settings.setting.options.option | ?{$_.name -eq 'PortalURL'}).value = '__PORTALURL__'
        Write-Verbose "clearing distribution point settings"
        ($result.configuration.cmsite.dpgroups.dpgroup) | %{$_.name='__DPGROUPNAME__'}
        ($result.configuration.cmsite.dpgroups.dpgroup) | %{$_.comment='__COMMENT__'}
        ($result.configuration.cmsite.dpgroups.dpgroup)[0].name='All DP Servers'
        ($result.configuration.cmsite.dpgroups.dpgroup)[0].comment='All Distribution Point Servers'
        ($result.configuration.cmsite.dpgroups.dpgroup)[1].name='All PXE DP Servers'
        ($result.configuration.cmsite.dpgroups.dpgroup)[1].comment='All PXE-enabled Distribution Point Servers'
        Write-Verbose "clearing site system role settings"
        ($result.configuration.cmsite.sitesystemroles.sitesystemrole) | %{$_.roleoptions.roleoption} | ? {$_.name -eq 'AddProducts'} | %{$_.use ='0'}
        Write-Verbose "clearing os images and os installer properties"
        $result.configuration.cmsite.osimages.osimage | %{$_.path = '__PATH_TO_WIM_FILE__'}
        $result.configuration.cmsite.osimages.osimage | %{$_.use = '0'}
        $result.configuration.cmsite.osinstallers.osinstaller | %{$_.path = '__PATH_TO_EXE_FILE__'}
        $result.configuration.cmsite.osinstallers.osinstaller | %{$_.use = '0'}
        Write-Verbose "clearing maintenance task properties"
        ($result.configuration.cmsite.mtasks.mtask | ?{$_.name -match 'Backup'}).options='__PATH__'
        Write-Verbose "clearing application and deployment types properties"
        ($result.configuration.cmsite.applications.application).deptypes.deptype | %{$x = $_.source;$_.source = $x.replace('FS1\apps','__PATH__')}
        Write-Verbose "clearing site system accounts properties"
        $result.configuration.cmsite.accounts.account | %{$_.name = '__ACCOUNTNAME__'}
        $result.configuration.cmsite.accounts.account | %{$_.password = '__PASSWORD__'}
        Write-Verbose "clearing EPP policy template properties"
        $result.configuration.cmsite.malwarepolicies.malwarepolicy | %{$x = $_.path; $_.path = $x.replace('E:\CONFIGMGR','__PATH__')}
    }
    catch {
        Write-Error $_.Exception.Message
    }
    Write-Output $result
}