public void ResetAdapters(string pathToXMLFile)
{
    // Load the Config XML
    XmlDocument oDoc = new XmlDocument();
    oDoc.Load(pathToXMLFile);

    string defaulInProcessHost = oDoc.DocumentElement.GetAttribute("defaultHost").ToString();
    string defaulIsoHost = oDoc.DocumentElement.GetAttribute("defaultIsoHost").ToString();

    try
    {
        PutOptions options = new PutOptions();
        options.Type = PutType.UpdateOnly;

        //Look for the target WMI Class MSBTS_ReceiveHandler instance
        string strWQL = "SELECT * FROM MSBTS_ReceiveHandler";
        ManagementObjectSearcher searcherReceiveHandler = new ManagementObjectSearcher(new ManagementScope("root\\MicrosoftBizTalkServer"), new WqlObjectQuery(strWQL), null);

        string recName;
        string recHost;
        string sndName;
        string sndHost;

        if (searcherReceiveHandler.Get().Count > 0)
            foreach (ManagementObject objReceiveHandler in searcherReceiveHandler.Get())
            {
                //Get the Adapter Name
                recName = objReceiveHandler["AdapterName"].ToString();

                // Get the Current Host
                recHost = objReceiveHandler["HostName"].ToString();

                // Find the Host Type
                string strWQLHost = "SELECT * FROM MSBTS_HostInstanceSetting where HostName = '" + recHost + "'";
                ManagementObjectSearcher searcherHostHandler = new ManagementObjectSearcher(new ManagementScope("root\\MicrosoftBizTalkServer"), new WqlObjectQuery(strWQLHost), null);

                foreach (ManagementObject objHostHandler in searcherHostHandler.Get())
                {
                    // Type 1 is In Process
                    if (objHostHandler["HostType"].ToString() == "1")
                    {
                        objReceiveHandler.SetPropertyValue("HostNameToSwitchTo", defaulInProcessHost);
                        objReceiveHandler.Put();
                    }
                    // Otherwise it is Isolated
                    else
                    {
                        objReceiveHandler.SetPropertyValue("HostNameToSwitchTo", defaulIsoHost);
                        objReceiveHandler.Put();
                    }
                }

                Console.WriteLine( "Receive Adapters: - " + recName + " \r\n");
            }

        //Look for the target WMI Class MSBTS_SendHandler instance
        string strWQLsnd = "SELECT * FROM MSBTS_SendHandler2";
        ManagementObjectSearcher searcherSendHandler = new ManagementObjectSearcher(new ManagementScope("root\\MicrosoftBizTalkServer"), new WqlObjectQuery(strWQLsnd), null);

        if (searcherSendHandler.Get().Count > 0)
            foreach (ManagementObject objSendHandler in searcherSendHandler.Get())
            {
                //Get the Adapter Name
                sndName = objSendHandler["AdapterName"].ToString();

                // Get the Current Host
                sndHost = objSendHandler["HostName"].ToString();

                // Find the Host Type
                string strWQLHost = "SELECT * FROM MSBTS_HostInstanceSetting where HostName = '" + sndHost + "'";
                ManagementObjectSearcher searcherHostHandler = new ManagementObjectSearcher(new ManagementScope("root\\MicrosoftBizTalkServer"), new WqlObjectQuery(strWQLHost), null);

                foreach (ManagementObject objHostHandler in searcherHostHandler.Get())
                {
                    // Type 1 is In Process
                    if (objHostHandler["HostType"].ToString() == "1")
                    {
                        objSendHandler.SetPropertyValue("HostNameToSwitchTo", defaulInProcessHost);
                        objSendHandler.Put();
                    }
                    // Otherwise it is Isolated
                    else
                    {
                        objSendHandler.SetPropertyValue("HostNameToSwitchTo", defaulIsoHost);
                        objSendHandler.Put();
                    }
                }

                Console.WriteLine( "Send Adapters: - " + sndName + " \r\n");
            }

        Console.WriteLine( "Done");
    }
    catch (Exception ex)
    {
        Console.WriteLine( ex.Message);
    }
}