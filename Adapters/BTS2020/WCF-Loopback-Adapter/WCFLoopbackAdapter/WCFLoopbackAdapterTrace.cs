using System;
using System.Collections.Generic;
using System.Text;
using Microsoft.ServiceModel.Channels.Common;

namespace Microsoft.BizTalk.WCFLoopback
{
    // Use LoopbackAdapterUtilities.Trace in the code to trace the adapter
    public class WCFLoopbackAdapterUtilities
    {
        #region Private Fields

        static AdapterTrace _trace;

        #endregion

        #region Constructors

        static WCFLoopbackAdapterUtilities()
        {
            // Initializes a new instance of  Microsoft.ServiceModel.Channels.Common.AdapterTrace using the specified name for the source
            _trace = new AdapterTrace("WCFLoopbackAdapter");
        }

        #endregion

        /// <summary>
        /// Gets the AdapterTrace
        /// </summary>
        public static AdapterTrace Trace
        {
            get
            {
                return _trace;
            }
        }
    }
}

