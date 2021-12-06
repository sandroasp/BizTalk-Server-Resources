using System;
using System.Collections.Generic;
using System.Text;
using System.ServiceModel;
using System.ServiceModel.Channels;
using System.ServiceModel.Configuration;
using Microsoft.ServiceModel.Channels.Common;

namespace Microsoft.BizTalk.WCFLoopback
{
    public class WCFLoopbackAdapterBinding : AdapterBinding
    {
        #region Private Fields

        // Scheme in Binding does not have to be the same as Adapter Scheme. 
        // Over write this value as appropriate.
        private const string BindingScheme = "loopback";

        #endregion

        #region Constructors

        /// <summary>
        /// Initializes a new instance of the AdapterBinding class
        /// </summary>
        public WCFLoopbackAdapterBinding()
        {
        }

        /// <summary>
        /// Initializes a new instance of the AdapterBinding class with a configuration name
        /// </summary>
        public WCFLoopbackAdapterBinding(string configName)
        {
            ApplyConfiguration(configName);
        }

        #endregion

        #region Private Methods

        private void ApplyConfiguration(string configurationName)
        {
           throw new NotImplementedException("The method or operation is not implemented.");
        }

        #endregion

        #region Private Fields

        private WCFLoopbackAdapter binding;

        #endregion 

        #region Public Properties

        /// <summary>
        /// Gets the URI transport scheme that is used by the channel and listener factories that are built by the bindings.
        /// </summary>
        public override string Scheme
        {
            get
            {
                return BindingScheme;
            }
        }

        /// <summary>
        /// Returns a value indicating whether this binding supports metadata browsing.
        /// </summary>
        public override bool SupportsMetadataBrowse
        {
            get
            {
                return false;
            }
        }

        /// <summary>
        /// Returns a value indicating whether this binding supports metadata retrieval.
        /// </summary>
        public override bool SupportsMetadataGet
        {
            get
            {
                return false;
            }
        }

        /// <summary>
        /// Returns a value indicating whether this binding supports metadata searching.
        /// </summary>
        public override bool SupportsMetadataSearch
        {
            get
            {
                return false;
            }
        }

        /// <summary>
        /// Returns the custom type of the ConnectionUri.
        /// </summary>
        public override Type ConnectionUriType
        {
            get
            {
                return typeof(WCFLoopbackAdapterConnectionUri);
            }
        }

        #endregion 

        #region Properties Custom Generated

        private bool _preserveProperties;

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

        #region Private Properties

        private WCFLoopbackAdapter BindingElement
        {
            get
            {
                if (binding == null)
                {
                    binding = new WCFLoopbackAdapter();
                }

                binding.PreserveProperties = this.PreserveProperties;

                return binding;
            }
        }

        #endregion

        #region Public Methods

        public override BindingElementCollection CreateBindingElements()
        {
            BindingElementCollection bindingElements = new BindingElementCollection();
            bindingElements.Add(this.BindingElement);
            return bindingElements.Clone();
        }

        #endregion
    }
}
