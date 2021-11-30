//---------------------------------------------------------------------
// File: AdapterException.cs
// 
// Summary: Implementation of an adapter framework sample adapter. 
// This class constitutes one of the BaseAdapter classes, which, are
// a set of generic re-usable set of classes to help adapter writers.
//
// Sample: Base Adapter Class Library v1.0.2
//
// Description: Adapter exception class
//
//---------------------------------------------------------------------
// This file is part of the Microsoft BizTalk Server SDK
//
// Copyright (c) Microsoft Corporation. All rights reserved.
//
// This source code is intended only as a supplement to Microsoft BizTalk
// Server release and/or on-line documentation. See these other
// materials for detailed information regarding Microsoft code samples.
//
// THIS CODE AND INFORMATION ARE PROVIDED "AS IS" WITHOUT WARRANTY OF ANY
// KIND, WHETHER EXPRESSED OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE
// IMPLIED WARRANTIES OF MERCHANTABILITY AND/OR FITNESS FOR A PARTICULAR
// PURPOSE.
//---------------------------------------------------------------------

using System;
using System.Runtime.Serialization;
using Microsoft.BizTalk.Component.Interop;
using Microsoft.BizTalk.Message.Interop;

namespace Microsoft.Samples.BizTalk.Adapter.Common
{
	// Adapter Exceptions

	[Serializable()]
	public class AdapterException : ApplicationException
	{
		public AdapterException () { }

		public AdapterException (string message) : base(message) { }

		public AdapterException (Exception inner) : base(String.Empty, inner) { }

		public AdapterException (string msg, Exception e) : base(msg,e) { }

		protected AdapterException (SerializationInfo info, StreamingContext context) : base(info, context) { }
	}

	[Serializable()]
    public class AlreadyInitialized : AdapterException
	{
        public AlreadyInitialized() : base("Adapter already initialized.") { }

		protected AlreadyInitialized (SerializationInfo info, StreamingContext context) : base(info, context) { }
	}

	[Serializable()]
    public class NotInitialized : AdapterException
	{
		public NotInitialized () : base("Adapter not initialized.") { }

		protected NotInitialized (SerializationInfo info, StreamingContext context) : base(info, context) { }
	}

	[Serializable()]
    public class InconsistentConfigurationUri : AdapterException
	{
		public InconsistentConfigurationUri (string uriLocation, string uriConfiguration) : base(
            String.Format("The adapter configuration URI is {0} but the Adapter Framework contains {1} possible corruption in the configuration. Delete and recreate the location.", uriLocation, uriConfiguration)) { }

		protected InconsistentConfigurationUri (SerializationInfo info, StreamingContext context) : base(info, context) { }
	}

	[Serializable()]
    public class EndpointExists : AdapterException
	{
		public EndpointExists (string uri) : base(String.Format("The endpoint {0} already exists.", uri)) { }

		protected EndpointExists (SerializationInfo info, StreamingContext context) : base(info, context) { }
	}
	
	[Serializable()]
    public class EndpointNotExists : AdapterException
	{
		public EndpointNotExists (string uri) : base(String.Format("The endpoint {0} does not exist.", uri)) { }

		protected EndpointNotExists (SerializationInfo info, StreamingContext context) : base(info, context) { }
	}

	[Serializable()]
    public class NoAdapterConfig : AdapterException
	{
		public NoAdapterConfig () : base("No adapter configuration XML was found on the configuration when one was expected.") { }

		protected NoAdapterConfig (SerializationInfo info, StreamingContext context) : base(info, context) { }
	}

	[Serializable()]
    public class NoSuchProperty : AdapterException 
	{
		public NoSuchProperty (string path) : base(String.Format("Property {0} not found on adapter configuration XML.", path)) { }

		protected NoSuchProperty (SerializationInfo info, StreamingContext context) : base(info, context) { }
	}

	[Serializable()]
    public class CreateEndpointFailed : AdapterException
	{
		public CreateEndpointFailed (string fullName, string uri) : base(String.Format("Unable to create endpoint type {0} location URI {1}", fullName, uri)) { }

		protected CreateEndpointFailed (SerializationInfo info, StreamingContext context) : base(info, context) { }
	}

	[Serializable()]
    public class ErrorThresholdExceeded : AdapterException
	{
        public ErrorThresholdExceeded() : base("Error Threshold exceeded") { }

		protected ErrorThresholdExceeded (SerializationInfo info, StreamingContext context) : base(info, context) { }
	}

	[Serializable()]
    public class ErrorLoadingConfigXmlDom : AdapterException
	{
        public ErrorLoadingConfigXmlDom() : base("A failure occurred in loading the configuration XML DOM.") { }

		protected ErrorLoadingConfigXmlDom (SerializationInfo info, StreamingContext context) : base(info, context) { }
	}

	[Serializable()]
    public class ErrorRetrievingSsoTicket : AdapterException
	{
        public ErrorRetrievingSsoTicket() : base("A failure occurred in retrieving the SSO ticket.") { }

		protected ErrorRetrievingSsoTicket (SerializationInfo info, StreamingContext context) : base(info, context) { }
	}

	[Serializable()]
    public class ErrorTransmitUnexpectedClrException : AdapterException
	{
		public ErrorTransmitUnexpectedClrException (string message) : base(String.Format("An unexpected failure occurred while processing a message. The text associated with the exception is \"{0}\".", message)) { }

		protected ErrorTransmitUnexpectedClrException (SerializationInfo info, StreamingContext context) : base(info, context) { }
	}

    [Serializable()]
    public class EventLogErrorThresholdExceeded : AdapterException
    {
        public EventLogErrorThresholdExceeded() : base("The Event Log Error Threshold has been reached. The adapter will continue polling, but further event log entries will be suppressed.") { }

        protected EventLogErrorThresholdExceeded(SerializationInfo info, StreamingContext context) : base(info, context) { }
    }

    [Serializable()]
    public class EventLogErrorThresholdReset : AdapterException
    {
        public EventLogErrorThresholdReset() : base("The adapter has recovered from recent failures. The Event Log Error Threshold count will also be reset.") { }
        
        protected EventLogErrorThresholdReset(SerializationInfo info, StreamingContext context) : base(info, context) { }
    }
}
