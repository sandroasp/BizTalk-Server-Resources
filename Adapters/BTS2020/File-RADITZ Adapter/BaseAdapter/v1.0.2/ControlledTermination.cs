//---------------------------------------------------------------------
// File: ControlledTermination.cs
// 
// Summary: Implementation of an adapter framework sample adapter. 
// This class constitutes one of the BaseAdapter classes, which, are
// a set of generic re-usable set of classes to help adapter writers.
//
// Sample: Base Adapter Class Library v1.0.1
//
// Description: This class is used to keep count of work in flight, an
// adapter should not return from terminate if it has work outstanding
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

namespace Microsoft.Samples.BizTalk.Adapter.Common
{
    public class ControlledTermination : IDisposable
    {
        private AutoResetEvent e = new AutoResetEvent(false);
        private int activityCount = 0;
        private bool terminate = false;

        //  to be called at the start of the activity
        //  returns false if terminate has been called
        public bool Enter ()
        {
            lock (this)
            {
                if (true == this.terminate)
                {
                    return false;
                }

                this.activityCount++;
            }
            return true;
        }

        //  to be called at the end of the activity
        public void Leave ()
        {
            lock (this)
            {
                this.activityCount--;

                // Set the event only if Terminate() is called
                if (this.activityCount == 0 && this.terminate)
                    this.e.Set();
            }
        }

        //  this method blocks waiting for any activity to complete
        public void Terminate ()
        {
            bool result;

            lock (this)
            {
                this.terminate = true;
                result = (this.activityCount == 0);
            }

            // If activity count was not zero, wait for pending activities
            if (!result)
            {
                this.e.WaitOne();
            }
        }

        public bool TerminateCalled
        {
            get
            { 
                lock (this)
                {
                    return this.terminate;
                }
            }
        }

        public void Dispose()
        {
            ((IDisposable)this.e).Dispose();
        }
    }
}