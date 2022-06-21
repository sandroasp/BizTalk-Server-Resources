########################################################################################################
#                                                                                                      #
# Author: Sandro Pereira                                                                               #
#                                                                                                      #
# Description: Use of the MSBTS_SendPortGroup2SendPort  WMI Class.                                     #
#                                                                                                      #
#                                                                                                      #
########################################################################################################

########################################################################################################
# Function to display all information about a send port group
########################################################################################################
function BTS-Display-Send-Port-Group($group)
{
    $groupname = $group.Name

    $ports = Get-WmiObject MSBTS_SendPortGroup2SendPort -namespace 'root\MicrosoftBizTalkServer' -filter "SendPortGroupName='$groupName'"

    Write-Host $groupname
    foreach ($port in $ports) 
    { 
        "`t" + $port.SendPortName 
    }
}