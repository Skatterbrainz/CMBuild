function Import-CmxQueries {
    [CmdletBinding(SupportsShouldProcess=$True)]
    param (
        [parameter(Mandatory=$True)]
        [ValidateNotNullOrEmpty()]
        $DataSet
    )
	Write-Log -Category "info" -Message "------------------------------ Import-CmxQueries -------------------------------"
    Write-Host "Importing custom Queries" -ForegroundColor Green
    $result = $True
    $Time1  = Get-Date
    foreach ($item in $DataSet.configuration.cmsite.queries.query | Where-Object {$_.use -eq '1'}) {
        $queryName = $item.name
        $queryComm = $item.comment
        $queryType = $item.class
        $queryExp  = $item.expression
        try {
            New-CMQuery -Name $queryName -Expression $queryExp -Comment $queryComm -TargetClassName $queryType | Out-Null
            Write-Log -Category "info" -Message "item created successfully: $queryName"
        }
        catch {
            if ($_.Exception.Message -like "*already exists*") {
                Write-Log -Category "info" -Message "item already exists: $queryname"
            }
            else {
                Write-Log -Category "error" -Message $_.Exception.Message
                $result = $False
                break
            }
        }
        Write-Verbose "- - - - - - - - - - - - - - - - - - - - - - - - - - - - - -"
    } # foreach
    Write-Log -Category info -Message "function runtime: $(Get-TimeOffset $time1)"
    Write-Output $result
}
