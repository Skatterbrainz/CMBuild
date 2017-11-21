function Import-CmxServerSettings {
    [CmdletBinding(SupportsShouldProcess=$True)]
    param (
        [parameter(Mandatory=$True)]
        [ValidateNotNullOrEmpty()]
        $DataSet
    )
	Write-Log -Category "info" -Message "------------------------------ Import-CmxServerSettings -------------------------------"
    Write-Host "Configuring Server Settings" -ForegroundColor Green
    $result = $True
    $Time1  = Get-Date
    foreach ($item in $DataSet.configuration.cmsite.serversettings.serversetting | Where-Object {$_.use -eq "1"}) {
        $setName = $item.name
        $setComm = $item.comment
        $setKey  = $item.key
        $setVal  = $item.value
        Write-Log -Category "info" -Message "setting name: $setName"
        Write-Log -Category "info" -Message "comment.....: $setComm"
        switch ($setName) {
            'CMSoftwareDistributionComponent' {
                switch ($setKey) {
                    'NetworkAccessAccountName' {
                        Write-Log -Category "info" -Message "setting $setKey == $setVal"
						if (Get-WmiObject -Class Win32_UserAccount | Where-Object {$_.Domain -eq "$($env:USERDOMAIN)" -and $_.Name -eq "$setVal"}) {
							try {
								Set-CMSoftwareDistributionComponent -SiteCode "$sitecode" -NetworkAccessAccountName "$setVal"
							}
							catch {
								Write-Log -Category "error" -Message $_.Exception.Message
								$result = $False
								break
							}
						}
						else {
							Write-Log -Category "error" -Message "account $setVal was not found in domain $($env:USERDOMAIN)"
							$result = $False
							break
						}
                        break
                    }
                } # switch
                break
            }
			## next condition / future use ##
        } # switch
    } # foreach
    Write-Log -Category "info" -Message "function runtime: $(Get-TimeOffset $time1)"
    Write-Output $result
}
