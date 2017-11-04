function Test-CMxPackage {
    param (
        [parameter(Mandatory=$False)]
        [string] $PackageName = ""
    )
    Write-Log -Category "info" -Message "[function: Test-CMxPackage]"
    $detRule = $detects | Where-Object {$_.name -eq $PackageName}
    if (($detRule) -and ($detRule -ne "")) {
        Write-Output (Test-Path $detRule)
    }
    else {
        Write-Output $True
    }
}
