[string] $bizTalkDbServer = "BTSSQL\INSTANCE"
[string] $bizTalkDbName = "BizTalkMgmtDb"

[System.reflection.Assembly]::LoadWithPartialName("Microsoft.BizTalk.ExplorerOM") | Out-Null

$catalog = New-Object Microsoft.BizTalk.ExplorerOM.BtsCatalogExplorer
$catalog.ConnectionString = "SERVER=$bizTalkDbServer;DATABASE=$bizTalkDbName;Integrated Security=SSPI"

foreach($receivePort in $catalog.ReceivePorts)
{
    # For each receive location in your environment
    foreach($recLocation in $receivePort.ReceiveLocations)
    {
        # In this case I want only Receive location that are using SQL Adapter
        if($recLocation.ReceiveHandler.TransportType.Name -eq 'SQL')
        {
            # Let's look for receive handlers associated with SQL Adapter
            foreach ($handler in $catalog.ReceiveHandlers)
            {
                # if is a SQL Adapter Receive Handler
                if ($handler.TransportType.Name -eq "SQL")
                {
                    # And is not BizTalkServerApplication, then configure that as the handler of the receive location
                    # Note: that in this case we will configure as a Receive Handler of the Receive location, the first 
                    #       receive handler that we find that is not the "BizTalkServerApplication"
                    #       because the goal is to delete this handler
                    if($handler.Name -ne 'BizTalkServerApplication')
                    { 
                        $recLocation.ReceiveHandler = $handler
                        break
                    }
                }
            }
        }
    }
}

$catalog.SaveChanges()