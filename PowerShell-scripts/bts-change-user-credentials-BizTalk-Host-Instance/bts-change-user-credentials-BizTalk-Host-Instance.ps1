########################################################################################################
#                                                                                                      #
# Author: Sandro Pereira                                                                               #
#                                                                                                      #
# Description: This script will allow you to change the user credentials of a specific Host Instance   #
#                                                                                                      #
########################################################################################################

# Getting the list of BizTalk Host Instances objects
$hosts = Get-WmiObject MSBTS_HostInstance -namespace 'root/MicrosoftBizTalkServer'
  
# Listing existing BizTalk Host Instances names
$hosts | ft HostName
 
# Getting/Filter the desired instance
$MyHost = $hosts | ?{$_.HostName -eq "BizTalkDemoApplication"}
 
# Change BizTalk Host Instance user credentials
$MyHost.Install("DOMAIN\User", "password", "true")