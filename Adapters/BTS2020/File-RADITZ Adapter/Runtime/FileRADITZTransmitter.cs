//---------------------------------------------------------------------
// File: FileRADITZTransmitter.cs
// 
// Summary: Implementation of an adapter framework sample adapter. 
//---------------------------------------------------------------------

using System;
using System.Xml;
using Microsoft.BizTalk.Component.Interop;
using Microsoft.Samples.BizTalk.Adapter.Common;
using Microsoft.BizTalk.TransportProxy.Interop;

namespace Microsoft.BizTalk.FileRADITZ.Adapter
{
	/// <summary>
	/// This is a singleton class for FileRADITZ send adapter. All the messages, going to various
	/// send ports of this adapter type, will go through this class.
	/// </summary>
	public class FileRADITZTransmitter : AsyncTransmitter
	{
		internal static string FileRADITZ_NAMESPACE = "http://schemas.microsoft.com/BizTalk/2003/SDK_Samples/Messaging/Transports/FileRADITZ-properties";

		public FileRADITZTransmitter() : base(
			"File-RADITZ Transmit Adapter",
			"1.0",
			"Send files form BizTalk to disk",
			"File-RADITZ",
			new Guid("28714BC3-FA9E-4789-BD63-A5B6E0B762B9"),
			FileRADITZ_NAMESPACE,
			typeof(FileRADITZTransmitterEndpoint),
			FileRADITZTransmitProperties.BatchSize)
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
					FileRADITZTransmitProperties.ReadTransmitHandlerConfiguration(handlerConfigDom);
				}
			}
		}
	}
}
