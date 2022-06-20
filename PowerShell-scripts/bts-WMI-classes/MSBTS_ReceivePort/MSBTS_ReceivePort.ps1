########################################################################################################
#                                                                                                      #
# Author: Sandro Pereira                                                                               #
#                                                                                                      #
# Description: Use of the MSBTS_ReceivePort WMI Class.                                                 #
#                                                                                                      #
#                                                                                                      #
########################################################################################################

########################################################################################################
# List all Receive Ports
########################################################################################################
Function List-Receive-Ports
{
   Get-WmiObject MSBTS_ReceivePort -namespace ‘root\MicrosoftBizTalkServer’
}

# Get all receive ports that as tracing enable
$trackingRecPorts = Get-WmiObject MSBTS_ReceivePort -namespace 'root\MicrosoftBizTalkServer' | Where-Object {$_.Tracking -gt 0 }