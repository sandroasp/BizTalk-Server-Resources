########################################################################################################
#                                                                                                      #
# Author: Sandro Pereira                                                                               #
#                                                                                                      #
# Description: This script allow you to restart specific BizTalk Server Send Port.                     #
#                                                                                                      #
#                                                                                                      #
########################################################################################################

function restart-send-port (
    [string]$sendPort) 
{
    # Get the Send Port by name
    $port = get-wmiobject MSBTS_SendPort -Namespace 'root\MicrosoftBizTalkServer' -Filter "name='$sendPort'"

    #Stop the send port
    $port.Stop()

    #Loop to check and garanty that the receive location was successfully disables (stopped)
    #Sometimes this can take a few seconds depending the workload that BizTalk Server is processing
    #So this loop is here to security to garanty the enable operation will be trigger only when the port is disabled.
    Do
    {

        $port = get-wmiobject MSBTS_SendPort -Namespace 'root\MicrosoftBizTalkServer' -Filter "name='$sendPort'"
        if($port.Status -ne 2) {
            Start-Sleep -s 10
        }

    } While ($port.Status –ne 2)

    #Enable the receive location (Start)
    $port.Start()

}
 
# trigger function restart-send-port
restart-send-port OUT_TEST_ARCHIVE