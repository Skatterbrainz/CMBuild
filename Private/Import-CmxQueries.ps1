function Import-CmxQueries {
    <#
    .SYNOPSIS
    Create ConfigMgr Custom Queries from XML data input
    
    .DESCRIPTION
    Create ConfigMgr Custom Queries from XML data input
    
    .PARAMETER DataSet
    XML data set
    
    .EXAMPLE
    Import-CmxQueries -DataSet $xmlData
    
    .NOTES
    ...
    #>
    [CmdletBinding()]
    param (
        [parameter(Mandatory=$True, HelpMessage="XML Data Set")]
        [ValidateNotNullOrEmpty()]
        [xml] $DataSet
    )
	Write-Log -Category "info" -Message "------------------------------ Import-CmxQueries -------------------------------" -LogFile $logfile
    Write-Host "Importing custom Queries" -ForegroundColor Green
    $result = $True
    $Time1  = Get-Date
    foreach ($item in $DataSet.configuration.cmsite.queries.query | Where-Object {$_.use -eq '1'}) {
        $queryName = $item.name
        $queryComm = $item.comment
        $queryType = $item.class
        $queryExp  = $item.expression
        if ($orgname -and ($orgname.length -gt 0)) {
            $NewName = $queryName -replace '@ORGNAME@', $orgname
        }
        else {
            $NewName = $queryName
        }
        try {
            New-CMQuery -Name $NewName -Expression $queryExp -Comment $queryComm -TargetClassName $queryType | Out-Null
            Write-Log -Category "info" -Message "item created successfully: $NewName" -LogFile $logfile
        }
        catch {
            if ($_.Exception.Message -like "*already exists*") {
                Write-Log -Category "info" -Message "item already exists: $NewName" -LogFile $logfile
            }
            else {
                Write-Log -Category "error" -Message $_.Exception.Message -Severity 3 -LogFile $logfile
                $result = $False
                break
            }
        }
        Write-Log -Category "info" -Message "- - - - - - - - - - - - - - - - - - - - - - - - - - - - - -" -LogFile $logfile
    } # foreach
    Write-Log -Category info -Message "function runtime: $(Get-TimeOffset $time1)" -LogFile $logfile
    Write-Output $result
}
