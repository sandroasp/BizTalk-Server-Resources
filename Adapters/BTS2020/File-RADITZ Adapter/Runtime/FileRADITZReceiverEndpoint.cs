//---------------------------------------------------------------------
// File: FileRADITZReceiverEndpoint.cs
// 
// Summary: Implementation of an adapter framework sample adapter. 
//---------------------------------------------------------------------

using System;
using System.IO;
using System.Net;
using System.Xml;
using System.Text;
using System.Security;
using System.Threading;
using System.Collections;
using System.Diagnostics;
using System.Collections.Generic;
using System.Runtime.InteropServices;
using Microsoft.BizTalk.Component.Interop;
using Microsoft.BizTalk.Message.Interop;
using Microsoft.BizTalk.TransportProxy.Interop;
using Microsoft.Samples.BizTalk.Adapter.Common;
using System.Linq;
using Microsoft.BizTalk.Streaming;

namespace Microsoft.BizTalk.FileRADITZ.Adapter
{
    /// <summary>
    /// This class corresponds to a Receive Location/URI.  It handles polling the
    /// given folder for new messages.
    /// </summary>
    internal class FileRADITZReceiverEndpoint : ReceiverEndpoint
    {
        public FileRADITZReceiverEndpoint()
        {
        }

        /// <summary>
        /// This method is called when a Receive Location is enabled.
        /// </summary>
        public override void Open(
            string uri,
            IPropertyBag config,
            IPropertyBag bizTalkConfig,
            IPropertyBag handlerPropertyBag,
            IBTTransportProxy transportProxy,
            string transportType,
            string propertyNamespace,
            ControlledTermination control)
        {
            Trace.WriteLine("[FileRADITZReceiverEndpoint] Open called");
            this.errorCount = 0;

            this.properties = new FileRADITZReceiveProperties();

            //  Location properties - possibly override some Handler properties
            XmlDocument locationConfigDom = ConfigProperties.ExtractConfigDom(config);
            this.properties.ReadLocationConfiguration(locationConfigDom);

            //  this is our handle back to the EPM
            this.transportProxy = transportProxy;

            // used to create new messages / message parts etc.
            this.messageFactory = this.transportProxy.GetMessageFactory();

            //  used in the creation of messages
            this.transportType = transportType;

            //  used in the creation of messages
            this.propertyNamespace = propertyNamespace;

            // used to track inflight work for shutting down properly
            this.controlledTermination = control;

            //start the task
            Start();
        }

        /// <summary>
        /// This method is called when the configuration for this receive location is modified.
        /// </summary>
        public override void Update (IPropertyBag config, IPropertyBag bizTalkConfig, IPropertyBag handlerPropertyBag)
        {
            Trace.WriteLine("[FileRADITZReceiverEndpoint] Updated called");
            lock (this)
            {
                Stop();

                errorCount = 0;

                //  keep handles to these property bags until we are ready
                this.updatedConfig             = config;
                this.updatedBizTalkConfig      = bizTalkConfig;
                this.updatedHandlerPropertyBag = handlerPropertyBag;

                if (updatedConfig != null)
                {
                    XmlDocument locationConfigDom = ConfigProperties.ExtractConfigDom(this.updatedConfig);
                    this.properties.ReadLocationConfiguration(locationConfigDom);
                }

                //Schedule the polling event
                Start();
            }
        }

        public override void Dispose()
        {
            Trace.WriteLine("[FileRADITZReceiverEndpoint] Dispose called");
            //  stop the schedule
            Stop();
        }

        private void Start()
        {
            this.timer = new Timer(new TimerCallback(ControlledEndpointTask));
            this.timer.Change(0, this.properties.PollingInterval * 1000);
        }

        private void Stop()
        {
            this.timer.Dispose();
        }

        /// <summary>
        /// this method is called from the task scheduler when the polling interval has elapsed.
        /// </summary>
        public void ControlledEndpointTask (object val)
        {
            if (this.controlledTermination.Enter())
            {
                try
                {
                    lock (this)
                    {
                        this.EndpointTask();
                    }
                    GC.Collect();
                }
                finally
                {
                    this.controlledTermination.Leave();
                }
            }
        }

        /// <summary>
        /// Handle the work to be performed each polling interval
        /// </summary>
        private void EndpointTask () 
        {
            try 
            {
                PickupFilesAndSubmit();

                //Success, reset the error count
                errorCount = 0; 
            }
            catch (Exception e) 
            {
                transportProxy.SetErrorInfo(e);
                //Track number of failures
                errorCount++;
            }
            CheckErrorThreshold();
        }

        private bool CheckErrorThreshold ()
        {
            if ((0 != this.properties.ErrorThreshold) && (this.errorCount > this.properties.ErrorThreshold))
            {
                this.transportProxy.ReceiverShuttingdown(this.properties.Uri, new ErrorThresholdExceeded());
                
                //Stop the timer.
                Stop();
                return false;
            }
            return true;
        }

        private bool CheckMaxFileSize (FileInfo item)
        {
            long fileSizeBytes = item.Length;
            if ( this.properties.MaxFileSize > 0 )
            {
                long maxFileSizeBytes = 1024 * 1024 * this.properties.MaxFileSize;
                return (fileSizeBytes <= maxFileSizeBytes);
            }
            else
                return true;
        }

        //  The algorithm implemented here splits the list of files according to the
        //  batch tuning parameters (number of bytes and number of files) because the
        //  list is randomly ordered it is possible to have non-optimal batches. It would
        //  be a slight optimization to order by increasing size and then cut the batches.
        private void PickupFilesAndSubmit ()
        {
            Trace.WriteLine("[FileRADITZReceiverEndpoint] PickupFilesAndSubmit called");
            
            int maxBatchSize     = this.properties.MaximumBatchSize;
            int maxNumberOfFiles = this.properties.MaximumNumberOfFiles;

            List<BatchMessage> files = new List<BatchMessage>();
            long bytesInBatch = 0;

            DirectoryInfo di = new DirectoryInfo(this.properties.Directory);
            FileInfo[] items = di.GetFiles(this.properties.FileMask);
            
            Trace.WriteLine(string.Format("[FileRADITZReceiverEndpoint] Found {0} files.", items.Length));
            foreach (FileInfo item in items) 
            {
                //  only consider files that are not read only
                if (FileAttributes.ReadOnly == (FileAttributes.ReadOnly & item.Attributes))
                    continue;

                //  only download files that are less than the configured max file size
                if (false == CheckMaxFileSize(item))
                    continue;

                //ignore empty (zero byte) files
                if (item.Length == 0)
                    continue;

                string fileName = Path.Combine(properties.Directory, item.Name);
                string renamedFileName;
                if ( this.properties.WorkInProgress.Length > 0 )
                    renamedFileName = fileName + this.properties.WorkInProgress;
                else
                    renamedFileName = null;

                // If we couldn't lock the file, just move onto the next file
                IBaseMessage msg = CreateMessage(fileName, renamedFileName);
                if ( null == msg )
                    continue;

                if ( null == renamedFileName )
                    files.Add(new BatchMessage(msg, fileName, BatchOperationType.Submit));
                else
                    files.Add(new BatchMessage(msg, renamedFileName, BatchOperationType.Submit));

                //  keep a running total for the current batch
                bytesInBatch += item.Length;

                //  zero for the value means infinite 
                bool fileCountExceeded = ((0 != maxNumberOfFiles) && (files.Count >= maxNumberOfFiles));
                bool byteCountExceeded = ((0 != maxBatchSize)     && (bytesInBatch    >  maxBatchSize));

                if (fileCountExceeded || byteCountExceeded)
                {
                    //  check if we have been asked to stop - if so don't start another batch
                    if (this.controlledTermination.TerminateCalled)
                        return;

                    //  execute the batch
                    SubmitFiles(files);

                    //  reset the running totals
                    bytesInBatch = 0;
                    files.Clear();
                }
            }

            //  check if we have been asked to stop - if so don't start another batch
            if (this.controlledTermination.TerminateCalled)
                return;

            //  end of file list - one final batch to do
            if (files.Count > 0)
                SubmitFiles(files);
        }

        /// <summary>
        /// Given a List of Messages submit them to BizTalk for processing
        /// </summary>
        private void SubmitFiles(List<BatchMessage> files)
        {
            if (files == null || files.Count == 0) throw new ArgumentException("SubmitFiles was called with an empty list of Files");

            Trace.WriteLine(string.Format("[FileRADITZReceiverEndpoint] SubmitFiles called. Submitting a batch of {0} files.", files.Count));

            //This class is used to track the files associated with this ReceiveBatch
            BatchInfo batchInfo = new BatchInfo(files);
            using (ReceiveBatch batch = new ReceiveBatch(this.transportProxy, this.controlledTermination, batchInfo.OnBatchComplete, this.properties.MaximumNumberOfFiles))
            {
                foreach (BatchMessage file in files)
                {
                    // submit file to batch
                    batch.SubmitMessage(file.Message, file.UserData);
                }

                batch.Done(null);
            }
        }

        /// <summary>
        /// This class tracks a collection of files associated with a EPM Batch
        /// </summary>
        private class BatchInfo
        {
            BatchMessage[] messages;

            internal BatchInfo(List<BatchMessage> messageList)
            {
                this.messages = new BatchMessage[messageList.Count];
                messageList.CopyTo(messages);
            }

            /// <summary>
            /// Called when the BizTalk Batch has been submitted.  If all the messages were submitted (good or suspended)
            /// we delete the files from the folder
            /// </summary>
            /// <param name="overallStatus"></param>
            internal void OnBatchComplete(bool overallStatus)
            {
                Trace.WriteLine(string.Format("[FileRADITZReceiverEndpoint] OnBatchComplete called. overallStatus == {0}.", overallStatus));

                if (overallStatus == true) //Batch completed
                {
                    //Delete the files
                    foreach (BatchMessage batchMessage in messages)
                    {
                        //Close the stream so we can delete this file
                        batchMessage.Message.BodyPart.Data.Close();
                        batchMessage.Message.BodyPart.Data.Dispose();
                        File.Delete((string)batchMessage.UserData);
                    }
                }
            }
        }


        private IBaseMessage CreateMessage(IBaseMessageFactory messageFactory, Stream stream, DateTime creationTime, string srcFilePath)
        {
            IBaseMessagePart messagePart = messageFactory.CreateMessagePart();
            messagePart.Data = stream;
            IBaseMessage message = messageFactory.CreateMessage();
            message.AddPart("body", messagePart, true);
            SystemMessageContext context = new SystemMessageContext(message.Context);
            context.InboundTransportLocation = this.properties.Uri;
            context.InboundTransportType = this.transportType;
            // Write/Promote any adapter specific properties on the message context
            // This will be using the same properties of the FILE Adapter
            message.Context.Promote("ReceivedFileName", "http://schemas.microsoft.com/BizTalk/2003/file-properties", (object)srcFilePath);
            message.Context.Promote("FileCreationTime", "http://schemas.microsoft.com/BizTalk/2003/file-properties", (object)creationTime);
            return message;
        }

        /// <summary>
        /// Create a BizTalk message given the name of a file on disk optionally renaming
        /// the file while the message is being submitted into BizTalk.
        /// </summary>
        /// <param name="srcFilePath">The File to create the message from</param>
        /// <param name="renamedFileName">Optional, if specified the file will be renamed to this value.</param>
        /// <returns>The message to be submitted to BizTalk.</returns>
        private IBaseMessage CreateMessage (string srcFilePath, string renamedFileName)
        {
            IBaseMessage message = null;

            MemoryStream ms = new MemoryStream();
            bool renamed = false;
            DateTime creationTime = File.GetCreationTime(srcFilePath);

            if (!String.IsNullOrEmpty(renamedFileName))
            {
                try { 
                    Trace.WriteLine("[FileRADITZReceiverEndpoint] Renaming file " + srcFilePath);
                    File.Move(srcFilePath, renamedFileName);
                    renamed = true;

                    using (Stream fs = File.Open(renamedFileName, FileMode.Open, FileAccess.ReadWrite, FileShare.None))
                    { 
                        if (fs.Length == 0)
                            fs.Write(new byte[0], 0, 0);

                        fs.CopyTo(ms);
                        ms.Seek(0, SeekOrigin.Begin);
                        message = this.CreateMessage(messageFactory, ms, creationTime, srcFilePath);
                    }
                }
                catch (Exception)
                {
                    // If we renamed the file, rename it back
                    if (renamed)
                        File.Move(renamedFileName, srcFilePath);

                    return null;
                }
            }
            else
            {
                using (Stream fs = File.Open(srcFilePath, FileMode.Open, FileAccess.ReadWrite, FileShare.None))
                {
                    if (fs.Length == 0)
                        fs.Write(new byte[0], 0, 0);

                    fs.CopyTo(ms);
                    ms.Seek(0, SeekOrigin.Begin);
                    message = this.CreateMessage(messageFactory, ms, creationTime, srcFilePath);
                }
            }

            return message;
        }


        //  properties
        private FileRADITZReceiveProperties properties;

        //  handle to the EPM
        private IBTTransportProxy transportProxy;

        // used to create new messages / message parts etc.
        private IBaseMessageFactory messageFactory;

        //  used in the creation of messages
        private string transportType;

        //  used in the creation of messages
        private string propertyNamespace;

        // used to track inflight work
        private ControlledTermination controlledTermination;

        //  error count for comparison with the error threshold
        int errorCount;

        private System.Threading.Timer timer = null;

        //  support for Update
        IPropertyBag updatedConfig;
        IPropertyBag updatedBizTalkConfig;
        IPropertyBag updatedHandlerPropertyBag;
    }
}
