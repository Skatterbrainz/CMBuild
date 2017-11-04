function Set-CMxTaskCompleted {
    [CmdletBinding(SupportsShouldProcess=$True)]
    param (
        [parameter(Mandatory=$True)]
            [ValidateNotNullOrEmpty()]
            [string] $KeyName, 
        [parameter(Mandatory=$True)]
            [ValidateNotNullOrEmpty()]
            [string] $Value
    )
    Write-Log -Category "info" -Message "function: Set-CMxTaskCompleted"
    try {
        New-Item -Path $CMBuildRegRoot1 -ErrorAction SilentlyContinue | Out-Null
        New-Item -Path $CMBuildRegRoot1\PROCESSED -ErrorAction SilentlyContinue | Out-Null
    }
    catch {
        Write-Error "FAIL: Unable to set registry path"
        break
    }
    try {
        New-Item -Path $CMBuildRegRoot1\PROCESSED\$KeyName -Value $Value -ErrorAction SilentlyContinue | Out-Null
        Write-Log -Category "info" -Message "writing registry key $KeyName"
    }
    catch {
        Write-Log -Category "error" -Message "failed to write to registry!"
    }
}
