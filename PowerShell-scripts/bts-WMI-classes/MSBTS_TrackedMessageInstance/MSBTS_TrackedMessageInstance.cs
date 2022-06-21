public stringGetMessageWithWMI(GuidMessageInstanceId)
{
    try
    {
        // Construct full WMI path to the MSBTS_TrackedMessageInstance using the message guid (NOTE: MessageInstanceID string value must be enclosed in {} curly brackets)
        string strInstanceFullPath = "\\\\.\\root\\MicrosoftBizTalkServer:MSBTS_TrackedMessageInstance.MessageInstanceID='{"+ MessageInstanceId.ToString() + "}'";
        // Load the MSBTS_TrackedMessageInstance
        ManagementObject objTrackedSvcInst = new ManagementObject(strInstanceFullPath);
        // Invoke "SaveToFile" method to save the message out into the specified folder
        objTrackedSvcInst.InvokeMethod("SaveToFile", new object[] {Application.StartupPath});
        //Get all files in the directory starting with this messageid
        string[] files = Directory.GetFiles(Application.StartupPath, "{"+ MessageInstanceId.ToString() + "*.*");
        string message = "";
        foreach (string file in files)
        {
            if(file.EndsWith(".out"))
            {
                using (StreamReadersr = new StreamReader(file))
                {
                    message = sr.ReadToEnd();
                }
            }
        }
        foreach (string file in files)
        {
            System.IO.File.Delete(file);
        }
        if (files.Length == 0)
        {
            throw new Exception("No files found on folder that match the GUID");
        }
        return message;
    }
    catch (ExceptionexWMI)
    {
        return "Failed to save tracked message with id "+ MessageInstanceId.ToString() + " into folder " + Application.StartupPath + ": "+ exWMI.Message;
    }
}