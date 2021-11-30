//---------------------------------------------------------------------
// File: FileZTransmitter.cs
// 
// Summary: Implementation of an adapter framework sample adapter. 
//---------------------------------------------------------------------

using System;
using System.Xml;
using Microsoft.BizTalk.Component.Interop;
using Microsoft.Samples.BizTalk.Adapter.Common;
using Microsoft.BizTalk.TransportProxy.Interop;

namespace Microsoft.BizTalk.FileZ.Adapter
{
	/// <summary>
	/// This is a singleton class for FileZ send adapter. All the messages, going to various
	/// send ports of this adapter type, will go through this class.
	/// </summary>
	public class FileZTransmitter : AsyncTransmitter
	{
		internal static string FILEZ_NAMESPACE = "http://schemas.microsoft.com/BizTalk/2003/SDK_Samples/Messaging/Transports/FileZ-properties";

		public FileZTransmitter() : base(
			"FILE-Z Transmit Adapter",
			"1.0",
			"Send files form BizTalk to disk",
			"FILE-Z",
			new Guid("9a623f34-4e16-484d-8217-1ec0973b4294"),
			FILEZ_NAMESPACE,
			typeof(FileZTransmitterEndpoint),
			FileZTransmitProperties.BatchSize)
		{
		}
	
		protected override void HandlerPropertyBagLoaded ()
		{
			IPropertyBag config = this.HandlerPropertyBag;
			if (null != config)
			{
				XmlDocument handlerConfigDom = ConfigProperties.IfExistsExtractConfigDom(config);
				if (null != handlerConfigDom)
				{
					FileZTransmitProperties.ReadTransmitHandlerConfiguration(handlerConfigDom);
				}
			}
		}
	}
}
