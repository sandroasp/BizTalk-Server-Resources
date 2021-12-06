/*************************************************************************************************
 This class is provided to surface Adapter as a binding element, so that it 
 can be used within a user-defined WCF "Custom Binding".

 In configuration file, it is defined under
     <system.serviceModel>
         <extensions>
             <bindingElementExtensions>
                 <add name="{name}" type="{this}, {assembly}"/>
             </bindingElementExtensions>
         </extensions>
     </system.serviceModel>
     
**************************************************************************************************/

using System;
using System.Configuration;
using System.ServiceModel;
using System.ServiceModel.Channels;
using System.ServiceModel.Configuration;

namespace Microsoft.BizTalk.WCFLoopback
{
    public class WCFLoopbackAdapterBindingElementExtension : BindingElementExtensionElement
    {
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

        #region Constructors

        /// <summary>
        /// Default constructor
        /// </summary>
        public WCFLoopbackAdapterBindingElementExtension()
        {
        }

        #endregion

        #region Overriden Base Class Methods

        /// <summary>
        /// Return the type of the adapter (binding element)
        /// </summary>
        public override Type BindingElementType
        {
            get
            {
                return typeof(WCFLoopbackAdapter);
            }
        }

        /// <summary>
        /// Return all the properites defined in this class.
        /// </summary>
        protected override ConfigurationPropertyCollection Properties
        {
            get
            {
                ConfigurationPropertyCollection properties = base.Properties;
                properties.Add(new ConfigurationProperty(WCFLoopbackAdapterConfigurationStrings.PreserveProperties, typeof(int), WCFLoopbackAdapterConfigurationDefaults.DefaultPreserveProperties));
                return properties;
            }
        }

        /// <summary>
        /// Instantiate the adapter.
        /// </summary>
        /// <returns></returns>
        protected override BindingElement CreateBindingElement()
        {
            WCFLoopbackAdapter adapter = new WCFLoopbackAdapter();
            this.ApplyConfiguration(adapter);
            return adapter;
        }

        /// <summary>
        /// Pass the properties from configuration file to the adapter.
        /// </summary>
        /// <param name="bindingElement"></param>
        public override void ApplyConfiguration(BindingElement bindingElement)
        {
            base.ApplyConfiguration(bindingElement);
            WCFLoopbackAdapter adapter = ((WCFLoopbackAdapter)(bindingElement));
            adapter.PreserveProperties = this.PreserveProperties;

        }

        /// <summary>
        /// Initialize the binding properties from the adapter.
        /// </summary>
        /// <param name="bindingElement"></param>
        protected override void InitializeFrom(BindingElement bindingElement)
        {
            base.InitializeFrom(bindingElement);
            WCFLoopbackAdapter adapter = ((WCFLoopbackAdapter)(bindingElement));
            this.PreserveProperties = adapter.PreserveProperties;
        }

        /// <summary>
        /// 
        /// </summary>
        /// <param name="from"></param>
        public override void CopyFrom(ServiceModelExtensionElement from)
        {
            base.CopyFrom(from);
            WCFLoopbackAdapterBindingElementExtension source = ((WCFLoopbackAdapterBindingElementExtension)(from));
            this.PreserveProperties = source.PreserveProperties;
        }

        #endregion
    }

    /// <summary>
    /// Configuration strings for the binding properties
    /// </summary>
    public class WCFLoopbackAdapterConfigurationStrings
    {
        internal const string PreserveProperties = "preserveProperties";
    }

    /// <summary>
    /// Provide defaults for the custom binding properties over here.
    /// </summary>
    public class WCFLoopbackAdapterConfigurationDefaults
    {
        internal const bool DefaultPreserveProperties = false;
    }
}
