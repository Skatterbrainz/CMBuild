<#
.SYNOPSIS
	Write Log output
.DESCRIPTION
	Write output to verbose (screen) or log file
.PARAMETER Category
	[string][optional] One of 'Info','Warning' or 'Error' 
	Default is 'Info'
.PARAMETER Message 
	[string] Message to display or write to log file
.EXAMPLE
	Write-Log -Category 'Warning' -Message 'This is a message'
#>

function Write-Log {
    param (
        [parameter(Mandatory=$False)]
            [ValidateSet('Info','Error','Warning')]
            [string] $Category = 'Info',
        [parameter(Mandatory=$True)]
            [ValidateNotNullOrEmpty()]
            [string] $Message
    )
    if ($Detailed) {
        Write-Host "DETAILED`: $(Get-Date -f 'yyyy-M-dd HH:mm:ss')`t$Category`t$Message" -ForegroundColor Cyan
    }
	"$(Get-Date -f 'yyyy-M-dd HH:mm:ss')`t$Category`t$Message" | Out-File -FilePath $CMBuildLogFile
}
