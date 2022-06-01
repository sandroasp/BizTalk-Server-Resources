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

    #Loop to check and guarantee that the send port was successfully stopped
    #Sometimes this can take a few seconds depending on the workload that BizTalk Server is processing
    #So this loop is here for security to guarantee the enable operation will be triggered only when the port is stopped.
    Do
    {

        $port = get-wmiobject MSBTS_SendPort -Namespace 'root\MicrosoftBizTalkServer' -Filter "name='$sendPort'"
        #Status 2 means that the port is stopped, so anything that is different of 2 we need to wait for the port to stop successfully 
        if($port.Status -ne 2) {
            Start-Sleep -s 10
        }

    } While ($port.Status –ne 2)

    #Start the Send Port
    $port.Start()

}
 
# trigger function restart-send-port
restart-send-port OUT_TEST_ARCHIVE