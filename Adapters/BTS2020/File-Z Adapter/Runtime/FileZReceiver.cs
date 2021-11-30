//---------------------------------------------------------------------
// File: FileZReceiver.cs
// 
// Summary: Implementation of an adapter framework sample adapter. 
//---------------------------------------------------------------------

using System;
using System.Xml;
using Microsoft.BizTalk.Component.Interop;
using Microsoft.Samples.BizTalk.Adapter.Common;

namespace Microsoft.BizTalk.FileZ.Adapter
{
    /// <summary>
    /// Main class for FileZ receive adapters. It provides the implementations of
    /// core interfaces needed to comply with receiver adapter contract.
    /// (1) This class is actually a Singleton. That is there will only ever be one
    /// instance of it created however many locations of this type are actually defined.
    /// (2) Individual locations are identified by a URI and are associated with FileZReceiverEndpoint
    /// (3) It is legal to have messages from different locations submitted in a single
    /// batch and this may be an important optimization. And this is fundamentally why
    /// the Receiver is a singleton.
    /// </summary>
    public class FileZReceiver : Receiver 
    {
        public FileZReceiver() : base(
            "FILE-Z Receive Adapter",
            "1.0",
            "Submits files from disk into BizTalk",
            "FILE-Z",
            new Guid("3c3d0ee2-bf30-466d-9d73-350fcb53e9c8"),
            "http://schemas.microsoft.com/BizTalk/2003/FileZ-properties",
            typeof(FileZReceiverEndpoint))
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
                    FileZReceiveProperties.ReceiveHandlerConfiguration(handlerConfigDom);
                }
            }
        }
    }
}
