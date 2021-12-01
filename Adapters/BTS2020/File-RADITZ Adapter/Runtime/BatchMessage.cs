//---------------------------------------------------------------------
// File: Batch.cs
// 
// Summary: Implementation of an adapter framework sample adapter. 
// This class constitutes one of the BaseAdapter classes, which, are
// a set of generic re-usable set of classes to help adapter writers.
//
// Sample: File-RADITZ Adapter
//---------------------------------------------------------------------

using System;
using System.Collections;
using System.Runtime.InteropServices;
using Microsoft.BizTalk.TransportProxy.Interop;
using Microsoft.BizTalk.Message.Interop;

namespace Microsoft.BizTalk.FileRADITZ.Adapter
{
	class BatchMessage
	{
		private IBaseMessage message;
		private object userData;
		private string correlationToken;
		private BatchOperationType operationType;

		public BatchMessage (IBaseMessage message, object userData, BatchOperationType oppType)
		{
			this.message = message;
			this.userData = userData;
			this.operationType = oppType;
		}

		public BatchMessage (string correlationToken, object userData, BatchOperationType oppType)
		{
			this.correlationToken = correlationToken;
			this.userData = userData;
			this.operationType = oppType;
		}

		public IBaseMessage Message
		{
			get { return this.message; }
		}
		public object UserData
		{
			get { return this.userData; }
		}
		public string CorrelationToken
		{
			get { return this.correlationToken; }
		}
		public BatchOperationType OperationType
		{
			get { return this.operationType; }
		}
	}
}