//---------------------------------------------------------------------
// File: FileZProperties.cs
// 
// Summary: Implementation of an adapter framework sample adapter. 
//---------------------------------------------------------------------

using System;
using System.IO;
using System.Xml;
using System.Net;
using Microsoft.BizTalk.Message.Interop;
using Microsoft.Samples.BizTalk.Adapter.Common;

namespace Microsoft.BizTalk.FileZ.Adapter
{
    /// <summary>
    /// This class contains common properties for both Receive and Send operations
    /// </summary>
    internal abstract class FileZCommonProperties : ConfigProperties
    {
        // default magic numbers
        protected const string USERNAME      = "";
        protected const string PASSWORD      = "";
        protected const int POLLING_INTERVAL = 60;
        protected const int ERROR_THRESHOLD  = 10;
		protected const int MAX_FILE_SIZE    = 100;

        // XML schema derived constants (like xpaths) is embedded throughout this class 

        private string directory;
		private string uri;

        public string Directory							{ get { return directory; } }

		public string Uri
		{
			get { return uri; }
			set { uri = value; }
		}

        public FileZCommonProperties()
        {
        }

        public virtual void ReadLocationConfiguration (XmlDocument configDOM)
        {
            uri = Extract(configDOM, "/Config/uri", string.Empty);
            
            //  In the case of running under SSO the uri will be different
            //  because we add the userName from SSO into the uri
            //if (!uri.Equals(this.uri))
            //    throw new InconsistentConfigurationUri(this.uri, uri);

            this.directory = Extract(configDOM, "/Config/directory", string.Empty);
        }
	}

    /// <summary>
    /// This class handles properties for a given Receive Location
    /// </summary>
    internal class FileZReceiveProperties : FileZCommonProperties
	{
		// Handler properties
		private static long handlerPollingInterval = POLLING_INTERVAL;
		private static int handlerMaximumNumberOfFiles = 0;
		
		// Endpoint properties
		private string fileMask;
        private long pollingInterval;
        private int maximumBatchSize;
        private int maximumNumberOfFiles;
        private int errorThreshold;
		private int maxFileSize;
		private string renameFileOnFailure;
		private string workInProgress;
  
        public string FileMask				{ get { return fileMask; } }
        public long PollingInterval			{ get { return pollingInterval; } }
        public int MaximumBatchSize			{ get { return maximumBatchSize; } }
        public int MaximumNumberOfFiles		{ get { return maximumNumberOfFiles; } }
		public int ErrorThreshold			{ get { return errorThreshold; } }
		public int MaxFileSize				{ get { return maxFileSize; } }
		public string RenameFileOnFailure	{ get { return renameFileOnFailure; } }
		public string WorkInProgress		{ get { return workInProgress; } }

        public FileZReceiveProperties () : base()
        {
            // establish defaults
            fileMask             = String.Empty;
            pollingInterval      = handlerPollingInterval; // default to handler value, override if set on the endpoint
            maximumBatchSize     = 0;
            maximumNumberOfFiles = handlerMaximumNumberOfFiles; // default to handler value, override if set on the endpoint
            errorThreshold       = ERROR_THRESHOLD;
			maxFileSize          = MAX_FILE_SIZE;
			renameFileOnFailure	 = String.Empty;
			workInProgress		 = String.Empty;
        }

		/// <summary>
		/// Load the Configuration for the Receive Handler
		/// </summary>
		public static void ReceiveHandlerConfiguration (XmlDocument configDOM)
		{
			// Handler properties
			handlerPollingInterval      = ExtractPollingInterval(configDOM);
			handlerMaximumNumberOfFiles = IfExistsExtractInt(configDOM, "/Config/maximumNumberOfFiles", handlerMaximumNumberOfFiles);
		}

		/// <summary>
		/// Load the Configuration for a Receive Location
		/// </summary>
		public override void ReadLocationConfiguration (XmlDocument configDOM)
        {
            base.ReadLocationConfiguration(configDOM);

            this.fileMask             = IfExistsExtract(configDOM, "/Config/fileMask", string.Empty);
            this.pollingInterval      = ExtractPollingInterval(configDOM);
            this.maximumBatchSize     = IfExistsExtractInt(configDOM, "/Config/maximumBatchSize", 0);
			this.maximumNumberOfFiles = IfExistsExtractInt(configDOM, "/Config/maximumNumberOfFiles", handlerMaximumNumberOfFiles);
			this.errorThreshold       = ExtractInt(configDOM, "/Config/errorThreshold");
			this.maxFileSize          = ExtractInt(configDOM, "/Config/maxFileSize");
			this.renameFileOnFailure  = IfExistsExtract(configDOM, "/Config/renameFileOnFailure", string.Empty);
			this.workInProgress		  = IfExistsExtract(configDOM, "/Config/workInProgress", string.Empty);
		}

		/// <summary>
		/// Extract the Polling Interval out of the Receive Location configuration
		/// </summary>
		public void UpdateOnlyPollingInterval (XmlDocument configDOM)
		{
			this.pollingInterval      = ExtractPollingInterval(configDOM);
		}
    }

    /// <summary>
	/// This class maintains send port properties associated with a message. These properties
	/// will be extracted from the message context for static send ports.
	/// </summary>
    internal class FileZTransmitProperties : FileZCommonProperties
    {
		// Handler properties
		private static int handlerSendBatchSize = 20;
		private static int handlerbufferSize = 4096;
		private static int handlerthreadsPerCPU = 1;

		// Endpoint properties
		private string directory;
		private string fileName;
		private FileMode fileMode;

		// If we needed to use SSO we will need this extra property. It is set in the
		// LocationConfiguration method below.
		// Additionally:
		//   TransmitLocation.xsd in the design-time project must also be edited to
		//   expose the necessary SSO properties.
		//   FileZAsyncTransmitterBatch.cs within the run-time project must be
		//   edited to retrieve and populate the SSOResult class.
		//private string ssoAffiliateApplication;
		//public string AffiliateApplication { get { return ssoAffiliateApplication; } }

		public string FileName				{ get { return fileName; } }
		public FileMode FileMode			{ get { return fileMode; } }

		// Handler properties
		public static int BufferSize		{ get { return handlerbufferSize; } }
		public static int ThreadsPerCPU		{ get { return handlerthreadsPerCPU; } }
		public static int BatchSize			{ get { return handlerSendBatchSize; } }

        public FileZTransmitProperties(IBaseMessage message, string propertyNamespace)
		{
            XmlDocument locationConfigDom = null;

            //  get the adapter configuration off the message
            IBaseMessageContext context = message.Context;
            string config = (string)context.Read("AdapterConfig", propertyNamespace);

            //  the config can be null all that means is that we are doing a dynamic send
            if (null != config)
            {
                locationConfigDom = new XmlDocument();
                locationConfigDom.LoadXml(config);

                this.ReadLocationConfiguration(locationConfigDom);
            }
		}

		/// <summary>
		/// Load the Transmit Handler configuration settings
		/// </summary>
		public static void ReadTransmitHandlerConfiguration (XmlDocument configDOM)
		{
			// Handler properties
			handlerSendBatchSize = ExtractInt(configDOM, "/Config/sendBatchSize");
			handlerbufferSize = ExtractInt(configDOM, "/Config/bufferSize");
			handlerthreadsPerCPU = ExtractInt(configDOM, "/Config/threadsPerCPU");
		}

		/// <summary>
		/// Load the configuration for the Message that is being transmitted
		/// </summary>
		/// <param name="configDOM"></param>
        public override void ReadLocationConfiguration (XmlDocument configDOM)
        {
            base.ReadLocationConfiguration(configDOM);

			this.directory = Extract(configDOM, "/Config/directory", string.Empty);
			this.fileName = Extract(configDOM, "/Config/fileName", string.Empty);
			this.fileMode = ExtractFileMode(configDOM);

			// If we needed to use SSO we will need this extra property
			//this.ssoAffiliateApplication = IfExistsExtract(configDOM, "/Config/ssoAffiliateApplication");
        }

		public void UpdateUriForDynamicSend()
		{
			if (!String.IsNullOrEmpty(this.Uri))
			{
				// Strip off the adapters alias
				const string adapterAlias = "FileZ://";
				if (this.Uri.StartsWith(adapterAlias, StringComparison.OrdinalIgnoreCase))
				{
					this.Uri = this.Uri.Substring(adapterAlias.Length);
				}
			}
		}

		/// <summary>
		/// Extract the FileMode out of the XML configuration
		/// </summary>
		public static FileMode ExtractFileMode (XmlDocument configDOM)
		{
			FileMode fileMode = FileMode.Create;

			string fm = IfExistsExtract(configDOM, "/Config/fileCopyMode", string.Empty);

			switch (fm) 
			{
				case "0":  
					fileMode = FileMode.Append;
					break;

				case "1":      
					fileMode = FileMode.Create;
					break;

				case "2":      
					fileMode = FileMode.CreateNew;
					break;
			}

			return fileMode;
		}

		/// <summary>
		/// Determines the name of the file that should be created for a transmitted message
		/// replaces %MessageID% with the message's Guid if specified.
		/// </summary>
		/// <param name="message">The Message to transmit</param>
		/// <param name="uri">The address of the message.  May contain "%MessageID%" </param>
		/// <returns>The name of the file to write to</returns>
		public static string CreateFileName(IBaseMessage message, string uri)
		{
			string uriNew = ReplaceMessageID(message, uri);
			return uriNew;
		}

		/// <summary>
		/// Helper method that puts the Message Guid in the URI
		/// </summary>
		private static string ReplaceMessageID(IBaseMessage message, string uri)
		{
			Guid msgId = message.MessageID;

			string res = uri.Replace("%MessageID%", msgId.ToString());
			if (res != null)
				return res;
			else
				return uri;
		}
	}
}

