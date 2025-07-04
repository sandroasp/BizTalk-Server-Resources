########################################################################################################
#                                                                                                      #
# Author: Sandro Pereira                                                                               #
#                                                                                                      #
# Description: This script will restart a specific BizTalk Server Host Instance.                       #
#                                                                                                      #
########################################################################################################

# Define the host instance you want to restart
$hostName = "Your-sftp-BizTalk-Host-Instance-Name"     # Change this to your actual host name
$serverName = "Your-Server-Name"                       # Change this to your BizTalk server name

# Get the BizTalk Host Instance
$hostInstance = Get-WmiObject -Namespace "root\MicrosoftBizTalkServer" -Class MSBTS_HostInstance |
    Where-Object { $_.HostName -eq $hostName -and $_.RunningServer -eq $serverName }

if ($hostInstance) {
    Write-Host "Stopping host instance..."
    $hostInstance.Stop()
    Start-Sleep -Seconds 5

    Write-Host "Starting host instance..."
    $hostInstance.Start()
    
    Write-Host "Host instance restarted successfully."
} else {
    Write-Host "Host instance not found."
}