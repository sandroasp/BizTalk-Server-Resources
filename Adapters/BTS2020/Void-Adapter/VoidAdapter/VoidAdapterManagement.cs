//---------------------------------------------------------------------
// File: VoidAdapterManagement.cs
// 
// Summary: Adapter Management class for the VoidAdapter.
//
// Sample: Void Adapter
//---------------------------------------------------------------------

using System;
using System.IO;
using System.Reflection;
using System.Resources;
using System.Xml;
using Microsoft.BizTalk.Component.Interop;
using Microsoft.BizTalk.Adapter.Framework;

namespace Microsoft.BizTalk.Void.Adapter
{
    /// <summary>
    /// Adapter Management class for the VoidAdapter.
    /// </summary>
    public class VoidAdapterManagement
      : IAdapterConfig,
          IStaticAdapterConfig,
        IAdapterConfigValidation
    {
        private const string NS = "Microsoft.BizTalk.Void.Adapter";

        #region IAdapterConfig Members

        public string GetConfigSchema(ConfigType configType)
        {
            if (configType == ConfigType.TransmitLocation)
            {
                string resName = NS + "." + "SendPortSchema.xsd";

                Assembly asm = Assembly.GetExecutingAssembly();
                Stream stream = asm.GetManifestResourceStream(resName);
                using (StreamReader reader = new StreamReader(stream))
                {
                    return reader.ReadToEnd();
                }
            }
            return null;
        }

        public Result GetSchema(string uri, string namespaceName, out string fileLocation)
        {
            fileLocation = null;
            return Result.Continue;
        }

        #endregion

        #region IStaticAdapterConfig Members

        public string GetServiceOrganization(IPropertyBag endPointConfiguration, string nodeIdentifier)
        {
            return null;
        }

        public string[] GetServiceDescription(string[] wsdlReferences)
        {
            return null;
        }

        #endregion

        #region IAdapterConfigValidation Members

        /// <summary>
        /// Validate the configuration of the send port.
        /// In here we load the configuration and create a new URI for the send port based on the value of the name
        /// attribute introduced by the user.
        /// </summary>
        /// <param name="configType">Configuration Type</param>
        /// <param name="configuration">Configuration XML</param>
        /// <returns>The new Configuration XML</returns>
        public string ValidateConfiguration(ConfigType configType, string configuration)
        {
            if (configType != ConfigType.TransmitLocation)
                return configuration;

            XmlDocument doc = new XmlDocument();
            doc.LoadXml(configuration);

            XmlNode uriNode = doc.SelectSingleNode("CustomProps/uri");
            if (uriNode == null)
            {
                uriNode = doc.CreateElement("uri");
                doc.DocumentElement.AppendChild(uriNode);
            }

            XmlNode nameNode = doc.SelectSingleNode("CustomProps/name");
            if (nameNode == null || nameNode.InnerText.Trim().Length == 0)
            {
                throw new InvalidOperationException("Name cannot be blank");
            }
            uriNode.InnerText = "null://" + nameNode.InnerText.Trim();

            return doc.OuterXml;
        }

        #endregion
    } 
}