//---------------------------------------------------------------------
// File: FileRADITZExceptions.cs
// 
// Summary: Implementation of an adapter framework sample adapter. 
//---------------------------------------------------------------------

using System;
using System.Runtime.Serialization;
using Microsoft.Samples.BizTalk.Adapter.Common;

namespace Microsoft.BizTalk.FileRADITZ.Adapter
{
	internal class FileRADITZExceptions : ApplicationException
	{
		public static string UnhandledTransmit_Error = "The File-RADITZ Adapter encounted an error transmitting a batch of messages.";

        public FileRADITZExceptions() { }

		public FileRADITZExceptions(string msg) : base(msg) { }

		public FileRADITZExceptions(Exception inner) : base(String.Empty, inner) { }

		public FileRADITZExceptions(string msg, Exception e) : base(msg, e) { }

		protected FileRADITZExceptions(SerializationInfo info, StreamingContext context) : base(info, context) { }
	}
}

