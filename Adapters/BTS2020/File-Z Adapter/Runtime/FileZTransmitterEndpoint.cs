//---------------------------------------------------------------------
// File: FileZAsyncTransmitterBatch.cs
// 
// Summary: Implementation of an adapter framework sample adapter. 
//---------------------------------------------------------------------

using System;
using System.IO;
using System.Xml;
using System.Text;
using System.Collections;
using System.Threading;
using Microsoft.BizTalk.TransportProxy.Interop;
using Microsoft.BizTalk.Component.Interop;
using Microsoft.BizTalk.Message.Interop;
using Microsoft.Samples.BizTalk.Adapter.Common;

namespace Microsoft.BizTalk.FileZ.Adapter
{
	/// <summary>
	/// There is one instance of HttpTransmitterEndpoint class for each every static send port.
	/// Messages will be forwarded to this class by AsyncTransmitterBatch
	/// </summary>
	internal class FileZTransmitterEndpoint : AsyncTransmitterEndpoint
	{
		private AsyncTransmitter asyncTransmitter = null;
        private string propertyNamespace;
        private static int IO_BUFFER_SIZE = 4096;

        public FileZTransmitterEndpoint(AsyncTransmitter asyncTransmitter) : base(asyncTransmitter)
		{
			this.asyncTransmitter = asyncTransmitter;
		}

        public override void Open(EndpointParameters endpointParameters, IPropertyBag handlerPropertyBag, string propertyNamespace)
        {
            this.propertyNamespace = propertyNamespace;
        }

		/// <summary>
		/// Implementation for AsyncTransmitterEndpoint::ProcessMessage
		/// Transmit the message and optionally return the response message (for Request-Response support)
		/// </summary>
		public override IBaseMessage ProcessMessage(IBaseMessage message)
		{   		
			Stream source = message.BodyPart.Data;

			// build url
			FileZTransmitProperties props = new FileZTransmitProperties(message, propertyNamespace);
            string filePath = FileZTransmitProperties.CreateFileName(message, props.Uri);

		    // Create the new file
			using (FileStream fileStream = new FileStream(filePath, props.FileMode))
			{
				// Seek to the end of the file in case we're appending to existing data
				fileStream.Seek(0, SeekOrigin.End);

				source.Seek(0, SeekOrigin.Begin);

				// Copy the data from the msg to the file
				byte[] buffer = new byte[IO_BUFFER_SIZE];
				int bytesRead;
				while(0 != (bytesRead = source.Read(buffer, 0, buffer.Length)))
				{
					fileStream.Write(buffer, 0, bytesRead);
				}
			}

			return null;
		}
	}
}
