function Invoke-CMBuildPayloadInstaller {
    [CmdletBinding()]
    param (
        [parameter(Mandatory=$True)]
            [ValidateNotNullOrEmpty()]
            [string] $Name,
        [parameter(Mandatory=$True)]
            [ValidateNotNullOrEmpty()]
            [string] $SourceFile,
        [parameter(Mandatory=$False)]
            [string] $OptionParams = ""
    )
    Write-Log -Category "info" -Message "----------------------------------------------------"
    Write-Log -Category "info" -Message "function: Invoke-CMBuildPayloadInstaller"
    Write-Log -Category "info" -Message "payload name..... $Name"
    Write-Log -Category "info" -Message "sourcefile....... $SourceFile"
    Write-Log -Category "info" -Message "input arguments.. $OptionParams"
    
    if (-not(Test-Path $SourceFile)) {
        Write-Log -Category "error" -Message "source file not found: $SourceFile"
        Write-Output -1
        break
    }
    if ($SourceFile.EndsWith('.msi')) {
        if ($OptionParams -ne "") {
            $ArgList = "/i $SourceFile $OptionParams"
        }
        else {
            $ArgList = "/i $SourceFile /qb! /norestart"
        }
        $SourceFile = "msiexec.exe"
    }
    else {
        $ArgList = $OptionParams
    }
    Write-Log -Category "info" -Message "source file...... $SourceFile"
    Write-Log -Category "info" -Message "new arguments.... $ArgList"
    $time1 = Get-Date
    $result = 0
    try {
        $p = Start-Process -FilePath $SourceFile -ArgumentList $ArgList -NoNewWindow -Wait -PassThru -ErrorAction Continue
        if (($Script:SuccessCodes).Contains($p.ExitCode)) {
            Write-Log -Category "info" -Message "aggregating a success code."
            Set-CMBuildTaskCompleted -KeyName $Name -Value $(Get-Date)
            $result = 0
        }
        else {
            Write-Log -Category "info" -Message "internal : exit code = $($p.ExitCode)"
            $result = $p.ExitCode
        }
    }
    catch {
        Write-Warning "error: failed to execute installation: $Name"
        Write-Warning "error: $($error[0].Exception)"
        Write-Log -Category "error" -Message "internal : exit code = -1"
        $result = -1
    }
    Invoke-CMxRestartRequest    
    Write-Log -Category "info" -Message "function runtime = $(Get-TimeOffset -StartTime $time1)"
    Write-Log -Category "info" -Message "function result = $result"
    Write-Output $result
}
