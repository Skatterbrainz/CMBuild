function Get-CMBuildInstallState {
    <#
    .SYNOPSIS
    Get Install State of a Given Feature or Application
    
    .DESCRIPTION
    Long description
    
    .PARAMETER PackageName
    Name of control Package
    
    .PARAMETER RuleType
    Rule type to process
    
    .PARAMETER RuleData
    Rule data to process
    
    .EXAMPLE
    Get-CMBuildInstallState -PackageName "ADK" -RuleType "auto" -RuleData "..."
    
    .NOTES
    General notes
    #>
    param (
        [parameter(Mandatory=$True)]
            [ValidateNotNullOrEmpty()]
            [string] $PackageName,
        [parameter(Mandatory=$True)]
            [ValidateNotNullOrEmpty()]
            [string] $RuleType, 
        [parameter(Mandatory=$True)]
            [ValidateNotNullOrEmpty()]
            [string] $RuleData
    )
    Write-Log -Category "info" -Message "[function: Get-CMBuildInstallState]"
    Write-Log -Category "info" -Message "detection type = $RuleType"
    Write-Log -Category "info" -Message "detection rule = $RuleData"
    switch ($RuleType.ToLower()) {
        'automatic' {
            $result = (Test-Path $RuleData)
            break
        }
        'synthetic' {
            $detPath = "$RuleData\$PackageName"
            Write-Log -Category "info" -Message "detection rule = $detPath"
            $result  = (Test-Path $detPath)
            break
        }
        'feature' {
            try {
                $result = ((Get-WindowsFeature $RuleData | Select-Object -ExpandProperty Installed) -eq $True)
            }
            catch {}
            break
        }
    }
    Write-Log -Category "info" -Message "function result = $result"
    Write-Output $result
}
