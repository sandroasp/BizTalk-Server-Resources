[string] $bizTalkDbServer = "BTSSQL\INSTANCE"
[string] $bizTalkDbName = "BizTalkMgmtDb"

[System.reflection.Assembly]::LoadWithPartialName("Microsoft.BizTalk.ExplorerOM") | Out-Null

$catalog = New-Object Microsoft.BizTalk.ExplorerOM.BtsCatalogExplorer
$catalog.ConnectionString = "SERVER=$bizTalkDbServer;DATABASE=$bizTalkDbName;Integrated Security=SSPI"

foreach($SendPort in $catalog.SendPorts)
{
    # For each receive location in your environment
    if($sendPort.IsDynamic -eq $False)
    {
        # Let's look for send handlers associated with Adapter configured in the send port
        foreach ($handler in $catalog.SendHandlers)
        {
            # if the Send Handler is associated with the Adapter configured in the send port
            if ($handler.TransportType.Name -eq $sendPort.PrimaryTransport.TransportType.Name)
            {
                # We will configured the port with the default send handler associated in each adapter in you system  
                # independently if it is "BizTalkServerApplication" or not.
                # Note: it's is recomended that you first configure the default send handlers for each adapter 
                #       and also not to use the "BizTalkServerApplication" (my personal recomendation)
                if($handler.IsDefault)
                { 
                    $sendPort.PrimaryTransport.SendHandler = $handler
                    break
                }
            }
        }
    }
}

$catalog.SaveChanges()