<#
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
	"$(Get-Date -f 'yyyy-M-dd HH:mm:ss')`t$Category`t$Message" | OutFile $CMLogFile
}
