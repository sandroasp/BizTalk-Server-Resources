using System.Management;  
  
// This sample takes an outbound URL, queries for any suspended (resumable) service instances associating with this  
// URL (via Send Port primary or secondary transport address) and then resume the service instances found.  The strOutboundURL  
// supports WQL LIKE-style pattern matching.  
//  
// NOTE: If strOutboundURL contains any backslash characters, they must be properly escaped. (e.g. "C:\\TEMP\\Out")  
//  
public void ResumeSvcInstByOutboundURL(string strOutboundURL)  
{  
    try  
    {  
        const uint SERVICE_STATUS_SUSPENDED_RESUMABLE = 4;  
        const uint REGULAR_RESUME_MODE = 1;  

        // Find all SendPort(s) which transmit to strOutboundURL either as primary or secondary transport address.  Comparison  
        // is done using the LIKE operator so SQL-style pattern matching can be used. (e.g. "%ABC%" will match any strings that  
        // contains "ABC" in it.  
        string strSendPortWQL = string.Format(  
        "SELECT * FROM MSBTS_SendPort WHERE PTAddress LIKE \"{0}\" OR STAddress LIKE \"{1}\"",  
        strOutboundURL, strOutboundURL);  

        ManagementObjectSearcher searcherSendPort = new ManagementObjectSearcher (new ManagementScope ("root\\MicrosoftBizTalkServer"), new WqlObjectQuery(strSendPortWQL), null);  
        int nNumSendPortFound = searcherSendPort.Get().Count;  

        if ( nNumSendPortFound > 0 )  
        {  
        bool fSvcInstFound = false;  

        // For each associating send port that we found  
        foreach ( ManagementObject objSendPort in searcherSendPort.Get() )  
        {  
            // Construct the WQL to find suspended service instance associating with the send port  
            string strSvcInstWQL = string.Format(  
                "SELECT * FROM MSBTS_ServiceInstance WHERE ServiceStatus = {0} AND ServiceName = \"{1}\"",  
                SERVICE_STATUS_SUSPENDED_RESUMABLE.ToString(), objSendPort["Name"]);  

            ManagementObjectSearcher searcherServiceInstance = new ManagementObjectSearcher (new ManagementScope ("root\\MicrosoftBizTalkServer"), new WqlObjectQuery(strSvcInstWQL), null);  
            int nNumSvcInstFound = searcherServiceInstance.Get().Count;  

            // If we found any matching suspended service instance(s)  
            if ( nNumSvcInstFound > 0 )  
            {  
                fSvcInstFound = true;  

                // Construct ID arrays to be passed into ResumeServiceInstancesByID() method  
                string[] InstIdList = new string[nNumSvcInstFound];  
                string[] ClassIdList = new string[nNumSvcInstFound];  
                string[] TypeIdList = new string[nNumSvcInstFound];  

                string strHost = string.Empty;  
                string strReport = string.Empty;  
                int i = 0;  
                foreach ( ManagementObject objServiceInstance in searcherServiceInstance.Get() )  
                {  
                    // It is safe to assume that all service instances of a send port belong to a single Host.  
                    if ( strHost == string.Empty )  
                    strHost = objServiceInstance["HostName"].ToString();  

                    ClassIdList[i] = objServiceInstance["ServiceClassId"].ToString();  
                    TypeIdList[i]  = objServiceInstance["ServiceTypeId"].ToString();  
                    InstIdList[i]  = objServiceInstance["InstanceID"].ToString();  

                    strReport += string.Format("  {0}\n", objServiceInstance["InstanceID"].ToString());  
                    i++;  
                }  

                // Load the MSBTS_HostQueue with Host name and invoke the "ResumeServiceInstancesByID" method  
                string strHostQueueFullPath = string.Format("root\\MicrosoftBizTalkServer:MSBTS_HostQueue.HostName=\"{0}\"", strHost);  
                ManagementObject objHostQueue = new ManagementObject(strHostQueueFullPath);  

                // Note: The ResumeServiceInstanceByID() method processes at most 2047 service instances with each call.  
                //   If you are dealing with larger number of service instances, this script needs to be modified to break down the  
                //   service instances into multiple batches.  
                objHostQueue.InvokeMethod("ResumeServiceInstancesByID",  
                    new object[] {ClassIdList, TypeIdList, InstIdList, REGULAR_RESUME_MODE}  
                    );  

                Console.WriteLine( string.Format("Service instances with the following service instance IDs have been resumed:\n{0}", strReport) );  
            }  
        }  
        if ( !fSvcInstFound )  
        {  
            System.Console.WriteLine(string.Format("There is no suspended (resumable) service instance associating with outbound URL '{0}'.", strOutboundURL));  
        }  
        }  
        else  
        {  
        System.Console.WriteLine(string.Format("There is no send port associating with outbound URL '{0}'.", strOutboundURL));  
        }  
    }  
    catch(Exception excep)  
    {  
        Console.WriteLine("Error: " + excep.Message);  
    }  
}  
