using System.Management;  
  
//Sample to show how to save a tracked message out to a file folder using MSBTS_TrackedMessageInstance2 class  
public void SaveTrackedMessageInstanceToFolder(Guid MessageInstanceId, string strOutputFolder)  
{  
    try  
    {  
    // Construct full WMI path to the MSBTS_TrackedMessageInstance using the message guid (NOTE: MessageInstanceID string value must be enclosed in {} curly brackets)  
    string strInstanceFullPath = "root\\MicrosoftBizTalkServer:MSBTS_TrackedMessageInstance2.MessageInstanceID='{" + MessageInstanceId.ToString() + "}'";  

    // Load the MSBTS_TrackedMessageInstance  
    ManagementObject objTrackedSvcInst = new ManagementObject(strInstanceFullPath);  

    // Invoke "SaveToFile" method to save the message out into the specified folder  
    objTrackedSvcInst.InvokeMethod("SaveToFile", new object[] {strOutputFolder});  
    }  
    catch(Exception excep)  
    {  
    Console.WriteLine("Failed to save tracked message with id " + MessageInstanceId.ToString() + " into folder " + strOutputFolder + ": " + excep.Message);  
    }  
}  