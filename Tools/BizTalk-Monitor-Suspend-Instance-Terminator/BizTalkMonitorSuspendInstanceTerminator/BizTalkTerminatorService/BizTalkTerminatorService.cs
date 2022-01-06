/*###############################################################################################################################
  # THIS CODE AND INFORMATION ARE PROVIDED "AS IS" WITHOUT WARRANTY OF ANY KIND, EITHER EXPRESSED OR IMPLIED,                   #
  # INCLUDING BUT NOT LIMITED TO THE IMPLIED WARRANTIES OF MERCHANTABILITY AND/OR FITNESS FOR A PARTICULAR PURPOSE.             #
  #    You can use, modify and redistribute this code in your product as per the Apache License, which governs this project.    #
  #                                                                                                                             #
  # BizTalk Terminator - The Windows Service Class                                                                              #
  ###############################################################################################################################*/

using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Configuration;
using System.Data;
using System.Diagnostics;
using System.Linq;
using System.Reflection;
using System.ServiceModel;
using System.ServiceProcess;
using System.Threading;
using System.Text;
using BizTalkTerminatorUtil;
using System.Xml;

namespace BizTalkTerminatorService
{
    /// <summary>
    /// The main Windows Service class that extends from ServiceBase
    /// </summary>
    public partial class BizTalkTerminatorService : ServiceBase
    {
        /// <summary>
        /// 
        /// </summary>
        protected ManualResetEvent shutdownEvent = new ManualResetEvent(false);

        /// <summary>
        /// 
        /// </summary>
        protected Thread serviceThread;

        /// <summary>
        /// 
        /// </summary>
        private BizTalkTerminatorHelper terminator;

        /// <summary>
        /// 
        /// </summary>
        private ServiceFilterCollection btsServiceFilterCollection;

        /// <summary>
        /// BizTalk Database Server Hostname\\InstanceName where InstanceName is applicable, if not just the SQL Server HostName.
        /// </summary>
        private string BTSMgmtDbHostName;

        /// <summary>
        /// BizTalk Magement Database TableName. Defaults: BizTalkMgmtDb.
        /// </summary>
        private string BTSMgmtDBName;

        /// <summary>
        /// Initializes a new instance of the <see cref="BizTalkTerminatorService"/> class.
        /// </summary>
        public BizTalkTerminatorService()
        {
            InitializeComponent();
            if (!System.Diagnostics.EventLog.SourceExists("BTSTerminator"))
            {
                System.Diagnostics.EventLog.CreateEventSource(
                    "BTSTerminator", "Application");
            }
            bizTalkTerminatorEventLog.Source = "BTSTerminator";
            bizTalkTerminatorEventLog.Log = "Application";

            this.btsServiceFilterCollection = new ServiceFilterCollection();

            //System.Diagnostics.Debugger.Launch();
        }

        public void OnDebug()
        {
            OnStart(null);
        }

        /// <summary>
        /// When implemented in a derived class, executes when a Start command is sent to the service by the Service Control Manager (SCM) or when the operating system starts (for a service that starts automatically). Specifies actions to take when the service starts.
        /// </summary>
        /// <param name="args">Data passed by the start command.</param>
        protected override void OnStart(string[] args)
        {
            try
            {
                bizTalkTerminatorEventLog.WriteEntry("Attempting to start the BizTalkTerminator Service");
                serviceThread = new Thread(new ThreadStart(RunTerminator));
                serviceThread.Start();
            }
            catch (Exception exception)
            {
                string error = "Failed to start BizTalkTerminator Service. Error: " + exception.Message;
                error = error.Substring(0, 254);
                bizTalkTerminatorEventLog.WriteEntry(error);
            }
        }

        /// <summary>
        /// When implemented in a derived class, executes when a Stop command is sent to the service by the Service Control Manager (SCM). Specifies actions to take when a service stops running.
        /// </summary>
        protected override void OnStop()
        {
            try
            {
                bizTalkTerminatorEventLog.WriteEntry("Attempting to stop the BizTalkTerminator Service");
                // Stop the service thread 
                while (serviceThread.IsAlive)
                {
                    // Notify service thread to stop 
                    shutdownEvent.Set();
                    this.RequestAdditionalTime(2000);
                    Thread.Sleep(1000);                    
                }
            }
            catch (Exception exception)
            {
                string error = "Failed to stop BizTalkTerminator Service. Error: " + exception.Message;
                if (error.Length > 254)
                {
                    error = error.Substring(0, 254);
                }
                bizTalkTerminatorEventLog.WriteEntry(error);
            }
        }
        
        /// <summary>
        /// Runs the terminator service using Helper Library.
        /// </summary>
        private void RunTerminator()
        {
            terminator = new BizTalkTerminatorHelper(30, 3, 10);

            //System.Diagnostics.Debugger.Break();

            Configuration config = ConfigurationManager.OpenExeConfiguration(Assembly.GetExecutingAssembly().Location);
            XmlDocument document = new XmlDocument();
            document.Load(config.FilePath);

            foreach (XmlNode node in document.SelectNodes("//configuration/BTSServiceInstanceFilters/DatabaseFilter/add"))
            {
                string key = node.SelectSingleNode("@key").Value;
                string value = node.SelectSingleNode("@value").Value;

                if (string.Compare("DBServerHostName", key) == 0)
                {
                    this.BTSMgmtDbHostName = value;
                }
                else if (string.Compare("BTSMgmtDBName", key) == 0)
                {
                    this.BTSMgmtDBName = value;
                }
                else
                {
                    continue;
                }
            }

            System.Diagnostics.Debug.WriteLine("BizTalkTerminator: Service DBHost[ " + this.BTSMgmtDbHostName + "] and Table [" + this.BTSMgmtDBName + "]");

            foreach (XmlNode node in document.SelectNodes("//configuration/BTSServiceInstanceFilters/ServiceFilters/ServiceFilter"))
            {
                string serviceClass = string.Empty;
                string status = string.Empty;
                string error = string.Empty;
                string action = string.Empty;
                string location = string.Empty;

                if (node != null && node.HasChildNodes)
                {
                    foreach (XmlNode cNode in node.ChildNodes)
                    {                        
                        string key = cNode.SelectSingleNode("@key").Value;
                        string value = cNode.SelectSingleNode("@value").Value;

                        if (string.Compare("ServiceClass", key, true) == 0)
                        {
                            serviceClass = value;
                        }
                        else if (string.Compare("ServiceStatus", key, true) == 0)
                        {
                            status = value;
                        }
                        else if (string.Compare("ErrorId", key, true) == 0)
                        {
                            error = value;
                        }
                        else if (string.Compare("Action", key, true) == 0)
                        {
                            action = value;
                        }
                        else if (string.Compare("SaveLocation", key, true) == 0)
                        {
                            location = value;
                        }

                        if (string.IsNullOrWhiteSpace(serviceClass) || string.IsNullOrWhiteSpace(status) || string.IsNullOrWhiteSpace(error) || string.IsNullOrWhiteSpace(location))
                        {
                            // Any one of the above is Empty, this condition should be met.
                            continue;
                        }
                        else
                        {
                            // This condition is only met when all are not empty or null.
                            System.Diagnostics.Debug.WriteLine("BizTalkTerminator: Adding a ServiceFilter to the Collection");
                            this.btsServiceFilterCollection.Add(new ServiceFilter(serviceClass, status, error, "Terminate", location));
                        }
                    }
                }
            }
            
            if (this.btsServiceFilterCollection.Count > 0)
            {
                terminator.InvokeWatchMan(this.btsServiceFilterCollection, this.BTSMgmtDbHostName, this.BTSMgmtDBName);
            }
            else
            {
                System.Diagnostics.Debug.WriteLine("BizTalkTerminator: Service will stop due to Configuration Issues.");
                this.OnStop();
            }
        }
        
        /// <summary>
        /// Waits the specified milli secs.
        /// </summary>
        /// <param name="milliSecs">The milli secs.</param>
        /// <returns></returns>
        protected bool Wait(int milliSecs)
        {
            return !this.shutdownEvent.WaitOne(milliSecs, true);
        }
    }
}
