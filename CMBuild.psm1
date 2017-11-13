# This is semi-tested, PRE-RELEASE junk
$Script:CMBuildVersion  = '1.0.0'
$Script:CMBuildRegRoot1 = 'HKLM:\SOFTWARE\CMBUILD'
$Script:CMBuildRegRoot2 = 'HKLM:\SOFTWARE\CMSITECONFIG'
$Script:CMBuildDefault1 = ''
$Script:CMBuildDefault2 = ''
$Script:CMBuildLogFile  = 'c:\windows\temp\cmbuild.log'
$Script:CMConfigLogFile = 'c:\windows\temp\cmsiteconfig.log'
$Script:SchemaVersion   = '1.3'

$LogsFolder   = "c:\windows\temp\"

$HostName     = $env:COMPUTERNAME

$Script:SuccessCodes = @(0,1003,3010,1605,1618,1641,1707)

#$basekey  = 'HKLM:\SOFTWARE\CMBUILD'
#$RunTime1 = Get-Date
$HostFullName = "$($env:COMPUTERNAME).$($env:USERDNSDOMAIN)"

$basekey        = 'HKLM:\SOFTWARE\CM_SITECONFIG'
$HostName       = "$($env:COMPUTERNAME).$($env:USERDNSDOMAIN)"
$tsFile         = "$LogsFolder\cmsiteconfig`_$HostName`_transaction.log"
$logFile        = "$LogsFolder\cmsiteconfig`_$HostName`_details.log"
$AutoBoundaries = $False

$(Get-ChildItem "$PSScriptRoot" -Recurse -Include "*.ps1").foreach{. $_.FullName}
