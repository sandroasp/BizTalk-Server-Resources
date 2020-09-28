##############################################################################################
# Script to properly update the URI (address) or part of the URI on a list of
# Receive locations present in the environment.
#
# Author: Sandro Pereira
##############################################################################################

[System.reflection.Assembly]::LoadWithPartialName("Microsoft.BizTalk.ExplorerOM") | Out-Null

#############################################################
# Global Variables
#############################################################
[string] $bizTalkDbServer = "SQLSERVER"
[string] $bizTalkDbName = "BizTalkMgmtDb"
$rcvLocations = "RECEIVE_LOCATION_1","RECEIVE_LOCATION_2","RECEIVE_LOCATION_3"

#############################################################
# Get information from BizTalk DV
#############################################################
$catalog = New-Object Microsoft.BizTalk.ExplorerOM.BtsCatalogExplorer
$catalog.ConnectionString = "SERVER=$bizTalkDbServer;DATABASE=$bizTalkDbName;Integrated Security=SSPI"

#############################################################
# Update URI
#############################################################
foreach($receivePort in $catalog.ReceivePorts)
{
    # For each receive location in your environment
    foreach($recLocation in $receivePort.ReceiveLocations)
    {
        # In this case ...
        if($rcvLocations.Contains($recLocation.Name))
        {
            [string] $address = $recLocation.Address
            $address = $address.Replace("DEV-SERVER-NAME","PRO_SERVER-NAME")
            # Sample of additional custom changes
            if($address.Contains("PREFIX"))
            {
                $address = $address.Replace("DATABASE","DATABASE-WITH-PREFIX-A")
            }
            else
            {
                $address = $address.Replace("DATABASE","DATABASE-WITH-PREFIX-B")
            }
            $recLocation.Address = $address
        }
    }
}

$catalog.SaveChanges()
$catalog.Refresh()