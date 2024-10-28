function getCmxTotalMemory {
	[math]::Round((Get-WmiObject -Class 'Win32_PhysicalMemory' | 
		Select-Object -ExpandProperty Capacity | 
			Measure-Object -Sum).Sum / 1gb, 0)
}
