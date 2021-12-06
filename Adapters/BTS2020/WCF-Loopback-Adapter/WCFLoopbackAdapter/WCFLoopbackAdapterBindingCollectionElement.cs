using System;
using System.Collections.Generic;
using System.Text;
using System.ServiceModel;
using System.ServiceModel.Configuration;
using Microsoft.ServiceModel.Channels.Common;

namespace Microsoft.BizTalk.WCFLoopback
{
    /// <summary>
    /// Initializes a new instance of the WCFLoopbackAdapterBindingCollectionElement class
    /// </summary>
    public class WCFLoopbackAdapterBindingCollectionElement : StandardBindingCollectionElement<WCFLoopbackAdapterBinding,
        WCFLoopbackAdapterBindingElement>
    {
    }
}

