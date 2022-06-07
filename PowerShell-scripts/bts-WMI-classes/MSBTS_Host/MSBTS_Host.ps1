########################################################################################################
#                                                                                                      #
# Author: Sandro Pereira                                                                               #
#                                                                                                      #
# Description: USe of the MSBTS_Host WMI Class.                                                        #
#                                                                                                      #
#                                                                                                      #
########################################################################################################

# Get the tracking host information
$trackingHost = Get-WmiObject MSBTS_Host -Namespace root\MicrosoftBizTalkServer -ErrorAction Stop | where {$_.HostTracking -eq "true" }