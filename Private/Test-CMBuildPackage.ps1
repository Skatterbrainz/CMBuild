function Test-CMBuildPackage {
    param (
        [parameter(Mandatory=$False)]
        [string] $PackageName = ""
    )
    Write-Log -Category "info" -Message "[function: Test-CMBuildPackage]"
    $detRule = $detects | Where-Object {$_.name -eq $PackageName}
    if (($detRule) -and ($detRule -ne "")) {
        Write-Output (Test-Path $detRule)
    }
    else {
        Write-Output $True
    }
}
