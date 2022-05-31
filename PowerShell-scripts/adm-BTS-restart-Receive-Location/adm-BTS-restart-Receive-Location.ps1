########################################################################################################
#                                                                                                      #
# Author: Sandro Pereira                                                                               #
#                                                                                                      #
# Description: This script allow you to restart specific BizTalk Server Receive Locations.             #
#                                                                                                      #
#                                                                                                      #
########################################################################################################

function restart-receive-location (
    [string]$receiveLocation) 
{
    # Get the Receive Location by name
    $location = get-wmiobject msbts_receivelocation -Namespace 'root\MicrosoftBizTalkServer' -Filter "name='$receiveLocation'"

    #Disable the receive location (stop)
    $location.Disable()

    #Loop to check and garanty that the receive location was successfully disables (stopped)
    #Sometimes this can take a few seconds depending the workload that BizTalk Server is processing
    #So this loop is here to security to garanty the enable operation will be trigger only when the port is disabled.
    Do
    {

        $location = get-wmiobject msbts_receivelocation -Namespace 'root\MicrosoftBizTalkServer' -Filter "name='$receiveLocation'"
        if($location.IsDisabled -eq $false) {
            Start-Sleep -s 10
        }

    } While ($location.IsDisabled –eq $false)

    #Enable the receive location (Start)
    $location.Enable()

}
 
# trigger function restart-receive-location 
restart-receive-location IN_TEST_ARCHIVE_RL