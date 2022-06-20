/// <summary>
/// Create a Send Handler.
/// </summary>
/// <param name="adapterName">The Adapter name.</param>
/// <param name="hostName">The Host name.</param>
/// <param name="isDefault">Indicating if the Handler is the default.</param>
public static void Create(string adapterName, string hostName, bool isDefault)
{
    PutOptions options = new PutOptions();
    options.Type = PutType.CreateOnly;
    using (ManagementClass handlerManagementClass = new ManagementClass("root\\MicrosoftBizTalkServer", "MSBTS_SendHandler", null))
    {
        foreach (ManagementObject handler in handlerManagementClass.GetInstances())
        {
            if ((string)handler["AdapterName"] == adapterName && (string)handler["HostName"] == hostName)
            {
                handler.Delete();
            }
        }

        ManagementObject handlerInstance = handlerManagementClass.CreateInstance();
        if (handlerInstance == null)
        {
            throw new CoreException("Could not create Management Object.");
        }

        handlerInstance["AdapterName"] = adapterName;
        handlerInstance["HostName"] = hostName;
        handlerInstance["IsDefault"] = isDefault;
        handlerInstance.Put(options);
    }
}