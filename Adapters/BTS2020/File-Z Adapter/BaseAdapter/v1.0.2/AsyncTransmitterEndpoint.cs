//---------------------------------------------------------------------
// File: AsyncTransmitterEndpoint.cs
// 
// Summary: Implementation of an adapter framework sample adapter. 
// This class constitutes one of the BaseAdapter classes, which, are
// a set of generic re-usable set of classes to help adapter writers.
//
// Sample: Base Adapter Class Library v1.0.2
//
// Description: TODO:
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
using System.Xml;
using Microsoft.BizTalk.Message.Interop;
using Microsoft.BizTalk.Component.Interop;

namespace Microsoft.Samples.BizTalk.Adapter.Common
{
    public abstract class EndpointParameters
    {
        public abstract string SessionKey { get; }
        public string OutboundLocation { get { return this.outboundLocation; } }
        public EndpointParameters (string outboundLocation)
        {
            this.outboundLocation = outboundLocation;
        }
        protected string outboundLocation;
    }

    internal class DefaultEndpointParameters : EndpointParameters
    {
        public override string SessionKey 
        {
            //  the SessionKey is the outboundLocation in the default case
            get { return this.outboundLocation; }
        }
        public DefaultEndpointParameters (string outboundLocation) : base(outboundLocation)
        {
        }
    }

    public abstract class AsyncTransmitterEndpoint : System.IDisposable
    {
        public AsyncTransmitterEndpoint(AsyncTransmitter transmitter) { }

        public virtual bool ReuseEndpoint { get { return true; } }
        public abstract void Open (EndpointParameters endpointParameters, IPropertyBag handlerPropertyBag, string propertyNamespace);
        public abstract IBaseMessage ProcessMessage (IBaseMessage message);
        public virtual void Dispose () { }
    }
}
