########################################################################################################
#                                                                                                      #
# Author: Sandro Pereira                                                                               #
#                                                                                                      #
# Description: This script will restart a specific BizTalk Server Host Instance.                       #
#                                                                                                      #
########################################################################################################

# Define the host instance you want to restart
$hostName = "Your-sftp-BizTalk-Host-Instance-Name"     # Change this to your actual host name
$serviceName = "BTSSvc$"+ $hostName

Restart-Service -Name $serviceName