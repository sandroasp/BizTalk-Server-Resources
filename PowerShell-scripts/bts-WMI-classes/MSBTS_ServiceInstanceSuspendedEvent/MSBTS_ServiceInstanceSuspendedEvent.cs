using System.Management;  
  
static public void ListenForSvcInstSuspendEvent()  
{  
    try  
    {  
    // Set up an event watcher and a handler for the MSBTS_ServiceInstanceSuspendedEvent event  
    ManagementEventWatcher watcher = new ManagementEventWatcher( new ManagementScope("root\\MicrosoftBizTalkServer"),  
        new EventQuery("SELECT * FROM MSBTS_ServiceInstanceSuspendedEvent") );  

    watcher.EventArrived += new EventArrivedEventHandler(MyEventHandler);  

    // Start watching for MSBTS_ServiceInstanceSuspendedEvent events  
    watcher.Start();  

    while (true)  
    {  
        System.Threading.Thread.Sleep(1000);  
    }  
    }  
    catch (Exception excep)  
    {  
    Console.WriteLine("Error: " + excep.Message);  
    }  
}  

static public void MyEventHandler(object sender, EventArrivedEventArgs e)   
{  
    // Print out the service instance ID and error description upon receiving of the suspend event  
    Console.WriteLine("A MSBTS_ServiceInstanceSuspendEvent has occurred!");  
    Console.WriteLine(string.Format("ServiceInstanceID: {0}", e.NewEvent["InstanceID"]));  
    Console.WriteLine(string.Format("ErrorDescription: {0}", e.NewEvent["ErrorDescription"]));  
    Console.WriteLine("");  
}  