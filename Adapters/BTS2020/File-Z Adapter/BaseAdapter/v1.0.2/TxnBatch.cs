//---------------------------------------------------------------------
// File: TxnBatch.cs
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
using System.IO;
using System.Transactions;
using System.Threading;
using System.Runtime.InteropServices;
using Microsoft.BizTalk.TransportProxy.Interop;
using Microsoft.BizTalk.Message.Interop;

namespace Microsoft.Samples.BizTalk.Adapter.Common
{
	public class TxnBatch : Batch
	{
        public TxnBatch(IBTTransportProxy transportProxy, ControlledTermination control, CommittableTransaction transaction, ManualResetEvent orderedEvent, bool makeSuccessCall) : base(transportProxy, makeSuccessCall)
        {
			this.control = control;

            this.comTxn = TransactionInterop.GetDtcTransaction(transaction);

            //  the System.Transactions transaction - must be the original transaction - only that can be used to commit
            this.transaction = transaction;

			this.orderedEvent = orderedEvent;
		}
        public TxnBatch(IBTTransportProxy transportProxy, ControlledTermination control, IDtcTransaction comTxn, CommittableTransaction transaction, ManualResetEvent orderedEvent, bool makeSuccessCall) : base(transportProxy, makeSuccessCall)
        {
            this.control = control;
            this.comTxn = comTxn;
            this.transaction = transaction;
            this.orderedEvent = orderedEvent;
        }
        public override void Done ()
		{
            this.CommitConfirm = base.Done(this.comTxn);
		}
		protected override void EndBatchComplete ()
		{
			if (this.pendingWork)
			{
				return;
			}
			try
			{
				if (this.needToAbort)
				{
                    this.transaction.Rollback();

                    this.CommitConfirm.DTCCommitConfirm(this.comTxn, false); 
				}
				else
				{
                    this.transaction.Commit();

                    this.CommitConfirm.DTCCommitConfirm(this.comTxn, true); 
				}
			}
			catch
			{
				try
				{
					this.CommitConfirm.DTCCommitConfirm(this.comTxn, false); 
				}
				catch
				{
				}
			}
			//  note the pending work check at the top of this function removes the need to check a needToLeave flag
			this.control.Leave();

			if (this.orderedEvent != null)
				this.orderedEvent.Set();
		}
        protected void SetAbort()
        {
            this.needToAbort = true;
        }
        protected void SetComplete()
        {
            this.needToAbort = false;
        }
        protected void SetPendingWork()
		{
			this.pendingWork = true;
		}
		protected IBTDTCCommitConfirm CommitConfirm
		{
			set
			{
				this.commitConfirm = value;
				this.commitConfirmEvent.Set();
			}
			get
			{
				this.commitConfirmEvent.WaitOne();
				return this.commitConfirm;
			}
		}
        protected IDtcTransaction comTxn;
        protected CommittableTransaction transaction;
        protected ControlledTermination control;
		protected IBTDTCCommitConfirm commitConfirm = null;
		protected ManualResetEvent orderedEvent;
		private ManualResetEvent commitConfirmEvent = new ManualResetEvent(false);
		private bool needToAbort = true;
		private bool pendingWork = false;
	}
}
