using System;
using System.IO;
using System.Collections.Generic;
using System.Text;
using Microsoft.ServiceModel.Channels.Common;

namespace Microsoft.BizTalk.WCFLoopback
{
    public class WCFLoopbackAdapterConnection : IConnection
    {
        #region Private Fields

        private WCFLoopbackAdapterConnectionFactory _connectionFactory;
        private string _connectionId;

        #endregion

        #region Constructors

        /// <summary>
        /// Initializes a new instance of the LoopbackAdapterConnection class with the LoopbackAdapterConnectionFactory
        /// </summary>
        public WCFLoopbackAdapterConnection(WCFLoopbackAdapterConnectionFactory connectionFactory)
        {
            this._connectionFactory = connectionFactory;
            this._connectionId = Guid.NewGuid().ToString();
        }

        #endregion

        #region Public Properties

        /// <summary>
        /// Gets the ConnectionFactory
        /// </summary>
        public WCFLoopbackAdapterConnectionFactory ConnectionFactory
        {
            get
            {
                return this._connectionFactory;
            }
        }

        #endregion

        #region IConnection Members

        /// <summary>
        /// Closes the connection to the target system
        /// </summary>
        public void Close(TimeSpan timeout)
        {
        }

        /// <summary>
        /// Returns a value indicating whether the connection is still valid
        /// </summary>
        /// <returns>Boolean</returns>
        public bool IsValid(TimeSpan timeout)
        {
            return true;
        }

        /// <summary>
        /// Opens the connection to the target system.
        /// </summary>
        public void Open(TimeSpan timeout)
        {
        }

        /// <summary>
        /// Clears the context of the Connection. This method is called when the connection is set back to the connection pool
        /// </summary>
        public void ClearContext()
        {
        }

        /// <summary>
        /// Builds a new instance of the specified IConnectionHandler type
        /// </summary>
        /// <typeparam name="TConnectionHandler">IConnectionHandler type</typeparam>
        /// /// <param name="metadataLookup">The MetadataLookup to use to retrieve operation metadata for the messages</param>
        /// <returns>A new instance of the specified IConnectionHandler type</returns>
        public TConnectionHandler BuildHandler<TConnectionHandler>(MetadataLookup metadataLookup)
             where TConnectionHandler : class, IConnectionHandler
        {
            if (typeof(IOutboundHandler).IsAssignableFrom(typeof(TConnectionHandler)))
            {
                return new WCFLoopbackAdapterOutboundHandler(this, metadataLookup) as TConnectionHandler;
            }

            return default(TConnectionHandler);
        }

        /// <summary>
        /// Aborts the connection to the target system
        /// </summary>
        public void Abort()
        {
            // throw new NotImplementedException("The method or operation is not implemented.");
        }

        /// <summary>
        /// Gets the Id of the Connection
        /// </summary>
        public String ConnectionId
        {
            get
            {
                return _connectionId;
            }
        }

        #endregion
    }
}
