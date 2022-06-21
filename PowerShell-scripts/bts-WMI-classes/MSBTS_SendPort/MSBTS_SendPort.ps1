########################################################################################################
#                                                                                                      #
# Author: Sandro Pereira                                                                               #
#                                                                                                      #
# Description: Use of the MSBTS_sendPort WMI Class.                                                    #
#                                                                                                      #
#                                                                                                      #
########################################################################################################

function BTS-Set-Send-Port-Status($name, $status)
{
    $sendport = Get-WmiObject MSBTS_sendPort -namespace 'root\MicrosoftBizTalkServer' -filter "Name=’$name'"

    switch ( $status )
    {
        'start' { 
            $sendport.psbase.invokemethod('Start', $null)
        }
        'stop' { 
            $sendport.psbase.invokemethod('Stop', $null)
        }
        'enlist' { 
            $sendport.psbase.invokemethod('Enlist', $null) 
        }
        'unenlist' { 
            $sendport.psbase.invokemethod('UnEnlist', $null) 
        }
    }
}

function BTS-List-Send-Ports()
{
   Get-WmiObject MSBTS_SendPort -namespace 'root\MicrosoftBizTalkServer'
}

function Start-Send-Port{
    param([string]$portName)

    $sp = Get-WmiObject MSBTS_SendPort -n root\MicrosoftBizTalkServer -filter "Name='$portName'"

    if($sp -ne $null)
    {
        if($sp.Status -eq 1 -or $sp.Status -eq 2)
        {
            if($sp.Status -eq 1)
            {
                $null = $sp.Enlist()
            }
            $null = $sp.Start()
            Write-Host "Started send port: " + $portName -fore Green
        }
        else
        {
            Write-Host "Send port " + $portName + " is already started." -fore Yellow
        }
    }
    else
    {
        Write-Host "Send port not found" -fore Red
    }
}

#Get Counters: Check if there are any disable receive locations and stopped/unelisted send ports
if ($sendports.count -ne (get-wmiobject MSBTS_SendPort -namespace 'root\MicrosoftBizTalkServer' -filter '(Status = 3)').count)
{
    [BOOL]$script:Continuescript = $True
    [INT]$countSendPorts = $sendports.count - $(get-wmiobject MSBTS_SendPort -namespace 'root\MicrosoftBizTalkServer' -filter {Status = 3}).count
}