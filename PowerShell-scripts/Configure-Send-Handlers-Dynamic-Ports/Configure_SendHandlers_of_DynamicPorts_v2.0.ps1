[string] $bizTalkDbServer = "BTSSQL\INSTANCE"
[string] $bizTalkDbName = "BizTalkMgmtDb"
# Optional if you want to specify a single Dynamic Send Port
# [string] $sendPortName = "ResendPort" 

[string] $sendHost32bits = "BizTalkServerSend32Host"
[string] $sendHost64bits = "BizTalkServerSendHost"

[System.reflection.Assembly]::LoadWithPartialName("Microsoft.BizTalk.ExplorerOM") | Out-Null

$catalog = New-Object Microsoft.BizTalk.ExplorerOM.BtsCatalogExplorer
$catalog.ConnectionString = "SERVER=$bizTalkDbServer;DATABASE=$bizTalkDbName;Integrated Security=SSPI"

foreach($sendPort in $catalog.SendPorts)
{
    # Optional if you want to specify a single Dynamic Send Port
    # if($sp.Name -eq $sendPortName)
    if($sendPort.IsDynamic -eq 'True')
    {
        # A Dynamic send port was found so now we need to configure the send handler as desired
        # 64 bits adapters
        # Changing the default send handlers of the dynamic port
        $sendPort.SetSendHandler("FILE", $sendHost64bits)
        $sendPort.SetSendHandler("HTTP", $sendHost64bits)
        $sendPort.SetSendHandler("MQSeries", $sendHost64bits)
        $sendPort.SetSendHandler("MSMQ", $sendHost64bits)
        $sendPort.SetSendHandler("SB-Messaging", $sendHost64bits)
        $sendPort.SetSendHandler("SFTP", $sendHost64bits)
        $sendPort.SetSendHandler("SOAP", $sendHost64bits)
        $sendPort.SetSendHandler("SMTP", $sendHost64bits)
        $sendPort.SetSendHandler("WCF-BasicHttp", $sendHost64bits)
        $sendPort.SetSendHandler("WCF-BasicHttpRelay", $sendHost64bits)
        $sendPort.SetSendHandler("WCF-Custom", $sendHost64bits)
        $sendPort.SetSendHandler("WCF-NetMsmq", $sendHost64bits)
        $sendPort.SetSendHandler("WCF-NetNamedPipe", $sendHost64bits)
        $sendPort.SetSendHandler("WCF-NetTcp", $sendHost64bits)
        $sendPort.SetSendHandler("WCF-NetTcpRelay", $sendHost64bits)
        $sendPort.SetSendHandler("WCF-SQL", $sendHost64bits)
        $sendPort.SetSendHandler("WCF-WebHttp", $sendHost64bits)
        $sendPort.SetSendHandler("WCF-WSHttp", $sendHost64bits)
        $sendPort.SetSendHandler("Windows SharePoint Services", $sendHost64bits)
            

        # 32 bits adapters
        # SMTP Supports 64 bits but I want to run in 32 because of the MIME/SMIME Encoder
        $sendPort.SetSendHandler("FTP", $sendHost32bits)
        $sendPort.SetSendHandler("SQL", $sendHost32bits)
    }
}

$catalog.SaveChanges()