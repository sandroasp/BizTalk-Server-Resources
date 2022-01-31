//---------------------------------------------------------------------
// File: VoidTransmitter.cs
// 
// Summary: BizTalk Server Void Adapter implementation.
// This class implements an Asynchronous Batch-Supported Send Adapter 
// that just sends messages to nowhere - dicart messages.
//
// Sample: Void Adapter
//---------------------------------------------------------------------

using System;
using System.Collections;
using System.Diagnostics;
using System.IO;
using System.Runtime.InteropServices;
using System.Text;
using System.Xml;
using System.Xml.XPath;
using Microsoft.BizTalk.TransportProxy.Interop;
using Microsoft.BizTalk.Component.Interop;
using Microsoft.BizTalk.Message.Interop;

namespace Microsoft.BizTalk.Void.Adapter
{
    /// <summary>
    /// BizTalk Server Void Adapter implementation.
    /// </summary>
    public class VoidTransmitter :
      IBTTransport,
      IBTTransportControl,
      IPersistPropertyBag,
      IBTTransmitter
    {
        private const string NAME = "Void Adapter";
        private const string DESCRIPTION = "BizTalk Server Void Send Adapter";
        private const string VERSION = "1.0.0.0";
        private readonly Guid CLSID = new Guid("{9A5DDDDA-E443-4239-A6AF-CDE159D5FA56}");
        private const string TRANSPORTTYPE = "void";
        private const string PROPNS = "urn:schemas-intothevoid-com:voidadapter";

        #region Properties

        private IBTTransportProxy tproxy;
        private TerminationController terminate = new TerminationController();

        #endregion

        #region IBTTransport Members

        public string Name
        {
            get { return NAME; }
        }

        public string Description
        {
            get { return DESCRIPTION; }
        }

        public string Version
        {
            get { return VERSION; }
        }

        public Guid ClassID
        {
            get { return CLSID; }
        }

        public string TransportType
        {
            get { return TRANSPORTTYPE; }
        }

        #endregion

        #region IPersistPropertyBag Members

        public void InitNew()
        {
        }

        public void GetClassID(out Guid classID)
        {
            classID = CLSID;
        }

        public void Load(IPropertyBag propertyBag, int errorLog)
        {
        }

        public void Save(IPropertyBag propertyBag, bool clearDirty, bool saveAllProperties)
        {
        }

        #endregion

        #region IBTTransmitter Members

        /// <summary>
        /// Terminate the adapter.
        /// Wait for all send operations to end, then release the transport proxy and terminate
        /// </summary>
        public void Terminate()
        {
            terminate.Leave();
            terminate.Terminate();
            Marshal.ReleaseComObject(tproxy);
            tproxy = null;
        }

        /// <summary>
        /// Transmit a message handed down by the EPM
        /// </summary>
        /// <param name="msg">Message to send (discart)</param>
        /// <returns>True if the message was sent (discarted) successfuly</returns>
        public bool TransmitMessage(IBaseMessage msg)
        {
            terminate.Enter();
            try
            {
                bool logMessages = Convert.ToBoolean(GetAdapterConfigValue(msg.Context, "logMessages"));

                // If the send port is configured to log, then we will be registry message information in the Event Viewer
                if (logMessages)
                {
                    SystemMessageContext ctxt = new SystemMessageContext(msg.Context);

                    string msgData = "";
                    StreamReader reader = new StreamReader(msg.BodyPart.Data);
                    using (reader)
                    {
                        msgData = reader.ReadToEnd();
                    }
                    LogHelper.RegisterLogEntry(msg.MessageID, ctxt.InterchangeID, msgData);
                }

                // discard the message
                return true;
            }
            finally
            {
                terminate.Leave();
            }
        }

        /// <summary>
        /// Initialize the Adapter
        /// </summary>
        /// <param name="transportProxy">Transport Proxy reference</param>
        public void Initialize(IBTTransportProxy transportProxy)
        {
            terminate.Enter();
            tproxy = transportProxy;
        }

        #endregion

        /// <summary>
        /// Loads the transmit location adapter configuration and gets the value of the specified field
        /// </summary>
        /// <param name="propBag">PropertyBag</param>
        /// <param name="propname">Property name</param>
        /// <returns>The value</returns>
        public string GetAdapterConfigValue(IBasePropertyBag propBag, string propname)
        {
            string config = (string)propBag.Read("AdapterConfig", PROPNS);
            if (config == null)
                return null;

            XPathDocument doc = new XPathDocument(new StringReader(config));
            XPathNavigator nav = doc.CreateNavigator();

            string xpath = string.Format("string(/CustomProps/{0})", propname);
            return (string)nav.Evaluate(xpath);
        }
    }
}