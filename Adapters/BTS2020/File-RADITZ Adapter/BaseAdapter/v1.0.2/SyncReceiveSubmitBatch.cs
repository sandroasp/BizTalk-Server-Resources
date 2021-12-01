//---------------------------------------------------------------------
// File: SyncReceiveSubmitBatch.cs
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
using System.Threading;
using System.Collections.Generic;
using Microsoft.BizTalk.TransportProxy.Interop;
using Microsoft.BizTalk.Message.Interop;

namespace Microsoft.Samples.BizTalk.Adapter.Common
{
    public class SyncReceiveSubmitBatch : ReceiveBatch
    {
        private ManualResetEvent workDone;
        private bool overallSuccess = false;
        private ControlledTermination control;

        public SyncReceiveSubmitBatch(IBTTransportProxy transportProxy, ControlledTermination control, int depth)
            : this(transportProxy, control, new ManualResetEvent(false), depth) { }

        private SyncReceiveSubmitBatch(IBTTransportProxy transportProxy, ControlledTermination control,
                                        ManualResetEvent submitComplete, int depth)
            : base(transportProxy, control, submitComplete, depth)
        {
            this.control = control;
            this.workDone = submitComplete;
            base.ReceiveBatchComplete += new ReceiveBatchCompleteHandler(OnBatchComplete);
        }

        private void OnBatchComplete(bool overallSuccess)
        {
            this.overallSuccess = overallSuccess;
        }

        public override void Done()
        {
            bool needToLeave = control.Enter();

            try
            {
                base.Done();
            }
            catch
            {
                if (needToLeave)
                    control.Leave();

                throw;
            }
        }

        public bool Wait()
        {
            this.workDone.WaitOne();

            return this.overallSuccess;
        }
    }
}