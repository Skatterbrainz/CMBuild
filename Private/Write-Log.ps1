function Write-Log {
    <#
    .SYNOPSIS
        Write Log output
    .DESCRIPTION
        Write output to verbose (screen) or log file
    .PARAMETER Category
        One of 'Info','Warning' or 'Error' 
        Default is 'Info'
    .PARAMETER Message 
        Message to display or write to log file
    .PARAMETER LogFile
        Optional path and name of log file.  Default is $CMxLogFile
    .EXAMPLE
        Write-Log -Category 'Warning' -Message 'This is a message'
    #>
    param (
        [parameter(Mandatory = $False, HelpMessage = "Category to assign to message")]
            [ValidateSet('Info', 'Error', 'Warning')]
            [string] $Category = 'Info',
        [parameter(Mandatory = $True, HelpMessage = "Message to display or write to log")]
            [ValidateNotNullOrEmpty()]
            [string] $Message,
        [parameter(Mandatory = $False, HelpMessage = "Log file path and name")]
            [ValidateNotNullOrEmpty()]
            [string] $LogFile = $Script:CMxLogFile
    )
    if ($Detailed) {
        Write-Host "DETAILED`: $(Get-Date -f 'yyyy-M-dd HH:mm:ss')`t$Category`t$Message" -ForegroundColor Cyan
    }
    "$(Get-Date -f 'yyyy-M-dd HH:mm:ss')`t$Category`t$Message" | Out-File -FilePath $LogFile -Append
}
