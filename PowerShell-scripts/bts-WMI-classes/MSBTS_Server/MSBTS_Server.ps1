########################################################################################################
#                                                                                                      #
# Author: Sandro Pereira                                                                               #
#                                                                                                      #
# Description: Use of the MSBTS_Server WMI Class.                                                      #
#                                                                                                      #
#                                                                                                      #
########################################################################################################

$BizTalkServer = Get-WmiObject MSBTS_Server -namespace root\MicrosoftBizTalkServer -ErrorAction Stop
Write-Host "Server name:" $BiztalkServer.Name