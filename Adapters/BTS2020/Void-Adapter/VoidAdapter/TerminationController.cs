//---------------------------------------------------------------------
// File: TerminationController.cs
// 
// Summary: Class used to ensure the adapter is terminated correctly, 
// waiting for existing operations to complete.
//
// Sample: Void Adapter
//---------------------------------------------------------------------

using System;
using System.Threading;

namespace Microsoft.BizTalk.Void.Adapter
{
    /// <summary>
    /// Class used to ensure the adapter is terminated correctly, waiting for existing operations to complete.
    /// </summary>
    internal class TerminationController
    {
        #region Properties

        private AutoResetEvent autoResetEvent = new AutoResetEvent(true);
        private int opCount;
        private bool terminating;

        #endregion

        #region Public Methods

        /// <summary>
        /// Creates a new instance
        /// </summary>
        public TerminationController()
        {
        }

        /// <summary>
        /// Increase the reference count because a new operation is in progress
        /// </summary>
        /// <exception cref="InvalidOperationException">If the adapter is terminating</exception>
        public void Enter()
        {
            if (terminating)
            {
                throw new InvalidOperationException("Adapter is terminating...");
            }

            autoResetEvent.Reset();
            Interlocked.Increment(ref opCount);
        }

        /// <summary>
        /// Decrement the reference count because a operation is terminating
        /// </summary>
        public void Leave()
        {
            if (Interlocked.Decrement(ref opCount) == 0)
            {
                autoResetEvent.Set();
            }
        }

        /// <summary>
        /// Terminate the adapter. We don't allow new operations after this point
        /// </summary>
        public void Terminate()
        {
            terminating = true;
            autoResetEvent.WaitOne();
        }

        #endregion
    } 
}