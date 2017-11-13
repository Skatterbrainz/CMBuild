function Invoke-CMxRestart {
    param (
        [parameter(Mandatory=$True)]
        [string] $XmlFile
    )
    $psfile  = "$($PWD.Path)\resume_cmbuild.ps1"
    $batfile = "$($PWD.Path)\resume_cmbuild.bat"
    $stask = 'SCHTASKS /Create /TN ResumeCMBuild /TR '+$batfile+' /RU SYSTEM /SC OnStart /RL HIGHEST /F'
    $psx = @"
Import-Module CMBuild -Force
Get-ScheduledTask -TaskName `"ResumeCMBuild`" | Unregister-ScheduledTask -Confirm`:`$False
Invoke-CMBuild -XmlFile $XmlFile -NoCheck -NoReboot -Detailed -Verbose
"@
    $psx | Out-File $psfile
    Write-Log -Category 'Info' -Message "PowerShell file... $psfile"
    $cmd = @"
`@echo off
set LOG=$($PWD.Path)\resume.log
powershell.exe -ExecutionPolicy ByPass -NoProfile -File $psfile
"@
    $cmd | Out-File $batfile
    Write-Log -Category 'Info' -Message "Batch file........ $batfile"

    try {
        Invoke-Expression -Command $stask -ErrorAction Stop
        Write-Log -Category 'Info' -Message "Scheduled Task.... $stask"
    }
    catch {
        Write-Log -Category 'Error' -Message $_.Exception.Message
        Write-Error $_.Exception.Message
    }
}