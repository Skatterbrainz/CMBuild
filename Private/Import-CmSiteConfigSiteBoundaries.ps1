function Import-CmSiteConfigSiteBoundaries {
    <#
    .SYNOPSIS
    Set CM Site Boundaries
    
    .DESCRIPTION
    Define Custom ConfigMgr Site Boundaries from XML configuration data
    
    .PARAMETER DataSet
    XML Data set
    
    .EXAMPLE
    Set-CmxBoundaries -DataSet $xmldata
    
    .NOTES
    General notes
    #>

    [CmdletBinding(SupportsShouldProcess=$True)]
    param (
        [parameter(Mandatory=$True)]
        [ValidateNotNullOrEmpty()]
        [xml] $DataSet
    )
	Write-Log -Category "info" -Message "------------------------------ Import-CmSiteConfigSiteBoundaries -------------------------------"
    Write-Host "Configuring Site Boundaries" -ForegroundColor Green
    $result = $True
    $Time1  = Get-Date
    foreach ($item in $DataSet.configuration.cmsite.boundaries.boundary | Where-Object {$_.use -eq '1'}) {
        $bName = $item.name
        $bType = $item.type
        $bData = $item.value
        $bGrp  = $item.boundarygroup
        $bComm = $item.comment
        Write-Log -Category "info" -Message "- - - - - - - - - - - - - - - - - - - - - - - - - -"
        Write-Log -Category "info" -Message "boundary name = $bName"
        Write-Log -Category "info" -Message "comment = $bComm"
        Write-Log -Category "info" -Message "data = $bData"
        Write-Log -Category "info" -Message "type = $bType"
        Write-Log -Category "info" -Message "boundary group = $bGrp"
        try {
            $bx = New-CMBoundary -Name $bName -Type IPRange -Value $bData -ErrorAction Stop
            Write-Log -Category "info" -Message "boundary [$bName] created"
        }
        catch {
            Write-Log -Category "info" -Message "boundary [$bName] already exists"
            try {
                $bx = Get-CMBoundary -BoundaryName $bName -ErrorAction SilentlyContinue
                Write-Log -Category "info" -Message "getting boundary information for $bName"
                $bID = $bx.BoundaryID
                Write-Log -Category "info" -Message "boundary [$bName] identifier = $bID"
            }
            catch {
                Write-Log -Category "error" -Message "unable to create or update boundary: $bName"
                $bID = $null
                break
            }
        }
        if ($bID -and $bGrp) {
            Write-Log -Category "info" -Message "assigning boundary [$bName] to boundary group: $bGrp"
            try {
                $bg = Get-CMBoundaryGroup -Name $bGrp -ErrorAction SilentlyContinue
                $bgID = $bg.GroupID
                Write-Log -Category "info" -Message "boundary group identifier = $bgID"
            }
            catch {
                Write-Log -Category "error" -Message "unable to obtain boundary group [$bGrp]"
                $bgID = $null
            }
            if ($bgID) {
                try {
                    Add-CMBoundaryToGroup -BoundaryId $bx.BoundaryID -BoundaryGroupId $bg.GroupID
                    Write-Log -Category "info" -Message "boundary ($bName) added to boundary group ($bGrp)"
                }
                catch {
                    Write-Log -Category "error" -Message "oops?"
                }
            }
        }
        else {
            Write-Log -Category "info" -Message "oundary [$bName] is not assigned to a boundary group"
        }
    } # foreach
    Write-Log -Category info -Message "function runtime: $(Get-TimeOffset $time1)"
    Write-Output $result
}
