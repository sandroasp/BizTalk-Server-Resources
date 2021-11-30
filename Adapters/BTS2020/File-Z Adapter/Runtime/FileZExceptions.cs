//---------------------------------------------------------------------
// File: FileZExceptions.cs
// 
// Summary: Implementation of an adapter framework sample adapter. 
//---------------------------------------------------------------------

using System;
using System.Runtime.Serialization;
using Microsoft.Samples.BizTalk.Adapter.Common;

namespace Microsoft.BizTalk.FileZ.Adapter
{
	internal class FileZExceptions : ApplicationException
	{
		public static string UnhandledTransmit_Error = "The File-Z Adapter encounted an error transmitting a batch of messages.";

        public FileZExceptions() { }

		public FileZExceptions(string msg) : base(msg) { }

		public FileZExceptions(Exception inner) : base(String.Empty, inner) { }

		public FileZExceptions(string msg, Exception e) : base(msg, e) { }

		protected FileZExceptions(SerializationInfo info, StreamingContext context) : base(info, context) { }
	}
}

