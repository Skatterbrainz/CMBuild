Write-Verbose "Defining CMBuildSettings object..."

$global:CmBuildSettings = @{
	CMBuildVersion  = '1.0.8'
	RegistryPath1   = 'HKLM:\SOFTWARE\CMBUILD'
	RegistryPath2   = 'HKLM:\SOFTWARE\CMSITECONFIG'
	CMBuildLogFile  = "$($env:SYSTEMROOT)\temp\cmbuild.log"
	CMConfigLogFile = "$($env:SYSTEMROOT)\temp\cmsiteconfig.log"
	CMxLogFile      = "$($env:SYSTEMROOT)\temp\cmbuild.log"
	SchemaVersion   = '1.3'
	LogsFolder      = "$($env:SYSTEMROOT)\temp\"
	ComputerName    = $env:COMPUTERNAME
	SuccessCodes    = @(0,1003,3010,1605,1618,1641,1707)
	HostFullName    = "$($env:COMPUTERNAME).$($env:USERDNSDOMAIN)"
	basekey         = 'HKLM:\SOFTWARE\CM_SITECONFIG'
	tsFile          = "$CmBuildSettings['LogsFolder']\cmsiteconfig`_$CmBuildSettings['ComputerName']`_transaction.log"
	RSJobName       = 'ResumeCMBuild'
}


Get-ChildItem -Path $PSScriptRoot -Filter "*.ps1" -Recurse | ForEach-Object {
	Write-Verbose "Importing: $($_.FullName)"
	. $_.FullName
}