using System;
using System.Collections.Generic;
using System.Text;
using System.ServiceModel;
using System.ServiceModel.Configuration;
using System.ServiceModel.Channels;
using System.Configuration;
using System.Globalization;
using Microsoft.ServiceModel.Channels.Common;

namespace Microsoft.BizTalk.WCFLoopback
{
    public class WCFLoopbackAdapterBindingElement : StandardBindingElement
    {
        #region Constructors

        /// <summary>
        /// Initializes a new instance of the LoopbackAdapterBindingElement class
        /// </summary>
        public WCFLoopbackAdapterBindingElement()
            : base(null)
        {
        }

        /// <summary>
        /// Initializes a new instance of the LoopbackAdapterBindingElement class with a configuration name
        /// </summary>
        public WCFLoopbackAdapterBindingElement(string configurationName)
            : base(configurationName)
        {
        }

        #endregion

        #region Protected Properties

        /// <summary>
        /// Gets the type of the BindingElement
        /// </summary>
        protected override Type BindingElementType
        {
            get
            {
                return typeof(WCFLoopbackAdapterBinding);
            }
        }

        #endregion

        #region BindingElement Members

        /// <summary>
        /// Initializes the binding with the configuration properties
        /// </summary>
        /// <param name="baseBinding"></param>
        protected override void InitializeFrom(Binding baseBinding)
        {
            base.InitializeFrom(baseBinding);
            WCFLoopbackAdapterBinding binding = (WCFLoopbackAdapterBinding)baseBinding;
            this[WCFLoopbackAdapterConfigurationStrings.PreserveProperties] = binding.PreserveProperties;
        }

        /// <summary>
        /// Applies the configuration
        /// </summary>
        /// <param name="baseBinding"></param>
        protected override void OnApplyConfiguration(Binding baseBinding)
        {
            if (baseBinding == null)
            {
                throw new ArgumentNullException("binding");
            }

            WCFLoopbackAdapterBinding binding = (WCFLoopbackAdapterBinding)baseBinding;
            binding.PreserveProperties = (bool)this[WCFLoopbackAdapterConfigurationStrings.PreserveProperties];
        }

        /// <summary>
        /// Returns a collection of the configuration properties
        /// </summary>
        protected override ConfigurationPropertyCollection Properties
        {
            get
            {
                ConfigurationPropertyCollection properties = base.Properties;
                properties.Add(new ConfigurationProperty(WCFLoopbackAdapterConfigurationStrings.PreserveProperties, typeof(bool), WCFLoopbackAdapterConfigurationDefaults.DefaultPreserveProperties, null, null, ConfigurationPropertyOptions.None));
                return properties;
            }
        }

        #endregion

        #region Adapter Custom Configuration Properties

        [ConfigurationProperty(WCFLoopbackAdapterConfigurationStrings.PreserveProperties, DefaultValue = WCFLoopbackAdapterConfigurationDefaults.DefaultPreserveProperties)]
        [System.ComponentModel.Category("Adapter Properties")]
        public bool PreserveProperties
        {
            get
            {
                return ((bool)(base[WCFLoopbackAdapterConfigurationStrings.PreserveProperties]));
            }
            set
            {
                base[WCFLoopbackAdapterConfigurationStrings.PreserveProperties] = value;
            }
        }

        #endregion
    }
}
