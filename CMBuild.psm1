$Script:CMBuildVersion  = '1.0.7'
$Script:CMBuildRegRoot1 = 'HKLM:\SOFTWARE\CMBUILD'
$Script:CMBuildRegRoot2 = 'HKLM:\SOFTWARE\CMSITECONFIG'
$Script:CMBuildLogFile  = "$($env:SYSTEMROOT)\temp\cmbuild.log"
$Script:CMConfigLogFile = "$($env:SYSTEMROOT)\temp\cmsiteconfig.log"
$Script:CMxLogFile      = "$($env:SYSTEMROOT)\temp\cmbuild.log"
$Script:SchemaVersion   = '1.3'
$Script:LogsFolder      = "$($env:SYSTEMROOT)\temp\"
$Script:HostName        = $env:COMPUTERNAME
$Script:SuccessCodes    = @(0,1003,3010,1605,1618,1641,1707)
$Script:HostFullName    = "$($env:COMPUTERNAME).$($env:USERDNSDOMAIN)"
$Script:basekey         = 'HKLM:\SOFTWARE\CM_SITECONFIG'
$Script:tsFile          = "$LogsFolder\cmsiteconfig`_$HostName`_transaction.log"
$Script:RSJobName       = 'ResumeCMBuild'

$(Get-ChildItem "$PSScriptRoot" -Recurse -Include "*.ps1").foreach{. $_.FullName}
