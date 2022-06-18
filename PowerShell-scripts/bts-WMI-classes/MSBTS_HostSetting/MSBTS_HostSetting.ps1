########################################################################################################
#                                                                                                      #
# Author: Sandro Pereira                                                                               #
#                                                                                                      #
# Description: USe of the MSBTS_HostSetting WMI Class.                                                 #
#                                                                                                      #
#                                                                                                      #
########################################################################################################

# Get Host Setting
$hSettings = Get-WmiObject MSBTS_HostSetting -Namespace root\MicrosoftBizTalkServer | where {$_.Name -eq "BizTalkServerApplication" }