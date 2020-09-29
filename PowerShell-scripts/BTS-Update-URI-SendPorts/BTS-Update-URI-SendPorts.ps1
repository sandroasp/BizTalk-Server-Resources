##############################################################################################
# Script to properly update the URI (address) or part of the URI on a list of
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
$sndPorts = "SendPort2","SQL_UPDATEDEMO_A_SENDPORT"

#############################################################
# Get information from BizTalk DV
#############################################################
$catalog = New-Object Microsoft.BizTalk.ExplorerOM.BtsCatalogExplorer
$catalog.ConnectionString = "SERVER=$bizTalkDbServer;DATABASE=$bizTalkDbName;Integrated Security=SSPI"

foreach($SendPort in $catalog.SendPorts)
{
    # In this case ...
    if($sndPorts.Contains($SendPort.Name))
    {
        [string] $address = $SendPort.PrimaryTransport.Address

        if($address.Contains("mssql://"))
        {
            $address = $address.Replace("mssql://.","mssql://BTS2020LAB01")
        }
        else
        {
            $address = $address.Replace("C:\","D:\")
        }
        $SendPort.PrimaryTransport.Address = $address
    }
}

$catalog.SaveChanges()
$catalog.Refresh()