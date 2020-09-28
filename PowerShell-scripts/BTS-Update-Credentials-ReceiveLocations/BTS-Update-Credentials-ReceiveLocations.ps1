##############################################################################################
# Script to properly update the credentials (username and password) on a list of 
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
# Get DB info
#############################################################
$catalog = New-Object Microsoft.BizTalk.ExplorerOM.BtsCatalogExplorer
$catalog.ConnectionString = "SERVER=$bizTalkDbServer;DATABASE=$bizTalkDbName;Integrated Security=SSPI"

#############################################################
# Update Credentials
#############################################################
foreach($receivePort in $catalog.ReceivePorts)
{
    # For each receive location in your environment
    foreach($recLocation in $receivePort.ReceiveLocations)
    {
        # In this case ...
        if($rcvLocations.Contains($recLocation.Name))
        {
            [xml]$bindingConfiguration = $recLocation.TransportTypeData
            if($bindingConfiguration.CustomProps.Password.vt -eq "1")
            {
                $bindingConfiguration.CustomProps.Password.InnerText = "my_password"
                $bindingConfiguration.CustomProps.Password.vt = "8"
            }
            else
            {
                $passwordElement = $bindingConfiguration.CreateElement("Password")
                $passwordElement.SetAttribute("vt", "8")
                $passwordElement.InnerText = "my_password"
                $bindingConfiguration.CustomProps.InsertAfter($passwordElement, $bindingConfiguration.CustomProps.SuspendMessageOnFailure)
            }
            if($bindingConfiguration.CustomProps.UserName.vt -eq "8")
            {
                $bindingConfiguration.CustomProps.UserName.InnerText = "my_username"
            }

            $transportConfigData = $bindingConfiguration.InnerXml
            $recLocation.TransportTypeData = $transportConfigData
        }
    }
}

$catalog.SaveChanges()
$catalog.Refresh()