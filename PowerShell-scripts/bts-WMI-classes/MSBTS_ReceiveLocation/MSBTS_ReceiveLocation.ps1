########################################################################################################
#                                                                                                      #
# Author: Sandro Pereira                                                                               #
#                                                                                                      #
# Description: Use of the MSBTS_ReceiveLocation WMI Class.                                             #
#                                                                                                      #
#                                                                                                      #
########################################################################################################

########################################################################################################
# Function to stop a receive location
########################################################################################################
Function Stop-Receive-Location($receiveLocationName)
{
	$name_filter = "Name='$receiveLocationName'"
	
	try {
        $recvloc = Get-WmiObject MSBTS_ReceiveLocation -namespace 'root\MicrosoftBizTalkServer' -filter $name_filter
		if ($recvloc)
		{
			[void]$recvloc.Disable()
		}
		else
		{
			write-host -foregroundcolor "yellow" "Could not find receive location $receiveLocationName"
		}
	}
	catch
	{
		write-host -foregroundcolor "red" "$_.Exception.Message"	
		return $FALSE
	}
	return $TRUE
}

########################################################################################################
# Function to star receive location
########################################################################################################
Function Start-Receive-Location($receiveLocationName)
{
	$name_filter = "Name='$receiveLocationName'"

	try
	{
		$recvloc = Get-WmiObject MSBTS_ReceiveLocation -namespace 'root\MicrosoftBizTalkServer' -filter $name_filter
		if ($recvloc)
		{
			[void]$recvloc.Enable()
		}
		else
		{
			write-host -foregroundcolor "yellow" "Could not find receive location $receiveLocationName"
		}
	}		  
	catch
	{
		write-host -foregroundcolor "red" "$_.Exception.Message"		
		return $FALSE
	}
	return $TRUE
}

########################################################################################################
# Function to display all information about a receive port
########################################################################################################
Function Display-Receive-Port-Locations($port)
{
   $portname = $port.Name
   $recvlocs = Get-WmiObject MSBTS_ReceiveLocation -namespace ‘root\MicrosoftBizTalkServer’ -filter “ReceivePortName=’$portName'”

   $recvlocs | ft Name, AdapterName, InboundTransportURL, IsDisabled
}