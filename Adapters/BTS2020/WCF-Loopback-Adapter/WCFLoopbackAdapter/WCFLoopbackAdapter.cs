using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.ServiceModel.Description;
using System.ServiceModel.Channels;

using Microsoft.ServiceModel.Channels.Common;


namespace Microsoft.BizTalk.WCFLoopback
{
    public class WCFLoopbackAdapter: Adapter
    {
        #region Private Fields

        // Scheme associated with the adapter
        internal const string SCHEME = "loopback";
        // Namespace for the proxy that will be generated from the adapter schema
        internal const string SERVICENAMESPACE = "loopback://LoopbackAdapter";
        // Adapter environment settings
        private static AdapterEnvironmentSettings _environmentSettings = new AdapterEnvironmentSettings();

        #endregion

        #region Fields Custom Generated

        private bool _preserveProperties;
        
        #endregion

        #region Constructors

         /// <summary>
        /// Initializes a new instance of the WCFLoopbackAdapter class
        /// </summary>
        public WCFLoopbackAdapter()
            : base(_environmentSettings)
        {
            this.Settings.Metadata.GenerateWsdlDocumentation = true;
        }

        public WCFLoopbackAdapter(WCFLoopbackAdapter binding)
            : base(binding)
        {
            this.PreserveProperties = binding.PreserveProperties;
            this.Settings.Metadata.GenerateWsdlDocumentation = true;
        }

        #endregion

        #region Properties Custom Generated

        [System.Configuration.ConfigurationProperty(WCFLoopbackAdapterConfigurationStrings.PreserveProperties, DefaultValue = WCFLoopbackAdapterConfigurationDefaults.DefaultPreserveProperties)]
        public bool PreserveProperties
        {
            get
            {
                return this._preserveProperties;
            }
            set
            {
                this._preserveProperties = value;
            }
        }

        #endregion

        #region Public Properties

        /// <summary>
        /// Gets the URI transport scheme that is used by the adapter
        /// </summary>
        public override string Scheme
        {
            get
            {
                return SCHEME;
            }
        }

        public string ServiceNamespace
        {
            get
            {
                return SERVICENAMESPACE;
            }
        }

        #endregion

        #region Protected Methods

        /// <summary>
        /// Creates a ConnectionUri instance from the provided Uri
        /// </summary>
        protected override ConnectionUri BuildConnectionUri(Uri uri)
        {
            return new WCFLoopbackAdapterConnectionUri(uri);
        }

        /// <summary>
        /// Builds a connection factory from the ConnectionUri and ClientCredentials
        /// </summary>
        /// <param name="unifiedConnectionUri"></param>
        /// <param name="clientCredentials"></param>
        /// <param name="context"></param>
        /// <returns></returns>
        protected override IConnectionFactory BuildConnectionFactory(
            ConnectionUri unifiedConnectionUri
            , ClientCredentials clientCredentials
            , BindingContext context)
        {
            return new WCFLoopbackAdapterConnectionFactory(unifiedConnectionUri, clientCredentials, this);
        }

        /// <summary>
        /// Returns a clone of the adapter object
        /// </summary>
        /// <returns>A clone of the adapter object</returns>
        protected override Adapter CloneAdapter()
        {
            return new WCFLoopbackAdapter(this);
        }

        /// <summary>
        /// Indicates whether the provided TConnectionHandler is supported by the adapter or not
        /// </summary>
        /// <typeparam name="TConnectionHandler">IConnectionHandler type</typeparam>
        /// <returns>A Boolean indicating whether the provided TConnectionHandler is supported by the adapter or not</returns>
        protected override bool IsHandlerSupported<TConnectionHandler>()
        {
            return (typeof(IOutboundHandler) == typeof(TConnectionHandler));
        }

        /// <summary>
        /// Gets the namespace that is used when generating schema and WSDL
        /// </summary>
        protected override string Namespace
        {
            get
            {
                return SERVICENAMESPACE;
            }
        }

        #endregion
    }
}
