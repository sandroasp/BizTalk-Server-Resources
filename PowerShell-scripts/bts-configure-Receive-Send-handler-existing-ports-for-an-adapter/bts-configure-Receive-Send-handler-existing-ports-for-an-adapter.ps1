##############################################################################################
# Script to properly configure the Receive and Send handler in each port present in 
# BizTalk Server environment for a specific adapter.
#
# Author: Sandro Pereira
##############################################################################################
[void] [System.reflection.Assembly]::LoadWithPartialName("Microsoft.BizTalk.ExplorerOM")

#############################################################
# Global Variables
#############################################################
[string] $bizTalkDbServer = "."
[string] $bizTalkDbName = "BizTalkMgmtDb"

#############################################################
# This function will create a handler for a specific 
# adapter on the new host, so these get used for processing.
# [direction]: 'Receive','Send'
#############################################################
function ConfigureBizTalkAdapterReceiveHandlerInExistingReceiveLocations(
	[string]$adapterName,
	[string]$defaulHostInstanceName)
{
    $catalog = New-Object Microsoft.BizTalk.ExplorerOM.BtsCatalogExplorer
    $catalog.ConnectionString = "SERVER=$bizTalkDbServer;DATABASE=$bizTalkDbName;Integrated Security=SSPI"

    # Let's look for receive handlers associated with the Adapter
    foreach ($handler in $catalog.ReceiveHandlers)
    {
         # if is a the correct Adapter Receive Handler
        if ($handler.TransportType.Name -eq $adapterName)
        {
            if($handler.Name -eq $defaulHostInstanceName)
            {
                foreach($receivePort in $catalog.ReceivePorts)
                {
                    # For each receive location in your environment
                    foreach($recLocation in $receivePort.ReceiveLocations)
                    {
                         # In this case I want only Receive location that are using SQL Adapter
                        if($recLocation.ReceiveHandler.TransportType.Name -eq $adapterName)
                        {
                            $recLocation.ReceiveHandler = $handler
                        }
                    }
                }
            }
        }
    }
    
    $catalog.SaveChanges()
}

function ConfigureBizTalkAdapterSendHandlerInExistingSendPorts(
	[string]$adapterName,
	[string]$defaulHostInstanceName)
{
    $catalog = New-Object Microsoft.BizTalk.ExplorerOM.BtsCatalogExplorer
    $catalog.ConnectionString = "SERVER=$bizTalkDbServer;DATABASE=$bizTalkDbName;Integrated Security=SSPI"


    # Let's look for send handlers associated with Adapter configured in the send port
    foreach ($handler in $catalog.SendHandlers)
    {
        # if the Send Handler is associated with the Adapter configured in the send port
        if ($handler.TransportType.Name -eq $adapterName)
        {
            if($handler.Name -eq $defaulHostInstanceName)
            {
                foreach($SendPort in $catalog.SendPorts)
                {
                    # For each receive location in your environment
                    if($sendPort.IsDynamic -eq $False)
                    {
                        if($sendPort.PrimaryTransport.TransportType.Name -eq $adapterName)
                        {
                            $sendPort.PrimaryTransport.SendHandler = $handler
                        }
                    }
                    if($sendPort.IsDynamic -eq 'True')
                    {
                        # Changing the default send handlers of the dynamic port
                        $sendPort.SetSendHandler($adapterName, $defaulHostInstanceName)
                    }
                }
            }
        }
    }

    $catalog.SaveChanges()
}

ConfigureBizTalkAdapterSendHandlerInExistingSendPorts 'SQL' 'BizTalkServerSend32Host'
ConfigureBizTalkAdapterReceiveHandlerInExistingReceiveLocations 'SQL' 'BizTalkServerReceive32Host'