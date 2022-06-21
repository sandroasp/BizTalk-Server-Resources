########################################################################################################
#                                                                                                      #
# Author: Sandro Pereira                                                                               #
#                                                                                                      #
# Description: Use of the MSBTS_ServiceInstance WMI Class.                                             #
#                                                                                                      #
#                                                                                                      #
########################################################################################################


########################################################################################################
# Function to get all suspended messaging service instances both resumable and not-resumable
########################################################################################################
function BTS-Get-Messaging-Svc-Instances()
{
    Get-WmiObject MSBTS_ServiceInstance -namespace 'root\MicrosoftBizTalkServer' -filter 'ServiceClass=4 and (ServiceStatus = 4 or ServiceStatus = 16)'
}

# list Suspended messages
BTS-Get-Messaging-Svc-Instances | fl InstanceId, ServiceName, SuspendTime, HostName, ServiceStatus, ErrorId, ErrorDescription