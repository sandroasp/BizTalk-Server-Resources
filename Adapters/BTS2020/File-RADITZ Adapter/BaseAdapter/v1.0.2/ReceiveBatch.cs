//---------------------------------------------------------------------
// File: ReceiveBatch.cs
// 
// Summary: Implementation of an adapter framework sample adapter. 
// This class constitutes one of the BaseAdapter classes, which, are
// a set of generic re-usable set of classes to help adapter writers.
//
// Sample: Base Adapter Class Library v1.0.2
//
// Description: Batching logic intended for Receive side adapters - supports submitting messages
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
using System.IO;
using System.Threading;
using System.Runtime.InteropServices;
using System.Diagnostics;
using Microsoft.BizTalk.TransportProxy.Interop;
using Microsoft.BizTalk.Message.Interop;
using System.Collections;

namespace Microsoft.Samples.BizTalk.Adapter.Common
{
    public delegate void ReceiveBatchCompleteHandler(bool overallStatus);

    public class ReceiveBatch : Batch
    {
        public ReceiveBatch (IBTTransportProxy transportProxy, ControlledTermination control, ManualResetEvent orderedEvent, int depth) : base(transportProxy, true)
        {
            this.control = control;
            this.orderedEvent = orderedEvent;
            this.innerBatch = null;
            this.depth = depth;
        }

        public ReceiveBatch(IBTTransportProxy transportProxy, ControlledTermination control, ReceiveBatchCompleteHandler callback, int depth) : base(transportProxy, true)
        {
            this.control = control;

            if( callback != null )
            {
                this.ReceiveBatchComplete += callback;
            }

            this.innerBatch = null;
            this.depth = depth;
        }

        protected override void StartProcessFailures ()
        {
            // Keep a recusive batch depth so we stop trying at some point.
            if (!this.OverallSuccess && this.depth > 0)
            {
                //  we don't at this point care about ordering with respect to failures
                if (orderedEvent != null)
                {
                    this.innerBatch = new ReceiveBatch(this.TransportProxy, this.control, this.orderedEvent, this.depth - 1);
                    this.innerBatch.ReceiveBatchComplete = this.ReceiveBatchComplete;
                }
                else
                {
                    this.innerBatch = new ReceiveBatch(this.TransportProxy, this.control, this.ReceiveBatchComplete, this.depth - 1);
                }
                this.innerBatchCount = 0;
            }
        }
        protected override void EndProcessFailures ()
        {
            if (this.innerBatch != null && this.innerBatchCount > 0)
            {
                try
                {
                    this.innerBatch.Done(null);
                    this.needToLeave = false;
                }
                catch (Exception e)
                {
                    Trace.WriteLine("ReceiveBatch.EndProcessFailures Exception: {0}", e.Message);
                    this.innerBatch = null;
                }
            }
        }
        protected override void EndBatchComplete ()
        {
            if (this.needToLeave)
                this.control.Leave();

            //  if there is no pending work and we have been given an event to set then set it!
            if (this.innerBatch == null)
            {
                // Theoretically, suspend should never fail unless DB is down/not-reachable
                // or the stream is not seekable. In such cases, there is a chance of duplicates
                // but that's safer than deleting messages that are not in the DB.
                if (this.ReceiveBatchComplete != null)
                    this.ReceiveBatchComplete(this.OverallSuccess && !this.suspendFailed);

                if (this.orderedEvent != null)
                    this.orderedEvent.Set();
            }
        }

        protected override void SubmitFailure (IBaseMessage message, Int32 hrStatus, object userData)
        {
            failedMessages.Add(new FailedMessage(message, hrStatus));
            Stream originalStream = message.BodyPart.GetOriginalDataStream();

            if (this.innerBatch != null)
            {
                try
                {
                    originalStream.Seek(0, SeekOrigin.Begin);
                    message.BodyPart.Data = originalStream;
                    this.innerBatch.MoveToSuspendQ(message, userData);
                    this.innerBatchCount++;
                }
                catch (Exception e)
                {
                    Trace.WriteLine("ReceiveBatch.SubmitFailure Exception: {0}", e.Message);
                    this.innerBatch = null;
                }
            }
        }
        protected override void SubmitSuccess (IBaseMessage message, Int32 hrStatus, object userData)
        {
            Stream originalStream = message.BodyPart.GetOriginalDataStream();

            if (this.innerBatch != null)
            {
                failedMessages.Add(new FailedMessage(message, hrStatus));
                // this good message was caught up with some bad ones - it needs to be submitted again
                try
                {
                    originalStream.Seek(0, SeekOrigin.Begin);
                    message.BodyPart.Data = originalStream;
                    this.innerBatch.SubmitMessage(message, userData);
                    this.innerBatchCount++;
                }
                catch(Exception e)
                {
                    Trace.WriteLine("ReceiveBatch.SubmitSuccess Exception: {0}", e.Message);
                    this.innerBatch = null;
                }
            }
            else
            {
                originalStream.Close();
            }
        }

        protected override void SubmitRequestFailure(IBaseMessage message, int hrStatus, object userData)
        {
            failedMessages.Add(new FailedMessage(message, hrStatus));
            Stream originalStream = message.BodyPart.GetOriginalDataStream();

            if (this.innerBatch != null)
            {
                try
                {
                    originalStream.Seek(0, SeekOrigin.Begin);
                    message.BodyPart.Data = originalStream;
                    this.innerBatch.MoveToSuspendQ(message, userData);
                    this.innerBatchCount++;
                }
                catch (Exception e)
                {
                    Trace.WriteLine("ReceiveBatch.SubmitFailure Exception: {0}", e.Message);
                    this.innerBatch = null;
                }
            }
        }

        protected override void SubmitRequestSuccess(IBaseMessage message, int hrStatus, object userData)
        {
            Stream originalStream = message.BodyPart.GetOriginalDataStream();

            if (this.innerBatch != null)
            {
                failedMessages.Add(new FailedMessage(message, hrStatus));
                try
                {
                    originalStream.Seek(0, SeekOrigin.Begin);
                    message.BodyPart.Data = originalStream;
                    this.innerBatch.SubmitMessage(message, userData);
                    this.innerBatchCount++;
                }
                catch (Exception e)
                {
                    Trace.WriteLine("ReceiveBatch.SubmitSuccess Exception: {0}", e.Message);
                    this.innerBatch = null;
                }
            }
            else
            {
                originalStream.Close();
            }
        }

        protected override void MoveToSuspendQFailure (IBaseMessage message, Int32 hrStatus, object userData)
        {
            suspendFailed = true;

            Stream originalStream = message.BodyPart.GetOriginalDataStream();
            originalStream.Close();
        }

        protected override void MoveToSuspendQSuccess (IBaseMessage message, Int32 hrStatus, object userData)
        {
            Stream originalStream = message.BodyPart.GetOriginalDataStream();

            //  We may not be done: so if we have successful suspends from last time then suspend them again
            if (this.innerBatch != null)
            {
                try
                {
                    originalStream.Seek(0, SeekOrigin.Begin);
                    message.BodyPart.Data = originalStream;
                    this.innerBatch.MoveToSuspendQ(message, userData);
                    this.innerBatchCount++;
                }
                catch (Exception e)
                {
                    Trace.WriteLine("ReceiveBatch.MoveToSuspendQSuccess Exception: {0}", e.Message);
                    this.innerBatch = null;
                }
            }
            else
            {
                originalStream.Close();
            }
        }
        private bool needToLeave = true;
        private ControlledTermination control;
        private ReceiveBatch innerBatch;
        private int innerBatchCount;
        private ManualResetEvent orderedEvent;
        private int depth;
        private bool suspendFailed = false;

        private ArrayList failedMessages = new ArrayList();

        public ArrayList FailedMessages
        {
            get { return failedMessages; }
            set { failedMessages = value; }
        }

        public event ReceiveBatchCompleteHandler ReceiveBatchComplete;
    }

    public class FailedMessage
    {
        private IBaseMessage message;
        private int status;

        public IBaseMessage Message
        {
            get { return message; }
            set { message = value; }
        }

        public int Status
        {
            get { return status; }
            set { status = value; }
        }

        public FailedMessage(IBaseMessage message, int status)
        {
            this.message = message;
            this.status = status;
        }
    }
}
