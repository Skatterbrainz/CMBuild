function Import-CmxAppCategories {
    [CmdletBinding(SupportsShouldProcess=$True)]
    param (
        [parameter(Mandatory=$True)]
        [ValidateNotNullOrEmpty()]
        $DataSet
    )
	Write-Log -Category "info" -Message "------------------------------ Import-CmxAppCategories -------------------------------"
    Write-Host "Configuring application categories" -ForegroundColor Green
    $result = $true
    $Time1  = Get-Date
    foreach ($item in $DataSet.configuration.cmsite.appcategories.appcategory | Where-Object {$_.use -eq '1'}) {
        $catName = $item.name
        $catComm = $item.comment
		Write-Log -Category "info" -Message "application category: $catName"
		if (Get-CMCategory -Name $catName -CategoryType AppCategories) {
			Write-Log -Category "info" -Message "category already exists"
		}
		else {
			try {
				New-CMCategory -CategoryType AppCategories -Name $catName -ErrorAction SilentlyContinue | Out-Null
				Write-Log -Category "info" -Message "category was created successfully"
			}
			catch {
				Write-Log -Category error -Message $_.Exception.Message
				$result = $False
				break
			}
		}
    } # foreach
    Write-Log -Category info -Message "function runtime: $(Get-TimeOffset $time1)"
    Write-Output $result
}
