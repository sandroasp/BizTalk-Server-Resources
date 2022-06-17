########################################################################################################
#                                                                                                      #
# Author: Sandro Pereira                                                                               #
#                                                                                                      #
# Description: Sample use of the MSBTS_HostInstance  WMI Class.                                        #
#                                                                                                      #
#                                                                                                      #
########################################################################################################

function Disable-HostInstances
{
    $hostInstances = Get-WmiObject MSBTS_HostInstance -Namespace root\MicrosoftBizTalkServer -Filter HostType=1

    foreach ($hostInstance in $hostinstances)
    {
        $hostInstance.IsDisabled = $true
        $hostInstance.Put() > $null
    }

    $hostInstances.Stop()
}

function Enable-HostInstances
{
    $hostInstances = Get-WmiObject MSBTS_HostInstance -Namespace root\MicrosoftBizTalkServer -Filter HostType=1

    foreach ($hostInstance in $hostinstances)
    {
        $hostInstance.IsDisabled = $false
        $hostInstance.Put() > $null
    }

    $hostInstances.Start()
}

function Stop-HostInstances
{
    $hostInstances = Get-WmiObject MSBTS_HostInstance -Namespace root\MicrosoftBizTalkServer -Filter HostType=1

    $hostInstances.Stop()
}

function Start-HostInstances
{
    $hostInstances = Get-WmiObject MSBTS_HostInstance -Namespace root\MicrosoftBizTalkServer -Filter HostType=1

    $hostInstances.Start()
}

Start-HostInstances
