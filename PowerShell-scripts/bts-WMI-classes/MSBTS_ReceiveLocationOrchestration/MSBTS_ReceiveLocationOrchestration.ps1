########################################################################################################
#                                                                                                      #
# Author: Sandro Pereira                                                                               #
#                                                                                                      #
# Description: Use of the MSBTS_ReceiveLocationOrchestration WMI Class.                                #
#                                                                                                      #
#                                                                                                      #
########################################################################################################

$recvlocs = Get-WmiObject MSBTS_ReceiveLocationOrchestration -namespace 'root\MicrosoftBizTalkServer' | where {$_.OrchestrationName -eq "POC_SB_AT.EDA" }