##############################################################################################
# Script to properly update the credentials (username and password) on a list of 
# Send Ports present in the environment.
#
# Author: Sandro Pereira
##############################################################################################

[System.reflection.Assembly]::LoadWithPartialName("Microsoft.BizTalk.ExplorerOM") | Out-Null

#############################################################
# Global Variables
#############################################################
[string] $bizTalkDbServer = "BTS2020LAB01"
[string] $bizTalkDbName = "BizTalkMgmtDb"
$sndPorts = "SendPort1","SQL_UPDATEDEMO_A_SENDPORT"

#############################################################
# Update Credentials
#############################################################
$catalog = New-Object Microsoft.BizTalk.ExplorerOM.BtsCatalogExplorer
$catalog.ConnectionString = "SERVER=$bizTalkDbServer;DATABASE=$bizTalkDbName;Integrated Security=SSPI"

foreach($SendPort in $catalog.SendPorts)
{
    # In this case ...
    if($sndPorts.Contains($SendPort.Name))
    {
        [xml]$bindingConfiguration = $SendPort.PrimaryTransport.TransportTypeData
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
            if($SendPort.PrimaryTransport.TransportType.Name -eq "FILE")
            {
                $bindingConfiguration.CustomProps.InsertAfter($passwordElement, $bindingConfiguration.CustomProps.CopyMode)
            }
            else {
                $bindingConfiguration.CustomProps.InsertAfter($passwordElement, $bindingConfiguration.CustomProps.EnableTransaction)
            }
            
        }
        if($bindingConfiguration.CustomProps.UserName.vt -eq "8")
        {
            $bindingConfiguration.CustomProps.UserName.InnerText = "my_username"
        }

        $transportConfigData = $bindingConfiguration.InnerXml
        $SendPort.PrimaryTransport.TransportTypeData = $transportConfigData
    }
}

$catalog.SaveChanges()
$catalog.Refresh()