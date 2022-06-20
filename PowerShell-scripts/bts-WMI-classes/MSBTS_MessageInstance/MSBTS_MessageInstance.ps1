########################################################################################################
#                                                                                                      #
# Author: Sandro Pereira                                                                               #
#                                                                                                      #
# Description: Use of the MSBTS_MessageInstance WMI Class.                                             #
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

########################################################################################################
# Function to save the message associated to the specified messaging Service Instance
########################################################################################################
function BTS-Save-Message([string]$msgid)
{
    $path = "c:\temp"
    $msg = Get-WmiObject MSBTS_MessageInstance -namespace 'root\MicrosoftBizTalkServer' -filter "ServiceInstanceID = '$msgid'"
    $msg.psbase.invokemethod('SaveToFile', ($path))

    Write-Host "Message from ServiceInstanceID=$msgid saved."
}

# save Suspended messsages
BTS-Get-Messaging-Svc-Instances | %{ BTS-Save-Message($_.InstanceID) }