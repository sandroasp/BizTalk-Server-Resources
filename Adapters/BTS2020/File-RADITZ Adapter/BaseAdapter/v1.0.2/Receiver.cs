//---------------------------------------------------------------------
// File: Receiver.cs
// 
// Summary: Implementation of an adapter framework sample adapter. 
// This class constitutes one of the BaseAdapter classes, which, are
// a set of generic re-usable set of classes to help adapter writers.
//
// Sample: Base Adapter Class Library v1.0.2
//
// Description: Base implementation for a receive adapter
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
using System.Collections.Generic;
using Microsoft.BizTalk.Component.Interop;
using Microsoft.BizTalk.TransportProxy.Interop;

namespace Microsoft.Samples.BizTalk.Adapter.Common
{
    /// <summary>
    /// Abstract base class for receiver adapters. Provides stock implementations of
    /// core interfaces needed to comply with receiver adapter contract.
    /// (1) This class is actually a Singleton. That is there will only ever be one
    /// instance of it created however many locations of this type are actually defined.
    /// (2) Individual locations are identified by a URI, the derived class must provide
    /// the Type name and this class acts as a Factory using the .NET Activator
    /// (3) It is legal to have messages from different locations submitted in a single
    /// batch and this may be an important optimization. And this is fundamentally why
    /// the Receiver is a singleton.
    /// </summary>
    public abstract class Receiver :
        Adapter,
        IBTTransportConfig,
        IDisposable
    {
        //  core member data
        private Dictionary<string, ReceiverEndpoint> endpoints = new Dictionary<string, ReceiverEndpoint>(StringComparer.OrdinalIgnoreCase);
        private Type endpointType;

        private ControlledTermination control;

        protected Receiver (
            string name,
            string version,
            string description,
            string transportType,
            Guid clsid,
            string propertyNamespace,
            Type endpointType)
        : base(
            name,
            version,
            description,
            transportType,
            clsid,
            propertyNamespace)
        {
			this.endpointType = endpointType;
            this.control = new ControlledTermination();
		}

        public void Dispose()
        {
            this.control.Dispose();
        }

        //  IBTTransportConfig
        public void AddReceiveEndpoint (string Url, IPropertyBag pConfig, IPropertyBag pBizTalkConfig)
        {
            if (!this.Initialized)
                throw new NotInitialized();

            if (this.endpoints.ContainsKey(Url))
                throw new EndpointExists(Url);

            ReceiverEndpoint endpoint = (ReceiverEndpoint)Activator.CreateInstance(this.endpointType);

            if (null == endpoint)
                throw new CreateEndpointFailed(this.endpointType.FullName, Url);

            endpoint.Open(Url, pConfig, pBizTalkConfig, this.HandlerPropertyBag, this.TransportProxy, this.TransportType, this.PropertyNamespace, this.control);

            this.endpoints[Url] = endpoint;
        }
        public void UpdateEndpointConfig (string Url, IPropertyBag pConfig, IPropertyBag pBizTalkConfig)
        {
            if (!this.Initialized)
                throw new NotInitialized();

            ReceiverEndpoint endpoint = (ReceiverEndpoint)this.endpoints[Url];

            if (null == endpoint)
                throw new EndpointNotExists(Url);

            //  delegate the update call to the endpoint instance itself
            endpoint.Update(pConfig, pBizTalkConfig, this.HandlerPropertyBag);
		}
        public void RemoveReceiveEndpoint (string Url)
        {
			if (!this.Initialized)
				throw new NotInitialized();

			ReceiverEndpoint endpoint = (ReceiverEndpoint)this.endpoints[Url];

			if (null == endpoint)
				return;

			this.endpoints.Remove(Url);
			endpoint.Dispose();
		}

        public ReceiverEndpoint GetEndpoint(string url)
        {
            ReceiverEndpoint endpoint;
            this.endpoints.TryGetValue(url, out endpoint);

            return endpoint;
        }

        //  IBTransportControl
        public override void Initialize (IBTTransportProxy transportProxy)
        {
			base.Initialize(transportProxy);
		}

        public override void Terminate ()
        {
            try
            {
                base.Terminate();
                foreach (ReceiverEndpoint endpoint in this.endpoints.Values)
                {
                    endpoint.Dispose();
                }
                this.endpoints.Clear();
                this.endpoints = null;

                //  Block until we are done...
                this.control.Terminate();
            }
            finally
            {
                this.Dispose();
            }
		}
    }
}
