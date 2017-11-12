<#
.SYNOPSIS
	Display Elapsed Time from a Base Time
.DESCRIPTION
	Display the time elapsed since a given base time
.PARAMETER StartTime
	[datetime][required] Date-Time value from which to calculate the elapsed value
.NOTES
.EXAMPLE
	Write-Host "Time lapsed: $($Get-TimeOffset -StartTime $MyTime1)"
#>

function Get-TimeOffset {
    param (
        [parameter(Mandatory=$True)]
        [ValidateNotNullOrEmpty()]
        $StartTime
    )
    $StopTime = Get-Date
    $Offset = [timespan]::FromSeconds(((New-TimeSpan -Start $StartTime -End $StopTime).TotalSeconds).ToString()).ToString("hh\:mm\:ss")
    Write-Output $Offset
}