function Get-TimeOffset {
	<#
	.SYNOPSIS
		Display Elapsed Time from a Base Time
	.DESCRIPTION
		Display the time elapsed since a given base time
	.PARAMETER StartTime
		Date-Time value from which to calculate the elapsed value
	.EXAMPLE
		Write-Host "Time lapsed: $($Get-TimeOffset -StartTime $MyTime1)"
	#>
	param (
		[parameter(Mandatory=$True)]
		[ValidateNotNullOrEmpty()]
		$StartTime
	)
	$StopTime = Get-Date
	$Offset = [timespan]::FromSeconds(((New-TimeSpan -Start $StartTime -End $StopTime).TotalSeconds).ToString()).ToString("hh\:mm\:ss")
	Write-Output $Offset
}