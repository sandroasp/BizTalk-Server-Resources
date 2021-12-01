//---------------------------------------------------------------------
// File: FileRADITZReceiver.cs
// 
// Summary: Implementation of an adapter framework sample adapter. 
//---------------------------------------------------------------------

using System;
using System.Xml;
using Microsoft.BizTalk.Component.Interop;
using Microsoft.Samples.BizTalk.Adapter.Common;

namespace Microsoft.BizTalk.FileRADITZ.Adapter
{
    /// <summary>
    /// Main class for FileRADITZ receive adapters. It provides the implementations of
    /// core interfaces needed to comply with receiver adapter contract.
    /// (1) This class is actually a Singleton. That is there will only ever be one
    /// instance of it created however many locations of this type are actually defined.
    /// (2) Individual locations are identified by a URI and are associated with FileRADITZReceiverEndpoint
    /// (3) It is legal to have messages from different locations submitted in a single
    /// batch and this may be an important optimization. And this is fundamentally why
    /// the Receiver is a singleton.
    /// </summary>
    public class FileRADITZReceiver : Receiver 
    {
        public FileRADITZReceiver() : base(
            "File-RADITZ Receive Adapter",
            "1.0",
            "Submits files from disk into BizTalk",
            "File-RADITZ",
            new Guid("47C49E26-609B-4A14-8190-2FB116572EA2"),
            "http://schemas.microsoft.com/BizTalk/2003/FileRADITZ-properties",
            typeof(FileRADITZReceiverEndpoint))
        {
        }
        /// <summary>
        /// This function is called when BizTalk runtime gives the handler properties to adapter.
        /// </summary>
        protected override void HandlerPropertyBagLoaded ()
        {
            IPropertyBag config = this.HandlerPropertyBag;
            if (null != config)
            {
                XmlDocument handlerConfigDom = ConfigProperties.IfExistsExtractConfigDom(config);
                if (null != handlerConfigDom)
                {
                    FileRADITZReceiveProperties.ReceiveHandlerConfiguration(handlerConfigDom);
                }
            }
        }
    }
}
