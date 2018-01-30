function Invoke-CMBuildRestartRequest {
    param ()
    if (Test-PendingReboot) {
        Write-Log -Category "info" -Message "a pending restart has been detected"
        Write-Log -Category "info" -Message "restartmode is set to: $RestartMod"
        if ($RestartMode -eq 'Prompt') {
            Write-Host "A restart is required before continiuing." -ForegroundColor Yellow
            $go = Read-Host -Prompt "Restart computer now? (y/N)"
            if ($go -eq 'Y') { 
                Invoke-CMBuildRestart -XmlFile $XmlFile
                Restart-Computer -Force
                break
            }
        }
        elseif ($RestartMode -eq 'Auto') {
            Invoke-CMBuildRestart -XmlFile $XmlFile
            Write-Warning "A reboot is requested. Reboot now."
            Restart-Computer -Force
            break
        }
    }
}