function Get-CMBuildTotalPhysicalMemory {
    [math]::Round((Get-WmiObject -Class Win32_PhysicalMemory | 
        Select-Object -ExpandProperty Capacity | 
            Measure-Object -Sum).sum/1gb,0)
}
