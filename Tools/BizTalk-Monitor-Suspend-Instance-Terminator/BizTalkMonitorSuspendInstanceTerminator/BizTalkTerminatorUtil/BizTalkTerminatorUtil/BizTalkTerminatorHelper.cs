/*###############################################################################################################################
  # THIS CODE AND INFORMATION ARE PROVIDED "AS IS" WITHOUT WARRANTY OF ANY KIND, EITHER EXPRESSED OR IMPLIED,                   #
  # INCLUDING BUT NOT LIMITED TO THE IMPLIED WARRANTIES OF MERCHANTABILITY AND/OR FITNESS FOR A PARTICULAR PURPOSE.             #
  #    You can use, modify and redistribute this code in your product as per the Apache License, which governs this project.    #
  #                                                                                                                             #
  # BizTalk Terminator Helper that invokes the WatchMan.                                                                        #
  ###############################################################################################################################*/

using System;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using System.Management;
using System.Reflection;
using System.Text;
using System.Threading;
using System.Threading.Tasks;

namespace BizTalkTerminatorUtil
{
    /// <summary>
    /// This is a main worker class that works around the clock and keeps an eye for Suspended Service Instances.
    /// This setups a WatchMan for Suspended Services based on a given polling interval, maximum retries and a delay Factory.
    /// </summary>
    public class BizTalkTerminatorHelper
    {
        #region Property Declaration        
        
        /// <summary>
        /// 
        /// </summary>
        private int PollingInterval = 30;

        /// <summary>
        /// 
        /// </summary>
        private int MaximumRetries = 3;

        /// <summary>
        /// 
        /// </summary>
        private int MaximumRetryDelayFactor = 10;

        /// <summary>
        /// 
        /// </summary>
        private int RetryCount = 0;

        /// <summary>
        /// 
        /// </summary>
        private List<string> QueryString = new List<string>();

        /// <summary>
        /// BizTalk Database Server Hostname\\InstanceName where InstanceName is applicable, if not just the SQL Server HostName.
        /// </summary>
        private string BTSMgmtDbHostName;

        /// <summary>
        /// BizTalk Magement Database TableName. Defaults: BizTalkMgmtDb.
        /// </summary>
        private string BTSMgmtDBName;
        #endregion

        /// <summary>
        /// Initializes a new instance of the <see cref="BizTalkTerminatorHelper"/> class.
        /// </summary>
        /// <param name="PI">The PI.</param>
        /// <param name="maxRetries">The max retries.</param>
        /// <param name="delayFactor">The delay factor.</param>
        public BizTalkTerminatorHelper(int PI, int maxRetries, int delayFactor)
        {            
            // If Polling Interval is less than 5 seconds or greater than 5 minutes, then set it to default value of 30 seconds.
            if (PI < 5 && PI > 300)
            {
                this.PollingInterval = 30;
            }
            else
            {
                this.PollingInterval = PI;
            }

            // If Maximum Retries is less than 3 seconds or greater than 99 times, then set it to default value of 3 retries.
            if (maxRetries < 3 && maxRetries > 99)
            {
                this.MaximumRetries = 3;
            }
            else
            {
                this.MaximumRetries = maxRetries;
            }

            // If Maximum Delay Factor is less than 0 or greater than 288 (24 hours), then set it to default value of 10 as factor.
            if (delayFactor <= 0 && delayFactor > 288)
            {
                this.MaximumRetryDelayFactor = 10;
            }

            //AppDomain.CurrentDomain.AssemblyResolve += new ResolveEventHandler(Resolver);
        }

        /// <summary>
        /// Invokes a Watch for Suspended Service Instances using a Thread.
        /// This is the method called by Windows Service (BizTalkTerminatorService)
        /// </summary>
        public void InvokeWatchMan(ServiceFilterCollection serviceFilters,
                                   string databaseInstance = "localhost", string biztalkMgmtDatabaseName = "BizTalkMgmtDb")
        {
            this.BTSMgmtDbHostName = databaseInstance;
            this.BTSMgmtDBName = biztalkMgmtDatabaseName;

            foreach (ServiceFilter serviceFilter in serviceFilters)
            {
                string serviceClass = serviceFilter.ServiceClass;
                string serviceStatus = serviceFilter.ServiceStatus;
                string errorId = serviceFilter.ErrorId;
                string tempQueryString = string.Empty;

                // Dynamically build the required QueryString based on what the user has provided amongst the given options, options itself are [serviceClass, serviceStatus, errorId]
                if (!string.IsNullOrWhiteSpace(serviceClass))
                {
                    // ServiceClass is present
                    tempQueryString = string.Format(Constants.ServiceInstanceServiceClassQuery, serviceClass);

                    if (!string.IsNullOrWhiteSpace(serviceStatus))
                    {
                        // ServiceClass and ServiceStatus are present
                        tempQueryString = string.Format(Constants.ServiceInstanceServiceClassAndStatusQuery, serviceClass, serviceStatus);
                        if (!string.IsNullOrWhiteSpace(errorId))
                        {
                            // ServiceClass, ServiceStatus and ErrorId all are present
                            tempQueryString = string.Format(Constants.ServiceInstanceAllQuery, serviceClass, serviceStatus, errorId);
                        }
                    }
                }
                else if (!string.IsNullOrWhiteSpace(serviceStatus))
                {
                    // ServiceStatus is present
                    tempQueryString = string.Format(Constants.ServiceInstanceServiceStatusQuery, serviceStatus);
                    if (!string.IsNullOrWhiteSpace(errorId))
                    {
                        // ServiceStatus and ErrorId are present
                        tempQueryString = string.Format(Constants.ServiceInstanceServiceStatusAndErrorQuery, serviceStatus, errorId);
                    }
                }
                else if (!string.IsNullOrWhiteSpace(errorId))
                {
                    tempQueryString = string.Format(Constants.ServiceInstanceErrorIdQuery, errorId);
                }
                else
                {
                    throw new ArgumentException("You cannot invoke the watch for suspended instances without providing any of the following [ServiceClass or ServiceStatus or ErrorId].");
                }

                this.QueryString.Add(tempQueryString);
                tempQueryString = string.Empty;
            }

            Thread serviceThread = new Thread(new ThreadStart(WatchForSuspendedServiceInstances));
            serviceThread.Start();            
        }

        /// <summary>
        /// Watches for suspended service instances.
        /// </summary>
        public void WatchForSuspendedServiceInstances()
        {
            try
            {
                while (true)
                {
                    List<ManagementObjectCollection> instances = this.GetSuspendedServiceInstances();
                    if (instances != null)
                    {                        
                        if (instances.Count > 0)
                        {        
                            SpanTerminateServiceInstancesTasks(instances);
                        }
                    }
                    System.Diagnostics.Debug.WriteLine("BizTalkTerminator: Sleeping for [" + this.PollingInterval + "] seconds");
                    System.Threading.Thread.Sleep(this.PollingInterval * 1000);
                }
            }
            catch (Exception exception)
            {
                System.Diagnostics.Debug.WriteLine("BizTalkTerminator: Caught Exception: " + exception.Message + "\n" + exception.StackTrace 
                                                    + "\n" + exception.InnerException + "\n" + exception.ToString());
                int delayFactor = this.PollingInterval * 1000 * this.MaximumRetryDelayFactor;
                System.Threading.Thread.Sleep(delayFactor);

                this.RetryCount = this.RetryCount + 1;
                if (this.RetryCount <= this.MaximumRetries)
                {
                    WatchForSuspendedServiceInstances();
                }
                else
                {
                    throw new Exception("Maximum Retries reached. User intervention is required. " +
                                        "Then restart the service. Inner Exception Message: " + exception.Message);
                }
            }
        }

        /// <summary>
        /// Gets the suspended service instances.
        /// </summary>
        /// <returns></returns>
        private ManagementObjectCollection GetSuspendedServiceInstances1()
        {            
            ManagementObjectSearcher searcherInstance =
                new ManagementObjectSearcher(
                    new ManagementScope("root\\MicrosoftBizTalkServer"), new WqlObjectQuery(this.QueryString[0]), null);
            
            if (searcherInstance != null)
            {
                return searcherInstance.Get();
            }
            else
            {
                return null;
            }
        }

        /// <summary>
        /// Gets the suspended service instances.
        /// </summary>
        /// <returns></returns>
        private List<ManagementObjectCollection> GetSuspendedServiceInstances()
        {
            List<ManagementObjectCollection> instanceCollections = new List<ManagementObjectCollection>();
           
            Parallel.ForEach(this.QueryString, queryString =>
                {
                    System.Diagnostics.Debug.WriteLine("BizTalkTerminator: Using Query[" + queryString + "]");
                    ManagementObjectSearcher searcherInstance =
                    new ManagementObjectSearcher(
                        new ManagementScope("root\\MicrosoftBizTalkServer"), new WqlObjectQuery(queryString), null);

                    instanceCollections.Add(searcherInstance.Get());
               });

             return instanceCollections;
        }

        /// <summary>
        /// Spans the terminate service instances tasks.
        /// </summary>
        /// <param name="instances">The instances.</param>
        private void SpanTerminateServiceInstancesTasks(List<ManagementObjectCollection> instances)
        {
            if (instances != null)
            {
                System.Diagnostics.Debug.WriteLine("BizTalkTerminator: Terminating multiple instances of suspended messages.");

                Parallel.ForEach(instances, instance =>
                    {
                        Microsoft.BizTalk.Operations.BizTalkOperations operation = null;
                        try
                        {
                             operation = new Microsoft.BizTalk.Operations.BizTalkOperations(this.BTSMgmtDbHostName, this.BTSMgmtDBName);
                        }
                        catch (System.Data.SqlClient.SqlException sqlException)
                        {
                            System.Diagnostics.Debug.WriteLine("BizTalkTerminator: Caught SQLException: " + sqlException.Message);
                            operation = null;
                        }

                        if (operation != null && instance != null)
                        {
                            System.Diagnostics.Debug.WriteLine("BizTalkTerminator: Terminating [" +  instance.Count + "] suspended routing failures");
                            ParallelOptions options = Constants.ConcurrencyOption;
                            Parallel.ForEach(instance.Cast<ManagementObject>(), innerInstance =>
                                {
                                    try
                                    {
                                        operation.TerminateInstance(new Guid(innerInstance["InstanceId"].ToString()));
                                    }
                                    catch (System.Data.SqlClient.SqlException sqlException)
                                    {
                                        System.Diagnostics.Debug.WriteLine("BizTalkTerminator: Caught SQLException While Terminating: " + sqlException.Message);                                        
                                    }
                                }
                            );
                        }
                    });
            }
        }

        /// <summary>
        /// Resolvers the specified sender.
        /// </summary>
        /// <param name="sender">The sender.</param>
        /// <param name="args">The <see cref="System.ResolveEventArgs"/> instance containing the event data.</param>
        /// <returns></returns>
        //public static Assembly Resolver(object sender, ResolveEventArgs args)
        //{
        //    //System.Diagnostics.Debug.WriteLine("LoadTestRamper: Resolve: [" + args.Name + "]");
        //    var fileName = "Microsoft.BizTalk.Operations.dll";
        //    Assembly a1 = Assembly.GetExecutingAssembly();
        //    Stream s = a1.GetManifestResourceStream(fileName);
        //    if (s == null)
        //    {
        //        //System.Diagnostics.Debug.WriteLine("LoadTestRamper: UnResolved: [" + fileName + "]");
        //        throw new FileNotFoundException("BizTalkTerminator: Cannot find assembly in the embedded resource.", fileName);
        //    }
        //    byte[] block = new byte[s.Length];
        //    s.Read(block, 0, block.Length);
        //    Assembly a2 = Assembly.Load(block);
        //    System.Diagnostics.Debug.WriteLine("BizTalkTerminator: Resolved Assembly: [" + a2.FullName + "]");
        //    return a2;
        //}
    }
}
