using System;
using System.Collections.Generic;
using System.Text;
using System.IdentityModel.Selectors;
using System.ServiceModel.Description;
using Microsoft.ServiceModel.Channels.Common;

namespace Microsoft.BizTalk.WCFLoopback
{
    public class WCFLoopbackAdapterConnectionFactory : IConnectionFactory
    {
        #region Private Fields

        // Stores the client credentials
        private ClientCredentials _clientCredentials;
        // Stores the adapter class
        private WCFLoopbackAdapter _adapter;

        #endregion

        #region Constructors

        /// <summary>
        /// Initializes a new instance of the LoopbackAdapterConnectionFactory class
        /// </summary>
        public WCFLoopbackAdapterConnectionFactory(ConnectionUri connectionUri
            , ClientCredentials clientCredentials
            , WCFLoopbackAdapter adapter)
        {
            this._clientCredentials = clientCredentials;
            this._adapter = adapter;
        }

        #endregion

        #region Public Properties

        /// <summary>
        /// Gets the adapter
        /// </summary>
        public WCFLoopbackAdapter Adapter
        {
            get
            {
                return this._adapter;
            }
        }

        /// <summary>
        /// Returns the client credentials
        /// </summary>
        public ClientCredentials ClientCredentials
        {
            get
            {
                return this._clientCredentials;
            }
        }

        #endregion

        #region Public Methods

        /// <summary>
        /// Creates the connection to the target system
        /// </summary>
        /// <returns>IConnection</returns>
        public IConnection CreateConnection()
        {
            return new WCFLoopbackAdapterConnection(this);
        }

        #endregion
    }
}
