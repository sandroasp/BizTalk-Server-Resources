########################################################################################################
#                                                                                                      #
# Author: Sandro Pereira                                                                               #
#                                                                                                      #
# Description: Use of the MSBTS_ServiceInstanceSuspendedEvent WMI Class.                               #
#                                                                                                      #
#                                                                                                      #
########################################################################################################

$sinstance = Get-WmiObject MSBTS_ServiceInstanceSuspendedEvent -namespace 'root\MicrosoftBizTalkServer'